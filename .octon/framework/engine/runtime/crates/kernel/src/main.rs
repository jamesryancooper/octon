mod context;
mod orchestration;
mod pipeline;
mod scaffold;
mod stdio;
mod workflow;

use clap::{Args, Parser, Subcommand, ValueEnum};
use octon_core::errors::{ErrorCode, KernelError};
use octon_core::tiers::validate_runtime_discovery_tiers;
use octon_core::trace::TraceWriter;
use octon_wasm_host::policy::GrantSet;
use std::path::PathBuf;
use std::process::Command as ProcessCommand;
use std::sync::Arc;

use crate::context::KernelContext;
use crate::pipeline::RunPipelineOptions;
use crate::workflow::ExecutorKind;

#[derive(Parser)]
#[command(
    name = "octon",
    version,
    about = "Octon executable runtime layer (v1)"
)]
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

    /// Canonical workflow execution entry points.
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
enum WorkflowCmd {
    /// List canonical workflows.
    List,
    /// Run a canonical workflow.
    Run {
        /// Canonical workflow id.
        workflow_id: String,
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
        Command::Workflow { cmd } => cmd_workflow(cmd),
        Command::Orchestration { cmd } => cmd_orchestration(cmd),
    }
}

fn cmd_info() -> anyhow::Result<()> {
    let ctx = KernelContext::load()?;
    println!("octon kernel v{}", env!("CARGO_PKG_VERSION"));
    println!("repo_root: {}", ctx.cfg.repo_root.display());
    println!("octon_dir: {}", ctx.cfg.octon_dir.display());
    println!("state_dir: {}", ctx.cfg.state_dir.display());
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

    // Policy gate.
    let caps = ctx.policy.decide_allow(svc)?;
    let grants = GrantSet::new(caps);

    let input: serde_json::Value = match input_json {
        Some(s) => serde_json::from_str(s).map_err(|e| {
            KernelError::new(ErrorCode::MalformedJson, format!("invalid --json: {e}"))
        })?,
        None => serde_json::json!({}),
    };

    let trace = TraceWriter::new(&ctx.cfg.state_dir, None).ok();
    let out = ctx
        .invoker
        .invoke(svc, grants, op, input, trace.as_ref(), None, None)?;

    println!("{}", serde_json::to_string_pretty(&out)?);
    Ok(())
}

fn cmd_serve_stdio() -> anyhow::Result<()> {
    let ctx = Arc::new(KernelContext::load()?);
    stdio::serve_stdio(ctx)
}

fn cmd_studio() -> anyhow::Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let runtime_dir = octon_dir.join("framework").join("engine").join("runtime");
    let manifest_path = runtime_dir.join("crates").join("Cargo.toml");
    let target_dir = octon_dir
        .join("framework")
        .join("engine")
        .join("_ops")
        .join("state")
        .join("build")
        .join("runtime-crates-target");

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
        .env("CARGO_TARGET_DIR", target_dir)
        .status()?;

    if !status.success() {
        anyhow::bail!("octon studio exited with status {}", status);
    }

    Ok(())
}

fn cmd_service(cmd: ServiceCmd) -> anyhow::Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    match cmd {
        ServiceCmd::New { category, name } => {
            scaffold::service_new(&octon_dir, &category, &name)?;
            println!(
                "created service scaffold at .octon/framework/capabilities/runtime/services/{category}/{name}"
            );
        }
        ServiceCmd::Build { target, name } => {
            let (category, name) = parse_category_name(&target, name.as_deref())?;
            scaffold::service_build(&octon_dir, &category, &name)?;
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
            set,
            executor,
            executor_bin,
            output_slug,
            model,
            prepare_only,
        } => {
            let input_overrides = parse_kv_overrides(&set)?;
            let result = pipeline::run_pipeline_from_octon_dir(
                &octon_dir,
                RunPipelineOptions {
                    pipeline_id: workflow_id,
                    executor,
                    executor_bin: executor_bin.map(Into::into),
                    output_slug,
                    model,
                    prepare_only,
                    input_overrides,
                },
            )?;
            println!("bundle_root: {}", result.bundle_root.display());
            println!("summary_report: {}", result.summary_report.display());
            println!("final_verdict: {}", result.final_verdict);
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

fn cmd_orchestration(cmd: OrchestrationCmd) -> anyhow::Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let repo_root = octon_dir
        .parent()
        .ok_or_else(|| anyhow::anyhow!(".octon has no repository root"))?
        .to_path_buf();

    match cmd {
        OrchestrationCmd::Lookup {
            query,
            format,
            output_report,
        } => orchestration::write_lookup(
            &octon_dir,
            query.try_into()?,
            format,
            output_report.as_deref().map(|path| resolve_output_path(&repo_root, path)),
        ),
        OrchestrationCmd::Summary {
            surface,
            format,
            output_report,
        } => orchestration::write_summary(
            &octon_dir,
            surface.into(),
            format,
            output_report.as_deref().map(|path| resolve_output_path(&repo_root, path)),
        ),
        OrchestrationCmd::Incident { cmd } => match cmd {
            OrchestrationIncidentCmd::ClosureReadiness {
                incident_id,
                format,
                output_report,
            } => orchestration::write_incident_closure_readiness(
                &octon_dir,
                &incident_id,
                format,
                output_report.as_deref().map(|path| resolve_output_path(&repo_root, path)),
            ),
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

#[cfg(test)]
mod tests {
    use super::{
        Cli, Command, OrchestrationCmd, OrchestrationIncidentCmd, OrchestrationSurfaceArg,
        WorkflowCmd,
    };
    use crate::workflow::ExecutorKind;
    use clap::{CommandFactory, Parser};

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
            help.contains("Canonical workflow execution entry points"),
            "help output should include workflow command description"
        );
    }

    #[test]
    fn cli_parses_workflow_validate_subcommand() {
        let cli = Cli::try_parse_from([
            "octon",
            "workflow",
            "validate",
            "audit-design-proposal",
        ])
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
                cmd:
                    OrchestrationCmd::Lookup {
                        query,
                        format,
                        ..
                    },
            } => {
                assert_eq!(query.run_id.as_deref(), Some("run-001"));
                assert_eq!(format, crate::orchestration::OutputFormat::Markdown);
            }
            _ => panic!("parsed command should be orchestration lookup"),
        }
    }

    #[test]
    fn cli_parses_orchestration_summary_subcommand() {
        let cli = Cli::try_parse_from([
            "octon",
            "orchestration",
            "summary",
            "--surface",
            "all",
        ])
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
                        cmd:
                            OrchestrationIncidentCmd::ClosureReadiness { incident_id, .. },
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
