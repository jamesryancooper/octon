use crate::context::KernelContext;
use crate::orchestration;
use crate::pipeline;
use crate::request_builders as request;
use crate::run_binding;
use crate::scaffold;
use crate::stdio;
use crate::workflow::ExecutorKind;
use anyhow::Result;
use octon_authority_engine::{
    artifact_root_from_relative, authorize_execution, authorized_effect_reference,
    finalize_execution, issue_capability_pack_activation_effect, issue_evidence_mutation_effect,
    issue_execution_artifact_effects, issue_executor_launch_effect,
    issue_extension_activation_effect, issue_generated_effective_publication_effect,
    issue_protected_ci_check_effect, issue_repo_mutation_effect, issue_service_invocation_effect,
    now_rfc3339, validate_run_lifecycle_operation, verify_authorized_effect,
    verify_authorized_effect_verification_bundle, write_authorized_effect_verification_bundle,
    write_execution_start, AuthorizedEffectReference, AuthorizedEffectVerificationBundle,
    ExecutionArtifactEffects, ExecutionOutcome, ExecutionRequest, ExecutorLaunch, GrantBundle,
    RepoMutation, ReviewRequirements, RunLifecycleOperation, ScopeConstraints, ServiceInvocation,
    SideEffectFlags, SideEffectSummary, VerifiedEffect,
};
use octon_core::errors::{ErrorCode, KernelError};
use octon_core::execution_integrity::service_capability_profile;
use octon_core::tiers::validate_runtime_discovery_tiers;
use octon_core::trace::TraceWriter;
use octon_wasm_host::policy::GrantSet;
use serde::{Deserialize, Serialize};
use serde_yaml::{Mapping, Value};
use std::collections::{BTreeMap, HashMap};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command as ProcessCommand;
use std::sync::Arc;
use std::thread;
use std::time::Duration;

mod engagement;
mod evolution;
mod mission;
mod stewardship;

use super::{
    ArmCmd, CapabilityCmd, Command, ConnectorAdmitCmd, ConnectorCmd, ConnectorDecisionCmd,
    ConnectorInspectCmd, ConnectorListCmd, ConnectorOperationCmd, ContinueCmd, DecideCmd,
    DecisionListCmd, DecisionResolveCmd, MissionCmd, MissionOpenCmd, OrchestrationCmd,
    OrchestrationIncidentCmd, PlanCmd, ProfileCmd, ProtectedCiCmd, PublicationInternalCmd,
    PublishCmd, RunCmd, ServiceCmd, ServicesCmd, StartCmd, StatusCmd, SupportCmd,
    SupportProofSubject, WorkflowCmd,
};

fn artifact_effects_for_root(root: &Path, grant: &GrantBundle) -> Result<ExecutionArtifactEffects> {
    Ok(issue_execution_artifact_effects(
        root,
        grant,
        root.display().to_string(),
    )?)
}

fn invoke_service_with_verified_effect(
    ctx: &KernelContext,
    grant: &GrantBundle,
    _effect: &VerifiedEffect<ServiceInvocation>,
    svc: &octon_core::registry::ServiceDescriptor,
    op: &str,
    input: serde_json::Value,
    trace: Option<&TraceWriter>,
    run_root: &Path,
    adapter_id: Option<&str>,
) -> Result<serde_json::Value> {
    let grants = GrantSet::new(grant.granted_capabilities.clone());
    Ok(ctx.invoker.invoke(
        svc, grants, op, input, trace, run_root, adapter_id, None, None,
    )?)
}

fn scaffold_service_new_with_verified_effect(
    octon_dir: &Path,
    category: &str,
    name: &str,
    _grant: &GrantBundle,
    _effect: &VerifiedEffect<RepoMutation>,
) -> Result<()> {
    scaffold::service_new(octon_dir, category, name)
}

fn scaffold_service_build_with_verified_effect(
    octon_dir: &Path,
    category: &str,
    name: &str,
    _grant: &GrantBundle,
    _effect: &VerifiedEffect<RepoMutation>,
) -> Result<()> {
    scaffold::service_build(octon_dir, category, name)
}

fn ensure_dir_with_verified_executor_effect(
    path: &Path,
    _grant: &GrantBundle,
    _effect: &VerifiedEffect<ExecutorLaunch>,
) -> Result<()> {
    std::fs::create_dir_all(path)?;
    Ok(())
}

pub(crate) fn dispatch(cmd: Command) -> Result<()> {
    match cmd {
        Command::Start(args) => engagement::cmd_start(args),
        Command::Profile(args) => engagement::cmd_profile(args),
        Command::Plan(args) => engagement::cmd_plan(args),
        Command::Arm(args) => engagement::cmd_arm(args),
        Command::Status(args) => engagement::cmd_status(args),
        Command::Continue(args) => mission::cmd_continue(args),
        Command::Mission { cmd } => mission::cmd_mission(cmd),
        Command::Decide { cmd } => cmd_decide(cmd),
        Command::Connector { cmd } => mission::cmd_connector(cmd),
        Command::Support { cmd } => mission::cmd_support(cmd),
        Command::Capability { cmd } => mission::cmd_capability(cmd),
        Command::Steward { cmd } => stewardship::cmd_steward(cmd),
        Command::Evolve { cmd } => evolution::cmd_evolve(cmd),
        Command::Amend { cmd } => evolution::cmd_amend(cmd),
        Command::Promote { cmd } => evolution::cmd_promote(cmd),
        Command::Recertify { cmd } => evolution::cmd_recertify(cmd),
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
        Command::Publish { cmd } => cmd_publish(cmd),
        Command::ProtectedCi { cmd } => cmd_protected_ci(cmd),
        Command::PublicationInternal { cmd } => cmd_publication_internal(cmd),
        Command::Orchestration { cmd } => cmd_orchestration(cmd),
    }
}

fn cmd_decide(cmd: DecideCmd) -> Result<()> {
    match cmd {
        DecideCmd::List(args) => {
            if args.program_id.is_some() {
                stewardship::cmd_decision_list(args)
            } else {
                mission::cmd_decision_list(args)
            }
        }
        DecideCmd::Resolve(args) => {
            if args.program_id.is_some()
                || stewardship::stewardship_decision_exists(
                    args.program_id.as_deref(),
                    &args.decision_id,
                )?
            {
                stewardship::cmd_decision_resolve(args)
            } else if args.mission_id.is_some()
                || mission::mission_decision_exists(args.mission_id.as_deref(), &args.decision_id)?
            {
                mission::cmd_decision_resolve(args)
            } else {
                engagement::cmd_decide(args)
            }
        }
    }
}

#[derive(Clone, Copy)]
enum PublicationEffectKind {
    GeneratedEffectivePublication,
    EvidenceMutation,
    ExtensionActivation,
    CapabilityPackActivation,
}

impl PublicationEffectKind {
    fn as_effect_kind(self) -> &'static str {
        match self {
            Self::GeneratedEffectivePublication => "generated-effective-publication",
            Self::EvidenceMutation => "evidence-mutation",
            Self::ExtensionActivation => "extension-activation",
            Self::CapabilityPackActivation => "capability-pack-activation",
        }
    }
}

struct PublicationScope<'a> {
    scope_rel: &'a str,
    consumer_suffix: &'a str,
    effect_kind: PublicationEffectKind,
    single_use: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct PublicationTokenManifest {
    schema_version: String,
    publisher_id: String,
    bundle_paths: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct PublicationTokenResultManifest {
    schema_version: String,
    publisher_id: String,
    authorized_effects: Vec<AuthorizedEffectReference>,
}

struct PublicationSpec<'a> {
    publisher_id: &'a str,
    action_type: &'a str,
    script_rel: &'a str,
    requested_capabilities: Vec<String>,
    scope_constraints_write_rel: Vec<&'a str>,
    scope_bindings: Vec<PublicationScope<'a>>,
    route_bundle_bypass: bool,
}

fn publication_spec(cmd: PublishCmd) -> PublicationSpec<'static> {
    match cmd {
        PublishCmd::SupportTargetMatrix => PublicationSpec {
            publisher_id: "support-target-matrix",
            action_type: "publish_generated_effective",
            script_rel: ".octon/framework/assurance/runtime/_ops/scripts/generate-support-target-matrix.sh",
            requested_capabilities: vec![
                "generated.effective.publish".to_string(),
                "governance.support.publish".to_string(),
            ],
            scope_constraints_write_rel: vec![".octon/generated/effective/governance"],
            scope_bindings: vec![PublicationScope {
                scope_rel: ".octon/generated/effective/governance",
                consumer_suffix: "generated",
                effect_kind: PublicationEffectKind::GeneratedEffectivePublication,
                single_use: false,
            }],
            route_bundle_bypass: true,
        },
        PublishCmd::PackRoutes => PublicationSpec {
            publisher_id: "pack-routes",
            action_type: "publish_generated_effective",
            script_rel: ".octon/framework/assurance/runtime/_ops/scripts/generate-pack-routes.sh",
            requested_capabilities: vec![
                "generated.effective.publish".to_string(),
                "capability.routing.publish".to_string(),
                "evidence.write".to_string(),
            ],
            scope_constraints_write_rel: vec![
                ".octon/generated/effective/capabilities",
                ".octon/state/evidence/validation/publication/capabilities",
            ],
            scope_bindings: vec![
                PublicationScope {
                    scope_rel: ".octon/generated/effective/capabilities",
                    consumer_suffix: "generated",
                    effect_kind: PublicationEffectKind::GeneratedEffectivePublication,
                    single_use: false,
                },
                PublicationScope {
                    scope_rel: ".octon/state/evidence/validation/publication/capabilities",
                    consumer_suffix: "evidence",
                    effect_kind: PublicationEffectKind::EvidenceMutation,
                    single_use: false,
                },
            ],
            route_bundle_bypass: true,
        },
        PublishCmd::RuntimeRouteBundle => PublicationSpec {
            publisher_id: "runtime-route-bundle",
            action_type: "publish_generated_effective",
            script_rel: ".octon/framework/assurance/runtime/_ops/scripts/generate-runtime-effective-route-bundle.sh",
            requested_capabilities: vec![
                "generated.effective.publish".to_string(),
                "runtime.route.publish".to_string(),
                "evidence.write".to_string(),
            ],
            scope_constraints_write_rel: vec![
                ".octon/generated/effective/runtime",
                ".octon/state/evidence/validation/publication/runtime",
            ],
            scope_bindings: vec![
                PublicationScope {
                    scope_rel: ".octon/generated/effective/runtime",
                    consumer_suffix: "generated",
                    effect_kind: PublicationEffectKind::GeneratedEffectivePublication,
                    single_use: false,
                },
                PublicationScope {
                    scope_rel: ".octon/state/evidence/validation/publication/runtime",
                    consumer_suffix: "evidence",
                    effect_kind: PublicationEffectKind::EvidenceMutation,
                    single_use: false,
                },
            ],
            route_bundle_bypass: true,
        },
        PublishCmd::ExtensionState => PublicationSpec {
            publisher_id: "extension-state",
            action_type: "publish_extension_activation",
            script_rel: ".octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh",
            requested_capabilities: vec![
                "extension.activation.publish".to_string(),
                "generated.effective.publish".to_string(),
                "state.control.write".to_string(),
                "evidence.write".to_string(),
            ],
            scope_constraints_write_rel: vec![
                ".octon/generated/effective/extensions",
                ".octon/state/control/extensions",
                ".octon/state/evidence/validation/publication/extensions",
                ".octon/state/evidence/validation/compatibility/extensions",
            ],
            scope_bindings: vec![
                PublicationScope {
                    scope_rel: ".octon/generated/effective/extensions",
                    consumer_suffix: "extensions-generated",
                    effect_kind: PublicationEffectKind::ExtensionActivation,
                    single_use: false,
                },
                PublicationScope {
                    scope_rel: ".octon/state/control/extensions",
                    consumer_suffix: "extensions-control",
                    effect_kind: PublicationEffectKind::ExtensionActivation,
                    single_use: false,
                },
                PublicationScope {
                    scope_rel: ".octon/state/evidence/validation/publication/extensions",
                    consumer_suffix: "extensions-publication-evidence",
                    effect_kind: PublicationEffectKind::EvidenceMutation,
                    single_use: false,
                },
                PublicationScope {
                    scope_rel: ".octon/state/evidence/validation/compatibility/extensions",
                    consumer_suffix: "extensions-compatibility-evidence",
                    effect_kind: PublicationEffectKind::EvidenceMutation,
                    single_use: false,
                },
            ],
            route_bundle_bypass: true,
        },
        PublishCmd::CapabilityRouting => PublicationSpec {
            publisher_id: "capability-routing",
            action_type: "publish_capability_pack_activation",
            script_rel: ".octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh",
            requested_capabilities: vec![
                "capability.routing.publish".to_string(),
                "capability.pack.activation".to_string(),
                "generated.effective.publish".to_string(),
                "evidence.write".to_string(),
            ],
            scope_constraints_write_rel: vec![
                ".octon/generated/effective/capabilities",
                ".octon/state/evidence/validation/publication/capabilities",
            ],
            scope_bindings: vec![
                PublicationScope {
                    scope_rel: ".octon/generated/effective/capabilities",
                    consumer_suffix: "capability-routing",
                    effect_kind: PublicationEffectKind::CapabilityPackActivation,
                    single_use: false,
                },
                PublicationScope {
                    scope_rel: ".octon/state/evidence/validation/publication/capabilities",
                    consumer_suffix: "capability-routing-evidence",
                    effect_kind: PublicationEffectKind::EvidenceMutation,
                    single_use: false,
                },
            ],
            route_bundle_bypass: true,
        },
        PublishCmd::HostProjections => PublicationSpec {
            publisher_id: "host-projections",
            action_type: "publish_extension_activation",
            script_rel: ".octon/framework/capabilities/_ops/scripts/publish-host-projections.sh",
            requested_capabilities: vec![
                "extension.activation.publish".to_string(),
                "host.projection.publish".to_string(),
            ],
            scope_constraints_write_rel: vec![".claude", ".cursor", ".codex"],
            scope_bindings: vec![
                PublicationScope {
                    scope_rel: ".claude",
                    consumer_suffix: "host-projections-claude",
                    effect_kind: PublicationEffectKind::ExtensionActivation,
                    single_use: false,
                },
                PublicationScope {
                    scope_rel: ".cursor",
                    consumer_suffix: "host-projections-cursor",
                    effect_kind: PublicationEffectKind::ExtensionActivation,
                    single_use: false,
                },
                PublicationScope {
                    scope_rel: ".codex",
                    consumer_suffix: "host-projections-codex",
                    effect_kind: PublicationEffectKind::ExtensionActivation,
                    single_use: false,
                },
            ],
            route_bundle_bypass: true,
        },
    }
}

fn publication_spec_by_publisher(publisher_id: &str) -> Option<PublicationSpec<'static>> {
    [
        PublishCmd::SupportTargetMatrix,
        PublishCmd::PackRoutes,
        PublishCmd::RuntimeRouteBundle,
        PublishCmd::ExtensionState,
        PublishCmd::CapabilityRouting,
        PublishCmd::HostProjections,
    ]
    .into_iter()
    .map(publication_spec)
    .find(|spec| spec.publisher_id == publisher_id)
}

fn resolve_scope_rel(repo_root: &Path, scope_rel: &str) -> PathBuf {
    if scope_rel == "." {
        repo_root.to_path_buf()
    } else {
        repo_root.join(scope_rel)
    }
}

fn write_publication_token_manifest(
    path: &Path,
    manifest: &PublicationTokenManifest,
) -> Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(path, serde_json::to_vec_pretty(manifest)?)?;
    Ok(())
}

fn read_publication_token_result_manifest(path: &Path) -> Result<PublicationTokenResultManifest> {
    Ok(serde_json::from_slice(&fs::read(path)?)?)
}

fn write_runtime_grant_bundle(path: &Path, grant: &GrantBundle) -> Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(path, serde_json::to_vec_pretty(grant)?)?;
    Ok(())
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
    let service_effect =
        issue_service_invocation_effect(&artifact_root, &grant, format!("{}::{op}", svc.key.id()))?;
    let verified_service_effect = verify_authorized_effect(
        &artifact_root,
        &grant,
        &service_effect,
        ".octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs::invoke_service_with_verified_effect",
        format!("{}::{op}", svc.key.id()),
    )?;
    let out = invoke_service_with_verified_effect(
        &ctx,
        &grant,
        &verified_service_effect,
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
            authorized_effects: vec![authorized_effect_reference(&verified_service_effect)],
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
            human_approval: false,
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
    let executor_effect =
        issue_executor_launch_effect(&artifact_root, &grant, target_dir.display().to_string())?;
    let verified_executor_effect = verify_authorized_effect(
        &artifact_root,
        &grant,
        &executor_effect,
        ".octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs::ensure_dir_with_verified_executor_effect",
        target_dir.display().to_string(),
    )?;

    ensure_dir_with_verified_executor_effect(&target_dir, &grant, &verified_executor_effect)?;

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
            authorized_effects: vec![authorized_effect_reference(&verified_executor_effect)],
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
            let artifacts =
                write_execution_start(&artifact_root, &request, &grant, &artifact_effects)?;
            let started_at = now_rfc3339()?;
            let repo_effect = issue_repo_mutation_effect(
                &artifact_root,
                &grant,
                service_root.display().to_string(),
            )?;
            let verified_repo_effect = verify_authorized_effect(
                &artifact_root,
                &grant,
                &repo_effect,
                ".octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs::scaffold_service_new_with_verified_effect",
                service_root.display().to_string(),
            )?;
            scaffold_service_new_with_verified_effect(
                &octon_dir,
                &category,
                &name,
                &grant,
                &verified_repo_effect,
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
                    touched_scope: vec![service_root.display().to_string()],
                    authorized_effects: vec![authorized_effect_reference(&verified_repo_effect)],
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
            let artifacts =
                write_execution_start(&artifact_root, &request, &grant, &artifact_effects)?;
            let started_at = now_rfc3339()?;
            let repo_effect = issue_repo_mutation_effect(
                &artifact_root,
                &grant,
                service_root.display().to_string(),
            )?;
            let verified_repo_effect = verify_authorized_effect(
                &artifact_root,
                &grant,
                &repo_effect,
                ".octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs::scaffold_service_build_with_verified_effect",
                service_root.display().to_string(),
            )?;
            scaffold_service_build_with_verified_effect(
                &octon_dir,
                &category,
                &name,
                &grant,
                &verified_repo_effect,
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
                    touched_scope: vec![
                        service_root.display().to_string(),
                        build_root.display().to_string(),
                    ],
                    shell_commands: vec![
                        "cargo fetch --locked --target wasm32-wasip1".to_string(),
                        "cargo component build --release --offline".to_string(),
                    ],
                    executor_profile: Some("scoped_repo_mutation".to_string()),
                    authorized_effects: vec![authorized_effect_reference(&verified_repo_effect)],
                    ..SideEffectSummary::default()
                },
            )?;
            println!("built service and updated integrity: {category}/{name}");
        }
    }
    Ok(())
}

fn issue_publication_effect_bundle(
    artifact_root: &Path,
    grant: &GrantBundle,
    binding: &PublicationScope<'_>,
    absolute_scope: &Path,
    execution_grant_path: &Path,
    bundle_root: &Path,
) -> Result<String> {
    let scope = absolute_scope.display().to_string();
    let consumer_api_ref = format!(
        ".octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs::publication_internal_verify:{}",
        binding.consumer_suffix
    );
    let bundle_path = bundle_root.join(format!("{}.json", binding.consumer_suffix));
    match binding.effect_kind {
        PublicationEffectKind::GeneratedEffectivePublication => {
            let effect = issue_generated_effective_publication_effect(
                artifact_root,
                grant,
                scope.clone(),
                binding.single_use,
            )?;
            write_authorized_effect_verification_bundle(
                &effect,
                execution_grant_path.display().to_string(),
                &consumer_api_ref,
                scope,
                &bundle_path,
            )?;
        }
        PublicationEffectKind::EvidenceMutation => {
            let effect = issue_evidence_mutation_effect(
                artifact_root,
                grant,
                scope.clone(),
                binding.single_use,
            )?;
            write_authorized_effect_verification_bundle(
                &effect,
                execution_grant_path.display().to_string(),
                &consumer_api_ref,
                scope,
                &bundle_path,
            )?;
        }
        PublicationEffectKind::ExtensionActivation => {
            let effect = issue_extension_activation_effect(
                artifact_root,
                grant,
                scope.clone(),
                binding.single_use,
            )?;
            write_authorized_effect_verification_bundle(
                &effect,
                execution_grant_path.display().to_string(),
                &consumer_api_ref,
                scope,
                &bundle_path,
            )?;
        }
        PublicationEffectKind::CapabilityPackActivation => {
            let effect = issue_capability_pack_activation_effect(
                artifact_root,
                grant,
                scope.clone(),
                binding.single_use,
            )?;
            write_authorized_effect_verification_bundle(
                &effect,
                execution_grant_path.display().to_string(),
                &consumer_api_ref,
                scope,
                &bundle_path,
            )?;
        }
    }
    Ok(bundle_path.display().to_string())
}

fn cmd_publish(cmd: PublishCmd) -> Result<()> {
    let spec = publication_spec(cmd);
    if spec.route_bundle_bypass {
        std::env::set_var("OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE", "1");
    }
    let ctx = KernelContext::load()?;
    let mut write_scope: Vec<String> = spec
        .scope_constraints_write_rel
        .iter()
        .map(|scope_rel| {
            resolve_scope_rel(&ctx.cfg.repo_root, scope_rel)
                .display()
                .to_string()
        })
        .collect();
    write_scope.sort();
    write_scope.dedup();
    let (intent_ref, execution_role_ref, metadata) =
        request::bind_repo_local_request(&ctx.cfg, BTreeMap::new())?;
    let request = ExecutionRequest {
        request_id: new_request_id("publish"),
        caller_path: "kernel".to_string(),
        action_type: spec.action_type.to_string(),
        target_id: format!("publication:{}", spec.publisher_id),
        requested_capabilities: spec.requested_capabilities.clone(),
        side_effect_flags: SideEffectFlags {
            write_evidence: spec.scope_bindings.iter().any(|binding| {
                matches!(binding.effect_kind, PublicationEffectKind::EvidenceMutation)
            }),
            shell: true,
            publication: true,
            state_mutation: write_scope
                .iter()
                .any(|scope| scope.contains("/.octon/state/control/")),
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
            human_approval: false,
            quorum: false,
            rollback_metadata: false,
        },
        scope_constraints: ScopeConstraints {
            read: vec![ctx.cfg.repo_root.display().to_string()],
            write: write_scope.clone(),
            executor_profile: Some("scoped_repo_mutation".to_string()),
            locality_scope: None,
        },
        policy_mode_requested: Some("hard-enforce".to_string()),
        environment_hint: None,
        metadata,
        ..ExecutionRequest::default()
    };

    let grant = authorize_execution(&ctx.cfg, &ctx.policy, &request, None)?;
    run_binding::ensure_canonical_run_binding(&ctx.cfg, &request, &grant, "publication")?;

    let artifact_root = artifact_root_from_relative(
        &ctx.cfg.repo_root,
        &ctx.cfg.execution_governance.receipt_roots.kernel,
        &request.request_id,
    );
    let artifact_effects = artifact_effects_for_root(&artifact_root, &grant)?;
    let artifacts = write_execution_start(&artifact_root, &request, &grant, &artifact_effects)?;
    let started_at = now_rfc3339()?;
    let publication_bundle_root = ctx
        .cfg
        .repo_root
        .join(".octon/generated/.tmp/publication-effect-bundles")
        .join(&request.request_id);
    let publication_manifest_path = publication_bundle_root.join("manifest.json");
    let publication_result_manifest_path = publication_bundle_root.join("result.json");
    let execution_grant_path = publication_bundle_root.join("runtime-grant.json");
    write_runtime_grant_bundle(&execution_grant_path, &grant)?;

    let mut bundle_paths = Vec::new();
    for binding in &spec.scope_bindings {
        let absolute_scope = resolve_scope_rel(&ctx.cfg.repo_root, binding.scope_rel);
        bundle_paths.push(issue_publication_effect_bundle(
            &artifact_root,
            &grant,
            binding,
            &absolute_scope,
            &execution_grant_path,
            &publication_bundle_root,
        )?);
    }
    write_publication_token_manifest(
        &publication_manifest_path,
        &PublicationTokenManifest {
            schema_version: "publication-token-manifest-v1".to_string(),
            publisher_id: spec.publisher_id.to_string(),
            bundle_paths,
        },
    )?;

    let script_path = ctx.cfg.repo_root.join(spec.script_rel);
    if !script_path.is_file() {
        anyhow::bail!("publication script not found: {}", script_path.display());
    }
    let status = ProcessCommand::new("bash")
        .arg(&script_path)
        .current_dir(&ctx.cfg.repo_root)
        .env("OCTON_PUBLICATION_ENTRYPOINT", "runtime")
        .env(
            "OCTON_PUBLICATION_TOKEN_MANIFEST",
            &publication_manifest_path,
        )
        .env(
            "OCTON_PUBLICATION_TOKEN_RESULT_MANIFEST",
            &publication_result_manifest_path,
        )
        .status()?;
    let mut publication_error = if status.success() {
        None
    } else {
        Some(format!("publication wrapper exited with status {status}"))
    };
    let authorized_effects = if publication_result_manifest_path.is_file() {
        let result_manifest =
            read_publication_token_result_manifest(&publication_result_manifest_path)?;
        if result_manifest.publisher_id != spec.publisher_id {
            publication_error = Some(format!(
                "publication result manifest publisher mismatch: expected {}, got {}",
                spec.publisher_id, result_manifest.publisher_id
            ));
            Vec::new()
        } else {
            result_manifest.authorized_effects
        }
    } else {
        if publication_error.is_none() {
            publication_error = Some(format!(
                "publication script completed without a verified token result manifest: {}",
                publication_result_manifest_path.display()
            ));
        }
        Vec::new()
    };

    finalize_execution(
        &artifacts,
        &request,
        &grant,
        &artifact_effects,
        &started_at,
        &ExecutionOutcome {
            status: if publication_error.is_none() {
                "succeeded".to_string()
            } else {
                "failed".to_string()
            },
            started_at: started_at.clone(),
            completed_at: now_rfc3339()?,
            error: publication_error.clone(),
        },
        &SideEffectSummary {
            touched_scope: write_scope.clone(),
            shell_commands: vec![format!("bash {}", script_path.display())],
            executor_profile: Some("scoped_repo_mutation".to_string()),
            authorized_effects,
            ..SideEffectSummary::default()
        },
    )?;

    if let Some(error) = publication_error {
        anyhow::bail!(error);
    }

    let _ = fs::remove_dir_all(&publication_bundle_root);

    if spec.route_bundle_bypass {
        std::env::remove_var("OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE");
    }

    Ok(())
}

fn cmd_publication_internal(cmd: PublicationInternalCmd) -> Result<()> {
    match cmd {
        PublicationInternalCmd::VerifyManifest {
            publisher,
            manifest,
            result_manifest,
        } => {
            let ctx = KernelContext::load()?;
            let repo_root = ctx.cfg.repo_root.clone();
            let manifest: PublicationTokenManifest = serde_json::from_slice(&fs::read(&manifest)?)?;
            if manifest.publisher_id != publisher {
                anyhow::bail!(
                    "publication token manifest publisher mismatch: expected {}, got {}",
                    publisher,
                    manifest.publisher_id
                );
            }
            let spec = publication_spec_by_publisher(&publisher)
                .ok_or_else(|| anyhow::anyhow!("unknown publication publisher id: {publisher}"))?;
            if manifest.bundle_paths.len() != spec.scope_bindings.len() {
                anyhow::bail!(
                    "publication token manifest bundle count mismatch for {}: expected {}, got {}",
                    publisher,
                    spec.scope_bindings.len(),
                    manifest.bundle_paths.len()
                );
            }

            let mut authorized_effects = Vec::new();
            let mut seen_suffixes = std::collections::BTreeSet::new();
            for bundle_path in manifest.bundle_paths {
                let bundle: AuthorizedEffectVerificationBundle =
                    serde_json::from_slice(&fs::read(&bundle_path)?)?;
                let matching_binding = spec.scope_bindings.iter().find(|binding| {
                    let expected_consumer = format!(
                        ".octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs::publication_internal_verify:{}",
                        binding.consumer_suffix
                    );
                    bundle.consumer_api_ref == expected_consumer
                        && bundle.token_payload.effect_kind == binding.effect_kind.as_effect_kind()
                        && bundle.target_scope
                            == resolve_scope_rel(&repo_root, binding.scope_rel)
                            .display()
                            .to_string()
                });
                let binding = matching_binding.ok_or_else(|| {
                    anyhow::anyhow!(
                        "publication token bundle {} does not match the expected publisher binding set for {}",
                        bundle_path,
                        publisher
                    )
                })?;
                if !seen_suffixes.insert(binding.consumer_suffix.to_string()) {
                    anyhow::bail!(
                        "duplicate publication token bundle binding for {}:{}",
                        publisher,
                        binding.consumer_suffix
                    );
                }
                authorized_effects.push(verify_authorized_effect_verification_bundle(Path::new(
                    &bundle_path,
                ))?);
            }

            if let Some(parent) = result_manifest.parent() {
                fs::create_dir_all(parent)?;
            }
            fs::write(
                &result_manifest,
                serde_json::to_vec_pretty(&PublicationTokenResultManifest {
                    schema_version: "publication-token-result-manifest-v1".to_string(),
                    publisher_id: publisher,
                    authorized_effects,
                })?,
            )?;
            Ok(())
        }
    }
}

#[derive(Debug, Deserialize)]
struct ProtectedCiApprovalProjection {
    #[serde(default)]
    approval_request_ref: Option<String>,
    #[serde(default)]
    approval_grant_ref: Option<String>,
    #[serde(default)]
    approval_granted: bool,
}

fn percent_encode_path_segment(value: &str) -> String {
    let mut encoded = String::new();
    for byte in value.bytes() {
        match byte {
            b'A'..=b'Z' | b'a'..=b'z' | b'0'..=b'9' | b'-' | b'_' | b'.' | b'~' => {
                encoded.push(byte as char)
            }
            _ => encoded.push_str(&format!("%{:02X}", byte)),
        }
    }
    encoded
}

fn gh_output(gh_bin: &str, repo_root: &Path, args: &[&str]) -> Result<String> {
    let output = ProcessCommand::new(gh_bin)
        .args(args)
        .current_dir(repo_root)
        .output()?;
    if output.status.success() {
        Ok(String::from_utf8(output.stdout)?)
    } else {
        anyhow::bail!(
            "gh command failed: {}",
            String::from_utf8_lossy(&output.stderr).trim()
        );
    }
}

fn cmd_protected_ci(cmd: ProtectedCiCmd) -> Result<()> {
    match cmd {
        ProtectedCiCmd::AutoMerge {
            repo,
            pr_number,
            control_json,
            delete_head_ref,
        } => {
            let ctx = KernelContext::load()?;
            let repo = repo
                .or_else(|| std::env::var("GH_REPO").ok())
                .ok_or_else(|| anyhow::anyhow!("--repo is required when GH_REPO is unset"))?;
            let control_json = if control_json.is_absolute() {
                control_json
            } else {
                ctx.cfg.repo_root.join(control_json)
            };
            let projection: ProtectedCiApprovalProjection =
                serde_json::from_slice(&fs::read(&control_json)?)?;
            if !projection.approval_granted {
                anyhow::bail!(
                    "protected CI merge requires a granted approval projection: {}",
                    control_json.display()
                );
            }
            for approval_ref in [
                projection.approval_request_ref.as_deref(),
                projection.approval_grant_ref.as_deref(),
            ]
            .into_iter()
            .flatten()
            {
                let approval_path = ctx.cfg.repo_root.join(approval_ref);
                if !approval_path.is_file() {
                    anyhow::bail!(
                        "protected CI approval artifact missing: {}",
                        approval_path.display()
                    );
                }
            }
            let target_scope = format!("github://repo/{repo}/pull/{pr_number}/merge");
            let mut metadata_input = BTreeMap::new();
            if let Some(approval_request_ref) = &projection.approval_request_ref {
                metadata_input.insert(
                    "protected_ci_approval_request_ref".to_string(),
                    approval_request_ref.clone(),
                );
            }
            if let Some(approval_grant_ref) = &projection.approval_grant_ref {
                metadata_input.insert(
                    "protected_ci_approval_grant_ref".to_string(),
                    approval_grant_ref.clone(),
                );
            }
            metadata_input.insert(
                "support_capability_packs".to_string(),
                "repo,git,shell,telemetry".to_string(),
            );

            let (intent_ref, execution_role_ref, metadata) = request::bind_request(
                &ctx.cfg,
                metadata_input,
                request::DEFAULT_WORKLOAD_TIER,
                "github-control-plane",
            )?;
            let request = ExecutionRequest {
                request_id: new_request_id("protected-ci"),
                caller_path: "kernel".to_string(),
                action_type: "protected_ci_auto_merge".to_string(),
                target_id: format!("github-pr:{repo}#{pr_number}"),
                requested_capabilities: vec![
                    "github.pr.merge".to_string(),
                    "github.branch.delete".to_string(),
                    "protected.ci.check".to_string(),
                ],
                side_effect_flags: SideEffectFlags {
                    shell: true,
                    network: true,
                    ..SideEffectFlags::default()
                },
                risk_tier: "high".to_string(),
                workflow_mode: request::role_mediated_mode(),
                locality_scope: None,
                intent_ref: Some(intent_ref),
                autonomy_context: None,
                execution_role_ref: Some(execution_role_ref),
                parent_run_ref: None,
                review_requirements: ReviewRequirements {
                    human_approval: false,
                    quorum: false,
                    rollback_metadata: false,
                },
                scope_constraints: ScopeConstraints {
                    read: vec![ctx.cfg.repo_root.display().to_string()],
                    write: vec![target_scope.clone()],
                    executor_profile: Some("scoped_repo_mutation".to_string()),
                    locality_scope: None,
                },
                policy_mode_requested: Some("hard-enforce".to_string()),
                environment_hint: None,
                metadata,
                ..ExecutionRequest::default()
            };

            let grant = authorize_execution(&ctx.cfg, &ctx.policy, &request, None)?;
            run_binding::ensure_canonical_run_binding(&ctx.cfg, &request, &grant, "protected-ci")?;
            let artifact_root = artifact_root_from_relative(
                &ctx.cfg.repo_root,
                &ctx.cfg.execution_governance.receipt_roots.kernel,
                &request.request_id,
            );
            let artifact_effects = artifact_effects_for_root(&artifact_root, &grant)?;
            let artifacts =
                write_execution_start(&artifact_root, &request, &grant, &artifact_effects)?;
            let started_at = now_rfc3339()?;

            let protected_effect = issue_protected_ci_check_effect(
                &artifact_root,
                &grant,
                target_scope.clone(),
                true,
            )?;
            let verified_effect = verify_authorized_effect(
                &artifact_root,
                &grant,
                &protected_effect,
                ".octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs::cmd_protected_ci_auto_merge",
                target_scope.clone(),
            )?;

            let gh_bin = std::env::var("OCTON_GH_BIN").unwrap_or_else(|_| "gh".to_string());
            let pr_view = gh_output(
                &gh_bin,
                &ctx.cfg.repo_root,
                &["api", &format!("repos/{repo}/pulls/{pr_number}")],
            )?;
            let pr_json: serde_json::Value = serde_json::from_str(&pr_view)?;
            if pr_json
                .get("state")
                .and_then(|value| value.as_str())
                .unwrap_or_default()
                != "open"
            {
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
                        touched_scope: vec![target_scope.clone()],
                        authorized_effects: vec![authorized_effect_reference(&verified_effect)],
                        ..SideEffectSummary::default()
                    },
                )?;
                return Ok(());
            }

            let mut shell_commands = vec![format!(
                "{gh_bin} api --method PUT repos/{repo}/pulls/{pr_number}/merge -f merge_method=squash"
            )];
            let mut merge_error = None;
            let mut merged = false;
            for _ in 0..120 {
                let output = ProcessCommand::new(&gh_bin)
                    .args([
                        "api",
                        "--method",
                        "PUT",
                        &format!("repos/{repo}/pulls/{pr_number}/merge"),
                        "-f",
                        "merge_method=squash",
                    ])
                    .current_dir(&ctx.cfg.repo_root)
                    .output()?;
                if output.status.success() {
                    merged = true;
                    break;
                }

                let stderr = String::from_utf8_lossy(&output.stderr).to_string();
                let transient_error = [
                    "HTTP 405",
                    "HTTP 409",
                    "HTTP 422",
                    "HTTP 500",
                    "HTTP 501",
                    "HTTP 502",
                    "HTTP 503",
                    "HTTP 504",
                    "Pull Request is not mergeable",
                    "required status check",
                    "review",
                    "Server Error",
                    "Bad Gateway",
                    "Service Unavailable",
                    "Gateway Timeout",
                ]
                .iter()
                .any(|pattern| stderr.contains(pattern));
                if transient_error {
                    thread::sleep(Duration::from_secs(5));
                    continue;
                }

                merge_error = Some(stderr);
                break;
            }

            let head_ref = pr_json
                .get("head")
                .and_then(|value| value.get("ref"))
                .and_then(|value| value.as_str())
                .unwrap_or_default()
                .to_string();
            if merged && delete_head_ref && !head_ref.is_empty() {
                let encoded_ref = percent_encode_path_segment(&head_ref);
                shell_commands.push(format!(
                    "{gh_bin} api --method DELETE repos/{repo}/git/refs/heads/{encoded_ref}"
                ));
                let _ = ProcessCommand::new(&gh_bin)
                    .args([
                        "api",
                        "--method",
                        "DELETE",
                        &format!("repos/{repo}/git/refs/heads/{encoded_ref}"),
                    ])
                    .current_dir(&ctx.cfg.repo_root)
                    .output();
            }

            let outcome = if merged {
                ExecutionOutcome {
                    status: "succeeded".to_string(),
                    started_at: started_at.clone(),
                    completed_at: now_rfc3339()?,
                    error: None,
                }
            } else {
                ExecutionOutcome {
                    status: "failed".to_string(),
                    started_at: started_at.clone(),
                    completed_at: now_rfc3339()?,
                    error: Some(merge_error.unwrap_or_else(|| {
                        "PR did not become mergeable within the protected-CI wait window"
                            .to_string()
                    })),
                }
            };

            finalize_execution(
                &artifacts,
                &request,
                &grant,
                &artifact_effects,
                &started_at,
                &outcome,
                &SideEffectSummary {
                    touched_scope: vec![target_scope.clone()],
                    shell_commands,
                    executor_profile: Some("scoped_repo_mutation".to_string()),
                    authorized_effects: vec![authorized_effect_reference(&verified_effect)],
                    ..SideEffectSummary::default()
                },
            )?;

            if merged {
                Ok(())
            } else {
                anyhow::bail!(
                    "{}",
                    outcome
                        .error
                        .unwrap_or_else(|| "protected CI merge failed".to_string())
                )
            }
        }
    }
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
    let repo_root = octon_dir.parent().unwrap_or(&octon_dir).to_path_buf();
    match cmd {
        RunCmd::Start {
            contract,
            executor,
            executor_bin,
            model,
            prepare_only,
        } => {
            let contract_path = resolve_octon_path(&octon_dir, &contract);
            if engagement::is_run_candidate_contract(&contract_path) {
                if !prepare_only {
                    anyhow::bail!(
                        "run-contract candidates may only be submitted with `octon run start --contract <candidate> --prepare-only`; live execution requires the canonical run contract after authorization binding"
                    );
                }
                let descriptor =
                    engagement::materialize_run_candidate_for_start(&octon_dir, &contract_path)?;
                return run_descriptor_start(
                    &octon_dir,
                    descriptor,
                    true,
                    executor,
                    executor_bin,
                    model,
                    prepare_only,
                );
            }
            let descriptor = load_run_descriptor(&octon_dir, &contract_path)?;
            validate_run_lifecycle_operation(
                &repo_root,
                &descriptor.run_id,
                RunLifecycleOperation::Start,
            )?;
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
            validate_run_lifecycle_operation(&repo_root, &run_id, RunLifecycleOperation::Inspect)?;
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
            validate_run_lifecycle_operation(&repo_root, &run_id, RunLifecycleOperation::Resume)?;
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
            validate_run_lifecycle_operation(
                &repo_root,
                &run_id,
                RunLifecycleOperation::Checkpoint,
            )?;
            print_yaml_file(&resolve_ref_path(
                &octon_dir,
                &descriptor.last_checkpoint_ref,
            )?)
        }
        RunCmd::Close { run_id } => {
            let descriptor = load_run_descriptor_by_id(&octon_dir, &run_id)?;
            validate_run_lifecycle_operation(&repo_root, &run_id, RunLifecycleOperation::Close)?;
            print_yaml_file(&resolve_ref_path(&octon_dir, &descriptor.run_card_ref)?)
        }
        RunCmd::Replay { run_id } => {
            let descriptor = load_run_descriptor_by_id(&octon_dir, &run_id)?;
            validate_run_lifecycle_operation(&repo_root, &run_id, RunLifecycleOperation::Replay)?;
            print_yaml_file(&resolve_ref_path(
                &octon_dir,
                &descriptor.replay_manifest_ref,
            )?)
        }
        RunCmd::Disclose { run_id } => {
            let descriptor = load_run_descriptor_by_id(&octon_dir, &run_id)?;
            validate_run_lifecycle_operation(&repo_root, &run_id, RunLifecycleOperation::Disclose)?;
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
                let artifacts =
                    write_execution_start(&artifact_root, &request, &grant, &artifact_effects)?;
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
                let artifacts =
                    write_execution_start(&artifact_root, &request, &grant, &artifact_effects)?;
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
