#![recursion_limit = "512"]

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
    /// Start a prepare-only Engagement for governed work.
    Start(StartCmd),

    /// Build or reconcile the Project Profile for an Engagement.
    Profile(ProfileCmd),

    /// Compile the Objective Brief and Work Package draft for an Engagement.
    Plan(PlanCmd),

    /// Prepare a Work Package handoff candidate without executing it.
    Arm(ArmCmd),

    /// Show Engagement status from canonical control and evidence roots.
    Status(StatusCmd),

    /// Continue the active mission through the governed mission runner.
    Continue(ContinueCmd),

    /// Mission-scoped governed continuation commands.
    Mission {
        #[command(subcommand)]
        cmd: MissionCmd,
    },

    /// Operator-facing Decision Request inspection and resolution.
    Decide {
        #[command(subcommand)]
        cmd: DecideCmd,
    },

    /// Connector posture and narrow admission inspection commands.
    Connector {
        #[command(subcommand)]
        cmd: ConnectorCmd,
    },

    /// Support-target proof helpers.
    Support {
        #[command(subcommand)]
        cmd: SupportCmd,
    },

    /// Capability-pack mapping helpers.
    Capability {
        #[command(subcommand)]
        cmd: CapabilityCmd,
    },

    /// Continuous stewardship availability and epoch admission commands.
    Steward {
        #[command(subcommand)]
        cmd: StewardCmd,
    },

    /// Self-evolution candidate, proposal, proof, and ledger commands.
    Evolve {
        #[command(subcommand)]
        cmd: EvolveCmd,
    },

    /// Constitutional amendment request commands.
    Amend {
        #[command(subcommand)]
        cmd: AmendCmd,
    },

    /// Proposal promotion inspection and gated apply commands.
    Promote {
        #[command(subcommand)]
        cmd: PromoteCmd,
    },

    /// Post-promotion recertification commands.
    Recertify {
        #[command(subcommand)]
        cmd: RecertifyCmd,
    },

    /// Run doctor checks over the live runtime architecture.
    Doctor {
        /// Validate the aggregate architecture health gate.
        #[arg(long, default_value_t = false)]
        architecture: bool,
    },

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

    /// Token-enforced publication wrappers for generated-effective outputs.
    Publish {
        #[command(subcommand)]
        cmd: PublishCmd,
    },

    /// Narrow protected-CI operations routed through the runtime boundary.
    ProtectedCi {
        #[command(subcommand)]
        cmd: ProtectedCiCmd,
    },

    /// Internal publication verification entrypoints.
    #[command(hide = true)]
    PublicationInternal {
        #[command(subcommand)]
        cmd: PublicationInternalCmd,
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

#[derive(Debug, Clone, Args)]
pub(crate) struct StartCmd {
    /// Optional explicit engagement id.
    #[arg(long = "engagement-id")]
    engagement_id: Option<String>,
    /// Seed intent to bind into the Engagement.
    #[arg(long)]
    intent: Option<String>,
    /// Keep the compiler in preflight/prepare-only mode.
    #[arg(long = "prepare-only", default_value_t = true)]
    prepare_only: bool,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct ProfileCmd {
    /// Engagement id returned by `octon start`.
    #[arg(long = "engagement-id")]
    engagement_id: String,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct PlanCmd {
    /// Engagement id returned by `octon start`.
    #[arg(long = "engagement-id")]
    engagement_id: String,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct ArmCmd {
    /// Engagement id returned by `octon start`.
    #[arg(long = "engagement-id")]
    engagement_id: String,
    /// Required v1 posture: prepare artifacts only, do not execute.
    #[arg(long = "prepare-only", default_value_t = true)]
    prepare_only: bool,
    /// Existing workflow id for the eventual `octon run start --contract` handoff.
    #[arg(long = "workflow-id", default_value = "agent-led-happy-path")]
    workflow_id: String,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct StatusCmd {
    /// Engagement id returned by `octon start`.
    #[arg(long = "engagement-id")]
    engagement_id: String,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct ContinueCmd {
    /// Optional Engagement id. Defaults to the single active Engagement.
    #[arg(long = "engagement-id")]
    engagement_id: Option<String>,
    /// Optional Mission id. Defaults to the Engagement active mission binding.
    #[arg(long = "mission-id")]
    mission_id: Option<String>,
    /// Attempt the existing run-start path after gates and decisions pass.
    #[arg(long = "start-run", default_value_t = false)]
    start_run: bool,
}

#[derive(Subcommand)]
pub(crate) enum MissionCmd {
    /// Open or verify mission state for an Engagement.
    Open(MissionOpenCmd),
    /// Show mission status from canonical control roots.
    Status(MissionStatusCmd),
    /// Continue a mission by one bounded Action Slice decision.
    Continue(MissionContinueCmd),
    /// Pause a mission at the mission control layer.
    Pause(MissionStatusCmd),
    /// Resume a paused mission when gates still pass.
    Resume(MissionStatusCmd),
    /// Revoke a mission and block continuation.
    Revoke(MissionStatusCmd),
    /// Close a mission after closeout gates pass.
    Close(MissionStatusCmd),
    /// Print Mission Queue state.
    Queue(MissionStatusCmd),
    /// Print the next selectable Action Slice.
    Next(MissionStatusCmd),
}

#[derive(Debug, Clone, Args)]
pub(crate) struct MissionOpenCmd {
    /// Engagement id returned by `octon start`.
    #[arg(long = "engagement")]
    engagement_id: String,
    /// Optional explicit mission id.
    #[arg(long = "mission-id")]
    mission_id: Option<String>,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct MissionStatusCmd {
    /// Mission id to inspect.
    #[arg(long = "mission-id")]
    mission_id: String,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct MissionContinueCmd {
    /// Mission id to continue.
    #[arg(long = "mission-id")]
    mission_id: String,
    /// Attempt the existing run-start path after gates and decisions pass.
    #[arg(long = "start-run", default_value_t = false)]
    start_run: bool,
}

#[derive(Subcommand)]
pub(crate) enum DecideCmd {
    /// List open Decision Requests across Engagement and Mission control roots.
    List(DecisionListCmd),
    /// Resolve one Decision Request.
    Resolve(DecisionResolveCmd),
}

#[derive(Debug, Clone, Args)]
pub(crate) struct DecisionListCmd {
    /// Optional Engagement id to scope the list.
    #[arg(long = "engagement-id")]
    engagement_id: Option<String>,
    /// Optional Mission id to scope the list.
    #[arg(long = "mission-id")]
    mission_id: Option<String>,
    /// Optional Stewardship Program id to scope the list.
    #[arg(long = "program-id")]
    program_id: Option<String>,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct DecisionResolveCmd {
    /// Decision Request id to resolve.
    decision_id: String,
    /// Optional Engagement id for v1 engagement decisions.
    #[arg(long = "engagement-id")]
    engagement_id: Option<String>,
    /// Optional Mission id for mission-aware decisions.
    #[arg(long = "mission-id")]
    mission_id: Option<String>,
    /// Optional Stewardship Program id for stewardship-aware decisions.
    #[arg(long = "program-id")]
    program_id: Option<String>,
    /// Operator response to materialize.
    #[arg(long = "response", value_enum)]
    response: DecisionResponseArg,
}

#[derive(Subcommand)]
pub(crate) enum ConnectorCmd {
    /// List known connector identities and operation summaries.
    List(ConnectorListCmd),
    /// Inspect connector posture, operation contracts, and admissions.
    Inspect(ConnectorInspectCmd),
    /// Show connector control status.
    Status(ConnectorOperationCmd),
    /// Validate connector admission posture without executing operations.
    Validate(ConnectorOperationCmd),
    /// Admit a connector operation in a narrowly scoped mode.
    Admit(ConnectorAdmitCmd),
    /// Stage a connector operation without live effects.
    Stage(ConnectorOperationCmd),
    /// Quarantine a connector operation.
    Quarantine(ConnectorOperationCmd),
    /// Retire a connector operation.
    Retire(ConnectorOperationCmd),
    /// Show the Connector Trust Dossier for an operation.
    Dossier(ConnectorOperationCmd),
    /// Show retained connector evidence refs.
    Evidence(ConnectorOperationCmd),
    /// Detect or report connector drift.
    Drift(ConnectorOperationCmd),
    /// Create a connector Decision Request.
    Decision(ConnectorDecisionCmd),
}

#[derive(Debug, Clone, Args)]
pub(crate) struct ConnectorListCmd {
    /// Optional connector id/class to filter.
    #[arg(long = "connector")]
    connector_id: Option<String>,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct ConnectorInspectCmd {
    /// Optional connector id/class to inspect.
    #[arg(long = "connector")]
    connector_id: Option<String>,
    /// Optional operation id to inspect.
    #[arg(long = "operation")]
    operation_id: Option<String>,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct ConnectorOperationCmd {
    /// Connector id/class.
    #[arg(long = "connector")]
    connector_id: String,
    /// Operation id.
    #[arg(long = "operation")]
    operation_id: String,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct ConnectorAdmitCmd {
    /// Connector id/class.
    #[arg(long = "connector")]
    connector_id: String,
    /// Operation id.
    #[arg(long = "operation")]
    operation_id: String,
    /// Observe-only admission.
    #[arg(long = "observe-only", default_value_t = false)]
    observe_only: bool,
    /// Read-only admission.
    #[arg(long = "read-only", default_value_t = false)]
    read_only: bool,
    /// Stage-only admission. Live connector effects remain deferred unless explicitly supported.
    #[arg(long = "stage-only", default_value_t = false)]
    stage_only: bool,
    /// Live-effectful admission request. Requires proof, policy, Decision Request, authorization, and effect token.
    #[arg(long = "live", default_value_t = false)]
    live: bool,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct ConnectorDecisionCmd {
    /// Connector id/class.
    #[arg(long = "connector")]
    connector_id: String,
    /// Operation id.
    #[arg(long = "operation")]
    operation_id: String,
    /// Decision type.
    #[arg(long = "type", default_value = "connector_admission_requested")]
    decision_type: String,
}

#[derive(Subcommand)]
pub(crate) enum SupportCmd {
    /// Support proof helpers.
    Proof(SupportProofCmd),
    /// Validate connector support proof posture.
    ValidateConnector(ConnectorOperationCmd),
}

#[derive(Debug, Clone, Args)]
pub(crate) struct SupportProofCmd {
    /// Proof subject.
    #[command(subcommand)]
    subject: SupportProofSubject,
}

#[derive(Subcommand, Debug, Clone)]
pub(crate) enum SupportProofSubject {
    /// Show connector support proof refs.
    Connector(ConnectorOperationCmd),
}

#[derive(Subcommand)]
pub(crate) enum CapabilityCmd {
    /// Show connector-to-capability-pack mapping.
    MapConnector(ConnectorOperationCmd),
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, ValueEnum)]
pub(crate) enum DecisionResponseArg {
    Approve,
    Deny,
    ExceptionLease,
    AcceptRisk,
    Revoke,
    Clarify,
    SupportScope,
    CapabilityAdmission,
    MissionScope,
    Close,
}

impl DecisionResponseArg {
    pub(crate) fn as_resolution(self) -> &'static str {
        match self {
            Self::Approve => "approval",
            Self::Deny => "denial",
            Self::ExceptionLease => "exception_lease",
            Self::AcceptRisk => "risk_acceptance",
            Self::Revoke => "revocation",
            Self::Clarify => "policy_clarification",
            Self::SupportScope => "support_scope_decision",
            Self::CapabilityAdmission => "capability_admission_decision",
            Self::MissionScope => "mission_scope_decision",
            Self::Close => "closure_acceptance",
        }
    }
}

#[derive(Subcommand)]
pub(crate) enum StewardCmd {
    /// Open or verify one repo-local Stewardship Program and active finite epoch.
    Open(StewardOpenCmd),
    /// Show Stewardship Program and active epoch status.
    Status(StewardProgramCmd),
    /// Normalize a supported stewardship trigger without admitting work.
    Observe(StewardObserveCmd),
    /// Evaluate a normalized trigger and emit an Admission Decision.
    Admit(StewardAdmitCmd),
    /// Emit or display Idle Decision state.
    Idle(StewardIdleCmd),
    /// Emit a Renewal Decision after epoch closeout gates.
    Renew(StewardRenewCmd),
    /// Pause the active Stewardship Epoch.
    Pause(StewardProgramCmd),
    /// Resume a paused Stewardship Epoch when gates still pass.
    Resume(StewardProgramCmd),
    /// Revoke the Stewardship Program and active epoch.
    Revoke(StewardProgramCmd),
    /// Close the Stewardship Program when closure gates pass.
    Close(StewardProgramCmd),
    /// Print the Stewardship Ledger.
    Ledger(StewardProgramCmd),
    /// Print normalized Stewardship Triggers.
    Triggers(StewardProgramCmd),
    /// Print Stewardship Epoch records.
    Epochs(StewardProgramCmd),
    /// Print stewardship-aware Decision Requests.
    Decisions(StewardProgramCmd),
}

#[derive(Subcommand)]
pub(crate) enum EvolveCmd {
    /// Observe retained evidence and report the current candidate bridge.
    Observe(EvolveProgramCmd),
    /// List Evolution Candidates.
    Candidates(EvolveProgramCmd),
    /// Inspect one Evolution Candidate.
    Inspect(EvolveCandidateArg),
    /// Classify one Evolution Candidate.
    Classify(EvolveCandidateArg),
    /// Inspect required governance impact simulation for one candidate.
    Simulate(EvolveCandidateArg),
    /// Inspect required assurance lab gate for one candidate.
    Lab(EvolveCandidateArg),
    /// Compile or inspect the proposal packet for one candidate without promoting it.
    Propose(EvolveCandidateArg),
    /// Inspect Decision Request or Constitutional Amendment Request state.
    Decide(EvolveDecisionArg),
    /// Inspect promotion posture for a proposal id or proposal path.
    Promote(EvolveProposalArg),
    /// Inspect recertification posture.
    Recertify(EvolveProgramCmd),
    /// Inspect rollback posture.
    Rollback(EvolveProgramCmd),
    /// Inspect retirement posture.
    Retire(EvolveProgramCmd),
    /// Print the Evolution Ledger.
    Ledger(EvolveProgramCmd),
}

#[derive(Subcommand)]
pub(crate) enum AmendCmd {
    /// Inspect or create the required Constitutional Amendment Request posture for a candidate.
    Request(EvolveCandidateArg),
    /// Inspect one Constitutional Amendment Request.
    Inspect(EvolveAmendmentArg),
}

#[derive(Subcommand)]
pub(crate) enum PromoteCmd {
    /// Inspect one self-evolution promotion request.
    Inspect(EvolvePromotionArg),
    /// Apply or dry-run one promotion request. Fails closed without accepted approval and recertification posture.
    Apply(EvolvePromotionArg),
    /// Print one retained promotion receipt.
    Receipt(EvolvePromotionArg),
}

#[derive(Subcommand)]
pub(crate) enum RecertifyCmd {
    /// Show self-evolution recertification status.
    Status(EvolveProgramCmd),
    /// Run a file-backed recertification dry-run and report pass/block state.
    Run(EvolveProgramCmd),
}

#[derive(Debug, Clone, Args)]
pub(crate) struct EvolveProgramCmd {
    /// Evolution Program id. Defaults to the repo-local MVP program.
    #[arg(long = "program-id", default_value = "octon-self-evolution")]
    program_id: String,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct EvolveCandidateArg {
    /// Evolution Candidate id.
    candidate: String,
    /// Evolution Program id. Defaults to the repo-local MVP program.
    #[arg(long = "program-id", default_value = "octon-self-evolution")]
    program_id: String,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct EvolveDecisionArg {
    /// Proposal id, Decision Request id, or Constitutional Amendment Request id.
    proposal_or_request: String,
    /// Evolution Program id. Defaults to the repo-local MVP program.
    #[arg(long = "program-id", default_value = "octon-self-evolution")]
    program_id: String,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct EvolveProposalArg {
    /// Proposal id or proposal path.
    proposal: String,
    /// Evolution Program id. Defaults to the repo-local MVP program.
    #[arg(long = "program-id", default_value = "octon-self-evolution")]
    program_id: String,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct EvolveAmendmentArg {
    /// Constitutional Amendment Request id.
    request_id: String,
    /// Evolution Program id. Defaults to the repo-local MVP program.
    #[arg(long = "program-id", default_value = "octon-self-evolution")]
    program_id: String,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct EvolvePromotionArg {
    /// Promotion id.
    #[arg(
        long = "promotion-id",
        default_value = "evolution-promotion-v5-validation"
    )]
    promotion_id: String,
    /// Evolution Program id. Defaults to the repo-local MVP program.
    #[arg(long = "program-id", default_value = "octon-self-evolution")]
    program_id: String,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct StewardProgramCmd {
    /// Stewardship Program id. Defaults to the repo-local MVP program.
    #[arg(long = "program-id", default_value = "octon-continuous-stewardship")]
    program_id: String,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct StewardOpenCmd {
    /// Stewardship Program id. Defaults to the repo-local MVP program.
    #[arg(long = "program-id", default_value = "octon-continuous-stewardship")]
    program_id: String,
    /// Optional explicit epoch id.
    #[arg(long = "epoch-id")]
    epoch_id: Option<String>,
    /// Stewardship objective for the repo-scoped care agreement.
    #[arg(
        long = "objective",
        default_value = "Maintain governed Octon harness readiness without unbounded execution."
    )]
    objective: String,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct StewardObserveCmd {
    /// Stewardship Program id. Defaults to the repo-local MVP program.
    #[arg(long = "program-id", default_value = "octon-continuous-stewardship")]
    program_id: String,
    /// Trigger family to normalize.
    #[arg(long = "trigger-type", value_enum, default_value_t = StewardTriggerArg::ScheduledReview)]
    trigger_type: StewardTriggerArg,
    /// Human-readable trigger summary.
    #[arg(long = "summary")]
    summary: Option<String>,
    /// Optional source reference. Must not be treated as authority.
    #[arg(long = "source-ref")]
    source_ref: Option<String>,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct StewardAdmitCmd {
    /// Stewardship Program id. Defaults to the repo-local MVP program.
    #[arg(long = "program-id", default_value = "octon-continuous-stewardship")]
    program_id: String,
    /// Trigger id to admit. Defaults to the oldest pending trigger.
    #[arg(long = "trigger-id")]
    trigger_id: Option<String>,
    /// Existing v1 Engagement id to use for an optional v2 mission handoff.
    #[arg(long = "engagement-id")]
    engagement_id: Option<String>,
    /// Allow campaign candidate evaluation. Campaign promotion still remains blocked without criteria evidence.
    #[arg(long = "campaign-candidate", default_value_t = false)]
    campaign_candidate: bool,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct StewardIdleCmd {
    /// Stewardship Program id. Defaults to the repo-local MVP program.
    #[arg(long = "program-id", default_value = "octon-continuous-stewardship")]
    program_id: String,
    /// Optional reason for the idle decision.
    #[arg(long = "reason")]
    reason: Option<String>,
}

#[derive(Debug, Clone, Args)]
pub(crate) struct StewardRenewCmd {
    /// Stewardship Program id. Defaults to the repo-local MVP program.
    #[arg(long = "program-id", default_value = "octon-continuous-stewardship")]
    program_id: String,
    /// Renewal outcome requested by the operator.
    #[arg(long = "outcome", value_enum, default_value_t = StewardRenewalOutcomeArg::IdleUntilNextTrigger)]
    outcome: StewardRenewalOutcomeArg,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, ValueEnum)]
pub(crate) enum StewardTriggerArg {
    ScheduledReview,
    HumanObjective,
    PriorMissionFollowup,
    ValidationEvidenceAgeout,
    RepoChange,
    CiFailure,
    DependencyDrift,
    SupportPostureDrift,
    ContextStaleness,
    ProjectProfileStaleness,
    WorkPackageAssumptionExpiry,
    DecisionRequestResolved,
    ConnectorPostureDrift,
    GeneratedEffectiveHandleStaleness,
}

impl StewardTriggerArg {
    pub(crate) fn as_str(self) -> &'static str {
        match self {
            Self::ScheduledReview => "scheduled_review",
            Self::HumanObjective => "human_objective",
            Self::PriorMissionFollowup => "prior_mission_followup",
            Self::ValidationEvidenceAgeout => "validation_evidence_ageout",
            Self::RepoChange => "repo_change",
            Self::CiFailure => "ci_failure",
            Self::DependencyDrift => "dependency_drift",
            Self::SupportPostureDrift => "support_posture_drift",
            Self::ContextStaleness => "context_staleness",
            Self::ProjectProfileStaleness => "project_profile_staleness",
            Self::WorkPackageAssumptionExpiry => "work_package_assumption_expiry",
            Self::DecisionRequestResolved => "decision_request_resolved",
            Self::ConnectorPostureDrift => "connector_posture_drift",
            Self::GeneratedEffectiveHandleStaleness => "generated_effective_handle_staleness",
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, ValueEnum)]
pub(crate) enum StewardRenewalOutcomeArg {
    Renew,
    Close,
    Pause,
    Escalate,
    Revoke,
    IdleUntilNextTrigger,
}

impl StewardRenewalOutcomeArg {
    pub(crate) fn as_str(self) -> &'static str {
        match self {
            Self::Renew => "renew",
            Self::Close => "close",
            Self::Pause => "pause",
            Self::Escalate => "escalate",
            Self::Revoke => "revoke",
            Self::IdleUntilNextTrigger => "idle_until_next_trigger",
        }
    }
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

#[derive(Subcommand)]
enum PublishCmd {
    /// Publish the effective support-target matrix through the runtime boundary.
    SupportTargetMatrix,
    /// Publish effective pack routes through the runtime boundary.
    PackRoutes,
    /// Publish the runtime route bundle through the runtime boundary.
    RuntimeRouteBundle,
    /// Publish extension active/quarantine state through the runtime boundary.
    ExtensionState,
    /// Publish capability routing through the runtime boundary.
    CapabilityRouting,
    /// Publish host projections through the runtime boundary.
    HostProjections,
}

#[derive(Subcommand)]
enum ProtectedCiCmd {
    /// Merge one PR through the token-enforced protected-CI boundary.
    AutoMerge {
        /// Repository slug in owner/name form. Defaults to GH_REPO when omitted.
        #[arg(long = "repo")]
        repo: Option<String>,
        /// Pull request number.
        #[arg(long = "pr-number")]
        pr_number: u64,
        /// Canonical GitHub control approval projection JSON.
        #[arg(long = "control-json")]
        control_json: PathBuf,
        /// Delete the head branch after a successful merge when possible.
        #[arg(long = "delete-head-ref", default_value_t = true)]
        delete_head_ref: bool,
    },
}

#[derive(Subcommand)]
enum PublicationInternalCmd {
    /// Verify one runtime-issued publication token manifest before script mutation.
    #[command(hide = true)]
    VerifyManifest {
        #[arg(long = "publisher")]
        publisher: String,
        #[arg(long = "manifest")]
        manifest: PathBuf,
        #[arg(long = "result-manifest")]
        result_manifest: PathBuf,
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
        AmendCmd, ArmCmd, CapabilityCmd, Cli, Command, ConnectorCmd, DecideCmd,
        DecisionResponseArg, EvolveCmd, MissionCmd, OrchestrationCmd, OrchestrationIncidentCmd,
        OrchestrationSurfaceArg, PlanCmd, ProfileCmd, PromoteCmd, RecertifyCmd, RunCmd, StartCmd,
        StatusCmd, StewardCmd, StewardRenewalOutcomeArg, StewardTriggerArg, SupportCmd,
        SupportProofSubject, WorkflowCmd,
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
    fn cli_parses_doctor_architecture_command() {
        let cli = Cli::try_parse_from(["octon", "doctor", "--architecture"])
            .expect("doctor command should parse successfully");

        match cli.cmd {
            Command::Doctor { architecture } => assert!(architecture),
            _ => panic!("parsed command should be doctor"),
        }
    }

    #[test]
    fn cli_parses_engagement_start_command() {
        let cli = Cli::try_parse_from([
            "octon",
            "start",
            "--intent",
            "Prepare a governed work package",
        ])
        .expect("start command should parse successfully");

        match cli.cmd {
            Command::Start(StartCmd {
                intent,
                prepare_only,
                ..
            }) => {
                assert_eq!(intent.as_deref(), Some("Prepare a governed work package"));
                assert!(prepare_only);
            }
            _ => panic!("parsed command should be start"),
        }
    }

    #[test]
    fn cli_parses_engagement_profile_command() {
        let cli = Cli::try_parse_from(["octon", "profile", "--engagement-id", "engagement-001"])
            .expect("profile command should parse successfully");

        match cli.cmd {
            Command::Profile(ProfileCmd { engagement_id }) => {
                assert_eq!(engagement_id, "engagement-001");
            }
            _ => panic!("parsed command should be profile"),
        }
    }

    #[test]
    fn cli_parses_engagement_plan_command() {
        let cli = Cli::try_parse_from(["octon", "plan", "--engagement-id", "engagement-001"])
            .expect("plan command should parse successfully");

        match cli.cmd {
            Command::Plan(PlanCmd { engagement_id }) => {
                assert_eq!(engagement_id, "engagement-001");
            }
            _ => panic!("parsed command should be plan"),
        }
    }

    #[test]
    fn cli_parses_engagement_arm_prepare_only_command() {
        let cli = Cli::try_parse_from([
            "octon",
            "arm",
            "--engagement-id",
            "engagement-001",
            "--prepare-only",
            "--workflow-id",
            "agent-led-happy-path",
        ])
        .expect("arm command should parse successfully");

        match cli.cmd {
            Command::Arm(ArmCmd {
                engagement_id,
                prepare_only,
                workflow_id,
            }) => {
                assert_eq!(engagement_id, "engagement-001");
                assert!(prepare_only);
                assert_eq!(workflow_id, "agent-led-happy-path");
            }
            _ => panic!("parsed command should be arm"),
        }
    }

    #[test]
    fn cli_parses_engagement_decide_command() {
        let cli = Cli::try_parse_from([
            "octon",
            "decide",
            "resolve",
            "engagement-001-authorize-run",
            "--engagement-id",
            "engagement-001",
            "--response",
            "approve",
        ])
        .expect("decide command should parse successfully");

        match cli.cmd {
            Command::Decide {
                cmd:
                    DecideCmd::Resolve(super::DecisionResolveCmd {
                        engagement_id,
                        decision_id,
                        response,
                        ..
                    }),
            } => {
                assert_eq!(engagement_id.as_deref(), Some("engagement-001"));
                assert_eq!(decision_id, "engagement-001-authorize-run");
                assert_eq!(response, DecisionResponseArg::Approve);
            }
            _ => panic!("parsed command should be decide"),
        }
    }

    #[test]
    fn cli_parses_mission_continue_command() {
        let cli = Cli::try_parse_from([
            "octon",
            "mission",
            "continue",
            "--mission-id",
            "mission-001",
        ])
        .expect("mission continue command should parse successfully");

        match cli.cmd {
            Command::Mission {
                cmd: MissionCmd::Continue(args),
            } => {
                assert_eq!(args.mission_id, "mission-001");
                assert!(!args.start_run);
            }
            _ => panic!("parsed command should be mission continue"),
        }
    }

    #[test]
    fn cli_parses_connector_stage_only_admission_command() {
        let cli = Cli::try_parse_from([
            "octon",
            "connector",
            "admit",
            "--stage-only",
            "--connector",
            "mcp",
            "--operation",
            "observe-context",
        ])
        .expect("connector admit command should parse successfully");

        match cli.cmd {
            Command::Connector {
                cmd: ConnectorCmd::Admit(args),
            } => {
                assert_eq!(args.connector_id, "mcp");
                assert_eq!(args.operation_id, "observe-context");
                assert!(args.stage_only);
                assert!(!args.live);
            }
            _ => panic!("parsed command should be connector admit"),
        }
    }

    #[test]
    fn cli_parses_connector_runtime_v4_commands() {
        let cases = [
            ["octon", "connector", "list", "--connector", "mcp"].as_slice(),
            [
                "octon",
                "connector",
                "inspect",
                "--connector",
                "mcp",
                "--operation",
                "observe-context",
            ]
            .as_slice(),
            [
                "octon",
                "connector",
                "status",
                "--connector",
                "mcp",
                "--operation",
                "observe-context",
            ]
            .as_slice(),
            [
                "octon",
                "connector",
                "validate",
                "--connector",
                "mcp",
                "--operation",
                "observe-context",
            ]
            .as_slice(),
            [
                "octon",
                "connector",
                "stage",
                "--connector",
                "mcp",
                "--operation",
                "observe-context",
            ]
            .as_slice(),
            [
                "octon",
                "connector",
                "quarantine",
                "--connector",
                "mcp",
                "--operation",
                "observe-context",
            ]
            .as_slice(),
            [
                "octon",
                "connector",
                "retire",
                "--connector",
                "mcp",
                "--operation",
                "observe-context",
            ]
            .as_slice(),
            [
                "octon",
                "connector",
                "dossier",
                "--connector",
                "mcp",
                "--operation",
                "observe-context",
            ]
            .as_slice(),
            [
                "octon",
                "connector",
                "evidence",
                "--connector",
                "mcp",
                "--operation",
                "observe-context",
            ]
            .as_slice(),
            [
                "octon",
                "connector",
                "drift",
                "--connector",
                "mcp",
                "--operation",
                "observe-context",
            ]
            .as_slice(),
            [
                "octon",
                "connector",
                "decision",
                "--connector",
                "mcp",
                "--operation",
                "observe-context",
                "--type",
                "connector_admission_requested",
            ]
            .as_slice(),
        ];

        for args in cases {
            Cli::try_parse_from(args).expect("connector v4 command should parse");
        }
    }

    #[test]
    fn cli_parses_connector_support_and_capability_helpers() {
        let support = Cli::try_parse_from([
            "octon",
            "support",
            "proof",
            "connector",
            "--connector",
            "mcp",
            "--operation",
            "observe-context",
        ])
        .expect("support proof connector should parse");
        match support.cmd {
            Command::Support {
                cmd:
                    SupportCmd::Proof(super::SupportProofCmd {
                        subject: SupportProofSubject::Connector(args),
                    }),
            } => {
                assert_eq!(args.connector_id, "mcp");
                assert_eq!(args.operation_id, "observe-context");
            }
            _ => panic!("parsed command should be support proof connector"),
        }

        let support_validate = Cli::try_parse_from([
            "octon",
            "support",
            "validate-connector",
            "--connector",
            "mcp",
            "--operation",
            "observe-context",
        ])
        .expect("support validate-connector should parse");
        assert!(matches!(
            support_validate.cmd,
            Command::Support {
                cmd: SupportCmd::ValidateConnector(_)
            }
        ));

        let capability = Cli::try_parse_from([
            "octon",
            "capability",
            "map-connector",
            "--connector",
            "mcp",
            "--operation",
            "observe-context",
        ])
        .expect("capability map-connector should parse");
        assert!(matches!(
            capability.cmd,
            Command::Capability {
                cmd: CapabilityCmd::MapConnector(_)
            }
        ));
    }

    #[test]
    fn cli_parses_engagement_status_command() {
        let cli = Cli::try_parse_from(["octon", "status", "--engagement-id", "engagement-001"])
            .expect("status command should parse successfully");

        match cli.cmd {
            Command::Status(StatusCmd { engagement_id }) => {
                assert_eq!(engagement_id, "engagement-001");
            }
            _ => panic!("parsed command should be status"),
        }
    }

    #[test]
    fn cli_help_lists_engagement_compiler_commands() {
        let mut cmd = Cli::command();
        let mut help = Vec::new();
        cmd.write_long_help(&mut help)
            .expect("long help should render");
        let help = String::from_utf8(help).expect("help should be valid utf-8");

        for command in [
            "start",
            "profile",
            "plan",
            "arm",
            "decide",
            "status",
            "continue",
            "mission",
            "connector",
            "steward",
        ] {
            assert!(
                help.contains(command),
                "help output should contain engagement or mission runtime command {command}"
            );
        }
        assert!(
            help.contains("Prepare a Work Package handoff candidate without executing it"),
            "help output should describe arm as a prepare-only handoff"
        );
    }

    #[test]
    fn cli_parses_steward_observe_command() {
        let cli = Cli::try_parse_from([
            "octon",
            "steward",
            "observe",
            "--program-id",
            "octon-continuous-stewardship",
            "--trigger-type",
            "human-objective",
            "--summary",
            "Review stale validation posture",
        ])
        .expect("steward observe command should parse successfully");

        match cli.cmd {
            Command::Steward {
                cmd: StewardCmd::Observe(args),
            } => {
                assert_eq!(args.program_id, "octon-continuous-stewardship");
                assert_eq!(args.trigger_type, StewardTriggerArg::HumanObjective);
                assert_eq!(
                    args.summary.as_deref(),
                    Some("Review stale validation posture")
                );
            }
            _ => panic!("parsed command should be steward observe"),
        }
    }

    #[test]
    fn cli_parses_steward_lifecycle_commands() {
        let cases = [
            ["octon", "steward", "open", "--program-id", "program-001"].as_slice(),
            ["octon", "steward", "status", "--program-id", "program-001"].as_slice(),
            ["octon", "steward", "idle", "--program-id", "program-001"].as_slice(),
            ["octon", "steward", "pause", "--program-id", "program-001"].as_slice(),
            ["octon", "steward", "resume", "--program-id", "program-001"].as_slice(),
            ["octon", "steward", "revoke", "--program-id", "program-001"].as_slice(),
            ["octon", "steward", "close", "--program-id", "program-001"].as_slice(),
            ["octon", "steward", "ledger", "--program-id", "program-001"].as_slice(),
            [
                "octon",
                "steward",
                "triggers",
                "--program-id",
                "program-001",
            ]
            .as_slice(),
            ["octon", "steward", "epochs", "--program-id", "program-001"].as_slice(),
            [
                "octon",
                "steward",
                "decisions",
                "--program-id",
                "program-001",
            ]
            .as_slice(),
        ];

        for args in cases {
            let cli = Cli::try_parse_from(args).expect("steward lifecycle command should parse");
            assert!(matches!(cli.cmd, Command::Steward { .. }));
        }
    }

    #[test]
    fn cli_parses_steward_admission_and_renewal_options() {
        let admit = Cli::try_parse_from([
            "octon",
            "steward",
            "admit",
            "--program-id",
            "program-001",
            "--trigger-id",
            "trigger-001",
            "--engagement-id",
            "engagement-001",
            "--campaign-candidate",
        ])
        .expect("steward admit command should parse");
        match admit.cmd {
            Command::Steward {
                cmd: StewardCmd::Admit(args),
            } => {
                assert_eq!(args.program_id, "program-001");
                assert_eq!(args.trigger_id.as_deref(), Some("trigger-001"));
                assert_eq!(args.engagement_id.as_deref(), Some("engagement-001"));
                assert!(args.campaign_candidate);
            }
            _ => panic!("parsed command should be steward admit"),
        }

        let renew = Cli::try_parse_from([
            "octon",
            "steward",
            "renew",
            "--program-id",
            "program-001",
            "--outcome",
            "idle-until-next-trigger",
        ])
        .expect("steward renew command should parse");
        match renew.cmd {
            Command::Steward {
                cmd: StewardCmd::Renew(args),
            } => {
                assert_eq!(args.program_id, "program-001");
                assert_eq!(args.outcome, StewardRenewalOutcomeArg::IdleUntilNextTrigger);
            }
            _ => panic!("parsed command should be steward renew"),
        }
    }

    #[test]
    fn cli_parses_stewardship_decide_routing_command() {
        let cli = Cli::try_parse_from([
            "octon",
            "decide",
            "resolve",
            "stewardship-gate-blocked-001",
            "--program-id",
            "program-001",
            "--response",
            "approve",
        ])
        .expect("stewardship decide resolve command should parse");

        match cli.cmd {
            Command::Decide {
                cmd:
                    DecideCmd::Resolve(super::DecisionResolveCmd {
                        program_id,
                        decision_id,
                        response,
                        ..
                    }),
            } => {
                assert_eq!(program_id.as_deref(), Some("program-001"));
                assert_eq!(decision_id, "stewardship-gate-blocked-001");
                assert_eq!(response, DecisionResponseArg::Approve);
            }
            _ => panic!("parsed command should be decide resolve"),
        }
    }

    #[test]
    fn cli_arm_help_preserves_run_start_contract_handoff() {
        let mut cmd = Cli::command();
        let arm = cmd
            .find_subcommand_mut("arm")
            .expect("arm subcommand should exist");
        let mut help = Vec::new();
        arm.write_long_help(&mut help)
            .expect("arm help should render");
        let help = String::from_utf8(help).expect("help should be valid utf-8");

        assert!(
            help.contains("--prepare-only"),
            "arm help should expose prepare-only posture"
        );
        assert!(
            help.contains("octon run start --contract"),
            "arm help should preserve the run-start contract handoff"
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

    #[test]
    fn cli_parses_evolve_inspect_subcommand() {
        let cli = Cli::try_parse_from([
            "octon",
            "evolve",
            "inspect",
            "evolution-candidate-v5-validation",
        ])
        .expect("evolve inspect should parse");

        match cli.cmd {
            Command::Evolve {
                cmd: EvolveCmd::Inspect(args),
            } => assert_eq!(args.candidate, "evolution-candidate-v5-validation"),
            _ => panic!("parsed command should be evolve inspect"),
        }
    }

    #[test]
    fn cli_parses_amend_request_subcommand() {
        let cli = Cli::try_parse_from([
            "octon",
            "amend",
            "request",
            "evolution-candidate-v5-validation",
        ])
        .expect("amend request should parse");

        match cli.cmd {
            Command::Amend {
                cmd: AmendCmd::Request(args),
            } => assert_eq!(args.candidate, "evolution-candidate-v5-validation"),
            _ => panic!("parsed command should be amend request"),
        }
    }

    #[test]
    fn cli_parses_promote_inspect_subcommand() {
        let cli = Cli::try_parse_from([
            "octon",
            "promote",
            "inspect",
            "--promotion-id",
            "evolution-promotion-v5-validation",
        ])
        .expect("promote inspect should parse");

        match cli.cmd {
            Command::Promote {
                cmd: PromoteCmd::Inspect(args),
            } => assert_eq!(args.promotion_id, "evolution-promotion-v5-validation"),
            _ => panic!("parsed command should be promote inspect"),
        }
    }

    #[test]
    fn cli_parses_recertify_status_subcommand() {
        let cli = Cli::try_parse_from(["octon", "recertify", "status"])
            .expect("recertify status should parse");

        match cli.cmd {
            Command::Recertify {
                cmd: RecertifyCmd::Status(args),
            } => assert_eq!(args.program_id, "octon-self-evolution"),
            _ => panic!("parsed command should be recertify status"),
        }
    }
}
