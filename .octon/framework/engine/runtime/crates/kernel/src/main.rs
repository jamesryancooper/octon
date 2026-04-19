mod context;
mod orchestration;
mod pipeline;
mod request;
mod run_binding;
mod scaffold;
mod stdio;
mod workflow;

use clap::{Args, Parser, Subcommand, ValueEnum};
use octon_authority_engine::{
    artifact_root_from_relative, authorize_execution, finalize_execution, now_rfc3339,
    write_execution_start, ExecutionOutcome, ExecutionRequest, ReviewRequirements,
    ScopeConstraints, SideEffectFlags, SideEffectSummary,
};
use octon_core::errors::{ErrorCode, KernelError};
use octon_core::execution_integrity::service_capability_profile;
use octon_core::tiers::validate_runtime_discovery_tiers;
use octon_core::trace::TraceWriter;
use octon_wasm_host::policy::GrantSet;
use serde_yaml::{Mapping, Value};
use std::fs;
use std::path::PathBuf;
use std::process::Command as ProcessCommand;
use std::sync::Arc;
#[cfg(test)]
use std::sync::{Mutex, MutexGuard, OnceLock};

use crate::context::KernelContext;
use crate::pipeline::RunPipelineOptions;
use crate::workflow::ExecutorKind;

#[cfg(test)]
static KERNEL_TEST_LOCK: OnceLock<Mutex<()>> = OnceLock::new();

#[cfg(test)]
pub(crate) fn acquire_kernel_test_lock() -> MutexGuard<'static, ()> {
    KERNEL_TEST_LOCK
        .get_or_init(|| Mutex::new(()))
        .lock()
        .unwrap_or_else(|poisoned| poisoned.into_inner())
}

#[derive(Parser)]
#[command(name = "octon", version, about = "Octon executable runtime layer (v1)")]
struct Cli {
    #[command(subcommand)]
    cmd: Command,
}

#[derive(Subcommand)]
enum Command {
    /// Print kernel info.
    Info,

    /// Service management and discovery.
    Services {
        #[command(subcommand)]
        cmd: ServicesCmd,
    },

    /// Invoke a service operation (one-shot).
    Tool {
        /// Service name or category/name.
        service: String,
        /// Operation name.
        op: String,
        /// Input JSON (default: {}).
        #[arg(long = "json")]
        json: Option<String>,
    },

    /// Validate services under .octon/framework/capabilities/runtime/services.
    Validate,

    /// Run the NDJSON stdio server.
    ServeStdio,

    /// Launch Octon Studio desktop UI.
    Studio,

    /// Guest service scaffolding.
    Service {
        #[command(subcommand)]
        cmd: ServiceCmd,
    },

    /// Run-first lifecycle execution commands.
    Run {
        #[command(subcommand)]
        cmd: RunCmd,
    },

    /// Compatibility workflow wrapper over run-first lifecycle semantics.
    Workflow {
        #[command(subcommand)]
        cmd: WorkflowCmd,
    },

    /// Read-only orchestration operator inspection commands.
    Orchestration {
        #[command(subcommand)]
        cmd: OrchestrationCmd,
    },
}

#[derive(Subcommand)]
enum ServicesCmd {
    /// List discovered services.
    List,
}

#[derive(Subcommand)]
enum ServiceCmd {
    /// Create a new service scaffold.
    New { category: String, name: String },

    /// Build a service (cargo-component) and update integrity hash.
    Build {
        /// Service category, or category/name.
        target: String,
        /// Service name (required only when target is category).
        name: Option<String>,
    },
}

#[derive(Subcommand)]
enum RunCmd {
    /// Start a run from a canonical run contract.
    Start {
        /// Path to the run contract.
        #[arg(long = "contract")]
        contract: PathBuf,
        /// Executor used for prompt stages.
        #[arg(long, value_enum, default_value_t = ExecutorKind::Auto)]
        executor: ExecutorKind,
        /// Optional explicit executor binary path.
        #[arg(long = "executor-bin")]
        executor_bin: Option<String>,
        /// Optional model override.
        #[arg(long)]
        model: Option<String>,
        /// Materialize stage packets and reports without invoking executors.
        #[arg(long = "prepare-only", default_value_t = false)]
        prepare_only: bool,
    },
    /// Inspect canonical run artifacts for one run id.
    Inspect {
        #[arg(long = "run-id")]
        run_id: String,
    },
    /// Resume a run from its canonical contract and continuity artifacts.
    Resume {
        #[arg(long = "run-id")]
        run_id: String,
        /// Executor used for prompt stages.
        #[arg(long, value_enum, default_value_t = ExecutorKind::Auto)]
        executor: ExecutorKind,
        /// Optional explicit executor binary path.
        #[arg(long = "executor-bin")]
        executor_bin: Option<String>,
        /// Optional model override.
        #[arg(long)]
        model: Option<String>,
        /// Materialize stage packets and reports without invoking executors.
        #[arg(long = "prepare-only", default_value_t = false)]
        prepare_only: bool,
    },
    /// Print the latest canonical checkpoint for one run.
    Checkpoint {
        #[arg(long = "run-id")]
        run_id: String,
    },
    /// Print canonical closeout state for one run.
    Close {
        #[arg(long = "run-id")]
        run_id: String,
    },
    /// Print canonical replay artifacts for one run.
    Replay {
        #[arg(long = "run-id")]
        run_id: String,
    },
    /// Print canonical disclosure artifacts for one run.
    Disclose {
        #[arg(long = "run-id")]
        run_id: String,
    },
}

#[derive(Subcommand)]
enum WorkflowCmd {
    /// List canonical workflows.
    List,
    /// Workflow execution must enter through `octon run start --contract ...`.
    Run {
        /// Canonical workflow id.
        workflow_id: String,
        /// Optional explicit canonical run id override.
        #[arg(long = "run-id")]
        run_id: Option<String>,
        /// Optional mission id for continuity-backed autonomous execution.
        #[arg(long = "mission-id")]
        mission_id: Option<String>,
        /// Input override in the form key=value. Repeatable.
        #[arg(long = "set")]
        set: Vec<String>,
        /// Executor used for prompt stages.
        #[arg(long, value_enum, default_value_t = ExecutorKind::Auto)]
        executor: ExecutorKind,
        /// Optional explicit executor binary path.
        #[arg(long = "executor-bin")]
        executor_bin: Option<String>,
        /// Optional output slug override for the run bundle.
        #[arg(long = "output-slug")]
        output_slug: Option<String>,
        /// Optional model override.
        #[arg(long)]
        model: Option<String>,
        /// Materialize stage packets and reports without invoking executors.
        #[arg(long = "prepare-only", default_value_t = false)]
        prepare_only: bool,
    },
    /// Validate canonical workflows.
    Validate {
        /// Optional workflow id to validate semantically after collection checks.
        workflow_id: Option<String>,
    },
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, ValueEnum)]
enum OrchestrationSurfaceArg {
    Watchers,
    Queue,
    Automations,
    Runs,
    Missions,
    Incidents,
    All,
}

impl From<OrchestrationSurfaceArg> for octon_core::orchestration::SummarySurface {
    fn from(value: OrchestrationSurfaceArg) -> Self {
        match value {
            OrchestrationSurfaceArg::Watchers => Self::Watchers,
            OrchestrationSurfaceArg::Queue => Self::Queue,
            OrchestrationSurfaceArg::Automations => Self::Automations,
            OrchestrationSurfaceArg::Runs => Self::Runs,
            OrchestrationSurfaceArg::Missions => Self::Missions,
            OrchestrationSurfaceArg::Incidents => Self::Incidents,
            OrchestrationSurfaceArg::All => Self::All,
        }
    }
}

#[derive(Debug, Clone, Args)]
#[group(required = true, multiple = false)]
struct OrchestrationLookupArgs {
    #[arg(long = "decision-id")]
    decision_id: Option<String>,
    #[arg(long = "run-id")]
    run_id: Option<String>,
    #[arg(long = "incident-id")]
    incident_id: Option<String>,
    #[arg(long = "queue-item-id")]
    queue_item_id: Option<String>,
    #[arg(long = "event-id")]
    event_id: Option<String>,
    #[arg(long = "automation-id")]
    automation_id: Option<String>,
    #[arg(long = "watcher-id")]
    watcher_id: Option<String>,
    #[arg(long = "mission-id")]
    mission_id: Option<String>,
}

impl TryFrom<OrchestrationLookupArgs> for octon_core::orchestration::LookupQuery {
    type Error = anyhow::Error;

    fn try_from(value: OrchestrationLookupArgs) -> Result<Self, Self::Error> {
        if let Some(id) = value.decision_id {
            return Ok(Self::DecisionId(id));
        }
        if let Some(id) = value.run_id {
            return Ok(Self::RunId(id));
        }
        if let Some(id) = value.incident_id {
            return Ok(Self::IncidentId(id));
        }
        if let Some(id) = value.queue_item_id {
            return Ok(Self::QueueItemId(id));
        }
        if let Some(id) = value.event_id {
            return Ok(Self::EventId(id));
        }
        if let Some(id) = value.automation_id {
            return Ok(Self::AutomationId(id));
        }
        if let Some(id) = value.watcher_id {
            return Ok(Self::WatcherId(id));
        }
        if let Some(id) = value.mission_id {
            return Ok(Self::MissionId(id));
        }
        anyhow::bail!("exactly one orchestration lookup id is required");
    }
}

#[derive(Subcommand)]
enum OrchestrationIncidentCmd {
    /// Evaluate incident closure readiness.
    ClosureReadiness {
        #[arg(long = "incident-id")]
        incident_id: String,
        #[arg(long, value_enum, default_value_t = orchestration::OutputFormat::Json)]
        format: orchestration::OutputFormat,
        #[arg(long = "output-report")]
        output_report: Option<PathBuf>,
    },
}

#[derive(Subcommand)]
enum OrchestrationCmd {
    /// Resolve forward and reverse orchestration lineage by canonical id.
    Lookup {
        #[command(flatten)]
        query: OrchestrationLookupArgs,
        #[arg(long, value_enum, default_value_t = orchestration::OutputFormat::Json)]
        format: orchestration::OutputFormat,
        #[arg(long = "output-report")]
        output_report: Option<PathBuf>,
    },
    /// Summarize orchestration surface health.
    Summary {
        #[arg(long, value_enum)]
        surface: OrchestrationSurfaceArg,
        #[arg(long, value_enum, default_value_t = orchestration::OutputFormat::Json)]
        format: orchestration::OutputFormat,
        #[arg(long = "output-report")]
        output_report: Option<PathBuf>,
    },
    /// Incident-specific operator inspection commands.
    Incident {
        #[command(subcommand)]
        cmd: OrchestrationIncidentCmd,
    },
}

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();

    match cli.cmd {
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

fn cmd_info() -> anyhow::Result<()> {
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

fn cmd_services(cmd: ServicesCmd) -> anyhow::Result<()> {
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

fn cmd_validate() -> anyhow::Result<()> {
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

fn cmd_tool(service_id_or_name: &str, op: &str, input_json: Option<&str>) -> anyhow::Result<()> {
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
    };
    let grant = authorize_execution(&ctx.cfg, &ctx.policy, &request, Some(svc))?;
    run_binding::ensure_canonical_run_binding(&ctx.cfg, &request, &grant, "tool")?;
    let artifacts = write_execution_start(
        &artifact_root_from_relative(
            &ctx.cfg.repo_root,
            &ctx.cfg.execution_governance.receipt_roots.services,
            &request.request_id,
        ),
        &request,
        &grant,
    )?;
    let started_at = now_rfc3339()?;
    let grants = GrantSet::new(grant.granted_capabilities.clone());
    let run_root = ctx.cfg.repo_root.join(&grant.run_root);
    ctx.cfg.ensure_execution_write_path(&run_root)?;
    let trace = TraceWriter::new(&run_root, None).ok();
    let out = ctx.invoker.invoke(
        svc,
        grants,
        op,
        input,
        trace.as_ref(),
        &run_root,
        service_profile.adapter_id.as_deref(),
        None,
        None,
    )?;
    finalize_execution(
        &artifacts,
        &request,
        &grant,
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

fn cmd_serve_stdio() -> anyhow::Result<()> {
    let ctx = Arc::new(KernelContext::load()?);
    stdio::serve_stdio(ctx)
}

fn cmd_studio() -> anyhow::Result<()> {
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
        request::bind_repo_local_request(&ctx.cfg, std::collections::BTreeMap::new())?;

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
    };
    let grant = authorize_execution(&ctx.cfg, &ctx.policy, &request, None)?;
    run_binding::ensure_canonical_run_binding(&ctx.cfg, &request, &grant, "studio")?;
    let artifacts = write_execution_start(
        &artifact_root_from_relative(
            &ctx.cfg.repo_root,
            &ctx.cfg.execution_governance.receipt_roots.executors,
            &request.request_id,
        ),
        &request,
        &grant,
    )?;
    let started_at = now_rfc3339()?;

    std::fs::create_dir_all(&target_dir)?;

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

fn cmd_service(cmd: ServiceCmd) -> anyhow::Result<()> {
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
                request::bind_repo_local_request(&ctx.cfg, std::collections::BTreeMap::new())?;
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
            };
            let grant = authorize_execution(&ctx.cfg, &ctx.policy, &request, None)?;
            run_binding::ensure_canonical_run_binding(&ctx.cfg, &request, &grant, "service")?;
            let artifacts = write_execution_start(
                &artifact_root_from_relative(
                    &ctx.cfg.repo_root,
                    &ctx.cfg.execution_governance.receipt_roots.kernel,
                    &request.request_id,
                ),
                &request,
                &grant,
            )?;
            let started_at = now_rfc3339()?;
            scaffold::service_new(&octon_dir, &category, &name)?;
            finalize_execution(
                &artifacts,
                &request,
                &grant,
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
                request::bind_repo_local_request(&ctx.cfg, std::collections::BTreeMap::new())?;
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
            };
            let grant = authorize_execution(&ctx.cfg, &ctx.policy, &request, None)?;
            run_binding::ensure_canonical_run_binding(&ctx.cfg, &request, &grant, "service")?;
            let artifacts = write_execution_start(
                &artifact_root_from_relative(
                    &ctx.cfg.repo_root,
                    &ctx.cfg.execution_governance.receipt_roots.kernel,
                    &request.request_id,
                ),
                &request,
                &grant,
            )?;
            let started_at = now_rfc3339()?;
            scaffold::service_build(&octon_dir, &category, &name)?;
            finalize_execution(
                &artifacts,
                &request,
                &grant,
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

fn cmd_workflow(cmd: WorkflowCmd) -> anyhow::Result<()> {
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

fn cmd_run(cmd: RunCmd) -> anyhow::Result<()> {
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

fn cmd_orchestration(cmd: OrchestrationCmd) -> anyhow::Result<()> {
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
                    request::bind_repo_local_request(&ctx.cfg, std::collections::BTreeMap::new())?;
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
                };
                let grant = authorize_execution(&ctx.cfg, &ctx.policy, &request, None)?;
                let artifacts = write_execution_start(
                    &artifact_root_from_relative(
                        &ctx.cfg.repo_root,
                        &ctx.cfg.execution_governance.receipt_roots.kernel,
                        &request.request_id,
                    ),
                    &request,
                    &grant,
                )?;
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
                    request::bind_repo_local_request(&ctx.cfg, std::collections::BTreeMap::new())?;
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
                };
                let grant = authorize_execution(&ctx.cfg, &ctx.policy, &request, None)?;
                let artifacts = write_execution_start(
                    &artifact_root_from_relative(
                        &ctx.cfg.repo_root,
                        &ctx.cfg.execution_governance.receipt_roots.kernel,
                        &request.request_id,
                    ),
                    &request,
                    &grant,
                )?;
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
                    let (intent_ref, execution_role_ref, metadata) = request::bind_repo_local_request(
                        &ctx.cfg,
                        std::collections::BTreeMap::new(),
                    )?;
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
                    };
                    let grant = authorize_execution(&ctx.cfg, &ctx.policy, &request, None)?;
                    let artifacts = write_execution_start(
                        &artifact_root_from_relative(
                            &ctx.cfg.repo_root,
                            &ctx.cfg.execution_governance.receipt_roots.kernel,
                            &request.request_id,
                        ),
                        &request,
                        &grant,
                    )?;
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

fn parse_category_name(target: &str, name: Option<&str>) -> anyhow::Result<(String, String)> {
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

fn parse_kv_overrides(
    values: &[String],
) -> anyhow::Result<std::collections::HashMap<String, String>> {
    let mut out = std::collections::HashMap::new();
    for value in values {
        let (key, value) = value
            .split_once('=')
            .ok_or_else(|| anyhow::anyhow!("invalid --set value '{value}', expected key=value"))?;
        if key.is_empty() {
            anyhow::bail!("invalid --set key in '{value}'");
        }
        out.insert(key.to_string(), value.to_string());
    }
    Ok(out)
}

fn resolve_output_path(repo_root: &std::path::Path, raw: &std::path::Path) -> PathBuf {
    if raw.is_absolute() {
        raw.to_path_buf()
    } else {
        repo_root.join(raw)
    }
}

fn new_request_id(prefix: &str) -> String {
    let millis = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|duration| duration.as_millis())
        .unwrap_or(0);
    format!("{prefix}-{millis}-{}", std::process::id())
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

fn resolve_octon_path(octon_dir: &std::path::Path, raw: &std::path::Path) -> PathBuf {
    if raw.is_absolute() {
        raw.to_path_buf()
    } else if raw.starts_with(".octon") {
        octon_dir.parent().unwrap_or(octon_dir).join(raw)
    } else {
        octon_dir.join(raw)
    }
}

fn resolve_ref_path(octon_dir: &std::path::Path, raw: &str) -> anyhow::Result<PathBuf> {
    let path = PathBuf::from(raw);
    let resolved = resolve_octon_path(octon_dir, &path);
    if resolved.exists() {
        Ok(resolved)
    } else {
        anyhow::bail!("referenced artifact does not exist: {}", resolved.display());
    }
}

fn load_yaml_value(path: &std::path::Path) -> anyhow::Result<Value> {
    let content = fs::read_to_string(path)?;
    Ok(serde_yaml::from_str(&content)?)
}

fn yaml_get_string<'a>(mapping: &'a Mapping, key: &str) -> anyhow::Result<&'a str> {
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

fn yaml_get_mapping<'a>(mapping: &'a Mapping, key: &str) -> anyhow::Result<&'a Mapping> {
    mapping
        .get(Value::String(key.to_string()))
        .and_then(Value::as_mapping)
        .ok_or_else(|| anyhow::anyhow!("missing mapping field `{key}`"))
}

fn load_run_descriptor(
    octon_dir: &std::path::Path,
    contract_path: &std::path::Path,
) -> anyhow::Result<RunDescriptor> {
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

fn load_run_descriptor_by_id(
    octon_dir: &std::path::Path,
    run_id: &str,
) -> anyhow::Result<RunDescriptor> {
    let contract_path = octon_dir
        .parent()
        .unwrap_or(octon_dir)
        .join(".octon/state/control/execution/runs")
        .join(run_id)
        .join("run-contract.yml");
    load_run_descriptor(octon_dir, &contract_path)
}

fn path_to_repo_ref(octon_dir: &std::path::Path, path: &std::path::Path) -> anyhow::Result<String> {
    let repo_root = octon_dir.parent().unwrap_or(octon_dir);
    let relative = path
        .strip_prefix(repo_root)
        .map_err(|_| anyhow::anyhow!("path is outside the repo root: {}", path.display()))?;
    Ok(relative.to_string_lossy().to_string())
}

fn run_descriptor_start(
    octon_dir: &std::path::Path,
    descriptor: RunDescriptor,
    resume_existing: bool,
    executor: ExecutorKind,
    executor_bin: Option<String>,
    model: Option<String>,
    prepare_only: bool,
) -> anyhow::Result<()> {
    let input_overrides = derive_run_input_overrides(octon_dir, &descriptor)?;
    let result = pipeline::run_pipeline_from_octon_dir(
        octon_dir,
        RunPipelineOptions {
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

fn print_run_inspection(
    octon_dir: &std::path::Path,
    descriptor: &RunDescriptor,
) -> anyhow::Result<()> {
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
    octon_dir: &std::path::Path,
    descriptor: &RunDescriptor,
) -> anyhow::Result<std::collections::HashMap<String, String>> {
    let mut overrides = std::collections::HashMap::new();
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

fn print_resume_summary(
    octon_dir: &std::path::Path,
    descriptor: &RunDescriptor,
) -> anyhow::Result<()> {
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

fn print_yaml_file(path: &std::path::Path) -> anyhow::Result<()> {
    let content = fs::read_to_string(path)?;
    println!("{content}");
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::{
        Cli, Command, OrchestrationCmd, OrchestrationIncidentCmd, OrchestrationSurfaceArg, RunCmd,
        WorkflowCmd,
    };
    use crate::workflow::ExecutorKind;
    use clap::{CommandFactory, Parser};
    use std::path::PathBuf;

    #[test]
    fn cli_parses_studio_subcommand() {
        let cli = Cli::try_parse_from(["octon", "studio"])
            .expect("studio subcommand should parse successfully");
        assert!(
            matches!(cli.cmd, Command::Studio),
            "parsed command should be Studio"
        );
    }

    #[test]
    fn cli_help_lists_studio_command() {
        let mut cmd = Cli::command();
        let mut help = Vec::new();
        cmd.write_long_help(&mut help)
            .expect("long help should render");
        let help = String::from_utf8(help).expect("help should be valid utf-8");
        assert!(
            help.contains("studio"),
            "help output should contain studio command"
        );
        assert!(
            help.contains("Launch Octon Studio desktop UI"),
            "help output should include studio description"
        );
    }

    #[test]
    fn cli_parses_workflow_run_subcommand() {
        let cli = Cli::try_parse_from([
            "octon",
            "workflow",
            "run",
            "audit-design-proposal",
            "--set",
            "proposal_path=.octon/inputs/exploratory/proposals/.archive/design/orchestration-domain-design-package",
            "--executor",
            "mock",
            "--prepare-only",
        ])
        .expect("workflow run should parse successfully");

        match cli.cmd {
            Command::Workflow {
                cmd:
                    WorkflowCmd::Run {
                        workflow_id,
                        executor,
                        prepare_only,
                        ..
                    },
            } => {
                assert_eq!(workflow_id, "audit-design-proposal");
                assert_eq!(executor, ExecutorKind::Mock);
                assert!(prepare_only);
            }
            _ => panic!("parsed command should be workflow run"),
        }
    }

    #[test]
    fn cli_parses_run_start_subcommand() {
        let cli = Cli::try_parse_from([
            "octon",
            "run",
            "start",
            "--contract",
            ".octon/state/control/execution/runs/example/run-contract.yml",
            "--executor",
            "mock",
            "--prepare-only",
        ])
        .expect("run start should parse successfully");

        match cli.cmd {
            Command::Run {
                cmd:
                    RunCmd::Start {
                        contract,
                        executor,
                        prepare_only,
                        ..
                    },
            } => {
                assert_eq!(
                    contract,
                    PathBuf::from(".octon/state/control/execution/runs/example/run-contract.yml")
                );
                assert_eq!(executor, ExecutorKind::Mock);
                assert!(prepare_only);
            }
            _ => panic!("parsed command should be run start"),
        }
    }

    #[test]
    fn cli_parses_run_inspect_subcommand() {
        let cli = Cli::try_parse_from(["octon", "run", "inspect", "--run-id", "run-001"])
            .expect("run inspect should parse successfully");

        match cli.cmd {
            Command::Run {
                cmd: RunCmd::Inspect { run_id },
            } => assert_eq!(run_id, "run-001"),
            _ => panic!("parsed command should be run inspect"),
        }
    }

    #[test]
    fn cli_help_lists_workflow_command() {
        let mut cmd = Cli::command();
        let mut help = Vec::new();
        cmd.write_long_help(&mut help)
            .expect("long help should render");
        let help = String::from_utf8(help).expect("help should be valid utf-8");
        assert!(
            help.contains("workflow"),
            "help output should contain workflow command"
        );
        assert!(
            help.contains("Compatibility workflow wrapper over run-first lifecycle semantics"),
            "help output should include workflow command description"
        );
    }

    #[test]
    fn cli_help_lists_run_command() {
        let mut cmd = Cli::command();
        let mut help = Vec::new();
        cmd.write_long_help(&mut help)
            .expect("long help should render");
        let help = String::from_utf8(help).expect("help should be valid utf-8");
        assert!(
            help.contains("run"),
            "help output should contain run command"
        );
        assert!(
            help.contains("Run-first lifecycle execution commands"),
            "help output should include run command description"
        );
    }

    #[test]
    fn cli_parses_workflow_validate_subcommand() {
        let cli = Cli::try_parse_from(["octon", "workflow", "validate", "audit-design-proposal"])
            .expect("workflow validate should parse successfully");

        match cli.cmd {
            Command::Workflow {
                cmd: WorkflowCmd::Validate { workflow_id },
            } => {
                assert_eq!(workflow_id.as_deref(), Some("audit-design-proposal"));
            }
            _ => panic!("parsed command should be workflow validate"),
        }
    }

    #[test]
    fn cli_parses_orchestration_lookup_subcommand() {
        let cli = Cli::try_parse_from([
            "octon",
            "orchestration",
            "lookup",
            "--run-id",
            "run-001",
            "--format",
            "markdown",
        ])
        .expect("orchestration lookup should parse");

        match cli.cmd {
            Command::Orchestration {
                cmd: OrchestrationCmd::Lookup { query, format, .. },
            } => {
                assert_eq!(query.run_id.as_deref(), Some("run-001"));
                assert_eq!(format, crate::orchestration::OutputFormat::Markdown);
            }
            _ => panic!("parsed command should be orchestration lookup"),
        }
    }

    #[test]
    fn cli_parses_orchestration_summary_subcommand() {
        let cli = Cli::try_parse_from(["octon", "orchestration", "summary", "--surface", "all"])
            .expect("orchestration summary should parse");

        match cli.cmd {
            Command::Orchestration {
                cmd: OrchestrationCmd::Summary { surface, .. },
            } => assert_eq!(surface, OrchestrationSurfaceArg::All),
            _ => panic!("parsed command should be orchestration summary"),
        }
    }

    #[test]
    fn cli_parses_orchestration_incident_closure_subcommand() {
        let cli = Cli::try_parse_from([
            "octon",
            "orchestration",
            "incident",
            "closure-readiness",
            "--incident-id",
            "inc-001",
        ])
        .expect("incident closure-readiness should parse");

        match cli.cmd {
            Command::Orchestration {
                cmd:
                    OrchestrationCmd::Incident {
                        cmd: OrchestrationIncidentCmd::ClosureReadiness { incident_id, .. },
                    },
            } => assert_eq!(incident_id, "inc-001"),
            _ => panic!("parsed command should be incident closure-readiness"),
        }
    }

    #[test]
    fn cli_help_lists_orchestration_command() {
        let mut cmd = Cli::command();
        let mut help = Vec::new();
        cmd.write_long_help(&mut help)
            .expect("long help should render");
        let help = String::from_utf8(help).expect("help should be valid utf-8");
        assert!(
            help.contains("orchestration"),
            "help output should contain orchestration command"
        );
        assert!(
            help.contains("Read-only orchestration operator inspection commands"),
            "help output should include orchestration description"
        );
    }
}
