use crate::context::KernelContext;
use crate::orchestration;
use crate::pipeline;
use crate::request_builders as request;
use crate::run_binding;
use crate::scaffold;
use crate::stdio;
use crate::workflow::{self, ExecutorKind};
use anyhow::Result;
use octon_authority_engine::{
    artifact_root_from_relative, authorize_execution, finalize_execution, now_rfc3339,
    validate_authorized_effect, write_execution_start, AuthorizedEffect, ExecutionArtifactEffects,
    ExecutionOutcome, ExecutionRequest, ExecutorLaunch, GrantBundle, RepoMutation,
    ReviewRequirements, ScopeConstraints, ServiceInvocation, SideEffectFlags,
    SideEffectSummary,
};
use octon_core::errors::{ErrorCode, KernelError};
use octon_core::execution_integrity::service_capability_profile;
use octon_core::tiers::validate_runtime_discovery_tiers;
use octon_core::trace::TraceWriter;
use octon_wasm_host::policy::GrantSet;
use serde_yaml::{Mapping, Value};
use std::collections::{BTreeMap, HashMap};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command as ProcessCommand;
use std::sync::Arc;

use super::{
    Command, OrchestrationCmd, OrchestrationIncidentCmd, OrchestrationSurfaceArg, RunCmd,
    ServiceCmd, ServicesCmd, WorkflowCmd,
};

fn artifact_effects_for_root(root: &Path, grant: &GrantBundle) -> Result<ExecutionArtifactEffects> {
    Ok(grant.execution_artifact_effects(root.display().to_string())?)
}

fn invoke_service_with_effect(
    ctx: &KernelContext,
    grant: &GrantBundle,
    effect: &AuthorizedEffect<ServiceInvocation>,
    svc: &octon_core::registry::ServiceDescriptor,
    op: &str,
    input: serde_json::Value,
    trace: Option<&TraceWriter>,
    run_root: &Path,
    adapter_id: Option<&str>,
) -> Result<serde_json::Value> {
    validate_authorized_effect(grant, effect)?;
    let grants = GrantSet::new(grant.granted_capabilities.clone());
    Ok(ctx
        .invoker
        .invoke(svc, grants, op, input, trace, run_root, adapter_id, None, None)?)
}

fn scaffold_service_new_with_effect(
    octon_dir: &Path,
    category: &str,
    name: &str,
    grant: &GrantBundle,
    effect: &AuthorizedEffect<RepoMutation>,
) -> Result<()> {
    validate_authorized_effect(grant, effect)?;
    scaffold::service_new(octon_dir, category, name)
}

fn scaffold_service_build_with_effect(
    octon_dir: &Path,
    category: &str,
    name: &str,
    grant: &GrantBundle,
    effect: &AuthorizedEffect<RepoMutation>,
) -> Result<()> {
    validate_authorized_effect(grant, effect)?;
    scaffold::service_build(octon_dir, category, name)
}

fn ensure_dir_with_executor_effect(
    path: &Path,
    grant: &GrantBundle,
    effect: &AuthorizedEffect<ExecutorLaunch>,
) -> Result<()> {
    validate_authorized_effect(grant, effect)?;
    std::fs::create_dir_all(path)?;
    Ok(())
}

pub(crate) fn dispatch(cmd: Command) -> Result<()> {
    match cmd {
        Command::Doctor { architecture } => cmd_doctor(architecture),
        Command::Info => cmd_info(),
        Command::Services { cmd } => cmd_services(cmd),
        Command::Tool { service, op, json } => cmd_tool(&service, &op, json.as_deref()),
        Command::Validate => cmd_validate(),
        Command::ServeStdio => cmd_serve_stdio(),
        Command::Studio => cmd_studio(),
        Command::Service { cmd } => cmd_service(cmd),
        Command::Run { cmd } => cmd_run(cmd),
        Command::Workflow { cmd } => cmd_workflow(cmd),
        Command::Orchestration { cmd } => cmd_orchestration(cmd),
    }
}

fn cmd_doctor(architecture: bool) -> Result<()> {
    let ctx = KernelContext::load()?;
    if !architecture {
        anyhow::bail!("doctor currently requires --architecture");
    }

    let validator = ctx
        .cfg
        .octon_dir
        .join("framework")
        .join("assurance")
        .join("runtime")
        .join("_ops")
        .join("scripts")
        .join("validate-architecture-health.sh");

    let status = ProcessCommand::new("bash")
        .arg(&validator)
        .env("OCTON_DIR_OVERRIDE", &ctx.cfg.octon_dir)
        .env("OCTON_ROOT_DIR", &ctx.cfg.repo_root)
        .status()?;

    if status.success() {
        Ok(())
    } else {
        anyhow::bail!("architecture health validation failed")
    }
}

fn cmd_info() -> Result<()> {
    let ctx = KernelContext::load()?;
    println!("octon kernel v{}", env!("CARGO_PKG_VERSION"));
    println!("repo_root: {}", ctx.cfg.repo_root.display());
    println!("octon_dir: {}", ctx.cfg.octon_dir.display());
    println!("run_evidence_root: {}", ctx.cfg.run_evidence_root.display());
    println!(
        "execution_control_root: {}",
        ctx.cfg.execution_control_root.display()
    );
    println!(
        "execution_tmp_root: {}",
        ctx.cfg.execution_tmp_root.display()
    );
    println!("os: {}", std::env::consts::OS);
    println!("arch: {}", std::env::consts::ARCH);
    println!("services: {}", ctx.registry.list().len());
    Ok(())
}

fn cmd_services(cmd: ServicesCmd) -> Result<()> {
    let ctx = KernelContext::load()?;
    match cmd {
        ServicesCmd::List => {
            for svc in ctx.registry.list() {
                println!("{} @ {} ({})", svc.key.id(), svc.version, svc.dir.display());
            }
        }
    }
    Ok(())
}

fn cmd_validate() -> Result<()> {
    let ctx = KernelContext::load()?;

    // Discovery already validates service.json schema and optional integrity hash.
    println!("discovered {} services", ctx.registry.list().len());

    for svc in ctx.registry.list() {
        println!("ok: {} @ {}", svc.key.id(), svc.version);
    }

    if let Some(report) = validate_runtime_discovery_tiers(&ctx.cfg.octon_dir, &ctx.registry)? {
        println!(
            "runtime tiers ok: {} services ({} + {})",
            report.service_count,
            report.manifest_path.display(),
            report.registry_path.display()
        );
    } else {
        println!("runtime tiers: not configured (manifest.runtime.yml not found)");
    }

    Ok(())
}

fn cmd_tool(service_id_or_name: &str, op: &str, input_json: Option<&str>) -> Result<()> {
    let ctx = KernelContext::load()?;

    let svc = ctx
        .registry
        .resolve_id(service_id_or_name)
        .ok_or_else(|| KernelError::new(ErrorCode::UnknownService, "unknown service"))?;

    let input: serde_json::Value = match input_json {
        Some(s) => serde_json::from_str(s).map_err(|e| {
            KernelError::new(ErrorCode::MalformedJson, format!("invalid --json: {e}"))
        })?,
        None => serde_json::json!({}),
    };
    let service_profile =
        service_capability_profile(&svc.key.id(), &input, &svc.manifest.capabilities_required);
    let (intent_ref, execution_role_ref, metadata) =
        request::bind_repo_observe_request(&ctx.cfg, service_profile.metadata.clone())?;

    let request = ExecutionRequest {
        request_id: new_request_id("tool"),
        caller_path: "service".to_string(),
        action_type: "invoke_service".to_string(),
        target_id: format!("{}::{op}", svc.key.id()),
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
    let grant = authorize_execution(&ctx.cfg, &ctx.policy, &request, Some(svc))?;
    run_binding::ensure_canonical_run_binding(&ctx.cfg, &request, &grant, "tool")?;
    let artifact_root = artifact_root_from_relative(
        &ctx.cfg.repo_root,
        &ctx.cfg.execution_governance.receipt_roots.services,
        &request.request_id,
    );
    let artifact_effects = artifact_effects_for_root(&artifact_root, &grant)?;
    let artifacts = write_execution_start(&artifact_root, &request, &grant, &artifact_effects)?;
    let started_at = now_rfc3339()?;
    let run_root = ctx.cfg.repo_root.join(&grant.run_root);
    ctx.cfg.ensure_execution_write_path(&run_root)?;
    let trace = TraceWriter::new(&run_root, None).ok();
    let service_effect = grant.service_invocation_effect(format!("{}::{op}", svc.key.id()))?;
    let out = invoke_service_with_effect(
        &ctx,
        &grant,
        &service_effect,
        svc,
        op,
        input,
        trace.as_ref(),
        &run_root,
        service_profile.adapter_id.as_deref(),
    )?;
    finalize_execution(
        &artifacts,
        &request,
        &grant,
        &artifact_effects,
        &started_at,
        &ExecutionOutcome {
            status: "succeeded".to_string(),
            started_at: started_at.clone(),
            completed_at: now_rfc3339()?,
            error: None,
        },
        &SideEffectSummary {
            touched_scope: vec!["service-state".to_string()],
            ..SideEffectSummary::default()
        },
    )?;

    println!("{}", serde_json::to_string_pretty(&out)?);
    Ok(())
}

fn cmd_serve_stdio() -> Result<()> {
    let ctx = Arc::new(KernelContext::load()?);
    stdio::serve_stdio(ctx)
}

fn cmd_studio() -> Result<()> {
    let ctx = KernelContext::load()?;
    let octon_dir = ctx.cfg.octon_dir.clone();
    let runtime_dir = octon_dir.join("framework").join("engine").join("runtime");
    let manifest_path = runtime_dir.join("crates").join("Cargo.toml");
    let target_dir = octon_dir
        .join("generated")
        .join(".tmp")
        .join("engine")
        .join("build")
        .join("runtime-crates-target");
    let (intent_ref, execution_role_ref, metadata) =
        request::bind_repo_local_request(&ctx.cfg, BTreeMap::new())?;

    let request = ExecutionRequest {
        request_id: new_request_id("studio"),
        caller_path: "kernel".to_string(),
        action_type: "launch_executor".to_string(),
        target_id: "octon-studio".to_string(),
        requested_capabilities: vec![
            "engine.studio.launch".to_string(),
            "executor.shell".to_string(),
            "evidence.write".to_string(),
        ],
        side_effect_flags: SideEffectFlags {
            write_repo: true,
            write_evidence: true,
            shell: true,
            state_mutation: true,
            ..SideEffectFlags::default()
        },
        risk_tier: "medium".to_string(),
        workflow_mode: request::role_mediated_mode(),
        locality_scope: None,
        intent_ref: Some(intent_ref),
        autonomy_context: None,
        execution_role_ref: Some(execution_role_ref),
        parent_run_ref: None,
        review_requirements: ReviewRequirements {
            human_approval: true,
            quorum: false,
            rollback_metadata: false,
        },
        scope_constraints: ScopeConstraints {
            read: vec!["repo-root".to_string()],
            write: vec![target_dir.display().to_string()],
            executor_profile: Some("scoped_repo_mutation".to_string()),
            locality_scope: None,
        },
        policy_mode_requested: None,
        environment_hint: None,
        metadata,
        ..ExecutionRequest::default()
    };
    let grant = authorize_execution(&ctx.cfg, &ctx.policy, &request, None)?;
    run_binding::ensure_canonical_run_binding(&ctx.cfg, &request, &grant, "studio")?;
    let artifact_root = artifact_root_from_relative(
        &ctx.cfg.repo_root,
        &ctx.cfg.execution_governance.receipt_roots.executors,
        &request.request_id,
    );
    let artifact_effects = artifact_effects_for_root(&artifact_root, &grant)?;
    let artifacts = write_execution_start(&artifact_root, &request, &grant, &artifact_effects)?;
    let started_at = now_rfc3339()?;
    let executor_effect = grant.executor_launch_effect(target_dir.display().to_string())?;

    ensure_dir_with_executor_effect(&target_dir, &grant, &executor_effect)?;

    let status = ProcessCommand::new("cargo")
        .arg("run")
        .arg("--manifest-path")
        .arg(&manifest_path)
        .arg("-p")
        .arg("octon_studio")
        .arg("--bin")
        .arg("octon-studio")
        .current_dir(&octon_dir)
        .env("CARGO_TARGET_DIR", &target_dir)
        .status()?;

    finalize_execution(
        &artifacts,
        &request,
        &grant,
        &artifact_effects,
        &started_at,
        &ExecutionOutcome {
            status: if status.success() {
                "succeeded".to_string()
            } else {
                "failed".to_string()
            },
            started_at: started_at.clone(),
            completed_at: now_rfc3339()?,
            error: if status.success() {
                None
            } else {
                Some(format!("cargo run exited with status {status}"))
            },
        },
        &SideEffectSummary {
            touched_scope: vec![target_dir.display().to_string()],
            shell_commands: vec!["cargo run -p octon_studio --bin octon-studio".to_string()],
            executor_profile: Some("scoped_repo_mutation".to_string()),
            ..SideEffectSummary::default()
        },
    )?;

    if !status.success() {
        anyhow::bail!("octon studio exited with status {}", status);
    }

    Ok(())
}

fn cmd_service(cmd: ServiceCmd) -> Result<()> {
    let ctx = KernelContext::load()?;
    let octon_dir = ctx.cfg.octon_dir.clone();
    match cmd {
        ServiceCmd::New { category, name } => {
            let service_root = octon_dir
                .join("capabilities")
                .join("runtime")
                .join("services")
                .join(&category)
                .join(&name);
            let (intent_ref, execution_role_ref, metadata) =
                request::bind_repo_local_request(&ctx.cfg, BTreeMap::new())?;
            let request = ExecutionRequest {
                request_id: new_request_id("service-new"),
                caller_path: "kernel".to_string(),
                action_type: "mutate_repo".to_string(),
                target_id: format!("service-new:{category}/{name}"),
                requested_capabilities: vec![
                    "repo.write".to_string(),
                    "scaffold.service".to_string(),
                    "evidence.write".to_string(),
                ],
                side_effect_flags: SideEffectFlags {
                    write_repo: true,
                    write_evidence: true,
                    ..SideEffectFlags::default()
                },
                risk_tier: "medium".to_string(),
                workflow_mode: request::role_mediated_mode(),
                locality_scope: None,
                intent_ref: Some(intent_ref),
                autonomy_context: None,
                execution_role_ref: Some(execution_role_ref),
                parent_run_ref: None,
                review_requirements: ReviewRequirements {
                    human_approval: true,
                    quorum: false,
                    rollback_metadata: false,
                },
                scope_constraints: ScopeConstraints {
                    read: vec!["service-scaffold-template".to_string()],
                    write: vec![service_root.display().to_string()],
                    executor_profile: None,
                    locality_scope: None,
                },
                policy_mode_requested: None,
                environment_hint: None,
                metadata,
                ..ExecutionRequest::default()
            };
            let grant = authorize_execution(&ctx.cfg, &ctx.policy, &request, None)?;
            run_binding::ensure_canonical_run_binding(&ctx.cfg, &request, &grant, "service")?;
            let artifact_root = artifact_root_from_relative(
                &ctx.cfg.repo_root,
                &ctx.cfg.execution_governance.receipt_roots.kernel,
                &request.request_id,
            );
            let artifact_effects = artifact_effects_for_root(&artifact_root, &grant)?;
            let artifacts = write_execution_start(&artifact_root, &request, &grant, &artifact_effects)?;
            let started_at = now_rfc3339()?;
            let repo_effect = grant.repo_mutation_effect(service_root.display().to_string())?;
            scaffold_service_new_with_effect(&octon_dir, &category, &name, &grant, &repo_effect)?;
            finalize_execution(
                &artifacts,
                &request,
                &grant,
                &artifact_effects,
                &started_at,
                &ExecutionOutcome {
                    status: "succeeded".to_string(),
                    started_at: started_at.clone(),
                    completed_at: now_rfc3339()?,
                    error: None,
                },
                &SideEffectSummary {
                    touched_scope: vec![service_root.display().to_string()],
                    ..SideEffectSummary::default()
                },
            )?;
            println!(
                "created service scaffold at .octon/framework/capabilities/runtime/services/{category}/{name}"
            );
        }
        ServiceCmd::Build { target, name } => {
            let (category, name) = parse_category_name(&target, name.as_deref())?;
            let service_root = octon_dir
                .join("capabilities")
                .join("runtime")
                .join("services")
                .join(&category)
                .join(&name);
            let build_root = octon_dir
                .join("capabilities")
                .join("runtime")
                .join("services")
                .join("_ops")
                .join("state")
                .join("build")
                .join(format!("{category}-{name}-target"));
            let (intent_ref, execution_role_ref, metadata) =
                request::bind_repo_local_request(&ctx.cfg, BTreeMap::new())?;
            let request = ExecutionRequest {
                request_id: new_request_id("service-build"),
                caller_path: "kernel".to_string(),
                action_type: "build_service".to_string(),
                target_id: format!("service-build:{category}/{name}"),
                requested_capabilities: vec![
                    "repo.write".to_string(),
                    "executor.shell".to_string(),
                    "evidence.write".to_string(),
                ],
                side_effect_flags: SideEffectFlags {
                    write_repo: true,
                    write_evidence: true,
                    shell: true,
                    network: true,
                    state_mutation: true,
                    ..SideEffectFlags::default()
                },
                risk_tier: "medium".to_string(),
                workflow_mode: request::role_mediated_mode(),
                locality_scope: None,
                intent_ref: Some(intent_ref),
                autonomy_context: None,
                execution_role_ref: Some(execution_role_ref),
                parent_run_ref: None,
                review_requirements: ReviewRequirements {
                    human_approval: true,
                    quorum: false,
                    rollback_metadata: false,
                },
                scope_constraints: ScopeConstraints {
                    read: vec![service_root.display().to_string()],
                    write: vec![
                        service_root.display().to_string(),
                        build_root.display().to_string(),
                    ],
                    executor_profile: Some("scoped_repo_mutation".to_string()),
                    locality_scope: None,
                },
                policy_mode_requested: None,
                environment_hint: None,
                metadata,
                ..ExecutionRequest::default()
            };
            let grant = authorize_execution(&ctx.cfg, &ctx.policy, &request, None)?;
            run_binding::ensure_canonical_run_binding(&ctx.cfg, &request, &grant, "service")?;
            let artifact_root = artifact_root_from_relative(
                &ctx.cfg.repo_root,
                &ctx.cfg.execution_governance.receipt_roots.kernel,
                &request.request_id,
            );
            let artifact_effects = artifact_effects_for_root(&artifact_root, &grant)?;
            let artifacts = write_execution_start(&artifact_root, &request, &grant, &artifact_effects)?;
            let started_at = now_rfc3339()?;
            let repo_effect = grant.repo_mutation_effect(service_root.display().to_string())?;
            scaffold_service_build_with_effect(&octon_dir, &category, &name, &grant, &repo_effect)?;
            finalize_execution(
                &artifacts,
                &request,
                &grant,
                &artifact_effects,
                &started_at,
                &ExecutionOutcome {
                    status: "succeeded".to_string(),
                    started_at: started_at.clone(),
                    completed_at: now_rfc3339()?,
                    error: None,
                },
                &SideEffectSummary {
                    touched_scope: vec![
                        service_root.display().to_string(),
                        build_root.display().to_string(),
                    ],
                    shell_commands: vec![
                        "cargo fetch --locked --target wasm32-wasip1".to_string(),
                        "cargo component build --release --offline".to_string(),
                    ],
                    executor_profile: Some("scoped_repo_mutation".to_string()),
                    ..SideEffectSummary::default()
                },
            )?;
            println!("built service and updated integrity: {category}/{name}");
        }
    }
    Ok(())
}

fn cmd_workflow(cmd: WorkflowCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    match cmd {
        WorkflowCmd::List => {
            for workflow_item in pipeline::list_pipelines_from_octon_dir(&octon_dir)? {
                println!(
                    "{} @ {} ({}, {})",
                    workflow_item.id,
                    workflow_item.version,
                    workflow_item.path,
                    workflow_item.execution_profile
                );
            }
        }
        WorkflowCmd::Run {
            workflow_id,
            run_id,
            mission_id,
            set,
            executor,
            executor_bin,
            output_slug,
            model,
            prepare_only,
        } => {
            let _ = (
                workflow_id,
                run_id,
                mission_id,
                set,
                executor,
                executor_bin,
                output_slug,
                model,
                prepare_only,
            );
            anyhow::bail!(
                "workflow run is retired; start consequential execution with `octon run start --contract ...`"
            );
        }
        WorkflowCmd::Validate { workflow_id } => {
            pipeline::validate_pipelines_from_octon_dir(&octon_dir, workflow_id.as_deref())?;
            if let Some(workflow_id) = workflow_id {
                println!("validated canonical workflow: {workflow_id}");
            }
        }
    }
    Ok(())
}

fn cmd_run(cmd: RunCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    match cmd {
        RunCmd::Start {
            contract,
            executor,
            executor_bin,
            model,
            prepare_only,
        } => {
            let contract_path = resolve_octon_path(&octon_dir, &contract);
            let descriptor = load_run_descriptor(&octon_dir, &contract_path)?;
            run_descriptor_start(
                &octon_dir,
                descriptor,
                false,
                executor,
                executor_bin,
                model,
                prepare_only,
            )
        }
        RunCmd::Inspect { run_id } => {
            let descriptor = load_run_descriptor_by_id(&octon_dir, &run_id)?;
            print_run_inspection(&octon_dir, &descriptor)
        }
        RunCmd::Resume {
            run_id,
            executor,
            executor_bin,
            model,
            prepare_only,
        } => {
            let descriptor = load_run_descriptor_by_id(&octon_dir, &run_id)?;
            print_resume_summary(&octon_dir, &descriptor)?;
            run_descriptor_start(
                &octon_dir,
                descriptor,
                true,
                executor,
                executor_bin,
                model,
                prepare_only,
            )
        }
        RunCmd::Checkpoint { run_id } => {
            let descriptor = load_run_descriptor_by_id(&octon_dir, &run_id)?;
            print_yaml_file(&resolve_ref_path(
                &octon_dir,
                &descriptor.last_checkpoint_ref,
            )?)
        }
        RunCmd::Close { run_id } => {
            let descriptor = load_run_descriptor_by_id(&octon_dir, &run_id)?;
            print_yaml_file(&resolve_ref_path(&octon_dir, &descriptor.run_card_ref)?)
        }
        RunCmd::Replay { run_id } => {
            let descriptor = load_run_descriptor_by_id(&octon_dir, &run_id)?;
            print_yaml_file(&resolve_ref_path(
                &octon_dir,
                &descriptor.replay_manifest_ref,
            )?)
        }
        RunCmd::Disclose { run_id } => {
            let descriptor = load_run_descriptor_by_id(&octon_dir, &run_id)?;
            print_yaml_file(&resolve_ref_path(&octon_dir, &descriptor.run_card_ref)?)
        }
    }
}

fn cmd_orchestration(cmd: OrchestrationCmd) -> Result<()> {
    let ctx = KernelContext::load()?;
    let octon_dir = ctx.cfg.octon_dir.clone();
    let repo_root = octon_dir
        .parent()
        .ok_or_else(|| anyhow::anyhow!(".octon has no repository root"))?
        .to_path_buf();

    match cmd {
        OrchestrationCmd::Lookup {
            query,
            format,
            output_report,
        } => {
            let output_report = output_report
                .as_deref()
                .map(|path| resolve_output_path(&repo_root, path));
            if let Some(path) = output_report.as_ref() {
                let (intent_ref, execution_role_ref, metadata) =
                    request::bind_repo_local_request(&ctx.cfg, BTreeMap::new())?;
                let request = ExecutionRequest {
                    request_id: new_request_id("orchestration-lookup"),
                    caller_path: "kernel".to_string(),
                    action_type: "write_report".to_string(),
                    target_id: "orchestration-lookup".to_string(),
                    requested_capabilities: vec!["evidence.write".to_string()],
                    side_effect_flags: SideEffectFlags {
                        write_repo: true,
                        write_evidence: true,
                        ..SideEffectFlags::default()
                    },
                    risk_tier: "low".to_string(),
                    workflow_mode: request::role_mediated_mode(),
                    locality_scope: None,
                    intent_ref: Some(intent_ref),
                    autonomy_context: None,
                    execution_role_ref: Some(execution_role_ref),
                    parent_run_ref: None,
                    review_requirements: ReviewRequirements::default(),
                    scope_constraints: ScopeConstraints {
                        read: vec!["orchestration-state".to_string()],
                        write: vec![path.display().to_string()],
                        executor_profile: None,
                        locality_scope: None,
                    },
                    policy_mode_requested: None,
                    environment_hint: None,
                    metadata,
                    ..ExecutionRequest::default()
                };
                let grant = authorize_execution(&ctx.cfg, &ctx.policy, &request, None)?;
                let artifact_root = artifact_root_from_relative(
                    &ctx.cfg.repo_root,
                    &ctx.cfg.execution_governance.receipt_roots.kernel,
                    &request.request_id,
                );
                let artifact_effects = artifact_effects_for_root(&artifact_root, &grant)?;
                let artifacts = write_execution_start(&artifact_root, &request, &grant, &artifact_effects)?;
                let started_at = now_rfc3339()?;
                orchestration::write_lookup(
                    &octon_dir,
                    query.try_into()?,
                    format,
                    output_report.clone(),
                )?;
                finalize_execution(
                    &artifacts,
                    &request,
                    &grant,
                    &artifact_effects,
                    &started_at,
                    &ExecutionOutcome {
                        status: "succeeded".to_string(),
                        started_at: started_at.clone(),
                        completed_at: now_rfc3339()?,
                        error: None,
                    },
                    &SideEffectSummary {
                        touched_scope: vec![path.display().to_string()],
                        ..SideEffectSummary::default()
                    },
                )?;
                Ok(())
            } else {
                orchestration::write_lookup(&octon_dir, query.try_into()?, format, None)
            }
        }
        OrchestrationCmd::Summary {
            surface,
            format,
            output_report,
        } => {
            let output_report = output_report
                .as_deref()
                .map(|path| resolve_output_path(&repo_root, path));
            if let Some(path) = output_report.as_ref() {
                let (intent_ref, execution_role_ref, metadata) =
                    request::bind_repo_local_request(&ctx.cfg, BTreeMap::new())?;
                let request = ExecutionRequest {
                    request_id: new_request_id("orchestration-summary"),
                    caller_path: "kernel".to_string(),
                    action_type: "write_report".to_string(),
                    target_id: "orchestration-summary".to_string(),
                    requested_capabilities: vec!["evidence.write".to_string()],
                    side_effect_flags: SideEffectFlags {
                        write_repo: true,
                        write_evidence: true,
                        ..SideEffectFlags::default()
                    },
                    risk_tier: "low".to_string(),
                    workflow_mode: request::role_mediated_mode(),
                    locality_scope: None,
                    intent_ref: Some(intent_ref),
                    autonomy_context: None,
                    execution_role_ref: Some(execution_role_ref),
                    parent_run_ref: None,
                    review_requirements: ReviewRequirements::default(),
                    scope_constraints: ScopeConstraints {
                        read: vec!["orchestration-state".to_string()],
                        write: vec![path.display().to_string()],
                        executor_profile: None,
                        locality_scope: None,
                    },
                    policy_mode_requested: None,
                    environment_hint: None,
                    metadata,
                    ..ExecutionRequest::default()
                };
                let grant = authorize_execution(&ctx.cfg, &ctx.policy, &request, None)?;
                let artifact_root = artifact_root_from_relative(
                    &ctx.cfg.repo_root,
                    &ctx.cfg.execution_governance.receipt_roots.kernel,
                    &request.request_id,
                );
                let artifact_effects = artifact_effects_for_root(&artifact_root, &grant)?;
                let artifacts = write_execution_start(&artifact_root, &request, &grant, &artifact_effects)?;
                let started_at = now_rfc3339()?;
                orchestration::write_summary(
                    &octon_dir,
                    surface.into(),
                    format,
                    output_report.clone(),
                )?;
                finalize_execution(
                    &artifacts,
                    &request,
                    &grant,
                    &artifact_effects,
                    &started_at,
                    &ExecutionOutcome {
                        status: "succeeded".to_string(),
                        started_at: started_at.clone(),
                        completed_at: now_rfc3339()?,
                        error: None,
                    },
                    &SideEffectSummary {
                        touched_scope: vec![path.display().to_string()],
                        ..SideEffectSummary::default()
                    },
                )?;
                Ok(())
            } else {
                orchestration::write_summary(&octon_dir, surface.into(), format, None)
            }
        }
        OrchestrationCmd::Incident { cmd } => match cmd {
            OrchestrationIncidentCmd::ClosureReadiness {
                incident_id,
                format,
                output_report,
            } => {
                let output_report = output_report
                    .as_deref()
                    .map(|path| resolve_output_path(&repo_root, path));
                if let Some(path) = output_report.as_ref() {
                    let (intent_ref, execution_role_ref, metadata) =
                        request::bind_repo_local_request(&ctx.cfg, BTreeMap::new())?;
                    let request = ExecutionRequest {
                        request_id: new_request_id("orchestration-closure"),
                        caller_path: "kernel".to_string(),
                        action_type: "write_report".to_string(),
                        target_id: format!("incident-closure:{incident_id}"),
                        requested_capabilities: vec!["evidence.write".to_string()],
                        side_effect_flags: SideEffectFlags {
                            write_repo: true,
                            write_evidence: true,
                            ..SideEffectFlags::default()
                        },
                        risk_tier: "low".to_string(),
                        workflow_mode: request::role_mediated_mode(),
                        locality_scope: None,
                        intent_ref: Some(intent_ref),
                        autonomy_context: None,
                        execution_role_ref: Some(execution_role_ref),
                        parent_run_ref: None,
                        review_requirements: ReviewRequirements::default(),
                        scope_constraints: ScopeConstraints {
                            read: vec!["orchestration-state".to_string()],
                            write: vec![path.display().to_string()],
                            executor_profile: None,
                            locality_scope: None,
                        },
                        policy_mode_requested: None,
                        environment_hint: None,
                        metadata,
                        ..ExecutionRequest::default()
                    };
                    let grant = authorize_execution(&ctx.cfg, &ctx.policy, &request, None)?;
                    let artifact_root = artifact_root_from_relative(
                        &ctx.cfg.repo_root,
                        &ctx.cfg.execution_governance.receipt_roots.kernel,
                        &request.request_id,
                    );
                    let artifact_effects = artifact_effects_for_root(&artifact_root, &grant)?;
                    let artifacts =
                        write_execution_start(&artifact_root, &request, &grant, &artifact_effects)?;
                    let started_at = now_rfc3339()?;
                    orchestration::write_incident_closure_readiness(
                        &octon_dir,
                        &incident_id,
                        format,
                        output_report.clone(),
                    )?;
                    finalize_execution(
                        &artifacts,
                        &request,
                        &grant,
                        &artifact_effects,
                        &started_at,
                        &ExecutionOutcome {
                            status: "succeeded".to_string(),
                            started_at: started_at.clone(),
                            completed_at: now_rfc3339()?,
                            error: None,
                        },
                        &SideEffectSummary {
                            touched_scope: vec![path.display().to_string()],
                            ..SideEffectSummary::default()
                        },
                    )?;
                    Ok(())
                } else {
                    orchestration::write_incident_closure_readiness(
                        &octon_dir,
                        &incident_id,
                        format,
                        None,
                    )
                }
            }
        },
    }
}

fn parse_category_name(target: &str, name: Option<&str>) -> Result<(String, String)> {
    if let Some((category, service)) = target.split_once('/') {
        if category.is_empty() || service.is_empty() {
            anyhow::bail!("invalid service id '{target}', expected <category>/<name>");
        }
        if name.is_some() {
            anyhow::bail!("do not pass a separate name when target is <category>/<name>");
        }
        return Ok((category.to_string(), service.to_string()));
    }

    let name = name.ok_or_else(|| {
        anyhow::anyhow!("missing <NAME>: expected `service build <CATEGORY> <NAME>` or `service build <CATEGORY>/<NAME>`")
    })?;
    if name.is_empty() {
        anyhow::bail!("service name cannot be empty");
    }

    Ok((target.to_string(), name.to_string()))
}

fn new_request_id(prefix: &str) -> String {
    let millis = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|duration| duration.as_millis())
        .unwrap_or(0);
    format!("{prefix}-{millis}-{}", std::process::id())
}

fn resolve_output_path(repo_root: &Path, raw: &Path) -> PathBuf {
    if raw.is_absolute() {
        raw.to_path_buf()
    } else {
        repo_root.join(raw)
    }
}

#[derive(Debug, Clone)]
struct RunDescriptor {
    run_id: String,
    workflow_id: String,
    run_contract_ref: String,
    run_manifest_ref: String,
    runtime_state_ref: String,
    continuity_ref: String,
    replay_manifest_ref: String,
    run_card_ref: String,
    last_checkpoint_ref: String,
    mission_id: Option<String>,
}

fn resolve_octon_path(octon_dir: &Path, raw: &Path) -> PathBuf {
    if raw.is_absolute() {
        raw.to_path_buf()
    } else if raw.starts_with(".octon") {
        octon_dir.parent().unwrap_or(octon_dir).join(raw)
    } else {
        octon_dir.join(raw)
    }
}

fn resolve_ref_path(octon_dir: &Path, raw: &str) -> Result<PathBuf> {
    let path = PathBuf::from(raw);
    let resolved = resolve_octon_path(octon_dir, &path);
    if resolved.exists() {
        Ok(resolved)
    } else {
        anyhow::bail!("referenced artifact does not exist: {}", resolved.display());
    }
}

fn load_yaml_value(path: &Path) -> Result<Value> {
    let content = fs::read_to_string(path)?;
    Ok(serde_yaml::from_str(&content)?)
}

fn yaml_get_string<'a>(mapping: &'a Mapping, key: &str) -> Result<&'a str> {
    mapping
        .get(Value::String(key.to_string()))
        .and_then(Value::as_str)
        .ok_or_else(|| anyhow::anyhow!("missing string field `{key}`"))
}

fn yaml_get_optional_string(mapping: &Mapping, key: &str) -> Option<String> {
    mapping
        .get(Value::String(key.to_string()))
        .and_then(Value::as_str)
        .map(ToString::to_string)
}

fn yaml_get_mapping<'a>(mapping: &'a Mapping, key: &str) -> Result<&'a Mapping> {
    mapping
        .get(Value::String(key.to_string()))
        .and_then(Value::as_mapping)
        .ok_or_else(|| anyhow::anyhow!("missing mapping field `{key}`"))
}

fn load_run_descriptor(octon_dir: &Path, contract_path: &Path) -> Result<RunDescriptor> {
    let contract = load_yaml_value(contract_path)?;
    let contract = contract
        .as_mapping()
        .ok_or_else(|| anyhow::anyhow!("run contract must be a mapping"))?;
    let run_id = yaml_get_string(contract, "run_id")?.to_string();
    let run_manifest_ref = yaml_get_string(contract, "run_manifest_ref")?.to_string();
    let runtime_state_ref = yaml_get_string(contract, "runtime_state_ref")?.to_string();
    let run_card_ref = yaml_get_string(contract, "run_card_ref")?.to_string();
    let last_checkpoint_ref = yaml_get_string(contract, "rollback_posture_ref")
        .ok()
        .map(ToString::to_string);
    let workflow_id = yaml_get_optional_string(contract, "workflow_id")
        .or_else(|| {
            yaml_get_optional_string(contract, "notes_ref").and_then(|notes_ref| {
                let notes_path = resolve_ref_path(octon_dir, &notes_ref).ok()?;
                let notes = load_yaml_value(&notes_path).ok()?;
                let notes = notes.as_mapping()?;
                let stage_ref = notes
                    .get(Value::String("stage_ref".to_string()))?
                    .as_str()?;
                stage_ref.strip_prefix("workflow:").map(ToString::to_string)
            })
        })
        .ok_or_else(|| {
            anyhow::anyhow!("run contract does not declare a workflow_id or workflow stage_ref")
        })?;
    let run_manifest_path = resolve_ref_path(octon_dir, &run_manifest_ref)?;
    let run_manifest = load_yaml_value(&run_manifest_path)?;
    let run_manifest = run_manifest
        .as_mapping()
        .ok_or_else(|| anyhow::anyhow!("run manifest must be a mapping"))?;
    let continuity_ref = yaml_get_string(run_manifest, "run_continuity_ref")?.to_string();
    let replay_manifest_ref = yaml_get_string(run_manifest, "replay_pointers_ref")
        .ok()
        .and_then(|replay_pointers_ref| {
            let replay_pointers_path = resolve_ref_path(octon_dir, replay_pointers_ref).ok()?;
            let replay_pointers = load_yaml_value(&replay_pointers_path).ok()?;
            let replay_pointers = replay_pointers.as_mapping()?;
            replay_pointers
                .get(Value::String("replay_manifest_refs".to_string()))
                .and_then(Value::as_sequence)
                .and_then(|seq| seq.first())
                .and_then(Value::as_str)
                .map(ToString::to_string)
        })
        .or_else(|| yaml_get_optional_string(run_manifest, "replay_manifest_ref"))
        .ok_or_else(|| anyhow::anyhow!("run manifest does not resolve a replay manifest ref"))?;
    let continuity_path = resolve_ref_path(octon_dir, &continuity_ref)?;
    let continuity = load_yaml_value(&continuity_path)?;
    let continuity = continuity
        .as_mapping()
        .ok_or_else(|| anyhow::anyhow!("continuity artifact must be a mapping"))?;
    let last_checkpoint_ref = yaml_get_optional_string(continuity, "last_checkpoint_ref")
        .or(last_checkpoint_ref)
        .ok_or_else(|| {
            anyhow::anyhow!("continuity artifact does not declare last_checkpoint_ref")
        })?;
    let mission_id = yaml_get_mapping(contract, "objective_refs")
        .ok()
        .and_then(|objective_refs| yaml_get_optional_string(objective_refs, "mission_id"));

    Ok(RunDescriptor {
        run_id,
        workflow_id,
        run_contract_ref: path_to_repo_ref(octon_dir, contract_path)?,
        run_manifest_ref,
        runtime_state_ref,
        continuity_ref,
        replay_manifest_ref,
        run_card_ref,
        last_checkpoint_ref,
        mission_id,
    })
}

fn load_run_descriptor_by_id(octon_dir: &Path, run_id: &str) -> Result<RunDescriptor> {
    let contract_path = octon_dir
        .parent()
        .unwrap_or(octon_dir)
        .join(".octon/state/control/execution/runs")
        .join(run_id)
        .join("run-contract.yml");
    load_run_descriptor(octon_dir, &contract_path)
}

fn path_to_repo_ref(octon_dir: &Path, path: &Path) -> Result<String> {
    let repo_root = octon_dir.parent().unwrap_or(octon_dir);
    let relative = path
        .strip_prefix(repo_root)
        .map_err(|_| anyhow::anyhow!("path is outside the repo root: {}", path.display()))?;
    Ok(relative.to_string_lossy().to_string())
}

fn run_descriptor_start(
    octon_dir: &Path,
    descriptor: RunDescriptor,
    resume_existing: bool,
    executor: ExecutorKind,
    executor_bin: Option<String>,
    model: Option<String>,
    prepare_only: bool,
) -> Result<()> {
    let input_overrides = derive_run_input_overrides(octon_dir, &descriptor)?;
    let result = pipeline::run_pipeline_from_octon_dir(
        octon_dir,
        pipeline::RunPipelineOptions {
            pipeline_id: descriptor.workflow_id,
            run_id: Some(descriptor.run_id),
            mission_id: descriptor.mission_id,
            resume_existing,
            executor,
            executor_bin: executor_bin.map(Into::into),
            output_slug: None,
            model,
            prepare_only,
            input_overrides,
        },
    )?;
    println!("bundle_root: {}", result.bundle_root.display());
    println!("summary_report: {}", result.summary_report.display());
    println!("final_verdict: {}", result.final_verdict);
    Ok(())
}

fn print_run_inspection(octon_dir: &Path, descriptor: &RunDescriptor) -> Result<()> {
    let summary = serde_json::json!({
        "run_id": descriptor.run_id,
        "run_contract_ref": descriptor.run_contract_ref,
        "run_manifest_ref": descriptor.run_manifest_ref,
        "runtime_state_ref": descriptor.runtime_state_ref,
        "continuity_ref": descriptor.continuity_ref,
        "replay_manifest_ref": descriptor.replay_manifest_ref,
        "run_card_ref": descriptor.run_card_ref,
        "last_checkpoint_ref": descriptor.last_checkpoint_ref,
    });
    println!("{}", serde_json::to_string_pretty(&summary)?);
    print_yaml_file(&resolve_ref_path(octon_dir, &descriptor.run_manifest_ref)?)
}

fn derive_run_input_overrides(
    octon_dir: &Path,
    descriptor: &RunDescriptor,
) -> Result<HashMap<String, String>> {
    let mut overrides = HashMap::new();
    if descriptor.workflow_id != "validate-proposal"
        && !descriptor.workflow_id.starts_with("audit-")
        && !descriptor.workflow_id.ends_with("-proposal")
        && descriptor.workflow_id != "promote-proposal"
        && descriptor.workflow_id != "archive-proposal"
    {
        return Ok(overrides);
    }

    let run_manifest =
        load_yaml_value(&resolve_ref_path(octon_dir, &descriptor.run_manifest_ref)?)?;
    let run_manifest = run_manifest
        .as_mapping()
        .ok_or_else(|| anyhow::anyhow!("run manifest must be a mapping"))?;
    let retained_evidence_ref = yaml_get_string(run_manifest, "retained_evidence_ref")?;
    let retained = load_yaml_value(&resolve_ref_path(octon_dir, retained_evidence_ref)?)?;
    let retained = retained
        .as_mapping()
        .ok_or_else(|| anyhow::anyhow!("retained run evidence must be a mapping"))?;
    let evidence_refs = yaml_get_mapping(retained, "evidence_refs")?;
    let side_effects_ref = evidence_refs
        .get(Value::String("side_effects".to_string()))
        .and_then(Value::as_str)
        .ok_or_else(|| anyhow::anyhow!("retained run evidence is missing side_effects ref"))?;
    let side_effects_path = resolve_ref_path(octon_dir, side_effects_ref)?;
    let side_effects: serde_json::Value =
        serde_json::from_str(&fs::read_to_string(side_effects_path)?)?;
    let bundle_root = side_effects
        .get("touched_scope")
        .and_then(serde_json::Value::as_array)
        .and_then(|items| items.first())
        .and_then(serde_json::Value::as_str)
        .ok_or_else(|| anyhow::anyhow!("side-effects receipt is missing workflow bundle root"))?;
    let bundle_path = resolve_octon_path(octon_dir, &PathBuf::from(bundle_root));
    let bundle_yaml = load_yaml_value(&bundle_path.join("bundle.yml"))?;
    let bundle_yaml = bundle_yaml
        .as_mapping()
        .ok_or_else(|| anyhow::anyhow!("workflow bundle.yml must be a mapping"))?;

    if let Some(path) = yaml_get_optional_string(bundle_yaml, "package_path")
        .or_else(|| yaml_get_optional_string(bundle_yaml, "proposal_path"))
    {
        overrides.insert("proposal_path".to_string(), path);
    }

    Ok(overrides)
}

fn print_resume_summary(octon_dir: &Path, descriptor: &RunDescriptor) -> Result<()> {
    let run_manifest =
        load_yaml_value(&resolve_ref_path(octon_dir, &descriptor.run_manifest_ref)?)?;
    let run_manifest = run_manifest
        .as_mapping()
        .ok_or_else(|| anyhow::anyhow!("run manifest must be a mapping"))?;
    let rollback_posture_ref = yaml_get_string(run_manifest, "rollback_posture_ref")?;
    let rollback_posture = load_yaml_value(&resolve_ref_path(octon_dir, rollback_posture_ref)?)?;
    let rollback_posture = rollback_posture
        .as_mapping()
        .ok_or_else(|| anyhow::anyhow!("rollback posture must be a mapping"))?;
    let contamination_record_ref = yaml_get_string(rollback_posture, "contamination_record_ref")?;
    let contamination_record =
        load_yaml_value(&resolve_ref_path(octon_dir, contamination_record_ref)?)?;
    let contamination_record = contamination_record
        .as_mapping()
        .ok_or_else(|| anyhow::anyhow!("contamination record must be a mapping"))?;
    let contamination_state = yaml_get_string(contamination_record, "contamination_state")?;
    let resume_allowed = rollback_posture
        .get(Value::String("resume_allowed".to_string()))
        .and_then(Value::as_bool)
        .unwrap_or(false);
    if !resume_allowed {
        anyhow::bail!(
            "run {} is not resumable under its rollback posture",
            descriptor.run_id
        );
    }
    if contamination_state != "clean" {
        anyhow::bail!(
            "run {} cannot resume because contamination_state is {}",
            descriptor.run_id,
            contamination_state
        );
    }

    let resume_plan = serde_json::json!({
        "run_id": descriptor.run_id,
        "resume_allowed": true,
        "last_checkpoint_ref": descriptor.last_checkpoint_ref,
        "continuity_ref": descriptor.continuity_ref,
        "replay_manifest_ref": descriptor.replay_manifest_ref,
        "input_overrides": derive_run_input_overrides(octon_dir, descriptor)?,
    });
    println!("{}", serde_json::to_string_pretty(&resume_plan)?);
    Ok(())
}

fn print_yaml_file(path: &Path) -> Result<()> {
    let content = fs::read_to_string(path)?;
    println!("{content}");
    Ok(())
}
