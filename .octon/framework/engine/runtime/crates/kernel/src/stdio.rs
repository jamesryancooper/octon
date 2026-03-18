use crate::context::KernelContext;
use octon_core::errors::{ErrorCode, KernelError};
use octon_core::jsonlines::{read_json_line, write_json_line};
use octon_core::registry::{ServiceKey};
use octon_core::trace::TraceWriter;
use octon_wasm_host::cancel::CancelHandle;
use octon_wasm_host::policy::GrantSet;
use serde_json::json;
use std::collections::HashMap;
use std::io;
use std::sync::{mpsc, Arc, Mutex};

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

    let protocol = hello
        .get("protocol")
        .and_then(|v| v.as_str())
        .unwrap_or("");
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
                let trace_id = meta.get("trace_id").and_then(|v| v.as_str()).map(|s| s.to_string());
                let deadline_ms = meta.get("deadline_ms").and_then(|v| v.as_u64());

                let ctx = ctx.clone();
                let out_tx = out_tx.clone();
                let inflight = inflight.clone();

                let worker = std::thread::spawn(move || {
                    let trace = TraceWriter::new(&ctx.cfg.state_dir, trace_id).ok();

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

                    // Policy gate.
                    let grants = match ctx.policy.decide_allow(&service) {
                        Ok(caps) => GrantSet::new(caps),
                        Err(e) => {
                            let _ = out_tx.send(response_error(&id, e));
                            let _ = inflight.lock().unwrap().remove(&id);
                            return;
                        }
                    };

                    let result = ctx.invoker.invoke(
                        &service,
                        grants,
                        &op,
                        input,
                        trace.as_ref(),
                        deadline_ms,
                        Some(handle_tx),
                    );

                    match result {
                        Ok(v) => {
                            let _ = out_tx.send(response_ok(&id, v));
                        }
                        Err(e) => {
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
