mod commands;
mod context;
mod orchestration;
mod pipeline;
mod request;
mod request_builders;
mod run_binding;
mod scaffold;
mod side_effects;
mod stdio;
mod workflow;

use crate::workflow::ExecutorKind;
use clap::{Args, Parser, Subcommand, ValueEnum};
use std::path::PathBuf;
#[cfg(test)]
use std::sync::{Mutex, MutexGuard, OnceLock};

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
    commands::dispatch(cli.cmd)
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
