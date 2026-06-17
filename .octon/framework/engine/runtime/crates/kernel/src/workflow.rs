use anyhow::{bail, ensure, Context, Result};
use clap::ValueEnum;
use octon_core::config::{ConfigLoader, RuntimeConfig};
use octon_core::policy::PolicyEngine;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::collections::{BTreeMap, BTreeSet};
use std::ffi::OsStr;
use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use time::format_description;
use walkdir::WalkDir;

use crate::request;
use octon_authority_engine::{
    authorize_execution, authorized_effect_reference, build_executor_command,
    default_autonomy_context, finalize_execution, issue_evidence_mutation_effect,
    issue_execution_artifact_effects, issue_repo_mutation_effect_with_mode,
    now_rfc3339 as auth_now_rfc3339, resolve_executor_profile, verify_authorized_effect,
    write_execution_start, AuthorizedEffect, AuthorizedEffectReference, EvidenceMutation,
    ExecutionArtifactEffects, ExecutionArtifactPaths, ExecutionOutcome, ExecutionRequest,
    ExecutorCommandSpec, GrantBundle, ManagedExecutorKind, RepoMutation, ReviewRequirements,
    ScopeConstraints, SideEffectFlags, SideEffectSummary,
};

const WORKFLOW_ID: &str = "audit-design-proposal";
const WORKFLOW_ROOT_REL: &str =
    ".octon/framework/orchestration/runtime/workflows/audit/audit-design-proposal";
const REPORTS_ROOT_REL: &str = ".octon/state/evidence/validation/analysis";
const WORKFLOW_REPORTS_ROOT_REL: &str = ".octon/state/evidence/runs/workflows";
const STANDARD_DESIGN_PACKAGE_VALIDATOR_REL: &str =
    ".octon/framework/assurance/runtime/_ops/scripts/validate-design-proposal.sh";
const DESIGN_PACKAGE_TEMPLATE_ROOT_REL: &str = ".octon/framework/scaffolding/runtime/templates";
const PROPOSALS_ROOT_REL: &str = ".octon/inputs/exploratory/proposals";
const DESIGN_PACKAGES_ROOT_REL: &str = ".octon/inputs/exploratory/proposals/design";
const PROPOSAL_REGISTRY_GENERATOR_REL: &str =
    ".octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh";
const PROPOSAL_REVIEW_GATE_VALIDATOR_REL: &str =
    ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh";

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ProposalScope {
    OctonInternal,
    RepoLocal,
}

impl ProposalScope {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::OctonInternal => "octon-internal",
            Self::RepoLocal => "repo-local",
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum StaticProposalKind {
    Migration,
    Policy,
    Architecture,
}

impl StaticProposalKind {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Migration => "migration",
            Self::Policy => "policy",
            Self::Architecture => "architecture",
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum DesignPackageClass {
    DomainRuntime,
    ExperienceProduct,
}

impl DesignPackageClass {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::DomainRuntime => "domain-runtime",
            Self::ExperienceProduct => "experience-product",
        }
    }

    fn template_name(self) -> &'static str {
        match self {
            Self::DomainRuntime => "proposal-design-domain-runtime",
            Self::ExperienceProduct => "proposal-design-experience-product",
        }
    }

    fn default_include_contracts(self) -> bool {
        matches!(self, Self::DomainRuntime)
    }

    fn default_include_conformance(self) -> bool {
        matches!(self, Self::DomainRuntime)
    }

    fn default_include_canonicalization(self) -> bool {
        matches!(self, Self::DomainRuntime)
    }
}

#[derive(Clone, Debug)]
pub struct RunCreateDesignPackageOptions {
    pub run_id: Option<String>,
    pub mission_id: Option<String>,
    pub package_id: String,
    pub package_title: String,
    pub package_class: DesignPackageClass,
    pub promotion_scope: ProposalScope,
    pub implementation_targets: Vec<String>,
    pub include_contracts: Option<bool>,
    pub include_conformance: Option<bool>,
    pub include_canonicalization: Option<bool>,
}

#[derive(Clone, Debug)]
pub struct RunCreateDesignPackageResult {
    pub bundle_root: PathBuf,
    pub summary_report: PathBuf,
    pub final_verdict: String,
}

#[derive(Clone, Debug)]
pub struct RunCreateStaticProposalOptions {
    pub run_id: Option<String>,
    pub mission_id: Option<String>,
    pub proposal_id: String,
    pub proposal_title: String,
    pub promotion_scope: ProposalScope,
    pub promotion_targets: Vec<String>,
}

#[derive(Clone, Debug)]
pub struct RunCreateStaticProposalResult {
    pub bundle_root: PathBuf,
    pub summary_report: PathBuf,
    pub final_verdict: String,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, ValueEnum)]
pub enum PipelineMode {
    Rigorous,
    Short,
}

impl PipelineMode {
    fn as_str(self) -> &'static str {
        match self {
            Self::Rigorous => "rigorous",
            Self::Short => "short",
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, ValueEnum)]
pub enum ExecutorKind {
    Auto,
    Codex,
    Claude,
    Mock,
}

impl ExecutorKind {
    pub(crate) fn as_str(self) -> &'static str {
        match self {
            Self::Auto => "auto",
            Self::Codex => "codex",
            Self::Claude => "claude",
            Self::Mock => "mock",
        }
    }
}

#[derive(Clone, Debug)]
enum ResolvedExecutor {
    Codex(PathBuf),
    Claude(PathBuf),
    Mock,
}

#[derive(Clone, Debug)]
pub struct RunDesignPackageOptions {
    pub package_path: PathBuf,
    pub mode: PipelineMode,
    pub executor: ExecutorKind,
    pub executor_bin: Option<PathBuf>,
    pub output_slug: Option<String>,
    pub model: Option<String>,
    pub prepare_only: bool,
}

#[derive(Clone, Debug)]
pub struct RunDesignPackageResult {
    pub bundle_root: PathBuf,
    pub summary_report: PathBuf,
    pub final_verdict: String,
}

#[derive(Clone, Debug)]
pub struct RunAuditStaticProposalOptions {
    pub run_id: Option<String>,
    pub resume_existing: bool,
    pub proposal_path: PathBuf,
}

#[derive(Clone, Debug)]
pub struct RunAuditStaticProposalResult {
    pub bundle_root: PathBuf,
    pub summary_report: PathBuf,
    pub final_verdict: String,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
enum StageClass {
    Evaluative,
    FileWriting,
    Guidance,
}

impl StageClass {
    fn is_file_writing(self) -> bool {
        matches!(self, Self::FileWriting)
    }
}

#[derive(Clone, Copy, Debug)]
struct StageDefinition {
    id: &'static str,
    prompt_file: &'static str,
    report_file: &'static str,
    class: StageClass,
}

const RIGOROUS_STAGES: &[StageDefinition] = &[
    StageDefinition {
        id: "01",
        prompt_file: "02-design-audit.md",
        report_file: "01-design-proposal-audit.md",
        class: StageClass::Evaluative,
    },
    StageDefinition {
        id: "03",
        prompt_file: "04-design-red-PROFILE.md",
        report_file: "03-design-red-PROFILE.md",
        class: StageClass::Evaluative,
    },
    StageDefinition {
        id: "04",
        prompt_file: "05-design-hardening.md",
        report_file: "04-design-hardening.md",
        class: StageClass::FileWriting,
    },
    StageDefinition {
        id: "05",
        prompt_file: "06-design-integration.md",
        report_file: "05-design-integration.md",
        class: StageClass::FileWriting,
    },
    StageDefinition {
        id: "06",
        prompt_file: "07-implementation-simulation.md",
        report_file: "06-implementation-simulation.md",
        class: StageClass::Evaluative,
    },
    StageDefinition {
        id: "07",
        prompt_file: "08-specification-closure.md",
        report_file: "07-specification-closure.md",
        class: StageClass::FileWriting,
    },
    StageDefinition {
        id: "08",
        prompt_file: "09-extract-blueprint.md",
        report_file: "08-minimal-implementation-architecture-blueprint.md",
        class: StageClass::Guidance,
    },
    StageDefinition {
        id: "09",
        prompt_file: "10-first-implementation-plan.md",
        report_file: "09-first-implementation-plan.md",
        class: StageClass::Guidance,
    },
];

const SHORT_STAGES: &[StageDefinition] = &[
    StageDefinition {
        id: "01",
        prompt_file: "02-design-audit.md",
        report_file: "01-design-proposal-audit.md",
        class: StageClass::Evaluative,
    },
    StageDefinition {
        id: "02",
        prompt_file: "03-design-proposal-remediation.md",
        report_file: "02-design-proposal-remediation.md",
        class: StageClass::FileWriting,
    },
    StageDefinition {
        id: "06",
        prompt_file: "07-implementation-simulation.md",
        report_file: "06-implementation-simulation.md",
        class: StageClass::Evaluative,
    },
    StageDefinition {
        id: "07",
        prompt_file: "08-specification-closure.md",
        report_file: "07-specification-closure.md",
        class: StageClass::FileWriting,
    },
    StageDefinition {
        id: "08",
        prompt_file: "09-extract-blueprint.md",
        report_file: "08-minimal-implementation-architecture-blueprint.md",
        class: StageClass::Guidance,
    },
    StageDefinition {
        id: "09",
        prompt_file: "10-first-implementation-plan.md",
        report_file: "09-first-implementation-plan.md",
        class: StageClass::Guidance,
    },
];

const REPORT_PLACEHOLDERS: &[(&str, &str)] = &[
    ("<AUDIT_REPORT>", "01"),
    ("<RED_TEAM_REPORT>", "03"),
    ("<HARDENING_REPORT>", "04"),
    ("<IMPLEMENTATION_SIMULATION_REPORT>", "06"),
    ("<SPEC_CLOSURE_REPORT>", "07"),
    ("<BLUEPRINT_REPORT>", "08"),
];

#[derive(Clone, Debug, Serialize)]
struct BundleMetadata {
    kind: String,
    id: String,
    workflow_id: String,
    package_path: String,
    mode: String,
    executor: String,
    prepare_only: bool,
    slug: String,
    started_at: String,
    completed_at: String,
    summary: String,
    reports_dir: String,
    stage_inputs_dir: String,
    stage_logs_dir: String,
    selected_stages: Vec<String>,
    report_paths: BTreeMap<String, String>,
    changed_files: BTreeMap<String, Vec<String>>,
    plan: String,
    inventory: String,
    commands: String,
    validation: String,
    summary_report: String,
    final_verdict: String,
    failure_class: Option<String>,
    failed_stage: Option<String>,
}

#[cfg_attr(not(test), allow(dead_code))]
#[derive(Clone, Debug, Default, Deserialize, Serialize)]
struct ProposalRegistry {
    schema_version: String,
    active: Vec<ProposalActiveRegistryEntry>,
    archived: Vec<ProposalArchivedRegistryEntry>,
}

#[cfg_attr(not(test), allow(dead_code))]
#[derive(Clone, Debug, Deserialize, Serialize)]
struct ProposalActiveRegistryEntry {
    id: String,
    kind: String,
    scope: String,
    path: String,
    title: String,
    status: String,
    promotion_targets: Vec<String>,
}

#[cfg_attr(not(test), allow(dead_code))]
#[derive(Clone, Debug, Deserialize, Serialize)]
struct ProposalArchivedRegistryEntry {
    id: String,
    kind: String,
    scope: String,
    path: String,
    title: String,
    status: String,
    disposition: String,
    archived_at: String,
    archived_from_status: String,
    original_path: String,
    promotion_targets: Vec<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct ProposalLifecycle {
    temporary: bool,
    exit_expectation: String,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct ProposalArchiveMetadata {
    archived_at: String,
    archived_from_status: String,
    disposition: String,
    original_path: String,
    promotion_evidence: Vec<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct ProposalManifest {
    schema_version: String,
    proposal_id: String,
    title: String,
    summary: String,
    proposal_kind: String,
    promotion_scope: String,
    promotion_targets: Vec<String>,
    status: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    archive: Option<ProposalArchiveMetadata>,
    lifecycle: ProposalLifecycle,
    related_proposals: Vec<String>,
    #[serde(flatten)]
    extra: BTreeMap<String, serde_yaml::Value>,
}

#[derive(Clone, Debug)]
pub struct RunValidateProposalOptions {
    pub run_id: Option<String>,
    pub resume_existing: bool,
    pub proposal_path: PathBuf,
}

#[derive(Clone, Debug)]
pub struct RunPromoteProposalOptions {
    pub run_id: Option<String>,
    pub resume_existing: bool,
    pub proposal_path: PathBuf,
    pub promotion_evidence: Vec<String>,
}

#[derive(Clone, Debug)]
pub struct RunArchiveProposalOptions {
    pub run_id: Option<String>,
    pub resume_existing: bool,
    pub proposal_path: PathBuf,
    pub disposition: String,
    pub promotion_evidence: Vec<String>,
}

#[derive(Clone, Debug)]
pub struct RunProposalPacketTerminalCloseoutOptions {
    pub run_id: Option<String>,
    pub resume_existing: bool,
    pub proposal_path: PathBuf,
    pub target_outcome: String,
    pub profile_path: Option<PathBuf>,
    pub terminal_run_id: Option<String>,
}

#[derive(Clone, Debug)]
pub struct RunFixtureRetentionCloseoutOptions {
    pub run_id: Option<String>,
    pub resume_existing: bool,
    pub fixture_path: PathBuf,
    pub purpose: String,
    pub owner_scope: String,
    pub evidence_refs: Vec<String>,
}

#[derive(Clone, Debug)]
pub struct RunProposalOperationResult {
    pub bundle_root: PathBuf,
    pub summary_report: PathBuf,
    pub final_verdict: String,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
enum FailureClass {
    ExecutorEnvironment,
    PromptPacket,
    StageValidation,
    PackageMutation,
    StandardValidator,
}

impl FailureClass {
    fn as_str(self) -> &'static str {
        match self {
            Self::ExecutorEnvironment => "executor-environment-failure",
            Self::PromptPacket => "prompt-packet-failure",
            Self::StageValidation => "stage-validation-failure",
            Self::PackageMutation => "package-mutation-failure",
            Self::StandardValidator => "standard-validator-failure",
        }
    }
}

#[derive(Clone, Debug)]
struct RunFailure {
    class: FailureClass,
    failed_stage: Option<String>,
    message: String,
}

impl RunFailure {
    fn new(class: FailureClass, failed_stage: Option<&str>, message: impl Into<String>) -> Self {
        Self {
            class,
            failed_stage: failed_stage.map(str::to_string),
            message: message.into(),
        }
    }
}

impl std::fmt::Display for RunFailure {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        if let Some(stage) = &self.failed_stage {
            write!(
                f,
                "{} at stage {}: {}",
                self.class.as_str(),
                stage,
                self.message
            )
        } else {
            write!(f, "{}: {}", self.class.as_str(), self.message)
        }
    }
}

#[derive(Clone, Debug, Serialize)]
struct CreateDesignPackageBundleMetadata {
    kind: String,
    id: String,
    workflow_id: String,
    package_id: String,
    package_class: String,
    started_at: String,
    completed_at: String,
    summary: String,
    commands: String,
    validation: String,
    inventory: String,
    reports_dir: String,
    stage_inputs_dir: String,
    stage_logs_dir: String,
    summary_report: String,
    final_verdict: String,
    failure_class: Option<String>,
    failed_stage: Option<String>,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
enum CreateDesignPackageFailureClass {
    RequestValidation,
    Scaffold,
    RegistryUpdate,
    StandardValidator,
}

impl CreateDesignPackageFailureClass {
    fn as_str(self) -> &'static str {
        match self {
            Self::RequestValidation => "request-validation-failure",
            Self::Scaffold => "scaffold-failure",
            Self::RegistryUpdate => "registry-update-failure",
            Self::StandardValidator => "standard-validator-failure",
        }
    }
}

#[derive(Clone, Debug)]
struct CreateDesignPackageFailure {
    class: CreateDesignPackageFailureClass,
    failed_stage: &'static str,
    message: String,
}

#[derive(Clone, Debug)]
struct Runner {
    repo_root: PathBuf,
    runtime_cfg: RuntimeConfig,
    target_package: PathBuf,
    workflow_root: PathBuf,
    options: RunDesignPackageOptions,
    bundle_root: PathBuf,
    reports_dir: PathBuf,
    stage_inputs_dir: PathBuf,
    stage_logs_dir: PathBuf,
    summary_report: PathBuf,
    started_at: String,
    slug: String,
    stages: &'static [StageDefinition],
}

#[derive(Clone, Debug)]
struct FileFingerprint {
    sha256: String,
}

#[derive(Clone, Debug)]
struct FileChange {
    kind: &'static str,
    path: String,
}

#[derive(Clone, Debug, Default)]
struct StageOutcome {
    changed_files: Vec<FileChange>,
}

struct StageExecutionResult {
    executor_used: String,
    blocked_flags: Vec<String>,
}

struct AuthorizedWorkflowStage {
    request: ExecutionRequest,
    grant: GrantBundle,
    effects: ExecutionArtifactEffects,
    artifacts: ExecutionArtifactPaths,
    started_at: String,
}

fn artifact_effects_for_root(root: &Path, grant: &GrantBundle) -> Result<ExecutionArtifactEffects> {
    Ok(issue_execution_artifact_effects(
        root,
        grant,
        root.display().to_string(),
    )?)
}

fn write_file_with_verified_evidence_effect(
    runtime_path: &Path,
    grant: &GrantBundle,
    effect: &AuthorizedEffect<EvidenceMutation>,
    path: &Path,
    contents: impl AsRef<[u8]>,
    consumer_api_ref: &str,
    authorized_effects: &mut Vec<AuthorizedEffectReference>,
) -> Result<()> {
    let verified = verify_authorized_effect(
        runtime_path,
        grant,
        effect,
        consumer_api_ref,
        path.display().to_string(),
    )?;
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent).with_context(|| format!("create {}", parent.display()))?;
    }
    fs::write(path, contents).with_context(|| format!("write {}", path.display()))?;
    authorized_effects.push(authorized_effect_reference(&verified));
    Ok(())
}

fn create_dir_with_verified_repo_effect(
    runtime_path: &Path,
    grant: &GrantBundle,
    effect: &AuthorizedEffect<RepoMutation>,
    path: &Path,
    consumer_api_ref: &str,
    authorized_effects: &mut Vec<AuthorizedEffectReference>,
) -> Result<()> {
    let verified = verify_authorized_effect(
        runtime_path,
        grant,
        effect,
        consumer_api_ref,
        path.display().to_string(),
    )?;
    fs::create_dir_all(path).with_context(|| format!("create {}", path.display()))?;
    authorized_effects.push(authorized_effect_reference(&verified));
    Ok(())
}

fn write_file_with_verified_repo_effect(
    runtime_path: &Path,
    grant: &GrantBundle,
    effect: &AuthorizedEffect<RepoMutation>,
    path: &Path,
    contents: impl AsRef<[u8]>,
    consumer_api_ref: &str,
    authorized_effects: &mut Vec<AuthorizedEffectReference>,
) -> Result<()> {
    let verified = verify_authorized_effect(
        runtime_path,
        grant,
        effect,
        consumer_api_ref,
        path.display().to_string(),
    )?;
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent).with_context(|| format!("create {}", parent.display()))?;
    }
    fs::write(path, contents).with_context(|| format!("write {}", path.display()))?;
    authorized_effects.push(authorized_effect_reference(&verified));
    Ok(())
}

fn authorize_workflow_stage(
    runtime_cfg: &RuntimeConfig,
    policy: &PolicyEngine,
    bundle_root: &Path,
    workflow_id: &str,
    parent_workflow_request_id: &str,
    stage_id: &str,
    action_type: &str,
    target_id: &str,
    requested_capabilities: Vec<String>,
    write_scope: Vec<String>,
    shell: bool,
    write_repo: bool,
    risk_tier: &str,
    executor_profile: Option<&str>,
    mission_id: Option<&str>,
    support_tier_override: Option<&str>,
) -> Result<AuthorizedWorkflowStage> {
    let workflow_mode = request::workflow_mode(mission_id);
    let stage_autonomy_context = mission_id
        .map(|mission_id| {
            default_autonomy_context(
                runtime_cfg,
                mission_id,
                stage_id,
                &format!("workflow-stage:{stage_id}"),
                if write_repo {
                    "feedback_window"
                } else {
                    "notify"
                },
                "continuous",
                "reversible",
            )
        })
        .transpose()?;
    let mut metadata = BTreeMap::from([
        ("workflow_id".to_string(), workflow_id.to_string()),
        ("stage_id".to_string(), stage_id.to_string()),
    ]);
    if let Some(support_tier) = support_tier_override {
        metadata.insert("support_tier".to_string(), support_tier.to_string());
    }
    let (intent_ref, execution_role_ref, metadata) =
        request::bind_repo_local_request(runtime_cfg, metadata)?;
    let request = ExecutionRequest {
        request_id: workflow_stage_request_id(parent_workflow_request_id, stage_id),
        caller_path: "workflow-stage".to_string(),
        action_type: action_type.to_string(),
        target_id: target_id.to_string(),
        requested_capabilities,
        side_effect_flags: SideEffectFlags {
            write_repo,
            write_evidence: true,
            shell,
            network: false,
            model_invoke: false,
            state_mutation: false,
            publication: false,
            branch_mutation: false,
        },
        risk_tier: risk_tier.to_string(),
        workflow_mode,
        locality_scope: None,
        intent_ref: Some(intent_ref),
        autonomy_context: stage_autonomy_context,
        execution_role_ref: Some(execution_role_ref),
        parent_run_ref: Some(parent_workflow_request_id.to_string()),
        review_requirements: ReviewRequirements::default(),
        scope_constraints: ScopeConstraints {
            read: vec!["workflow-scope".to_string()],
            write: write_scope,
            executor_profile: executor_profile.map(ToOwned::to_owned),
            locality_scope: None,
        },
        policy_mode_requested: None,
        environment_hint: None,
        metadata,
        ..ExecutionRequest::default()
    };
    let grant = authorize_execution(runtime_cfg, policy, &request, None)?;
    let artifact_root = bundle_root.join("stages").join(stage_id);
    let effects = artifact_effects_for_root(&artifact_root, &grant)?;
    let artifacts = write_execution_start(&artifact_root, &request, &grant, &effects)?;
    let started_at = auth_now_rfc3339()?;
    Ok(AuthorizedWorkflowStage {
        request,
        grant,
        effects,
        artifacts,
        started_at,
    })
}

fn finalize_workflow_stage(
    stage: &AuthorizedWorkflowStage,
    status: &str,
    error: Option<String>,
    touched_scope: Vec<String>,
) -> Result<()> {
    finalize_execution(
        &stage.artifacts,
        &stage.request,
        &stage.grant,
        &stage.effects,
        &stage.started_at,
        &ExecutionOutcome {
            status: status.to_string(),
            started_at: stage.started_at.clone(),
            completed_at: auth_now_rfc3339()?,
            error,
        },
        &SideEffectSummary {
            touched_scope,
            executor_profile: stage.grant.scope_constraints.executor_profile.clone(),
            ..SideEffectSummary::default()
        },
    )
}

fn finalize_workflow_failure(
    artifacts: &ExecutionArtifactPaths,
    request: &ExecutionRequest,
    grant: &GrantBundle,
    started_at: &str,
    error: String,
    touched_scope: Vec<String>,
) -> Result<()> {
    let effects = artifact_effects_for_root(&artifacts.root, grant)?;
    finalize_execution(
        artifacts,
        request,
        grant,
        &effects,
        started_at,
        &ExecutionOutcome {
            status: "failed".to_string(),
            started_at: started_at.to_string(),
            completed_at: auth_now_rfc3339()?,
            error: Some(error),
        },
        &SideEffectSummary {
            touched_scope,
            ..SideEffectSummary::default()
        },
    )
}

pub fn run_design_package_from_octon_dir(
    octon_dir: &Path,
    options: RunDesignPackageOptions,
) -> Result<RunDesignPackageResult> {
    let runner = Runner::new(octon_dir, options)?;
    runner.run()
}

pub fn run_create_design_package_from_octon_dir(
    octon_dir: &Path,
    options: RunCreateDesignPackageOptions,
) -> Result<RunCreateDesignPackageResult> {
    let runtime_cfg = ConfigLoader::load(octon_dir)?;
    let policy = PolicyEngine::new(runtime_cfg.clone());
    let repo_root = octon_dir
        .parent()
        .context("failed to resolve repository root from .octon directory")?
        .canonicalize()
        .context("failed to canonicalize repository root")?;

    let design_proposals_root = repo_root.join(DESIGN_PACKAGES_ROOT_REL);
    let reports_root = repo_root.join(REPORTS_ROOT_REL);
    let workflow_bundles_root = repo_root.join(WORKFLOW_REPORTS_ROOT_REL);
    let workflow_request_id = resolve_requested_workflow_run_id(
        &runtime_cfg,
        options.run_id.as_deref(),
        "create-design-proposal",
        false,
    )?;
    let workflow_mode = request::workflow_mode(options.mission_id.as_deref());
    let workflow_autonomy_context = options
        .mission_id
        .as_deref()
        .map(|mission_id| {
            default_autonomy_context(
                &runtime_cfg,
                mission_id,
                "create-design-proposal",
                "workflow",
                "feedback_window",
                "continuous",
                "reversible",
            )
        })
        .transpose()?;
    let (intent_ref, execution_role_ref, metadata) = request::bind_repo_local_request(
        &runtime_cfg,
        BTreeMap::from([(
            "workflow_id".to_string(),
            "create-design-proposal".to_string(),
        )]),
    )?;
    let workflow_request = ExecutionRequest {
        request_id: workflow_request_id.clone(),
        caller_path: "workflow".to_string(),
        action_type: "execute_workflow".to_string(),
        target_id: "create-design-proposal".to_string(),
        requested_capabilities: vec![
            "workflow.execute".to_string(),
            "repo.write".to_string(),
            "evidence.write".to_string(),
        ],
        side_effect_flags: SideEffectFlags {
            write_repo: true,
            write_evidence: true,
            ..SideEffectFlags::default()
        },
        risk_tier: "medium".to_string(),
        workflow_mode,
        locality_scope: None,
        intent_ref: Some(intent_ref),
        autonomy_context: workflow_autonomy_context.clone(),
        execution_role_ref: Some(execution_role_ref),
        parent_run_ref: None,
        review_requirements: ReviewRequirements::default(),
        scope_constraints: ScopeConstraints {
            read: vec!["workflow-scope".to_string()],
            write: vec![
                design_proposals_root.display().to_string(),
                reports_root.display().to_string(),
                workflow_bundles_root.display().to_string(),
            ],
            executor_profile: None,
            locality_scope: None,
        },
        policy_mode_requested: None,
        environment_hint: None,
        metadata,
        ..ExecutionRequest::default()
    };
    let workflow_auth = authorize_execution(&runtime_cfg, &policy, &workflow_request, None)?;
    fs::create_dir_all(&design_proposals_root)
        .with_context(|| format!("create {}", design_proposals_root.display()))?;
    fs::create_dir_all(&reports_root)
        .with_context(|| format!("create {}", reports_root.display()))?;
    fs::create_dir_all(&workflow_bundles_root)
        .with_context(|| format!("create {}", workflow_bundles_root.display()))?;

    let date = today_string()?;
    let started_at = now_rfc3339()?;
    let bundle_root = unique_directory(
        &workflow_bundles_root,
        &format!(
            "{date}-{}",
            slugify(&format!("create-design-proposal-{}", options.package_id))
        ),
    )?;
    fs::create_dir_all(bundle_root.join("reports"))?;
    fs::create_dir_all(bundle_root.join("stage-inputs"))?;
    fs::create_dir_all(bundle_root.join("stage-logs"))?;
    let workflow_artifact_root = bundle_root.join("workflow-execution");
    let workflow_effects = artifact_effects_for_root(&workflow_artifact_root, &workflow_auth)?;
    let workflow_artifacts = write_execution_start(
        &workflow_artifact_root,
        &workflow_request,
        &workflow_auth,
        &workflow_effects,
    )?;
    let summary_report = unique_file(
        &reports_root,
        &format!("{date}-create-design-proposal"),
        "md",
    )?;

    let proposal_root = design_proposals_root.join(&options.package_id);
    let proposal_rel = rel_path(&repo_root, &proposal_root);

    let include_contracts = options
        .include_contracts
        .unwrap_or(options.package_class.default_include_contracts());
    let include_conformance = options
        .include_conformance
        .unwrap_or(options.package_class.default_include_conformance());
    let include_canonicalization = options
        .include_canonicalization
        .unwrap_or(options.package_class.default_include_canonicalization());

    let selected_modules = build_selected_modules(
        include_contracts,
        include_conformance,
        include_canonicalization,
    );
    let package_summary = format!(
        "Temporary implementation-scoped design package for {}.",
        options.package_title.trim()
    );
    let exit_expectation = format!(
        "Promote durable outputs into {} and remove this package after implementation lands.",
        options.implementation_targets.join(", ")
    );
    let conformance_validator_path = if include_conformance {
        format!("{proposal_rel}/conformance/validate_scenarios.py")
    } else {
        "null".to_string()
    };

    let replacements = build_design_package_replacements(
        &options,
        &package_summary,
        &exit_expectation,
        &proposal_rel,
        &selected_modules,
        &conformance_validator_path,
    );

    let mut command_log = Vec::new();
    let mut notes = Vec::new();
    let mut validator_log: Option<PathBuf> = None;
    let mut failure: Option<CreateDesignPackageFailure> = None;
    let mut registry_synced = false;

    let stage01_input = write_create_stage_input(
        &bundle_root,
        "01",
        "validate-request",
        &format!(
            "# Validate Request\n\n- proposal_id: `{}`\n- proposal_title: `{}`\n- proposal_class: `{}`\n- promotion_scope: `{}`\n- promotion_targets: `{}`\n",
            options.package_id,
            options.package_title.trim(),
            options.package_class.as_str(),
            options.promotion_scope.as_str(),
            options.implementation_targets.join(", ")
        ),
    )?;

    if let Err(error) = validate_design_package_id(&options.package_id) {
        failure = Some(CreateDesignPackageFailure {
            class: CreateDesignPackageFailureClass::RequestValidation,
            failed_stage: "validate-request",
            message: error.to_string(),
        });
    } else if options.package_title.trim().is_empty() {
        failure = Some(CreateDesignPackageFailure {
            class: CreateDesignPackageFailureClass::RequestValidation,
            failed_stage: "validate-request",
            message: "package_title must not be empty".to_string(),
        });
    } else if options.implementation_targets.is_empty() {
        failure = Some(CreateDesignPackageFailure {
            class: CreateDesignPackageFailureClass::RequestValidation,
            failed_stage: "validate-request",
            message: "implementation_targets must contain at least one target path".to_string(),
        });
    } else if proposal_root.exists() {
        failure = Some(CreateDesignPackageFailure {
            class: CreateDesignPackageFailureClass::RequestValidation,
            failed_stage: "validate-request",
            message: format!(
                "target design proposal already exists: {}",
                proposal_root.display()
            ),
        });
    }

    write_create_stage_log(
        &bundle_root,
        "01",
        "validate-request",
        if failure.is_some() {
            "failed"
        } else {
            "passed"
        },
        &format!("- proposal_root: `{}`\n", proposal_root.display()),
    )?;
    command_log.push(format!(
        "- stage validate-request | status={} | input={} | proposal_root={}",
        if failure.is_some() {
            "failed"
        } else {
            "passed"
        },
        rel_path(&repo_root, &stage01_input),
        proposal_root.display()
    ));

    if failure.is_none() {
        let stage02_input = write_create_stage_input(
            &bundle_root,
            "02",
            "select-bundles",
            &format!(
                "# Select Bundles\n\n- proposal_class: `{}`\n- include_contracts: `{}`\n- include_conformance: `{}`\n- include_canonicalization: `{}`\n- selected_modules: `{}`\n",
                options.package_class.as_str(),
                include_contracts,
                include_conformance,
                include_canonicalization,
                selected_modules.join(", ")
            ),
        )?;
        write_create_stage_log(
            &bundle_root,
            "02",
            "select-bundles",
            "passed",
            &format!("- selected_modules: `{}`\n", selected_modules.join(", ")),
        )?;
        command_log.push(format!(
            "- stage select-bundles | status=passed | input={} | selected_modules={}",
            rel_path(&repo_root, &stage02_input),
            selected_modules.join(", ")
        ));
    }

    if failure.is_none() {
        let template_root = repo_root.join(DESIGN_PACKAGE_TEMPLATE_ROOT_REL);
        let stage03_input = write_create_stage_input(
            &bundle_root,
            "03",
            "scaffold-package",
            &format!(
                "# Scaffold Proposal\n\n- proposal_root: `{}`\n- proposal_rel: `{}`\n- selected_modules: `{}`\n",
                proposal_root.display(),
                proposal_rel,
                selected_modules.join(", ")
            ),
        )?;
        let stage03_auth = authorize_workflow_stage(
            &runtime_cfg,
            &policy,
            &bundle_root,
            "create-design-proposal",
            &workflow_request.request_id,
            "03-scaffold-proposal",
            "execute_stage",
            "create-design-proposal::scaffold-proposal",
            vec![
                "workflow.stage.execute".to_string(),
                "repo.write".to_string(),
                "evidence.write".to_string(),
            ],
            vec![
                proposal_root.display().to_string(),
                bundle_root
                    .join("stages/03-scaffold-proposal")
                    .display()
                    .to_string(),
            ],
            false,
            true,
            "medium",
            Some("scoped_repo_mutation"),
            options.mission_id.as_deref(),
            None,
        )?;
        let scaffold_result: Result<()> = (|| {
            fs::create_dir_all(&proposal_root)
                .with_context(|| format!("create {}", proposal_root.display()))?;
            apply_template_bundle(
                &template_root.join("proposal-core"),
                &proposal_root,
                &replacements,
            )?;
            apply_template_bundle(
                &template_root.join("proposal-design-core"),
                &proposal_root,
                &replacements,
            )?;
            apply_template_bundle(
                &template_root.join(options.package_class.template_name()),
                &proposal_root,
                &replacements,
            )?;
            if include_contracts {
                apply_template_bundle(
                    &template_root.join("proposal-design-contracts"),
                    &proposal_root,
                    &replacements,
                )?;
            }
            if include_conformance {
                apply_template_bundle(
                    &template_root.join("proposal-design-conformance"),
                    &proposal_root,
                    &replacements,
                )?;
            }
            if include_canonicalization {
                apply_template_bundle(
                    &template_root.join("proposal-design-canonicalization"),
                    &proposal_root,
                    &replacements,
                )?;
            }
            fs::write(
                proposal_root.join("proposal.yml"),
                build_proposal_manifest(&options, &package_summary, &exit_expectation),
            )
            .with_context(|| format!("write {}", proposal_root.join("proposal.yml").display()))?;
            fs::write(
                proposal_root.join("design-proposal.yml"),
                build_design_proposal_manifest(
                    &options,
                    &selected_modules,
                    if include_conformance {
                        Some(conformance_validator_path.as_str())
                    } else {
                        None
                    },
                ),
            )
            .with_context(|| {
                format!(
                    "write {}",
                    proposal_root.join("design-proposal.yml").display()
                )
            })?;
            fs::write(
                proposal_root.join("navigation/source-of-truth-map.md"),
                build_source_of_truth_map(&options, &selected_modules),
            )
            .with_context(|| {
                format!(
                    "write {}",
                    proposal_root
                        .join("navigation/source-of-truth-map.md")
                        .display()
                )
            })?;
            fs::write(
                proposal_root.join("navigation/artifact-catalog.md"),
                build_artifact_catalog(
                    &proposal_root,
                    "design",
                    &options.package_id,
                    &proposal_rel,
                )?,
            )
            .with_context(|| {
                format!(
                    "write {}",
                    proposal_root
                        .join("navigation/artifact-catalog.md")
                        .display()
                )
            })?;
            regenerate_proposal_registry(&repo_root, true)?;
            registry_synced = true;
            Ok(())
        })();

        if let Err(error) = scaffold_result {
            let _ = finalize_workflow_stage(
                &stage03_auth,
                "failed",
                Some(error.to_string()),
                vec![proposal_root.display().to_string()],
            );
            let class = if error
                .to_string()
                .contains(".octon/generated/proposals/registry.yml")
            {
                CreateDesignPackageFailureClass::RegistryUpdate
            } else {
                CreateDesignPackageFailureClass::Scaffold
            };
            failure = Some(CreateDesignPackageFailure {
                class,
                failed_stage: "scaffold-package",
                message: error.to_string(),
            });
        } else {
            finalize_workflow_stage(
                &stage03_auth,
                "succeeded",
                None,
                vec![proposal_root.display().to_string()],
            )?;
        }
        write_create_stage_log(
            &bundle_root,
            "03",
            "scaffold-proposal",
            if failure.is_some() {
                "failed"
            } else {
                "passed"
            },
            &format!(
                "- proposal_root: `{}`\n- registry_synced: `{}`\n",
                proposal_root.display(),
                registry_synced
            ),
        )?;
        command_log.push(format!(
            "- stage scaffold-proposal | status={} | input={} | proposal_root={}",
            if failure.is_some() {
                "failed"
            } else {
                "passed"
            },
            rel_path(&repo_root, &stage03_input),
            proposal_root.display()
        ));
    }

    write_create_inventory(&bundle_root, &proposal_root)?;

    if failure.is_none() {
        let stage04_input = write_create_stage_input(
            &bundle_root,
            "04",
            "validate-package",
            &format!(
                "# Validate Proposal\n\n- proposal_path: `{}`\n- validators:\n  - `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package {}`\n  - `bash .octon/framework/assurance/runtime/_ops/scripts/validate-design-proposal.sh --package {}`\n",
                proposal_root.display(),
                proposal_rel,
                proposal_rel
            ),
        )?;
        let stage04_auth = authorize_workflow_stage(
            &runtime_cfg,
            &policy,
            &bundle_root,
            "create-design-proposal",
            &workflow_request.request_id,
            "04-validate-proposal",
            "execute_stage",
            "create-design-proposal::validate-proposal",
            vec![
                "workflow.stage.execute".to_string(),
                "evidence.write".to_string(),
            ],
            vec![
                bundle_root
                    .join("standard-validator.log")
                    .display()
                    .to_string(),
                bundle_root
                    .join("stages/04-validate-proposal")
                    .display()
                    .to_string(),
            ],
            true,
            false,
            "low",
            Some("read_only_analysis"),
            options.mission_id.as_deref(),
            None,
        )?;
        match run_design_proposal_validator_stack(&repo_root, &proposal_root, &bundle_root) {
            Ok(log_path) => {
                finalize_workflow_stage(
                    &stage04_auth,
                    "succeeded",
                    None,
                    vec![rel_path(&repo_root, &log_path)],
                )?;
                validator_log = Some(log_path.clone());
                write_create_stage_log(
                    &bundle_root,
                    "04",
                    "validate-proposal",
                    "passed",
                    &format!("- validator_log: `{}`\n", rel_path(&repo_root, &log_path)),
                )?;
                command_log.push(format!(
                    "- stage validate-proposal | status=passed | input={} | validator_log={}",
                    rel_path(&repo_root, &stage04_input),
                    rel_path(&repo_root, &log_path)
                ));
            }
            Err(error) => {
                let _ = finalize_workflow_stage(
                    &stage04_auth,
                    "failed",
                    Some(error.to_string()),
                    vec![rel_path(
                        &repo_root,
                        &bundle_root.join("standard-validator.log"),
                    )],
                );
                failure = Some(CreateDesignPackageFailure {
                    class: CreateDesignPackageFailureClass::StandardValidator,
                    failed_stage: "validate-proposal",
                    message: error.to_string(),
                });
                write_create_stage_log(
                    &bundle_root,
                    "04",
                    "validate-proposal",
                    "failed",
                    &format!("- error: `{}`\n", error),
                )?;
                command_log.push(format!(
                    "- stage validate-proposal | status=failed | input={}",
                    rel_path(&repo_root, &stage04_input)
                ));
            }
        }
    }

    let final_verdict = if failure.is_some() {
        "failed"
    } else {
        "scaffolded"
    };
    notes.push(format!("registry_synced: `{}`", registry_synced));
    if final_verdict == "scaffolded" {
        notes.push(
            "package is ready for content authoring, not automatically implementation-ready"
                .to_string(),
        );
    } else if let Some(failure) = &failure {
        notes.push(failure.message.clone());
    }

    let stage05_input = write_create_stage_input(
        &bundle_root,
        "05",
        "report",
        &format!(
            "# Report Outcome\n\n- final_verdict: `{}`\n- bundle_root: `{}`\n",
            final_verdict,
            bundle_root.display()
        ),
    )?;
    write_create_stage_log(
        &bundle_root,
        "05",
        "report",
        if failure.is_some() {
            "partial"
        } else {
            "passed"
        },
        &format!("- summary_report: `{}`\n", summary_report.display()),
    )?;
    command_log.push(format!(
        "- stage report | status={} | input={} | summary_report={}",
        if failure.is_some() {
            "partial"
        } else {
            "passed"
        },
        rel_path(&repo_root, &stage05_input),
        rel_path(&repo_root, &summary_report)
    ));

    write_create_commands_log(&bundle_root, &command_log)?;
    let summary = build_create_design_package_summary(
        &repo_root,
        &proposal_root,
        &bundle_root,
        &summary_report,
        &options,
        &selected_modules,
        validator_log.as_deref(),
        final_verdict,
        failure.as_ref(),
        &notes,
    );
    fs::write(bundle_root.join("summary.md"), &summary)
        .with_context(|| format!("write {}", bundle_root.join("summary.md").display()))?;
    fs::write(&summary_report, summary)
        .with_context(|| format!("write {}", summary_report.display()))?;
    write_create_bundle_metadata(
        &repo_root,
        &bundle_root,
        &summary_report,
        &options,
        final_verdict,
        failure.as_ref(),
        &started_at,
    )?;
    write_create_validation(
        &bundle_root,
        &proposal_root,
        final_verdict,
        failure.as_ref(),
        validator_log.as_deref(),
        registry_synced,
        &notes,
    )?;

    if let Some(failure) = failure {
        let _ = finalize_execution(
            &workflow_artifacts,
            &workflow_request,
            &workflow_auth,
            &workflow_effects,
            &started_at,
            &ExecutionOutcome {
                status: "failed".to_string(),
                started_at: started_at.clone(),
                completed_at: auth_now_rfc3339()?,
                error: Some(failure.message.clone()),
            },
            &SideEffectSummary {
                touched_scope: vec![bundle_root.display().to_string()],
                ..SideEffectSummary::default()
            },
        );
        bail!(
            "{} at stage {}: {}",
            failure.class.as_str(),
            failure.failed_stage,
            failure.message
        );
    }

    finalize_execution(
        &workflow_artifacts,
        &workflow_request,
        &workflow_auth,
        &workflow_effects,
        &started_at,
        &ExecutionOutcome {
            status: "succeeded".to_string(),
            started_at: started_at.clone(),
            completed_at: auth_now_rfc3339()?,
            error: None,
        },
        &SideEffectSummary {
            touched_scope: vec![
                bundle_root.display().to_string(),
                proposal_root.display().to_string(),
            ],
            ..SideEffectSummary::default()
        },
    )?;

    Ok(RunCreateDesignPackageResult {
        bundle_root,
        summary_report,
        final_verdict: final_verdict.to_string(),
    })
}

pub fn run_create_static_proposal_from_octon_dir(
    octon_dir: &Path,
    kind: StaticProposalKind,
    options: RunCreateStaticProposalOptions,
) -> Result<RunCreateStaticProposalResult> {
    let runtime_cfg = ConfigLoader::load(octon_dir)?;
    let policy = PolicyEngine::new(runtime_cfg.clone());
    let repo_root = octon_dir
        .parent()
        .context("failed to resolve repository root from .octon directory")?
        .canonicalize()
        .context("failed to canonicalize repository root")?;

    let proposals_root = repo_root.join(PROPOSALS_ROOT_REL).join(kind.as_str());
    let reports_root = repo_root.join(REPORTS_ROOT_REL);
    let workflow_bundles_root = repo_root.join(WORKFLOW_REPORTS_ROOT_REL);
    let workflow_request_id = resolve_requested_workflow_run_id(
        &runtime_cfg,
        options.run_id.as_deref(),
        &format!("create-{}-proposal", kind.as_str()),
        false,
    )?;
    let workflow_mode = request::workflow_mode(options.mission_id.as_deref());
    let workflow_autonomy_context = options
        .mission_id
        .as_deref()
        .map(|mission_id| {
            default_autonomy_context(
                &runtime_cfg,
                mission_id,
                &format!("create-{}-proposal", kind.as_str()),
                "workflow",
                "feedback_window",
                "continuous",
                "reversible",
            )
        })
        .transpose()?;
    let (intent_ref, execution_role_ref, metadata) = request::bind_repo_local_request(
        &runtime_cfg,
        BTreeMap::from([(
            "workflow_id".to_string(),
            format!("create-{}-proposal", kind.as_str()),
        )]),
    )?;
    let workflow_request = ExecutionRequest {
        request_id: workflow_request_id,
        caller_path: "workflow".to_string(),
        action_type: "execute_workflow".to_string(),
        target_id: format!("create-{}-proposal", kind.as_str()),
        requested_capabilities: vec![
            "workflow.execute".to_string(),
            "repo.write".to_string(),
            "evidence.write".to_string(),
        ],
        side_effect_flags: SideEffectFlags {
            write_repo: true,
            write_evidence: true,
            ..SideEffectFlags::default()
        },
        risk_tier: "medium".to_string(),
        workflow_mode,
        locality_scope: None,
        intent_ref: Some(intent_ref),
        autonomy_context: workflow_autonomy_context.clone(),
        execution_role_ref: Some(execution_role_ref),
        parent_run_ref: None,
        review_requirements: ReviewRequirements::default(),
        scope_constraints: ScopeConstraints {
            read: vec!["workflow-scope".to_string()],
            write: vec![
                proposals_root.display().to_string(),
                reports_root.display().to_string(),
                workflow_bundles_root.display().to_string(),
            ],
            executor_profile: None,
            locality_scope: None,
        },
        policy_mode_requested: None,
        environment_hint: None,
        metadata,
        ..ExecutionRequest::default()
    };
    let workflow_grant = authorize_execution(&runtime_cfg, &policy, &workflow_request, None)?;
    fs::create_dir_all(&proposals_root)?;
    fs::create_dir_all(&reports_root)?;
    fs::create_dir_all(&workflow_bundles_root)?;

    let date = today_string()?;
    let started_at = auth_now_rfc3339()?;
    let bundle_root = unique_directory(
        &workflow_bundles_root,
        &format!(
            "{date}-create-{}-proposal-{}",
            kind.as_str(),
            slugify(&options.proposal_id)
        ),
    )?;
    fs::create_dir_all(bundle_root.join("reports"))?;
    fs::create_dir_all(bundle_root.join("stage-inputs"))?;
    fs::create_dir_all(bundle_root.join("stage-logs"))?;
    let workflow_artifact_root = bundle_root.join("workflow-execution");
    let workflow_effects = artifact_effects_for_root(&workflow_artifact_root, &workflow_grant)?;
    let workflow_artifacts = write_execution_start(
        &workflow_artifact_root,
        &workflow_request,
        &workflow_grant,
        &workflow_effects,
    )?;
    let summary_report = unique_file(
        &reports_root,
        &format!("{date}-create-{}-proposal", kind.as_str()),
        "md",
    )?;

    let proposal_root = proposals_root.join(&options.proposal_id);
    if proposal_root.exists() {
        let message = format!(
            "target proposal already exists: {}",
            proposal_root.display()
        );
        let _ = finalize_workflow_failure(
            &workflow_artifacts,
            &workflow_request,
            &workflow_grant,
            &started_at,
            message.clone(),
            vec![
                bundle_root.display().to_string(),
                proposal_root.display().to_string(),
            ],
        );
        bail!(message);
    }
    if options.proposal_title.trim().is_empty() {
        let message = "proposal_title must not be empty".to_string();
        let _ = finalize_workflow_failure(
            &workflow_artifacts,
            &workflow_request,
            &workflow_grant,
            &started_at,
            message.clone(),
            vec![bundle_root.display().to_string()],
        );
        bail!(message);
    }
    if options.promotion_targets.is_empty() {
        let message = "promotion_targets must contain at least one target path".to_string();
        let _ = finalize_workflow_failure(
            &workflow_artifacts,
            &workflow_request,
            &workflow_grant,
            &started_at,
            message.clone(),
            vec![bundle_root.display().to_string()],
        );
        bail!(message);
    }

    let exit_expectation = format!(
        "Promote durable outputs into {} and remove this proposal after implementation lands.",
        options.promotion_targets.join(", ")
    );
    let replacements = build_static_proposal_replacements(kind, &options, &exit_expectation);
    let template_root = repo_root.join(DESIGN_PACKAGE_TEMPLATE_ROOT_REL);

    let stage_scaffold = match authorize_workflow_stage(
        &runtime_cfg,
        &policy,
        &bundle_root,
        &format!("create-{}-proposal", kind.as_str()),
        &workflow_request.request_id,
        "scaffold-proposal",
        "execute_stage",
        &format!("create-{}-proposal::scaffold-proposal", kind.as_str()),
        vec![
            "workflow.stage.execute".to_string(),
            "repo.write".to_string(),
            "evidence.write".to_string(),
        ],
        vec![
            proposal_root.display().to_string(),
            bundle_root
                .join("stages/scaffold-proposal")
                .display()
                .to_string(),
        ],
        false,
        true,
        "medium",
        Some("scoped_repo_mutation"),
        options.mission_id.as_deref(),
        None,
    ) {
        Ok(stage) => stage,
        Err(error) => {
            let message = error.to_string();
            let _ = finalize_workflow_failure(
                &workflow_artifacts,
                &workflow_request,
                &workflow_grant,
                &started_at,
                message.clone(),
                vec![
                    bundle_root.display().to_string(),
                    proposal_root.display().to_string(),
                ],
            );
            bail!(message);
        }
    };
    let scaffold_result: Result<()> = (|| {
        fs::create_dir_all(&proposal_root)?;
        apply_template_bundle(
            &template_root.join("proposal-core"),
            &proposal_root,
            &replacements,
        )?;
        apply_template_bundle(
            &template_root.join(format!("proposal-{}-core", kind.as_str())),
            &proposal_root,
            &replacements,
        )?;
        let proposal_rel = rel_path(&repo_root, &proposal_root);
        fs::write(
            proposal_root.join("navigation/source-of-truth-map.md"),
            build_static_source_of_truth_map(kind),
        )
        .with_context(|| {
            format!(
                "write {}",
                proposal_root
                    .join("navigation/source-of-truth-map.md")
                    .display()
            )
        })?;
        fs::write(
            proposal_root.join("navigation/artifact-catalog.md"),
            build_artifact_catalog(
                &proposal_root,
                kind.as_str(),
                &options.proposal_id,
                &proposal_rel,
            )?,
        )
        .with_context(|| {
            format!(
                "write {}",
                proposal_root
                    .join("navigation/artifact-catalog.md")
                    .display()
            )
        })?;
        regenerate_proposal_registry(&repo_root, true)?;
        Ok(())
    })();
    if let Err(error) = scaffold_result {
        let _ = finalize_workflow_stage(
            &stage_scaffold,
            "failed",
            Some(error.to_string()),
            vec![proposal_root.display().to_string()],
        );
        let _ = finalize_workflow_failure(
            &workflow_artifacts,
            &workflow_request,
            &workflow_grant,
            &started_at,
            error.to_string(),
            vec![
                bundle_root.display().to_string(),
                proposal_root.display().to_string(),
            ],
        );
        return Err(error);
    }
    finalize_workflow_stage(
        &stage_scaffold,
        "succeeded",
        None,
        vec![proposal_root.display().to_string()],
    )?;

    let stage_validate = match authorize_workflow_stage(
        &runtime_cfg,
        &policy,
        &bundle_root,
        &format!("create-{}-proposal", kind.as_str()),
        &workflow_request.request_id,
        "validate-proposal",
        "execute_stage",
        &format!("create-{}-proposal::validate-proposal", kind.as_str()),
        vec![
            "workflow.stage.execute".to_string(),
            "evidence.write".to_string(),
        ],
        vec![
            bundle_root
                .join("standard-validator.log")
                .display()
                .to_string(),
            bundle_root
                .join("stages/validate-proposal")
                .display()
                .to_string(),
        ],
        true,
        false,
        "low",
        Some("read_only_analysis"),
        options.mission_id.as_deref(),
        None,
    ) {
        Ok(stage) => stage,
        Err(error) => {
            let message = error.to_string();
            let _ = finalize_workflow_failure(
                &workflow_artifacts,
                &workflow_request,
                &workflow_grant,
                &started_at,
                message.clone(),
                vec![
                    bundle_root.display().to_string(),
                    proposal_root.display().to_string(),
                ],
            );
            bail!(message);
        }
    };
    let validator_log =
        match run_static_proposal_validator_stack(&repo_root, &proposal_root, &bundle_root, kind) {
            Ok(log) => log,
            Err(error) => {
                let _ = finalize_workflow_stage(
                    &stage_validate,
                    "failed",
                    Some(error.to_string()),
                    vec![bundle_root
                        .join("standard-validator.log")
                        .display()
                        .to_string()],
                );
                let _ = finalize_workflow_failure(
                    &workflow_artifacts,
                    &workflow_request,
                    &workflow_grant,
                    &started_at,
                    error.to_string(),
                    vec![
                        bundle_root.display().to_string(),
                        proposal_root.display().to_string(),
                    ],
                );
                return Err(error);
            }
        };
    finalize_workflow_stage(
        &stage_validate,
        "succeeded",
        None,
        vec![rel_path(&repo_root, &validator_log)],
    )?;
    write_create_inventory(&bundle_root, &proposal_root)?;
    write_create_commands_log(
        &bundle_root,
        &[format!(
            "- create {} proposal | proposal_root={} | validator_log={}",
            kind.as_str(),
            rel_path(&repo_root, &proposal_root),
            rel_path(&repo_root, &validator_log)
        )],
    )?;
    let summary = build_static_create_summary(
        &repo_root,
        &proposal_root,
        &bundle_root,
        &summary_report,
        kind,
        &options,
        &validator_log,
    );
    fs::write(bundle_root.join("summary.md"), &summary)?;
    fs::write(&summary_report, summary)?;
    write_create_validation(
        &bundle_root,
        &proposal_root,
        "scaffolded",
        None,
        Some(&validator_log),
        true,
        &[format!("kind: `{}`", kind.as_str())],
    )?;
    write_static_create_bundle_metadata(
        &repo_root,
        &bundle_root,
        &summary_report,
        kind,
        &options,
        "scaffolded",
    )?;
    finalize_execution(
        &workflow_artifacts,
        &workflow_request,
        &workflow_grant,
        &workflow_effects,
        &started_at,
        &ExecutionOutcome {
            status: "succeeded".to_string(),
            started_at: started_at.clone(),
            completed_at: auth_now_rfc3339()?,
            error: None,
        },
        &SideEffectSummary {
            touched_scope: vec![
                bundle_root.display().to_string(),
                proposal_root.display().to_string(),
            ],
            ..SideEffectSummary::default()
        },
    )?;

    Ok(RunCreateStaticProposalResult {
        bundle_root,
        summary_report,
        final_verdict: "scaffolded".to_string(),
    })
}

pub fn run_audit_static_proposal_from_octon_dir(
    octon_dir: &Path,
    kind: StaticProposalKind,
    options: RunAuditStaticProposalOptions,
) -> Result<RunAuditStaticProposalResult> {
    let runtime_cfg = ConfigLoader::load(octon_dir)?;
    let policy = PolicyEngine::new(runtime_cfg.clone());
    let repo_root = octon_dir
        .parent()
        .context("failed to resolve repository root from .octon directory")?
        .canonicalize()
        .context("failed to canonicalize repository root")?;
    let proposal_root = if options.proposal_path.is_absolute() {
        options.proposal_path.clone()
    } else {
        repo_root.join(&options.proposal_path)
    };
    let reports_root = repo_root.join(REPORTS_ROOT_REL);
    let workflow_bundles_root = repo_root.join(WORKFLOW_REPORTS_ROOT_REL);
    let workflow_request_id = resolve_requested_workflow_run_id(
        &runtime_cfg,
        options.run_id.as_deref(),
        &format!("audit-{}-proposal", kind.as_str()),
        options.resume_existing,
    )?;
    let (intent_ref, execution_role_ref, metadata) = request::bind_repo_local_request(
        &runtime_cfg,
        BTreeMap::from([
            (
                "workflow_id".to_string(),
                format!("audit-{}-proposal", kind.as_str()),
            ),
            ("support_tier".to_string(), "observe-and-read".to_string()),
        ]),
    )?;
    let workflow_request = ExecutionRequest {
        request_id: workflow_request_id,
        caller_path: "workflow".to_string(),
        action_type: "execute_workflow".to_string(),
        target_id: format!("audit-{}-proposal", kind.as_str()),
        requested_capabilities: vec!["workflow.execute".to_string(), "evidence.write".to_string()],
        side_effect_flags: SideEffectFlags {
            write_repo: false,
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
            read: vec!["workflow-scope".to_string()],
            write: vec![
                reports_root.display().to_string(),
                workflow_bundles_root.display().to_string(),
            ],
            executor_profile: None,
            locality_scope: None,
        },
        policy_mode_requested: None,
        environment_hint: None,
        metadata,
        ..ExecutionRequest::default()
    };
    let workflow_grant = authorize_execution(&runtime_cfg, &policy, &workflow_request, None)?;
    fs::create_dir_all(&reports_root)?;
    fs::create_dir_all(&workflow_bundles_root)?;
    let date = today_string()?;
    let started_at = auth_now_rfc3339()?;
    let bundle_root = unique_directory(
        &workflow_bundles_root,
        &format!(
            "{date}-audit-{}-proposal-{}",
            kind.as_str(),
            slugify(&rel_path(&repo_root, &proposal_root))
        ),
    )?;
    fs::create_dir_all(bundle_root.join("reports"))?;
    fs::create_dir_all(bundle_root.join("stage-inputs"))?;
    fs::create_dir_all(bundle_root.join("stage-logs"))?;
    let workflow_artifact_root = bundle_root.join("workflow-execution");
    let workflow_effects = artifact_effects_for_root(&workflow_artifact_root, &workflow_grant)?;
    let workflow_artifacts = write_execution_start(
        &workflow_artifact_root,
        &workflow_request,
        &workflow_grant,
        &workflow_effects,
    )?;
    let summary_report = unique_file(
        &reports_root,
        &format!("{date}-audit-{}-proposal", kind.as_str()),
        "md",
    )?;

    if !proposal_root.is_dir() {
        let message = format!("target proposal not found: {}", proposal_root.display());
        let _ = finalize_workflow_failure(
            &workflow_artifacts,
            &workflow_request,
            &workflow_grant,
            &started_at,
            message.clone(),
            vec![
                bundle_root.display().to_string(),
                proposal_root.display().to_string(),
            ],
        );
        bail!(message);
    }

    let stage_validate = match authorize_workflow_stage(
        &runtime_cfg,
        &policy,
        &bundle_root,
        &format!("audit-{}-proposal", kind.as_str()),
        &workflow_request.request_id,
        "validate-proposal",
        "execute_stage",
        &format!("audit-{}-proposal::validate-proposal", kind.as_str()),
        vec![
            "workflow.stage.execute".to_string(),
            "evidence.write".to_string(),
        ],
        vec![
            bundle_root
                .join("standard-validator.log")
                .display()
                .to_string(),
            bundle_root
                .join("stages/validate-proposal")
                .display()
                .to_string(),
        ],
        true,
        false,
        "low",
        Some("read_only_analysis"),
        None,
        None,
    ) {
        Ok(stage) => stage,
        Err(error) => {
            let message = error.to_string();
            let _ = finalize_workflow_failure(
                &workflow_artifacts,
                &workflow_request,
                &workflow_grant,
                &started_at,
                message.clone(),
                vec![
                    bundle_root.display().to_string(),
                    proposal_root.display().to_string(),
                ],
            );
            bail!(message);
        }
    };
    let validator_log =
        match run_static_proposal_validator_stack(&repo_root, &proposal_root, &bundle_root, kind) {
            Ok(log) => log,
            Err(error) => {
                let _ = finalize_workflow_stage(
                    &stage_validate,
                    "failed",
                    Some(error.to_string()),
                    vec![bundle_root
                        .join("standard-validator.log")
                        .display()
                        .to_string()],
                );
                let _ = finalize_workflow_failure(
                    &workflow_artifacts,
                    &workflow_request,
                    &workflow_grant,
                    &started_at,
                    error.to_string(),
                    vec![
                        bundle_root.display().to_string(),
                        proposal_root.display().to_string(),
                    ],
                );
                return Err(error);
            }
        };
    finalize_workflow_stage(
        &stage_validate,
        "succeeded",
        None,
        vec![rel_path(&repo_root, &validator_log)],
    )?;
    write_create_inventory(&bundle_root, &proposal_root)?;
    write_create_commands_log(
        &bundle_root,
        &[format!(
            "- audit {} proposal | proposal_root={} | validator_log={}",
            kind.as_str(),
            rel_path(&repo_root, &proposal_root),
            rel_path(&repo_root, &validator_log)
        )],
    )?;
    let summary = format!(
        "# Audit {} Proposal Summary\n\n- workflow_id: `audit-{}-proposal`\n- proposal_path: `{}`\n- final_verdict: `validated`\n- bundle_root: `{}`\n- summary_report: `{}`\n- validator_log: `{}`\n",
        kind.as_str(),
        kind.as_str(),
        rel_path(&repo_root, &proposal_root),
        rel_path(&repo_root, &bundle_root),
        rel_path(&repo_root, &summary_report),
        rel_path(&repo_root, &validator_log)
    );
    fs::write(bundle_root.join("summary.md"), &summary)?;
    fs::write(&summary_report, summary)?;
    write_static_audit_validation(&bundle_root, kind, &validator_log)?;
    write_static_audit_bundle_metadata(
        &repo_root,
        &bundle_root,
        &summary_report,
        kind,
        &proposal_root,
    )?;
    finalize_execution(
        &workflow_artifacts,
        &workflow_request,
        &workflow_grant,
        &workflow_effects,
        &started_at,
        &ExecutionOutcome {
            status: "succeeded".to_string(),
            started_at: started_at.clone(),
            completed_at: auth_now_rfc3339()?,
            error: None,
        },
        &SideEffectSummary {
            touched_scope: vec![
                bundle_root.display().to_string(),
                proposal_root.display().to_string(),
            ],
            ..SideEffectSummary::default()
        },
    )?;

    Ok(RunAuditStaticProposalResult {
        bundle_root,
        summary_report,
        final_verdict: "validated".to_string(),
    })
}

pub fn run_validate_proposal_from_octon_dir(
    octon_dir: &Path,
    options: RunValidateProposalOptions,
) -> Result<RunProposalOperationResult> {
    let runtime_cfg = ConfigLoader::load(octon_dir)?;
    let policy = PolicyEngine::new(runtime_cfg.clone());
    let repo_root = octon_dir
        .parent()
        .context("failed to resolve repository root from .octon directory")?
        .canonicalize()
        .context("failed to canonicalize repository root")?;
    let proposal_root = if options.proposal_path.is_absolute() {
        options.proposal_path.clone()
    } else {
        repo_root.join(&options.proposal_path)
    };
    let proposal_rel = rel_path(&repo_root, &proposal_root);
    let workflow_request_id = resolve_requested_workflow_run_id(
        &runtime_cfg,
        options.run_id.as_deref(),
        "validate-proposal",
        options.resume_existing,
    )?;

    let reports_root = repo_root.join(REPORTS_ROOT_REL);
    let workflow_bundles_root = repo_root.join(WORKFLOW_REPORTS_ROOT_REL);
    let (intent_ref, execution_role_ref, metadata) = request::bind_repo_local_request(
        &runtime_cfg,
        BTreeMap::from([("workflow_id".to_string(), "validate-proposal".to_string())]),
    )?;
    let workflow_request = ExecutionRequest {
        request_id: workflow_request_id.clone(),
        caller_path: "workflow".to_string(),
        action_type: "execute_workflow".to_string(),
        target_id: "validate-proposal".to_string(),
        requested_capabilities: vec!["workflow.execute".to_string(), "evidence.write".to_string()],
        side_effect_flags: SideEffectFlags {
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
            read: vec!["workflow-scope".to_string()],
            write: vec![
                reports_root.display().to_string(),
                workflow_bundles_root.display().to_string(),
            ],
            executor_profile: None,
            locality_scope: None,
        },
        policy_mode_requested: None,
        environment_hint: None,
        metadata,
        ..ExecutionRequest::default()
    };
    let workflow_grant = authorize_execution(&runtime_cfg, &policy, &workflow_request, None)?;
    fs::create_dir_all(&reports_root)?;
    fs::create_dir_all(&workflow_bundles_root)?;
    let date = today_string()?;
    let started_at = auth_now_rfc3339()?;
    let bundle_root = unique_directory(
        &workflow_bundles_root,
        &format!("{date}-validate-proposal-{}", slugify(&proposal_rel)),
    )?;
    fs::create_dir_all(bundle_root.join("reports"))?;
    fs::create_dir_all(bundle_root.join("stage-inputs"))?;
    fs::create_dir_all(bundle_root.join("stage-logs"))?;
    let workflow_artifact_root = bundle_root.join("workflow-execution");
    let workflow_effects = artifact_effects_for_root(&workflow_artifact_root, &workflow_grant)?;
    let workflow_artifacts = write_execution_start(
        &workflow_artifact_root,
        &workflow_request,
        &workflow_grant,
        &workflow_effects,
    )?;
    let summary_report = unique_file(&reports_root, &format!("{date}-validate-proposal"), "md")?;

    if !proposal_root.is_dir() {
        let message = format!("target proposal not found: {}", proposal_root.display());
        let _ = finalize_workflow_failure(
            &workflow_artifacts,
            &workflow_request,
            &workflow_grant,
            &started_at,
            message.clone(),
            vec![
                bundle_root.display().to_string(),
                proposal_root.display().to_string(),
            ],
        );
        bail!(message);
    }

    let manifest = load_proposal_manifest(&proposal_root)?;
    let stage_validate = authorize_workflow_stage(
        &runtime_cfg,
        &policy,
        &bundle_root,
        "validate-proposal",
        &workflow_request.request_id,
        "validate-proposal",
        "execute_stage",
        "validate-proposal::validate-proposal",
        vec![
            "workflow.stage.execute".to_string(),
            "evidence.write".to_string(),
        ],
        vec![
            bundle_root
                .join("standard-validator.log")
                .display()
                .to_string(),
            bundle_root
                .join("stages/validate-proposal")
                .display()
                .to_string(),
        ],
        true,
        false,
        "low",
        Some("read_only_analysis"),
        None,
        None,
    )?;
    let validator_log = match run_proposal_validator_stack(
        &repo_root,
        &proposal_root,
        &bundle_root,
        &manifest.proposal_kind,
    )
    .and_then(|path| {
        run_proposal_review_gate_validator(&repo_root, &proposal_root, &bundle_root, false)?;
        Ok(path)
    }) {
        Ok(path) => path,
        Err(error) => {
            let _ = finalize_workflow_stage(
                &stage_validate,
                "failed",
                Some(error.to_string()),
                vec![bundle_root
                    .join("standard-validator.log")
                    .display()
                    .to_string()],
            );
            let _ = finalize_workflow_failure(
                &workflow_artifacts,
                &workflow_request,
                &workflow_grant,
                &started_at,
                error.to_string(),
                vec![
                    bundle_root.display().to_string(),
                    proposal_root.display().to_string(),
                ],
            );
            return Err(error);
        }
    };
    finalize_workflow_stage(
        &stage_validate,
        "succeeded",
        None,
        vec![rel_path(&repo_root, &validator_log)],
    )?;

    let run_control_root = repo_root
        .join(".octon/state/control/execution/runs")
        .join(&workflow_request.request_id);
    let run_evidence_root = repo_root
        .join(".octon/state/evidence/runs")
        .join(&workflow_request.request_id);
    fs::create_dir_all(run_evidence_root.join("assurance"))?;
    fs::create_dir_all(run_evidence_root.join("measurements"))?;
    fs::create_dir_all(run_evidence_root.join("interventions"))?;
    fs::create_dir_all(run_evidence_root.join("replay"))?;
    let generated_at = auth_now_rfc3339()?;
    for (plane, summary, refs) in [
        (
            "structural",
            "Structural proof confirms the canonical run contract, manifest, and checkpoint topology were emitted for this workflow run.",
            vec![
                rel_path(&repo_root, &run_control_root.join("run-contract.yml")),
                rel_path(&repo_root, &run_control_root.join("run-manifest.yml")),
                rel_path(&repo_root, &run_control_root.join("checkpoints/bound.yml")),
            ],
        ),
        (
            "governance",
            "Governance proof confirms support-target, proposal-registry, and validator governance checks passed for this workflow run.",
            vec![
                ".octon/instance/governance/support-targets.yml".to_string(),
                ".octon/generated/proposals/registry.yml".to_string(),
                rel_path(&repo_root, &validator_log),
            ],
        ),
        (
            "functional",
            "Functional proof confirms the proposal validator stack passed and the workflow emitted a successful bounded validation bundle.",
            vec![
                rel_path(&repo_root, &validator_log),
                rel_path(&repo_root, &run_evidence_root.join("receipts/execution-receipt.json")),
                rel_path(&repo_root, &run_evidence_root.join("retained-run-evidence.yml")),
            ],
        ),
    ] {
        fs::write(
            run_evidence_root.join("assurance").join(format!("{plane}.yml")),
            serde_yaml::to_string(&serde_json::json!({
                "schema_version": "proof-plane-report-v1",
                "plane": plane,
                "subject_kind": "run",
                "subject_ref": rel_path(&repo_root, &run_control_root.join("run-contract.yml")),
                "outcome": "pass",
                "proof_class": "deterministic",
                "summary": summary,
                "evidence_refs": refs,
                "known_limits": [],
                "generated_at": generated_at,
            }))?,
        )?;
    }
    fs::write(
        run_evidence_root.join("measurements").join("summary.yml"),
        serde_yaml::to_string(&serde_json::json!({
            "schema_version": "measurement-summary-v1",
            "subject_kind": "run",
            "subject_ref": rel_path(&repo_root, &run_control_root.join("run-contract.yml")),
            "metrics": [
                {
                    "metric_id": "validator-count",
                    "label": "Proposal validators executed",
                    "value": 3,
                    "unit": "count",
                },
                {
                    "metric_id": "proof-plane-count",
                    "label": "Explicit proof-plane reports emitted by the workflow",
                    "value": 3,
                    "unit": "count",
                },
                {
                    "metric_id": "intervention-count",
                    "label": "Material interventions",
                    "value": 0,
                    "unit": "count",
                }
            ],
            "summary": "Validate-proposal emitted deterministic validator, proof-plane, and canonical run evidence.",
            "recorded_at": generated_at,
        }))?,
    )?;
    fs::write(
        run_evidence_root.join("interventions").join("log.yml"),
        serde_yaml::to_string(&serde_json::json!({
            "schema_version": "intervention-log-v1",
            "subject_kind": "run",
            "subject_ref": rel_path(&repo_root, &run_control_root.join("run-contract.yml")),
            "interventions": [],
            "summary": "No hidden or material human intervention was required for this validate-proposal run.",
            "recorded_at": generated_at,
        }))?,
    )?;
    fs::write(
        run_evidence_root.join("replay").join("manifest.yml"),
        serde_yaml::to_string(&serde_json::json!({
            "schema_version": "run-replay-manifest-v1",
            "run_id": workflow_request.request_id,
            "entrypoint": rel_path(&repo_root, &bundle_root.join("workflow-execution")),
            "replay_payload_class": "git-inline",
            "receipt_refs": [
                rel_path(&repo_root, &run_evidence_root.join("receipts/execution-receipt.json")),
            ],
            "checkpoint_refs": [
                rel_path(&repo_root, &run_evidence_root.join("checkpoints/bound.yml")),
            ],
            "trace_refs": [],
            "external_index_refs": [],
            "reproduction_steps": [
                "Read the canonical run contract and execution receipt.",
                "Review the validator log and proof-plane reports retained under the run evidence root.",
            ],
            "recorded_at": generated_at,
        }))?,
    )?;

    write_create_inventory(&bundle_root, &proposal_root)?;
    write_create_commands_log(
        &bundle_root,
        &[format!(
            "- validate proposal | proposal_path={} | proposal_kind={} | validator_log={}",
            proposal_rel,
            manifest.proposal_kind,
            rel_path(&repo_root, &validator_log)
        )],
    )?;

    let summary = format!(
        "# Validate Proposal Summary\n\n- workflow_id: `validate-proposal`\n- proposal_path: `{}`\n- proposal_kind: `{}`\n- final_verdict: `validated`\n- bundle_root: `{}`\n- summary_report: `{}`\n- validator_log: `{}`\n",
        proposal_rel,
        manifest.proposal_kind,
        rel_path(&repo_root, &bundle_root),
        rel_path(&repo_root, &summary_report),
        rel_path(&repo_root, &validator_log),
    );
    fs::write(bundle_root.join("summary.md"), &summary)?;
    fs::write(&summary_report, summary)?;
    fs::write(
        bundle_root.join("validation.md"),
        format!(
            "# Validation\n\n- final_verdict: `validated`\n- proposal_kind: `{}`\n- validator_log: `{}`\n- registry_check: `passed`\n",
            manifest.proposal_kind,
            rel_path(&repo_root, &validator_log)
        ),
    )?;
    fs::write(
        bundle_root.join("bundle.yml"),
        serde_yaml::to_string(&BundleMetadata {
            kind: "workflow-execution-bundle".to_string(),
            id: bundle_root
                .file_name()
                .and_then(|v| v.to_str())
                .unwrap_or("workflow-bundle")
                .to_string(),
            workflow_id: "validate-proposal".to_string(),
            package_path: proposal_rel.clone(),
            mode: "n/a".to_string(),
            executor: "n/a".to_string(),
            prepare_only: false,
            slug: slugify(&proposal_rel),
            started_at: started_at.clone(),
            completed_at: auth_now_rfc3339()?,
            summary: "summary.md".to_string(),
            reports_dir: "reports".to_string(),
            stage_inputs_dir: "stage-inputs".to_string(),
            stage_logs_dir: "stage-logs".to_string(),
            selected_stages: vec!["validate-proposal".to_string(), "report".to_string()],
            report_paths: BTreeMap::new(),
            changed_files: BTreeMap::new(),
            plan: "plan.md".to_string(),
            inventory: "inventory.md".to_string(),
            commands: "commands.md".to_string(),
            validation: "validation.md".to_string(),
            summary_report: rel_path(&repo_root, &summary_report),
            final_verdict: "validated".to_string(),
            failure_class: None,
            failed_stage: None,
        })?,
    )?;
    finalize_execution(
        &workflow_artifacts,
        &workflow_request,
        &workflow_grant,
        &workflow_effects,
        &started_at,
        &ExecutionOutcome {
            status: "succeeded".to_string(),
            started_at: started_at.clone(),
            completed_at: auth_now_rfc3339()?,
            error: None,
        },
        &SideEffectSummary {
            touched_scope: vec![bundle_root.display().to_string()],
            ..SideEffectSummary::default()
        },
    )?;

    Ok(RunProposalOperationResult {
        bundle_root,
        summary_report,
        final_verdict: "validated".to_string(),
    })
}

pub fn run_promote_proposal_from_octon_dir(
    octon_dir: &Path,
    options: RunPromoteProposalOptions,
) -> Result<RunProposalOperationResult> {
    let runtime_cfg = ConfigLoader::load(octon_dir)?;
    let policy = PolicyEngine::new(runtime_cfg.clone());
    let repo_root = octon_dir
        .parent()
        .context("failed to resolve repository root from .octon directory")?
        .canonicalize()
        .context("failed to canonicalize repository root")?;
    let proposal_root = if options.proposal_path.is_absolute() {
        options.proposal_path.clone()
    } else {
        repo_root.join(&options.proposal_path)
    };
    let proposal_rel = rel_path(&repo_root, &proposal_root);
    let workflow_request_id = resolve_requested_workflow_run_id(
        &runtime_cfg,
        options.run_id.as_deref(),
        "promote-proposal",
        options.resume_existing,
    )?;

    let reports_root = repo_root.join(REPORTS_ROOT_REL);
    let workflow_bundles_root = repo_root.join(WORKFLOW_REPORTS_ROOT_REL);
    let (intent_ref, execution_role_ref, metadata) = request::bind_repo_local_request(
        &runtime_cfg,
        BTreeMap::from([("workflow_id".to_string(), "promote-proposal".to_string())]),
    )?;
    let workflow_request = ExecutionRequest {
        request_id: workflow_request_id,
        caller_path: "workflow".to_string(),
        action_type: "execute_workflow".to_string(),
        target_id: "promote-proposal".to_string(),
        requested_capabilities: vec![
            "workflow.execute".to_string(),
            "repo.write".to_string(),
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
        review_requirements: ReviewRequirements::default(),
        scope_constraints: ScopeConstraints {
            read: vec!["workflow-scope".to_string()],
            write: vec![
                proposal_root.display().to_string(),
                reports_root.display().to_string(),
                workflow_bundles_root.display().to_string(),
            ],
            executor_profile: None,
            locality_scope: None,
        },
        policy_mode_requested: None,
        environment_hint: None,
        metadata,
        ..ExecutionRequest::default()
    };
    let workflow_grant = authorize_execution(&runtime_cfg, &policy, &workflow_request, None)?;
    fs::create_dir_all(&reports_root)?;
    fs::create_dir_all(&workflow_bundles_root)?;
    let date = today_string()?;
    let started_at = auth_now_rfc3339()?;
    let bundle_root = unique_directory(
        &workflow_bundles_root,
        &format!("{date}-promote-proposal-{}", slugify(&proposal_rel)),
    )?;
    fs::create_dir_all(bundle_root.join("reports"))?;
    fs::create_dir_all(bundle_root.join("stage-inputs"))?;
    fs::create_dir_all(bundle_root.join("stage-logs"))?;
    let workflow_artifact_root = bundle_root.join("workflow-execution");
    let workflow_effects = artifact_effects_for_root(&workflow_artifact_root, &workflow_grant)?;
    let workflow_artifacts = write_execution_start(
        &workflow_artifact_root,
        &workflow_request,
        &workflow_grant,
        &workflow_effects,
    )?;
    let summary_report = unique_file(&reports_root, &format!("{date}-promote-proposal"), "md")?;

    if !proposal_root.is_dir() {
        let message = format!("target proposal not found: {}", proposal_root.display());
        let _ = finalize_workflow_failure(
            &workflow_artifacts,
            &workflow_request,
            &workflow_grant,
            &started_at,
            message.clone(),
            vec![
                bundle_root.display().to_string(),
                proposal_root.display().to_string(),
            ],
        );
        bail!(message);
    }

    validate_repo_relative_paths(
        &repo_root,
        &options.promotion_evidence,
        "promotion_evidence",
    )?;
    let mut manifest = load_proposal_manifest(&proposal_root)?;
    ensure!(
        proposal_rel
            == expected_active_proposal_rel(&manifest.proposal_kind, &manifest.proposal_id),
        "proposal must be promoted from the active path: {}",
        proposal_rel
    );
    let promotion_mode = match manifest.status.as_str() {
        "accepted" => "mutating-transition",
        "implemented" => "idempotent-no-op",
        other => bail!(
            "promote-proposal requires status=accepted, or status=implemented with matching registry for replay; found {}",
            other
        ),
    };
    ensure!(
        promotion_mode != "idempotent-no-op"
            || proposal_registry_active_status_matches(
                &repo_root,
                &proposal_rel,
                &manifest.proposal_kind,
                &manifest.proposal_id,
                "implemented",
            )?,
        "promote-proposal replay requires registry status=implemented for {}",
        proposal_rel
    );

    let stage_validate = authorize_workflow_stage(
        &runtime_cfg,
        &policy,
        &bundle_root,
        "promote-proposal",
        &workflow_request.request_id,
        "validate-proposal",
        "execute_stage",
        "promote-proposal::validate-proposal",
        vec![
            "workflow.stage.execute".to_string(),
            "evidence.write".to_string(),
        ],
        vec![
            bundle_root
                .join("standard-validator.log")
                .display()
                .to_string(),
            bundle_root
                .join("stages/validate-proposal")
                .display()
                .to_string(),
        ],
        true,
        false,
        "low",
        Some("read_only_analysis"),
        None,
        None,
    )?;
    let validator_log = match run_promote_proposal_validator_stack(
        &repo_root,
        &proposal_root,
        &bundle_root,
        &manifest.proposal_kind,
    ) {
        Ok(path) => path,
        Err(error) => {
            let _ = finalize_workflow_stage(
                &stage_validate,
                "failed",
                Some(error.to_string()),
                vec![bundle_root
                    .join("standard-validator.log")
                    .display()
                    .to_string()],
            );
            let _ = finalize_workflow_failure(
                &workflow_artifacts,
                &workflow_request,
                &workflow_grant,
                &started_at,
                error.to_string(),
                vec![
                    bundle_root.display().to_string(),
                    proposal_root.display().to_string(),
                ],
            );
            return Err(error);
        }
    };
    if promotion_mode == "mutating-transition" {
        if let Err(error) =
            run_proposal_review_gate_validator(&repo_root, &proposal_root, &bundle_root, true)
        {
            let _ = finalize_workflow_stage(
                &stage_validate,
                "failed",
                Some(error.to_string()),
                vec![bundle_root
                    .join("standard-validator.log")
                    .display()
                    .to_string()],
            );
            let _ = finalize_workflow_failure(
                &workflow_artifacts,
                &workflow_request,
                &workflow_grant,
                &started_at,
                error.to_string(),
                vec![
                    bundle_root.display().to_string(),
                    proposal_root.display().to_string(),
                ],
            );
            return Err(error);
        }
    }
    finalize_workflow_stage(
        &stage_validate,
        "succeeded",
        None,
        vec![rel_path(&repo_root, &validator_log)],
    )?;

    let stage_promote = authorize_workflow_stage(
        &runtime_cfg,
        &policy,
        &bundle_root,
        "promote-proposal",
        &workflow_request.request_id,
        "promote-proposal",
        "execute_stage",
        "promote-proposal::promote-proposal",
        vec![
            "workflow.stage.execute".to_string(),
            "repo.write".to_string(),
            "evidence.write".to_string(),
        ],
        vec![
            proposal_root.display().to_string(),
            bundle_root
                .join("stages/promote-proposal")
                .display()
                .to_string(),
        ],
        false,
        true,
        "medium",
        Some("scoped_repo_mutation"),
        None,
        None,
    )?;
    let promote_result: Result<Vec<String>> = (|| {
        ensure_promotion_targets_ready(&repo_root, &manifest, &proposal_root)?;
        if promotion_mode == "idempotent-no-op" {
            return Ok(vec![".octon/generated/proposals/registry.yml".to_string()]);
        }
        let original_manifest = manifest.clone();
        manifest.status = "implemented".to_string();
        write_proposal_manifest(&proposal_root, &manifest)?;
        if let Err(error) = regenerate_proposal_registry(&repo_root, true) {
            write_proposal_manifest(&proposal_root, &original_manifest)?;
            return Err(error);
        }
        ensure!(
            proposal_registry_active_status_matches(
                &repo_root,
                &proposal_rel,
                &manifest.proposal_kind,
                &manifest.proposal_id,
                "implemented",
            )?,
            "promote-proposal registry regeneration did not publish implemented status for {}",
            proposal_rel
        );
        Ok(vec![
            rel_path(&repo_root, &proposal_root.join("proposal.yml")),
            ".octon/generated/proposals/registry.yml".to_string(),
        ])
    })();
    let promoted_paths = match promote_result {
        Ok(paths) => paths,
        Err(error) => {
            let _ = finalize_workflow_stage(
                &stage_promote,
                "failed",
                Some(error.to_string()),
                vec![proposal_root.display().to_string()],
            );
            let _ = finalize_workflow_failure(
                &workflow_artifacts,
                &workflow_request,
                &workflow_grant,
                &started_at,
                error.to_string(),
                vec![
                    bundle_root.display().to_string(),
                    proposal_root.display().to_string(),
                ],
            );
            return Err(error);
        }
    };
    finalize_workflow_stage(&stage_promote, "succeeded", None, promoted_paths)?;

    write_create_inventory(&bundle_root, &proposal_root)?;
    write_create_commands_log(
        &bundle_root,
        &[
            format!(
                "- validate proposal before promotion | proposal_path={} | validator_log={}",
                proposal_rel,
                rel_path(&repo_root, &validator_log)
            ),
            format!(
                "- promote proposal | proposal_path={} | promotion_mode={} | promotion_evidence={}",
                proposal_rel,
                promotion_mode,
                options.promotion_evidence.join(", ")
            ),
        ],
    )?;
    let summary = format!(
        "# Promote Proposal Summary\n\n- workflow_id: `promote-proposal`\n- proposal_path: `{}`\n- proposal_kind: `{}`\n- final_verdict: `implemented`\n- promotion_mode: `{}`\n- bundle_root: `{}`\n- summary_report: `{}`\n- validator_log: `{}`\n- promotion_evidence: `{}`\n",
        proposal_rel,
        manifest.proposal_kind,
        promotion_mode,
        rel_path(&repo_root, &bundle_root),
        rel_path(&repo_root, &summary_report),
        rel_path(&repo_root, &validator_log),
        options.promotion_evidence.join(", ")
    );
    fs::write(bundle_root.join("summary.md"), &summary)?;
    fs::write(&summary_report, summary)?;
    fs::write(
        bundle_root.join("validation.md"),
        format!(
            "# Validation\n\n- final_verdict: `implemented`\n- proposal_kind: `{}`\n- validator_log: `{}`\n- status_after_promotion: `implemented`\n- promotion_mode: `{}`\n- registry_sync: `passed`\n",
            manifest.proposal_kind,
            rel_path(&repo_root, &validator_log),
            promotion_mode
        ),
    )?;
    fs::write(
        bundle_root.join("bundle.yml"),
        serde_yaml::to_string(&BundleMetadata {
            kind: "workflow-execution-bundle".to_string(),
            id: bundle_root
                .file_name()
                .and_then(|v| v.to_str())
                .unwrap_or("workflow-bundle")
                .to_string(),
            workflow_id: "promote-proposal".to_string(),
            package_path: proposal_rel.clone(),
            mode: "n/a".to_string(),
            executor: "n/a".to_string(),
            prepare_only: false,
            slug: slugify(&proposal_rel),
            started_at: started_at.clone(),
            completed_at: auth_now_rfc3339()?,
            summary: "summary.md".to_string(),
            reports_dir: "reports".to_string(),
            stage_inputs_dir: "stage-inputs".to_string(),
            stage_logs_dir: "stage-logs".to_string(),
            selected_stages: vec![
                "validate-proposal".to_string(),
                "promote-proposal".to_string(),
                "report".to_string(),
            ],
            report_paths: BTreeMap::new(),
            changed_files: BTreeMap::new(),
            plan: "plan.md".to_string(),
            inventory: "inventory.md".to_string(),
            commands: "commands.md".to_string(),
            validation: "validation.md".to_string(),
            summary_report: rel_path(&repo_root, &summary_report),
            final_verdict: "implemented".to_string(),
            failure_class: None,
            failed_stage: None,
        })?,
    )?;
    finalize_execution(
        &workflow_artifacts,
        &workflow_request,
        &workflow_grant,
        &workflow_effects,
        &started_at,
        &ExecutionOutcome {
            status: "succeeded".to_string(),
            started_at: started_at.clone(),
            completed_at: auth_now_rfc3339()?,
            error: None,
        },
        &SideEffectSummary {
            touched_scope: vec![
                bundle_root.display().to_string(),
                proposal_root.display().to_string(),
                repo_root
                    .join(".octon/generated/proposals/registry.yml")
                    .display()
                    .to_string(),
            ],
            ..SideEffectSummary::default()
        },
    )?;

    Ok(RunProposalOperationResult {
        bundle_root,
        summary_report,
        final_verdict: "implemented".to_string(),
    })
}

const TERMINAL_CLOSEOUT_WORKFLOW_ID: &str = "proposal-packet-terminal-closeout";
const TERMINAL_CLOSEOUT_STAGES: &[&str] = &[
    "bind-profile",
    "verify-durable-implementation-state",
    "verify-implementation-conformance",
    "verify-post-implementation-drift",
    "validate-publication-freshness",
    "classify-repo-hygiene",
    "classify-worktree-hygiene",
    "run-evidence-only-reviews",
    "resolve-git-github-route",
    "emit-terminal-receipt",
];

#[derive(Clone, Debug)]
struct TerminalValidationResult {
    command: String,
    log_rel: String,
    success: bool,
}

#[derive(Clone, Debug)]
struct TerminalStageRecord {
    state_id: String,
    input_refs: Vec<String>,
    validator_command_refs: Vec<String>,
    output_evidence_refs: Vec<String>,
    state_verdict: String,
}

#[derive(Clone, Debug)]
struct TerminalBlocker {
    class: String,
    detail: String,
    failing_evidence_ref: String,
    next_canonical_route: String,
}

pub fn run_proposal_packet_terminal_closeout_from_octon_dir(
    octon_dir: &Path,
    options: RunProposalPacketTerminalCloseoutOptions,
) -> Result<RunProposalOperationResult> {
    let runtime_cfg = ConfigLoader::load(octon_dir)?;
    let policy = PolicyEngine::new(runtime_cfg.clone());
    let repo_root = octon_dir
        .parent()
        .context("failed to resolve repository root from .octon directory")?
        .canonicalize()
        .context("failed to canonicalize repository root")?;
    let proposal_root = resolve_repo_relative_path(&repo_root, &options.proposal_path)?;
    ensure!(
        proposal_root.starts_with(&repo_root),
        "proposal_path must stay inside repository root: {}",
        proposal_root.display()
    );
    ensure!(
        proposal_root.is_dir(),
        "target proposal not found: {}",
        proposal_root.display()
    );
    let proposal_rel = rel_path(&repo_root, &proposal_root);
    let manifest = load_proposal_manifest(&proposal_root)?;
    ensure!(
        options.target_outcome == "archive-ready" || options.target_outcome == "blocked",
        "target_outcome must be archive-ready or blocked"
    );

    let terminal_run_id = options.terminal_run_id.clone().unwrap_or_else(|| {
        options.run_id.clone().unwrap_or_else(|| {
            format!(
                "{}-{}",
                TERMINAL_CLOSEOUT_WORKFLOW_ID,
                slugify(&proposal_rel)
            )
        })
    });
    let workflow_request_id = resolve_requested_workflow_run_id(
        &runtime_cfg,
        options.run_id.as_deref(),
        TERMINAL_CLOSEOUT_WORKFLOW_ID,
        options.resume_existing,
    )?;
    let reports_root = repo_root.join(REPORTS_ROOT_REL);
    let workflow_bundles_root = repo_root.join(WORKFLOW_REPORTS_ROOT_REL);
    let (intent_ref, execution_role_ref, metadata) = request::bind_repo_local_request(
        &runtime_cfg,
        BTreeMap::from([(
            "workflow_id".to_string(),
            TERMINAL_CLOSEOUT_WORKFLOW_ID.to_string(),
        )]),
    )?;
    let workflow_request = ExecutionRequest {
        request_id: workflow_request_id.clone(),
        caller_path: "workflow".to_string(),
        action_type: "execute_workflow".to_string(),
        target_id: TERMINAL_CLOSEOUT_WORKFLOW_ID.to_string(),
        requested_capabilities: vec![
            "workflow.execute".to_string(),
            "repo.write".to_string(),
            "evidence.write".to_string(),
        ],
        side_effect_flags: SideEffectFlags {
            write_repo: true,
            write_evidence: true,
            shell: true,
            network: false,
            model_invoke: false,
            state_mutation: false,
            publication: false,
            branch_mutation: false,
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
            read: vec!["workflow-scope".to_string()],
            write: vec![
                proposal_root.display().to_string(),
                reports_root.display().to_string(),
                workflow_bundles_root.display().to_string(),
            ],
            executor_profile: Some("scoped_repo_mutation".to_string()),
            locality_scope: None,
        },
        policy_mode_requested: None,
        environment_hint: None,
        metadata,
        ..ExecutionRequest::default()
    };
    let workflow_grant = authorize_execution(&runtime_cfg, &policy, &workflow_request, None)?;
    fs::create_dir_all(&reports_root)?;
    fs::create_dir_all(&workflow_bundles_root)?;
    let date = today_string()?;
    let started_at = auth_now_rfc3339()?;
    let bundle_root = unique_directory(
        &workflow_bundles_root,
        &format!(
            "{date}-{}-{}",
            TERMINAL_CLOSEOUT_WORKFLOW_ID,
            slugify(&proposal_rel)
        ),
    )?;
    fs::create_dir_all(bundle_root.join("reports"))?;
    fs::create_dir_all(bundle_root.join("stage-inputs"))?;
    fs::create_dir_all(bundle_root.join("stage-logs"))?;
    let workflow_artifact_root = bundle_root.join("workflow-execution");
    let workflow_effects = artifact_effects_for_root(&workflow_artifact_root, &workflow_grant)?;
    let workflow_artifacts = write_execution_start(
        &workflow_artifact_root,
        &workflow_request,
        &workflow_grant,
        &workflow_effects,
    )?;
    let summary_report = unique_file(
        &reports_root,
        &format!("{date}-{TERMINAL_CLOSEOUT_WORKFLOW_ID}"),
        "md",
    )?;

    let mut stages = Vec::<TerminalStageRecord>::new();
    let mut command_log = Vec::<String>::new();
    let mut retained_inventory = Vec::<String>::new();
    let mut blocker: Option<TerminalBlocker> = None;

    let profile_path = bundle_root.join("profile.yml");
    if let Some(source_profile) = options.profile_path.as_ref() {
        let source_profile = resolve_repo_relative_path(&repo_root, source_profile)?;
        fs::copy(&source_profile, &profile_path).with_context(|| {
            format!(
                "copy supplied terminal closeout profile {} to {}",
                source_profile.display(),
                profile_path.display()
            )
        })?;
    } else {
        fs::write(
            &profile_path,
            default_terminal_closeout_profile(
                &manifest,
                &proposal_rel,
                &options.target_outcome,
                &terminal_run_id,
            ),
        )?;
    }
    let profile_rel = rel_path(&repo_root, &profile_path);
    let profile_digest = format!(
        "sha256:{}",
        hex::encode(Sha256::digest(fs::read(&profile_path)?))
    );
    let profile_validation = run_terminal_validator(
        &repo_root,
        &bundle_root,
        "bind-profile-profile-validation",
        ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-profile.sh",
        &[String::from("--profile"), profile_rel.clone()],
    )?;
    command_log.push(format!(
        "- {} | log={} | status={}",
        profile_validation.command, profile_validation.log_rel, profile_validation.success
    ));
    if !profile_validation.success {
        set_terminal_blocker(
            &mut blocker,
            "validator-failed",
            "terminal closeout profile validation failed",
            &profile_validation.log_rel,
            "manual-intervention",
        );
    }
    stages.push(write_terminal_stage_record(
        &runtime_cfg,
        &policy,
        &repo_root,
        &bundle_root,
        &workflow_request_id,
        "bind-profile",
        false,
        "pass",
        vec![
            format!("{proposal_rel}/proposal.yml"),
            profile_rel.clone(),
        ],
        vec![profile_validation.command.clone()],
        vec![profile_validation.log_rel.clone(), profile_rel.clone()],
        format!(
            "# Bind Profile\n\n- proposal_path: `{proposal_rel}`\n- target_outcome: `{}`\n- profile_ref: `{profile_rel}`\n- profile_digest: `{profile_digest}`\n- profile_validation: `{}`\n",
            options.target_outcome,
            profile_validation.log_rel
        ),
    )?);
    retained_inventory.extend([profile_rel.clone(), profile_validation.log_rel.clone()]);

    let durable_report = bundle_root.join("reports/durable-implementation-state.md");
    let mut durable_notes = Vec::<String>::new();
    if manifest.status != "implemented" && options.target_outcome == "archive-ready" {
        set_terminal_blocker(
            &mut blocker,
            "missing-evidence",
            &format!(
                "archive-ready terminal closeout requires implemented status, found {}",
                manifest.status
            ),
            &format!("{proposal_rel}/proposal.yml"),
            "promote-proposal",
        );
    }
    for target in &manifest.promotion_targets {
        let target_path = repo_root.join(target);
        if target_path.exists() {
            durable_notes.push(format!("- [x] promotion target exists: `{target}`"));
        } else {
            durable_notes.push(format!("- [ ] promotion target missing: `{target}`"));
            set_terminal_blocker(
                &mut blocker,
                "missing-evidence",
                &format!("promotion target missing: {target}"),
                &format!("{proposal_rel}/proposal.yml"),
                "run-packet-implementation",
            );
        }
    }
    fs::write(
        &durable_report,
        format!(
            "# Durable Implementation State\n\n- proposal_status: `{}`\n- promotion_target_count: `{}`\n\n{}\n",
            manifest.status,
            manifest.promotion_targets.len(),
            durable_notes.join("\n")
        ),
    )?;
    stages.push(write_terminal_stage_record(
        &runtime_cfg,
        &policy,
        &repo_root,
        &bundle_root,
        &workflow_request_id,
        "verify-durable-implementation-state",
        false,
        if blocker.is_some() { "blocked" } else { "pass" },
        vec![format!("{proposal_rel}/proposal.yml")],
        vec!["deterministic promotion target existence check".to_string()],
        vec![rel_path(&repo_root, &durable_report)],
        fs::read_to_string(&durable_report)?,
    )?);
    retained_inventory.push(rel_path(&repo_root, &durable_report));

    let conformance = run_terminal_validator(
        &repo_root,
        &bundle_root,
        "implementation-conformance",
        ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh",
        &[String::from("--package"), proposal_rel.clone()],
    )?;
    command_log.push(format!(
        "- {} | log={} | status={}",
        conformance.command, conformance.log_rel, conformance.success
    ));
    if !conformance.success {
        set_terminal_blocker(
            &mut blocker,
            "validator-failed",
            "implementation conformance validator failed",
            &conformance.log_rel,
            "run-packet-verification-and-correction-loop",
        );
    }
    stages.push(write_terminal_stage_record(
        &runtime_cfg,
        &policy,
        &repo_root,
        &bundle_root,
        &workflow_request_id,
        "verify-implementation-conformance",
        false,
        if conformance.success {
            "pass"
        } else {
            "blocked"
        },
        vec![format!(
            "{proposal_rel}/support/implementation-conformance-review.md"
        )],
        vec![conformance.command.clone()],
        vec![conformance.log_rel.clone()],
        format!(
            "# Verify Implementation Conformance\n\n- validator_log: `{}`\n- verdict: `{}`\n",
            conformance.log_rel,
            if conformance.success {
                "pass"
            } else {
                "blocked"
            }
        ),
    )?);
    retained_inventory.push(conformance.log_rel.clone());

    let drift = run_terminal_validator(
        &repo_root,
        &bundle_root,
        "post-implementation-drift",
        ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh",
        &[String::from("--package"), proposal_rel.clone()],
    )?;
    command_log.push(format!(
        "- {} | log={} | status={}",
        drift.command, drift.log_rel, drift.success
    ));
    if !drift.success {
        set_terminal_blocker(
            &mut blocker,
            "validator-failed",
            "post-implementation drift validator failed",
            &drift.log_rel,
            "run-packet-verification-and-correction-loop",
        );
    }
    stages.push(write_terminal_stage_record(
        &runtime_cfg,
        &policy,
        &repo_root,
        &bundle_root,
        &workflow_request_id,
        "verify-post-implementation-drift",
        false,
        if drift.success { "pass" } else { "blocked" },
        vec![format!(
            "{proposal_rel}/support/post-implementation-drift-churn-review.md"
        )],
        vec![drift.command.clone()],
        vec![drift.log_rel.clone()],
        format!(
            "# Verify Post-Implementation Drift\n\n- validator_log: `{}`\n- verdict: `{}`\n",
            drift.log_rel,
            if drift.success { "pass" } else { "blocked" }
        ),
    )?);
    retained_inventory.push(drift.log_rel.clone());

    let publication_validators = [
        (
            "generated-non-authority",
            ".octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh",
            Vec::<String>::new(),
        ),
        (
            "input-non-authority",
            ".octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh",
            Vec::<String>::new(),
        ),
        (
            "run-health-read-model",
            ".octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh",
            Vec::<String>::new(),
        ),
        (
            "capability-publication-state",
            ".octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh",
            Vec::<String>::new(),
        ),
        (
            "extension-publication-state",
            ".octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh",
            Vec::<String>::new(),
        ),
        (
            "product-feature-catalog",
            ".octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh",
            Vec::<String>::new(),
        ),
    ];
    let mut publication_results = Vec::<TerminalValidationResult>::new();
    for (log_name, script_rel, args) in publication_validators {
        let result = run_terminal_validator(&repo_root, &bundle_root, log_name, script_rel, &args)?;
        command_log.push(format!(
            "- {} | log={} | status={}",
            result.command, result.log_rel, result.success
        ));
        if !result.success {
            set_terminal_blocker(
                &mut blocker,
                "publication-freshness-blocked",
                &format!("publication or non-authority validator failed: {script_rel}"),
                &result.log_rel,
                "blocked",
            );
        }
        retained_inventory.push(result.log_rel.clone());
        publication_results.push(result);
    }
    let publication_logs = publication_results
        .iter()
        .map(|result| result.log_rel.clone())
        .collect::<Vec<_>>();
    stages.push(write_terminal_stage_record(
        &runtime_cfg,
        &policy,
        &repo_root,
        &bundle_root,
        &workflow_request_id,
        "validate-publication-freshness",
        false,
        if publication_results.iter().all(|result| result.success) {
            "pass"
        } else {
            "blocked"
        },
        vec!["terminal closeout publication validator selection".to_string()],
        publication_results
            .iter()
            .map(|result| result.command.clone())
            .collect(),
        publication_logs.clone(),
        format!(
            "# Validate Publication Freshness\n\n{}\n",
            publication_results
                .iter()
                .map(|result| format!(
                    "- `{}` -> `{}`",
                    result.command,
                    if result.success { "pass" } else { "blocked" }
                ))
                .collect::<Vec<_>>()
                .join("\n")
        ),
    )?);

    let repo_hygiene_report = bundle_root.join("reports/repo-hygiene-classification.md");
    fs::write(
        &repo_hygiene_report,
        "# Repo Hygiene Classification\n\n- cleanup_performed: `false`\n- unauthorized_deletion_performed: `false`\n- deletion_authority: `not-granted-by-terminal-closeout`\n",
    )?;
    stages.push(write_terminal_stage_record(
        &runtime_cfg,
        &policy,
        &repo_root,
        &bundle_root,
        &workflow_request_id,
        "classify-repo-hygiene",
        false,
        "pass",
        publication_logs.clone(),
        vec!["deterministic repo hygiene classification".to_string()],
        vec![rel_path(&repo_root, &repo_hygiene_report)],
        fs::read_to_string(&repo_hygiene_report)?,
    )?);
    retained_inventory.push(rel_path(&repo_root, &repo_hygiene_report));

    let worktree = classify_terminal_worktree(
        &repo_root,
        &bundle_root,
        &proposal_rel,
        &manifest,
        &workflow_request_id,
    )?;
    if worktree.foreign_or_ambiguous_count > 0 {
        set_terminal_blocker(
            &mut blocker,
            "hygiene-blocked",
            &format!(
                "foreign or ambiguous worktree residue remains: {} paths",
                worktree.foreign_or_ambiguous_count
            ),
            &worktree.report_rel,
            "closeout-worktree",
        );
    }
    stages.push(write_terminal_stage_record(
        &runtime_cfg,
        &policy,
        &repo_root,
        &bundle_root,
        &workflow_request_id,
        "classify-worktree-hygiene",
        false,
        if worktree.foreign_or_ambiguous_count == 0 {
            "pass"
        } else {
            "blocked"
        },
        vec![rel_path(&repo_root, &repo_hygiene_report)],
        vec!["git status --porcelain".to_string()],
        vec![worktree.report_rel.clone()],
        worktree.report_body.clone(),
    )?);
    retained_inventory.push(worktree.report_rel.clone());

    let evidence_review_report = bundle_root.join("reports/evidence-only-reviews.md");
    fs::write(
        &evidence_review_report,
        format!(
            "# Evidence-Only Reviews\n\n- proposal_kind: `{}`\n- post_integration_architecture_review_authority: `evidence-only`\n- packet_terminal_evaluator_authority: `evidence-only`\n- lifecycle_postmortem_authority: `evidence-only`\n- terminal_receipt_authority: `terminal-closeout-workflow-only`\n",
            manifest.proposal_kind
        ),
    )?;
    stages.push(write_terminal_stage_record(
        &runtime_cfg,
        &policy,
        &repo_root,
        &bundle_root,
        &workflow_request_id,
        "run-evidence-only-reviews",
        false,
        "pass",
        vec![worktree.report_rel.clone()],
        vec!["deterministic evidence-only review classification".to_string()],
        vec![rel_path(&repo_root, &evidence_review_report)],
        fs::read_to_string(&evidence_review_report)?,
    )?);
    retained_inventory.push(rel_path(&repo_root, &evidence_review_report));

    let git_route_report = bundle_root.join("reports/git-github-route.md");
    let git_next_route = if worktree.foreign_or_ambiguous_count > 0 {
        "closeout-worktree"
    } else {
        "archive-proposal"
    };
    fs::write(
        &git_route_report,
        format!(
            "# Git And GitHub Route\n\n- mutation_delegated: `true`\n- branch_no_pr: `false`\n- route_ref: `{git_next_route}`\n- exact_sha_checks_ref: `not-applicable`\n- landing_authorization_ref: `not-applicable`\n- branch_cleanup_required: `false`\n- branch_cleanup_authorization_ref: `not-applicable`\n"
        ),
    )?;
    stages.push(write_terminal_stage_record(
        &runtime_cfg,
        &policy,
        &repo_root,
        &bundle_root,
        &workflow_request_id,
        "resolve-git-github-route",
        false,
        if worktree.foreign_or_ambiguous_count == 0 {
            "pass"
        } else {
            "blocked"
        },
        vec![worktree.report_rel.clone()],
        vec!["deterministic Git/GitHub route classification".to_string()],
        vec![rel_path(&repo_root, &git_route_report)],
        fs::read_to_string(&git_route_report)?,
    )?);
    retained_inventory.push(rel_path(&repo_root, &git_route_report));

    let final_blocker = blocker.unwrap_or_else(|| TerminalBlocker {
        class: "none".to_string(),
        detail: "no blocker".to_string(),
        failing_evidence_ref: "not-applicable".to_string(),
        next_canonical_route: "archive-proposal".to_string(),
    });
    let terminal_verdict = if options.target_outcome == "archive-ready"
        && final_blocker.class == "none"
        && conformance.success
        && drift.success
        && publication_results.iter().all(|result| result.success)
        && worktree.foreign_or_ambiguous_count == 0
    {
        "archive-ready"
    } else {
        "blocked"
    };
    let receipt_path = bundle_root.join("terminal-receipt.yml");
    let packet_receipt_path = proposal_root.join("support/proposal-terminal-closeout.yml");
    let receipt_rel = rel_path(&repo_root, &receipt_path);
    let packet_receipt_rel = rel_path(&repo_root, &packet_receipt_path);
    let receipt_validation_log_rel = rel_path(
        &repo_root,
        &bundle_root
            .join("stage-logs")
            .join("terminal-receipt-validation.log"),
    );
    retained_inventory.extend([
        receipt_rel.clone(),
        packet_receipt_rel.clone(),
        format!("{proposal_rel}/support/implementation-conformance-review.md"),
        format!("{proposal_rel}/support/post-implementation-drift-churn-review.md"),
        format!("{proposal_rel}/support/proposal-closeout.md"),
    ]);
    retained_inventory.sort();
    retained_inventory.dedup();
    stages.push(write_terminal_stage_record(
        &runtime_cfg,
        &policy,
        &repo_root,
        &bundle_root,
        &workflow_request_id,
        "emit-terminal-receipt",
        true,
        terminal_verdict,
        vec![rel_path(&repo_root, &git_route_report)],
        vec![format!(
            "bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-receipt.sh --receipt {receipt_rel}"
        )],
        vec![
            receipt_rel.clone(),
            packet_receipt_rel.clone(),
            receipt_validation_log_rel.clone(),
        ],
        format!(
            "# Emit Terminal Receipt\n\n- terminal_verdict: `{terminal_verdict}`\n- receipt_ref: `{receipt_rel}`\n- packet_receipt_ref: `{packet_receipt_rel}`\n- receipt_validation_ref: `{receipt_validation_log_rel}`\n",
        ),
    )?);
    let receipt_yaml = build_terminal_receipt_yaml(
        &repo_root,
        &terminal_run_id,
        &auth_now_rfc3339()?,
        &manifest,
        &proposal_rel,
        &options.target_outcome,
        terminal_verdict,
        &profile_rel,
        &profile_digest,
        &profile_validation.log_rel,
        &stages,
        &conformance,
        &drift,
        &publication_results,
        &repo_hygiene_report,
        &worktree,
        &evidence_review_report,
        &git_route_report,
        &final_blocker,
        &retained_inventory,
    );
    fs::write(&receipt_path, &receipt_yaml)?;
    if let Some(parent) = packet_receipt_path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(&packet_receipt_path, &receipt_yaml)?;
    let receipt_validation = run_terminal_validator(
        &repo_root,
        &bundle_root,
        "terminal-receipt-validation",
        ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-receipt.sh",
        &[String::from("--receipt"), receipt_rel.clone()],
    )?;
    command_log.push(format!(
        "- {} | log={} | status={}",
        receipt_validation.command, receipt_validation.log_rel, receipt_validation.success
    ));
    write_terminal_state_ledger(
        &repo_root,
        &bundle_root,
        &terminal_run_id,
        &workflow_request_id,
        &manifest,
        &proposal_rel,
        &options.target_outcome,
        &profile_rel,
        &profile_digest,
        &profile_validation.log_rel,
        &stages,
    )?;
    if !receipt_validation.success {
        let error = format!(
            "terminal closeout receipt validation failed (see {})",
            receipt_validation.log_rel
        );
        let _ = finalize_workflow_failure(
            &workflow_artifacts,
            &workflow_request,
            &workflow_grant,
            &started_at,
            error.clone(),
            vec![
                bundle_root.display().to_string(),
                packet_receipt_path.display().to_string(),
            ],
        );
        bail!(error);
    }

    write_create_inventory(&bundle_root, &proposal_root)?;
    write_create_commands_log(&bundle_root, &command_log)?;
    let summary = format!(
        "# Proposal Packet Terminal Closeout Summary\n\n- workflow_id: `{TERMINAL_CLOSEOUT_WORKFLOW_ID}`\n- proposal_path: `{proposal_rel}`\n- terminal_verdict: `{terminal_verdict}`\n- blocker_class: `{}`\n- next_canonical_route: `{}`\n- receipt_ref: `{receipt_rel}`\n- packet_receipt_ref: `{packet_receipt_rel}`\n- bundle_root: `{}`\n",
        final_blocker.class,
        final_blocker.next_canonical_route,
        rel_path(&repo_root, &bundle_root)
    );
    fs::write(bundle_root.join("summary.md"), &summary)?;
    fs::write(&summary_report, &summary)?;
    fs::write(
        bundle_root.join("validation.md"),
        format!(
            "# Validation\n\n- final_verdict: `{terminal_verdict}`\n- receipt_validation: `passed`\n- terminal_receipt: `{receipt_rel}`\n- packet_terminal_receipt: `{packet_receipt_rel}`\n- archive_relocation_performed: `false`\n- git_mutation_performed: `false`\n- residue_deletion_performed: `false`\n"
        ),
    )?;
    fs::write(
        bundle_root.join("bundle.yml"),
        serde_yaml::to_string(&BundleMetadata {
            kind: "workflow-execution-bundle".to_string(),
            id: bundle_root
                .file_name()
                .and_then(|value| value.to_str())
                .unwrap_or("workflow-bundle")
                .to_string(),
            workflow_id: TERMINAL_CLOSEOUT_WORKFLOW_ID.to_string(),
            package_path: proposal_rel.clone(),
            mode: "n/a".to_string(),
            executor: "deterministic".to_string(),
            prepare_only: false,
            slug: slugify(&proposal_rel),
            started_at: started_at.clone(),
            completed_at: auth_now_rfc3339()?,
            summary: "summary.md".to_string(),
            reports_dir: "reports".to_string(),
            stage_inputs_dir: "stage-inputs".to_string(),
            stage_logs_dir: "stage-logs".to_string(),
            selected_stages: TERMINAL_CLOSEOUT_STAGES
                .iter()
                .map(|stage| stage.to_string())
                .collect(),
            report_paths: stages
                .iter()
                .map(|stage| {
                    (
                        stage.state_id.clone(),
                        format!("reports/{}-report.md", stage.state_id),
                    )
                })
                .collect(),
            changed_files: BTreeMap::new(),
            plan: "state-ledger.yml".to_string(),
            inventory: "inventory.md".to_string(),
            commands: "commands.md".to_string(),
            validation: "validation.md".to_string(),
            summary_report: rel_path(&repo_root, &summary_report),
            final_verdict: terminal_verdict.to_string(),
            failure_class: None,
            failed_stage: None,
        })?,
    )?;
    finalize_execution(
        &workflow_artifacts,
        &workflow_request,
        &workflow_grant,
        &workflow_effects,
        &started_at,
        &ExecutionOutcome {
            status: "succeeded".to_string(),
            started_at: started_at.clone(),
            completed_at: auth_now_rfc3339()?,
            error: None,
        },
        &SideEffectSummary {
            touched_scope: vec![
                bundle_root.display().to_string(),
                receipt_path.display().to_string(),
                packet_receipt_path.display().to_string(),
            ],
            ..SideEffectSummary::default()
        },
    )?;

    Ok(RunProposalOperationResult {
        bundle_root,
        summary_report,
        final_verdict: terminal_verdict.to_string(),
    })
}

#[derive(Clone, Debug)]
struct TerminalWorktreeClassification {
    report_rel: String,
    report_body: String,
    foreign_or_ambiguous_count: usize,
    retained_fixture_path_count: usize,
    retained_fixture_receipt_refs: Vec<String>,
    dirty_worktree: bool,
}

const FIXTURE_RETENTION_CLOSEOUT_WORKFLOW_ID: &str = "fixture-retention-closeout";
#[derive(Clone, Debug)]
struct FixtureRetentionStageRecord {
    state_id: String,
    input_refs: Vec<String>,
    validator_command_refs: Vec<String>,
    output_evidence_refs: Vec<String>,
    state_verdict: String,
}

#[derive(Clone, Debug, Deserialize)]
struct FixtureRetentionConsumption {
    receipt_ref: String,
    #[serde(default)]
    retained_status_entries: Vec<FixtureRetentionStatusEntry>,
}

#[derive(Clone, Debug, Deserialize)]
struct FixtureRetentionStatusEntry {
    status: String,
    path: String,
}

#[derive(Clone, Debug)]
struct FixtureRetentionCoverage {
    by_path: BTreeMap<String, (String, String)>,
    receipt_refs: BTreeSet<String>,
    ambiguous_paths: BTreeSet<String>,
}

#[derive(Clone, Debug)]
struct GitStatusEntry {
    status: String,
    path: String,
}

pub fn run_fixture_retention_closeout_from_octon_dir(
    octon_dir: &Path,
    options: RunFixtureRetentionCloseoutOptions,
) -> Result<RunProposalOperationResult> {
    let runtime_cfg = ConfigLoader::load(octon_dir)?;
    let policy = PolicyEngine::new(runtime_cfg.clone());
    let repo_root = octon_dir
        .parent()
        .context("failed to resolve repository root from .octon directory")?
        .canonicalize()
        .context("failed to canonicalize repository root")?;
    let fixture_root = resolve_repo_relative_path(&repo_root, &options.fixture_path)?;
    ensure!(
        fixture_root.starts_with(&repo_root),
        "fixture_path must stay inside repository root: {}",
        fixture_root.display()
    );
    ensure!(
        fixture_root.is_dir(),
        "fixture proposal not found: {}",
        fixture_root.display()
    );
    let fixture_rel = rel_path(&repo_root, &fixture_root);
    let manifest = load_proposal_manifest(&fixture_root)?;
    ensure!(
        manifest.lifecycle.temporary,
        "fixture-retention-closeout requires proposal.yml lifecycle.temporary: true"
    );
    ensure!(
        !options.owner_scope.trim().is_empty(),
        "fixture-retention-closeout requires owner_scope"
    );
    ensure!(
        !options.evidence_refs.is_empty(),
        "fixture-retention-closeout requires non-empty evidence_refs proving fixture use"
    );
    validate_repo_relative_paths(&repo_root, &options.evidence_refs, "fixture evidence_refs")?;
    for evidence_ref in &options.evidence_refs {
        ensure!(
            fixture_retention_evidence_ref_allowed(evidence_ref),
            "fixture evidence_ref is not an allowed source evidence ref: {}",
            evidence_ref
        );
    }

    let retention_run_id = options.run_id.clone().unwrap_or_else(|| {
        format!(
            "{}-{}",
            FIXTURE_RETENTION_CLOSEOUT_WORKFLOW_ID,
            slugify(&fixture_rel)
        )
    });
    let workflow_request_id = resolve_requested_workflow_run_id(
        &runtime_cfg,
        options.run_id.as_deref(),
        FIXTURE_RETENTION_CLOSEOUT_WORKFLOW_ID,
        options.resume_existing,
    )?;
    let reports_root = repo_root.join(REPORTS_ROOT_REL);
    let workflow_bundles_root = repo_root.join(WORKFLOW_REPORTS_ROOT_REL);
    let (intent_ref, execution_role_ref, metadata) = request::bind_repo_local_request(
        &runtime_cfg,
        BTreeMap::from([(
            "workflow_id".to_string(),
            FIXTURE_RETENTION_CLOSEOUT_WORKFLOW_ID.to_string(),
        )]),
    )?;
    let workflow_request = ExecutionRequest {
        request_id: workflow_request_id.clone(),
        caller_path: "workflow".to_string(),
        action_type: "execute_workflow".to_string(),
        target_id: FIXTURE_RETENTION_CLOSEOUT_WORKFLOW_ID.to_string(),
        requested_capabilities: vec!["workflow.execute".to_string(), "evidence.write".to_string()],
        side_effect_flags: SideEffectFlags {
            write_repo: false,
            write_evidence: true,
            shell: true,
            network: false,
            model_invoke: false,
            state_mutation: false,
            publication: false,
            branch_mutation: false,
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
            read: vec!["workflow-scope".to_string()],
            write: vec![
                reports_root.display().to_string(),
                workflow_bundles_root.display().to_string(),
            ],
            executor_profile: Some("read_only_analysis".to_string()),
            locality_scope: None,
        },
        policy_mode_requested: None,
        environment_hint: None,
        metadata,
        ..ExecutionRequest::default()
    };
    let workflow_grant = authorize_execution(&runtime_cfg, &policy, &workflow_request, None)?;
    fs::create_dir_all(&reports_root)?;
    fs::create_dir_all(&workflow_bundles_root)?;
    let date = today_string()?;
    let started_at = auth_now_rfc3339()?;
    let bundle_root = unique_directory(
        &workflow_bundles_root,
        &format!(
            "{date}-{}-{}",
            FIXTURE_RETENTION_CLOSEOUT_WORKFLOW_ID,
            slugify(&fixture_rel)
        ),
    )?;
    fs::create_dir_all(bundle_root.join("reports"))?;
    fs::create_dir_all(bundle_root.join("stage-inputs"))?;
    fs::create_dir_all(bundle_root.join("stage-logs"))?;
    let workflow_artifact_root = bundle_root.join("workflow-execution");
    let workflow_effects = artifact_effects_for_root(&workflow_artifact_root, &workflow_grant)?;
    let workflow_artifacts = write_execution_start(
        &workflow_artifact_root,
        &workflow_request,
        &workflow_grant,
        &workflow_effects,
    )?;
    let summary_report = unique_file(
        &reports_root,
        &format!("{date}-{FIXTURE_RETENTION_CLOSEOUT_WORKFLOW_ID}"),
        "md",
    )?;

    let generated_artifact_root = format!(
        ".octon/generated/proposals/artifacts/{}/{}",
        manifest.proposal_kind, manifest.proposal_id
    );
    let validation_root = format!(
        ".octon/state/evidence/validation/proposals/{}",
        manifest.proposal_id
    );
    let fixture_scope_roots = vec![
        fixture_rel.clone(),
        generated_artifact_root.clone(),
        validation_root.clone(),
    ];
    let retained_entries = git_status_entries_for_roots(&repo_root, &fixture_scope_roots)?;
    let retained_paths = retained_entries
        .iter()
        .map(|entry| entry.path.clone())
        .collect::<Vec<_>>();
    let path_set_digest = digest_lines(retained_paths.iter().map(String::as_str));
    let git_status_lines = retained_entries
        .iter()
        .map(|entry| format!("{}\t{}", entry.status, entry.path))
        .collect::<Vec<_>>();
    let git_status_digest = digest_lines(git_status_lines.iter().map(String::as_str));
    let source_digests = fixture_source_digests(&repo_root, &fixture_scope_roots)?;
    let generated_artifact_refs = retained_paths
        .iter()
        .filter(|path| {
            path == &&generated_artifact_root
                || path.starts_with(&format!("{generated_artifact_root}/"))
        })
        .cloned()
        .collect::<Vec<_>>();

    let mut stages = Vec::<FixtureRetentionStageRecord>::new();
    let mut blocker = TerminalBlocker {
        class: "none".to_string(),
        detail: "no blocker".to_string(),
        failing_evidence_ref: "not-applicable".to_string(),
        next_canonical_route: "not-applicable".to_string(),
    };
    if retained_entries.is_empty() {
        blocker = TerminalBlocker {
            class: "missing-retained-path-set".to_string(),
            detail: "fixture retention requires current retained path-set evidence".to_string(),
            failing_evidence_ref: fixture_rel.clone(),
            next_canonical_route: "closeout-worktree".to_string(),
        };
    }

    stages.push(write_fixture_retention_stage_record(
        &runtime_cfg,
        &policy,
        &repo_root,
        &bundle_root,
        &workflow_request_id,
        "resolve-fixture-identity",
        "pass",
        vec![format!("{fixture_rel}/proposal.yml")],
        vec!["proposal.yml manifest parse".to_string()],
        Vec::new(),
        format!(
            "# Resolve Fixture Identity\n\n- fixture_path: `{fixture_rel}`\n- proposal_id: `{}`\n- proposal_kind: `{}`\n- status: `{}`\n- lifecycle_temporary: `{}`\n",
            manifest.proposal_id, manifest.proposal_kind, manifest.status, manifest.lifecycle.temporary
        ),
    )?);
    stages.push(write_fixture_retention_stage_record(
        &runtime_cfg,
        &policy,
        &repo_root,
        &bundle_root,
        &workflow_request_id,
        "bind-retention-scope",
        "pass",
        vec![format!("{fixture_rel}/proposal.yml")],
        vec!["derive fixture scope from proposal_path, proposal_kind, proposal_id, and generated artifact conventions".to_string()],
        Vec::new(),
        format!(
            "# Bind Retention Scope\n\n- purpose: `{}`\n- owner_scope: `{}`\n- retained_scope_roots:\n{}\n",
            options.purpose,
            options.owner_scope,
            terminal_yaml_array(&fixture_scope_roots, "")
        ),
    )?);
    stages.push(write_fixture_retention_stage_record(
        &runtime_cfg,
        &policy,
        &repo_root,
        &bundle_root,
        &workflow_request_id,
        "verify-retained-evidence",
        if blocker.class == "none" { "pass" } else { "blocked" },
        options.evidence_refs.clone(),
        vec!["validate evidence_refs exist and are not generated/proposal-local authority".to_string()],
        Vec::new(),
        format!(
            "# Verify Retained Evidence\n\n- evidence_ref_count: `{}`\n- authority_model: `source-evidence-by-reference`\n- generated_artifacts_authority: `derived-only-non-authority`\n\n{}\n",
            options.evidence_refs.len(),
            terminal_bullets(&options.evidence_refs)
        ),
    )?);
    stages.push(write_fixture_retention_stage_record(
        &runtime_cfg,
        &policy,
        &repo_root,
        &bundle_root,
        &workflow_request_id,
        "classify-retained-path-set",
        if blocker.class == "none" { "pass" } else { "blocked" },
        fixture_scope_roots.clone(),
        vec!["git status --porcelain=v1 --untracked-files=all -- <fixture-scope-roots>".to_string()],
        Vec::new(),
        format!(
            "# Classify Retained Path Set\n\n- retained_path_count: `{}`\n- retained_path_set_digest: `{}`\n- git_status_digest: `{}`\n\n## Retained Status Entries\n\n{}\n",
            retained_entries.len(),
            path_set_digest,
            git_status_digest,
            terminal_bullets(
                &retained_entries
                    .iter()
                    .map(|entry| format!("{} {}", entry.status, entry.path))
                    .collect::<Vec<_>>()
            )
        ),
    )?);

    let receipt_path = bundle_root.join("retention-receipt.yml");
    let receipt_rel = rel_path(&repo_root, &receipt_path);
    let receipt_validation_log_rel = rel_path(
        &repo_root,
        &bundle_root
            .join("stage-logs")
            .join("fixture-retention-receipt-validation.log"),
    );
    let retention_verdict = if blocker.class == "none" {
        "retained"
    } else {
        "blocked"
    };
    stages.push(write_fixture_retention_stage_record(
        &runtime_cfg,
        &policy,
        &repo_root,
        &bundle_root,
        &workflow_request_id,
        "emit-retention-receipt",
        retention_verdict,
        vec![fixture_rel.clone()],
        vec![format!(
            "bash .octon/framework/assurance/runtime/_ops/scripts/validate-fixture-retention-closeout-receipt.sh --receipt {receipt_rel}"
        )],
        vec![receipt_rel.clone(), receipt_validation_log_rel.clone()],
        format!(
            "# Emit Retention Receipt\n\n- retention_verdict: `{retention_verdict}`\n- receipt_ref: `{receipt_rel}`\n- receipt_validation_ref: `{receipt_validation_log_rel}`\n",
        ),
    )?);

    let receipt_yaml = build_fixture_retention_receipt_yaml(
        &retention_run_id,
        &auth_now_rfc3339()?,
        retention_verdict,
        &manifest,
        &fixture_rel,
        &options.purpose,
        &options.owner_scope,
        &options.evidence_refs,
        &fixture_scope_roots,
        &retained_entries,
        &path_set_digest,
        &git_status_digest,
        &source_digests,
        &generated_artifact_refs,
        &receipt_validation_log_rel,
        &blocker,
        &stages,
    );
    fs::write(&receipt_path, receipt_yaml)?;

    let receipt_validation = run_terminal_validator(
        &repo_root,
        &bundle_root,
        "fixture-retention-receipt-validation",
        ".octon/framework/assurance/runtime/_ops/scripts/validate-fixture-retention-closeout-receipt.sh",
        &[String::from("--receipt"), receipt_rel.clone()],
    )?;
    let final_verdict = if retention_verdict == "retained" && receipt_validation.success {
        "retained"
    } else {
        "blocked"
    };
    fs::write(
        &summary_report,
        format!(
            "# Fixture Retention Closeout Summary\n\n- workflow_id: `{FIXTURE_RETENTION_CLOSEOUT_WORKFLOW_ID}`\n- fixture_path: `{fixture_rel}`\n- proposal_id: `{}`\n- proposal_kind: `{}`\n- final_verdict: `{final_verdict}`\n- bundle_root: `{}`\n- retention_receipt: `{receipt_rel}`\n- retained_path_set_digest: `{}`\n- git_status_digest: `{}`\n- receipt_validation: `{}`\n",
            manifest.proposal_id,
            manifest.proposal_kind,
            rel_path(&repo_root, &bundle_root),
            path_set_digest,
            git_status_digest,
            receipt_validation.log_rel
        ),
    )?;

    finalize_execution(
        &workflow_artifacts,
        &workflow_request,
        &workflow_grant,
        &workflow_effects,
        &started_at,
        &ExecutionOutcome {
            status: "succeeded".to_string(),
            started_at: started_at.clone(),
            completed_at: auth_now_rfc3339()?,
            error: None,
        },
        &SideEffectSummary {
            touched_scope: vec![
                bundle_root.display().to_string(),
                summary_report.display().to_string(),
            ],
            ..SideEffectSummary::default()
        },
    )?;

    Ok(RunProposalOperationResult {
        bundle_root,
        summary_report,
        final_verdict: final_verdict.to_string(),
    })
}

fn default_terminal_closeout_profile(
    manifest: &ProposalManifest,
    proposal_rel: &str,
    target_outcome: &str,
    terminal_run_id: &str,
) -> String {
    format!(
        r#"schema_version: proposal-packet-terminal-closeout-profile-v1
profile_id: proposal-packet-terminal-closeout-{profile_slug}
created_at: "{created_at}"
packet:
  proposal_id: {proposal_id}
  path: {proposal_path}
  expected_status: implemented
target_outcome: {target_outcome}
route_preference: none-closeout-only
pr_policy:
  allow_pr_creation: false
  allow_branch_no_pr: false
  exact_sha_required: true
publication_freshness_policy:
  canonical_publisher_only: true
  direct_generated_edits_forbidden: true
  validator_family_map:
    - target_family: publication
      validators:
        - validate-generated-non-authority.sh
        - validate-run-health-read-model.sh
        - validate-capability-publication-state.sh
        - validate-extension-publication-state.sh
hygiene_policy:
  repo_hygiene_delegation_only: true
  worktree_foreign_residue_blocks_archive_ready: true
  cleanup_authorization_required: true
expected_retained_evidence:
  - evidence_id: implementation-conformance
    required: true
    owner: proposal-packet
    path_pattern: "{proposal_path}/support/implementation-conformance-review.md"
  - evidence_id: post-implementation-drift
    required: true
    owner: proposal-packet
    path_pattern: "{proposal_path}/support/post-implementation-drift-churn-review.md"
required_validators_by_target_family:
  - target_family: terminal-closeout
    validators:
      - validate-proposal-implementation-conformance.sh
      - validate-proposal-post-implementation-drift.sh
      - validate-proposal-packet-terminal-closeout-receipt.sh
post_integration_architecture_review_policy:
  run_when_applicable: true
  evidence_only: true
packet_terminal_evaluator_policy:
  required_for:
    - blocked
    - nonterminal
    - cancelled
    - rollback
    - repeated-retry
  evidence_only: true
git_github_hosted_check_policy:
  delegate_to_closeout_routes: true
  exact_sha_required_when_hosted: true
  landing_authorization_required: true
  branch_cleanup_authorization_required: true
blocker_reporting:
  required: true
  allowed_blocker_classes:
    - none
    - missing-evidence
    - stale-evidence
    - validator-failed
    - publication-freshness-blocked
    - hygiene-blocked
    - git-route-blocked
    - scope-overrun
    - archive-boundary-violation
  allowed_next_routes:
    - archive-proposal
    - promote-proposal
    - run-packet-implementation
    - run-packet-verification-and-correction-loop
    - repo-hygiene-cleanup
    - closeout-worktree
    - closeout-change
    - blocked
    - manual-intervention
forbidden_authority_requests:
  archive_relocation: false
  proposal_status_mutation: false
  generated_direct_publication: false
  git_mutation: false
  residue_deletion: false
  host_state_authority: false
  chat_or_model_memory_authority: false
  tool_authority: false
"#,
        profile_slug = slugify(terminal_run_id),
        created_at = now_rfc3339().unwrap_or_else(|_| "1970-01-01T00:00:00Z".to_string()),
        proposal_id = manifest.proposal_id,
        proposal_path = proposal_rel,
        target_outcome = target_outcome
    )
}

fn run_terminal_validator(
    repo_root: &Path,
    bundle_root: &Path,
    log_name: &str,
    script_rel: &str,
    args: &[String],
) -> Result<TerminalValidationResult> {
    let log_path = bundle_root
        .join("stage-logs")
        .join(format!("{log_name}.log"));
    let log_rel = rel_path(repo_root, &log_path);
    let command = if args.is_empty() {
        format!("bash {script_rel}")
    } else {
        format!("bash {} {}", script_rel, args.join(" "))
    };
    let script = repo_root.join(script_rel);
    if !script.is_file() {
        fs::write(
            &log_path,
            format!(
                "# Terminal Closeout Validator\n\n- command: `{}`\n- status: `missing-script`\n- script: `{}`\n",
                command,
                script.display()
            ),
        )?;
        return Ok(TerminalValidationResult {
            command,
            log_rel,
            success: false,
        });
    }
    let output = Command::new("bash")
        .arg(&script)
        .args(args)
        .current_dir(repo_root)
        .output()
        .with_context(|| format!("run terminal closeout validator {script_rel}"))?;
    fs::write(
        &log_path,
        format!(
            "# Terminal Closeout Validator\n\n- command: `{}`\n- status: `{}`\n\n## stdout\n\n```\n{}\n```\n\n## stderr\n\n```\n{}\n```\n",
            command,
            output.status,
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr)
        ),
    )?;
    Ok(TerminalValidationResult {
        command,
        log_rel,
        success: output.status.success(),
    })
}

fn write_terminal_stage_record(
    runtime_cfg: &RuntimeConfig,
    policy: &PolicyEngine,
    repo_root: &Path,
    bundle_root: &Path,
    workflow_request_id: &str,
    state_id: &str,
    write_repo: bool,
    state_verdict: &str,
    input_refs: Vec<String>,
    validator_command_refs: Vec<String>,
    output_refs: Vec<String>,
    report_body: String,
) -> Result<TerminalStageRecord> {
    let stage = authorize_workflow_stage(
        runtime_cfg,
        policy,
        bundle_root,
        TERMINAL_CLOSEOUT_WORKFLOW_ID,
        workflow_request_id,
        state_id,
        "execute_stage",
        &format!("{TERMINAL_CLOSEOUT_WORKFLOW_ID}::{state_id}"),
        if write_repo {
            vec![
                "workflow.stage.execute".to_string(),
                "repo.write".to_string(),
                "evidence.write".to_string(),
            ]
        } else {
            vec![
                "workflow.stage.execute".to_string(),
                "evidence.write".to_string(),
            ]
        },
        vec![bundle_root.display().to_string()],
        true,
        write_repo,
        if write_repo { "medium" } else { "low" },
        Some(if write_repo {
            "scoped_repo_mutation"
        } else {
            "read_only_analysis"
        }),
        None,
        None,
    )?;
    let input_path = bundle_root
        .join("stage-inputs")
        .join(format!("{state_id}-packet.md"));
    fs::write(
        &input_path,
        format!(
            "# Stage Input: {state_id}\n\n## Input Refs\n\n{}\n\n## Validator Commands\n\n{}\n",
            terminal_bullets(&input_refs),
            terminal_bullets(&validator_command_refs)
        ),
    )?;
    let report_path = bundle_root
        .join("reports")
        .join(format!("{state_id}-report.md"));
    fs::write(&report_path, report_body)?;
    finalize_workflow_stage(
        &stage,
        "succeeded",
        None,
        vec![report_path.display().to_string()],
    )?;
    let mut outputs = vec![
        rel_path(repo_root, &report_path),
        rel_path(repo_root, &stage.artifacts.root.join("outcome.json")),
    ];
    outputs.extend(output_refs);
    outputs.sort();
    outputs.dedup();
    Ok(TerminalStageRecord {
        state_id: state_id.to_string(),
        input_refs,
        validator_command_refs,
        output_evidence_refs: outputs,
        state_verdict: state_verdict.to_string(),
    })
}

fn classify_terminal_worktree(
    repo_root: &Path,
    bundle_root: &Path,
    proposal_rel: &str,
    manifest: &ProposalManifest,
    workflow_request_id: &str,
) -> Result<TerminalWorktreeClassification> {
    let fixture_coverage = load_valid_fixture_retention_coverage(repo_root)?;
    let output = Command::new("git")
        .args(["status", "--porcelain=v1", "--untracked-files=all"])
        .current_dir(repo_root)
        .output()
        .context("run git status --porcelain for terminal closeout")?;
    let stdout = String::from_utf8_lossy(&output.stdout);
    let mut in_scope = Vec::<String>::new();
    let mut retained_fixture = Vec::<String>::new();
    let mut foreign = Vec::<String>::new();
    for line in stdout.lines() {
        if line.len() < 4 {
            continue;
        }
        let status = line[0..2].trim().to_string();
        let raw_path = line[3..].trim();
        let path = raw_path
            .rsplit(" -> ")
            .next()
            .unwrap_or(raw_path)
            .trim()
            .to_string();
        if terminal_path_in_scope(&path, proposal_rel, manifest)
            || terminal_current_run_acp_decision_log_append(
                repo_root,
                &path,
                &status,
                workflow_request_id,
            )?
        {
            in_scope.push(path);
        } else if fixture_coverage
            .by_path
            .get(&path)
            .map(|(covered_status, _)| covered_status == &status)
            .unwrap_or(false)
        {
            let receipt_ref = fixture_coverage
                .by_path
                .get(&path)
                .map(|(_, receipt_ref)| receipt_ref.clone())
                .unwrap_or_else(|| "unknown-fixture-retention-receipt".to_string());
            retained_fixture.push(format!("{status} {path} (receipt: {receipt_ref})"));
        } else {
            foreign.push(path);
        }
    }
    let retained_fixture_receipt_refs = fixture_coverage
        .receipt_refs
        .iter()
        .cloned()
        .collect::<Vec<_>>();
    let report_path = bundle_root.join("reports/worktree-hygiene-classification.md");
    let report_body = format!(
        "# Worktree Hygiene Classification\n\n- git_status_exit: `{}`\n- in_scope_path_count: `{}`\n- retained_fixture_path_count: `{}`\n- fixture_retention_receipt_count: `{}`\n- fixture_retention_ambiguous_path_count: `{}`\n- foreign_or_ambiguous_count: `{}`\n- dirty_worktree: `{}`\n\n## In Scope\n\n{}\n\n## Retained Fixture Evidence\n\n{}\n\n## Fixture Retention Receipts\n\n{}\n\n## Ambiguous Fixture Retention Coverage\n\n{}\n\n## Foreign Or Ambiguous\n\n{}\n",
        output.status,
        in_scope.len(),
        retained_fixture.len(),
        retained_fixture_receipt_refs.len(),
        fixture_coverage.ambiguous_paths.len(),
        foreign.len(),
        !foreign.is_empty(),
        terminal_bullets(&in_scope),
        terminal_bullets(&retained_fixture),
        terminal_bullets(&retained_fixture_receipt_refs),
        terminal_bullets(
            &fixture_coverage
                .ambiguous_paths
                .iter()
                .cloned()
                .collect::<Vec<_>>()
        ),
        terminal_bullets(&foreign)
    );
    fs::write(&report_path, &report_body)?;
    Ok(TerminalWorktreeClassification {
        report_rel: rel_path(repo_root, &report_path),
        report_body,
        foreign_or_ambiguous_count: foreign.len(),
        retained_fixture_path_count: retained_fixture.len(),
        retained_fixture_receipt_refs,
        dirty_worktree: !foreign.is_empty(),
    })
}

fn terminal_path_in_scope(path: &str, proposal_rel: &str, manifest: &ProposalManifest) -> bool {
    let proposal_validation_prefix = format!(
        ".octon/state/evidence/validation/proposals/{}/",
        manifest.proposal_id
    );
    path == proposal_rel
        || path.starts_with(&format!("{proposal_rel}/"))
        || path.starts_with(".octon/state/evidence/runs/workflows/")
        || path.starts_with(".octon/state/evidence/control/execution/")
        || path.starts_with(".octon/state/control/execution/runs/")
        || path.starts_with(".octon/state/continuity/runs/")
        || path.starts_with(".octon/state/evidence/external-index/runs/")
        || path.starts_with(&proposal_validation_prefix)
        || manifest.promotion_targets.iter().any(|target| {
            path == target || path.starts_with(&format!("{}/", target.trim_end_matches('/')))
        })
}

fn terminal_current_run_acp_decision_log_append(
    repo_root: &Path,
    path: &str,
    status: &str,
    workflow_request_id: &str,
) -> Result<bool> {
    if path != ".octon/state/evidence/decisions/repo/capabilities/acp-decisions.jsonl"
        || status != "M"
        || workflow_request_id.trim().is_empty()
    {
        return Ok(false);
    }
    let tracked = Command::new("git")
        .args(["ls-files", "--error-unmatch", "--", path])
        .current_dir(repo_root)
        .output()
        .with_context(|| format!("check tracked status for {path}"))?;
    if !tracked.status.success() {
        return Ok(false);
    }
    let diff = Command::new("git")
        .args(["diff", "--unified=0", "--", path])
        .current_dir(repo_root)
        .output()
        .with_context(|| format!("read current ACP decision log diff for {path}"))?;
    if !diff.status.success() {
        return Ok(false);
    }
    Ok(terminal_acp_diff_additions_belong_to_run(
        &String::from_utf8_lossy(&diff.stdout),
        workflow_request_id,
    ))
}

fn terminal_acp_diff_additions_belong_to_run(diff: &str, workflow_request_id: &str) -> bool {
    let mut added_rows = 0usize;
    let stage_prefix = format!("{workflow_request_id}-");
    for line in diff.lines() {
        if line.starts_with("---") || line.starts_with("+++") {
            continue;
        }
        if line.starts_with('-') {
            return false;
        }
        if !line.starts_with('+') {
            continue;
        }
        added_rows += 1;
        let row = &line[1..];
        let Ok(value) = serde_json::from_str::<serde_json::Value>(row) else {
            return false;
        };
        let Some(run_id) = value.get("run_id").and_then(|value| value.as_str()) else {
            return false;
        };
        if run_id != workflow_request_id && !run_id.starts_with(&stage_prefix) {
            return false;
        }
    }
    added_rows > 0
}

fn load_valid_fixture_retention_coverage(repo_root: &Path) -> Result<FixtureRetentionCoverage> {
    let mut coverage = FixtureRetentionCoverage {
        by_path: BTreeMap::new(),
        receipt_refs: BTreeSet::new(),
        ambiguous_paths: BTreeSet::new(),
    };
    let validator = repo_root.join(
        ".octon/framework/assurance/runtime/_ops/scripts/validate-fixture-retention-closeout-receipt.sh",
    );
    if !validator.is_file() {
        return Ok(coverage);
    }
    let workflows_root = repo_root.join(WORKFLOW_REPORTS_ROOT_REL);
    if !workflows_root.is_dir() {
        return Ok(coverage);
    }
    for entry in WalkDir::new(&workflows_root)
        .follow_links(false)
        .into_iter()
        .filter_map(|entry| entry.ok())
    {
        if !entry.file_type().is_file() || entry.file_name() != OsStr::new("retention-receipt.yml")
        {
            continue;
        }
        let receipt_rel = rel_path(repo_root, entry.path());
        let output = Command::new("bash")
            .arg(&validator)
            .args(["--receipt", &receipt_rel, "--emit-consumption-json"])
            .current_dir(repo_root)
            .output()
            .with_context(|| format!("validate fixture retention receipt {receipt_rel}"))?;
        if !output.status.success() {
            continue;
        }
        let parsed: FixtureRetentionConsumption = serde_json::from_slice(&output.stdout)
            .with_context(|| {
                format!("parse fixture retention consumption JSON for {receipt_rel}")
            })?;
        coverage.receipt_refs.insert(parsed.receipt_ref.clone());
        for retained in parsed.retained_status_entries {
            if coverage.by_path.contains_key(&retained.path) {
                coverage.by_path.remove(&retained.path);
                coverage.ambiguous_paths.insert(retained.path);
            } else if !coverage.ambiguous_paths.contains(&retained.path) {
                coverage
                    .by_path
                    .insert(retained.path, (retained.status, parsed.receipt_ref.clone()));
            }
        }
    }
    Ok(coverage)
}

fn fixture_retention_evidence_ref_allowed(path: &str) -> bool {
    !(path.starts_with(".octon/generated/")
        || path.contains("/generated/")
        || path.ends_with("/support/proposal-closeout.md")
        || path.ends_with("/support/executable-implementation-prompt.md"))
}

fn git_status_entries_for_roots(repo_root: &Path, roots: &[String]) -> Result<Vec<GitStatusEntry>> {
    let mut command = Command::new("git");
    command
        .args(["status", "--porcelain=v1", "--untracked-files=all", "--"])
        .args(roots)
        .current_dir(repo_root);
    let output = command
        .output()
        .context("run git status for fixture retention scope")?;
    ensure!(
        output.status.success(),
        "git status for fixture retention scope failed: {}",
        String::from_utf8_lossy(&output.stderr)
    );
    let mut entries = Vec::new();
    for line in String::from_utf8_lossy(&output.stdout).lines() {
        if line.len() < 4 {
            continue;
        }
        let status = line[0..2].trim().to_string();
        let raw_path = line[3..].trim();
        let path = raw_path
            .rsplit(" -> ")
            .next()
            .unwrap_or(raw_path)
            .trim()
            .trim_end_matches('/')
            .to_string();
        if path.is_empty() {
            continue;
        }
        entries.push(GitStatusEntry { status, path });
    }
    entries.sort_by(|left, right| {
        left.path
            .cmp(&right.path)
            .then(left.status.cmp(&right.status))
    });
    entries.dedup_by(|left, right| left.path == right.path && left.status == right.status);
    Ok(entries)
}

fn digest_lines<'a>(values: impl Iterator<Item = &'a str>) -> String {
    let mut lines = values.map(ToString::to_string).collect::<Vec<_>>();
    lines.sort();
    let joined = if lines.is_empty() {
        String::new()
    } else {
        format!("{}\n", lines.join("\n"))
    };
    format!("sha256:{}", hex::encode(Sha256::digest(joined.as_bytes())))
}

fn fixture_source_digests(
    repo_root: &Path,
    fixture_scope_roots: &[String],
) -> Result<Vec<(String, String)>> {
    let mut digests = Vec::new();
    for root_rel in fixture_scope_roots {
        let root = repo_root.join(root_rel);
        if root.is_file() {
            let digest = format!("sha256:{}", hex::encode(Sha256::digest(fs::read(&root)?)));
            digests.push((root_rel.clone(), digest));
            continue;
        }
        if !root.is_dir() {
            continue;
        }
        for entry in WalkDir::new(&root)
            .follow_links(false)
            .into_iter()
            .filter_map(|entry| entry.ok())
        {
            if !entry.file_type().is_file() {
                continue;
            }
            let path = entry.path();
            let rel = rel_path(repo_root, path);
            let digest = format!("sha256:{}", hex::encode(Sha256::digest(fs::read(path)?)));
            digests.push((rel, digest));
        }
    }
    digests.sort_by(|left, right| left.0.cmp(&right.0));
    digests.dedup_by(|left, right| left.0 == right.0);
    Ok(digests)
}

fn write_fixture_retention_stage_record(
    runtime_cfg: &RuntimeConfig,
    policy: &PolicyEngine,
    repo_root: &Path,
    bundle_root: &Path,
    workflow_request_id: &str,
    state_id: &str,
    state_verdict: &str,
    input_refs: Vec<String>,
    validator_command_refs: Vec<String>,
    output_refs: Vec<String>,
    report_body: String,
) -> Result<FixtureRetentionStageRecord> {
    let stage = authorize_workflow_stage(
        runtime_cfg,
        policy,
        bundle_root,
        FIXTURE_RETENTION_CLOSEOUT_WORKFLOW_ID,
        workflow_request_id,
        state_id,
        "execute_stage",
        &format!("{FIXTURE_RETENTION_CLOSEOUT_WORKFLOW_ID}::{state_id}"),
        vec![
            "workflow.stage.execute".to_string(),
            "evidence.write".to_string(),
        ],
        vec![bundle_root.display().to_string()],
        true,
        false,
        "low",
        Some("read_only_analysis"),
        None,
        None,
    )?;
    let input_path = bundle_root
        .join("stage-inputs")
        .join(format!("{state_id}-fixture.md"));
    fs::write(
        &input_path,
        format!(
            "# Stage Input: {state_id}\n\n## Input Refs\n\n{}\n\n## Validator Commands\n\n{}\n",
            terminal_bullets(&input_refs),
            terminal_bullets(&validator_command_refs)
        ),
    )?;
    let report_path = bundle_root
        .join("reports")
        .join(format!("{state_id}-report.md"));
    fs::write(&report_path, report_body)?;
    finalize_workflow_stage(
        &stage,
        "succeeded",
        None,
        vec![report_path.display().to_string()],
    )?;
    let mut outputs = vec![
        rel_path(repo_root, &report_path),
        rel_path(repo_root, &stage.artifacts.root.join("outcome.json")),
    ];
    outputs.extend(output_refs);
    outputs.sort();
    outputs.dedup();
    Ok(FixtureRetentionStageRecord {
        state_id: state_id.to_string(),
        input_refs,
        validator_command_refs,
        output_evidence_refs: outputs,
        state_verdict: state_verdict.to_string(),
    })
}

fn build_fixture_retention_receipt_yaml(
    retention_run_id: &str,
    retained_at: &str,
    retention_verdict: &str,
    manifest: &ProposalManifest,
    fixture_rel: &str,
    purpose: &str,
    owner_scope: &str,
    evidence_refs: &[String],
    fixture_scope_roots: &[String],
    retained_entries: &[GitStatusEntry],
    retained_path_set_digest: &str,
    git_status_digest: &str,
    source_digests: &[(String, String)],
    generated_artifact_refs: &[String],
    validation_ref: &str,
    blocker: &TerminalBlocker,
    stages: &[FixtureRetentionStageRecord],
) -> String {
    let retained_paths = retained_entries
        .iter()
        .map(|entry| entry.path.clone())
        .collect::<Vec<_>>();
    let retained_status_yaml = if retained_entries.is_empty() {
        "  []\n".to_string()
    } else {
        retained_entries
            .iter()
            .map(|entry| {
                format!(
                    "  - status: {}\n    path: {}\n",
                    terminal_yaml_quote(&entry.status),
                    terminal_yaml_quote(&entry.path)
                )
            })
            .collect::<String>()
    };
    let source_digest_yaml = if source_digests.is_empty() {
        "  []\n".to_string()
    } else {
        source_digests
            .iter()
            .map(|(path, digest)| {
                format!(
                    "  - path: {}\n    digest: {}\n",
                    terminal_yaml_quote(path),
                    terminal_yaml_quote(digest)
                )
            })
            .collect::<String>()
    };
    let generated_artifact_yaml = if generated_artifact_refs.is_empty() {
        "  []\n".to_string()
    } else {
        generated_artifact_refs
            .iter()
            .map(|path| {
                format!(
                    "  - path: {}\n    authority: derived-only-non-authority\n",
                    terminal_yaml_quote(path)
                )
            })
            .collect::<String>()
    };
    format!(
        "schema_version: fixture-retention-closeout-receipt-v1\nroute_id: fixture-retention-closeout\nretention_run_id: {}\nretained_at: {}\nretention_verdict: {}\nfixture:\n  proposal_id: {}\n  proposal_kind: {}\n  path: {}\n  status: {}\n  temporary_lifecycle: {}\n  promotion_targets:\n{}purpose: {}\nowner_scope: {}\nused_as_evidence_for:\n  - {}\nevidence_refs:\n{}fixture_scope:\n  roots:\n{}retained_paths:\n{}retained_status_entries:\n{}retained_path_set_digest: {}\ngit_status_digest: {}\nsource_digests:\n{}generated_artifact_refs:\n{}freshness:\n  mode: current-git-status-and-source-digest-bound\n  status: {}\nvalidation_refs:\n  - {}\nterminal_worktree_hygiene_consumption:\n  allowed: true\n  exact_path_set_match_required: true\n  current_digest_match_required: true\n  schema_route_version_match_required: true\n  purpose_owner_scope_match_required: true\n  all_retained_paths_inside_declared_scope_required: true\n  unrelated_residue_coverage_forbidden: true\n  nonblocking_only_for_unrelated_packet_terminal_readiness: true\n  target_packet_evidence_authority: false\n  purpose: {}\n  owner_scope: {}\n  does_not_authorize:\n    - archive-ready-claim\n    - cleaned-claim\n    - archive-relocation\n    - proposal-status-mutation\n    - generated-publication-edit\n    - git-mutation\n    - repo-hygiene-deletion\n    - target-packet-implementation-evidence\n    - target-packet-conformance-evidence\n    - target-packet-drift-evidence\nauthority_boundaries:\n  archive_relocation: false\n  proposal_status_mutation: false\n  generated_publication_edit: false\n  git_mutation: false\n  residue_deletion: false\n  repo_hygiene_deletion_authority: false\n  target_packet_evidence_authority: false\nblocker:\n  class: {}\n  detail: {}\n  failing_evidence_ref: {}\n  next_canonical_route: {}\nstate_ledger:\n{}",
        terminal_yaml_quote(retention_run_id),
        terminal_yaml_quote(retained_at),
        terminal_yaml_quote(retention_verdict),
        terminal_yaml_quote(&manifest.proposal_id),
        terminal_yaml_quote(&manifest.proposal_kind),
        terminal_yaml_quote(fixture_rel),
        terminal_yaml_quote(&manifest.status),
        if manifest.lifecycle.temporary { "true" } else { "false" },
        terminal_yaml_array(&manifest.promotion_targets, "  "),
        terminal_yaml_quote(purpose),
        terminal_yaml_quote(owner_scope),
        terminal_yaml_quote(purpose),
        terminal_yaml_array(evidence_refs, ""),
        terminal_yaml_array(fixture_scope_roots, "  "),
        terminal_yaml_array(&retained_paths, ""),
        retained_status_yaml,
        terminal_yaml_quote(retained_path_set_digest),
        terminal_yaml_quote(git_status_digest),
        source_digest_yaml,
        generated_artifact_yaml,
        if retention_verdict == "retained" { "fresh" } else { "blocked" },
        terminal_yaml_quote(validation_ref),
        terminal_yaml_quote(purpose),
        terminal_yaml_quote(owner_scope),
        terminal_yaml_quote(&blocker.class),
        terminal_yaml_quote(&blocker.detail),
        terminal_yaml_quote(&blocker.failing_evidence_ref),
        terminal_yaml_quote(&blocker.next_canonical_route),
        fixture_retention_stage_ledger_yaml(stages, "  ")
    )
}

fn fixture_retention_stage_ledger_yaml(
    stages: &[FixtureRetentionStageRecord],
    indent: &str,
) -> String {
    stages
        .iter()
        .map(|stage| {
            format!(
                "{indent}- state_id: {}\n{indent}  input_refs:\n{}{indent}  validator_command_refs:\n{}{indent}  output_evidence_refs:\n{}{indent}  state_verdict: {}\n{indent}  retry_count: 0\n{indent}  resume_cursor: complete\n",
                stage.state_id,
                terminal_yaml_array(&stage.input_refs, &format!("{indent}    ")),
                terminal_yaml_array(&stage.validator_command_refs, &format!("{indent}    ")),
                terminal_yaml_array(&stage.output_evidence_refs, &format!("{indent}    ")),
                stage.state_verdict
            )
        })
        .collect::<String>()
}

fn set_terminal_blocker(
    blocker: &mut Option<TerminalBlocker>,
    class: &str,
    detail: &str,
    failing_evidence_ref: &str,
    next_canonical_route: &str,
) {
    if blocker.is_none() {
        *blocker = Some(TerminalBlocker {
            class: class.to_string(),
            detail: detail.to_string(),
            failing_evidence_ref: failing_evidence_ref.to_string(),
            next_canonical_route: next_canonical_route.to_string(),
        });
    }
}

fn write_terminal_state_ledger(
    repo_root: &Path,
    bundle_root: &Path,
    terminal_run_id: &str,
    workflow_request_id: &str,
    manifest: &ProposalManifest,
    proposal_rel: &str,
    target_outcome: &str,
    profile_rel: &str,
    profile_digest: &str,
    profile_validation_ref: &str,
    stages: &[TerminalStageRecord],
) -> Result<()> {
    let mut body = format!(
        "schema_version: proposal-packet-terminal-closeout-state-ledger-v1\nterminal_run_id: {}\nworkflow_run_id: {}\npacket:\n  proposal_id: {}\n  path: {}\n  proposal_kind: {}\n  status: {}\ntarget_outcome: {}\nprofile:\n  profile_ref: {}\n  profile_digest: {}\n  profile_validation_evidence_ref: {}\nstate_ledger:\n",
        terminal_yaml_quote(terminal_run_id),
        terminal_yaml_quote(workflow_request_id),
        terminal_yaml_quote(&manifest.proposal_id),
        terminal_yaml_quote(proposal_rel),
        terminal_yaml_quote(&manifest.proposal_kind),
        terminal_yaml_quote(&manifest.status),
        terminal_yaml_quote(target_outcome),
        terminal_yaml_quote(profile_rel),
        terminal_yaml_quote(profile_digest),
        terminal_yaml_quote(profile_validation_ref)
    );
    body.push_str(&terminal_stage_ledger_yaml(stages, "  "));
    fs::write(bundle_root.join("state-ledger.yml"), body)
        .with_context(|| format!("write {}", bundle_root.join("state-ledger.yml").display()))?;
    let _ = repo_root;
    Ok(())
}

fn build_terminal_receipt_yaml(
    repo_root: &Path,
    terminal_run_id: &str,
    terminalized_at: &str,
    manifest: &ProposalManifest,
    proposal_rel: &str,
    target_outcome: &str,
    terminal_verdict: &str,
    profile_rel: &str,
    profile_digest: &str,
    profile_validation_ref: &str,
    stages: &[TerminalStageRecord],
    conformance: &TerminalValidationResult,
    drift: &TerminalValidationResult,
    publication_results: &[TerminalValidationResult],
    repo_hygiene_report: &Path,
    worktree: &TerminalWorktreeClassification,
    evidence_review_report: &Path,
    git_route_report: &Path,
    blocker: &TerminalBlocker,
    retained_inventory: &[String],
) -> String {
    let generated_non_authority = publication_results
        .iter()
        .find(|result| {
            result
                .command
                .contains("validate-generated-non-authority.sh")
        })
        .unwrap_or(&publication_results[0]);
    let run_health = publication_results
        .iter()
        .find(|result| result.command.contains("validate-run-health-read-model.sh"))
        .unwrap_or(&publication_results[0]);
    let capability = publication_results
        .iter()
        .find(|result| {
            result
                .command
                .contains("validate-capability-publication-state.sh")
        })
        .unwrap_or(&publication_results[0]);
    let extension = publication_results
        .iter()
        .find(|result| {
            result
                .command
                .contains("validate-extension-publication-state.sh")
        })
        .unwrap_or(&publication_results[0]);
    let repo_hygiene_rel = rel_path(repo_root, repo_hygiene_report);
    let evidence_review_rel = rel_path(repo_root, evidence_review_report);
    let git_route_rel = rel_path(repo_root, git_route_report);
    let publication_validator_yaml = publication_results
        .iter()
        .map(|result| {
            format!(
                "    - validator_ref: {}\n      evidence_ref: {}\n      verdict: {}\n      fresh: {}\n",
                terminal_yaml_quote(&result.command),
                terminal_yaml_quote(&result.log_rel),
                if result.success { "pass" } else { "blocked" },
                if result.success { "true" } else { "false" }
            )
        })
        .collect::<String>();
    format!(
        "schema_version: proposal-packet-terminal-closeout-receipt-v1\nterminal_run_id: {}\nterminalized_at: {}\npacket:\n  proposal_id: {}\n  path: {}\n  proposal_kind: {}\n  status: {}\ntarget_outcome: {}\nterminal_verdict: {}\nprofile:\n  profile_ref: {}\n  profile_digest: {}\n  profile_validation_evidence_ref: {}\nstate_ledger:\n{}implementation:\n  conformance_receipt_ref: {}\n  conformance_validator_ref: {}\n  conformance_fresh: {}\n  post_implementation_drift_receipt_ref: {}\n  post_implementation_drift_validator_ref: {}\n  post_implementation_drift_fresh: {}\ndurable_implementation_state_evidence_refs:\n{}\npublication_freshness:\n  validators:\n{}  publisher_refresh_receipts: []\n  rerun_evidence_refs:\n{}\n  direct_generated_output_edit_used: false\ngenerated_input_non_authority:\n  validation_ref: {}\n  proposal_inputs_non_authority: true\n  generated_outputs_non_authority: true\n  generated_prompts_non_authority: true\n  host_state_non_authority: true\n  chat_state_non_authority: true\n  tool_state_non_authority: true\n  model_memory_non_authority: true\nrun_health:\n  validation_ref: {}\n  verdict: {}\ncapability_publication:\n  validation_ref: {}\n  verdict: {}\nextension_publication:\n  validation_ref: {}\n  verdict: {}\nrepo_hygiene:\n  classification_ref: {}\n  cleanup_performed: false\n  cleanup_authorization_refs: []\n  unauthorized_deletion_performed: false\nworktree_hygiene:\n  classification_ref: {}\n  verdict: {}\n  foreign_or_ambiguous_count: {}\n  retained_fixture_path_count: {}\n  fixture_retention_refs:\n{}  dirty_worktree: {}\nevidence_only_reviews:\n  post_integration_architecture_review_ref: {}\n  post_integration_architecture_review_authority: evidence-only\n  packet_terminal_evaluator_ref: {}\n  packet_terminal_evaluator_authority: evidence-only\n  lifecycle_postmortem_ref: {}\n  lifecycle_postmortem_authority: evidence-only\ngit_github_route:\n  route_ref: {}\n  branch_no_pr: false\n  mutation_delegated: true\n  exact_sha_checks_ref: not-applicable\n  landing_authorization_ref: not-applicable\n  branch_cleanup_required: false\n  branch_cleanup_authorization_ref: not-applicable\narchive_boundary:\n  archive_owner_ref: .octon/framework/orchestration/runtime/workflows/meta/archive-proposal/workflow.yml\n  relocation_performed: false\nblocker:\n  class: {}\n  detail: {}\n  failing_evidence_ref: {}\n  next_canonical_route: {}\nretained_evidence_inventory:\n{}\nexpected_no_new_evidence_loop: true\nnon_authority_declarations:\n  proposal_inputs: non-authority\n  generated_outputs: derived-only-non-authority\n  generated_prompts: non-authority\n  host_state: non-authority\n  dashboards: non-authority\n  chat: non-authority\n  tool_state: non-authority\n  model_memory: non-authority\ntarget_owned_evidence_policy:\n  cites_target_owned_evidence: true\n  aggregate_receipt_replaces_target_owned_receipts: false\n",
        terminal_yaml_quote(terminal_run_id),
        terminal_yaml_quote(terminalized_at),
        terminal_yaml_quote(&manifest.proposal_id),
        terminal_yaml_quote(proposal_rel),
        terminal_yaml_quote(&manifest.proposal_kind),
        terminal_yaml_quote(&manifest.status),
        terminal_yaml_quote(target_outcome),
        terminal_yaml_quote(terminal_verdict),
        terminal_yaml_quote(profile_rel),
        terminal_yaml_quote(profile_digest),
        terminal_yaml_quote(profile_validation_ref),
        terminal_stage_ledger_yaml(stages, "  "),
        terminal_yaml_quote(&format!("{proposal_rel}/support/implementation-conformance-review.md")),
        terminal_yaml_quote(&conformance.log_rel),
        if conformance.success { "true" } else { "false" },
        terminal_yaml_quote(&format!(
            "{proposal_rel}/support/post-implementation-drift-churn-review.md"
        )),
        terminal_yaml_quote(&drift.log_rel),
        if drift.success { "true" } else { "false" },
        terminal_yaml_array(&[
            format!("{proposal_rel}/proposal.yml"),
            format!("{proposal_rel}/support/implementation-run.md"),
            format!("{proposal_rel}/support/proposal-closeout.md")
        ], "  "),
        publication_validator_yaml,
        terminal_yaml_array(
            &publication_results
                .iter()
                .map(|result| result.log_rel.clone())
                .collect::<Vec<_>>(),
            "  "
        ),
        terminal_yaml_quote(&generated_non_authority.log_rel),
        terminal_yaml_quote(&run_health.log_rel),
        if run_health.success { "pass" } else { "blocked" },
        terminal_yaml_quote(&capability.log_rel),
        if capability.success { "pass" } else { "blocked" },
        terminal_yaml_quote(&extension.log_rel),
        if extension.success { "pass" } else { "blocked" },
        terminal_yaml_quote(&repo_hygiene_rel),
        terminal_yaml_quote(&worktree.report_rel),
        if worktree.foreign_or_ambiguous_count == 0 {
            "pass"
        } else {
            "blocked"
        },
        worktree.foreign_or_ambiguous_count,
        worktree.retained_fixture_path_count,
        terminal_yaml_array_or_empty(&worktree.retained_fixture_receipt_refs, "  "),
        if worktree.dirty_worktree { "true" } else { "false" },
        terminal_yaml_quote(&evidence_review_rel),
        terminal_yaml_quote(&evidence_review_rel),
        terminal_yaml_quote(&evidence_review_rel),
        terminal_yaml_quote(&git_route_rel),
        terminal_yaml_quote(&blocker.class),
        terminal_yaml_quote(&blocker.detail),
        terminal_yaml_quote(&blocker.failing_evidence_ref),
        terminal_yaml_quote(&blocker.next_canonical_route),
        terminal_yaml_array(retained_inventory, "")
    )
}

fn terminal_stage_ledger_yaml(stages: &[TerminalStageRecord], indent: &str) -> String {
    stages
        .iter()
        .map(|stage| {
            format!(
                "{indent}- state_id: {}\n{indent}  input_refs:\n{}{indent}  validator_command_refs:\n{}{indent}  output_evidence_refs:\n{}{indent}  state_verdict: {}\n{indent}  retry_count: 0\n{indent}  resume_cursor: complete\n",
                stage.state_id,
                terminal_yaml_array(&stage.input_refs, &format!("{indent}    ")),
                terminal_yaml_array(&stage.validator_command_refs, &format!("{indent}    ")),
                terminal_yaml_array(&stage.output_evidence_refs, &format!("{indent}    ")),
                stage.state_verdict
            )
        })
        .collect::<String>()
}

fn terminal_yaml_array(values: &[String], indent: &str) -> String {
    if values.is_empty() {
        return format!("{indent}- not-applicable\n");
    }
    values
        .iter()
        .map(|value| format!("{indent}- {}\n", terminal_yaml_quote(value)))
        .collect()
}

fn terminal_yaml_array_or_empty(values: &[String], indent: &str) -> String {
    if values.is_empty() {
        return format!("{indent}  []\n");
    }
    terminal_yaml_array(values, indent)
}

fn terminal_bullets(values: &[String]) -> String {
    if values.is_empty() {
        return "- none".to_string();
    }
    values
        .iter()
        .map(|value| format!("- `{value}`"))
        .collect::<Vec<_>>()
        .join("\n")
}

fn terminal_yaml_quote(value: &str) -> String {
    format!("\"{}\"", value.replace('\\', "\\\\").replace('"', "\\\""))
}

pub fn run_archive_proposal_from_octon_dir(
    octon_dir: &Path,
    options: RunArchiveProposalOptions,
) -> Result<RunProposalOperationResult> {
    let runtime_cfg = ConfigLoader::load(octon_dir)?;
    let policy = PolicyEngine::new(runtime_cfg.clone());
    let repo_root = octon_dir
        .parent()
        .context("failed to resolve repository root from .octon directory")?
        .canonicalize()
        .context("failed to canonicalize repository root")?;
    let proposal_root = if options.proposal_path.is_absolute() {
        options.proposal_path.clone()
    } else {
        repo_root.join(&options.proposal_path)
    };
    let proposal_rel = rel_path(&repo_root, &proposal_root);
    let workflow_request_id = resolve_requested_workflow_run_id(
        &runtime_cfg,
        options.run_id.as_deref(),
        "archive-proposal",
        options.resume_existing,
    )?;

    let reports_root = repo_root.join(REPORTS_ROOT_REL);
    let workflow_bundles_root = repo_root.join(WORKFLOW_REPORTS_ROOT_REL);
    let (intent_ref, execution_role_ref, metadata) = request::bind_repo_local_request(
        &runtime_cfg,
        BTreeMap::from([("workflow_id".to_string(), "archive-proposal".to_string())]),
    )?;
    let workflow_request = ExecutionRequest {
        request_id: workflow_request_id,
        caller_path: "workflow".to_string(),
        action_type: "execute_workflow".to_string(),
        target_id: "archive-proposal".to_string(),
        requested_capabilities: vec![
            "workflow.execute".to_string(),
            "repo.write".to_string(),
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
        review_requirements: ReviewRequirements::default(),
        scope_constraints: ScopeConstraints {
            read: vec!["workflow-scope".to_string()],
            write: vec![
                proposal_root.display().to_string(),
                reports_root.display().to_string(),
                workflow_bundles_root.display().to_string(),
            ],
            executor_profile: None,
            locality_scope: None,
        },
        policy_mode_requested: None,
        environment_hint: None,
        metadata,
        ..ExecutionRequest::default()
    };
    let workflow_grant = authorize_execution(&runtime_cfg, &policy, &workflow_request, None)?;
    fs::create_dir_all(&reports_root)?;
    fs::create_dir_all(&workflow_bundles_root)?;
    let date = today_string()?;
    let started_at = auth_now_rfc3339()?;
    let bundle_root = unique_directory(
        &workflow_bundles_root,
        &format!("{date}-archive-proposal-{}", slugify(&proposal_rel)),
    )?;
    fs::create_dir_all(bundle_root.join("reports"))?;
    fs::create_dir_all(bundle_root.join("stage-inputs"))?;
    fs::create_dir_all(bundle_root.join("stage-logs"))?;
    let workflow_artifact_root = bundle_root.join("workflow-execution");
    let workflow_effects = artifact_effects_for_root(&workflow_artifact_root, &workflow_grant)?;
    let workflow_artifacts = write_execution_start(
        &workflow_artifact_root,
        &workflow_request,
        &workflow_grant,
        &workflow_effects,
    )?;
    let summary_report = unique_file(&reports_root, &format!("{date}-archive-proposal"), "md")?;

    let active_identity = parse_active_proposal_rel(&proposal_rel);
    let (mut manifest, validation_root, recovered_partial_archive) = if proposal_root.is_dir() {
        let manifest = load_proposal_manifest(&proposal_root)?;
        ensure!(
            proposal_rel
                == expected_active_proposal_rel(&manifest.proposal_kind, &manifest.proposal_id),
            "proposal must be archived from the active path: {}",
            proposal_rel
        );
        ensure!(
            manifest.status != "archived",
            "proposal is already archived: {}",
            proposal_rel
        );
        (manifest, proposal_root.clone(), false)
    } else if let Some((proposal_kind, proposal_id)) = active_identity {
        let archived_rel = expected_archived_proposal_rel(&proposal_kind, &proposal_id);
        let archived_root = repo_root.join(&archived_rel);
        if !archived_root.is_dir() {
            let message = format!("target proposal not found: {}", proposal_root.display());
            let _ = finalize_workflow_failure(
                &workflow_artifacts,
                &workflow_request,
                &workflow_grant,
                &started_at,
                message.clone(),
                vec![
                    bundle_root.display().to_string(),
                    proposal_root.display().to_string(),
                ],
            );
            bail!(message);
        }
        let manifest = load_proposal_manifest(&archived_root)?;
        validate_partial_archive_recovery(
            &manifest,
            &proposal_kind,
            &proposal_id,
            &proposal_rel,
            &options.disposition,
            &options.promotion_evidence,
        )?;
        (manifest, archived_root, true)
    } else {
        let message = format!("target proposal not found: {}", proposal_root.display());
        let _ = finalize_workflow_failure(
            &workflow_artifacts,
            &workflow_request,
            &workflow_grant,
            &started_at,
            message.clone(),
            vec![
                bundle_root.display().to_string(),
                proposal_root.display().to_string(),
            ],
        );
        bail!(message);
    };

    validate_archive_disposition(
        &repo_root,
        &manifest,
        &options.disposition,
        &options.promotion_evidence,
        recovered_partial_archive,
    )?;

    let stage_validate = authorize_workflow_stage(
        &runtime_cfg,
        &policy,
        &bundle_root,
        "archive-proposal",
        &workflow_request.request_id,
        "validate-proposal",
        "execute_stage",
        "archive-proposal::validate-proposal",
        vec![
            "workflow.stage.execute".to_string(),
            "evidence.write".to_string(),
        ],
        vec![
            bundle_root
                .join("standard-validator.log")
                .display()
                .to_string(),
            bundle_root
                .join("stages/validate-proposal")
                .display()
                .to_string(),
        ],
        true,
        false,
        "low",
        Some("read_only_analysis"),
        None,
        None,
    )?;
    let validator_log = match run_archive_proposal_validator_stack(
        &repo_root,
        &validation_root,
        &bundle_root,
        &manifest.proposal_kind,
    ) {
        Ok(path) => path,
        Err(error) => {
            let _ = finalize_workflow_stage(
                &stage_validate,
                "failed",
                Some(error.to_string()),
                vec![bundle_root
                    .join("standard-validator.log")
                    .display()
                    .to_string()],
            );
            let _ = finalize_workflow_failure(
                &workflow_artifacts,
                &workflow_request,
                &workflow_grant,
                &started_at,
                error.to_string(),
                vec![
                    bundle_root.display().to_string(),
                    proposal_root.display().to_string(),
                ],
            );
            return Err(error);
        }
    };
    finalize_workflow_stage(
        &stage_validate,
        "succeeded",
        None,
        vec![rel_path(&repo_root, &validator_log)],
    )?;

    let archived_from_status = manifest
        .archive
        .as_ref()
        .map(|archive| archive.archived_from_status.clone())
        .unwrap_or_else(|| manifest.status.clone());
    let archived_rel =
        expected_archived_proposal_rel(&manifest.proposal_kind, &manifest.proposal_id);
    let archived_root = repo_root.join(&archived_rel);
    let stage_archive = authorize_workflow_stage(
        &runtime_cfg,
        &policy,
        &bundle_root,
        "archive-proposal",
        &workflow_request.request_id,
        "archive-proposal",
        "execute_stage",
        "archive-proposal::archive-proposal",
        vec![
            "workflow.stage.execute".to_string(),
            "repo.write".to_string(),
            "evidence.write".to_string(),
        ],
        vec![
            proposal_root.display().to_string(),
            archived_root.display().to_string(),
            bundle_root
                .join("stages/archive-proposal")
                .display()
                .to_string(),
        ],
        false,
        true,
        "medium",
        Some("scoped_repo_mutation"),
        None,
        None,
    )?;
    let archive_result: Result<()> = (|| {
        if recovered_partial_archive {
            ensure!(
                archived_root.is_dir(),
                "partial archive recovery requires archived destination: {}",
                archived_root.display()
            );
            ensure!(
                !proposal_root.exists(),
                "partial archive recovery requires absent active source: {}",
                proposal_root.display()
            );
        } else {
            ensure!(
                !archived_root.exists(),
                "archive destination already exists: {}",
                archived_root.display()
            );
            if let Some(parent) = archived_root.parent() {
                fs::create_dir_all(parent)
                    .with_context(|| format!("create {}", parent.display()))?;
            }
            fs::rename(&proposal_root, &archived_root).with_context(|| {
                format!(
                    "move proposal from {} to {}",
                    proposal_root.display(),
                    archived_root.display()
                )
            })?;
            manifest.status = "archived".to_string();
            manifest.archive = Some(ProposalArchiveMetadata {
                archived_at: today_string()?,
                archived_from_status,
                disposition: options.disposition.clone(),
                original_path: proposal_rel.clone(),
                promotion_evidence: options.promotion_evidence.clone(),
            });
        }
        write_proposal_manifest(&archived_root, &manifest)?;
        fs::write(
            archived_root.join("navigation/artifact-catalog.md"),
            build_artifact_catalog(
                &archived_root,
                &manifest.proposal_kind,
                &manifest.proposal_id,
                &archived_rel,
            )?,
        )?;
        ensure_archive_gitignore_allowlist(&repo_root, &archived_rel)?;
        regenerate_proposal_artifact_index(&repo_root, &archived_rel)?;
        regenerate_proposal_registry(&repo_root, true)?;
        Ok(())
    })();
    if let Err(error) = archive_result {
        let _ = finalize_workflow_stage(
            &stage_archive,
            "failed",
            Some(error.to_string()),
            vec![archived_root.display().to_string()],
        );
        let _ = finalize_workflow_failure(
            &workflow_artifacts,
            &workflow_request,
            &workflow_grant,
            &started_at,
            error.to_string(),
            vec![
                bundle_root.display().to_string(),
                proposal_root.display().to_string(),
            ],
        );
        return Err(error);
    }
    finalize_workflow_stage(
        &stage_archive,
        "succeeded",
        None,
        vec![
            archived_rel.clone(),
            ".gitignore".to_string(),
            format!(
                ".octon/generated/proposals/artifacts/{}/{}/proposal-artifact-index.yml",
                manifest.proposal_kind, manifest.proposal_id
            ),
            format!(
                ".octon/generated/proposals/artifacts/{}/{}/proposal-program-spine.yml",
                manifest.proposal_kind, manifest.proposal_id
            ),
            ".octon/generated/proposals/registry.yml".to_string(),
        ],
    )?;

    write_create_inventory(&bundle_root, &archived_root)?;
    write_create_commands_log(
        &bundle_root,
        &[
            format!(
                "- validate proposal before archive | proposal_path={} | validator_log={}",
                proposal_rel,
                rel_path(&repo_root, &validator_log)
            ),
            format!(
                "- archive proposal | from={} | to={} | disposition={} | promotion_evidence={}",
                proposal_rel,
                archived_rel,
                options.disposition,
                options.promotion_evidence.join(", ")
            ),
        ],
    )?;
    let summary = format!(
        "# Archive Proposal Summary\n\n- workflow_id: `archive-proposal`\n- proposal_path: `{}`\n- archived_path: `{}`\n- proposal_kind: `{}`\n- final_verdict: `archived`\n- bundle_root: `{}`\n- summary_report: `{}`\n- validator_log: `{}`\n- disposition: `{}`\n",
        proposal_rel,
        archived_rel,
        manifest.proposal_kind,
        rel_path(&repo_root, &bundle_root),
        rel_path(&repo_root, &summary_report),
        rel_path(&repo_root, &validator_log),
        options.disposition
    );
    fs::write(bundle_root.join("summary.md"), &summary)?;
    fs::write(&summary_report, summary)?;
    fs::write(
        bundle_root.join("validation.md"),
        format!(
            "# Validation\n\n- final_verdict: `archived`\n- proposal_kind: `{}`\n- validator_log: `{}`\n- archived_path: `{}`\n- registry_sync: `passed`\n",
            manifest.proposal_kind,
            rel_path(&repo_root, &validator_log),
            archived_rel
        ),
    )?;
    fs::write(
        bundle_root.join("bundle.yml"),
        serde_yaml::to_string(&BundleMetadata {
            kind: "workflow-execution-bundle".to_string(),
            id: bundle_root
                .file_name()
                .and_then(|v| v.to_str())
                .unwrap_or("workflow-bundle")
                .to_string(),
            workflow_id: "archive-proposal".to_string(),
            package_path: archived_rel.clone(),
            mode: "n/a".to_string(),
            executor: "n/a".to_string(),
            prepare_only: false,
            slug: slugify(&archived_rel),
            started_at: started_at.clone(),
            completed_at: auth_now_rfc3339()?,
            summary: "summary.md".to_string(),
            reports_dir: "reports".to_string(),
            stage_inputs_dir: "stage-inputs".to_string(),
            stage_logs_dir: "stage-logs".to_string(),
            selected_stages: vec![
                "validate-proposal".to_string(),
                "archive-proposal".to_string(),
                "report".to_string(),
            ],
            report_paths: BTreeMap::new(),
            changed_files: BTreeMap::new(),
            plan: "plan.md".to_string(),
            inventory: "inventory.md".to_string(),
            commands: "commands.md".to_string(),
            validation: "validation.md".to_string(),
            summary_report: rel_path(&repo_root, &summary_report),
            final_verdict: "archived".to_string(),
            failure_class: None,
            failed_stage: None,
        })?,
    )?;
    finalize_execution(
        &workflow_artifacts,
        &workflow_request,
        &workflow_grant,
        &workflow_effects,
        &started_at,
        &ExecutionOutcome {
            status: "succeeded".to_string(),
            started_at: started_at.clone(),
            completed_at: auth_now_rfc3339()?,
            error: None,
        },
        &SideEffectSummary {
            touched_scope: vec![
                bundle_root.display().to_string(),
                archived_root.display().to_string(),
                repo_root
                    .join(".octon/generated/proposals/registry.yml")
                    .display()
                    .to_string(),
            ],
            ..SideEffectSummary::default()
        },
    )?;

    Ok(RunProposalOperationResult {
        bundle_root,
        summary_report,
        final_verdict: "archived".to_string(),
    })
}

impl Runner {
    fn new(octon_dir: &Path, options: RunDesignPackageOptions) -> Result<Self> {
        let runtime_cfg = ConfigLoader::load(octon_dir)?;
        let repo_root = octon_dir
            .parent()
            .context("failed to resolve repository root from .octon directory")?
            .canonicalize()
            .context("failed to canonicalize repository root")?;

        let target_package = resolve_repo_relative_path(&repo_root, &options.package_path)?;
        if !target_package.starts_with(&repo_root) {
            bail!(
                "target package must live inside the repository root: {}",
                target_package.display()
            );
        }
        if !target_package.is_dir() {
            bail!("target package not found: {}", target_package.display());
        }

        let workflow_root = repo_root.join(WORKFLOW_ROOT_REL);
        let reports_root = repo_root.join(REPORTS_ROOT_REL);
        let workflow_bundles_root = repo_root.join(WORKFLOW_REPORTS_ROOT_REL);
        fs::create_dir_all(&reports_root)
            .with_context(|| format!("create reports root {}", reports_root.display()))?;
        fs::create_dir_all(&workflow_bundles_root).with_context(|| {
            format!(
                "create workflow bundles root {}",
                workflow_bundles_root.display()
            )
        })?;

        let date = today_string()?;
        let started_at = now_rfc3339()?;
        let target_slug = slugify(&options.output_slug.clone().unwrap_or_else(|| {
            target_package
                .file_name()
                .and_then(OsStr::to_str)
                .unwrap_or("design-package")
                .to_string()
        }));

        let bundle_root = unique_directory(
            &workflow_bundles_root,
            &format!("{date}-{WORKFLOW_ID}-{target_slug}"),
        )?;
        let reports_dir = bundle_root.join("reports");
        let stage_inputs_dir = bundle_root.join("stage-inputs");
        let stage_logs_dir = bundle_root.join("stage-logs");
        fs::create_dir_all(&reports_dir)?;
        fs::create_dir_all(&stage_inputs_dir)?;
        fs::create_dir_all(&stage_logs_dir)?;

        let summary_report = unique_file(
            &reports_root,
            &format!("{date}-audit-design-proposal"),
            "md",
        )?;

        let stages = match options.mode {
            PipelineMode::Rigorous => RIGOROUS_STAGES,
            PipelineMode::Short => SHORT_STAGES,
        };

        Ok(Self {
            repo_root,
            runtime_cfg,
            target_package,
            workflow_root,
            options,
            bundle_root,
            reports_dir,
            stage_inputs_dir,
            stage_logs_dir,
            summary_report,
            started_at,
            slug: target_slug,
            stages,
        })
    }

    fn run(self) -> Result<RunDesignPackageResult> {
        let mut validation_notes = Vec::new();
        let mut report_paths = BTreeMap::new();
        let mut report_bodies = BTreeMap::new();
        let mut stage_outcomes = BTreeMap::<String, StageOutcome>::new();
        let mut changed_files = BTreeMap::<String, Vec<String>>::new();
        let mut command_log = Vec::new();

        let package_inventory = snapshot_package(&self.target_package)?;
        self.write_inventory(&package_inventory)?;
        self.write_plan()?;

        if let Err(error) = self.ensure_workflow_files() {
            let failure = RunFailure::new(FailureClass::StageValidation, None, error.to_string());
            validation_notes.push(failure.to_string());
            self.record_failure(
                &failure,
                &report_paths,
                &stage_outcomes,
                &changed_files,
                &command_log,
                &validation_notes,
            )?;
            return Err(anyhow::anyhow!(failure.to_string()));
        }

        let final_verdict = match self.execute_stages(
            &mut report_paths,
            &mut report_bodies,
            &mut stage_outcomes,
            &mut changed_files,
            &mut command_log,
        ) {
            Ok(()) => {
                if self.options.prepare_only {
                    validation_notes.push(
                        "prepare-only mode materialized stage packets without executing stages"
                            .to_string(),
                    );
                    "prepared-only".to_string()
                } else if self.options.executor == ExecutorKind::Mock {
                    validation_notes.push(
                        "mock executor completed all selected stages with deterministic synthetic outputs"
                            .to_string(),
                    );
                    "mock-executed".to_string()
                } else {
                    validation_notes.push(
                        "all selected stages executed and reports were persisted".to_string(),
                    );
                    "manual-review-required".to_string()
                }
            }
            Err(failure) => {
                validation_notes.push(failure.to_string());
                self.record_failure(
                    &failure,
                    &report_paths,
                    &stage_outcomes,
                    &changed_files,
                    &command_log,
                    &validation_notes,
                )?;
                return Err(anyhow::anyhow!(failure.to_string()));
            }
        };

        match self.validate_standard_governed_target() {
            Ok(Some(log_path)) => validation_notes.push(format!(
                "standard validator passed for manifest-bearing package (`{}`)",
                rel_path(&self.repo_root, &log_path)
            )),
            Ok(None) => {
                if self.options.prepare_only {
                    validation_notes
                        .push("prepare-only mode skipped the standard validator".to_string());
                } else {
                    validation_notes.push(
                        "target package has no design-proposal.yml; standard validator skipped"
                            .to_string(),
                    );
                }
            }
            Err(error) => {
                let failure =
                    RunFailure::new(FailureClass::StandardValidator, None, error.to_string());
                validation_notes.push(failure.to_string());
                self.record_failure(
                    &failure,
                    &report_paths,
                    &stage_outcomes,
                    &changed_files,
                    &command_log,
                    &validation_notes,
                )?;
                return Err(anyhow::anyhow!(failure.to_string()));
            }
        }

        self.write_package_delta(&stage_outcomes)?;
        self.write_commands_log(&command_log)?;
        self.write_validation(
            &final_verdict,
            &report_paths,
            &stage_outcomes,
            &validation_notes,
            None,
        )?;
        self.write_summary(
            &final_verdict,
            &report_paths,
            &stage_outcomes,
            &validation_notes,
            None,
        )?;
        self.write_bundle_metadata(&report_paths, &changed_files, &final_verdict, None)?;

        Ok(RunDesignPackageResult {
            bundle_root: self.bundle_root,
            summary_report: self.summary_report,
            final_verdict,
        })
    }

    fn validate_standard_governed_target(&self) -> Result<Option<PathBuf>> {
        if self.options.prepare_only || !self.target_package.join("design-proposal.yml").is_file() {
            return Ok(None);
        }

        let log_path = run_standard_design_package_validator(
            &self.repo_root,
            &self.target_package,
            &self.bundle_root,
        )?;
        Ok(Some(log_path))
    }

    fn ensure_workflow_files(&self) -> Result<()> {
        let required_paths = [
            self.workflow_root.join("workflow.yml"),
            self.workflow_root.join("stages"),
        ];
        for path in required_paths {
            if !path.exists() {
                bail!("required workflow path is missing: {}", path.display());
            }
        }

        for stage in self.stages {
            let prompt_path = self.prompt_path(stage);
            if !prompt_path.is_file() {
                bail!(
                    "missing prompt file for stage {}: {}",
                    stage.id,
                    prompt_path.display()
                );
            }
        }

        Ok(())
    }

    fn stage_executor_profile(stage: &StageDefinition) -> &'static str {
        if stage.class.is_file_writing() {
            "scoped_repo_mutation"
        } else {
            "read_only_analysis"
        }
    }

    fn stage_request(
        &self,
        stage: &StageDefinition,
        mut metadata: BTreeMap<String, String>,
    ) -> Result<ExecutionRequest> {
        metadata.insert("workflow_id".to_string(), WORKFLOW_ID.to_string());
        metadata.insert("stage_id".to_string(), stage.id.to_string());
        let (intent_ref, execution_role_ref, metadata) =
            request::bind_repo_local_request(&self.runtime_cfg, metadata)?;
        Ok(ExecutionRequest {
            request_id: format!("{}-stage-{}", self.slug, stage.id),
            caller_path: "workflow-stage".to_string(),
            action_type: "execute_stage".to_string(),
            target_id: format!("{WORKFLOW_ID}::{stage_id}", stage_id = stage.id),
            requested_capabilities: if stage.class.is_file_writing() {
                vec![
                    "workflow.stage.execute".to_string(),
                    "repo.write".to_string(),
                    "evidence.write".to_string(),
                ]
            } else {
                vec![
                    "workflow.stage.execute".to_string(),
                    "evidence.write".to_string(),
                ]
            },
            side_effect_flags: SideEffectFlags {
                write_repo: stage.class.is_file_writing(),
                write_evidence: true,
                shell: !self.options.prepare_only && self.options.executor != ExecutorKind::Mock,
                network: false,
                model_invoke: !self.options.prepare_only
                    && self.options.executor != ExecutorKind::Mock,
                state_mutation: false,
                publication: false,
                branch_mutation: false,
            },
            risk_tier: if stage.class.is_file_writing() {
                "medium".to_string()
            } else {
                "low".to_string()
            },
            workflow_mode: request::role_mediated_mode(),
            locality_scope: None,
            intent_ref: Some(intent_ref),
            autonomy_context: None,
            execution_role_ref: Some(execution_role_ref),
            parent_run_ref: Some(self.slug.clone()),
            review_requirements: ReviewRequirements {
                human_approval: false,
                quorum: false,
                rollback_metadata: false,
            },
            scope_constraints: ScopeConstraints {
                read: vec![self.target_package.display().to_string()],
                write: if stage.class.is_file_writing() {
                    vec![
                        self.target_package.display().to_string(),
                        self.bundle_root.join("stages").display().to_string(),
                    ]
                } else {
                    vec![self.bundle_root.join("stages").display().to_string()]
                },
                executor_profile: Some(Self::stage_executor_profile(stage).to_string()),
                locality_scope: None,
            },
            policy_mode_requested: None,
            environment_hint: None,
            metadata,
            ..ExecutionRequest::default()
        })
    }

    fn execute_stages(
        &self,
        report_paths: &mut BTreeMap<String, String>,
        report_bodies: &mut BTreeMap<String, String>,
        stage_outcomes: &mut BTreeMap<String, StageOutcome>,
        changed_files: &mut BTreeMap<String, Vec<String>>,
        command_log: &mut Vec<String>,
    ) -> std::result::Result<(), RunFailure> {
        let policy = PolicyEngine::new(self.runtime_cfg.clone());
        for stage in self.stages {
            let prompt_markdown = self
                .render_stage_prompt(stage, report_paths, report_bodies)
                .map_err(|error| {
                    RunFailure::new(
                        FailureClass::PromptPacket,
                        Some(stage.id),
                        error.to_string(),
                    )
                })?;
            let prompt_packet_path = self.stage_inputs_dir.join(format!(
                "{}-{}.prompt.md",
                stage.id,
                trim_md_suffix(stage.report_file)
            ));

            let relative_report_path = PathBuf::from("reports").join(stage.report_file);
            report_paths.insert(
                stage.id.to_string(),
                relative_report_path.display().to_string(),
            );

            let package_before = if stage.class.is_file_writing() {
                Some(snapshot_package(&self.target_package).map_err(|error| {
                    RunFailure::new(
                        FailureClass::PackageMutation,
                        Some(stage.id),
                        error.to_string(),
                    )
                })?)
            } else {
                None
            };

            let report_path = self.reports_dir.join(stage.report_file);
            let log_path = self.stage_logs_dir.join(format!(
                "{}-{}.log",
                stage.id,
                trim_md_suffix(stage.report_file)
            ));
            let executor_metadata = if self.options.executor == ExecutorKind::Mock {
                BTreeMap::new()
            } else {
                execution_budget_metadata(
                    &resolve_executor(self.options.executor, self.options.executor_bin.as_deref())
                        .map_err(|error| {
                            RunFailure::new(
                                FailureClass::ExecutorEnvironment,
                                Some(stage.id),
                                error.to_string(),
                            )
                        })?,
                    self.options.model.as_deref(),
                    prompt_markdown.as_bytes().len(),
                )
            };
            let stage_request = self
                .stage_request(stage, executor_metadata)
                .map_err(|error| {
                    RunFailure::new(
                        FailureClass::ExecutorEnvironment,
                        Some(stage.id),
                        error.to_string(),
                    )
                })?;
            let stage_grant = authorize_execution(&self.runtime_cfg, &policy, &stage_request, None)
                .map_err(|error| {
                    RunFailure::new(
                        FailureClass::ExecutorEnvironment,
                        Some(stage.id),
                        error.to_string(),
                    )
                })?;
            let stage_artifact_root = self.bundle_root.join("stages").join(stage.id);
            let stage_effects = artifact_effects_for_root(&stage_artifact_root, &stage_grant)
                .map_err(|error| {
                    RunFailure::new(
                        FailureClass::ExecutorEnvironment,
                        Some(stage.id),
                        error.to_string(),
                    )
                })?;
            let stage_evidence_effect = issue_evidence_mutation_effect(
                &stage_artifact_root,
                &stage_grant,
                self.bundle_root.display().to_string(),
                false,
            )
            .map_err(|error| {
                RunFailure::new(
                    FailureClass::ExecutorEnvironment,
                    Some(stage.id),
                    error.to_string(),
                )
            })?;
            let stage_repo_effect = if stage.class.is_file_writing() {
                Some(
                    issue_repo_mutation_effect_with_mode(
                        &stage_artifact_root,
                        &stage_grant,
                        self.target_package.display().to_string(),
                        false,
                    )
                    .map_err(|error| {
                        RunFailure::new(
                            FailureClass::ExecutorEnvironment,
                            Some(stage.id),
                            error.to_string(),
                        )
                    })?,
                )
            } else {
                None
            };
            let mut stage_authorized_effects = Vec::new();
            write_file_with_verified_evidence_effect(
                &stage_artifact_root,
                &stage_grant,
                &stage_evidence_effect,
                &prompt_packet_path,
                &prompt_markdown,
                ".octon/framework/engine/runtime/crates/kernel/src/workflow.rs::execute_stages:prompt_packet",
                &mut stage_authorized_effects,
            )
            .map_err(|error| {
                RunFailure::new(
                    FailureClass::PromptPacket,
                    Some(stage.id),
                    error.to_string(),
                )
            })?;
            if self.options.prepare_only {
                command_log.push(format!(
                    "- stage {} | prepare-only | prompt_packet={} | report={}",
                    stage.id,
                    rel_path(&self.repo_root, &prompt_packet_path),
                    relative_report_path.display()
                ));
                stage_outcomes.insert(stage.id.to_string(), StageOutcome::default());
                continue;
            }
            let stage_artifacts = write_execution_start(
                &stage_artifact_root,
                &stage_request,
                &stage_grant,
                &stage_effects,
            )
            .map_err(|error| {
                RunFailure::new(
                    FailureClass::ExecutorEnvironment,
                    Some(stage.id),
                    error.to_string(),
                )
            })?;
            let stage_started_at = auth_now_rfc3339().map_err(|error| {
                RunFailure::new(
                    FailureClass::ExecutorEnvironment,
                    Some(stage.id),
                    error.to_string(),
                )
            })?;
            let execution = match self.execute_stage(
                stage,
                &prompt_markdown,
                &report_path,
                &log_path,
                &stage_artifact_root,
                &stage_grant,
                &stage_evidence_effect,
                stage_repo_effect.as_ref(),
                &mut stage_authorized_effects,
            ) {
                Ok(execution) => execution,
                Err(error) => {
                    let _ = finalize_execution(
                        &stage_artifacts,
                        &stage_request,
                        &stage_grant,
                        &stage_effects,
                        &stage_started_at,
                        &ExecutionOutcome {
                            status: "failed".to_string(),
                            started_at: stage_started_at.clone(),
                            completed_at: auth_now_rfc3339()
                                .unwrap_or_else(|_| stage_started_at.clone()),
                            error: Some(error.to_string()),
                        },
                        &SideEffectSummary {
                            touched_scope: vec![
                                rel_path(&self.repo_root, &report_path),
                                rel_path(&self.repo_root, &log_path),
                            ],
                            executor_profile: Some(Self::stage_executor_profile(stage).to_string()),
                            authorized_effects: stage_authorized_effects.clone(),
                            ..SideEffectSummary::default()
                        },
                    );
                    if let Some(before) = package_before.as_ref() {
                        let after = snapshot_package(&self.target_package).map_err(|snapshot_error| {
                            RunFailure::new(
                                FailureClass::PackageMutation,
                                Some(stage.id),
                                format!(
                                    "executor failed and package state could not be inspected: {}; {}",
                                    error, snapshot_error
                                ),
                            )
                        })?;
                        let mut outcome = StageOutcome::default();
                        outcome.changed_files = diff_snapshots(before, &after);
                        if !outcome.changed_files.is_empty() {
                            changed_files.insert(
                                stage.id.to_string(),
                                outcome
                                    .changed_files
                                    .iter()
                                    .map(|change| format!("{}:{}", change.kind, change.path))
                                    .collect(),
                            );
                        }
                        stage_outcomes.insert(stage.id.to_string(), outcome);
                    }
                    command_log.push(format!(
                        "- stage {} | executor={} | prompt_packet={} | report={} | log={} | status=failed-before-report",
                        stage.id,
                        self.options.executor.as_str(),
                        rel_path(&self.repo_root, &prompt_packet_path),
                        rel_path(&self.repo_root, &report_path),
                        rel_path(&self.repo_root, &log_path)
                    ));
                    return Err(RunFailure::new(
                        FailureClass::ExecutorEnvironment,
                        Some(stage.id),
                        error.to_string(),
                    ));
                }
            };

            let report_body = fs::read_to_string(&report_path)
                .with_context(|| format!("read stage report {}", report_path.display()))
                .map_err(|error| {
                    RunFailure::new(
                        FailureClass::StageValidation,
                        Some(stage.id),
                        error.to_string(),
                    )
                })?;

            let mut outcome = StageOutcome::default();
            if let Some(before) = package_before.as_ref() {
                let after = snapshot_package(&self.target_package).map_err(|error| {
                    RunFailure::new(
                        FailureClass::PackageMutation,
                        Some(stage.id),
                        error.to_string(),
                    )
                })?;
                outcome.changed_files = diff_snapshots(before, &after);
                let changed = outcome
                    .changed_files
                    .iter()
                    .map(|change| format!("{}:{}", change.kind, change.path))
                    .collect::<Vec<_>>();
                changed_files.insert(stage.id.to_string(), changed);
            }

            if report_body.trim().is_empty() {
                stage_outcomes.insert(stage.id.to_string(), outcome);
                return Err(RunFailure::new(
                    FailureClass::StageValidation,
                    Some(stage.id),
                    format!("stage {} produced an empty report", stage.id),
                ));
            }

            if stage.class.is_file_writing() && !report_has_change_receipt(&report_body) {
                stage_outcomes.insert(stage.id.to_string(), outcome);
                return Err(RunFailure::new(
                    FailureClass::StageValidation,
                    Some(stage.id),
                    format!(
                        "stage {} report does not include a change manifest or explicit zero-change receipt",
                        stage.id
                    ),
                ));
            }

            command_log.push(format!(
                "- stage {} | executor={} | prompt_packet={} | report={} | log={}",
                stage.id,
                execution.executor_used,
                rel_path(&self.repo_root, &prompt_packet_path),
                rel_path(&self.repo_root, &report_path),
                rel_path(&self.repo_root, &log_path)
            ));
            finalize_execution(
                &stage_artifacts,
                &stage_request,
                &stage_grant,
                &stage_effects,
                &stage_started_at,
                &ExecutionOutcome {
                    status: "succeeded".to_string(),
                    started_at: stage_started_at.clone(),
                    completed_at: auth_now_rfc3339().map_err(|error| {
                        RunFailure::new(
                            FailureClass::ExecutorEnvironment,
                            Some(stage.id),
                            error.to_string(),
                        )
                    })?,
                    error: None,
                },
                &SideEffectSummary {
                    touched_scope: vec![
                        rel_path(&self.repo_root, &report_path),
                        rel_path(&self.repo_root, &log_path),
                    ],
                    executor_profile: Some(Self::stage_executor_profile(stage).to_string()),
                    dangerous_flags_blocked: execution.blocked_flags,
                    authorized_effects: stage_authorized_effects,
                    ..SideEffectSummary::default()
                },
            )
            .map_err(|error| {
                RunFailure::new(
                    FailureClass::StageValidation,
                    Some(stage.id),
                    error.to_string(),
                )
            })?;

            report_bodies.insert(stage.id.to_string(), report_body);
            stage_outcomes.insert(stage.id.to_string(), outcome);
        }

        Ok(())
    }

    fn execute_stage(
        &self,
        stage: &StageDefinition,
        prompt_markdown: &str,
        report_path: &Path,
        log_path: &Path,
        runtime_path: &Path,
        grant: &GrantBundle,
        evidence_effect: &AuthorizedEffect<EvidenceMutation>,
        repo_effect: Option<&AuthorizedEffect<RepoMutation>>,
        authorized_effects: &mut Vec<AuthorizedEffectReference>,
    ) -> Result<StageExecutionResult> {
        match resolve_executor(self.options.executor, self.options.executor_bin.as_deref())? {
            ResolvedExecutor::Mock => {
                self.execute_stage_mock(
                    stage,
                    prompt_markdown,
                    report_path,
                    log_path,
                    runtime_path,
                    grant,
                    evidence_effect,
                    repo_effect,
                    authorized_effects,
                )?;
                Ok(StageExecutionResult {
                    executor_used: "mock".to_string(),
                    blocked_flags: Vec::new(),
                })
            }
            ResolvedExecutor::Codex(executor_bin) => {
                let blocked_flags = self.execute_stage_codex(
                    stage,
                    prompt_markdown,
                    report_path,
                    log_path,
                    &executor_bin,
                    runtime_path,
                    grant,
                    evidence_effect,
                    repo_effect,
                    authorized_effects,
                )?;
                Ok(StageExecutionResult {
                    executor_used: "codex".to_string(),
                    blocked_flags,
                })
            }
            ResolvedExecutor::Claude(executor_bin) => {
                let blocked_flags = self.execute_stage_claude(
                    stage,
                    prompt_markdown,
                    report_path,
                    log_path,
                    &executor_bin,
                    runtime_path,
                    grant,
                    evidence_effect,
                    repo_effect,
                    authorized_effects,
                )?;
                Ok(StageExecutionResult {
                    executor_used: "claude".to_string(),
                    blocked_flags,
                })
            }
        }
    }

    fn execute_stage_codex(
        &self,
        stage: &StageDefinition,
        prompt_markdown: &str,
        report_path: &Path,
        log_path: &Path,
        executor_bin: &Path,
        runtime_path: &Path,
        grant: &GrantBundle,
        evidence_effect: &AuthorizedEffect<EvidenceMutation>,
        repo_effect: Option<&AuthorizedEffect<RepoMutation>>,
        authorized_effects: &mut Vec<AuthorizedEffectReference>,
    ) -> Result<Vec<String>> {
        let profile =
            resolve_executor_profile(&self.runtime_cfg, Self::stage_executor_profile(stage))?;
        let (mut command, blocked_flags) = build_executor_command(ExecutorCommandSpec {
            kind: ManagedExecutorKind::Codex,
            executor_bin,
            repo_root: &self.repo_root,
            output_path: Some(report_path),
            model: self.options.model.as_deref(),
            profile,
        })?;
        let report_effect = verify_authorized_effect(
            runtime_path,
            grant,
            evidence_effect,
            ".octon/framework/engine/runtime/crates/kernel/src/workflow.rs::execute_stage_codex:report_output",
            report_path.display().to_string(),
        )?;
        authorized_effects.push(authorized_effect_reference(&report_effect));
        if let Some(repo_effect) = repo_effect {
            let verified_repo_effect = verify_authorized_effect(
                runtime_path,
                grant,
                repo_effect,
                ".octon/framework/engine/runtime/crates/kernel/src/workflow.rs::execute_stage_codex:executor_repo_scope",
                self.target_package.display().to_string(),
            )?;
            authorized_effects.push(authorized_effect_reference(&verified_repo_effect));
        }

        let output = run_command_with_stdin(
            &mut command,
            &self.repo_root,
            prompt_markdown,
            stage.id,
            executor_bin.display().to_string(),
        )?;
        self.write_executor_log(
            stage.id,
            executor_bin.display().to_string(),
            &output,
            log_path,
            runtime_path,
            grant,
            evidence_effect,
            authorized_effects,
        )?;
        if !output.status.success() {
            bail!(
                "stage {} executor failed with status {} (see {})",
                stage.id,
                output.status,
                log_path.display()
            );
        }
        Ok(blocked_flags)
    }

    fn execute_stage_claude(
        &self,
        stage: &StageDefinition,
        prompt_markdown: &str,
        report_path: &Path,
        log_path: &Path,
        executor_bin: &Path,
        runtime_path: &Path,
        grant: &GrantBundle,
        evidence_effect: &AuthorizedEffect<EvidenceMutation>,
        repo_effect: Option<&AuthorizedEffect<RepoMutation>>,
        authorized_effects: &mut Vec<AuthorizedEffectReference>,
    ) -> Result<Vec<String>> {
        let profile =
            resolve_executor_profile(&self.runtime_cfg, Self::stage_executor_profile(stage))?;
        let (mut command, blocked_flags) = build_executor_command(ExecutorCommandSpec {
            kind: ManagedExecutorKind::Claude,
            executor_bin,
            repo_root: &self.repo_root,
            output_path: None,
            model: self.options.model.as_deref(),
            profile,
        })?;
        if let Some(repo_effect) = repo_effect {
            let verified_repo_effect = verify_authorized_effect(
                runtime_path,
                grant,
                repo_effect,
                ".octon/framework/engine/runtime/crates/kernel/src/workflow.rs::execute_stage_claude:executor_repo_scope",
                self.target_package.display().to_string(),
            )?;
            authorized_effects.push(authorized_effect_reference(&verified_repo_effect));
        }

        let output = run_command_with_stdin(
            &mut command,
            &self.repo_root,
            prompt_markdown,
            stage.id,
            executor_bin.display().to_string(),
        )?;
        self.write_executor_log(
            stage.id,
            executor_bin.display().to_string(),
            &output,
            log_path,
            runtime_path,
            grant,
            evidence_effect,
            authorized_effects,
        )?;
        if !output.status.success() {
            bail!(
                "stage {} executor failed with status {} (see {})",
                stage.id,
                output.status,
                log_path.display()
            );
        }

        write_file_with_verified_evidence_effect(
            runtime_path,
            grant,
            evidence_effect,
            report_path,
            &output.stdout,
            ".octon/framework/engine/runtime/crates/kernel/src/workflow.rs::execute_stage_claude:report",
            authorized_effects,
        )?;
        Ok(blocked_flags)
    }

    fn execute_stage_mock(
        &self,
        stage: &StageDefinition,
        prompt_markdown: &str,
        report_path: &Path,
        log_path: &Path,
        runtime_path: &Path,
        grant: &GrantBundle,
        evidence_effect: &AuthorizedEffect<EvidenceMutation>,
        repo_effect: Option<&AuthorizedEffect<RepoMutation>>,
        authorized_effects: &mut Vec<AuthorizedEffectReference>,
    ) -> Result<()> {
        let mock_root = self.target_package.join(".octon-mock-runner");
        let (mutations, report_body) =
            build_mock_stage_artifacts(stage, &self.target_package, &mock_root, prompt_markdown)?;

        if !mutations.is_empty() {
            let repo_effect = repo_effect.ok_or_else(|| {
                anyhow::anyhow!("workflow mock execution requires a repo mutation effect")
            })?;
            create_dir_with_verified_repo_effect(
                runtime_path,
                grant,
                repo_effect,
                &mock_root,
                ".octon/framework/engine/runtime/crates/kernel/src/workflow.rs::execute_stage_mock:mock_root",
                authorized_effects,
            )?;
            for (path, contents) in mutations {
                write_file_with_verified_repo_effect(
                    runtime_path,
                    grant,
                    repo_effect,
                    &path,
                    contents,
                    ".octon/framework/engine/runtime/crates/kernel/src/workflow.rs::execute_stage_mock:artifact",
                    authorized_effects,
                )?;
            }
        }

        write_file_with_verified_evidence_effect(
            runtime_path,
            grant,
            evidence_effect,
            report_path,
            report_body,
            ".octon/framework/engine/runtime/crates/kernel/src/workflow.rs::execute_stage_mock:report",
            authorized_effects,
        )?;
        write_file_with_verified_evidence_effect(
            runtime_path,
            grant,
            evidence_effect,
            log_path,
            format!(
                "# Stage {}\n\n- executor: mock\n- status: synthetic-success\n- report: {}\n",
                stage.id,
                report_path.display()
            ),
            ".octon/framework/engine/runtime/crates/kernel/src/workflow.rs::execute_stage_mock:log",
            authorized_effects,
        )?;

        Ok(())
    }

    fn write_executor_log(
        &self,
        stage_id: &str,
        executor_label: String,
        output: &std::process::Output,
        log_path: &Path,
        runtime_path: &Path,
        grant: &GrantBundle,
        evidence_effect: &AuthorizedEffect<EvidenceMutation>,
        authorized_effects: &mut Vec<AuthorizedEffectReference>,
    ) -> Result<()> {
        let mut log = String::new();
        log.push_str(&format!(
            "# Stage {}\n\n- executor: {}\n- status: {}\n\n## stdout\n\n```\n{}\n```\n\n## stderr\n\n```\n{}\n```\n",
            stage_id,
            executor_label,
            output.status,
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr)
        ));
        write_file_with_verified_evidence_effect(
            runtime_path,
            grant,
            evidence_effect,
            log_path,
            log,
            ".octon/framework/engine/runtime/crates/kernel/src/workflow.rs::write_executor_log",
            authorized_effects,
        )
    }

    fn render_stage_prompt(
        &self,
        stage: &StageDefinition,
        report_paths: &BTreeMap<String, String>,
        report_bodies: &BTreeMap<String, String>,
    ) -> Result<String> {
        let prompt_path = self.prompt_path(stage);
        let mut prompt = fs::read_to_string(&prompt_path)
            .with_context(|| format!("read prompt {}", prompt_path.display()))?;
        prompt = prompt.replace("<PACKAGE_PATH>", &self.target_package.display().to_string());

        let mut injected_sections = Vec::new();
        for (placeholder, source_stage) in REPORT_PLACEHOLDERS {
            if prompt.contains(placeholder) {
                if let Some(report_body) = report_bodies.get(*source_stage) {
                    let report_path = report_paths
                        .get(*source_stage)
                        .map(String::as_str)
                        .unwrap_or("reports/<missing>");
                    prompt = prompt.replace(
                        placeholder,
                        &format!(
                            "Injected by Octon runner from `{report_path}`. Full content is appended below."
                        ),
                    );
                    injected_sections.push(format!(
                        "### {placeholder}\n\nSource: `{report_path}`\n\n````md\n{report_body}\n````\n"
                    ));
                } else if self.options.prepare_only {
                    prompt = prompt.replace(
                        placeholder,
                        &format!(
                            "Pending output from stage `{source_stage}`. Octon runner will inject the full report during execution."
                        ),
                    );
                } else {
                    prompt = prompt.replace(
                        placeholder,
                        &format!(
                            "No prior report was produced for stage `{source_stage}` in the selected mode. Treat this input as not applicable."
                        ),
                    );
                }
            }
        }

        let mut rendered = String::new();
        rendered.push_str("# Octon Runner Envelope\n\n");
        rendered.push_str(&format!(
            "- Workflow: `{WORKFLOW_ID}`\n- Stage: `{}`\n- Mode: `{}`\n- Target package: `{}`\n- Bundle root: `{}`\n- Prompt source: `{}`\n\n",
            stage.id,
            self.options.mode.as_str(),
            self.target_package.display(),
            self.bundle_root.display(),
            rel_path(&self.repo_root, &prompt_path)
        ));
        rendered.push_str("## Final Answer Requirement\n\n");
        rendered.push_str(
            "Return only the full markdown report for this stage. If the stage is file-writing, apply the package changes directly when possible and include the required `CHANGE MANIFEST` or explicit zero-change receipt.\n\n",
        );
        rendered.push_str("## Canonical Prompt\n\n");
        rendered.push_str(&prompt);
        if !injected_sections.is_empty() {
            rendered.push_str("\n\n## Injected Inputs\n\n");
            for section in injected_sections {
                rendered.push_str(&section);
                rendered.push('\n');
            }
        }

        Ok(rendered)
    }

    fn prompt_path(&self, stage: &StageDefinition) -> PathBuf {
        self.workflow_root.join("stages").join(stage.prompt_file)
    }

    fn write_plan(&self) -> Result<()> {
        let mut plan = String::new();
        plan.push_str("# Design Package Workflow Plan\n\n");
        plan.push_str(&format!(
            "- workflow_id: `{WORKFLOW_ID}`\n- package_path: `{}`\n- mode: `{}`\n- executor: `{}`\n- prepare_only: `{}`\n- bundle_root: `{}`\n- summary_report: `{}`\n\n",
            self.target_package.display(),
            self.options.mode.as_str(),
            self.options.executor.as_str(),
            self.options.prepare_only,
            self.bundle_root.display(),
            self.summary_report.display()
        ));
        plan.push_str("## Selected Stages\n\n");
        for stage in self.stages {
            plan.push_str(&format!(
                "- `{}` -> `stages/{}` -> `reports/{}`\n",
                stage.id, stage.prompt_file, stage.report_file
            ));
        }
        fs::write(self.bundle_root.join("plan.md"), plan)
            .with_context(|| format!("write plan {}", self.bundle_root.join("plan.md").display()))
    }

    fn write_inventory(&self, inventory: &BTreeMap<String, FileFingerprint>) -> Result<()> {
        let mut body = String::new();
        body.push_str("# Target Package Inventory\n\n");
        body.push_str(&format!(
            "- package_path: `{}`\n- file_count: `{}`\n\n",
            self.target_package.display(),
            inventory.len()
        ));
        for path in inventory.keys() {
            body.push_str(&format!("- `{path}`\n"));
        }
        fs::write(self.bundle_root.join("inventory.md"), body).with_context(|| {
            format!(
                "write inventory {}",
                self.bundle_root.join("inventory.md").display()
            )
        })
    }

    fn write_package_delta(&self, outcomes: &BTreeMap<String, StageOutcome>) -> Result<()> {
        let mut body = String::new();
        body.push_str("# Package Delta\n\n");
        body.push_str(&format!(
            "- target_package: `{}`\n- mode: `{}`\n\n",
            self.target_package.display(),
            self.options.mode.as_str()
        ));

        for stage in self.stages {
            body.push_str(&format!("## Stage {}\n\n", stage.id));
            match outcomes.get(stage.id) {
                Some(outcome) if !outcome.changed_files.is_empty() => {
                    for change in &outcome.changed_files {
                        body.push_str(&format!("- `{}` `{}`\n", change.kind, change.path));
                    }
                }
                _ if stage.class.is_file_writing() => {
                    body.push_str("- no package file delta recorded\n");
                }
                _ => {
                    body.push_str("- non-file-writing stage\n");
                }
            }
            body.push('\n');
        }

        fs::write(self.bundle_root.join("package-delta.md"), body).with_context(|| {
            format!(
                "write package delta {}",
                self.bundle_root.join("package-delta.md").display()
            )
        })
    }

    fn write_commands_log(&self, command_log: &[String]) -> Result<()> {
        let mut body = String::new();
        body.push_str("# Stage Commands\n\n");
        if command_log.is_empty() {
            body.push_str("- no executor commands recorded\n");
        } else {
            for entry in command_log {
                body.push_str(entry);
                body.push('\n');
            }
        }
        fs::write(self.bundle_root.join("commands.md"), body).with_context(|| {
            format!(
                "write commands log {}",
                self.bundle_root.join("commands.md").display()
            )
        })
    }

    fn write_validation(
        &self,
        final_verdict: &str,
        report_paths: &BTreeMap<String, String>,
        outcomes: &BTreeMap<String, StageOutcome>,
        notes: &[String],
        failure: Option<&RunFailure>,
    ) -> Result<()> {
        let mut body = String::new();
        body.push_str("# Validation\n\n");
        body.push_str(&format!(
            "- final_verdict: `{final_verdict}`\n- prepare_only: `{}`\n\n",
            self.options.prepare_only
        ));
        if let Some(failure) = failure {
            body.push_str(&format!("- failure_class: `{}`\n", failure.class.as_str()));
            if let Some(stage) = &failure.failed_stage {
                body.push_str(&format!("- failed_stage: `{stage}`\n"));
            }
            body.push('\n');
        }
        body.push_str("## Checks\n\n");
        for stage in self.stages {
            let report_exists = if self.options.prepare_only {
                false
            } else {
                self.reports_dir.join(stage.report_file).is_file()
            };
            let file_receipt_ok = if stage.class.is_file_writing() {
                self.options.prepare_only || outcomes.contains_key(stage.id)
            } else {
                true
            };
            body.push_str(&format!("- [x] stage `{}` selected\n", stage.id));
            body.push_str(&format!(
                "- [{}] report `{}` {}\n",
                if report_exists { "x" } else { " " },
                stage.report_file,
                if self.options.prepare_only {
                    "planned"
                } else {
                    "written"
                }
            ));
            if stage.class.is_file_writing() {
                body.push_str(&format!(
                    "- [{}] file-writing receipt/delta recorded\n",
                    if file_receipt_ok { "x" } else { " " }
                ));
            }
        }
        if self.target_package.join("design-proposal.yml").is_file() {
            body.push_str(&format!(
                "- [{}] standard design-package validator passed\n",
                if self.options.prepare_only
                    || self.bundle_root.join("standard-validator.log").is_file()
                {
                    "x"
                } else {
                    " "
                }
            ));
        }
        body.push_str(&format!(
            "- [{}] `commands.md` exists\n",
            if self.bundle_root.join("commands.md").is_file() {
                "x"
            } else {
                " "
            }
        ));
        body.push_str(&format!(
            "- [{}] `inventory.md` exists\n",
            if self.bundle_root.join("inventory.md").is_file() {
                "x"
            } else {
                " "
            }
        ));
        body.push_str(&format!(
            "- [{}] `stage-inputs/` and `stage-logs/` exist\n",
            if self.bundle_root.join("stage-inputs").is_dir()
                && self.bundle_root.join("stage-logs").is_dir()
            {
                "x"
            } else {
                " "
            }
        ));
        body.push_str("\n## Notes\n\n");
        for note in notes {
            body.push_str(&format!("- {note}\n"));
        }

        let _ = report_paths;
        fs::write(self.bundle_root.join("validation.md"), body).with_context(|| {
            format!(
                "write validation {}",
                self.bundle_root.join("validation.md").display()
            )
        })
    }

    fn write_summary(
        &self,
        final_verdict: &str,
        report_paths: &BTreeMap<String, String>,
        outcomes: &BTreeMap<String, StageOutcome>,
        notes: &[String],
        failure: Option<&RunFailure>,
    ) -> Result<()> {
        let mut body = String::new();
        body.push_str("# Design Package Workflow Summary\n\n");
        body.push_str(&format!(
            "- workflow_id: `{WORKFLOW_ID}`\n- package_path: `{}`\n- mode: `{}`\n- executor: `{}`\n- prepare_only: `{}`\n- final_verdict: `{}`\n- bundle_root: `{}`\n\n",
            self.target_package.display(),
            self.options.mode.as_str(),
            self.options.executor.as_str(),
            self.options.prepare_only,
            final_verdict,
            self.bundle_root.display()
        ));
        if let Some(failure) = failure {
            body.push_str(&format!("- failure_class: `{}`\n", failure.class.as_str()));
            if let Some(stage) = &failure.failed_stage {
                body.push_str(&format!("- failed_stage: `{stage}`\n"));
            }
            body.push('\n');
        }
        body.push_str("## Reports\n\n");
        for stage in self.stages {
            if let Some(report_path) = report_paths.get(stage.id) {
                body.push_str(&format!("- stage `{}` -> `{}`\n", stage.id, report_path));
            }
        }
        body.push_str("\n## Package Delta\n\n");
        for stage in self.stages {
            let outcome = outcomes.get(stage.id);
            match outcome {
                Some(outcome) if !outcome.changed_files.is_empty() => {
                    body.push_str(&format!(
                        "- stage `{}` changed {} file(s)\n",
                        stage.id,
                        outcome.changed_files.len()
                    ));
                }
                Some(_) if stage.class.is_file_writing() => {
                    body.push_str(&format!("- stage `{}` reported no file delta\n", stage.id));
                }
                _ => {}
            }
        }
        body.push_str("\n## Notes\n\n");
        for note in notes {
            body.push_str(&format!("- {note}\n"));
        }
        fs::write(self.bundle_root.join("summary.md"), &body).with_context(|| {
            format!(
                "write bundle summary {}",
                self.bundle_root.join("summary.md").display()
            )
        })?;
        fs::write(&self.summary_report, body)
            .with_context(|| format!("write summary {}", self.summary_report.display()))
    }

    fn write_bundle_metadata(
        &self,
        report_paths: &BTreeMap<String, String>,
        changed_files: &BTreeMap<String, Vec<String>>,
        final_verdict: &str,
        failure: Option<&RunFailure>,
    ) -> Result<()> {
        let metadata = BundleMetadata {
            kind: "workflow-execution-bundle".to_string(),
            id: self
                .bundle_root
                .file_name()
                .and_then(|value| value.to_str())
                .unwrap_or("workflow-bundle")
                .to_string(),
            workflow_id: WORKFLOW_ID.to_string(),
            package_path: rel_path(&self.repo_root, &self.target_package),
            mode: self.options.mode.as_str().to_string(),
            executor: self.options.executor.as_str().to_string(),
            prepare_only: self.options.prepare_only,
            slug: self.slug.clone(),
            started_at: self.started_at.clone(),
            completed_at: now_rfc3339()?,
            summary: "summary.md".to_string(),
            reports_dir: "reports".to_string(),
            stage_inputs_dir: "stage-inputs".to_string(),
            stage_logs_dir: "stage-logs".to_string(),
            selected_stages: self
                .stages
                .iter()
                .map(|stage| stage.id.to_string())
                .collect(),
            report_paths: report_paths.clone(),
            changed_files: changed_files.clone(),
            plan: "plan.md".to_string(),
            inventory: "inventory.md".to_string(),
            commands: "commands.md".to_string(),
            validation: "validation.md".to_string(),
            summary_report: rel_path(&self.repo_root, &self.summary_report),
            final_verdict: final_verdict.to_string(),
            failure_class: failure.map(|failure| failure.class.as_str().to_string()),
            failed_stage: failure.and_then(|failure| failure.failed_stage.clone()),
        };
        let yaml = serde_yaml::to_string(&metadata)?;
        fs::write(self.bundle_root.join("bundle.yml"), yaml).with_context(|| {
            format!(
                "write bundle metadata {}",
                self.bundle_root.join("bundle.yml").display()
            )
        })
    }

    fn record_failure(
        &self,
        failure: &RunFailure,
        report_paths: &BTreeMap<String, String>,
        stage_outcomes: &BTreeMap<String, StageOutcome>,
        changed_files: &BTreeMap<String, Vec<String>>,
        command_log: &[String],
        validation_notes: &[String],
    ) -> Result<()> {
        self.write_package_delta(stage_outcomes)?;
        self.write_commands_log(command_log)?;
        self.write_validation(
            "failed",
            report_paths,
            stage_outcomes,
            validation_notes,
            Some(failure),
        )?;
        self.write_summary(
            "failed",
            report_paths,
            stage_outcomes,
            validation_notes,
            Some(failure),
        )?;
        self.write_bundle_metadata(report_paths, changed_files, "failed", Some(failure))
    }
}

fn resolve_repo_relative_path(repo_root: &Path, raw: &Path) -> Result<PathBuf> {
    let joined = if raw.is_absolute() {
        raw.to_path_buf()
    } else {
        repo_root.join(raw)
    };
    joined
        .canonicalize()
        .with_context(|| format!("resolve path {}", joined.display()))
}

fn resolve_executor(kind: ExecutorKind, override_bin: Option<&Path>) -> Result<ResolvedExecutor> {
    if kind == ExecutorKind::Mock {
        return Ok(ResolvedExecutor::Mock);
    }

    if let Some(path) = override_bin {
        return match kind {
            ExecutorKind::Claude => Ok(ResolvedExecutor::Claude(path.to_path_buf())),
            ExecutorKind::Codex => Ok(ResolvedExecutor::Codex(path.to_path_buf())),
            ExecutorKind::Auto => infer_auto_executor_from_path(path),
            ExecutorKind::Mock => Ok(ResolvedExecutor::Mock),
        };
    }

    if let Some(path) = std::env::var_os("OCTON_DESIGN_PACKAGE_EXECUTOR") {
        let path = PathBuf::from(path);
        return match kind {
            ExecutorKind::Claude => Ok(ResolvedExecutor::Claude(path)),
            ExecutorKind::Codex => Ok(ResolvedExecutor::Codex(path)),
            ExecutorKind::Auto => infer_auto_executor_from_path(&path),
            ExecutorKind::Mock => Ok(ResolvedExecutor::Mock),
        };
    }

    match kind {
        ExecutorKind::Codex => find_binary("codex")
            .map(ResolvedExecutor::Codex)
            .ok_or_else(|| anyhow::anyhow!("codex executable not found on PATH")),
        ExecutorKind::Claude => find_binary("claude")
            .map(ResolvedExecutor::Claude)
            .ok_or_else(|| anyhow::anyhow!("claude executable not found on PATH")),
        ExecutorKind::Auto => {
            if let Some(path) = find_binary("codex") {
                Ok(ResolvedExecutor::Codex(path))
            } else if let Some(path) = find_binary("claude") {
                Ok(ResolvedExecutor::Claude(path))
            } else {
                bail!("no supported executor found on PATH (tried codex, claude)")
            }
        }
        ExecutorKind::Mock => Ok(ResolvedExecutor::Mock),
    }
}

fn infer_auto_executor_from_path(path: &Path) -> Result<ResolvedExecutor> {
    let filename = path
        .file_name()
        .map(|value| value.to_string_lossy().to_ascii_lowercase())
        .unwrap_or_else(|| path.display().to_string().to_ascii_lowercase());

    if filename.contains("claude") {
        Ok(ResolvedExecutor::Claude(path.to_path_buf()))
    } else if filename.contains("codex") {
        Ok(ResolvedExecutor::Codex(path.to_path_buf()))
    } else {
        bail!(
            "unable to infer executor kind from override path '{}'; pass --executor codex or --executor claude",
            path.display()
        )
    }
}

fn execution_budget_metadata(
    executor: &ResolvedExecutor,
    model: Option<&str>,
    prompt_bytes: usize,
) -> BTreeMap<String, String> {
    let (executor_kind, provider) = match executor {
        ResolvedExecutor::Claude(_) => ("claude", "anthropic"),
        ResolvedExecutor::Codex(_) => ("codex", "openai"),
        ResolvedExecutor::Mock => ("mock", "unknown"),
    };

    let mut metadata = BTreeMap::from([
        ("executor_kind".to_string(), executor_kind.to_string()),
        ("budget_provider".to_string(), provider.to_string()),
        ("prompt_bytes".to_string(), prompt_bytes.to_string()),
    ]);
    if let Some(model) = model {
        metadata.insert("budget_model".to_string(), model.to_string());
    }
    metadata
}

fn find_binary(name: &str) -> Option<PathBuf> {
    if name.contains(std::path::MAIN_SEPARATOR) {
        let path = PathBuf::from(name);
        return path.is_file().then_some(path);
    }

    let path_var = std::env::var_os("PATH")?;
    for entry in std::env::split_paths(&path_var) {
        let candidate = entry.join(name);
        if candidate.is_file() {
            return Some(candidate);
        }
    }
    None
}

fn run_command_with_stdin(
    command: &mut Command,
    cwd: &Path,
    stdin_text: &str,
    stage_id: &str,
    executor_label: String,
) -> Result<std::process::Output> {
    command
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .current_dir(cwd);

    let mut child = command
        .spawn()
        .with_context(|| format!("spawn executor '{}' for stage {}", executor_label, stage_id))?;

    if let Some(stdin) = child.stdin.as_mut() {
        stdin
            .write_all(stdin_text.as_bytes())
            .with_context(|| format!("write stage {} prompt to executor stdin", stage_id))?;
    }

    child
        .wait_with_output()
        .with_context(|| format!("wait for stage {} executor", stage_id))
}

fn build_mock_stage_artifacts(
    stage: &StageDefinition,
    target_package: &Path,
    mock_root: &Path,
    prompt_markdown: &str,
) -> Result<(Vec<(PathBuf, String)>, String)> {
    let mut mutations = Vec::new();
    let prompt_hash = hex::encode(Sha256::digest(prompt_markdown.as_bytes()));
    let prompt_hash = &prompt_hash[..12];

    let report_title = match stage.id {
        "01" => "Design Audit Report",
        "02" => "Design Package Remediation Report",
        "03" => "Design Red-Team Report",
        "04" => "Design Hardening Report",
        "05" => "Design Integration Report",
        "06" => "Implementation Simulation Report",
        "07" => "Specification Closure Report",
        "08" => "Minimal Implementation Architecture Blueprint",
        "09" => "First Implementation Plan",
        _ => "Design Package Stage Report",
    };

    let report_body = match stage.id {
        "02" => {
            let target = mock_root.join("synthetic-remediation.md");
            mutations.push((
                target.clone(),
                format!(
                    "# Synthetic Remediation\n\n- stage: `02`\n- package: `{}`\n- prompt_hash: `{}`\n",
                    target_package.display(),
                    prompt_hash
                ),
            ));
            format!(
                "# {report_title}\n\nCHANGE MANIFEST\n- CREATE: `{}`\n\n## Summary\n\nMock executor created a deterministic remediation artifact.\n",
                target.display()
            )
        }
        "04" => {
            let target = mock_root.join("synthetic-hardening.md");
            mutations.push((
                target.clone(),
                format!(
                    "# Synthetic Hardening\n\n- stage: `04`\n- package: `{}`\n- prompt_hash: `{}`\n",
                    target_package.display(),
                    prompt_hash
                ),
            ));
            format!(
                "# {report_title}\n\nCHANGE MANIFEST\n- CREATE: `{}`\n\n## Summary\n\nMock executor created a deterministic hardening artifact.\n",
                target.display()
            )
        }
        "05" => {
            let target = mock_root.join("synthetic-hardening.md");
            let previous = if target.exists() {
                fs::read_to_string(&target).unwrap_or_default()
            } else {
                String::new()
            };
            mutations.push((
                target.clone(),
                format!(
                    "{previous}\n## Integration Pass\n\n- stage: `05`\n- prompt_hash: `{}`\n",
                    prompt_hash
                ),
            ));
            format!(
                "# {report_title}\n\nCHANGE MANIFEST\n- UPDATE: `{}`\n\n## Summary\n\nMock executor updated the prior hardening artifact to exercise delta tracking.\n",
                target.display()
            )
        }
        "07" => format!(
            "# {report_title}\n\nZero-Change Receipt\n\n- rationale: `mock executor simulates a no-op closure when no blockers remain`\n- reviewed_files: `[]`\n"
        ),
        "08" => format!(
            "# {report_title}\n\n## Minimal Production Architecture\n\n- control module\n- contract store\n- report bundle writer\n"
        ),
        "09" => format!(
            "# {report_title}\n\n## Workstreams\n\n- contracts and schemas\n- executor integration\n- assurance and smoke tests\n"
        ),
        _ => format!(
            "# {report_title}\n\n## Summary\n\nMock executor synthesized a deterministic stage report.\n\n- package: `{}`\n- prompt_hash: `{}`\n",
            target_package.display(),
            prompt_hash
        ),
    };

    Ok((mutations, report_body))
}

fn validate_design_package_id(package_id: &str) -> Result<()> {
    let bytes = package_id.as_bytes();
    if bytes.is_empty() {
        bail!("package_id must not be empty");
    }
    if !bytes[0].is_ascii_lowercase() {
        bail!("package_id must start with a lowercase ASCII letter");
    }
    if !bytes
        .iter()
        .all(|byte| byte.is_ascii_lowercase() || byte.is_ascii_digit() || *byte == b'-')
    {
        bail!("package_id may contain only lowercase ASCII letters, digits, and hyphens");
    }
    Ok(())
}

fn build_selected_modules(
    include_contracts: bool,
    include_conformance: bool,
    include_canonicalization: bool,
) -> Vec<&'static str> {
    let mut modules = vec!["reference", "history"];
    if include_contracts {
        modules.push("contracts");
    }
    if include_conformance {
        modules.push("conformance");
    }
    if include_canonicalization {
        modules.push("canonicalization");
    }
    modules
}

fn build_design_package_replacements(
    options: &RunCreateDesignPackageOptions,
    package_summary: &str,
    exit_expectation: &str,
    _package_rel: &str,
    selected_modules: &[&str],
    conformance_validator_path: &str,
) -> BTreeMap<String, String> {
    let mut replacements = BTreeMap::new();
    replacements.insert("PACKAGE_ID".to_string(), options.package_id.clone());
    replacements.insert(
        "PROPOSAL_TITLE".to_string(),
        options.package_title.trim().to_string(),
    );
    replacements.insert("PROPOSAL_ID".to_string(), options.package_id.clone());
    replacements.insert("PROPOSAL_SUMMARY".to_string(), package_summary.to_string());
    replacements.insert("PROPOSAL_KIND".to_string(), "design".to_string());
    replacements.insert(
        "DESIGN_CLASS".to_string(),
        options.package_class.as_str().to_string(),
    );
    replacements.insert(
        "PROMOTION_SCOPE".to_string(),
        options.promotion_scope.as_str().to_string(),
    );
    replacements.insert(
        "SELECTED_MODULES_YAML".to_string(),
        format_yaml_list(selected_modules.iter().copied()),
    );
    replacements.insert(
        "PROMOTION_TARGETS_YAML".to_string(),
        format_yaml_list(options.implementation_targets.iter().map(String::as_str)),
    );
    replacements.insert(
        "PROMOTION_TARGETS_BULLETS".to_string(),
        format_markdown_bullets(options.implementation_targets.iter().map(String::as_str)),
    );
    replacements.insert(
        "SELECTED_MODULES_BULLETS".to_string(),
        format_markdown_bullets(selected_modules.iter().copied()),
    );
    replacements.insert("EXIT_EXPECTATION".to_string(), exit_expectation.to_string());
    replacements.insert("PROPOSAL_STATUS".to_string(), "draft".to_string());
    replacements.insert("RELATED_PROPOSALS_YAML".to_string(), "  []\n".to_string());
    replacements.insert("DEFAULT_AUDIT_MODE".to_string(), "rigorous".to_string());
    replacements.insert("DESIGN_VALIDATOR_PATH".to_string(), "null".to_string());
    replacements.insert(
        "CONFORMANCE_VALIDATOR_PATH".to_string(),
        if conformance_validator_path == "null" {
            "null".to_string()
        } else {
            format!("\"{conformance_validator_path}\"")
        },
    );
    replacements.insert(
        "CLASS_PRIMARY_DOCS".to_string(),
        match options.package_class {
            DesignPackageClass::DomainRuntime => format_markdown_bullets([
                "`normative/architecture/domain-model.md`",
                "`normative/architecture/runtime-architecture.md`",
                "`normative/execution/behavior-model.md`",
                "`normative/assurance/implementation-readiness.md`",
            ]),
            DesignPackageClass::ExperienceProduct => format_markdown_bullets([
                "`normative/experience/user-journeys.md`",
                "`normative/experience/information-architecture.md`",
                "`normative/experience/screen-states-and-flows.md`",
                "`normative/assurance/implementation-readiness.md`",
            ]),
        },
    );
    replacements.insert(
        "OPTIONAL_MODULE_DOCS".to_string(),
        build_optional_module_docs(selected_modules),
    );
    replacements.insert(
        "ARTIFACT_CATALOG_ENTRIES".to_string(),
        "- generated after scaffold completion".to_string(),
    );
    replacements
}

fn build_optional_module_docs(selected_modules: &[&str]) -> String {
    let mut docs = vec![
        "`reference/README.md`".to_string(),
        "`history/README.md`".to_string(),
    ];
    if selected_modules.contains(&"contracts") {
        docs.push("`contracts/README.md`".to_string());
    }
    if selected_modules.contains(&"conformance") {
        docs.push("`conformance/README.md`".to_string());
    }
    if selected_modules.contains(&"canonicalization") {
        docs.push("`navigation/canonicalization-target-map.md`".to_string());
    }
    format_markdown_bullets(docs.iter().map(String::as_str))
}

fn build_proposal_manifest(
    options: &RunCreateDesignPackageOptions,
    package_summary: &str,
    exit_expectation: &str,
) -> String {
    format!(
        "schema_version: \"proposal-v1\"\nproposal_id: \"{}\"\ntitle: \"{}\"\nsummary: \"{}\"\nproposal_kind: \"design\"\npromotion_scope: \"{}\"\npromotion_targets:\n{}status: \"draft\"\nlifecycle:\n  temporary: true\n  exit_expectation: \"{}\"\nrelated_proposals: []\n",
        options.package_id,
        options.package_title.trim().replace('"', "\\\""),
        package_summary.replace('"', "\\\""),
        options.promotion_scope.as_str(),
        format_yaml_list(options.implementation_targets.iter().map(String::as_str)),
        exit_expectation.replace('"', "\\\""),
    )
}

fn build_design_proposal_manifest(
    options: &RunCreateDesignPackageOptions,
    selected_modules: &[&str],
    conformance_validator_path: Option<&str>,
) -> String {
    format!(
        "schema_version: \"design-proposal-v1\"\ndesign_class: \"{}\"\nselected_modules:\n{}validation:\n  default_audit_mode: \"rigorous\"\n  design_validator_path: null\n  conformance_validator_path: {}\n",
        options.package_class.as_str(),
        format_yaml_list(selected_modules.iter().copied()),
        conformance_validator_path
            .map(|path| format!("\"{}\"", path.replace('"', "\\\"")))
            .unwrap_or_else(|| "null".to_string())
    )
}

fn build_source_of_truth_map(
    options: &RunCreateDesignPackageOptions,
    selected_modules: &[&str],
) -> String {
    let primary_docs = match options.package_class {
        DesignPackageClass::DomainRuntime => format_markdown_bullets([
            "`normative/architecture/domain-model.md`",
            "`normative/architecture/runtime-architecture.md`",
            "`normative/execution/behavior-model.md`",
            "`normative/assurance/implementation-readiness.md`",
        ]),
        DesignPackageClass::ExperienceProduct => format_markdown_bullets([
            "`normative/experience/user-journeys.md`",
            "`normative/experience/information-architecture.md`",
            "`normative/experience/screen-states-and-flows.md`",
            "`normative/assurance/implementation-readiness.md`",
        ]),
    };
    let optional_docs = build_optional_module_docs(selected_modules);
    format!(
        "# Proposal Reading And Precedence Map\n\n## Purpose\n\nThis file defines the proposal-local reading order, authority boundaries, and evidence model for this temporary design proposal. It does not make the proposal a canonical repository authority.\n\n## External Authorities\n\n| Concern | Source of truth | Notes |\n| --- | --- | --- |\n| Repo-wide authority and non-canonical rules | `.octon/README.md`, `.octon/framework/cognition/_meta/architecture/specification.md`, `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` | These durable surfaces outrank this proposal. |\n| Proposal workspace layout and lifecycle contract | `.octon/inputs/exploratory/proposals/README.md`, `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`, `.octon/framework/scaffolding/governance/patterns/design-proposal-standard.md` | These durable proposal rules define placement, lifecycle, and packet expectations. |\n| Design subtype contract | `.octon/framework/scaffolding/runtime/templates/design-proposal.schema.json`, `.octon/framework/assurance/runtime/_ops/scripts/validate-design-proposal.sh` | The subtype manifest, module rules, and validator behavior must remain aligned. |\n| Proposal registry projection contract | `.octon/generated/proposals/registry.yml`, `.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json` | The registry is projection-only and never outranks the manifests. |\n| Workflow evidence location | `.octon/state/evidence/runs/workflows/`, `.octon/state/evidence/validation/` | Proposal operation receipts belong under retained evidence, not inside the proposal packet. |\n\n## Primary Proposal Inputs\n\n### Core\n\n- `proposal.yml`\n- `design-proposal.yml`\n- `implementation/README.md`\n- `implementation/minimal-implementation-blueprint.md`\n- `implementation/first-implementation-plan.md`\n\n### Class-Specific Normative Docs\n\n{}\n\n### Optional Modules\n\n{}\n\n### Discovery Projection\n\n- `/.octon/generated/proposals/registry.yml`\n\n## Proposal-Local Authority Roles\n\n| Artifact | Role | Authority level |\n| --- | --- | --- |\n| `proposal.yml` | Base identity, scope, targets, lifecycle, and exit contract | Highest proposal-local |\n| `design-proposal.yml` | Design subtype class, module, and validation contract | Secondary proposal-local |\n| Class-specific normative docs | The design-spec authority that implementation and review rely on | Primary working design surface |\n| `implementation/*.md` | Implementation framing and first-slice guidance | Supporting implementation guidance |\n| Optional module docs | Supporting reference, history, contracts, conformance, and canonicalization material | Supporting, not authoritative over manifests |\n| `navigation/source-of-truth-map.md` | Manual proposal-local precedence, authority, and evidence map | Explanatory support |\n| `navigation/artifact-catalog.md` | Generated file inventory for the current packet shape | Low-authority generated inventory |\n| `/.octon/generated/proposals/registry.yml` | Discovery projection rebuilt from proposal manifests | Projection only |\n| `README.md` | Human entry point and reading guidance | Explanatory only |\n\n## Derived Or Projection-Only Surfaces\n\n| Surface | Status | Rule |\n| --- | --- | --- |\n| `/.octon/generated/proposals/registry.yml` | Committed projection | Must be regenerated from manifests or fail-closed validated; never authoritative over manifests |\n| `navigation/artifact-catalog.md` | Generated inventory | Reflects the current packet shape but does not define lifecycle truth |\n| Workflow bundles under `state/evidence/runs/workflows/**` | Retained evidence | Evidence of proposal operations, not lifecycle authority |\n\n## Conflict Resolution\n\n1. Repository-wide governance and durable authorities\n2. `proposal.yml`\n3. `design-proposal.yml`\n4. Class-specific normative docs\n5. `implementation/README.md`\n6. `implementation/minimal-implementation-blueprint.md`\n7. `implementation/first-implementation-plan.md`\n8. Optional module docs\n9. `navigation/source-of-truth-map.md`\n10. `navigation/artifact-catalog.md`\n11. `/.octon/generated/proposals/registry.yml`\n12. `README.md`\n\n## Boundary Rules\n\n- This proposal remains temporary and non-canonical even when its content is implementation-ready.\n- Durable runtime, documentation, policy, and contract outputs must be promoted outside `/.octon/inputs/exploratory/proposals/`.\n- Proposal discovery is allowed through the committed registry projection, but lifecycle truth stays in `proposal.yml` and `design-proposal.yml`.\n- Proposal operation evidence belongs under `state/evidence/**`, not inside the proposal packet or under `generated/**`.\n",
        primary_docs, optional_docs
    )
}

fn expected_active_proposal_rel(proposal_kind: &str, proposal_id: &str) -> String {
    format!("{PROPOSALS_ROOT_REL}/{proposal_kind}/{proposal_id}")
}

fn expected_archived_proposal_rel(proposal_kind: &str, proposal_id: &str) -> String {
    format!("{PROPOSALS_ROOT_REL}/.archive/{proposal_kind}/{proposal_id}")
}

fn parse_active_proposal_rel(proposal_rel: &str) -> Option<(String, String)> {
    let prefix = format!("{PROPOSALS_ROOT_REL}/");
    let rest = proposal_rel.strip_prefix(&prefix)?;
    if rest.starts_with(".archive/") {
        return None;
    }
    let mut parts = rest.split('/');
    let proposal_kind = parts.next()?;
    let proposal_id = parts.next()?;
    if parts.next().is_some() || proposal_kind.is_empty() || proposal_id.is_empty() {
        return None;
    }
    Some((proposal_kind.to_string(), proposal_id.to_string()))
}

fn validate_partial_archive_recovery(
    manifest: &ProposalManifest,
    proposal_kind: &str,
    proposal_id: &str,
    original_path: &str,
    disposition: &str,
    promotion_evidence: &[String],
) -> Result<()> {
    ensure!(
        manifest.proposal_kind == proposal_kind,
        "partial archive proposal_kind mismatch: expected {}, found {}",
        proposal_kind,
        manifest.proposal_kind
    );
    ensure!(
        manifest.proposal_id == proposal_id,
        "partial archive proposal_id mismatch: expected {}, found {}",
        proposal_id,
        manifest.proposal_id
    );
    ensure!(
        manifest.status == "archived",
        "partial archive recovery requires archived status, found {}",
        manifest.status
    );
    let archive = manifest
        .archive
        .as_ref()
        .context("partial archive recovery requires archive metadata")?;
    ensure!(
        archive.original_path == original_path,
        "partial archive original_path mismatch: expected {}, found {}",
        original_path,
        archive.original_path
    );
    ensure!(
        archive.disposition == disposition,
        "partial archive disposition mismatch: expected {}, found {}",
        disposition,
        archive.disposition
    );
    ensure!(
        archive.promotion_evidence == promotion_evidence,
        "partial archive promotion_evidence mismatch"
    );
    Ok(())
}

fn validate_archive_disposition(
    repo_root: &Path,
    manifest: &ProposalManifest,
    disposition: &str,
    promotion_evidence: &[String],
    recovered_partial_archive: bool,
) -> Result<()> {
    match disposition {
        "implemented" => {
            if recovered_partial_archive {
                let archive = manifest
                    .archive
                    .as_ref()
                    .context("implemented partial archive recovery requires archive metadata")?;
                ensure!(
                    archive.archived_from_status == "implemented",
                    "archive-proposal with disposition=implemented requires archived_from_status=implemented, found {}",
                    archive.archived_from_status
                );
            } else {
                ensure!(
                    manifest.status == "implemented",
                    "archive-proposal with disposition=implemented requires status=implemented, found {}",
                    manifest.status
                );
            }
            validate_repo_relative_paths(repo_root, promotion_evidence, "promotion_evidence")?;
        }
        "rejected" => {
            if recovered_partial_archive {
                let archive = manifest
                    .archive
                    .as_ref()
                    .context("rejected partial archive recovery requires archive metadata")?;
                ensure!(
                    archive.archived_from_status == "rejected",
                    "archive-proposal with disposition=rejected requires archived_from_status=rejected, found {}",
                    archive.archived_from_status
                );
            } else {
                ensure!(
                    manifest.status == "rejected",
                    "archive-proposal with disposition=rejected requires status=rejected, found {}",
                    manifest.status
                );
            }
        }
        "historical" => {
            if !promotion_evidence.is_empty() {
                validate_repo_relative_paths(repo_root, promotion_evidence, "promotion_evidence")?;
            }
        }
        "superseded" => {
            validate_repo_relative_paths(repo_root, promotion_evidence, "promotion_evidence")?;
        }
        other => bail!("unsupported archive disposition '{}'", other),
    }
    Ok(())
}

fn ensure_archive_gitignore_allowlist(repo_root: &Path, archived_rel: &str) -> Result<()> {
    let gitignore_path = repo_root.join(".gitignore");
    let mut contents = fs::read_to_string(&gitignore_path).unwrap_or_default();
    let dir_line = format!("!{archived_rel}/");
    let tree_line = format!("!{archived_rel}/**");
    if contents.lines().any(|line| line == dir_line)
        && contents.lines().any(|line| line == tree_line)
    {
        return Ok(());
    }
    let marker = "!.octon/inputs/exploratory/proposals/.archive/architecture/";
    let mut lines: Vec<String> = contents.lines().map(ToString::to_string).collect();
    let insert_at = lines
        .iter()
        .rposition(|line| line.starts_with("!.octon/inputs/exploratory/proposals/.archive/"))
        .map(|index| index + 1)
        .or_else(|| {
            lines
                .iter()
                .position(|line| line == marker)
                .map(|index| index + 1)
        })
        .unwrap_or(lines.len());
    if !lines.iter().any(|line| line == &dir_line) {
        lines.insert(insert_at, dir_line);
    }
    let tree_insert_at = lines
        .iter()
        .position(|line| line == &format!("!{archived_rel}/"))
        .map(|index| index + 1)
        .unwrap_or(insert_at + 1);
    if !lines.iter().any(|line| line == &tree_line) {
        lines.insert(tree_insert_at, tree_line);
    }
    contents = lines.join("\n");
    contents.push('\n');
    fs::write(&gitignore_path, contents)
        .with_context(|| format!("write {}", gitignore_path.display()))
}

fn regenerate_proposal_artifact_index(repo_root: &Path, proposal_rel: &str) -> Result<()> {
    let generator = repo_root.join(
        ".octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh",
    );
    ensure!(
        generator.is_file(),
        "proposal artifact index generator missing: {}",
        generator.display()
    );
    let output = Command::new("bash")
        .arg(&generator)
        .arg("--proposal")
        .arg(proposal_rel)
        .arg("--write")
        .current_dir(repo_root)
        .output()
        .with_context(|| {
            format!(
                "run proposal artifact index generator {}",
                generator.display()
            )
        })?;
    if !output.status.success() {
        bail!(
            "proposal artifact index generator failed via --write (status {})\nstdout:\n{}\nstderr:\n{}",
            output.status,
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr),
        );
    }
    Ok(())
}

fn static_primary_docs(kind: StaticProposalKind) -> Vec<&'static str> {
    match kind {
        StaticProposalKind::Migration => vec![
            "`migration/plan.md`",
            "`migration/release-notes.md`",
            "`migration/rollback.md`",
        ],
        StaticProposalKind::Policy => vec![
            "`policy/decision.md`",
            "`policy/policy-delta.md`",
            "`policy/enforcement-plan.md`",
        ],
        StaticProposalKind::Architecture => vec![
            "`architecture/target-architecture.md`",
            "`architecture/acceptance-criteria.md`",
            "`architecture/implementation-plan.md`",
        ],
    }
}

fn static_subtype_manifest_name(kind: StaticProposalKind) -> &'static str {
    match kind {
        StaticProposalKind::Migration => "migration-proposal.yml",
        StaticProposalKind::Policy => "policy-proposal.yml",
        StaticProposalKind::Architecture => "architecture-proposal.yml",
    }
}

fn static_standard_path(kind: StaticProposalKind) -> &'static str {
    match kind {
        StaticProposalKind::Migration => {
            ".octon/framework/scaffolding/governance/patterns/migration-proposal-standard.md"
        }
        StaticProposalKind::Policy => {
            ".octon/framework/scaffolding/governance/patterns/policy-proposal-standard.md"
        }
        StaticProposalKind::Architecture => {
            ".octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md"
        }
    }
}

fn static_schema_path(kind: StaticProposalKind) -> &'static str {
    match kind {
        StaticProposalKind::Migration => {
            ".octon/framework/scaffolding/runtime/templates/migration-proposal.schema.json"
        }
        StaticProposalKind::Policy => {
            ".octon/framework/scaffolding/runtime/templates/policy-proposal.schema.json"
        }
        StaticProposalKind::Architecture => {
            ".octon/framework/scaffolding/runtime/templates/architecture-proposal.schema.json"
        }
    }
}

fn static_validator_rel(kind: StaticProposalKind) -> &'static str {
    match kind {
        StaticProposalKind::Migration => {
            ".octon/framework/assurance/runtime/_ops/scripts/validate-migration-proposal.sh"
        }
        StaticProposalKind::Policy => {
            ".octon/framework/assurance/runtime/_ops/scripts/validate-policy-proposal.sh"
        }
        StaticProposalKind::Architecture => {
            ".octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh"
        }
    }
}

fn build_static_source_of_truth_map(kind: StaticProposalKind) -> String {
    let primary_docs = format_markdown_bullets(static_primary_docs(kind));
    format!(
        "# Proposal Reading And Precedence Map\n\n## Purpose\n\nThis file defines the proposal-local reading order, authority boundaries, and evidence model for this temporary {} proposal. It does not make the proposal a canonical repository authority.\n\n## External Authorities\n\n| Concern | Source of truth | Notes |\n| --- | --- | --- |\n| Repo-wide authority and non-canonical rules | `.octon/README.md`, `.octon/framework/cognition/_meta/architecture/specification.md`, `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` | These durable surfaces outrank this proposal. |\n| Proposal workspace layout and lifecycle contract | `.octon/inputs/exploratory/proposals/README.md`, `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`, `{}` | These durable proposal rules define placement, lifecycle, and subtype requirements. |\n| Subtype contract | `{}`, `{}` | The subtype manifest shape, template, and validator behavior must remain aligned. |\n| Proposal registry projection contract | `.octon/generated/proposals/registry.yml`, `.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json` | The registry is projection-only and never outranks the manifests. |\n| Workflow evidence location | `.octon/state/evidence/runs/workflows/`, `.octon/state/evidence/validation/` | Proposal operation receipts belong under retained evidence, not inside the proposal packet. |\n\n## Primary Proposal Inputs\n\n1. `proposal.yml`\n2. `{}`\n3. `navigation/source-of-truth-map.md`\n4. {}\n5. `navigation/artifact-catalog.md`\n6. `/.octon/generated/proposals/registry.yml`\n\n## Proposal-Local Authority Roles\n\n| Artifact | Role | Authority level |\n| --- | --- | --- |\n| `proposal.yml` | Base identity, scope, targets, lifecycle, and exit contract | Highest proposal-local |\n| `{}` | Subtype-specific structured contract | Secondary proposal-local |\n| Primary subtype docs | The proposal's working design/architecture/policy surface | Primary working surface |\n| `navigation/source-of-truth-map.md` | Manual proposal-local precedence, authority, and evidence map | Explanatory support |\n| `navigation/artifact-catalog.md` | Generated file inventory for the current packet shape | Low-authority generated inventory |\n| `/.octon/generated/proposals/registry.yml` | Discovery projection rebuilt from proposal manifests | Projection only |\n| `README.md` | Human entry point and reading guidance | Explanatory only |\n\n## Derived Or Projection-Only Surfaces\n\n| Surface | Status | Rule |\n| --- | --- | --- |\n| `/.octon/generated/proposals/registry.yml` | Committed projection | Must be regenerated from manifests or fail-closed validated; never authoritative over manifests |\n| `navigation/artifact-catalog.md` | Generated inventory | Reflects the current packet shape but does not define lifecycle truth |\n| Workflow bundles under `state/evidence/runs/workflows/**` | Retained evidence | Evidence of proposal operations, not lifecycle authority |\n\n## Conflict Resolution\n\n1. Repository-wide governance and durable authorities\n2. `proposal.yml`\n3. `{}`\n4. Primary subtype docs\n5. `navigation/source-of-truth-map.md`\n6. `navigation/artifact-catalog.md`\n7. `/.octon/generated/proposals/registry.yml`\n8. `README.md`\n\n## Boundary Rules\n\n- This proposal remains temporary and non-canonical at every lifecycle stage.\n- Durable runtime, documentation, policy, and contract outputs must be promoted outside `/.octon/inputs/exploratory/proposals/`.\n- Proposal discovery is allowed through the committed registry projection, but lifecycle truth stays in `proposal.yml` and the subtype manifest.\n- Proposal operation evidence belongs under `state/evidence/**`, not inside the proposal packet or under `generated/**`.\n",
        kind.as_str(),
        static_standard_path(kind),
        static_schema_path(kind),
        static_validator_rel(kind),
        static_subtype_manifest_name(kind),
        primary_docs,
        static_subtype_manifest_name(kind),
        static_subtype_manifest_name(kind),
    )
}

fn catalog_inventory(package_root: &Path) -> Result<Vec<String>> {
    let mut entries = Vec::new();
    for path in snapshot_package(package_root)?.keys() {
        if path.split('/').any(|segment| segment.starts_with('.')) {
            continue;
        }
        entries.push(path.clone());
    }
    Ok(entries)
}

fn build_artifact_catalog(
    package_root: &Path,
    proposal_kind: &str,
    package_id: &str,
    package_rel: &str,
) -> Result<String> {
    let inventory = catalog_inventory(package_root)?;
    let entries = if inventory.is_empty() {
        "| _none_ | No visible files recorded |\n".to_string()
    } else {
        inventory
            .iter()
            .map(|path| format!("| `{path}` | Generated inventory entry |\n"))
            .collect::<String>()
    };
    Ok(format!(
        "# Artifact Catalog\n\nThis catalog is generated from the on-disk proposal packet shape. Regenerate it whenever files are added, removed, or reorganized.\n\n## Proposal\n\n- `proposal_id`: `{}`\n- `proposal_kind`: `{}`\n- `proposal_path`: `{}`\n\n## Files\n\n| Path | Role |\n| --- | --- |\n{}",
        package_id, proposal_kind, package_rel, entries
    ))
}

fn apply_template_bundle(
    template_root: &Path,
    package_root: &Path,
    replacements: &BTreeMap<String, String>,
) -> Result<()> {
    let manifest = template_root.join("manifest.json");
    if !manifest.is_file() {
        bail!(
            "template bundle missing manifest.json: {}",
            template_root.display()
        );
    }

    for entry in WalkDir::new(template_root)
        .follow_links(false)
        .into_iter()
        .filter_map(|entry| entry.ok())
    {
        if !entry.file_type().is_file() {
            continue;
        }
        let source = entry.path();
        let rel = source
            .strip_prefix(template_root)
            .with_context(|| format!("strip template prefix from {}", source.display()))?;
        if rel == Path::new("manifest.json") {
            continue;
        }

        let rendered = render_template_text(
            &fs::read_to_string(source)
                .with_context(|| format!("read template file {}", source.display()))?,
            replacements,
        );
        let destination = package_root.join(rel);
        if let Some(parent) = destination.parent() {
            fs::create_dir_all(parent).with_context(|| format!("create {}", parent.display()))?;
        }
        fs::write(&destination, rendered)
            .with_context(|| format!("write scaffolded file {}", destination.display()))?;
    }

    Ok(())
}

fn render_template_text(template: &str, replacements: &BTreeMap<String, String>) -> String {
    let mut rendered = template.to_string();
    for (key, value) in replacements {
        rendered = rendered.replace(&format!("{{{{{key}}}}}"), value);
    }
    rendered
}

fn format_yaml_list<'a>(items: impl IntoIterator<Item = &'a str>) -> String {
    let collected = items
        .into_iter()
        .map(|item| format!("  - \"{}\"\n", item.replace('"', "\\\"")))
        .collect::<String>();
    if collected.is_empty() {
        "  []\n".to_string()
    } else {
        collected
    }
}

fn format_markdown_bullets<'a>(items: impl IntoIterator<Item = &'a str>) -> String {
    let collected = items
        .into_iter()
        .map(|item| format!("- {item}\n"))
        .collect::<String>();
    if collected.is_empty() {
        "- none\n".to_string()
    } else {
        collected.trim_end().to_string()
    }
}

fn run_standard_design_package_validator(
    repo_root: &Path,
    package_root: &Path,
    bundle_root: &Path,
) -> Result<PathBuf> {
    run_design_proposal_validator_stack(repo_root, package_root, bundle_root)
}

fn build_create_design_package_summary(
    repo_root: &Path,
    package_root: &Path,
    bundle_root: &Path,
    summary_report: &Path,
    options: &RunCreateDesignPackageOptions,
    selected_modules: &[&str],
    validator_log: Option<&Path>,
    final_verdict: &str,
    failure: Option<&CreateDesignPackageFailure>,
    notes: &[String],
) -> String {
    let mut body = String::new();
    body.push_str("# Create Design Package Summary\n\n");
    body.push_str(&format!(
        "- workflow_id: `create-design-proposal`\n- package_path: `{}`\n- package_class: `{}`\n- final_verdict: `{}`\n- bundle_root: `{}`\n- summary_report: `{}`\n",
        rel_path(repo_root, package_root),
        options.package_class.as_str(),
        final_verdict,
        rel_path(repo_root, bundle_root),
        rel_path(repo_root, summary_report),
    ));
    if let Some(validator_log) = validator_log {
        body.push_str(&format!(
            "- validator_log: `{}`\n",
            rel_path(repo_root, validator_log)
        ));
    }
    if let Some(failure) = failure {
        body.push_str(&format!(
            "- failure_class: `{}`\n- failed_stage: `{}`\n",
            failure.class.as_str(),
            failure.failed_stage,
        ));
    }
    body.push_str("\n## Selected Modules\n\n");
    body.push_str(&format!(
        "{}\n\n",
        format_markdown_bullets(selected_modules.iter().copied())
    ));
    body.push_str("## Implementation Targets\n\n");
    body.push_str(&format!(
        "{}\n\n",
        format_markdown_bullets(options.implementation_targets.iter().map(String::as_str))
    ));
    body.push_str("## Notes\n\n");
    if notes.is_empty() {
        body.push_str("- no additional notes\n");
    } else {
        for note in notes {
            body.push_str(&format!("- {note}\n"));
        }
    }
    body.push_str("\n## Next Steps\n\n");
    if final_verdict == "scaffolded" {
        body.push_str(&format!(
            "1. Fill in the proposal-specific normative and implementation details.\n2. Run `/audit-design-proposal proposal_path=\"{}\"` to mature the proposal.\n3. Promote durable outputs into the listed implementation targets before archiving the proposal.\n",
            rel_path(repo_root, package_root),
        ));
    } else {
        body.push_str(
            "1. Inspect `validation.md`, `commands.md`, and any stage logs in the workflow bundle.\n2. Fix the recorded failure cause.\n3. Re-run `/create-design-proposal` with the same request after the failure is resolved.\n",
        );
    }
    body
}

fn regenerate_proposal_registry(repo_root: &Path, write: bool) -> Result<()> {
    let generator = repo_root.join(PROPOSAL_REGISTRY_GENERATOR_REL);
    ensure!(
        generator.is_file(),
        "proposal registry generator missing: {}",
        generator.display()
    );

    let mode = if write { "--write" } else { "--check" };
    let output = Command::new("bash")
        .arg(&generator)
        .arg(mode)
        .env("OCTON_PROPOSAL_REGISTRY_SKIP_SUBTYPE_VALIDATION", "1")
        .current_dir(repo_root)
        .output()
        .with_context(|| format!("run proposal registry generator {}", generator.display()))?;
    if !output.status.success() {
        bail!(
            "proposal registry generator failed via {} (status {})\nstdout:\n{}\nstderr:\n{}",
            mode,
            output.status,
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr),
        );
    }
    Ok(())
}

fn proposal_registry_active_status_matches(
    repo_root: &Path,
    proposal_rel: &str,
    proposal_kind: &str,
    proposal_id: &str,
    expected_status: &str,
) -> Result<bool> {
    let registry_path = repo_root.join(".octon/generated/proposals/registry.yml");
    ensure!(
        registry_path.is_file(),
        "proposal registry missing: {}",
        registry_path.display()
    );
    let registry: ProposalRegistry = serde_yaml::from_str(
        &fs::read_to_string(&registry_path)
            .with_context(|| format!("read {}", registry_path.display()))?,
    )
    .with_context(|| format!("parse {}", registry_path.display()))?;
    Ok(registry.active.iter().any(|entry| {
        entry.path == proposal_rel
            && entry.kind == proposal_kind
            && entry.id == proposal_id
            && entry.status == expected_status
    }))
}

fn write_create_stage_input(
    bundle_root: &Path,
    stage_id: &str,
    stage_slug: &str,
    body: &str,
) -> Result<PathBuf> {
    let path = bundle_root
        .join("stage-inputs")
        .join(format!("{stage_id}-{stage_slug}.md"));
    fs::write(&path, body).with_context(|| format!("write {}", path.display()))?;
    Ok(path)
}

fn write_create_stage_log(
    bundle_root: &Path,
    stage_id: &str,
    stage_slug: &str,
    status: &str,
    body: &str,
) -> Result<PathBuf> {
    let path = bundle_root
        .join("stage-logs")
        .join(format!("{stage_id}-{stage_slug}.log"));
    fs::write(
        &path,
        format!("# Stage {stage_id}\n\n- stage: `{stage_slug}`\n- status: `{status}`\n\n{body}\n"),
    )
    .with_context(|| format!("write {}", path.display()))?;
    Ok(path)
}

fn write_create_inventory(bundle_root: &Path, package_root: &Path) -> Result<()> {
    let path = bundle_root.join("inventory.md");
    let body = if package_root.is_dir() {
        let inventory = snapshot_package(package_root)?;
        let mut body = String::new();
        body.push_str("# Scaffolded Proposal Inventory\n\n");
        body.push_str(&format!(
            "- proposal_path: `{}`\n- file_count: `{}`\n\n",
            package_root.display(),
            inventory.len()
        ));
        for path in inventory.keys() {
            body.push_str(&format!("- `{path}`\n"));
        }
        body
    } else {
        "# Scaffolded Proposal Inventory\n\n- proposal_path: `not-created`\n- file_count: `0`\n"
            .to_string()
    };
    fs::write(&path, body).with_context(|| format!("write {}", path.display()))
}

fn write_create_commands_log(bundle_root: &Path, command_log: &[String]) -> Result<()> {
    let path = bundle_root.join("commands.md");
    let mut body = String::from("# Stage Commands\n\n");
    if command_log.is_empty() {
        body.push_str("- no stage commands or receipts recorded\n");
    } else {
        for entry in command_log {
            body.push_str(entry);
            body.push('\n');
        }
    }
    fs::write(&path, body).with_context(|| format!("write {}", path.display()))
}

fn write_create_validation(
    bundle_root: &Path,
    package_root: &Path,
    final_verdict: &str,
    failure: Option<&CreateDesignPackageFailure>,
    validator_log: Option<&Path>,
    registry_synced: bool,
    notes: &[String],
) -> Result<()> {
    let mut body = String::from("# Validation\n\n");
    body.push_str(&format!("- final_verdict: `{final_verdict}`\n"));
    if let Some(failure) = failure {
        body.push_str(&format!(
            "- failure_class: `{}`\n- failed_stage: `{}`\n",
            failure.class.as_str(),
            failure.failed_stage,
        ));
    }
    body.push_str("\n## Checks\n\n");
    body.push_str(&format!(
        "- [{}] scaffolded proposal directory exists under `/.octon/inputs/exploratory/proposals/`\n",
        if package_root.is_dir() { "x" } else { " " }
    ));
    body.push_str(&format!(
        "- [{}] `proposal.yml` and subtype manifest are present\n",
        if package_root.join("proposal.yml").is_file()
            && (package_root.join("design-proposal.yml").is_file()
                || package_root.join("migration-proposal.yml").is_file()
                || package_root.join("policy-proposal.yml").is_file()
                || package_root.join("architecture-proposal.yml").is_file())
        {
            "x"
        } else {
            " "
        }
    ));
    body.push_str(&format!(
        "- [{}] `registry.yml` includes the scaffolded proposal\n",
        if registry_synced { "x" } else { " " }
    ));
    body.push_str(&format!(
        "- [{}] workflow bundle contract files exist\n",
        if bundle_root.join("bundle.yml").is_file()
            && bundle_root.join("summary.md").is_file()
            && bundle_root.join("commands.md").is_file()
            && bundle_root.join("validation.md").is_file()
            && bundle_root.join("inventory.md").is_file()
        {
            "x"
        } else {
            " "
        }
    ));
    body.push_str(&format!(
        "- [{}] `reports/`, `stage-inputs/`, and `stage-logs/` exist\n",
        if bundle_root.join("reports").is_dir()
            && bundle_root.join("stage-inputs").is_dir()
            && bundle_root.join("stage-logs").is_dir()
        {
            "x"
        } else {
            " "
        }
    ));
    body.push_str(&format!(
        "- [{}] `standard-validator.log` exists\n",
        if validator_log.is_some() { "x" } else { " " }
    ));
    body.push_str("\n## Notes\n\n");
    if notes.is_empty() {
        body.push_str("- no additional notes\n");
    } else {
        for note in notes {
            body.push_str(&format!("- {note}\n"));
        }
    }
    fs::write(bundle_root.join("validation.md"), body)
        .with_context(|| format!("write {}", bundle_root.join("validation.md").display()))
}

fn write_create_bundle_metadata(
    repo_root: &Path,
    bundle_root: &Path,
    summary_report: &Path,
    options: &RunCreateDesignPackageOptions,
    final_verdict: &str,
    failure: Option<&CreateDesignPackageFailure>,
    started_at: &str,
) -> Result<()> {
    let metadata = CreateDesignPackageBundleMetadata {
        kind: "workflow-execution-bundle".to_string(),
        id: bundle_root
            .file_name()
            .and_then(|value| value.to_str())
            .unwrap_or("workflow-bundle")
            .to_string(),
        workflow_id: "create-design-proposal".to_string(),
        package_id: options.package_id.clone(),
        package_class: options.package_class.as_str().to_string(),
        started_at: started_at.to_string(),
        completed_at: now_rfc3339()?,
        summary: "summary.md".to_string(),
        commands: "commands.md".to_string(),
        validation: "validation.md".to_string(),
        inventory: "inventory.md".to_string(),
        reports_dir: "reports".to_string(),
        stage_inputs_dir: "stage-inputs".to_string(),
        stage_logs_dir: "stage-logs".to_string(),
        summary_report: rel_path(repo_root, summary_report),
        final_verdict: final_verdict.to_string(),
        failure_class: failure.map(|failure| failure.class.as_str().to_string()),
        failed_stage: failure.map(|failure| failure.failed_stage.to_string()),
    };
    let yaml = serde_yaml::to_string(&metadata)?;
    fs::write(bundle_root.join("bundle.yml"), yaml)
        .with_context(|| format!("write {}", bundle_root.join("bundle.yml").display()))
}

fn run_design_proposal_validator_stack(
    repo_root: &Path,
    proposal_root: &Path,
    bundle_root: &Path,
) -> Result<PathBuf> {
    run_proposal_validator_stack(repo_root, proposal_root, bundle_root, "design")
}

fn run_static_proposal_validator_stack(
    repo_root: &Path,
    proposal_root: &Path,
    bundle_root: &Path,
    kind: StaticProposalKind,
) -> Result<PathBuf> {
    run_proposal_validator_stack(repo_root, proposal_root, bundle_root, kind.as_str())
}

fn proposal_validator_rel(proposal_kind: &str) -> Result<&'static str> {
    match proposal_kind {
        "design" => Ok(STANDARD_DESIGN_PACKAGE_VALIDATOR_REL),
        "migration" => Ok(static_validator_rel(StaticProposalKind::Migration)),
        "policy" => Ok(static_validator_rel(StaticProposalKind::Policy)),
        "architecture" => Ok(static_validator_rel(StaticProposalKind::Architecture)),
        other => bail!("unsupported proposal kind '{}'", other),
    }
}

fn run_proposal_validator_stack(
    repo_root: &Path,
    proposal_root: &Path,
    bundle_root: &Path,
    proposal_kind: &str,
) -> Result<PathBuf> {
    run_proposal_validator_stack_with_standard_args(
        repo_root,
        proposal_root,
        bundle_root,
        proposal_kind,
        &[],
    )
}

fn run_archive_proposal_validator_stack(
    repo_root: &Path,
    proposal_root: &Path,
    bundle_root: &Path,
    proposal_kind: &str,
) -> Result<PathBuf> {
    run_proposal_validator_stack_with_standard_args(
        repo_root,
        proposal_root,
        bundle_root,
        proposal_kind,
        &["--skip-registry-check"],
    )
}

fn run_promote_proposal_validator_stack(
    repo_root: &Path,
    proposal_root: &Path,
    bundle_root: &Path,
    proposal_kind: &str,
) -> Result<PathBuf> {
    run_proposal_validator_stack_with_standard_args(
        repo_root,
        proposal_root,
        bundle_root,
        proposal_kind,
        &["--skip-registry-check"],
    )
}

fn run_proposal_validator_stack_with_standard_args(
    repo_root: &Path,
    proposal_root: &Path,
    bundle_root: &Path,
    proposal_kind: &str,
    standard_validator_extra_args: &[&str],
) -> Result<PathBuf> {
    let kind_validator_rel = proposal_validator_rel(proposal_kind)?;
    let validators = [
        ProposalValidatorInvocation {
            rel: ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh",
            extra_args: standard_validator_extra_args,
        },
        ProposalValidatorInvocation {
            rel: kind_validator_rel,
            extra_args: &[],
        },
    ];
    run_validator_stack(repo_root, proposal_root, bundle_root, &validators)
}

fn run_proposal_review_gate_validator(
    repo_root: &Path,
    proposal_root: &Path,
    bundle_root: &Path,
    require_implementation_authorization: bool,
) -> Result<PathBuf> {
    let proposal_rel = rel_path(repo_root, proposal_root);
    let log_path = bundle_root.join("standard-validator.log");
    let script = repo_root.join(PROPOSAL_REVIEW_GATE_VALIDATOR_REL);
    if !script.is_file() {
        bail!("missing proposal validator: {}", script.display());
    }

    let mut command = Command::new("bash");
    command
        .arg(&script)
        .arg("--package")
        .arg(&proposal_rel)
        .current_dir(repo_root);
    if require_implementation_authorization {
        command.arg("--require-implementation-authorization");
    }
    let output = command.output().with_context(|| {
        format!(
            "run validator {} for {}",
            PROPOSAL_REVIEW_GATE_VALIDATOR_REL,
            proposal_root.display()
        )
    })?;

    let mut log = if log_path.is_file() {
        fs::read_to_string(&log_path).unwrap_or_default()
    } else {
        String::from("# Proposal Validator Stack\n\n")
    };
    if !log.ends_with('\n') {
        log.push('\n');
    }
    let suffix = if require_implementation_authorization {
        " --require-implementation-authorization"
    } else {
        ""
    };
    log.push_str(&format!(
        "## `{}`{}\n\n- proposal: `{}`\n- status: `{}`\n\n### stdout\n\n```\n{}\n```\n\n### stderr\n\n```\n{}\n```\n\n",
        PROPOSAL_REVIEW_GATE_VALIDATOR_REL,
        suffix,
        proposal_rel,
        output.status,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr),
    ));
    fs::write(&log_path, &log)?;
    if !output.status.success() {
        bail!(
            "proposal validator failed for {} via {}{} (see {})",
            proposal_rel,
            PROPOSAL_REVIEW_GATE_VALIDATOR_REL,
            suffix,
            log_path.display()
        );
    }

    Ok(log_path)
}

#[derive(Clone, Copy, Debug)]
struct ProposalValidatorInvocation<'a> {
    rel: &'a str,
    extra_args: &'a [&'a str],
}

fn run_validator_stack(
    repo_root: &Path,
    proposal_root: &Path,
    bundle_root: &Path,
    validators: &[ProposalValidatorInvocation<'_>],
) -> Result<PathBuf> {
    let proposal_rel = rel_path(repo_root, proposal_root);
    let log_path = bundle_root.join("standard-validator.log");
    let mut log = String::from("# Proposal Validator Stack\n\n");

    for validator in validators {
        let script = repo_root.join(validator.rel);
        if !script.is_file() {
            bail!("missing proposal validator: {}", script.display());
        }
        let mut command = Command::new("bash");
        command.arg(&script).arg("--package").arg(&proposal_rel);
        for extra_arg in validator.extra_args {
            command.arg(extra_arg);
        }
        let output = command.current_dir(repo_root).output().with_context(|| {
            format!(
                "run validator {} for {}",
                validator.rel,
                proposal_root.display()
            )
        })?;
        let extra_args = if validator.extra_args.is_empty() {
            String::new()
        } else {
            format!(" {}", validator.extra_args.join(" "))
        };
        log.push_str(&format!(
            "## `{}`{}\n\n- proposal: `{}`\n- status: `{}`\n\n### stdout\n\n```\n{}\n```\n\n### stderr\n\n```\n{}\n```\n\n",
            validator.rel,
            extra_args,
            proposal_rel,
            output.status,
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr),
        ));
        if !output.status.success() {
            fs::write(&log_path, &log)?;
            bail!(
                "proposal validator failed for {} via {} (see {})",
                proposal_rel,
                validator.rel,
                log_path.display()
            );
        }
    }

    fs::write(&log_path, log)?;
    Ok(log_path)
}

fn build_static_proposal_replacements(
    kind: StaticProposalKind,
    options: &RunCreateStaticProposalOptions,
    exit_expectation: &str,
) -> BTreeMap<String, String> {
    let mut replacements = BTreeMap::new();
    replacements.insert("PROPOSAL_ID".to_string(), options.proposal_id.clone());
    replacements.insert(
        "PROPOSAL_TITLE".to_string(),
        options.proposal_title.trim().to_string(),
    );
    replacements.insert(
        "PROPOSAL_SUMMARY".to_string(),
        format!(
            "Temporary implementation-scoped {} proposal.",
            kind.as_str()
        ),
    );
    replacements.insert("PROPOSAL_KIND".to_string(), kind.as_str().to_string());
    replacements.insert(
        "PROMOTION_SCOPE".to_string(),
        options.promotion_scope.as_str().to_string(),
    );
    replacements.insert(
        "PROMOTION_TARGETS_YAML".to_string(),
        format_yaml_list(options.promotion_targets.iter().map(String::as_str)),
    );
    replacements.insert(
        "PROMOTION_TARGETS_BULLETS".to_string(),
        format_markdown_bullets(options.promotion_targets.iter().map(String::as_str)),
    );
    replacements.insert("EXIT_EXPECTATION".to_string(), exit_expectation.to_string());
    replacements.insert("PROPOSAL_STATUS".to_string(), "draft".to_string());
    replacements.insert("RELATED_PROPOSALS_YAML".to_string(), "  []\n".to_string());
    replacements
}

fn load_proposal_manifest(proposal_root: &Path) -> Result<ProposalManifest> {
    let manifest_path = proposal_root.join("proposal.yml");
    let raw = fs::read_to_string(&manifest_path)
        .with_context(|| format!("read {}", manifest_path.display()))?;
    serde_yaml::from_str(&raw).with_context(|| format!("parse {}", manifest_path.display()))
}

fn write_proposal_manifest(proposal_root: &Path, manifest: &ProposalManifest) -> Result<()> {
    let manifest_path = proposal_root.join("proposal.yml");
    fs::write(&manifest_path, serde_yaml::to_string(manifest)?)
        .with_context(|| format!("write {}", manifest_path.display()))
}

fn validate_repo_relative_paths(repo_root: &Path, paths: &[String], label: &str) -> Result<()> {
    ensure!(!paths.is_empty(), "{} must not be empty", label);
    for path in paths {
        ensure!(
            !path.starts_with('/'),
            "{} must use repo-relative paths: {}",
            label,
            path
        );
        let canonical = repo_root
            .join(path)
            .canonicalize()
            .with_context(|| format!("resolve {} path {}", label, path))?;
        ensure!(
            canonical.starts_with(repo_root),
            "{} path must stay inside the repository root: {}",
            label,
            path
        );
        ensure!(canonical.exists(), "{} path must exist: {}", label, path);
    }
    Ok(())
}

fn ensure_promotion_targets_ready(
    repo_root: &Path,
    manifest: &ProposalManifest,
    proposal_root: &Path,
) -> Result<()> {
    let active_rel = rel_path(repo_root, proposal_root);
    let archived_rel =
        expected_archived_proposal_rel(&manifest.proposal_kind, &manifest.proposal_id);

    for target in &manifest.promotion_targets {
        let target_path = repo_root.join(target);
        ensure!(
            target_path.exists(),
            "promotion target must exist before promotion: {}",
            target
        );

        for pattern in [&active_rel, &archived_rel] {
            let output = Command::new("grep")
                .arg("-R")
                .arg("-n")
                .arg("-F")
                .arg(pattern)
                .arg(&target_path)
                .current_dir(repo_root)
                .output()
                .with_context(|| {
                    format!(
                        "scan promotion target {} for proposal references",
                        target_path.display()
                    )
                })?;
            if output.status.success() {
                bail!(
                    "promotion target retains proposal-path dependency: {}\n{}",
                    target,
                    String::from_utf8_lossy(&output.stdout)
                );
            }
        }
    }

    Ok(())
}

fn build_static_create_summary(
    repo_root: &Path,
    proposal_root: &Path,
    bundle_root: &Path,
    summary_report: &Path,
    kind: StaticProposalKind,
    options: &RunCreateStaticProposalOptions,
    validator_log: &Path,
) -> String {
    format!(
        "# Create {} Proposal Summary\n\n- workflow_id: `create-{}-proposal`\n- proposal_path: `{}`\n- promotion_scope: `{}`\n- final_verdict: `scaffolded`\n- bundle_root: `{}`\n- summary_report: `{}`\n- validator_log: `{}`\n",
        kind.as_str(),
        kind.as_str(),
        rel_path(repo_root, proposal_root),
        options.promotion_scope.as_str(),
        rel_path(repo_root, bundle_root),
        rel_path(repo_root, summary_report),
        rel_path(repo_root, validator_log),
    )
}

fn write_static_create_bundle_metadata(
    repo_root: &Path,
    bundle_root: &Path,
    summary_report: &Path,
    kind: StaticProposalKind,
    options: &RunCreateStaticProposalOptions,
    final_verdict: &str,
) -> Result<()> {
    let metadata = BundleMetadata {
        kind: "workflow-execution-bundle".to_string(),
        id: bundle_root
            .file_name()
            .and_then(|v| v.to_str())
            .unwrap_or("workflow-bundle")
            .to_string(),
        workflow_id: format!("create-{}-proposal", kind.as_str()),
        package_path: options.proposal_id.clone(),
        mode: "n/a".to_string(),
        executor: "n/a".to_string(),
        prepare_only: false,
        slug: kind.as_str().to_string(),
        started_at: now_rfc3339()?,
        completed_at: now_rfc3339()?,
        summary: "summary.md".to_string(),
        reports_dir: "reports".to_string(),
        stage_inputs_dir: "stage-inputs".to_string(),
        stage_logs_dir: "stage-logs".to_string(),
        selected_stages: vec![
            "validate-request".to_string(),
            "scaffold-proposal".to_string(),
            "validate-proposal".to_string(),
            "report".to_string(),
        ],
        report_paths: BTreeMap::new(),
        changed_files: BTreeMap::new(),
        plan: "plan.md".to_string(),
        inventory: "inventory.md".to_string(),
        commands: "commands.md".to_string(),
        validation: "validation.md".to_string(),
        summary_report: rel_path(repo_root, summary_report),
        final_verdict: final_verdict.to_string(),
        failure_class: None,
        failed_stage: None,
    };
    fs::write(
        bundle_root.join("bundle.yml"),
        serde_yaml::to_string(&metadata)?,
    )?;
    Ok(())
}

fn write_static_audit_validation(
    bundle_root: &Path,
    kind: StaticProposalKind,
    validator_log: &Path,
) -> Result<()> {
    let body = format!(
        "# Validation\n\n- final_verdict: `validated`\n- proposal_kind: `{}`\n- validator_log: `{}`\n",
        kind.as_str(),
        validator_log.display()
    );
    fs::write(bundle_root.join("validation.md"), body)?;
    Ok(())
}

fn write_static_audit_bundle_metadata(
    repo_root: &Path,
    bundle_root: &Path,
    summary_report: &Path,
    kind: StaticProposalKind,
    proposal_root: &Path,
) -> Result<()> {
    let metadata = BundleMetadata {
        kind: "workflow-execution-bundle".to_string(),
        id: bundle_root
            .file_name()
            .and_then(|v| v.to_str())
            .unwrap_or("workflow-bundle")
            .to_string(),
        workflow_id: format!("audit-{}-proposal", kind.as_str()),
        package_path: rel_path(repo_root, proposal_root),
        mode: "n/a".to_string(),
        executor: "n/a".to_string(),
        prepare_only: false,
        slug: kind.as_str().to_string(),
        started_at: now_rfc3339()?,
        completed_at: now_rfc3339()?,
        summary: "summary.md".to_string(),
        reports_dir: "reports".to_string(),
        stage_inputs_dir: "stage-inputs".to_string(),
        stage_logs_dir: "stage-logs".to_string(),
        selected_stages: vec![
            "configure".to_string(),
            "proposal-audit".to_string(),
            "report".to_string(),
            "verify".to_string(),
        ],
        report_paths: BTreeMap::new(),
        changed_files: BTreeMap::new(),
        plan: "plan.md".to_string(),
        inventory: "inventory.md".to_string(),
        commands: "commands.md".to_string(),
        validation: "validation.md".to_string(),
        summary_report: rel_path(repo_root, summary_report),
        final_verdict: "validated".to_string(),
        failure_class: None,
        failed_stage: None,
    };
    fs::write(
        bundle_root.join("bundle.yml"),
        serde_yaml::to_string(&metadata)?,
    )?;
    Ok(())
}

fn today_string() -> Result<String> {
    let format = format_description::parse("[year]-[month]-[day]")?;
    Ok(time::OffsetDateTime::now_utc().format(&format)?)
}

fn now_rfc3339() -> Result<String> {
    Ok(time::OffsetDateTime::now_utc().format(&time::format_description::well_known::Rfc3339)?)
}

fn unique_directory(parent: &Path, stem: &str) -> Result<PathBuf> {
    for idx in 0.. {
        let candidate = if idx == 0 {
            parent.join(stem)
        } else {
            parent.join(format!("{stem}-{idx}"))
        };
        if !candidate.exists() {
            fs::create_dir_all(&candidate)?;
            return Ok(candidate);
        }
    }
    bail!(
        "failed to allocate unique directory under {}",
        parent.display()
    )
}

fn unique_file(parent: &Path, stem: &str, extension: &str) -> Result<PathBuf> {
    for idx in 0.. {
        let candidate = if idx == 0 {
            parent.join(format!("{stem}.{extension}"))
        } else {
            parent.join(format!("{stem}-{idx}.{extension}"))
        };
        if !candidate.exists() {
            return Ok(candidate);
        }
    }
    bail!("failed to allocate unique file under {}", parent.display())
}

fn slugify(input: &str) -> String {
    let mut out = String::with_capacity(input.len());
    let mut prev_dash = false;
    for ch in input.chars() {
        let mapped = if ch.is_ascii_alphanumeric() {
            prev_dash = false;
            ch.to_ascii_lowercase()
        } else {
            if prev_dash {
                continue;
            }
            prev_dash = true;
            '-'
        };
        out.push(mapped);
    }
    let trimmed = out.trim_matches('-');
    if trimmed.is_empty() {
        "design-package".to_string()
    } else {
        trimmed.to_string()
    }
}

fn trim_md_suffix(name: &str) -> &str {
    name.strip_suffix(".md").unwrap_or(name)
}

fn snapshot_package(root: &Path) -> Result<BTreeMap<String, FileFingerprint>> {
    let mut files = BTreeMap::new();
    for entry in WalkDir::new(root)
        .follow_links(false)
        .into_iter()
        .filter_map(|entry| entry.ok())
    {
        if !entry.file_type().is_file() {
            continue;
        }
        let path = entry.path();
        let rel = rel_path(root, path);
        let bytes =
            fs::read(path).with_context(|| format!("read package file {}", path.display()))?;
        let sha256 = hex::encode(Sha256::digest(bytes));
        files.insert(rel, FileFingerprint { sha256 });
    }
    Ok(files)
}

fn diff_snapshots(
    before: &BTreeMap<String, FileFingerprint>,
    after: &BTreeMap<String, FileFingerprint>,
) -> Vec<FileChange> {
    let mut paths = BTreeSet::new();
    paths.extend(before.keys().cloned());
    paths.extend(after.keys().cloned());

    let mut changes = Vec::new();
    for path in paths {
        match (before.get(&path), after.get(&path)) {
            (None, Some(_)) => changes.push(FileChange {
                kind: "create",
                path,
            }),
            (Some(_), None) => changes.push(FileChange {
                kind: "delete",
                path,
            }),
            (Some(left), Some(right)) if left.sha256 != right.sha256 => changes.push(FileChange {
                kind: "update",
                path,
            }),
            _ => {}
        }
    }
    changes
}

fn report_has_change_receipt(report: &str) -> bool {
    let lower = report.to_ascii_lowercase();
    lower.contains("change manifest")
        || lower.contains("zero-change receipt")
        || lower.contains("zero change receipt")
        || lower.contains("no-op receipt")
        || lower.contains("no-op closure receipt")
}

fn rel_path(root: &Path, path: &Path) -> String {
    path.strip_prefix(root)
        .unwrap_or(path)
        .display()
        .to_string()
}

fn new_workflow_request_id(prefix: &str) -> String {
    let millis = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|duration| duration.as_millis())
        .unwrap_or(0);
    format!("{prefix}-{millis}-{}", std::process::id())
}

fn workflow_stage_request_id(parent_workflow_request_id: &str, stage_id: &str) -> String {
    format!("{parent_workflow_request_id}-{stage_id}")
}

fn validate_workflow_run_id(input: &str) -> Result<String> {
    let trimmed = input.trim();
    if trimmed.is_empty() {
        bail!("workflow --run-id must not be empty");
    }
    if trimmed.len() > 128 {
        bail!("workflow --run-id must be 128 characters or fewer");
    }
    if trimmed == "." || trimmed == ".." {
        bail!("workflow --run-id must not be a dot-segment");
    }
    if trimmed.contains('/') || trimmed.contains('\\') {
        bail!("workflow --run-id must not contain path separators");
    }
    if !trimmed
        .chars()
        .all(|ch| ch.is_ascii_lowercase() || ch.is_ascii_digit() || ch == '-')
    {
        bail!("workflow --run-id must match ^[a-z0-9-]+$");
    }
    if trimmed.starts_with('-') || trimmed.ends_with('-') || trimmed.contains("--") {
        bail!("workflow --run-id must use canonical hyphen-separated segments");
    }
    Ok(trimmed.to_string())
}

fn ensure_workflow_run_id_unused(cfg: &RuntimeConfig, request_id: &str) -> Result<()> {
    let existing_paths = [
        cfg.run_control_root(request_id),
        cfg.run_root(request_id),
        cfg.run_continuity_path(request_id),
        cfg.execution_control_root
            .join("approvals")
            .join("requests")
            .join(format!("{request_id}.yml")),
        cfg.execution_control_root
            .join("approvals")
            .join("grants")
            .join(format!("grant-{request_id}.yml")),
        cfg.octon_dir
            .join("state")
            .join("evidence")
            .join("control")
            .join("execution")
            .join(format!("authority-decision-{request_id}.yml")),
        cfg.octon_dir
            .join("state")
            .join("evidence")
            .join("control")
            .join("execution")
            .join(format!("authority-grant-bundle-{request_id}.yml")),
    ];

    if let Some(existing) = existing_paths.iter().find(|path| path.exists()) {
        bail!(
            "run id '{}' already exists in canonical execution artifacts at {}",
            request_id,
            existing.display()
        );
    }

    Ok(())
}

fn resolve_requested_workflow_run_id(
    cfg: &RuntimeConfig,
    requested: Option<&str>,
    fallback_prefix: &str,
    resume_existing: bool,
) -> Result<String> {
    match requested {
        Some(value) => {
            let run_id = validate_workflow_run_id(value)?;
            if !resume_existing {
                ensure_workflow_run_id_unused(cfg, &run_id)?;
            }
            Ok(run_id)
        }
        None => Ok(new_workflow_request_id(fallback_prefix)),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::os::unix::fs::PermissionsExt;
    use std::time::{SystemTime, UNIX_EPOCH};

    fn acquire_workflow_test_lock() -> std::sync::MutexGuard<'static, ()> {
        crate::acquire_kernel_test_lock()
    }

    fn make_temp_root(label: &str) -> PathBuf {
        let stamp = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("time should move forward")
            .as_nanos();
        let root = std::env::temp_dir().join(format!(
            "octon-kernel-workflow-{label}-{}-{stamp}",
            std::process::id()
        ));
        fs::create_dir_all(&root).expect("temp root should be created");
        root
    }

    fn make_locked_temp_root(label: &str) -> (std::sync::MutexGuard<'static, ()>, PathBuf) {
        let guard = acquire_workflow_test_lock();
        let root = make_temp_root(label);
        (guard, root)
    }

    fn seed_policy_runtime_env() {
        let source_root = source_repo_root();
        std::env::set_var(
            "OCTON_POLICY_RUNNER_OVERRIDE",
            source_root.join(".octon/framework/engine/runtime/policy"),
        );
        std::env::set_var(
            "OCTON_POLICY_BIN",
            source_root.join(
                ".octon/generated/.tmp/engine/build/runtime-crates-target/debug/octon-policy",
            ),
        );
    }

    fn write_file(path: &Path, contents: &str) {
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).expect("parent directory should exist");
        }
        fs::write(path, contents).expect("file should be written");
    }

    #[test]
    fn terminal_acp_diff_accepts_only_current_run_appends() {
        let run_id = "proposal-packet-terminal-closeout-123-456";
        let accepted = r#"diff --git a/.octon/state/evidence/decisions/repo/capabilities/acp-decisions.jsonl b/.octon/state/evidence/decisions/repo/capabilities/acp-decisions.jsonl
index 1111111..2222222 100644
--- a/.octon/state/evidence/decisions/repo/capabilities/acp-decisions.jsonl
+++ b/.octon/state/evidence/decisions/repo/capabilities/acp-decisions.jsonl
@@ -1,0 +2,2 @@
+{"run_id":"proposal-packet-terminal-closeout-123-456","decision":"allow"}
+{"run_id":"proposal-packet-terminal-closeout-123-456-bind-profile","decision":"allow"}
"#;
        assert!(terminal_acp_diff_additions_belong_to_run(accepted, run_id));

        let wrong_run = accepted.replace(
            "proposal-packet-terminal-closeout-123-456-bind-profile",
            "proposal-packet-terminal-closeout-999-000-bind-profile",
        );
        assert!(!terminal_acp_diff_additions_belong_to_run(
            &wrong_run, run_id
        ));

        let removed = format!("{accepted}-{{\"run_id\":\"{run_id}\",\"decision\":\"old\"}}\n");
        assert!(!terminal_acp_diff_additions_belong_to_run(&removed, run_id));

        let malformed = format!("{accepted}+not-json\n");
        assert!(!terminal_acp_diff_additions_belong_to_run(
            &malformed, run_id
        ));

        let missing_run_id = format!("{accepted}+{{\"decision\":\"allow\"}}\n");
        assert!(!terminal_acp_diff_additions_belong_to_run(
            &missing_run_id,
            run_id
        ));
    }

    #[test]
    fn proposal_manifest_round_trip_preserves_extra_fields() {
        let root = make_temp_root("manifest-extra-fields");
        let proposal_root = root.join("proposal");
        write_file(
            &proposal_root.join("proposal.yml"),
            r#"
schema_version: proposal-v1
proposal_id: extra-field-proposal
title: Extra Field Proposal
summary: Preserve extra fields when workflow status writers round-trip manifests.
proposal_kind: architecture
promotion_scope: octon-internal
promotion_targets:
  - framework/a.md
status: accepted
lifecycle:
  temporary: true
  exit_expectation: Keep metadata.
related_proposals:
  - parent-proposal
release_state: pre-1.0
change_profile: atomic
source_lineage:
  - resources/source.md
rollback_summary: Patch reversal.
"#,
        );

        let mut manifest = load_proposal_manifest(&proposal_root).unwrap();
        manifest.status = "implemented".to_string();
        write_proposal_manifest(&proposal_root, &manifest).unwrap();

        let raw = fs::read_to_string(proposal_root.join("proposal.yml")).unwrap();
        assert!(raw.contains("status: implemented"));
        assert!(raw.contains("release_state: pre-1.0"));
        assert!(raw.contains("change_profile: atomic"));
        assert!(raw.contains("source_lineage:"));
        assert!(raw.contains("rollback_summary: Patch reversal."));
    }

    fn seed_pipeline_fixture(root: &Path) -> (PathBuf, PathBuf) {
        seed_policy_runtime_env();
        let octon_dir = root.join(".octon");
        let source_root = source_repo_root();
        let copy_rel = |rel: &str| {
            let from = source_root.join(rel);
            let to = root.join(rel);
            if let Some(parent) = to.parent() {
                fs::create_dir_all(parent).expect("fixture parent should exist");
            }
            fs::copy(from, to).expect("fixture file should copy");
        };
        fs::create_dir_all(&octon_dir).expect(".octon dir should exist");
        fs::create_dir_all(octon_dir.join("instance/charter"))
            .expect("workspace charter dir should exist");
        write_file(
            &octon_dir.join("instance/charter/workspace.yml"),
            "schema_version: \"workspace-charter-v1\"\nworkspace_charter_id: \"workspace-charter://test/design-workflow\"\nversion: \"1.0.0\"\n",
        );
        fs::create_dir_all(octon_dir.join("framework/capabilities/governance/policy"))
            .expect("policy root should exist");
        copy_rel(".octon/octon.yml");
        copy_rel(".octon/framework/constitution/CHARTER.md");
        copy_rel(".octon/framework/constitution/obligations/fail-closed.yml");
        copy_rel(".octon/framework/engine/runtime/spec/context-pack-builder-v1.md");
        copy_rel(".octon/framework/engine/runtime/spec/execution-authorization-v1.md");
        copy_rel(".octon/instance/charter/workspace.md");
        fs::copy(
            source_root
                .join(".octon/framework/capabilities/governance/policy/deny-by-default.v2.yml"),
            octon_dir.join("framework/capabilities/governance/policy/deny-by-default.v2.yml"),
        )
        .expect("copy ACP policy");
        copy_tree(
            &source_repo_root().join(".octon/framework/capabilities/_ops/scripts"),
            &root.join(".octon/framework/capabilities/_ops/scripts"),
        );
        fs::create_dir_all(octon_dir.join("instance/governance/ownership"))
            .expect("ownership registry dir should exist");
        write_file(
            &octon_dir.join("instance/governance/ownership/registry.yml"),
            "schema_version: \"ownership-registry-v1\"\ndirective_precedence:\n  - mission_owner\noperators:\n  - operator_id: \"fixtures\"\n    display_name: \"Fixtures\"\n    contact: \"repo://fixtures\"\ndefaults:\n  operator_id: \"fixtures\"\n  support_tier: \"observe-and-read\"\nassets:\n  - asset_id: \"workflow-scope\"\n    path_globs:\n      - \"workflow-scope\"\n    owners:\n      - \"fixtures\"\nservices: []\nsubscriptions: {}\n",
        );
        fs::copy(
            source_root.join(".octon/instance/governance/support-targets.yml"),
            octon_dir.join("instance/governance/support-targets.yml"),
        )
        .expect("copy support targets");
        fs::copy(
            source_root.join(".octon/instance/governance/runtime-resolution.yml"),
            octon_dir.join("instance/governance/runtime-resolution.yml"),
        )
        .expect("copy runtime resolution");
        copy_tree(
            &source_root.join(".octon/instance/governance/support-target-admissions"),
            &root.join(".octon/instance/governance/support-target-admissions"),
        );
        copy_tree(
            &source_root.join(".octon/instance/governance/support-dossiers"),
            &root.join(".octon/instance/governance/support-dossiers"),
        );
        copy_tree(
            &source_root.join(".octon/instance/governance/capability-packs"),
            &root.join(".octon/instance/governance/capability-packs"),
        );
        copy_tree(
            &source_root.join(".octon/instance/governance/policies"),
            &root.join(".octon/instance/governance/policies"),
        );
        fs::create_dir_all(octon_dir.join("instance/governance/policies"))
            .expect("governance policy dir should exist");
        fs::copy(
            source_root.join(".octon/instance/governance/policies/mission-autonomy.yml"),
            octon_dir.join("instance/governance/policies/mission-autonomy.yml"),
        )
        .expect("copy mission autonomy policy");
        copy_tree(
            &source_root.join(".octon/instance/orchestration/missions"),
            &root.join(".octon/instance/orchestration/missions"),
        );
        fs::create_dir_all(octon_dir.join("instance/capabilities/runtime/packs"))
            .expect("runtime pack dir should exist");
        fs::copy(
            source_root.join(".octon/instance/capabilities/runtime/packs/registry.yml"),
            octon_dir.join("instance/capabilities/runtime/packs/registry.yml"),
        )
        .expect("copy runtime pack registry");
        copy_tree(
            &source_root.join(".octon/framework/engine/runtime/adapters"),
            &root.join(".octon/framework/engine/runtime/adapters"),
        );
        copy_tree(
            &source_root.join(".octon/framework/capabilities/packs"),
            &root.join(".octon/framework/capabilities/packs"),
        );
        copy_tree(
            &source_root.join(".octon/state/control/execution/missions"),
            &root.join(".octon/state/control/execution/missions"),
        );
        copy_tree(
            &source_root.join(".octon/state/control/extensions"),
            &root.join(".octon/state/control/extensions"),
        );
        copy_tree(
            &source_root.join(".octon/state/continuity/repo/missions"),
            &root.join(".octon/state/continuity/repo/missions"),
        );
        copy_tree(
            &source_root.join(".octon/generated/effective/runtime"),
            &root.join(".octon/generated/effective/runtime"),
        );
        copy_tree(
            &source_root.join(".octon/generated/effective/capabilities"),
            &root.join(".octon/generated/effective/capabilities"),
        );
        copy_tree(
            &source_root.join(".octon/generated/effective/governance"),
            &root.join(".octon/generated/effective/governance"),
        );
        copy_tree(
            &source_root.join(".octon/generated/effective/extensions"),
            &root.join(".octon/generated/effective/extensions"),
        );
        copy_tree(
            &source_root.join(".octon/generated/effective/locality"),
            &root.join(".octon/generated/effective/locality"),
        );
        copy_tree(
            &source_root.join(".octon/state/evidence/validation/publication/runtime"),
            &root.join(".octon/state/evidence/validation/publication/runtime"),
        );
        copy_tree(
            &source_root.join(".octon/state/evidence/validation/publication/capabilities"),
            &root.join(".octon/state/evidence/validation/publication/capabilities"),
        );
        copy_tree(
            &source_root.join(".octon/state/evidence/validation/publication/extensions"),
            &root.join(".octon/state/evidence/validation/publication/extensions"),
        );

        let target_package = root.join(".design-packages").join("target-package");
        fs::create_dir_all(&target_package).expect("target package should exist");
        write_file(&target_package.join("README.md"), "# Target Package\n");

        let workflow_root = root.join(WORKFLOW_ROOT_REL);
        fs::create_dir_all(workflow_root.join("stages")).expect("workflow stages dir should exist");
        write_file(
            &workflow_root.join("workflow.yml"),
            "name: audit-design-proposal\n",
        );

        for name in [
            "02-design-audit.md",
            "03-design-proposal-remediation.md",
            "04-design-red-PROFILE.md",
            "05-design-hardening.md",
            "06-design-integration.md",
            "07-implementation-simulation.md",
            "08-specification-closure.md",
            "09-extract-blueprint.md",
            "10-first-implementation-plan.md",
        ] {
            let body = match name {
                "03-design-proposal-remediation.md" => {
                    "Target: <PACKAGE_PATH>\nAudit: <AUDIT_REPORT>\nCHANGE MANIFEST"
                }
                "05-design-hardening.md" => {
                    "Target: <PACKAGE_PATH>\nRed team: <RED_TEAM_REPORT>\nCHANGE MANIFEST"
                }
                "06-design-integration.md" => {
                    "Target: <PACKAGE_PATH>\nHardening: <HARDENING_REPORT>\nCHANGE MANIFEST"
                }
                "07-implementation-simulation.md" => "Target: <PACKAGE_PATH>",
                "08-specification-closure.md" => {
                    "Target: <PACKAGE_PATH>\nSimulation: <IMPLEMENTATION_SIMULATION_REPORT>\nzero-change receipt"
                }
                "10-first-implementation-plan.md" => {
                    "Target: <PACKAGE_PATH>\nBlueprint: <BLUEPRINT_REPORT>"
                }
                _ => "Target: <PACKAGE_PATH>",
            };
            write_file(&workflow_root.join("stages").join(name), body);
        }

        (octon_dir, target_package)
    }

    fn source_repo_root() -> PathBuf {
        PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("../../../../../..")
            .canonicalize()
            .expect("source repo root should resolve")
    }

    fn copy_tree(from: &Path, to: &Path) {
        for entry in WalkDir::new(from)
            .follow_links(false)
            .into_iter()
            .filter_map(|entry| entry.ok())
        {
            let path = entry.path();
            let rel = path
                .strip_prefix(from)
                .expect("relative path should resolve");
            let dest = to.join(rel);
            if entry.file_type().is_dir() {
                fs::create_dir_all(&dest).expect("target directory should exist");
            } else if entry.file_type().is_file() {
                if let Some(parent) = dest.parent() {
                    fs::create_dir_all(parent).expect("parent directory should exist");
                }
                fs::copy(path, &dest).expect("file should copy");
            }
        }
    }

    fn replace_yaml_scalar(source: &str, key: &str, value: &str) -> String {
        let mut output = source
            .lines()
            .map(|line| {
                if line.starts_with(&format!("{key}: ")) {
                    format!("{key}: \"{value}\"")
                } else {
                    line.to_string()
                }
            })
            .collect::<Vec<_>>()
            .join("\n");
        output.push('\n');
        output
    }

    fn seed_create_design_package_fixture(root: &Path) -> PathBuf {
        seed_policy_runtime_env();
        let octon_dir = root.join(".octon");
        let source_root = source_repo_root();
        let copy_rel = |rel: &str| {
            let from = source_root.join(rel);
            let to = root.join(rel);
            if let Some(parent) = to.parent() {
                fs::create_dir_all(parent).expect("fixture parent should exist");
            }
            fs::copy(from, to).expect("fixture file should copy");
        };
        fs::create_dir_all(&octon_dir).expect(".octon dir should exist");
        fs::create_dir_all(octon_dir.join("instance/charter"))
            .expect("workspace charter dir should exist");
        fs::create_dir_all(octon_dir.join("instance/governance/ownership"))
            .expect("governance ownership dir should exist");
        write_file(
            &octon_dir.join("instance/charter/workspace.yml"),
            "schema_version: \"workspace-charter-v1\"\nworkspace_charter_id: \"workspace-charter://test/create-design-package\"\nversion: \"1.0.0\"\n",
        );
        write_file(
            &octon_dir.join("instance/governance/ownership/registry.yml"),
            "schema_version: \"ownership-registry-v1\"\ndirective_precedence:\n  - mission_owner\noperators:\n  - operator_id: \"fixtures\"\n    display_name: \"Fixtures\"\n    contact: \"repo://fixtures\"\ndefaults:\n  operator_id: \"fixtures\"\n  support_tier: \"observe-and-read\"\nassets:\n  - asset_id: \"workflow-scope\"\n    path_globs:\n      - \"workflow-scope\"\n    owners:\n      - \"fixtures\"\nservices: []\nsubscriptions: {}\n",
        );
        copy_rel(".octon/octon.yml");
        copy_rel(".octon/framework/constitution/CHARTER.md");
        copy_rel(".octon/framework/constitution/obligations/fail-closed.yml");
        copy_rel(".octon/framework/engine/runtime/spec/context-pack-builder-v1.md");
        copy_rel(".octon/framework/engine/runtime/spec/execution-authorization-v1.md");
        copy_rel(".octon/instance/charter/workspace.md");
        copy_rel(".octon/instance/governance/runtime-resolution.yml");
        copy_rel(".octon/instance/governance/support-targets.yml");
        copy_tree(
            &source_root.join(".octon/instance/governance/support-target-admissions"),
            &root.join(".octon/instance/governance/support-target-admissions"),
        );
        copy_tree(
            &source_root.join(".octon/instance/governance/support-dossiers"),
            &root.join(".octon/instance/governance/support-dossiers"),
        );
        copy_tree(
            &source_root.join(".octon/instance/governance/capability-packs"),
            &root.join(".octon/instance/governance/capability-packs"),
        );
        copy_tree(
            &source_root.join(".octon/instance/governance/policies"),
            &root.join(".octon/instance/governance/policies"),
        );
        fs::create_dir_all(octon_dir.join("instance/governance/policies"))
            .expect("governance policy dir should exist");
        fs::copy(
            source_root.join(".octon/instance/governance/policies/mission-autonomy.yml"),
            octon_dir.join("instance/governance/policies/mission-autonomy.yml"),
        )
        .expect("copy mission autonomy policy");
        copy_tree(
            &source_root.join(".octon/instance/orchestration/missions"),
            &root.join(".octon/instance/orchestration/missions"),
        );
        fs::create_dir_all(octon_dir.join("instance/capabilities/runtime/packs"))
            .expect("runtime pack dir should exist");
        copy_rel(".octon/instance/capabilities/runtime/packs/registry.yml");
        copy_tree(
            &source_root.join(".octon/instance/capabilities/runtime/packs/admissions"),
            &root.join(".octon/instance/capabilities/runtime/packs/admissions"),
        );
        fs::create_dir_all(octon_dir.join("framework/capabilities/governance/policy"))
            .expect("policy root should exist");
        copy_tree(
            &source_root.join(".octon/framework/engine/runtime/adapters"),
            &root.join(".octon/framework/engine/runtime/adapters"),
        );
        copy_tree(
            &source_root.join(".octon/framework/capabilities/packs"),
            &root.join(".octon/framework/capabilities/packs"),
        );
        fs::copy(
            source_root
                .join(".octon/framework/capabilities/governance/policy/deny-by-default.v2.yml"),
            octon_dir.join("framework/capabilities/governance/policy/deny-by-default.v2.yml"),
        )
        .expect("copy ACP policy");
        copy_tree(
            &source_root.join(".octon/framework/capabilities/_ops/scripts"),
            &root.join(".octon/framework/capabilities/_ops/scripts"),
        );
        copy_tree(
            &source_root.join(".octon/state/control/execution/missions"),
            &root.join(".octon/state/control/execution/missions"),
        );
        copy_tree(
            &source_root.join(".octon/state/continuity/repo/missions"),
            &root.join(".octon/state/continuity/repo/missions"),
        );
        copy_tree(
            &source_root.join(".octon/state/control/extensions"),
            &root.join(".octon/state/control/extensions"),
        );
        copy_tree(
            &source_root.join(".octon/generated/effective/runtime"),
            &root.join(".octon/generated/effective/runtime"),
        );
        copy_tree(
            &source_root.join(".octon/generated/effective/capabilities"),
            &root.join(".octon/generated/effective/capabilities"),
        );
        copy_tree(
            &source_root.join(".octon/generated/effective/governance"),
            &root.join(".octon/generated/effective/governance"),
        );
        copy_tree(
            &source_root.join(".octon/generated/effective/extensions"),
            &root.join(".octon/generated/effective/extensions"),
        );
        copy_tree(
            &source_root.join(".octon/generated/effective/locality"),
            &root.join(".octon/generated/effective/locality"),
        );
        copy_tree(
            &source_root.join(".octon/state/evidence/validation/publication/runtime"),
            &root.join(".octon/state/evidence/validation/publication/runtime"),
        );
        copy_tree(
            &source_root.join(".octon/state/evidence/validation/publication/capabilities"),
            &root.join(".octon/state/evidence/validation/publication/capabilities"),
        );
        copy_tree(
            &source_root.join(".octon/state/evidence/validation/publication/extensions"),
            &root.join(".octon/state/evidence/validation/publication/extensions"),
        );
        copy_tree(
            &source_root.join(".octon/generated/effective/orchestration/missions"),
            &root.join(".octon/generated/effective/orchestration/missions"),
        );
        let lease_path = octon_dir
            .join("state/control/execution/missions/mission-autonomy-live-validation/lease.yml");
        let lease = fs::read_to_string(&lease_path).expect("read mission lease");
        fs::write(
            &lease_path,
            lease.replace("state: \"paused\"", "state: \"active\""),
        )
        .expect("rewrite mission lease active");
        let mode_state_path = octon_dir.join(
            "state/control/execution/missions/mission-autonomy-live-validation/mode-state.yml",
        );
        let mode_state = fs::read_to_string(&mode_state_path).expect("read mission mode state");
        fs::write(
            &mode_state_path,
            mode_state
                .replace(
                    "oversight_mode: \"notify\"",
                    "oversight_mode: \"feedback_window\"",
                )
                .replace(
                    "execution_posture: \"interruptible_scheduled\"",
                    "execution_posture: \"continuous\"",
                )
                .replace("safety_state: \"paused\"", "safety_state: \"active\""),
        )
        .expect("rewrite mission mode state active");
        let scenario_path = octon_dir.join(
            "generated/effective/orchestration/missions/mission-autonomy-live-validation/scenario-resolution.yml",
        );
        let scenario =
            fs::read_to_string(&scenario_path).expect("read mission scenario resolution");
        let scenario = replace_yaml_scalar(&scenario, "generated_at", "2099-03-23T00:00:00Z");
        let scenario = replace_yaml_scalar(&scenario, "fresh_until", "2099-03-30T00:00:00Z");
        fs::write(
            &scenario_path,
            scenario
                .replace(
                    "oversight_mode: \"notify\"",
                    "oversight_mode: \"feedback_window\"",
                )
                .replace(
                    "execution_posture: \"interruptible_scheduled\"",
                    "execution_posture: \"continuous\"",
                )
                .replace(
                    "feedback_window_required: false",
                    "feedback_window_required: true",
                ),
        )
        .expect("rewrite mission scenario resolution active");
        let schedule_path = octon_dir
            .join("state/control/execution/missions/mission-autonomy-live-validation/schedule.yml");
        let schedule = fs::read_to_string(&schedule_path).expect("read mission schedule");
        fs::write(
            &schedule_path,
            schedule
                .replace(
                    "cadence_or_trigger: \"interruptible_scheduled\"",
                    "cadence_or_trigger: \"continuous\"",
                )
                .replace(
                    "pause_active_run_requested: true",
                    "pause_active_run_requested: false",
                ),
        )
        .expect("rewrite mission schedule active");

        let source_root = source_repo_root();
        copy_tree(
            &source_root.join(".octon/framework/scaffolding/runtime/templates"),
            &root.join(".octon/framework/scaffolding/runtime/templates"),
        );
        copy_tree(
            &source_root.join(".octon/framework/assurance/runtime/_ops/scripts"),
            &root.join(".octon/framework/assurance/runtime/_ops/scripts"),
        );
        copy_tree(
            &source_root
                .join(".octon/framework/cognition/_meta/architecture/generated/proposals/schemas"),
            &root.join(".octon/framework/cognition/_meta/architecture/generated/proposals/schemas"),
        );

        octon_dir
    }

    #[test]
    fn mode_stage_selection_matches_contract() {
        assert_eq!(
            RIGOROUS_STAGES
                .iter()
                .map(|stage| stage.id)
                .collect::<Vec<_>>(),
            vec!["01", "03", "04", "05", "06", "07", "08", "09"]
        );
        assert_eq!(
            SHORT_STAGES
                .iter()
                .map(|stage| stage.id)
                .collect::<Vec<_>>(),
            vec!["01", "02", "06", "07", "08", "09"]
        );
    }

    #[test]
    fn render_stage_prompt_injects_prior_reports() {
        let (_guard, root) = make_locked_temp_root("render");
        let (octon_dir, target_package) = seed_pipeline_fixture(&root);
        let runner = Runner::new(
            &octon_dir,
            RunDesignPackageOptions {
                package_path: target_package.strip_prefix(&root).unwrap().to_path_buf(),
                mode: PipelineMode::Short,
                executor: ExecutorKind::Auto,
                executor_bin: None,
                output_slug: None,
                model: None,
                prepare_only: true,
            },
        )
        .expect("runner should initialize");

        let stage = SHORT_STAGES
            .iter()
            .find(|stage| stage.id == "02")
            .expect("stage 02 should exist");
        let mut report_paths = BTreeMap::new();
        report_paths.insert(
            "01".to_string(),
            "reports/01-design-proposal-audit.md".to_string(),
        );
        let mut report_bodies = BTreeMap::new();
        report_bodies.insert("01".to_string(), "# Audit Report\n\nbody".to_string());

        let rendered = runner
            .render_stage_prompt(stage, &report_paths, &report_bodies)
            .expect("render should succeed");

        assert!(rendered.contains("Injected by Octon runner"));
        assert!(rendered.contains("## Injected Inputs"));
        assert!(rendered.contains("# Audit Report"));
        assert!(rendered.contains(
            &target_package
                .canonicalize()
                .expect("target package should canonicalize")
                .display()
                .to_string()
        ));
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn prepare_only_run_materializes_bundle_and_prompt_packets() {
        let (_guard, root) = make_locked_temp_root("prepare-only");
        let (octon_dir, target_package) = seed_pipeline_fixture(&root);

        let result = run_design_package_from_octon_dir(
            &octon_dir,
            RunDesignPackageOptions {
                package_path: target_package.strip_prefix(&root).unwrap().to_path_buf(),
                mode: PipelineMode::Short,
                executor: ExecutorKind::Auto,
                executor_bin: None,
                output_slug: Some("fixture".to_string()),
                model: None,
                prepare_only: true,
            },
        )
        .expect("prepare-only run should succeed");

        let validation = fs::read_to_string(result.bundle_root.join("validation.md"))
            .expect("validation should exist");
        let summary = fs::read_to_string(&result.summary_report).expect("summary should exist");
        let prompt_packet = fs::read_to_string(
            result
                .bundle_root
                .join("stage-inputs/02-02-design-proposal-remediation.prompt.md"),
        )
        .expect("stage 02 prompt packet should exist");

        assert!(validation.contains("prepared-only"));
        assert!(summary.contains("prepared-only"));
        assert!(prompt_packet.contains("Final Answer Requirement"));
        assert!(result
            .bundle_root
            .to_string_lossy()
            .contains(".octon/state/evidence/runs/workflows/"));
        assert!(result.bundle_root.join("summary.md").is_file());
        assert!(result.bundle_root.join("plan.md").is_file());
        assert!(result.bundle_root.join("bundle.yml").is_file());
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn mock_executor_run_materializes_reports_and_package_delta() {
        let (_guard, root) = make_locked_temp_root("mock-run");
        let (octon_dir, target_package) = seed_pipeline_fixture(&root);

        let result = run_design_package_from_octon_dir(
            &octon_dir,
            RunDesignPackageOptions {
                package_path: target_package.strip_prefix(&root).unwrap().to_path_buf(),
                mode: PipelineMode::Short,
                executor: ExecutorKind::Mock,
                executor_bin: None,
                output_slug: Some("mock-fixture".to_string()),
                model: None,
                prepare_only: false,
            },
        )
        .expect("mock run should succeed");

        let summary = fs::read_to_string(&result.summary_report).expect("summary should exist");
        let validation = fs::read_to_string(result.bundle_root.join("validation.md"))
            .expect("validation should exist");
        let package_delta = fs::read_to_string(result.bundle_root.join("package-delta.md"))
            .expect("package delta should exist");
        let stage_report = fs::read_to_string(
            result
                .bundle_root
                .join("reports/02-design-proposal-remediation.md"),
        )
        .expect("stage report should exist");

        assert_eq!(result.final_verdict, "mock-executed");
        assert!(summary.contains("mock-executed"));
        assert!(validation.contains("mock-executed"));
        assert!(result
            .bundle_root
            .to_string_lossy()
            .contains(".octon/state/evidence/runs/workflows/"));
        assert!(result.bundle_root.join("summary.md").is_file());
        assert!(result.bundle_root.join("commands.md").is_file());
        assert!(result.bundle_root.join("inventory.md").is_file());
        assert!(result.bundle_root.join("stage-inputs").is_dir());
        assert!(result.bundle_root.join("stage-logs").is_dir());
        assert!(package_delta.contains("synthetic-remediation.md"));
        assert!(stage_report.contains("CHANGE MANIFEST"));
        assert!(target_package
            .join(".octon-mock-runner/synthetic-remediation.md")
            .is_file());
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn rigorous_mock_executor_run_materializes_rigorous_reports() {
        let (_guard, root) = make_locked_temp_root("mock-rigorous");
        let (octon_dir, target_package) = seed_pipeline_fixture(&root);

        let result = run_design_package_from_octon_dir(
            &octon_dir,
            RunDesignPackageOptions {
                package_path: target_package.strip_prefix(&root).unwrap().to_path_buf(),
                mode: PipelineMode::Rigorous,
                executor: ExecutorKind::Mock,
                executor_bin: None,
                output_slug: Some("mock-rigorous".to_string()),
                model: None,
                prepare_only: false,
            },
        )
        .expect("rigorous mock run should succeed");

        assert_eq!(result.final_verdict, "mock-executed");
        assert!(result
            .bundle_root
            .join("reports/03-design-red-PROFILE.md")
            .is_file());
        assert!(result
            .bundle_root
            .join("reports/04-design-hardening.md")
            .is_file());
        assert!(result
            .bundle_root
            .join("reports/05-design-integration.md")
            .is_file());
        assert!(result.bundle_root.join("commands.md").is_file());
        assert!(result.bundle_root.join("inventory.md").is_file());
        assert!(result.bundle_root.join("stage-inputs").is_dir());
        assert!(result.bundle_root.join("stage-logs").is_dir());
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn failing_executor_writes_failure_receipts() {
        let (_guard, root) = make_locked_temp_root("failing-executor");
        let (octon_dir, target_package) = seed_pipeline_fixture(&root);

        let fake_codex = root.join("bin/codex");
        write_file(
            &fake_codex,
            "#!/usr/bin/env bash\nprintf 'synthetic failure\\n' >&2\nexit 1\n",
        );
        let mut permissions = fs::metadata(&fake_codex)
            .expect("fake codex should exist")
            .permissions();
        permissions.set_mode(0o755);
        fs::set_permissions(&fake_codex, permissions).expect("fake codex should be executable");

        let error = run_design_package_from_octon_dir(
            &octon_dir,
            RunDesignPackageOptions {
                package_path: target_package.strip_prefix(&root).unwrap().to_path_buf(),
                mode: PipelineMode::Short,
                executor: ExecutorKind::Codex,
                executor_bin: Some(fake_codex),
                output_slug: Some("failing-executor".to_string()),
                model: Some("gpt-5".to_string()),
                prepare_only: false,
            },
        )
        .expect_err("failing executor should fail the run");

        assert!(error
            .to_string()
            .contains("executor-environment-failure at stage 01"));

        let bundles_root = root.join(".octon/state/evidence/runs/workflows");
        let bundle_root = fs::read_dir(&bundles_root)
            .expect("workflow bundle root should exist")
            .filter_map(|entry| entry.ok())
            .map(|entry| entry.path())
            .find(|path| path.is_dir())
            .expect("failed bundle should exist");

        let bundle = fs::read_to_string(bundle_root.join("bundle.yml"))
            .expect("bundle metadata should exist");
        let validation =
            fs::read_to_string(bundle_root.join("validation.md")).expect("validation should exist");
        let summary =
            fs::read_to_string(bundle_root.join("summary.md")).expect("summary should exist");
        let commands =
            fs::read_to_string(bundle_root.join("commands.md")).expect("commands log should exist");

        assert!(bundle.contains("failure_class: executor-environment-failure"));
        assert!(bundle.contains("failed_stage: '01'") || bundle.contains("failed_stage: \"01\""));
        assert!(validation.contains("failure_class: `executor-environment-failure`"));
        assert!(validation.contains("failed_stage: `01`"));
        assert!(summary.contains("failure_class: `executor-environment-failure`"));
        assert!(summary.contains("failed_stage: `01`"));
        assert!(commands.contains("status=failed-before-report"));
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn auto_executor_override_infers_claude_from_binary_name() {
        let resolved = resolve_executor(ExecutorKind::Auto, Some(Path::new("/tmp/claude")))
            .expect("auto executor should infer claude from override");

        match resolved {
            ResolvedExecutor::Claude(path) => assert_eq!(path, PathBuf::from("/tmp/claude")),
            other => panic!("expected claude executor, got {:?}", other),
        }
    }

    #[test]
    fn auto_executor_override_rejects_unknown_binary_name() {
        let error = resolve_executor(ExecutorKind::Auto, Some(Path::new("/tmp/custom-runner")))
            .expect_err("auto executor should reject unknown override names");

        assert!(
            error
                .to_string()
                .contains("unable to infer executor kind from override path"),
            "unexpected error: {error}"
        );
    }

    #[test]
    fn create_design_package_scaffolds_domain_runtime_defaults() {
        let (_guard, root) = make_locked_temp_root("create-runtime");
        let octon_dir = seed_create_design_package_fixture(&root);

        let result = run_create_design_package_from_octon_dir(
            &octon_dir,
            RunCreateDesignPackageOptions {
                run_id: None,
                mission_id: Some("mission-autonomy-live-validation".to_string()),
                package_id: "runtime-package".to_string(),
                package_title: "Runtime Package".to_string(),
                package_class: DesignPackageClass::DomainRuntime,
                promotion_scope: ProposalScope::OctonInternal,
                implementation_targets: vec![
                    ".octon/framework/orchestration/runtime/example.md".to_string()
                ],
                include_contracts: None,
                include_conformance: None,
                include_canonicalization: None,
            },
        )
        .expect("create-design-proposal should succeed");

        let package_root = root.join(".octon/inputs/exploratory/proposals/design/runtime-package");
        let manifest =
            fs::read_to_string(package_root.join("design-proposal.yml")).expect("manifest exists");
        let summary = fs::read_to_string(&result.summary_report).expect("summary should exist");

        assert!(package_root.join("contracts/README.md").is_file());
        assert!(package_root.join("conformance/README.md").is_file());
        assert!(package_root
            .join("navigation/canonicalization-target-map.md")
            .is_file());
        assert!(manifest.contains("design_class: \"domain-runtime\""));
        assert!(manifest.contains("- \"contracts\""));
        assert!(manifest.contains("- \"conformance\""));
        assert!(manifest.contains("- \"canonicalization\""));
        assert!(summary.contains("final_verdict: `scaffolded`"));
        assert!(summary.contains(
            "/audit-design-proposal proposal_path=\".octon/inputs/exploratory/proposals/design/runtime-package\""
        ));
        assert!(summary.contains("bundle_root: `"));
        assert!(result.bundle_root.join("summary.md").is_file());
        assert!(result.bundle_root.join("bundle.yml").is_file());
        assert!(result.bundle_root.join("commands.md").is_file());
        assert!(result.bundle_root.join("validation.md").is_file());
        assert!(result.bundle_root.join("inventory.md").is_file());
        assert!(result.bundle_root.join("stage-inputs").is_dir());
        assert!(result.bundle_root.join("stage-logs").is_dir());
        assert!(result.bundle_root.join("standard-validator.log").is_file());
        assert!(
            fs::read_to_string(root.join(".octon/generated/proposals/registry.yml"))
                .expect("registry should exist")
                .contains("runtime-package")
        );
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn create_design_package_scaffolds_experience_product_defaults() {
        let (_guard, root) = make_locked_temp_root("create-experience");
        let octon_dir = seed_create_design_package_fixture(&root);

        let result = run_create_design_package_from_octon_dir(
            &octon_dir,
            RunCreateDesignPackageOptions {
                run_id: None,
                mission_id: Some("mission-autonomy-live-validation".to_string()),
                package_id: "experience-package".to_string(),
                package_title: "Experience Package".to_string(),
                package_class: DesignPackageClass::ExperienceProduct,
                promotion_scope: ProposalScope::OctonInternal,
                implementation_targets: vec![
                    ".octon/framework/scaffolding/runtime/example.md".to_string()
                ],
                include_contracts: None,
                include_conformance: None,
                include_canonicalization: None,
            },
        )
        .expect("create-design-proposal should succeed");

        let package_root =
            root.join(".octon/inputs/exploratory/proposals/design/experience-package");
        let manifest =
            fs::read_to_string(package_root.join("design-proposal.yml")).expect("manifest exists");

        assert!(package_root
            .join("normative/experience/user-journeys.md")
            .is_file());
        assert!(package_root.join("reference/README.md").is_file());
        assert!(!package_root.join("contracts/README.md").exists());
        assert!(!package_root.join("conformance/README.md").exists());
        assert!(manifest.contains("design_class: \"experience-product\""));
        assert!(manifest.contains("- \"reference\""));
        assert!(manifest.contains("- \"history\""));
        assert!(manifest.contains("conformance_validator_path: null"));
        assert!(result.bundle_root.join("summary.md").is_file());
        assert!(result.bundle_root.join("bundle.yml").is_file());
        assert!(result.bundle_root.join("commands.md").is_file());
        assert!(result.bundle_root.join("validation.md").is_file());
        assert!(result.bundle_root.join("inventory.md").is_file());
        assert!(result.bundle_root.join("stage-inputs").is_dir());
        assert!(result.bundle_root.join("stage-logs").is_dir());
        assert!(result.bundle_root.join("standard-validator.log").is_file());
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn create_design_package_duplicate_id_writes_failure_receipts() {
        let (_guard, root) = make_locked_temp_root("create-duplicate");
        let octon_dir = seed_create_design_package_fixture(&root);

        run_create_design_package_from_octon_dir(
            &octon_dir,
            RunCreateDesignPackageOptions {
                run_id: None,
                mission_id: Some("mission-autonomy-live-validation".to_string()),
                package_id: "duplicate-package".to_string(),
                package_title: "Duplicate Package".to_string(),
                package_class: DesignPackageClass::DomainRuntime,
                promotion_scope: ProposalScope::OctonInternal,
                implementation_targets: vec![
                    ".octon/framework/orchestration/runtime/example.md".to_string()
                ],
                include_contracts: None,
                include_conformance: None,
                include_canonicalization: None,
            },
        )
        .expect("first create-design-proposal run should succeed");

        let error = run_create_design_package_from_octon_dir(
            &octon_dir,
            RunCreateDesignPackageOptions {
                run_id: None,
                mission_id: Some("mission-autonomy-live-validation".to_string()),
                package_id: "duplicate-package".to_string(),
                package_title: "Duplicate Package".to_string(),
                package_class: DesignPackageClass::DomainRuntime,
                promotion_scope: ProposalScope::OctonInternal,
                implementation_targets: vec![
                    ".octon/framework/orchestration/runtime/example.md".to_string()
                ],
                include_contracts: None,
                include_conformance: None,
                include_canonicalization: None,
            },
        )
        .expect_err("duplicate package id should fail");

        assert!(
            error
                .to_string()
                .contains("request-validation-failure at stage validate-request"),
            "unexpected error: {error}"
        );

        let bundles_root = root.join(".octon/state/evidence/runs/workflows");
        let bundle_root = fs::read_dir(&bundles_root)
            .expect("workflow bundles root should exist")
            .filter_map(|entry| entry.ok())
            .map(|entry| entry.path())
            .filter(|path| path.is_dir())
            .max()
            .expect("failed bundle should exist");

        let bundle = fs::read_to_string(bundle_root.join("bundle.yml"))
            .expect("bundle metadata should exist");
        let validation =
            fs::read_to_string(bundle_root.join("validation.md")).expect("validation should exist");
        let summary =
            fs::read_to_string(bundle_root.join("summary.md")).expect("summary should exist");

        assert!(bundle.contains("failure_class: request-validation-failure"));
        assert!(
            bundle.contains("failed_stage: validate-request")
                || bundle.contains("failed_stage: \"validate-request\"")
        );
        assert!(validation.contains("request-validation-failure"));
        assert!(summary.contains("request-validation-failure"));
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn validate_proposal_rejects_invalid_explicit_run_id() {
        let (_guard, root) = make_locked_temp_root("validate-invalid-run-id");
        let octon_dir = seed_create_design_package_fixture(&root);

        run_create_design_package_from_octon_dir(
            &octon_dir,
            RunCreateDesignPackageOptions {
                run_id: None,
                mission_id: Some("mission-autonomy-live-validation".to_string()),
                package_id: "validate-target".to_string(),
                package_title: "Validate Target".to_string(),
                package_class: DesignPackageClass::ExperienceProduct,
                promotion_scope: ProposalScope::OctonInternal,
                implementation_targets: vec![
                    ".octon/framework/scaffolding/runtime/example.md".to_string()
                ],
                include_contracts: None,
                include_conformance: None,
                include_canonicalization: None,
            },
        )
        .expect("fixture package should scaffold");

        let error = run_validate_proposal_from_octon_dir(
            &octon_dir,
            RunValidateProposalOptions {
                run_id: Some("../escape".to_string()),
                resume_existing: false,
                proposal_path: PathBuf::from(
                    ".octon/inputs/exploratory/proposals/design/validate-target",
                ),
            },
        )
        .expect_err("invalid explicit run id must fail");

        assert!(error
            .to_string()
            .contains("workflow --run-id must not contain path separators"));
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn validate_proposal_rejects_reused_explicit_run_id() {
        let (_guard, root) = make_locked_temp_root("validate-reused-run-id");
        let octon_dir = seed_create_design_package_fixture(&root);
        let runtime_cfg = ConfigLoader::load(&octon_dir).expect("runtime config should load");

        run_create_design_package_from_octon_dir(
            &octon_dir,
            RunCreateDesignPackageOptions {
                run_id: None,
                mission_id: Some("mission-autonomy-live-validation".to_string()),
                package_id: "validate-target".to_string(),
                package_title: "Validate Target".to_string(),
                package_class: DesignPackageClass::ExperienceProduct,
                promotion_scope: ProposalScope::OctonInternal,
                implementation_targets: vec![
                    ".octon/framework/scaffolding/runtime/example.md".to_string()
                ],
                include_contracts: None,
                include_conformance: None,
                include_canonicalization: None,
            },
        )
        .expect("fixture package should scaffold");

        let reused_run_id = "validate-proposal-20260331";
        fs::create_dir_all(runtime_cfg.run_control_root(reused_run_id))
            .expect("existing control root should be seeded");

        let error = run_validate_proposal_from_octon_dir(
            &octon_dir,
            RunValidateProposalOptions {
                run_id: Some(reused_run_id.to_string()),
                resume_existing: false,
                proposal_path: PathBuf::from(
                    ".octon/inputs/exploratory/proposals/design/validate-target",
                ),
            },
        )
        .expect_err("reused explicit run id must fail");

        assert!(error
            .to_string()
            .contains("already exists in canonical execution artifacts"));
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn proposal_registry_preserves_same_id_across_kinds() {
        let (_guard, root) = make_locked_temp_root("proposal-registry-kinds");
        let octon_dir = seed_create_design_package_fixture(&root);

        run_create_static_proposal_from_octon_dir(
            &octon_dir,
            StaticProposalKind::Migration,
            RunCreateStaticProposalOptions {
                run_id: None,
                mission_id: Some("mission-autonomy-live-validation".to_string()),
                proposal_id: "shared-id".to_string(),
                proposal_title: "Shared Migration".to_string(),
                promotion_scope: ProposalScope::RepoLocal,
                promotion_targets: vec!["docs/migration.md".to_string()],
            },
        )
        .expect("migration proposal should scaffold");

        run_create_static_proposal_from_octon_dir(
            &octon_dir,
            StaticProposalKind::Policy,
            RunCreateStaticProposalOptions {
                run_id: None,
                mission_id: Some("mission-autonomy-live-validation".to_string()),
                proposal_id: "shared-id".to_string(),
                proposal_title: "Shared Policy".to_string(),
                promotion_scope: ProposalScope::RepoLocal,
                promotion_targets: vec!["docs/policy.md".to_string()],
            },
        )
        .expect("policy proposal should scaffold");

        let registry: ProposalRegistry = serde_yaml::from_str(
            &fs::read_to_string(root.join(".octon/generated/proposals/registry.yml"))
                .expect("registry should exist"),
        )
        .expect("registry should parse");

        assert_eq!(registry.active.len(), 2);
        assert!(registry
            .active
            .iter()
            .any(|entry| entry.kind == "migration" && entry.id == "shared-id"));
        assert!(registry
            .active
            .iter()
            .any(|entry| entry.kind == "policy" && entry.id == "shared-id"));

        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn create_design_package_writes_execution_artifacts() {
        let (_guard, root) = make_locked_temp_root("create-artifacts");
        let octon_dir = seed_create_design_package_fixture(&root);

        let result = run_create_design_package_from_octon_dir(
            &octon_dir,
            RunCreateDesignPackageOptions {
                run_id: None,
                mission_id: Some("mission-autonomy-live-validation".to_string()),
                package_id: "artifact-package".to_string(),
                package_title: "Artifact Package".to_string(),
                package_class: DesignPackageClass::DomainRuntime,
                promotion_scope: ProposalScope::OctonInternal,
                implementation_targets: vec![
                    ".octon/framework/orchestration/runtime/example.md".to_string()
                ],
                include_contracts: None,
                include_conformance: None,
                include_canonicalization: None,
            },
        )
        .expect("create-design-proposal should succeed");

        for path in [
            result
                .bundle_root
                .join("workflow-execution/execution-receipt.json"),
            result
                .bundle_root
                .join("stages/03-scaffold-proposal/execution-receipt.json"),
            result
                .bundle_root
                .join("stages/04-validate-proposal/execution-receipt.json"),
        ] {
            assert!(
                path.is_file(),
                "expected execution artifact {}",
                path.display()
            );
        }

        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn create_static_and_audit_proposal_write_execution_artifacts() {
        let (_guard, root) = make_locked_temp_root("static-artifacts");
        let octon_dir = seed_create_design_package_fixture(&root);

        let create_result = run_create_static_proposal_from_octon_dir(
            &octon_dir,
            StaticProposalKind::Architecture,
            RunCreateStaticProposalOptions {
                run_id: None,
                mission_id: Some("mission-autonomy-live-validation".to_string()),
                proposal_id: "auditable-static".to_string(),
                proposal_title: "Auditable Static".to_string(),
                promotion_scope: ProposalScope::RepoLocal,
                promotion_targets: vec!["docs/auditable.md".to_string()],
            },
        )
        .expect("static proposal should scaffold");

        let audit_result = run_audit_static_proposal_from_octon_dir(
            &octon_dir,
            StaticProposalKind::Architecture,
            RunAuditStaticProposalOptions {
                run_id: None,
                resume_existing: false,
                proposal_path: PathBuf::from(
                    ".octon/inputs/exploratory/proposals/architecture/auditable-static",
                ),
            },
        )
        .expect("static proposal audit should succeed");

        for path in [
            create_result
                .bundle_root
                .join("workflow-execution/execution-receipt.json"),
            create_result
                .bundle_root
                .join("stages/scaffold-proposal/execution-receipt.json"),
            create_result
                .bundle_root
                .join("stages/validate-proposal/execution-receipt.json"),
            audit_result
                .bundle_root
                .join("workflow-execution/execution-receipt.json"),
            audit_result
                .bundle_root
                .join("stages/validate-proposal/execution-receipt.json"),
        ] {
            assert!(
                path.is_file(),
                "expected execution artifact {}",
                path.display()
            );
        }

        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn create_static_proposal_failure_writes_execution_artifacts() {
        let (_guard, root) = make_locked_temp_root("static-create-failure");
        let octon_dir = seed_create_design_package_fixture(&root);

        run_create_static_proposal_from_octon_dir(
            &octon_dir,
            StaticProposalKind::Policy,
            RunCreateStaticProposalOptions {
                run_id: None,
                mission_id: Some("mission-autonomy-live-validation".to_string()),
                proposal_id: "duplicate-static".to_string(),
                proposal_title: "Duplicate Static".to_string(),
                promotion_scope: ProposalScope::RepoLocal,
                promotion_targets: vec!["docs/policy.md".to_string()],
            },
        )
        .expect("first static proposal should scaffold");

        let error = run_create_static_proposal_from_octon_dir(
            &octon_dir,
            StaticProposalKind::Policy,
            RunCreateStaticProposalOptions {
                run_id: None,
                mission_id: Some("mission-autonomy-live-validation".to_string()),
                proposal_id: "duplicate-static".to_string(),
                proposal_title: "Duplicate Static".to_string(),
                promotion_scope: ProposalScope::RepoLocal,
                promotion_targets: vec!["docs/policy.md".to_string()],
            },
        )
        .expect_err("duplicate static proposal should fail");
        assert!(error.to_string().contains("target proposal already exists"));

        let bundles_root = root.join(".octon/state/evidence/runs/workflows");
        let bundle_root = fs::read_dir(&bundles_root)
            .expect("workflow bundles root should exist")
            .filter_map(|entry| entry.ok())
            .map(|entry| entry.path())
            .filter(|path| path.is_dir())
            .max()
            .expect("failed bundle should exist");
        assert!(bundle_root
            .join("workflow-execution/execution-receipt.json")
            .is_file());
        assert!(bundle_root
            .join("workflow-execution/outcome.json")
            .is_file());

        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn audit_static_missing_target_writes_execution_artifacts() {
        let (_guard, root) = make_locked_temp_root("static-audit-failure");
        let octon_dir = seed_create_design_package_fixture(&root);

        let error = run_audit_static_proposal_from_octon_dir(
            &octon_dir,
            StaticProposalKind::Architecture,
            RunAuditStaticProposalOptions {
                run_id: None,
                resume_existing: false,
                proposal_path: PathBuf::from(
                    ".octon/inputs/exploratory/proposals/architecture/missing",
                ),
            },
        )
        .expect_err("missing static proposal should fail");
        assert!(!error.to_string().is_empty());

        let bundles_root = root.join(".octon/state/evidence/runs/workflows");
        let bundle_root = fs::read_dir(&bundles_root)
            .expect("workflow bundles root should exist")
            .filter_map(|entry| entry.ok())
            .map(|entry| entry.path())
            .find(|path| path.is_dir())
            .expect("failed bundle should exist");
        assert!(bundle_root
            .join("workflow-execution/execution-receipt.json")
            .is_file());
        assert!(bundle_root
            .join("workflow-execution/outcome.json")
            .is_file());

        fs::remove_dir_all(root).ok();
    }
}
