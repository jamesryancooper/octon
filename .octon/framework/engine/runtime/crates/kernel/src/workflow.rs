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

use crate::authorization::{
    authorize_execution, build_executor_command, finalize_execution,
    now_rfc3339 as auth_now_rfc3339, resolve_executor_profile, write_execution_start,
    with_authority_env_metadata, ExecutionArtifactPaths, ExecutionOutcome, ExecutionRequest, ExecutorCommandSpec,
    GrantBundle, ManagedExecutorKind, ReviewRequirements, ScopeConstraints,
    SideEffectFlags, SideEffectSummary,
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
        prompt_file: "04-design-red-team.md",
        report_file: "03-design-red-team.md",
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
}

#[derive(Clone, Debug)]
pub struct RunValidateProposalOptions {
    pub proposal_path: PathBuf,
}

#[derive(Clone, Debug)]
pub struct RunPromoteProposalOptions {
    pub proposal_path: PathBuf,
    pub promotion_evidence: Vec<String>,
}

#[derive(Clone, Debug)]
pub struct RunArchiveProposalOptions {
    pub proposal_path: PathBuf,
    pub disposition: String,
    pub promotion_evidence: Vec<String>,
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
            write!(f, "{} at stage {}: {}", self.class.as_str(), stage, self.message)
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
    artifacts: ExecutionArtifactPaths,
    started_at: String,
}

fn authorize_workflow_stage(
    runtime_cfg: &RuntimeConfig,
    policy: &PolicyEngine,
    bundle_root: &Path,
    workflow_id: &str,
    stage_id: &str,
    action_type: &str,
    target_id: &str,
    requested_capabilities: Vec<String>,
    write_scope: Vec<String>,
    shell: bool,
    write_repo: bool,
    risk_tier: &str,
    executor_profile: Option<&str>,
) -> Result<AuthorizedWorkflowStage> {
    let request = ExecutionRequest {
        request_id: format!("{workflow_id}-{stage_id}"),
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
        workflow_mode: "human-only".to_string(),
        locality_scope: None,
        intent_ref: None,
        autonomy_context: None,
        actor_ref: None,
        parent_run_ref: Some(workflow_id.to_string()),
        review_requirements: ReviewRequirements::default(),
        scope_constraints: ScopeConstraints {
            read: vec!["workflow-scope".to_string()],
            write: write_scope,
            executor_profile: executor_profile.map(ToOwned::to_owned),
            locality_scope: None,
        },
        policy_mode_requested: None,
        environment_hint: None,
        metadata: BTreeMap::from([
            ("workflow_id".to_string(), workflow_id.to_string()),
            ("stage_id".to_string(), stage_id.to_string()),
        ]),
    };
    let grant = authorize_execution(runtime_cfg, policy, &request, None)?;
    let artifacts = write_execution_start(&bundle_root.join("stages").join(stage_id), &request, &grant)?;
    let started_at = auth_now_rfc3339()?;
    Ok(AuthorizedWorkflowStage {
        request,
        grant,
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
    finalize_execution(
        artifacts,
        request,
        grant,
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
    let workflow_auth = authorize_execution(
        &runtime_cfg,
        &policy,
        &ExecutionRequest {
            request_id: format!("create-design-proposal-{}", options.package_id),
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
            workflow_mode: "human-only".to_string(),
            locality_scope: None,
            intent_ref: None,
            autonomy_context: None,
            actor_ref: None,
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
            metadata: BTreeMap::from([(
                "workflow_id".to_string(),
                "create-design-proposal".to_string(),
            )]),
        },
        None,
    )?;
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
    let workflow_artifacts =
        write_execution_start(&bundle_root.join("workflow-execution"), &ExecutionRequest {
            request_id: format!("create-design-proposal-{}", options.package_id),
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
            workflow_mode: "human-only".to_string(),
            locality_scope: None,
            intent_ref: None,
            autonomy_context: None,
            actor_ref: None,
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
            metadata: BTreeMap::from([(
                "workflow_id".to_string(),
                "create-design-proposal".to_string(),
            )]),
        }, &workflow_auth)?;
    let summary_report =
        unique_file(&reports_root, &format!("{date}-create-design-proposal"), "md")?;

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
            message: format!("target design proposal already exists: {}", proposal_root.display()),
        });
    }

    write_create_stage_log(
        &bundle_root,
        "01",
        "validate-request",
        if failure.is_some() { "failed" } else { "passed" },
        &format!("- proposal_root: `{}`\n", proposal_root.display()),
    )?;
    command_log.push(format!(
        "- stage validate-request | status={} | input={} | proposal_root={}",
        if failure.is_some() { "failed" } else { "passed" },
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
                bundle_root.join("stages/03-scaffold-proposal").display().to_string(),
            ],
            false,
            true,
            "medium",
            Some("scoped_repo_mutation"),
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
                build_proposal_manifest(
                    &options,
                    &package_summary,
                    &exit_expectation,
                ),
            )
            .with_context(|| {
                format!(
                    "write {}",
                    proposal_root.join("proposal.yml").display()
                )
            })?;
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
                build_artifact_catalog(&proposal_root, "design", &options.package_id, &proposal_rel)?,
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
            let class = if error.to_string().contains(".octon/generated/proposals/registry.yml") {
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
            if failure.is_some() { "failed" } else { "passed" },
            &format!(
                "- proposal_root: `{}`\n- registry_synced: `{}`\n",
                proposal_root.display(),
                registry_synced
            ),
        )?;
        command_log.push(format!(
            "- stage scaffold-proposal | status={} | input={} | proposal_root={}",
            if failure.is_some() { "failed" } else { "passed" },
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
            "04-validate-proposal",
            "execute_stage",
            "create-design-proposal::validate-proposal",
            vec![
                "workflow.stage.execute".to_string(),
                "evidence.write".to_string(),
            ],
            vec![
                bundle_root.join("standard-validator.log").display().to_string(),
                bundle_root.join("stages/04-validate-proposal").display().to_string(),
            ],
            true,
            false,
            "low",
            Some("read_only_analysis"),
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
                    vec![rel_path(&repo_root, &bundle_root.join("standard-validator.log"))],
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

    let final_verdict = if failure.is_some() { "failed" } else { "scaffolded" };
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
        if failure.is_some() { "partial" } else { "passed" },
        &format!("- summary_report: `{}`\n", summary_report.display()),
    )?;
    command_log.push(format!(
        "- stage report | status={} | input={} | summary_report={}",
        if failure.is_some() { "partial" } else { "passed" },
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
            &ExecutionRequest {
                request_id: format!("create-design-proposal-{}", options.package_id),
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
                workflow_mode: "human-only".to_string(),
                locality_scope: None,
                intent_ref: None,
                autonomy_context: None,
                actor_ref: None,
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
                metadata: BTreeMap::from([(
                    "workflow_id".to_string(),
                    "create-design-proposal".to_string(),
                )]),
            },
            &workflow_auth,
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
        &ExecutionRequest {
            request_id: format!("create-design-proposal-{}", options.package_id),
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
            workflow_mode: "human-only".to_string(),
            locality_scope: None,
            intent_ref: None,
            autonomy_context: None,
            actor_ref: None,
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
            metadata: BTreeMap::from([(
                "workflow_id".to_string(),
                "create-design-proposal".to_string(),
            )]),
        },
        &workflow_auth,
        &started_at,
        &ExecutionOutcome {
            status: "succeeded".to_string(),
            started_at: started_at.clone(),
            completed_at: auth_now_rfc3339()?,
            error: None,
        },
        &SideEffectSummary {
            touched_scope: vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
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
    let workflow_request = ExecutionRequest {
        request_id: format!("create-{}-proposal-{}", kind.as_str(), options.proposal_id),
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
        workflow_mode: "human-only".to_string(),
        locality_scope: None,
        intent_ref: None,
        autonomy_context: None,
        actor_ref: None,
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
        metadata: BTreeMap::from([(
            "workflow_id".to_string(),
            format!("create-{}-proposal", kind.as_str()),
        )]),
    };
    let workflow_grant = authorize_execution(&runtime_cfg, &policy, &workflow_request, None)?;
    fs::create_dir_all(&proposals_root)?;
    fs::create_dir_all(&reports_root)?;
    fs::create_dir_all(&workflow_bundles_root)?;

    let date = today_string()?;
    let started_at = auth_now_rfc3339()?;
    let bundle_root = unique_directory(
        &workflow_bundles_root,
        &format!("{date}-create-{}-proposal-{}", kind.as_str(), slugify(&options.proposal_id)),
    )?;
    fs::create_dir_all(bundle_root.join("reports"))?;
    fs::create_dir_all(bundle_root.join("stage-inputs"))?;
    fs::create_dir_all(bundle_root.join("stage-logs"))?;
    let workflow_artifacts =
        write_execution_start(&bundle_root.join("workflow-execution"), &workflow_request, &workflow_grant)?;
    let summary_report = unique_file(
        &reports_root,
        &format!("{date}-create-{}-proposal", kind.as_str()),
        "md",
    )?;

    let proposal_root = proposals_root.join(&options.proposal_id);
    if proposal_root.exists() {
        let message = format!("target proposal already exists: {}", proposal_root.display());
        let _ = finalize_workflow_failure(
            &workflow_artifacts,
            &workflow_request,
            &workflow_grant,
            &started_at,
            message.clone(),
            vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
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
            bundle_root.join("stages/scaffold-proposal").display().to_string(),
        ],
        false,
        true,
        "medium",
        Some("scoped_repo_mutation"),
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
                vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
            );
            bail!(message);
        }
    };
    let scaffold_result: Result<()> = (|| {
        fs::create_dir_all(&proposal_root)?;
        apply_template_bundle(&template_root.join("proposal-core"), &proposal_root, &replacements)?;
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
            vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
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
        "validate-proposal",
        "execute_stage",
        &format!("create-{}-proposal::validate-proposal", kind.as_str()),
        vec![
            "workflow.stage.execute".to_string(),
            "evidence.write".to_string(),
        ],
        vec![
            bundle_root.join("standard-validator.log").display().to_string(),
            bundle_root.join("stages/validate-proposal").display().to_string(),
        ],
        true,
        false,
        "low",
        Some("read_only_analysis"),
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
                vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
            );
            bail!(message);
        }
    };
    let validator_log = match run_static_proposal_validator_stack(&repo_root, &proposal_root, &bundle_root, kind) {
        Ok(log) => log,
        Err(error) => {
            let _ = finalize_workflow_stage(
                &stage_validate,
                "failed",
                Some(error.to_string()),
                vec![bundle_root.join("standard-validator.log").display().to_string()],
            );
            let _ = finalize_workflow_failure(
                &workflow_artifacts,
                &workflow_request,
                &workflow_grant,
                &started_at,
                error.to_string(),
                vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
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
        &started_at,
        &ExecutionOutcome {
            status: "succeeded".to_string(),
            started_at: started_at.clone(),
            completed_at: auth_now_rfc3339()?,
            error: None,
        },
        &SideEffectSummary {
            touched_scope: vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
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
    let workflow_request = ExecutionRequest {
        request_id: format!("audit-{}-proposal-{}", kind.as_str(), slugify(&rel_path(&repo_root, &proposal_root))),
        caller_path: "workflow".to_string(),
        action_type: "execute_workflow".to_string(),
        target_id: format!("audit-{}-proposal", kind.as_str()),
        requested_capabilities: vec![
            "workflow.execute".to_string(),
            "evidence.write".to_string(),
        ],
        side_effect_flags: SideEffectFlags {
            write_repo: true,
            write_evidence: true,
            ..SideEffectFlags::default()
        },
        risk_tier: "low".to_string(),
        workflow_mode: "human-only".to_string(),
        locality_scope: None,
        intent_ref: None,
        autonomy_context: None,
        actor_ref: None,
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
        metadata: BTreeMap::from([(
            "workflow_id".to_string(),
            format!("audit-{}-proposal", kind.as_str()),
        )]),
    };
    let workflow_grant = authorize_execution(&runtime_cfg, &policy, &workflow_request, None)?;
    fs::create_dir_all(&reports_root)?;
    fs::create_dir_all(&workflow_bundles_root)?;
    let date = today_string()?;
    let started_at = auth_now_rfc3339()?;
    let bundle_root = unique_directory(
        &workflow_bundles_root,
        &format!("{date}-audit-{}-proposal-{}", kind.as_str(), slugify(&rel_path(&repo_root, &proposal_root))),
    )?;
    fs::create_dir_all(bundle_root.join("reports"))?;
    fs::create_dir_all(bundle_root.join("stage-inputs"))?;
    fs::create_dir_all(bundle_root.join("stage-logs"))?;
    let workflow_artifacts =
        write_execution_start(&bundle_root.join("workflow-execution"), &workflow_request, &workflow_grant)?;
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
            vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
        );
        bail!(message);
    }

    let stage_validate = match authorize_workflow_stage(
        &runtime_cfg,
        &policy,
        &bundle_root,
        &format!("audit-{}-proposal", kind.as_str()),
        "validate-proposal",
        "execute_stage",
        &format!("audit-{}-proposal::validate-proposal", kind.as_str()),
        vec![
            "workflow.stage.execute".to_string(),
            "evidence.write".to_string(),
        ],
        vec![
            bundle_root.join("standard-validator.log").display().to_string(),
            bundle_root.join("stages/validate-proposal").display().to_string(),
        ],
        true,
        false,
        "low",
        Some("read_only_analysis"),
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
                vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
            );
            bail!(message);
        }
    };
    let validator_log = match run_static_proposal_validator_stack(&repo_root, &proposal_root, &bundle_root, kind) {
        Ok(log) => log,
        Err(error) => {
            let _ = finalize_workflow_stage(
                &stage_validate,
                "failed",
                Some(error.to_string()),
                vec![bundle_root.join("standard-validator.log").display().to_string()],
            );
            let _ = finalize_workflow_failure(
                &workflow_artifacts,
                &workflow_request,
                &workflow_grant,
                &started_at,
                error.to_string(),
                vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
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
        &started_at,
        &ExecutionOutcome {
            status: "succeeded".to_string(),
            started_at: started_at.clone(),
            completed_at: auth_now_rfc3339()?,
            error: None,
        },
        &SideEffectSummary {
            touched_scope: vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
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

    let reports_root = repo_root.join(REPORTS_ROOT_REL);
    let workflow_bundles_root = repo_root.join(WORKFLOW_REPORTS_ROOT_REL);
    let workflow_request = ExecutionRequest {
        request_id: format!("validate-proposal-{}", slugify(&proposal_rel)),
        caller_path: "workflow".to_string(),
        action_type: "execute_workflow".to_string(),
        target_id: "validate-proposal".to_string(),
        requested_capabilities: vec![
            "workflow.execute".to_string(),
            "evidence.write".to_string(),
        ],
        side_effect_flags: SideEffectFlags {
            write_evidence: true,
            ..SideEffectFlags::default()
        },
        risk_tier: "low".to_string(),
        workflow_mode: "human-only".to_string(),
        locality_scope: None,
        intent_ref: None,
        autonomy_context: None,
        actor_ref: None,
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
        metadata: BTreeMap::from([("workflow_id".to_string(), "validate-proposal".to_string())]),
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
    let workflow_artifacts =
        write_execution_start(&bundle_root.join("workflow-execution"), &workflow_request, &workflow_grant)?;
    let summary_report = unique_file(&reports_root, &format!("{date}-validate-proposal"), "md")?;

    if !proposal_root.is_dir() {
        let message = format!("target proposal not found: {}", proposal_root.display());
        let _ = finalize_workflow_failure(
            &workflow_artifacts,
            &workflow_request,
            &workflow_grant,
            &started_at,
            message.clone(),
            vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
        );
        bail!(message);
    }

    let manifest = load_proposal_manifest(&proposal_root)?;
    let stage_validate = authorize_workflow_stage(
        &runtime_cfg,
        &policy,
        &bundle_root,
        "validate-proposal",
        "validate-proposal",
        "execute_stage",
        "validate-proposal::validate-proposal",
        vec![
            "workflow.stage.execute".to_string(),
            "evidence.write".to_string(),
        ],
        vec![
            bundle_root.join("standard-validator.log").display().to_string(),
            bundle_root.join("stages/validate-proposal").display().to_string(),
        ],
        true,
        false,
        "low",
        Some("read_only_analysis"),
    )?;
    let validator_log =
        match run_proposal_validator_stack(&repo_root, &proposal_root, &bundle_root, &manifest.proposal_kind) {
            Ok(path) => path,
            Err(error) => {
                let _ = finalize_workflow_stage(
                    &stage_validate,
                    "failed",
                    Some(error.to_string()),
                    vec![bundle_root.join("standard-validator.log").display().to_string()],
                );
                let _ = finalize_workflow_failure(
                    &workflow_artifacts,
                    &workflow_request,
                    &workflow_grant,
                    &started_at,
                    error.to_string(),
                    vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
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

    let reports_root = repo_root.join(REPORTS_ROOT_REL);
    let workflow_bundles_root = repo_root.join(WORKFLOW_REPORTS_ROOT_REL);
    let workflow_request = ExecutionRequest {
        request_id: format!("promote-proposal-{}", slugify(&proposal_rel)),
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
        workflow_mode: "human-only".to_string(),
        locality_scope: None,
        intent_ref: None,
        autonomy_context: None,
        actor_ref: None,
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
        metadata: BTreeMap::from([("workflow_id".to_string(), "promote-proposal".to_string())]),
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
    let workflow_artifacts =
        write_execution_start(&bundle_root.join("workflow-execution"), &workflow_request, &workflow_grant)?;
    let summary_report = unique_file(&reports_root, &format!("{date}-promote-proposal"), "md")?;

    if !proposal_root.is_dir() {
        let message = format!("target proposal not found: {}", proposal_root.display());
        let _ = finalize_workflow_failure(
            &workflow_artifacts,
            &workflow_request,
            &workflow_grant,
            &started_at,
            message.clone(),
            vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
        );
        bail!(message);
    }

    validate_repo_relative_paths(&repo_root, &options.promotion_evidence, "promotion_evidence")?;
    let mut manifest = load_proposal_manifest(&proposal_root)?;
    ensure!(
        proposal_rel == expected_active_proposal_rel(&manifest.proposal_kind, &manifest.proposal_id),
        "proposal must be promoted from the active path: {}",
        proposal_rel
    );
    ensure!(
        manifest.status == "accepted",
        "promote-proposal requires status=accepted, found {}",
        manifest.status
    );

    let stage_validate = authorize_workflow_stage(
        &runtime_cfg,
        &policy,
        &bundle_root,
        "promote-proposal",
        "validate-proposal",
        "execute_stage",
        "promote-proposal::validate-proposal",
        vec![
            "workflow.stage.execute".to_string(),
            "evidence.write".to_string(),
        ],
        vec![
            bundle_root.join("standard-validator.log").display().to_string(),
            bundle_root.join("stages/validate-proposal").display().to_string(),
        ],
        true,
        false,
        "low",
        Some("read_only_analysis"),
    )?;
    let validator_log =
        match run_proposal_validator_stack(&repo_root, &proposal_root, &bundle_root, &manifest.proposal_kind) {
            Ok(path) => path,
            Err(error) => {
                let _ = finalize_workflow_stage(
                    &stage_validate,
                    "failed",
                    Some(error.to_string()),
                    vec![bundle_root.join("standard-validator.log").display().to_string()],
                );
                let _ = finalize_workflow_failure(
                    &workflow_artifacts,
                    &workflow_request,
                    &workflow_grant,
                    &started_at,
                    error.to_string(),
                    vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
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

    let stage_promote = authorize_workflow_stage(
        &runtime_cfg,
        &policy,
        &bundle_root,
        "promote-proposal",
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
            bundle_root.join("stages/promote-proposal").display().to_string(),
        ],
        false,
        true,
        "medium",
        Some("scoped_repo_mutation"),
    )?;
    let promote_result: Result<()> = (|| {
        let original_manifest = manifest.clone();
        ensure_promotion_targets_ready(&repo_root, &manifest, &proposal_root)?;
        manifest.status = "implemented".to_string();
        write_proposal_manifest(&proposal_root, &manifest)?;
        if let Err(error) = regenerate_proposal_registry(&repo_root, true) {
            write_proposal_manifest(&proposal_root, &original_manifest)?;
            return Err(error);
        }
        Ok(())
    })();
    if let Err(error) = promote_result {
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
            vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
        );
        return Err(error);
    }
    finalize_workflow_stage(
        &stage_promote,
        "succeeded",
        None,
        vec![
            rel_path(&repo_root, &proposal_root.join("proposal.yml")),
            ".octon/generated/proposals/registry.yml".to_string(),
        ],
    )?;

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
                "- promote proposal | proposal_path={} | promotion_evidence={}",
                proposal_rel,
                options.promotion_evidence.join(", ")
            ),
        ],
    )?;
    let summary = format!(
        "# Promote Proposal Summary\n\n- workflow_id: `promote-proposal`\n- proposal_path: `{}`\n- proposal_kind: `{}`\n- final_verdict: `implemented`\n- bundle_root: `{}`\n- summary_report: `{}`\n- validator_log: `{}`\n- promotion_evidence: `{}`\n",
        proposal_rel,
        manifest.proposal_kind,
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
            "# Validation\n\n- final_verdict: `implemented`\n- proposal_kind: `{}`\n- validator_log: `{}`\n- status_after_promotion: `implemented`\n- registry_sync: `passed`\n",
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

    let reports_root = repo_root.join(REPORTS_ROOT_REL);
    let workflow_bundles_root = repo_root.join(WORKFLOW_REPORTS_ROOT_REL);
    let workflow_request = ExecutionRequest {
        request_id: format!("archive-proposal-{}", slugify(&proposal_rel)),
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
        workflow_mode: "human-only".to_string(),
        locality_scope: None,
        intent_ref: None,
        autonomy_context: None,
        actor_ref: None,
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
        metadata: BTreeMap::from([("workflow_id".to_string(), "archive-proposal".to_string())]),
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
    let workflow_artifacts =
        write_execution_start(&bundle_root.join("workflow-execution"), &workflow_request, &workflow_grant)?;
    let summary_report = unique_file(&reports_root, &format!("{date}-archive-proposal"), "md")?;

    if !proposal_root.is_dir() {
        let message = format!("target proposal not found: {}", proposal_root.display());
        let _ = finalize_workflow_failure(
            &workflow_artifacts,
            &workflow_request,
            &workflow_grant,
            &started_at,
            message.clone(),
            vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
        );
        bail!(message);
    }

    let mut manifest = load_proposal_manifest(&proposal_root)?;
    ensure!(
        proposal_rel == expected_active_proposal_rel(&manifest.proposal_kind, &manifest.proposal_id),
        "proposal must be archived from the active path: {}",
        proposal_rel
    );
    ensure!(
        manifest.status != "archived",
        "proposal is already archived: {}",
        proposal_rel
    );
    match options.disposition.as_str() {
        "implemented" => {
            ensure!(
                manifest.status == "implemented",
                "archive-proposal with disposition=implemented requires status=implemented, found {}",
                manifest.status
            );
            validate_repo_relative_paths(&repo_root, &options.promotion_evidence, "promotion_evidence")?;
        }
        "rejected" => {
            ensure!(
                manifest.status == "rejected",
                "archive-proposal with disposition=rejected requires status=rejected, found {}",
                manifest.status
            );
        }
        "historical" | "superseded" => {
            if !options.promotion_evidence.is_empty() {
                validate_repo_relative_paths(&repo_root, &options.promotion_evidence, "promotion_evidence")?;
            }
        }
        other => bail!("unsupported archive disposition '{}'", other),
    }

    let stage_validate = authorize_workflow_stage(
        &runtime_cfg,
        &policy,
        &bundle_root,
        "archive-proposal",
        "validate-proposal",
        "execute_stage",
        "archive-proposal::validate-proposal",
        vec![
            "workflow.stage.execute".to_string(),
            "evidence.write".to_string(),
        ],
        vec![
            bundle_root.join("standard-validator.log").display().to_string(),
            bundle_root.join("stages/validate-proposal").display().to_string(),
        ],
        true,
        false,
        "low",
        Some("read_only_analysis"),
    )?;
    let validator_log =
        match run_proposal_validator_stack(&repo_root, &proposal_root, &bundle_root, &manifest.proposal_kind) {
            Ok(path) => path,
            Err(error) => {
                let _ = finalize_workflow_stage(
                    &stage_validate,
                    "failed",
                    Some(error.to_string()),
                    vec![bundle_root.join("standard-validator.log").display().to_string()],
                );
                let _ = finalize_workflow_failure(
                    &workflow_artifacts,
                    &workflow_request,
                    &workflow_grant,
                    &started_at,
                    error.to_string(),
                    vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
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

    let archived_from_status = manifest.status.clone();
    let archived_rel = expected_archived_proposal_rel(&manifest.proposal_kind, &manifest.proposal_id);
    let archived_root = repo_root.join(&archived_rel);
    let stage_archive = authorize_workflow_stage(
        &runtime_cfg,
        &policy,
        &bundle_root,
        "archive-proposal",
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
            bundle_root.join("stages/archive-proposal").display().to_string(),
        ],
        false,
        true,
        "medium",
        Some("scoped_repo_mutation"),
    )?;
    let archive_result: Result<()> = (|| {
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
            vec![bundle_root.display().to_string(), proposal_root.display().to_string()],
        );
        return Err(error);
    }
    finalize_workflow_stage(
        &stage_archive,
        "succeeded",
        None,
        vec![
            archived_rel.clone(),
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

        let summary_report =
            unique_file(&reports_root, &format!("{date}-audit-design-proposal"), "md")?;

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
                let failure = RunFailure::new(
                    FailureClass::StandardValidator,
                    None,
                    error.to_string(),
                );
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
    ) -> ExecutionRequest {
        metadata.insert("workflow_id".to_string(), WORKFLOW_ID.to_string());
        metadata.insert("stage_id".to_string(), stage.id.to_string());
        ExecutionRequest {
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
                shell: self.options.executor != ExecutorKind::Mock,
                network: false,
                model_invoke: self.options.executor != ExecutorKind::Mock,
                state_mutation: false,
                publication: false,
                branch_mutation: false,
            },
            risk_tier: if stage.class.is_file_writing() {
                "medium".to_string()
            } else {
                "low".to_string()
            },
            workflow_mode: "human-only".to_string(),
            locality_scope: None,
            intent_ref: None,
            autonomy_context: None,
            actor_ref: None,
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
            metadata: with_authority_env_metadata(metadata),
        }
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
            fs::write(&prompt_packet_path, &prompt_markdown)
                .with_context(|| format!("write prompt packet {}", prompt_packet_path.display()))
                .map_err(|error| {
                    RunFailure::new(
                        FailureClass::PromptPacket,
                        Some(stage.id),
                        error.to_string(),
                    )
                })?;

            let relative_report_path = PathBuf::from("reports").join(stage.report_file);
            report_paths.insert(
                stage.id.to_string(),
                relative_report_path.display().to_string(),
            );

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
            let stage_request = self.stage_request(stage, executor_metadata);
            let stage_grant = authorize_execution(&self.runtime_cfg, &policy, &stage_request, None)
                .map_err(|error| {
                    RunFailure::new(
                        FailureClass::ExecutorEnvironment,
                        Some(stage.id),
                        error.to_string(),
                    )
                })?;
            let stage_artifacts = write_execution_start(
                &self.bundle_root.join("stages").join(stage.id),
                &stage_request,
                &stage_grant,
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
            let execution = match self.execute_stage(stage, &prompt_markdown, &report_path, &log_path) {
                Ok(execution) => execution,
                Err(error) => {
                    let _ = finalize_execution(
                        &stage_artifacts,
                        &stage_request,
                        &stage_grant,
                        &stage_started_at,
                        &ExecutionOutcome {
                            status: "failed".to_string(),
                            started_at: stage_started_at.clone(),
                            completed_at: auth_now_rfc3339().unwrap_or_else(|_| stage_started_at.clone()),
                            error: Some(error.to_string()),
                        },
                        &SideEffectSummary {
                            touched_scope: vec![
                                rel_path(&self.repo_root, &report_path),
                                rel_path(&self.repo_root, &log_path),
                            ],
                            executor_profile: Some(Self::stage_executor_profile(stage).to_string()),
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
    ) -> Result<StageExecutionResult> {
        match resolve_executor(self.options.executor, self.options.executor_bin.as_deref())? {
            ResolvedExecutor::Mock => {
                self.execute_stage_mock(stage, prompt_markdown, report_path, log_path)?;
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
    ) -> Result<Vec<String>> {
        let profile = resolve_executor_profile(&self.runtime_cfg, Self::stage_executor_profile(stage))?;
        let (mut command, blocked_flags) = build_executor_command(ExecutorCommandSpec {
            kind: ManagedExecutorKind::Codex,
            executor_bin,
            repo_root: &self.repo_root,
            output_path: Some(report_path),
            model: self.options.model.as_deref(),
            profile,
        })?;

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
    ) -> Result<Vec<String>> {
        let profile = resolve_executor_profile(&self.runtime_cfg, Self::stage_executor_profile(stage))?;
        let (mut command, blocked_flags) = build_executor_command(ExecutorCommandSpec {
            kind: ManagedExecutorKind::Claude,
            executor_bin,
            repo_root: &self.repo_root,
            output_path: None,
            model: self.options.model.as_deref(),
            profile,
        })?;

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
        )?;
        if !output.status.success() {
            bail!(
                "stage {} executor failed with status {} (see {})",
                stage.id,
                output.status,
                log_path.display()
            );
        }

        fs::write(report_path, &output.stdout)
            .with_context(|| format!("write stage report {}", report_path.display()))?;
        Ok(blocked_flags)
    }

    fn execute_stage_mock(
        &self,
        stage: &StageDefinition,
        prompt_markdown: &str,
        report_path: &Path,
        log_path: &Path,
    ) -> Result<()> {
        let mock_root = self.target_package.join(".octon-mock-runner");
        fs::create_dir_all(&mock_root)
            .with_context(|| format!("create mock artifact root {}", mock_root.display()))?;

        let (mutations, report_body) =
            build_mock_stage_artifacts(stage, &self.target_package, &mock_root, prompt_markdown)?;

        for (path, contents) in mutations {
            if let Some(parent) = path.parent() {
                fs::create_dir_all(parent)
                    .with_context(|| format!("create parent directory {}", parent.display()))?;
            }
            fs::write(&path, contents)
                .with_context(|| format!("write mock artifact {}", path.display()))?;
        }

        fs::write(report_path, report_body)
            .with_context(|| format!("write mock stage report {}", report_path.display()))?;
        fs::write(
            log_path,
            format!(
                "# Stage {}\n\n- executor: mock\n- status: synthetic-success\n- report: {}\n",
                stage.id,
                report_path.display()
            ),
        )
        .with_context(|| format!("write stage log {}", log_path.display()))?;

        Ok(())
    }

    fn write_executor_log(
        &self,
        stage_id: &str,
        executor_label: String,
        output: &std::process::Output,
        log_path: &Path,
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
        fs::write(log_path, log).with_context(|| format!("write stage log {}", log_path.display()))
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
            body.push_str(&format!(
                "- failure_class: `{}`\n",
                failure.class.as_str()
            ));
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
            body.push_str(&format!(
                "- failure_class: `{}`\n",
                failure.class.as_str()
            ));
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
    replacements.insert(
        "PROPOSAL_KIND".to_string(),
        "design".to_string(),
    );
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
        "# Proposal Reading And Precedence Map\n\n## Purpose\n\nThis file defines the proposal-local reading order, authority boundaries, and evidence model for this temporary design proposal. It does not make the proposal a canonical repository authority.\n\n## External Authorities\n\n| Concern | Source of truth | Notes |\n| --- | --- | --- |\n| Repo-wide authority and non-canonical rules | `.octon/README.md`, `.octon/framework/cognition/_meta/architecture/specification.md`, `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` | These durable surfaces outrank this proposal. |\n| Proposal workspace layout and lifecycle contract | `.octon/inputs/exploratory/proposals/README.md`, `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`, `.octon/framework/scaffolding/governance/patterns/design-proposal-standard.md` | These durable proposal rules define placement, lifecycle, and package expectations. |\n| Design subtype contract | `.octon/framework/scaffolding/runtime/templates/design-proposal.schema.json`, `.octon/framework/assurance/runtime/_ops/scripts/validate-design-proposal.sh` | The subtype manifest, module rules, and validator behavior must remain aligned. |\n| Proposal registry projection contract | `.octon/generated/proposals/registry.yml`, `.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json` | The registry is projection-only and never outranks the manifests. |\n| Workflow evidence location | `.octon/state/evidence/runs/workflows/`, `.octon/state/evidence/validation/` | Proposal operation receipts belong under retained evidence, not inside the proposal package. |\n\n## Primary Proposal Inputs\n\n### Core\n\n- `proposal.yml`\n- `design-proposal.yml`\n- `implementation/README.md`\n- `implementation/minimal-implementation-blueprint.md`\n- `implementation/first-implementation-plan.md`\n\n### Class-Specific Normative Docs\n\n{}\n\n### Optional Modules\n\n{}\n\n### Discovery Projection\n\n- `/.octon/generated/proposals/registry.yml`\n\n## Proposal-Local Authority Roles\n\n| Artifact | Role | Authority level |\n| --- | --- | --- |\n| `proposal.yml` | Base identity, scope, targets, lifecycle, and exit contract | Highest proposal-local |\n| `design-proposal.yml` | Design subtype class, module, and validation contract | Secondary proposal-local |\n| Class-specific normative docs | The design-spec authority that implementation and review rely on | Primary working design surface |\n| `implementation/*.md` | Implementation framing and first-slice guidance | Supporting implementation guidance |\n| Optional module docs | Supporting reference, history, contracts, conformance, and canonicalization material | Supporting, not authoritative over manifests |\n| `navigation/source-of-truth-map.md` | Manual proposal-local precedence, authority, and evidence map | Explanatory support |\n| `navigation/artifact-catalog.md` | Generated file inventory for the current package shape | Low-authority generated inventory |\n| `/.octon/generated/proposals/registry.yml` | Discovery projection rebuilt from proposal manifests | Projection only |\n| `README.md` | Human entry point and reading guidance | Explanatory only |\n\n## Derived Or Projection-Only Surfaces\n\n| Surface | Status | Rule |\n| --- | --- | --- |\n| `/.octon/generated/proposals/registry.yml` | Committed projection | Must be regenerated from manifests or fail-closed validated; never authoritative over manifests |\n| `navigation/artifact-catalog.md` | Generated inventory | Reflects the current package shape but does not define lifecycle truth |\n| Workflow bundles under `state/evidence/runs/workflows/**` | Retained evidence | Evidence of proposal operations, not lifecycle authority |\n\n## Conflict Resolution\n\n1. Repository-wide governance and durable authorities\n2. `proposal.yml`\n3. `design-proposal.yml`\n4. Class-specific normative docs\n5. `implementation/README.md`\n6. `implementation/minimal-implementation-blueprint.md`\n7. `implementation/first-implementation-plan.md`\n8. Optional module docs\n9. `navigation/source-of-truth-map.md`\n10. `navigation/artifact-catalog.md`\n11. `/.octon/generated/proposals/registry.yml`\n12. `README.md`\n\n## Boundary Rules\n\n- This proposal remains temporary and non-canonical even when its content is implementation-ready.\n- Durable runtime, documentation, policy, and contract outputs must be promoted outside `/.octon/inputs/exploratory/proposals/`.\n- Proposal discovery is allowed through the committed registry projection, but lifecycle truth stays in `proposal.yml` and `design-proposal.yml`.\n- Proposal operation evidence belongs under `state/evidence/**`, not inside the proposal package or under `generated/**`.\n",
        primary_docs, optional_docs
    )
}

fn expected_active_proposal_rel(proposal_kind: &str, proposal_id: &str) -> String {
    format!("{PROPOSALS_ROOT_REL}/{proposal_kind}/{proposal_id}")
}

fn expected_archived_proposal_rel(proposal_kind: &str, proposal_id: &str) -> String {
    format!("{PROPOSALS_ROOT_REL}/.archive/{proposal_kind}/{proposal_id}")
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
        StaticProposalKind::Migration => ".octon/framework/scaffolding/governance/patterns/migration-proposal-standard.md",
        StaticProposalKind::Policy => ".octon/framework/scaffolding/governance/patterns/policy-proposal-standard.md",
        StaticProposalKind::Architecture => ".octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md",
    }
}

fn static_schema_path(kind: StaticProposalKind) -> &'static str {
    match kind {
        StaticProposalKind::Migration => ".octon/framework/scaffolding/runtime/templates/migration-proposal.schema.json",
        StaticProposalKind::Policy => ".octon/framework/scaffolding/runtime/templates/policy-proposal.schema.json",
        StaticProposalKind::Architecture => ".octon/framework/scaffolding/runtime/templates/architecture-proposal.schema.json",
    }
}

fn static_validator_rel(kind: StaticProposalKind) -> &'static str {
    match kind {
        StaticProposalKind::Migration => ".octon/framework/assurance/runtime/_ops/scripts/validate-migration-proposal.sh",
        StaticProposalKind::Policy => ".octon/framework/assurance/runtime/_ops/scripts/validate-policy-proposal.sh",
        StaticProposalKind::Architecture => ".octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh",
    }
}

fn build_static_source_of_truth_map(kind: StaticProposalKind) -> String {
    let primary_docs = format_markdown_bullets(static_primary_docs(kind));
    format!(
        "# Proposal Reading And Precedence Map\n\n## Purpose\n\nThis file defines the proposal-local reading order, authority boundaries, and evidence model for this temporary {} proposal. It does not make the proposal a canonical repository authority.\n\n## External Authorities\n\n| Concern | Source of truth | Notes |\n| --- | --- | --- |\n| Repo-wide authority and non-canonical rules | `.octon/README.md`, `.octon/framework/cognition/_meta/architecture/specification.md`, `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` | These durable surfaces outrank this proposal. |\n| Proposal workspace layout and lifecycle contract | `.octon/inputs/exploratory/proposals/README.md`, `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`, `{}` | These durable proposal rules define placement, lifecycle, and subtype requirements. |\n| Subtype contract | `{}`, `{}` | The subtype manifest shape, template, and validator behavior must remain aligned. |\n| Proposal registry projection contract | `.octon/generated/proposals/registry.yml`, `.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json` | The registry is projection-only and never outranks the manifests. |\n| Workflow evidence location | `.octon/state/evidence/runs/workflows/`, `.octon/state/evidence/validation/` | Proposal operation receipts belong under retained evidence, not inside the proposal package. |\n\n## Primary Proposal Inputs\n\n1. `proposal.yml`\n2. `{}`\n3. `navigation/source-of-truth-map.md`\n4. {}\n5. `navigation/artifact-catalog.md`\n6. `/.octon/generated/proposals/registry.yml`\n\n## Proposal-Local Authority Roles\n\n| Artifact | Role | Authority level |\n| --- | --- | --- |\n| `proposal.yml` | Base identity, scope, targets, lifecycle, and exit contract | Highest proposal-local |\n| `{}` | Subtype-specific structured contract | Secondary proposal-local |\n| Primary subtype docs | The proposal's working design/architecture/policy surface | Primary working surface |\n| `navigation/source-of-truth-map.md` | Manual proposal-local precedence, authority, and evidence map | Explanatory support |\n| `navigation/artifact-catalog.md` | Generated file inventory for the current package shape | Low-authority generated inventory |\n| `/.octon/generated/proposals/registry.yml` | Discovery projection rebuilt from proposal manifests | Projection only |\n| `README.md` | Human entry point and reading guidance | Explanatory only |\n\n## Derived Or Projection-Only Surfaces\n\n| Surface | Status | Rule |\n| --- | --- | --- |\n| `/.octon/generated/proposals/registry.yml` | Committed projection | Must be regenerated from manifests or fail-closed validated; never authoritative over manifests |\n| `navigation/artifact-catalog.md` | Generated inventory | Reflects the current package shape but does not define lifecycle truth |\n| Workflow bundles under `state/evidence/runs/workflows/**` | Retained evidence | Evidence of proposal operations, not lifecycle authority |\n\n## Conflict Resolution\n\n1. Repository-wide governance and durable authorities\n2. `proposal.yml`\n3. `{}`\n4. Primary subtype docs\n5. `navigation/source-of-truth-map.md`\n6. `navigation/artifact-catalog.md`\n7. `/.octon/generated/proposals/registry.yml`\n8. `README.md`\n\n## Boundary Rules\n\n- This proposal remains temporary and non-canonical at every lifecycle stage.\n- Durable runtime, documentation, policy, and contract outputs must be promoted outside `/.octon/inputs/exploratory/proposals/`.\n- Proposal discovery is allowed through the committed registry projection, but lifecycle truth stays in `proposal.yml` and the subtype manifest.\n- Proposal operation evidence belongs under `state/evidence/**`, not inside the proposal package or under `generated/**`.\n",
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
        "# Artifact Catalog\n\nThis catalog is generated from the on-disk proposal package shape. Regenerate it whenever files are added, removed, or reorganized.\n\n## Proposal\n\n- `proposal_id`: `{}`\n- `proposal_kind`: `{}`\n- `proposal_path`: `{}`\n\n## Files\n\n| Path | Role |\n| --- | --- |\n{}",
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
        body.push_str(&format!("- validator_log: `{}`\n", rel_path(repo_root, validator_log)));
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
        format!(
            "# Stage {stage_id}\n\n- stage: `{stage_slug}`\n- status: `{status}`\n\n{body}\n"
        ),
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
    run_validator_stack(
        repo_root,
        proposal_root,
        bundle_root,
        &[
            ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh",
            proposal_validator_rel(proposal_kind)?,
        ],
    )
}

fn run_validator_stack(
    repo_root: &Path,
    proposal_root: &Path,
    bundle_root: &Path,
    validators: &[&str],
) -> Result<PathBuf> {
    let proposal_rel = rel_path(repo_root, proposal_root);
    let log_path = bundle_root.join("standard-validator.log");
    let mut log = String::from("# Proposal Validator Stack\n\n");

    for validator_rel in validators {
        let script = repo_root.join(validator_rel);
        if !script.is_file() {
            bail!("missing proposal validator: {}", script.display());
        }
        let output = Command::new("bash")
            .arg(&script)
            .arg("--package")
            .arg(&proposal_rel)
            .current_dir(repo_root)
            .output()
            .with_context(|| format!("run validator {} for {}", validator_rel, proposal_root.display()))?;
        log.push_str(&format!(
            "## `{}`\n\n- proposal: `{}`\n- status: `{}`\n\n### stdout\n\n```\n{}\n```\n\n### stderr\n\n```\n{}\n```\n\n",
            validator_rel,
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
                validator_rel,
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
    replacements.insert("PROPOSAL_TITLE".to_string(), options.proposal_title.trim().to_string());
    replacements.insert(
        "PROPOSAL_SUMMARY".to_string(),
        format!("Temporary implementation-scoped {} proposal.", kind.as_str()),
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
    let raw =
        fs::read_to_string(&manifest_path).with_context(|| format!("read {}", manifest_path.display()))?;
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
        ensure!(
            canonical.exists(),
            "{} path must exist: {}",
            label,
            path
        );
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
        id: bundle_root.file_name().and_then(|v| v.to_str()).unwrap_or("workflow-bundle").to_string(),
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
    fs::write(bundle_root.join("bundle.yml"), serde_yaml::to_string(&metadata)?)?;
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
        id: bundle_root.file_name().and_then(|v| v.to_str()).unwrap_or("workflow-bundle").to_string(),
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
    fs::write(bundle_root.join("bundle.yml"), serde_yaml::to_string(&metadata)?)?;
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

#[cfg(test)]
mod tests {
    use super::*;
    use std::os::unix::fs::PermissionsExt;
    use std::time::{SystemTime, UNIX_EPOCH};

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

    fn seed_policy_runtime_env() {
        let source_root = source_repo_root();
        std::env::set_var(
            "OCTON_POLICY_RUNNER_OVERRIDE",
            source_root.join(".octon/framework/engine/runtime/policy"),
        );
        std::env::set_var(
            "OCTON_POLICY_BIN",
            source_root.join(".octon/generated/.tmp/engine/build/runtime-crates-target/debug/octon-policy"),
        );
    }

    fn write_file(path: &Path, contents: &str) {
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).expect("parent directory should exist");
        }
        fs::write(path, contents).expect("file should be written");
    }

    fn seed_pipeline_fixture(root: &Path) -> (PathBuf, PathBuf) {
        seed_policy_runtime_env();
        let octon_dir = root.join(".octon");
        fs::create_dir_all(&octon_dir).expect(".octon dir should exist");
        fs::create_dir_all(octon_dir.join("instance/charter"))
            .expect("workspace charter dir should exist");
        write_file(
            &octon_dir.join("instance/charter/workspace.yml"),
            "intent_id: \"intent://test/design-workflow\"\nversion: \"1.0.0\"\n",
        );
        fs::create_dir_all(octon_dir.join("framework/capabilities/governance/policy"))
            .expect("policy root should exist");
        write_file(
            &octon_dir.join("octon.yml"),
            "engine:\n  runtime:\n    policy_file: framework/capabilities/governance/policy/deny-by-default.v2.yml\n",
        );
        fs::copy(
            source_repo_root().join(".octon/framework/capabilities/governance/policy/deny-by-default.v2.yml"),
            octon_dir.join("framework/capabilities/governance/policy/deny-by-default.v2.yml"),
        )
        .expect("copy ACP policy");

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
            "04-design-red-team.md",
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

    fn seed_create_design_package_fixture(root: &Path) -> PathBuf {
        seed_policy_runtime_env();
        let octon_dir = root.join(".octon");
        fs::create_dir_all(&octon_dir).expect(".octon dir should exist");
        fs::create_dir_all(octon_dir.join("instance/charter"))
            .expect("workspace charter dir should exist");
        fs::create_dir_all(octon_dir.join("instance/governance/ownership"))
            .expect("governance ownership dir should exist");
        write_file(
            &octon_dir.join("instance/charter/workspace.yml"),
            "intent_id: \"intent://test/create-design-package\"\nversion: \"1.0.0\"\n",
        );
        write_file(
            &octon_dir.join("instance/governance/ownership/registry.yml"),
            "schema_version: \"ownership-registry-v1\"\ndirective_precedence:\n  - mission_owner\noperators:\n  - operator_id: \"fixtures\"\n    display_name: \"Fixtures\"\n    contact: \"repo://fixtures\"\ndefaults:\n  operator_id: \"fixtures\"\n  support_tier: \"repo-local-transitional\"\nassets:\n  - asset_id: \"workflow-scope\"\n    path_globs:\n      - \"workflow-scope\"\n    owners:\n      - \"fixtures\"\nservices: []\nsubscriptions: {}\n",
        );
        fs::copy(
            source_repo_root().join(".octon/instance/governance/support-targets.yml"),
            octon_dir.join("instance/governance/support-targets.yml"),
        )
        .expect("copy support targets");
        fs::create_dir_all(octon_dir.join("instance/capabilities/runtime/packs"))
            .expect("runtime pack dir should exist");
        fs::copy(
            source_repo_root().join(".octon/instance/capabilities/runtime/packs/registry.yml"),
            octon_dir.join("instance/capabilities/runtime/packs/registry.yml"),
        )
        .expect("copy runtime pack registry");
        fs::create_dir_all(octon_dir.join("framework/capabilities/governance/policy"))
            .expect("policy root should exist");
        copy_tree(
            &source_repo_root().join(".octon/framework/engine/runtime/adapters"),
            &root.join(".octon/framework/engine/runtime/adapters"),
        );
        copy_tree(
            &source_repo_root().join(".octon/framework/capabilities/packs"),
            &root.join(".octon/framework/capabilities/packs"),
        );
        write_file(
            &octon_dir.join("octon.yml"),
            "engine:\n  runtime:\n    policy_file: framework/capabilities/governance/policy/deny-by-default.v2.yml\n",
        );
        fs::copy(
            source_repo_root().join(".octon/framework/capabilities/governance/policy/deny-by-default.v2.yml"),
            octon_dir.join("framework/capabilities/governance/policy/deny-by-default.v2.yml"),
        )
        .expect("copy ACP policy");

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
            &source_root.join(".octon/framework/cognition/_meta/architecture/generated/proposals/schemas"),
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
        let root = make_temp_root("render");
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
        let root = make_temp_root("prepare-only");
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
        let root = make_temp_root("mock-run");
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
        let root = make_temp_root("mock-rigorous");
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
            .join("reports/03-design-red-team.md")
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
        let root = make_temp_root("failing-executor");
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
                model: None,
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
        let validation = fs::read_to_string(bundle_root.join("validation.md"))
            .expect("validation should exist");
        let summary = fs::read_to_string(bundle_root.join("summary.md"))
            .expect("summary should exist");
        let commands = fs::read_to_string(bundle_root.join("commands.md"))
            .expect("commands log should exist");

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
        let root = make_temp_root("create-runtime");
        let octon_dir = seed_create_design_package_fixture(&root);

        let result = run_create_design_package_from_octon_dir(
            &octon_dir,
            RunCreateDesignPackageOptions {
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
        let root = make_temp_root("create-experience");
        let octon_dir = seed_create_design_package_fixture(&root);

        let result = run_create_design_package_from_octon_dir(
            &octon_dir,
            RunCreateDesignPackageOptions {
                package_id: "experience-package".to_string(),
                package_title: "Experience Package".to_string(),
                package_class: DesignPackageClass::ExperienceProduct,
                promotion_scope: ProposalScope::OctonInternal,
                implementation_targets: vec![".octon/framework/scaffolding/runtime/example.md".to_string()],
                include_contracts: None,
                include_conformance: None,
                include_canonicalization: None,
            },
        )
        .expect("create-design-proposal should succeed");

        let package_root = root.join(".octon/inputs/exploratory/proposals/design/experience-package");
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
        let root = make_temp_root("create-duplicate");
        let octon_dir = seed_create_design_package_fixture(&root);

        run_create_design_package_from_octon_dir(
            &octon_dir,
            RunCreateDesignPackageOptions {
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
        let validation = fs::read_to_string(bundle_root.join("validation.md"))
            .expect("validation should exist");
        let summary = fs::read_to_string(bundle_root.join("summary.md"))
            .expect("summary should exist");

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
    fn proposal_registry_preserves_same_id_across_kinds() {
        let root = make_temp_root("proposal-registry-kinds");
        let octon_dir = seed_create_design_package_fixture(&root);

        run_create_static_proposal_from_octon_dir(
            &octon_dir,
            StaticProposalKind::Migration,
            RunCreateStaticProposalOptions {
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
        let root = make_temp_root("create-artifacts");
        let octon_dir = seed_create_design_package_fixture(&root);

        let result = run_create_design_package_from_octon_dir(
            &octon_dir,
            RunCreateDesignPackageOptions {
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
            result.bundle_root.join("workflow-execution/execution-receipt.json"),
            result.bundle_root.join("stages/03-scaffold-proposal/execution-receipt.json"),
            result.bundle_root.join("stages/04-validate-proposal/execution-receipt.json"),
        ] {
            assert!(path.is_file(), "expected execution artifact {}", path.display());
        }

        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn create_static_and_audit_proposal_write_execution_artifacts() {
        let root = make_temp_root("static-artifacts");
        let octon_dir = seed_create_design_package_fixture(&root);

        let create_result = run_create_static_proposal_from_octon_dir(
            &octon_dir,
            StaticProposalKind::Architecture,
            RunCreateStaticProposalOptions {
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
                proposal_path: PathBuf::from(".octon/inputs/exploratory/proposals/architecture/auditable-static"),
            },
        )
        .expect("static proposal audit should succeed");

        for path in [
            create_result.bundle_root.join("workflow-execution/execution-receipt.json"),
            create_result.bundle_root.join("stages/scaffold-proposal/execution-receipt.json"),
            create_result.bundle_root.join("stages/validate-proposal/execution-receipt.json"),
            audit_result.bundle_root.join("workflow-execution/execution-receipt.json"),
            audit_result.bundle_root.join("stages/validate-proposal/execution-receipt.json"),
        ] {
            assert!(path.is_file(), "expected execution artifact {}", path.display());
        }

        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn create_static_proposal_failure_writes_execution_artifacts() {
        let root = make_temp_root("static-create-failure");
        let octon_dir = seed_create_design_package_fixture(&root);

        run_create_static_proposal_from_octon_dir(
            &octon_dir,
            StaticProposalKind::Policy,
            RunCreateStaticProposalOptions {
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
        assert!(bundle_root.join("workflow-execution/execution-receipt.json").is_file());
        assert!(bundle_root.join("workflow-execution/outcome.json").is_file());

        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn audit_static_missing_target_writes_execution_artifacts() {
        let root = make_temp_root("static-audit-failure");
        let octon_dir = seed_create_design_package_fixture(&root);

        let error = run_audit_static_proposal_from_octon_dir(
            &octon_dir,
            StaticProposalKind::Architecture,
            RunAuditStaticProposalOptions {
                proposal_path: PathBuf::from(".octon/inputs/exploratory/proposals/architecture/missing"),
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
        assert!(bundle_root.join("workflow-execution/execution-receipt.json").is_file());
        assert!(bundle_root.join("workflow-execution/outcome.json").is_file());

        fs::remove_dir_all(root).ok();
    }
}
