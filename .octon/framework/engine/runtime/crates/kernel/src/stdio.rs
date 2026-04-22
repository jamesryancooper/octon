use crate::context::KernelContext;
use crate::request;
use octon_authority_engine::{
    artifact_root_from_relative, authorize_execution, finalize_execution, now_rfc3339,
    validate_authorized_effect, write_execution_start, AuthorizedEffect, ExecutionArtifactEffects,
    ExecutionOutcome, ExecutionRequest, GrantBundle, ReviewRequirements, ScopeConstraints,
    ServiceInvocation, SideEffectFlags, SideEffectSummary,
};
use octon_core::errors::{ErrorCode, KernelError};
use octon_core::execution_integrity::service_capability_profile;
use octon_core::jsonlines::{read_json_line, write_json_line};
use octon_core::registry::ServiceKey;
use octon_core::trace::TraceWriter;
use octon_wasm_host::cancel::CancelHandle;
use octon_wasm_host::policy::GrantSet;
use serde_json::json;
use std::collections::HashMap;
use std::io;
use std::sync::{mpsc, Arc, Mutex};

fn artifact_effects_for_root(
    root: &std::path::Path,
    grant: &GrantBundle,
) -> anyhow::Result<ExecutionArtifactEffects> {
    Ok(grant.execution_artifact_effects(root.display().to_string())?)
}

fn service_grants_for_effect(
    grant: &GrantBundle,
    effect: &AuthorizedEffect<ServiceInvocation>,
) -> anyhow::Result<GrantSet> {
    validate_authorized_effect(grant, effect)?;
    Ok(GrantSet::new(grant.granted_capabilities.clone()))
}

#[derive(Default)]
struct InflightEntry {
    handle: Option<CancelHandle>,
    cancel_requested: bool,
}

pub fn serve_stdio(ctx: Arc<KernelContext>) -> anyhow::Result<()> {
    let max_line = ctx.cfg.ndjson_max_line_bytes;

    let mut stdin = io::BufReader::new(io::stdin());
    let mut stdout = io::BufWriter::new(io::stdout());

    // --- Handshake ---
    let hello = match read_json_line(&mut stdin, max_line) {
        Ok(Some(v)) => v,
        Ok(None) => return Ok(()),
        Err(e) => {
            // Handshake errors are uncorrelated.
            let msg = json!({"type":"error","error": e.as_error_object()});
            let _ = write_json_line(&mut stdout, &msg);
            return Ok(());
        }
    };

    let protocol = hello.get("protocol").and_then(|v| v.as_str()).unwrap_or("");
    let msg_type = hello.get("type").and_then(|v| v.as_str()).unwrap_or("");

    if msg_type != "hello" || protocol != "octon-stdio-v1" {
        let err = KernelError::new(
            ErrorCode::ProtocolUnsupported,
            "unsupported or missing protocol (expected octon-stdio-v1)",
        )
        .with_details(json!({"received_type": msg_type, "received_protocol": protocol}));
        let msg = json!({"type":"error","error": err.as_error_object()});
        let _ = write_json_line(&mut stdout, &msg);
        return Ok(());
    }

    let hello_resp = json!({
        "type": "hello",
        "protocol": "octon-stdio-v1",
        "kernel": {
            "version": env!("CARGO_PKG_VERSION"),
            "os": std::env::consts::OS,
            "arch": std::env::consts::ARCH,
        }
    });
    write_json_line(&mut stdout, &hello_resp)?;

    // Writer thread for responses/events.
    let (out_tx, out_rx) = mpsc::channel::<serde_json::Value>();
    std::thread::spawn(move || {
        let mut stdout = io::BufWriter::new(io::stdout());
        for msg in out_rx {
            let _ = write_json_line(&mut stdout, &msg);
        }
    });

    let inflight: Arc<Mutex<HashMap<String, InflightEntry>>> = Arc::new(Mutex::new(HashMap::new()));
    let mut workers: Vec<std::thread::JoinHandle<()>> = Vec::new();

    // --- Main loop ---
    loop {
        let v = match read_json_line(&mut stdin, max_line) {
            Ok(Some(v)) => v,
            Ok(None) => break,
            Err(e) => {
                // Uncorrelated parse/size error.
                let msg = json!({"type":"error","error": e.as_error_object()});
                let _ = out_tx.send(msg);
                continue;
            }
        };

        let msg_type = v.get("type").and_then(|v| v.as_str()).unwrap_or("");
        if msg_type != "request" {
            let err = KernelError::new(ErrorCode::MalformedJson, "expected type=request");
            let msg = json!({"type":"error","error": err.as_error_object()});
            let _ = out_tx.send(msg);
            continue;
        }

        let id = match v.get("id").and_then(|v| v.as_str()) {
            Some(s) => s.to_string(),
            None => {
                let err = KernelError::new(ErrorCode::MalformedJson, "request missing id");
                let msg = json!({"type":"error","error": err.as_error_object()});
                let _ = out_tx.send(msg);
                continue;
            }
        };

        let method = v.get("method").and_then(|v| v.as_str()).unwrap_or("");

        match method {
            "tool.invoke" => {
                // Prevent duplicate ids.
                {
                    let mut map = inflight.lock().unwrap();
                    if map.contains_key(&id) {
                        let err = KernelError::new(
                            ErrorCode::Internal,
                            format!("duplicate request id '{id}'"),
                        );
                        let msg = response_error(&id, err);
                        let _ = out_tx.send(msg);
                        continue;
                    }
                    map.insert(id.clone(), InflightEntry::default());
                }

                let params = v.get("params").cloned().unwrap_or(json!({}));
                let service_name = params
                    .get("service")
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .to_string();
                let category = params
                    .get("category")
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .to_string();
                let op = params
                    .get("op")
                    .and_then(|v| v.as_str())
                    .unwrap_or("")
                    .to_string();
                let input = params.get("input").cloned().unwrap_or(json!({}));

                let meta = v.get("meta").cloned().unwrap_or(json!({}));
                let trace_id = meta
                    .get("trace_id")
                    .and_then(|v| v.as_str())
                    .map(|s| s.to_string());
                let deadline_ms = meta.get("deadline_ms").and_then(|v| v.as_u64());

                let ctx = ctx.clone();
                let out_tx = out_tx.clone();
                let inflight = inflight.clone();

                let worker = std::thread::spawn(move || {
                    // Register a cancel handle as soon as one becomes available.
                    let (handle_tx, handle_rx) = mpsc::channel::<CancelHandle>();
                    let inflight_reg = inflight.clone();
                    let id_reg = id.clone();
                    std::thread::spawn(move || {
                        if let Ok(handle) = handle_rx.recv() {
                            let mut map = inflight_reg.lock().unwrap();
                            if let Some(entry) = map.get_mut(&id_reg) {
                                let cancel_now = entry.cancel_requested;
                                entry.handle = Some(handle.clone());
                                if cancel_now {
                                    handle.cancel();
                                }
                            }
                        }
                    });

                    // Resolve service.
                    let svc = {
                        let key = ServiceKey {
                            category: category.clone(),
                            name: service_name.clone(),
                        };
                        ctx.registry.get(&key).cloned()
                    };

                    let Some(service) = svc else {
                        let err = KernelError::new(
                            ErrorCode::UnknownService,
                            format!("unknown service '{category}/{service_name}'"),
                        );
                        let _ = out_tx.send(response_error(&id, err));
                        let _ = inflight.lock().unwrap().remove(&id);
                        return;
                    };
                    let service_profile = service_capability_profile(
                        &service.key.id(),
                        &input,
                        &service.manifest.capabilities_required,
                    );
                    let (intent_ref, execution_role_ref, metadata) =
                        match request::bind_repo_local_request(
                            &ctx.cfg,
                            service_profile.metadata.clone(),
                        ) {
                            Ok(bindings) => bindings,
                            Err(error) => {
                                let err = KernelError::new(
                                    ErrorCode::CapabilityDenied,
                                    format!("failed to bind canonical execution request: {error}"),
                                );
                                let _ = out_tx.send(response_error(&id, err));
                                let _ = inflight.lock().unwrap().remove(&id);
                                return;
                            }
                        };

                    let request = ExecutionRequest {
                        request_id: format!("stdio-{id}"),
                        caller_path: "service".to_string(),
                        action_type: "invoke_service".to_string(),
                        target_id: format!("{}::{op}", service.key.id()),
                        requested_capabilities: service_profile.requested_capabilities.clone(),
                        side_effect_flags: SideEffectFlags {
                            write_evidence: true,
                            state_mutation: true,
                            network: service_profile.network_target_url.is_some(),
                            ..SideEffectFlags::default()
                        },
                        risk_tier: "medium".to_string(),
                        workflow_mode: request::role_mediated_mode(),
                        locality_scope: None,
                        intent_ref: Some(intent_ref),
                        autonomy_context: None,
                        execution_role_ref: Some(execution_role_ref),
                        parent_run_ref: None,
                        review_requirements: ReviewRequirements::default(),
                        scope_constraints: ScopeConstraints {
                            read: vec!["service-input".to_string()],
                            write: vec!["service-state".to_string()],
                            executor_profile: None,
                            locality_scope: None,
                        },
                        policy_mode_requested: None,
                        environment_hint: None,
                        metadata,
                        ..ExecutionRequest::default()
                    };
                    let grant = match authorize_execution(
                        &ctx.cfg,
                        &ctx.policy,
                        &request,
                        Some(&service),
                    ) {
                        Ok(grant) => grant,
                        Err(e) => {
                            let _ = out_tx.send(response_error(&id, e));
                            let _ = inflight.lock().unwrap().remove(&id);
                            return;
                        }
                    };
                    let artifact_root = artifact_root_from_relative(
                        &ctx.cfg.repo_root,
                        &ctx.cfg.execution_governance.receipt_roots.services,
                        &request.request_id,
                    );
                    let artifact_effects = match artifact_effects_for_root(&artifact_root, &grant) {
                        Ok(effects) => effects,
                        Err(error) => {
                            let err = KernelError::new(
                                ErrorCode::Internal,
                                format!("failed to issue stdio artifact effects: {error}"),
                            );
                            let _ = out_tx.send(response_error(&id, err));
                            let _ = inflight.lock().unwrap().remove(&id);
                            return;
                        }
                    };
                    let artifacts = match write_execution_start(
                        &artifact_root,
                        &request,
                        &grant,
                        &artifact_effects,
                    ) {
                        Ok(paths) => paths,
                        Err(error) => {
                            let err = KernelError::new(
                                ErrorCode::Internal,
                                format!("failed to create stdio execution artifacts: {error}"),
                            );
                            let _ = out_tx.send(response_error(&id, err));
                            let _ = inflight.lock().unwrap().remove(&id);
                            return;
                        }
                    };
                    let started_at = match now_rfc3339() {
                        Ok(value) => value,
                        Err(error) => {
                            let err = KernelError::new(
                                ErrorCode::Internal,
                                format!("failed to capture stdio start timestamp: {error}"),
                            );
                            let _ = out_tx.send(response_error(&id, err));
                            let _ = inflight.lock().unwrap().remove(&id);
                            return;
                        }
                    };
                    let service_effect = match grant
                        .service_invocation_effect(format!("{}::{op}", service.key.id()))
                    {
                        Ok(effect) => effect,
                        Err(error) => {
                            let err = KernelError::new(
                                ErrorCode::CapabilityDenied,
                                format!("failed to issue stdio service effect: {error}"),
                            );
                            let _ = out_tx.send(response_error(&id, err));
                            let _ = inflight.lock().unwrap().remove(&id);
                            return;
                        }
                    };
                    let grants = match service_grants_for_effect(&grant, &service_effect) {
                        Ok(grants) => grants,
                        Err(error) => {
                            let err = KernelError::new(
                                ErrorCode::CapabilityDenied,
                                format!("failed to validate stdio service effect: {error}"),
                            );
                            let _ = out_tx.send(response_error(&id, err));
                            let _ = inflight.lock().unwrap().remove(&id);
                            return;
                        }
                    };
                    let run_root = ctx.cfg.repo_root.join(&grant.run_root);
                    if let Err(error) = ctx.cfg.ensure_execution_write_path(&run_root) {
                        let _ = out_tx.send(response_error(&id, error));
                        let _ = inflight.lock().unwrap().remove(&id);
                        return;
                    }
                    let trace = TraceWriter::new(&run_root, trace_id).ok();

                    let result = ctx.invoker.invoke(
                        &service,
                        grants,
                        &op,
                        input,
                        trace.as_ref(),
                        &run_root,
                        service_profile.adapter_id.as_deref(),
                        deadline_ms,
                        Some(handle_tx),
                    );

                    match result {
                        Ok(v) => {
                            let _ = finalize_execution(
                                &artifacts,
                                &request,
                                &grant,
                                &artifact_effects,
                                &started_at,
                                &ExecutionOutcome {
                                    status: "succeeded".to_string(),
                                    started_at: started_at.clone(),
                                    completed_at: now_rfc3339()
                                        .unwrap_or_else(|_| started_at.clone()),
                                    error: None,
                                },
                                &SideEffectSummary {
                                    touched_scope: vec!["service-state".to_string()],
                                    ..SideEffectSummary::default()
                                },
                            );
                            let _ = out_tx.send(response_ok(&id, v));
                        }
                        Err(e) => {
                            let _ = finalize_execution(
                                &artifacts,
                                &request,
                                &grant,
                                &artifact_effects,
                                &started_at,
                                &ExecutionOutcome {
                                    status: "failed".to_string(),
                                    started_at: started_at.clone(),
                                    completed_at: now_rfc3339()
                                        .unwrap_or_else(|_| started_at.clone()),
                                    error: Some(e.to_string()),
                                },
                                &SideEffectSummary {
                                    touched_scope: vec!["service-state".to_string()],
                                    ..SideEffectSummary::default()
                                },
                            );
                            let _ = out_tx.send(response_error(&id, e));
                        }
                    }

                    let _ = inflight.lock().unwrap().remove(&id);
                });
                workers.push(worker);
            }

            "cancel" => {
                let target = v
                    .get("params")
                    .and_then(|p| p.get("id"))
                    .and_then(|x| x.as_str())
                    .unwrap_or("")
                    .to_string();

                let mut map = inflight.lock().unwrap();
                if let Some(entry) = map.get_mut(&target) {
                    entry.cancel_requested = true;
                    if let Some(h) = entry.handle.as_ref() {
                        h.cancel();
                    }
                    let _ = out_tx.send(response_ok(&id, json!({"cancelled": true, "id": target})));
                } else {
                    let _ = out_tx.send(response_ok(
                        &id,
                        json!({"cancelled": false, "id": target, "reason": "not_found_or_done"}),
                    ));
                }
            }

            _ => {
                let err = KernelError::new(
                    ErrorCode::UnknownMethod,
                    format!("unknown method '{method}'"),
                )
                .with_details(json!({"method": method}));
                let _ = out_tx.send(response_error(&id, err));
            }
        }
    }

    // Ensure all in-flight requests finish before process exit so piped stdio
    // sessions receive their final responses.
    for worker in workers {
        let _ = worker.join();
    }

    Ok(())
}

fn response_ok(id: &str, result: serde_json::Value) -> serde_json::Value {
    json!({
        "id": id,
        "type": "response",
        "ok": true,
        "result": result,
    })
}

fn response_error(id: &str, err: KernelError) -> serde_json::Value {
    json!({
        "id": id,
        "type": "response",
        "ok": false,
        "error": err.as_error_object(),
    })
}
