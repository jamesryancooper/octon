use anyhow::{bail, Context, Result};
use octon_core::config::{ConfigLoader, RuntimeConfig};
use octon_core::policy::PolicyEngine;
use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, HashMap};
use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use time::format_description;

use crate::request;
use crate::workflow::{
    self, DesignPackageClass, ExecutorKind, PipelineMode, ProposalScope, RunArchiveProposalOptions,
    RunAuditStaticProposalOptions, RunCreateDesignPackageOptions, RunCreateStaticProposalOptions,
    RunDesignPackageOptions, RunPromoteProposalOptions, RunValidateProposalOptions,
    StaticProposalKind,
};
use octon_authority_engine::{
    authorize_execution, build_executor_command, default_autonomy_context, finalize_execution,
    now_rfc3339 as auth_now_rfc3339, resolve_executor_profile, write_execution_start,
    ExecutionOutcome, ExecutionRequest, ExecutorCommandSpec, ManagedExecutorKind,
    ReviewRequirements, ScopeConstraints, SideEffectFlags, SideEffectSummary,
};

const WORKFLOW_REPORTS_ROOT_REL: &str = ".octon/state/evidence/runs/workflows";

fn workflows_root(octon_dir: &Path) -> PathBuf {
    octon_dir
        .join("framework")
        .join("orchestration")
        .join("runtime")
        .join("workflows")
}

#[derive(Debug, Clone)]
pub struct RunPipelineOptions {
    pub pipeline_id: String,
    pub run_id: Option<String>,
    pub mission_id: Option<String>,
    pub resume_existing: bool,
    pub executor: ExecutorKind,
    pub executor_bin: Option<PathBuf>,
    pub output_slug: Option<String>,
    pub model: Option<String>,
    pub prepare_only: bool,
    pub input_overrides: HashMap<String, String>,
}

#[derive(Debug, Clone)]
pub struct RunPipelineResult {
    pub bundle_root: PathBuf,
    pub summary_report: PathBuf,
    pub final_verdict: String,
}

#[derive(Debug, Serialize)]
struct WorkflowBundleMetadata {
    kind: String,
    id: String,
    workflow_id: String,
    version: String,
    entry_mode: String,
    execution_profile: String,
    executor: String,
    prepare_only: bool,
    started_at: String,
    completed_at: String,
    summary: String,
    commands: String,
    validation: String,
    inventory: String,
    reports_dir: String,
    stage_inputs_dir: String,
    stage_logs_dir: String,
    final_verdict: String,
    resolved_inputs: BTreeMap<String, String>,
    stage_assets: BTreeMap<String, String>,
    stage_reports: BTreeMap<String, String>,
    target_root: Option<String>,
}

#[derive(Debug, Deserialize)]
struct PipelineCollectionManifest {
    #[serde(alias = "pipelines")]
    workflows: Vec<PipelineManifestEntry>,
}

#[derive(Debug, Deserialize)]
struct PipelineManifestEntry {
    id: String,
    path: String,
    execution_profile: Option<String>,
}

#[derive(Debug, Deserialize)]
struct PipelineRegistry {
    #[serde(alias = "pipelines")]
    workflows: BTreeMap<String, PipelineRegistryEntry>,
}

#[derive(Debug, Deserialize, Default, Clone)]
struct PipelineRegistryEntry {
    version: Option<String>,
}

#[derive(Debug, Deserialize)]
struct PipelineContract {
    name: String,
    description: String,
    version: String,
    #[serde(default)]
    entry_mode: String,
    #[serde(default)]
    execution_profile: String,
    #[serde(default)]
    inputs: Vec<PipelineInput>,
    #[serde(default)]
    stages: Vec<PipelineStage>,
}

#[derive(Debug, Deserialize)]
struct PipelineInput {
    name: String,
    #[serde(default)]
    required: bool,
    default: Option<serde_yaml::Value>,
}

#[derive(Debug, Deserialize)]
struct PipelineStage {
    id: String,
    asset: String,
    kind: String,
    #[serde(default)]
    mutation_scope: Vec<String>,
    authorization: StageAuthorization,
}

#[derive(Debug, Deserialize)]
struct StageAuthorization {
    action_type: String,
    #[serde(default)]
    requested_capabilities: Vec<String>,
    side_effects: StageSideEffects,
    risk_tier: String,
    scope: StageScope,
    review_requirements: StageReviewRequirements,
    #[serde(default)]
    allowed_executor_profiles: Vec<String>,
}

#[derive(Debug, Deserialize)]
struct StageSideEffects {
    #[serde(default)]
    write_repo: bool,
    #[serde(default)]
    write_evidence: bool,
    #[serde(default)]
    shell: bool,
    #[serde(default)]
    network: bool,
    #[serde(default)]
    model_invoke: bool,
    #[serde(default)]
    state_mutation: bool,
    #[serde(default)]
    publication: bool,
    #[serde(default)]
    branch_mutation: bool,
}

#[derive(Debug, Deserialize)]
struct StageScope {
    #[serde(default)]
    read: Vec<String>,
    #[serde(default)]
    write: Vec<String>,
}

#[derive(Debug, Deserialize, Default)]
struct StageReviewRequirements {
    #[serde(default)]
    human_approval: bool,
    #[serde(default)]
    quorum: bool,
    #[serde(default)]
    rollback_metadata: bool,
}

fn aggregated_workflow_side_effects(
    contract: &PipelineContract,
    prepare_only: bool,
) -> SideEffectFlags {
    if prepare_only {
        return SideEffectFlags {
            write_repo: false,
            write_evidence: true,
            shell: false,
            network: false,
            model_invoke: false,
            state_mutation: false,
            publication: false,
            branch_mutation: false,
        };
    }

    let mut aggregated = SideEffectFlags {
        write_repo: false,
        write_evidence: true,
        shell: false,
        network: false,
        model_invoke: false,
        state_mutation: false,
        publication: false,
        branch_mutation: false,
    };

    for stage in &contract.stages {
        aggregated.write_repo |= stage.authorization.side_effects.write_repo;
        aggregated.write_evidence |= stage.authorization.side_effects.write_evidence;
        aggregated.state_mutation |= stage.authorization.side_effects.state_mutation;
        aggregated.publication |= stage.authorization.side_effects.publication;
        aggregated.branch_mutation |= stage.authorization.side_effects.branch_mutation;
    }

    aggregated
}

fn aggregated_workflow_risk_tier(contract: &PipelineContract, prepare_only: bool) -> String {
    if prepare_only {
        return "low".to_string();
    }

    let mut current = 0;
    for stage in &contract.stages {
        let candidate = match stage.authorization.risk_tier.as_str() {
            "low" => 0,
            "medium" => 1,
            "high" => 2,
            "critical" => 3,
            _ => 1,
        };
        if candidate > current {
            current = candidate;
        }
    }

    match current {
        0 => "low".to_string(),
        1 => "medium".to_string(),
        2 => "high".to_string(),
        _ => "critical".to_string(),
    }
}

fn side_effects_require_repo_consequential_mode(side_effects: &StageSideEffects) -> bool {
    side_effects.write_repo
        || side_effects.state_mutation
        || side_effects.publication
        || side_effects.branch_mutation
}

fn flags_require_repo_consequential_mode(side_effects: &SideEffectFlags) -> bool {
    side_effects.write_repo
        || side_effects.state_mutation
        || side_effects.publication
        || side_effects.branch_mutation
}

#[derive(Debug, Clone)]
pub struct PipelineListEntry {
    pub id: String,
    pub path: String,
    pub version: String,
    pub execution_profile: String,
}

pub fn list_pipelines_from_octon_dir(octon_dir: &Path) -> Result<Vec<PipelineListEntry>> {
    let (manifest, registry, _) = load_pipeline_collection(octon_dir)?;
    let mut entries = Vec::new();
    for pipeline in manifest.workflows {
        let reg = registry
            .workflows
            .get(&pipeline.id)
            .cloned()
            .unwrap_or_default();
        entries.push(PipelineListEntry {
            id: pipeline.id,
            path: pipeline.path,
            version: reg.version.unwrap_or_else(|| "1.0.0".to_string()),
            execution_profile: pipeline
                .execution_profile
                .unwrap_or_else(|| "core".to_string()),
        });
    }
    entries.sort_by(|a, b| a.id.cmp(&b.id));
    Ok(entries)
}

pub fn validate_pipelines_from_octon_dir(
    octon_dir: &Path,
    pipeline_id: Option<&str>,
) -> Result<()> {
    let script = workflows_root(octon_dir)
        .join("_ops")
        .join("scripts")
        .join("validate-workflows.sh");
    let mut command = Command::new("bash");
    command.arg(script);
    if let Some(pipeline_id) = pipeline_id {
        command.arg("--workflow-id").arg(pipeline_id);
    }
    let status = command
        .current_dir(octon_dir.parent().unwrap_or(octon_dir))
        .status()
        .context("failed to run validate-workflows.sh")?;
    if !status.success() {
        bail!("workflow validation failed with status {}", status);
    }
    Ok(())
}

pub fn run_pipeline_from_octon_dir(
    octon_dir: &Path,
    options: RunPipelineOptions,
) -> Result<RunPipelineResult> {
    if options.pipeline_id == "audit-design-proposal" {
        return run_design_package_pipeline(octon_dir, options);
    }
    if options.pipeline_id == "create-design-proposal" {
        return run_create_design_package_pipeline(octon_dir, options);
    }
    if options.pipeline_id == "create-migration-proposal" {
        return run_create_static_proposal_pipeline(
            octon_dir,
            options,
            StaticProposalKind::Migration,
        );
    }
    if options.pipeline_id == "create-policy-proposal" {
        return run_create_static_proposal_pipeline(octon_dir, options, StaticProposalKind::Policy);
    }
    if options.pipeline_id == "create-architecture-proposal" {
        return run_create_static_proposal_pipeline(
            octon_dir,
            options,
            StaticProposalKind::Architecture,
        );
    }
    if options.pipeline_id == "audit-migration-proposal" {
        return run_audit_static_proposal_pipeline(
            octon_dir,
            options,
            StaticProposalKind::Migration,
        );
    }
    if options.pipeline_id == "audit-policy-proposal" {
        return run_audit_static_proposal_pipeline(octon_dir, options, StaticProposalKind::Policy);
    }
    if options.pipeline_id == "audit-architecture-proposal" {
        return run_audit_static_proposal_pipeline(
            octon_dir,
            options,
            StaticProposalKind::Architecture,
        );
    }
    if options.pipeline_id == "validate-proposal" {
        return run_validate_proposal_pipeline(octon_dir, options);
    }
    if options.pipeline_id == "promote-proposal" {
        return run_promote_proposal_pipeline(octon_dir, options);
    }
    if options.pipeline_id == "archive-proposal" {
        return run_archive_proposal_pipeline(octon_dir, options);
    }
    run_generic_pipeline(octon_dir, options)
}

fn run_design_package_pipeline(
    octon_dir: &Path,
    options: RunPipelineOptions,
) -> Result<RunPipelineResult> {
    let package_path = options
        .input_overrides
        .get("proposal_path")
        .cloned()
        .ok_or_else(|| {
            anyhow::anyhow!("workflow 'audit-design-proposal' requires --set proposal_path=<path>")
        })?;

    let mode = match options
        .input_overrides
        .get("mode")
        .map(String::as_str)
        .unwrap_or("rigorous")
    {
        "rigorous" => PipelineMode::Rigorous,
        "short" => PipelineMode::Short,
        other => bail!("unsupported audit-design-proposal mode '{other}'"),
    };

    let result = workflow::run_design_package_from_octon_dir(
        octon_dir,
        RunDesignPackageOptions {
            package_path: package_path.into(),
            mode,
            executor: options.executor,
            executor_bin: options.executor_bin,
            output_slug: options.output_slug,
            model: options.model,
            prepare_only: options.prepare_only,
        },
    )?;

    Ok(RunPipelineResult {
        bundle_root: result.bundle_root,
        summary_report: result.summary_report,
        final_verdict: result.final_verdict,
    })
}

fn run_create_design_package_pipeline(
    octon_dir: &Path,
    options: RunPipelineOptions,
) -> Result<RunPipelineResult> {
    let package_id = options
        .input_overrides
        .get("proposal_id")
        .cloned()
        .ok_or_else(|| {
            anyhow::anyhow!("workflow 'create-design-proposal' requires --set proposal_id=<value>")
        })?;
    let package_title = options
        .input_overrides
        .get("proposal_title")
        .cloned()
        .ok_or_else(|| {
            anyhow::anyhow!(
                "workflow 'create-design-proposal' requires --set proposal_title=<value>"
            )
        })?;
    let implementation_targets = options
        .input_overrides
        .get("promotion_targets")
        .cloned()
        .ok_or_else(|| {
            anyhow::anyhow!(
                "workflow 'create-design-proposal' requires --set promotion_targets=<value>"
            )
        })?;
    let promotion_scope = parse_promotion_scope(
        options
            .input_overrides
            .get("promotion_scope")
            .map(String::as_str)
            .ok_or_else(|| {
                anyhow::anyhow!(
                    "workflow 'create-design-proposal' requires --set promotion_scope=<value>"
                )
            })?,
        "create-design-proposal",
    )?;

    let package_class = match options
        .input_overrides
        .get("proposal_class")
        .map(String::as_str)
        .unwrap_or("domain-runtime")
    {
        "domain-runtime" => DesignPackageClass::DomainRuntime,
        "experience-product" => DesignPackageClass::ExperienceProduct,
        other => bail!("unsupported create-design-proposal proposal_class '{other}'"),
    };

    let result = workflow::run_create_design_package_from_octon_dir(
        octon_dir,
        RunCreateDesignPackageOptions {
            run_id: options.run_id,
            mission_id: options.mission_id,
            package_id,
            package_title,
            package_class,
            promotion_scope,
            implementation_targets: parse_csv_list(&implementation_targets),
            include_contracts: parse_optional_bool(
                options.input_overrides.get("include_contracts"),
                "include_contracts",
            )?,
            include_conformance: parse_optional_bool(
                options.input_overrides.get("include_conformance"),
                "include_conformance",
            )?,
            include_canonicalization: parse_optional_bool(
                options.input_overrides.get("include_canonicalization"),
                "include_canonicalization",
            )?,
        },
    )?;

    Ok(RunPipelineResult {
        bundle_root: result.bundle_root,
        summary_report: result.summary_report,
        final_verdict: result.final_verdict,
    })
}

fn run_create_static_proposal_pipeline(
    octon_dir: &Path,
    options: RunPipelineOptions,
    kind: StaticProposalKind,
) -> Result<RunPipelineResult> {
    let workflow_id = format!("create-{}-proposal", kind.as_str());
    let proposal_id = options
        .input_overrides
        .get("proposal_id")
        .cloned()
        .ok_or_else(|| {
            anyhow::anyhow!("workflow '{workflow_id}' requires --set proposal_id=<value>")
        })?;
    let proposal_title = options
        .input_overrides
        .get("proposal_title")
        .cloned()
        .ok_or_else(|| {
            anyhow::anyhow!("workflow '{workflow_id}' requires --set proposal_title=<value>")
        })?;
    let promotion_targets = options
        .input_overrides
        .get("promotion_targets")
        .cloned()
        .ok_or_else(|| {
            anyhow::anyhow!("workflow '{workflow_id}' requires --set promotion_targets=<value>")
        })?;
    let promotion_scope = parse_promotion_scope(
        options
            .input_overrides
            .get("promotion_scope")
            .map(String::as_str)
            .ok_or_else(|| {
                anyhow::anyhow!("workflow '{workflow_id}' requires --set promotion_scope=<value>")
            })?,
        &workflow_id,
    )?;

    let result = workflow::run_create_static_proposal_from_octon_dir(
        octon_dir,
        kind,
        RunCreateStaticProposalOptions {
            run_id: options.run_id,
            mission_id: options.mission_id,
            proposal_id,
            proposal_title,
            promotion_scope,
            promotion_targets: parse_csv_list(&promotion_targets),
        },
    )?;

    Ok(RunPipelineResult {
        bundle_root: result.bundle_root,
        summary_report: result.summary_report,
        final_verdict: result.final_verdict,
    })
}

fn run_audit_static_proposal_pipeline(
    octon_dir: &Path,
    options: RunPipelineOptions,
    kind: StaticProposalKind,
) -> Result<RunPipelineResult> {
    let workflow_id = format!("audit-{}-proposal", kind.as_str());
    let proposal_path = options
        .input_overrides
        .get("proposal_path")
        .cloned()
        .ok_or_else(|| {
            anyhow::anyhow!("workflow '{workflow_id}' requires --set proposal_path=<path>")
        })?;

    let result = workflow::run_audit_static_proposal_from_octon_dir(
        octon_dir,
        kind,
        RunAuditStaticProposalOptions {
            run_id: options.run_id,
            resume_existing: options.resume_existing,
            proposal_path: proposal_path.into(),
        },
    )?;

    Ok(RunPipelineResult {
        bundle_root: result.bundle_root,
        summary_report: result.summary_report,
        final_verdict: result.final_verdict,
    })
}

fn run_validate_proposal_pipeline(
    octon_dir: &Path,
    options: RunPipelineOptions,
) -> Result<RunPipelineResult> {
    let proposal_path = options
        .input_overrides
        .get("proposal_path")
        .cloned()
        .ok_or_else(|| {
            anyhow::anyhow!("workflow 'validate-proposal' requires --set proposal_path=<path>")
        })?;

    let result = workflow::run_validate_proposal_from_octon_dir(
        octon_dir,
        RunValidateProposalOptions {
            run_id: options.run_id,
            resume_existing: options.resume_existing,
            proposal_path: proposal_path.into(),
        },
    )?;

    Ok(RunPipelineResult {
        bundle_root: result.bundle_root,
        summary_report: result.summary_report,
        final_verdict: result.final_verdict,
    })
}

fn run_promote_proposal_pipeline(
    octon_dir: &Path,
    options: RunPipelineOptions,
) -> Result<RunPipelineResult> {
    let proposal_path = options
        .input_overrides
        .get("proposal_path")
        .cloned()
        .ok_or_else(|| {
            anyhow::anyhow!("workflow 'promote-proposal' requires --set proposal_path=<path>")
        })?;
    let promotion_evidence = options
        .input_overrides
        .get("promotion_evidence")
        .cloned()
        .ok_or_else(|| {
            anyhow::anyhow!("workflow 'promote-proposal' requires --set promotion_evidence=<csv>")
        })?;

    let result = workflow::run_promote_proposal_from_octon_dir(
        octon_dir,
        RunPromoteProposalOptions {
            run_id: options.run_id,
            resume_existing: options.resume_existing,
            proposal_path: proposal_path.into(),
            promotion_evidence: parse_csv_list(&promotion_evidence),
        },
    )?;

    Ok(RunPipelineResult {
        bundle_root: result.bundle_root,
        summary_report: result.summary_report,
        final_verdict: result.final_verdict,
    })
}

fn run_archive_proposal_pipeline(
    octon_dir: &Path,
    options: RunPipelineOptions,
) -> Result<RunPipelineResult> {
    let proposal_path = options
        .input_overrides
        .get("proposal_path")
        .cloned()
        .ok_or_else(|| {
            anyhow::anyhow!("workflow 'archive-proposal' requires --set proposal_path=<path>")
        })?;
    let disposition = options
        .input_overrides
        .get("disposition")
        .cloned()
        .ok_or_else(|| {
            anyhow::anyhow!("workflow 'archive-proposal' requires --set disposition=<value>")
        })?;
    let promotion_evidence = options
        .input_overrides
        .get("promotion_evidence")
        .cloned()
        .unwrap_or_default();

    let result = workflow::run_archive_proposal_from_octon_dir(
        octon_dir,
        RunArchiveProposalOptions {
            run_id: options.run_id,
            resume_existing: options.resume_existing,
            proposal_path: proposal_path.into(),
            disposition,
            promotion_evidence: parse_csv_list(&promotion_evidence),
        },
    )?;

    Ok(RunPipelineResult {
        bundle_root: result.bundle_root,
        summary_report: result.summary_report,
        final_verdict: result.final_verdict,
    })
}

fn run_generic_pipeline(
    octon_dir: &Path,
    options: RunPipelineOptions,
) -> Result<RunPipelineResult> {
    let (entry, _, pipeline_dir) = load_pipeline_definition(octon_dir, &options.pipeline_id)?;
    let runtime_cfg = ConfigLoader::load(octon_dir)?;
    let policy = PolicyEngine::new(runtime_cfg.clone());
    let contract: PipelineContract = serde_yaml::from_str(
        &fs::read_to_string(pipeline_dir.join("workflow.yml"))
            .with_context(|| format!("read {}", pipeline_dir.join("workflow.yml").display()))?,
    )
    .with_context(|| format!("parse {}", pipeline_dir.join("workflow.yml").display()))?;

    let repo_root = octon_dir
        .parent()
        .context("failed to resolve repository root from .octon directory")?
        .canonicalize()
        .context("failed to canonicalize repository root")?;

    let reports_root = repo_root.join(WORKFLOW_REPORTS_ROOT_REL);
    let workflow_mode = request::workflow_mode(options.mission_id.as_deref());
    let workflow_autonomy_context = options
        .mission_id
        .as_deref()
        .map(|mission_id| {
            default_autonomy_context(
                &runtime_cfg,
                mission_id,
                &entry.id,
                "workflow",
                "feedback_window",
                "continuous",
                "reversible",
            )
        })
        .transpose()?;
    let request_id = match options.run_id.as_deref() {
        Some(value) => {
            let run_id = validate_run_id(value)?;
            if !options.resume_existing {
                ensure_run_id_unused(&runtime_cfg, &run_id)?;
            }
            run_id
        }
        None => new_request_id("workflow"),
    };
    let workflow_side_effects = aggregated_workflow_side_effects(&contract, options.prepare_only);
    let (intent_ref, execution_role_ref, metadata) = if flags_require_repo_consequential_mode(&workflow_side_effects)
    {
        request::bind_repo_local_request(
            &runtime_cfg,
            BTreeMap::from([("workflow_id".to_string(), entry.id.clone())]),
        )?
    } else {
        request::bind_repo_observe_request(
            &runtime_cfg,
            BTreeMap::from([("workflow_id".to_string(), entry.id.clone())]),
        )?
    };
    let workflow_request = ExecutionRequest {
        request_id,
        caller_path: "workflow".to_string(),
        action_type: if options.prepare_only {
            "prepare_workflow".to_string()
        } else {
            "execute_workflow".to_string()
        },
        target_id: entry.id.clone(),
        requested_capabilities: vec!["workflow.execute".to_string(), "evidence.write".to_string()],
        side_effect_flags: workflow_side_effects,
        risk_tier: aggregated_workflow_risk_tier(&contract, options.prepare_only),
        workflow_mode: workflow_mode.clone(),
        locality_scope: None,
        intent_ref: Some(intent_ref),
        autonomy_context: workflow_autonomy_context.clone(),
        execution_role_ref: Some(execution_role_ref),
        parent_run_ref: None,
        review_requirements: ReviewRequirements::default(),
        scope_constraints: ScopeConstraints {
            read: vec!["workflow-contract".to_string()],
            write: vec![WORKFLOW_REPORTS_ROOT_REL.to_string()],
            executor_profile: None,
            locality_scope: None,
        },
        policy_mode_requested: None,
        environment_hint: None,
        metadata,
    };
    let workflow_grant = authorize_execution(&runtime_cfg, &policy, &workflow_request, None)?;
    fs::create_dir_all(&reports_root)?;

    let date = today_string()?;
    let started_at = auth_now_rfc3339()?;
    let slug = options
        .output_slug
        .clone()
        .unwrap_or_else(|| contract.name.clone());
    let slug = slugify(&slug);
    let bundle_root = unique_directory(&reports_root, &format!("{date}-{slug}"))?;
    let reports_dir = bundle_root.join("reports");
    let stage_inputs_dir = bundle_root.join("stage-inputs");
    let stage_logs_dir = bundle_root.join("stage-logs");
    fs::create_dir_all(&reports_dir)?;
    fs::create_dir_all(&stage_inputs_dir)?;
    fs::create_dir_all(&stage_logs_dir)?;
    let workflow_artifacts = write_execution_start(
        &bundle_root.join("workflow-execution"),
        &workflow_request,
        &workflow_grant,
    )?;

    let summary_report = bundle_root.join("summary.md");
    let commands_report = bundle_root.join("commands.md");
    let validation_report = bundle_root.join("validation.md");
    let inventory_report = bundle_root.join("inventory.md");

    let input_map = resolve_inputs(&contract, &options.input_overrides)?;
    let resolved_inputs = input_map
        .iter()
        .map(|(key, value)| (key.clone(), value.clone()))
        .collect::<BTreeMap<_, _>>();
    let target_root = input_map
        .get("package_path")
        .or_else(|| input_map.get("subsystem"))
        .or_else(|| input_map.get("docs_root"))
        .map(|value| resolve_relative_to_repo(&repo_root, value))
        .transpose()?;
    let target_root_rel = target_root.as_ref().map(|path| {
        path.strip_prefix(&repo_root)
            .unwrap_or(path)
            .display()
            .to_string()
    });

    let final_verdict = if options.prepare_only {
        "prepared-only".to_string()
    } else if options.executor == ExecutorKind::Mock {
        "mock-executed".to_string()
    } else {
        "manual-review-required".to_string()
    };

    let mut summary = format!(
        "# Workflow Run Summary\n\n- workflow_id: `{}`\n- version: `{}`\n- entry_mode: `{}`\n- description: `{}`\n- execution_profile: `{}`\n- canonical_path: `{}`\n- bundle_root: `{}`\n- prepare_only: `{}`\n- final_verdict: `{}`\n",
        entry.id,
        contract.version,
        contract.entry_mode,
        contract.description,
        entry.execution_profile.clone().unwrap_or_else(|| contract.execution_profile.clone()),
        pipeline_dir.strip_prefix(&repo_root).unwrap_or(&pipeline_dir).display(),
        bundle_root.display(),
        options.prepare_only,
        final_verdict
    );
    let mut stage_assets = BTreeMap::new();
    let mut stage_reports = BTreeMap::new();
    let mut command_log = Vec::new();

    for stage in &contract.stages {
        let asset_path = pipeline_dir.join(&stage.asset);
        let mut rendered = fs::read_to_string(&asset_path)
            .with_context(|| format!("read stage asset {}", asset_path.display()))?;
        for (key, value) in &input_map {
            rendered = rendered.replace(&format!("{{{{input:{key}}}}}"), value);
        }

        let packet_path = stage_inputs_dir.join(format!("{}-packet.md", stage.id));
        fs::write(&packet_path, &rendered)?;
        let report_path = reports_dir.join(format!("{}-report.md", stage.id));
        let log_path = stage_logs_dir.join(format!("{}-executor.log", stage.id));
        let packet_rel = packet_path
            .strip_prefix(&bundle_root)
            .unwrap_or(&packet_path)
            .display()
            .to_string();
        let report_rel = report_path
            .strip_prefix(&bundle_root)
            .unwrap_or(&report_path)
            .display()
            .to_string();
        let log_rel = log_path
            .strip_prefix(&bundle_root)
            .unwrap_or(&log_path)
            .display()
            .to_string();
        stage_assets.insert(stage.id.clone(), stage.asset.clone());
        stage_reports.insert(stage.id.clone(), report_rel.clone());

        if options.prepare_only {
            fs::write(
                &report_path,
                format!(
                    "# Planned Stage Report\n\n- stage: `{}`\n- kind: `{}`\n- asset: `{}`\n",
                    stage.id, stage.kind, stage.asset
                ),
            )?;
            fs::write(
                &log_path,
                format!(
                    "prepare-only: stage `{}` was not executed; prompt packet materialized.\n",
                    stage.id
                ),
            )?;
            command_log.push(format!(
                "- stage `{}` | kind=`{}` | asset=`{}` | prompt_packet=`{}` | report=`{}` | log=`{}` | executor=`prepare-only`",
                stage.id, stage.kind, stage.asset, packet_rel, report_rel, log_rel
            ));
            continue;
        }

        let stage_executor_profile = stage
            .authorization
            .allowed_executor_profiles
            .first()
            .cloned();
        let executor_metadata = if options.executor == ExecutorKind::Mock {
            BTreeMap::new()
        } else {
            execution_budget_metadata(
                options.executor,
                options.executor_bin.as_deref(),
                options.model.as_deref(),
                rendered.as_bytes().len(),
            )?
        };
        let stage_autonomy_context = options
            .mission_id
            .as_deref()
            .map(|mission_id| {
                default_autonomy_context(
                    &runtime_cfg,
                    mission_id,
                    &stage.id,
                    &format!("workflow-stage:{}", stage.id),
                    if stage.authorization.review_requirements.human_approval {
                        "approval_required"
                    } else if stage.authorization.side_effects.write_repo
                        || stage.authorization.side_effects.publication
                        || stage.authorization.side_effects.state_mutation
                    {
                        "feedback_window"
                    } else {
                        "notify"
                    },
                    "continuous",
                    if stage.authorization.side_effects.publication
                        || stage.authorization.side_effects.branch_mutation
                    {
                        "compensable"
                    } else {
                        "reversible"
                    },
                )
            })
            .transpose()?;
        let (intent_ref, execution_role_ref, metadata) = if side_effects_require_repo_consequential_mode(
            &stage.authorization.side_effects,
        ) {
            request::bind_repo_local_request(&runtime_cfg, executor_metadata)?
        } else {
            request::bind_repo_observe_request(&runtime_cfg, executor_metadata)?
        };
        let stage_request = ExecutionRequest {
            request_id: format!("{}-stage-{}", workflow_request.request_id, stage.id),
            caller_path: "workflow-stage".to_string(),
            action_type: stage.authorization.action_type.clone(),
            target_id: format!("{}::{}", entry.id, stage.id),
            requested_capabilities: stage.authorization.requested_capabilities.clone(),
            side_effect_flags: SideEffectFlags {
                write_repo: stage.authorization.side_effects.write_repo,
                write_evidence: stage.authorization.side_effects.write_evidence,
                shell: stage.authorization.side_effects.shell
                    && options.executor != ExecutorKind::Mock,
                network: stage.authorization.side_effects.network
                    && options.executor != ExecutorKind::Mock,
                model_invoke: stage.authorization.side_effects.model_invoke
                    && options.executor != ExecutorKind::Mock,
                state_mutation: stage.authorization.side_effects.state_mutation,
                publication: stage.authorization.side_effects.publication,
                branch_mutation: stage.authorization.side_effects.branch_mutation,
            },
            risk_tier: stage.authorization.risk_tier.clone(),
            workflow_mode: workflow_mode.clone(),
            locality_scope: None,
            intent_ref: Some(intent_ref),
            autonomy_context: stage_autonomy_context,
            execution_role_ref: Some(execution_role_ref),
            parent_run_ref: Some(workflow_request.request_id.clone()),
            review_requirements: ReviewRequirements {
                human_approval: stage.authorization.review_requirements.human_approval,
                quorum: stage.authorization.review_requirements.quorum,
                rollback_metadata: stage.authorization.review_requirements.rollback_metadata,
            },
            scope_constraints: ScopeConstraints {
                read: stage.authorization.scope.read.clone(),
                write: if stage.authorization.scope.write.is_empty() {
                    stage.mutation_scope.clone()
                } else {
                    stage.authorization.scope.write.clone()
                },
                executor_profile: stage_executor_profile.clone(),
                locality_scope: None,
            },
            policy_mode_requested: None,
            environment_hint: None,
            metadata: {
                let mut metadata = metadata;
                metadata.insert("workflow_id".to_string(), entry.id.clone());
                metadata.insert("stage_id".to_string(), stage.id.clone());
                metadata
            },
        };
        let stage_grant = authorize_execution(&runtime_cfg, &policy, &stage_request, None)?;
        let stage_artifacts = write_execution_start(
            &bundle_root.join("stages").join(&stage.id),
            &stage_request,
            &stage_grant,
        )?;
        let stage_started_at = auth_now_rfc3339()?;

        match options.executor {
            ExecutorKind::Mock => {
                if stage.kind == "mutation" {
                    let mutation_root = target_root
                        .clone()
                        .unwrap_or_else(|| bundle_root.join("mock-state"));
                    fs::create_dir_all(&mutation_root)?;
                    fs::write(
                        mutation_root.join(format!("{}-mutation.md", stage.id)),
                        format!("# Synthetic mutation for {}\n", stage.id),
                    )?;
                }
                fs::write(
                    &report_path,
                    format!(
                        "# Synthetic Stage Report\n\n- stage: `{}`\n- kind: `{}`\n",
                        stage.id, stage.kind
                    ),
                )?;
                fs::write(
                    &log_path,
                    format!(
                        "mock executor produced synthetic output for stage `{}`.\n",
                        stage.id
                    ),
                )?;
                finalize_execution(
                    &stage_artifacts,
                    &stage_request,
                    &stage_grant,
                    &stage_started_at,
                    &ExecutionOutcome {
                        status: "succeeded".to_string(),
                        started_at: stage_started_at.clone(),
                        completed_at: auth_now_rfc3339()?,
                        error: None,
                    },
                    &SideEffectSummary {
                        touched_scope: vec![report_rel.clone(), log_rel.clone()],
                        executor_profile: stage_executor_profile.clone(),
                        ..SideEffectSummary::default()
                    },
                )?;
            }
            ExecutorKind::Codex | ExecutorKind::Claude | ExecutorKind::Auto => {
                let executor_bin =
                    resolve_executor_binary(options.executor, options.executor_bin.as_deref())?;
                let profile_name = stage_executor_profile
                    .clone()
                    .unwrap_or_else(|| "read_only_analysis".to_string());
                let output = if matches!(options.executor, ExecutorKind::Claude)
                    || executor_bin.ends_with("claude")
                {
                    run_claude(
                        &repo_root,
                        &executor_bin,
                        options.model.as_deref(),
                        &rendered,
                        &profile_name,
                        &runtime_cfg,
                    )?
                } else {
                    run_codex(
                        &repo_root,
                        &executor_bin,
                        options.model.as_deref(),
                        &rendered,
                        &profile_name,
                        &runtime_cfg,
                    )?
                };
                fs::write(&log_path, &output.stderr)?;
                fs::write(&report_path, &output.stdout)?;
                finalize_execution(
                    &stage_artifacts,
                    &stage_request,
                    &stage_grant,
                    &stage_started_at,
                    &ExecutionOutcome {
                        status: "succeeded".to_string(),
                        started_at: stage_started_at.clone(),
                        completed_at: auth_now_rfc3339()?,
                        error: None,
                    },
                    &SideEffectSummary {
                        touched_scope: vec![report_rel.clone(), log_rel.clone()],
                        shell_commands: vec![executor_bin.display().to_string()],
                        executor_profile: Some(profile_name),
                        dangerous_flags_blocked: output.blocked_flags,
                        ..SideEffectSummary::default()
                    },
                )?;
            }
        }

        command_log.push(format!(
            "- stage `{}` | kind=`{}` | asset=`{}` | prompt_packet=`{}` | report=`{}` | log=`{}` | executor=`{}`",
            stage.id,
            stage.kind,
            stage.asset,
            packet_rel,
            report_rel,
            log_rel,
            options.executor.as_str()
        ));

        summary.push_str(&format!(
            "- stage `{}` -> `{}`\n",
            stage.id,
            report_path
                .strip_prefix(&repo_root)
                .unwrap_or(&report_path)
                .display()
        ));
    }

    let inventory = format!(
        "# Workflow Bundle Inventory\n\n- workflow_id: `{}`\n- version: `{}`\n- entry_mode: `{}`\n- execution_profile: `{}`\n- bundle_root: `{}`\n{}\n\n## Resolved Inputs\n\n{}\n## Stages\n\n{}\n",
        entry.id,
        contract.version,
        contract.entry_mode,
        entry.execution_profile.clone().unwrap_or_else(|| contract.execution_profile.clone()),
        bundle_root.display(),
        target_root_rel
            .as_ref()
            .map(|value| format!("- target_root: `{value}`"))
            .unwrap_or_else(|| "- target_root: `<none>`".to_string()),
        if resolved_inputs.is_empty() {
            "- None\n\n".to_string()
        } else {
            resolved_inputs
                .iter()
                .map(|(key, value)| format!("- `{key}` = `{value}`"))
                .collect::<Vec<_>>()
                .join("\n")
                + "\n\n"
        },
        contract
            .stages
            .iter()
            .map(|stage| format!(
                "- `{}` | kind=`{}` | asset=`{}` | report=`{}`",
                stage.id,
                stage.kind,
                stage.asset,
                stage_reports
                    .get(&stage.id)
                    .cloned()
                    .unwrap_or_else(|| "reports/<missing>".to_string())
            ))
            .collect::<Vec<_>>()
            .join("\n")
    );
    fs::write(&inventory_report, inventory)?;

    let commands = format!(
        "# Workflow Bundle Commands\n\n- workflow_id: `{}`\n- executor: `{}`\n- prepare_only: `{}`\n\n## Stage Packets\n\n{}\n",
        entry.id,
        options.executor.as_str(),
        options.prepare_only,
        command_log.join("\n")
    );
    fs::write(&commands_report, commands)?;

    fs::write(&summary_report, summary)?;

    let validation = format!(
        "# Workflow Bundle Validation\n\n- workflow_id: `{}`\n- final_verdict: `{}`\n- prepare_only: `{}`\n\n## Checks\n\n- [x] `reports/`, `stage-inputs/`, and `stage-logs/` were created\n- [x] `summary.md`, `commands.md`, `validation.md`, and `inventory.md` were written\n- [x] Every declared stage produced a prompt packet and report path\n- [x] Bundle metadata can resolve the internal workflow bundle files\n",
        entry.id, final_verdict, options.prepare_only
    );
    fs::write(&validation_report, validation)?;

    let metadata = WorkflowBundleMetadata {
        kind: "workflow-execution-bundle".to_string(),
        id: bundle_root
            .file_name()
            .and_then(|value| value.to_str())
            .unwrap_or("workflow-bundle")
            .to_string(),
        workflow_id: entry.id.clone(),
        version: contract.version.clone(),
        entry_mode: contract.entry_mode.clone(),
        execution_profile: entry
            .execution_profile
            .clone()
            .unwrap_or_else(|| contract.execution_profile.clone()),
        executor: options.executor.as_str().to_string(),
        prepare_only: options.prepare_only,
        started_at: started_at.clone(),
        completed_at: now_rfc3339()?,
        summary: "summary.md".to_string(),
        commands: "commands.md".to_string(),
        validation: "validation.md".to_string(),
        inventory: "inventory.md".to_string(),
        reports_dir: "reports".to_string(),
        stage_inputs_dir: "stage-inputs".to_string(),
        stage_logs_dir: "stage-logs".to_string(),
        final_verdict: final_verdict.clone(),
        resolved_inputs,
        stage_assets,
        stage_reports,
        target_root: target_root_rel,
    };
    fs::write(
        bundle_root.join("bundle.yml"),
        serde_yaml::to_string(&metadata)?,
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

    Ok(RunPipelineResult {
        bundle_root,
        summary_report,
        final_verdict,
    })
}

fn load_pipeline_collection(
    octon_dir: &Path,
) -> Result<(PipelineCollectionManifest, PipelineRegistry, PathBuf)> {
    let pipelines_root = workflows_root(octon_dir);
    let manifest: PipelineCollectionManifest = serde_yaml::from_str(
        &fs::read_to_string(pipelines_root.join("manifest.yml"))
            .with_context(|| format!("read {}", pipelines_root.join("manifest.yml").display()))?,
    )
    .with_context(|| "parse workflow manifest")?;
    let registry: PipelineRegistry = serde_yaml::from_str(
        &fs::read_to_string(pipelines_root.join("registry.yml"))
            .with_context(|| format!("read {}", pipelines_root.join("registry.yml").display()))?,
    )
    .with_context(|| "parse workflow registry")?;
    Ok((manifest, registry, pipelines_root))
}

fn load_pipeline_definition(
    octon_dir: &Path,
    pipeline_id: &str,
) -> Result<(PipelineManifestEntry, PipelineRegistryEntry, PathBuf)> {
    let (manifest, registry, pipelines_root) = load_pipeline_collection(octon_dir)?;
    let entry = manifest
        .workflows
        .into_iter()
        .find(|entry| entry.id == pipeline_id)
        .ok_or_else(|| anyhow::anyhow!("unknown workflow id '{}'", pipeline_id))?;
    let registry_entry = registry
        .workflows
        .get(pipeline_id)
        .cloned()
        .unwrap_or_default();
    let pipeline_dir = pipelines_root.join(entry.path.trim_end_matches('/'));
    Ok((entry, registry_entry, pipeline_dir))
}

fn resolve_inputs(
    contract: &PipelineContract,
    overrides: &HashMap<String, String>,
) -> Result<HashMap<String, String>> {
    let mut resolved = HashMap::new();
    for input in &contract.inputs {
        if let Some(value) = overrides.get(&input.name) {
            resolved.insert(input.name.clone(), value.clone());
            continue;
        }
        if let Some(default) = &input.default {
            let default_text = match default {
                serde_yaml::Value::String(text) => text.clone(),
                other => serde_yaml::to_string(other)?.trim().to_string(),
            };
            resolved.insert(input.name.clone(), default_text);
            continue;
        }
        if input.required {
            bail!(
                "missing required workflow input '{}'; pass it with --set {}=<value>",
                input.name,
                input.name
            );
        }
    }
    Ok(resolved)
}

fn parse_csv_list(value: &str) -> Vec<String> {
    value
        .split(',')
        .map(str::trim)
        .filter(|item| !item.is_empty())
        .map(ToOwned::to_owned)
        .collect()
}

fn parse_promotion_scope(value: &str, workflow_id: &str) -> Result<ProposalScope> {
    match value {
        "octon-internal" => Ok(ProposalScope::OctonInternal),
        "repo-local" => Ok(ProposalScope::RepoLocal),
        other => bail!(
            "unsupported {workflow_id} promotion_scope '{other}' (expected octon-internal or repo-local)"
        ),
    }
}

fn parse_optional_bool(value: Option<&String>, field: &str) -> Result<Option<bool>> {
    let Some(value) = value else {
        return Ok(None);
    };

    match value.to_ascii_lowercase().as_str() {
        "true" | "1" | "yes" => Ok(Some(true)),
        "false" | "0" | "no" => Ok(Some(false)),
        other => bail!(
            "workflow field '{}' expects a boolean value, got '{}'",
            field,
            other
        ),
    }
}

fn resolve_relative_to_repo(repo_root: &Path, raw: &str) -> Result<PathBuf> {
    let joined = if Path::new(raw).is_absolute() {
        PathBuf::from(raw)
    } else {
        repo_root.join(raw)
    };
    Ok(joined.canonicalize().unwrap_or(joined))
}

fn resolve_executor_binary(kind: ExecutorKind, override_bin: Option<&Path>) -> Result<PathBuf> {
    if let Some(path) = override_bin {
        return Ok(path.to_path_buf());
    }
    if let Some(path) = std::env::var_os("OCTON_DESIGN_PACKAGE_EXECUTOR") {
        return Ok(PathBuf::from(path));
    }
    match kind {
        ExecutorKind::Claude => find_binary("claude")
            .ok_or_else(|| anyhow::anyhow!("claude executable not found on PATH")),
        ExecutorKind::Auto | ExecutorKind::Codex => find_binary("codex")
            .or_else(|| find_binary("claude"))
            .ok_or_else(|| {
                anyhow::anyhow!("no supported executor found on PATH (tried codex, claude)")
            }),
        ExecutorKind::Mock => Ok(PathBuf::from("mock")),
    }
}

fn find_binary(name: &str) -> Option<PathBuf> {
    let path_var = std::env::var_os("PATH")?;
    for entry in std::env::split_paths(&path_var) {
        let candidate = entry.join(name);
        if candidate.is_file() {
            return Some(candidate);
        }
    }
    None
}

fn infer_executor_kind_from_binary(path: &Path) -> Result<&'static str> {
    let filename = path
        .file_name()
        .map(|value| value.to_string_lossy().to_ascii_lowercase())
        .unwrap_or_else(|| path.display().to_string().to_ascii_lowercase());

    if filename.contains("claude") {
        Ok("claude")
    } else if filename.contains("codex") {
        Ok("codex")
    } else {
        bail!(
            "unable to infer executor kind from override path '{}'; pass --executor codex or --executor claude",
            path.display()
        )
    }
}

fn execution_budget_metadata(
    executor: ExecutorKind,
    executor_bin: Option<&Path>,
    model: Option<&str>,
    prompt_bytes: usize,
) -> Result<BTreeMap<String, String>> {
    let resolved_kind = match executor {
        ExecutorKind::Claude => "claude",
        ExecutorKind::Codex => "codex",
        ExecutorKind::Mock => "mock",
        ExecutorKind::Auto => {
            let binary = resolve_executor_binary(executor, executor_bin)?;
            infer_executor_kind_from_binary(&binary)?
        }
    };

    let provider = match resolved_kind {
        "claude" => "anthropic",
        "codex" => "openai",
        _ => "unknown",
    };

    let mut metadata = BTreeMap::from([
        ("executor_kind".to_string(), resolved_kind.to_string()),
        ("budget_provider".to_string(), provider.to_string()),
        ("prompt_bytes".to_string(), prompt_bytes.to_string()),
    ]);
    if let Some(model) = model {
        metadata.insert("budget_model".to_string(), model.to_string());
    }
    Ok(metadata)
}

struct ExecOutput {
    stdout: String,
    stderr: String,
    blocked_flags: Vec<String>,
}

fn run_codex(
    repo_root: &Path,
    executor: &Path,
    model: Option<&str>,
    prompt: &str,
    profile_name: &str,
    cfg: &octon_core::config::RuntimeConfig,
) -> Result<ExecOutput> {
    let output_file =
        std::env::temp_dir().join(format!("pipeline-codex-{}.txt", std::process::id()));
    let profile = resolve_executor_profile(cfg, profile_name)?;
    let (mut command, blocked_flags) = build_executor_command(ExecutorCommandSpec {
        kind: ManagedExecutorKind::Codex,
        executor_bin: executor,
        repo_root,
        output_path: Some(&output_file),
        model,
        profile,
    })?;
    let output = run_with_stdin(&mut command, repo_root, prompt)?;
    let stdout = fs::read_to_string(&output_file).unwrap_or_default();
    let _ = fs::remove_file(output_file);
    Ok(ExecOutput {
        stdout,
        stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
        blocked_flags,
    })
}

fn run_claude(
    repo_root: &Path,
    executor: &Path,
    model: Option<&str>,
    prompt: &str,
    profile_name: &str,
    cfg: &octon_core::config::RuntimeConfig,
) -> Result<ExecOutput> {
    let profile = resolve_executor_profile(cfg, profile_name)?;
    let (mut command, blocked_flags) = build_executor_command(ExecutorCommandSpec {
        kind: ManagedExecutorKind::Claude,
        executor_bin: executor,
        repo_root,
        output_path: None,
        model,
        profile,
    })?;
    let output = run_with_stdin(&mut command, repo_root, prompt)?;
    Ok(ExecOutput {
        stdout: String::from_utf8_lossy(&output.stdout).into_owned(),
        stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
        blocked_flags,
    })
}

fn run_with_stdin(
    command: &mut Command,
    cwd: &Path,
    stdin_text: &str,
) -> Result<std::process::Output> {
    command
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .current_dir(cwd);
    let mut child = command.spawn().context("spawn executor")?;
    if let Some(stdin) = child.stdin.as_mut() {
        stdin
            .write_all(stdin_text.as_bytes())
            .context("write executor stdin")?;
    }
    let output = child.wait_with_output().context("wait for executor")?;
    if !output.status.success() {
        bail!("executor failed with status {}", output.status);
    }
    Ok(output)
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

fn new_request_id(prefix: &str) -> String {
    let millis = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|duration| duration.as_millis())
        .unwrap_or(0);
    format!("{prefix}-{millis}-{}", std::process::id())
}

fn validate_run_id(input: &str) -> Result<String> {
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

fn ensure_run_id_unused(cfg: &RuntimeConfig, request_id: &str) -> Result<()> {
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
        "pipeline".to_string()
    } else {
        trimmed.to_string()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashMap;
    use std::path::PathBuf;
    use walkdir::WalkDir;

    fn acquire_pipeline_test_lock() -> std::sync::MutexGuard<'static, ()> {
        crate::acquire_kernel_test_lock()
    }

    fn source_repo_root() -> PathBuf {
        PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("../../../../../..")
            .canonicalize()
            .expect("source repo root should resolve")
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

    fn make_temp_root(label: &str) -> PathBuf {
        let root = std::env::temp_dir().join(format!(
            "octon-pipeline-fixture-{}-{}",
            label,
            std::process::id()
        ));
        let _ = fs::remove_dir_all(&root);
        fs::create_dir_all(&root).expect("create temp root");
        root
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

    fn seed_generic_workflow_fixture(root: &Path) -> PathBuf {
        seed_policy_runtime_env();
        let octon_dir = root.join(".octon");
        let workflows_dir =
            octon_dir.join("framework/orchestration/runtime/workflows/test/sample-workflow");
        fs::create_dir_all(workflows_dir.join("stages")).expect("create workflow stages");
        fs::create_dir_all(octon_dir.join("state/evidence/validation/analysis"))
            .expect("create evidence root");
        fs::create_dir_all(octon_dir.join("instance/charter"))
            .expect("create workspace charter root");
        fs::create_dir_all(octon_dir.join("instance/governance")).expect("create governance root");
        fs::create_dir_all(octon_dir.join("framework/capabilities/governance/policy"))
            .expect("create policy root");
        fs::create_dir_all(octon_dir.join("framework/capabilities/_ops/scripts"))
            .expect("create ACP ops root");
        fs::write(
            octon_dir.join("instance/charter/workspace.yml"),
            "schema_version: \"workspace-charter-v1\"\nworkspace_charter_id: \"workspace-charter://test/sample-workflow\"\nversion: \"1.0.0\"\n",
        )
        .expect("write workspace machine charter");
        fs::write(
            octon_dir.join("octon.yml"),
            "engine:\n  runtime:\n    policy_file: framework/capabilities/governance/policy/deny-by-default.v2.yml\n",
        )
        .expect("write root manifest");
        fs::copy(
            source_repo_root()
                .join(".octon/framework/capabilities/governance/policy/deny-by-default.v2.yml"),
            octon_dir.join("framework/capabilities/governance/policy/deny-by-default.v2.yml"),
        )
        .expect("copy ACP policy");
        fs::copy(
            source_repo_root()
                .join(".octon/framework/capabilities/_ops/scripts/policy-receipt-write.sh"),
            octon_dir.join("framework/capabilities/_ops/scripts/policy-receipt-write.sh"),
        )
        .expect("copy ACP receipt writer");
        fs::copy(
            source_repo_root().join(".octon/instance/governance/support-targets.yml"),
            octon_dir.join("instance/governance/support-targets.yml"),
        )
        .expect("copy support targets");
        copy_tree(
            &source_repo_root().join(".octon/instance/governance/support-target-admissions"),
            &root.join(".octon/instance/governance/support-target-admissions"),
        );

        fs::write(
            octon_dir.join("framework/orchestration/runtime/workflows/manifest.yml"),
            r#"workflows:
  - id: "sample-workflow"
    path: "test/sample-workflow/"
    execution_profile: "core"
"#,
        )
        .expect("write manifest");
        fs::write(
            octon_dir.join("framework/orchestration/runtime/workflows/registry.yml"),
            r#"workflows:
  sample-workflow:
    version: "1.0.0"
"#,
        )
        .expect("write registry");
        fs::write(
            workflows_dir.join("workflow.yml"),
            r#"schema_version: "workflow-contract-v2"
name: "sample-workflow"
description: "Fixture workflow for workflow bundle contract tests."
version: "1.0.0"
entry_mode: "human"
execution_profile: "core"
inputs:
  - name: package_path
    type: folder
    required: false
stages:
  - id: "01"
    asset: "stages/01-analyze.md"
    kind: "analysis"
    mutation_scope: []
    authorization:
      action_type: "execute_stage"
      requested_capabilities: ["workflow.stage.execute", "evidence.write"]
      side_effects:
        write_repo: false
        write_evidence: true
        shell: false
        network: false
        model_invoke: false
        state_mutation: false
        publication: false
        branch_mutation: false
      risk_tier: "low"
      scope:
        read: ["workflow-scope"]
        write: ["workflow-evidence"]
      review_requirements:
        human_approval: false
        quorum: false
        rollback_metadata: false
      allowed_executor_profiles: ["read_only_analysis"]
  - id: "02"
    asset: "stages/02-mutate.md"
    kind: "mutation"
    mutation_scope: ["workflow-scope"]
    authorization:
      action_type: "execute_stage"
      requested_capabilities: ["workflow.stage.execute", "repo.write", "evidence.write"]
      side_effects:
        write_repo: true
        write_evidence: true
        shell: false
        network: false
        model_invoke: false
        state_mutation: false
        publication: false
        branch_mutation: false
      risk_tier: "medium"
      scope:
        read: ["workflow-scope"]
        write: ["workflow-scope"]
      review_requirements:
        human_approval: false
        quorum: false
        rollback_metadata: false
      allowed_executor_profiles: ["scoped_repo_mutation"]
"#,
        )
        .expect("write workflow contract");
        fs::create_dir_all(octon_dir.join("instance/cognition/context/shared"))
            .expect("create workspace charter directory");
        fs::create_dir_all(octon_dir.join("instance/orchestration/missions/sample-mission"))
            .expect("create mission authority fixture");
        fs::create_dir_all(octon_dir.join("instance/governance/policies"))
            .expect("create mission policy fixture");
        fs::create_dir_all(octon_dir.join("instance/governance/ownership"))
            .expect("create ownership fixture");
        fs::create_dir_all(octon_dir.join("instance/governance"))
            .expect("create governance fixture");
        fs::create_dir_all(octon_dir.join("state/control/execution/missions/sample-mission"))
            .expect("create mission control fixture");
        fs::create_dir_all(
            octon_dir.join("generated/effective/orchestration/missions/sample-mission"),
        )
        .expect("create mission effective fixture");
        fs::write(
            octon_dir.join("instance/charter/workspace.yml"),
            "schema_version: \"workspace-charter-v1\"\nworkspace_charter_id: \"workspace-charter://test/sample-workflow\"\nversion: \"1.0.0\"\n",
        )
        .expect("write workspace machine charter");
        fs::write(
            octon_dir.join("instance/orchestration/missions/registry.yml"),
            "schema_version: \"octon-mission-registry-v2\"\nactive:\n  - sample-mission\narchived: []\n",
        )
        .expect("write mission registry");
        fs::write(
            octon_dir.join("instance/orchestration/missions/sample-mission/mission.yml"),
            "schema_version: \"octon-mission-v2\"\nmission_id: \"sample-mission\"\ntitle: \"Sample Mission\"\nsummary: \"Fixture mission\"\nstatus: \"active\"\nmission_class: \"maintenance\"\nowner_ref: \"operator://fixtures\"\ncreated_at: \"2026-03-23\"\nrisk_ceiling: \"ACP-2\"\nallowed_action_classes:\n  - \"repo-maintenance\"\ndefault_safing_subset:\n  - \"observe_only\"\n  - \"stage_only\"\ndefault_schedule_hint: \"interruptible_scheduled\"\ndefault_overlap_policy: \"skip\"\nscope_ids: []\nsuccess_criteria:\n  - \"Fixture workflow completes\"\nfailure_conditions: []\n",
        )
        .expect("write mission charter");
        fs::write(
            octon_dir.join("instance/governance/policies/mission-autonomy.yml"),
            "schema_version: \"mission-autonomy-policy-v1\"\nmode_defaults: {}\nexecution_postures: {}\npreview_defaults: {}\ndigest_cadence_defaults: {}\nownership_routing: {}\noverlap_defaults: {}\nbackfill_defaults: {}\npause_on_failure: {}\nrecovery_windows: {}\nproceed_on_silence: {}\nsafe_interrupt_boundaries: {}\nautonomy_burn: {}\ncircuit_breakers: {}\nquorum: {}\nsafing_defaults: {}\n",
        )
        .expect("write mission autonomy policy");
        fs::write(
            octon_dir.join("instance/governance/ownership/registry.yml"),
            "schema_version: \"ownership-registry-v1\"\ndirective_precedence:\n  - mission_owner\noperators:\n  - operator_id: \"fixtures\"\n    display_name: \"Fixtures\"\n    contact: \"repo://fixtures\"\ndefaults:\n  operator_id: \"fixtures\"\n  support_tier: \"repo-consequential\"\nassets:\n  - asset_id: \"workflow-scope\"\n    path_globs:\n      - \"workflow-scope\"\n    owners:\n      - \"fixtures\"\nservices: []\nsubscriptions: {}\n",
        )
        .expect("write ownership registry");
        fs::copy(
            source_repo_root().join(".octon/instance/governance/support-targets.yml"),
            octon_dir.join("instance/governance/support-targets.yml"),
        )
        .expect("copy support targets");
        fs::create_dir_all(octon_dir.join("instance/capabilities/runtime/packs"))
            .expect("create runtime pack dir");
        fs::create_dir_all(octon_dir.join("framework/engine/runtime/adapters/host"))
            .expect("create host adapter dir");
        fs::create_dir_all(octon_dir.join("framework/engine/runtime/adapters/model"))
            .expect("create model adapter dir");
        fs::create_dir_all(octon_dir.join("framework/capabilities/packs/repo"))
            .expect("create repo pack dir");
        fs::create_dir_all(octon_dir.join("framework/capabilities/packs/git"))
            .expect("create git pack dir");
        fs::create_dir_all(octon_dir.join("framework/capabilities/packs/shell"))
            .expect("create shell pack dir");
        fs::create_dir_all(octon_dir.join("framework/capabilities/packs/telemetry"))
            .expect("create telemetry pack dir");
        fs::copy(
            source_repo_root().join(".octon/instance/capabilities/runtime/packs/registry.yml"),
            octon_dir.join("instance/capabilities/runtime/packs/registry.yml"),
        )
        .expect("copy runtime pack registry");
        fs::copy(
            source_repo_root().join(".octon/framework/engine/runtime/adapters/host/repo-shell.yml"),
            octon_dir.join("framework/engine/runtime/adapters/host/repo-shell.yml"),
        )
        .expect("copy repo-shell adapter");
        fs::copy(
            source_repo_root()
                .join(".octon/framework/engine/runtime/adapters/model/repo-local-governed.yml"),
            octon_dir.join("framework/engine/runtime/adapters/model/repo-local-governed.yml"),
        )
        .expect("copy repo-local-governed adapter");
        fs::copy(
            source_repo_root().join(".octon/framework/capabilities/packs/repo/manifest.yml"),
            octon_dir.join("framework/capabilities/packs/repo/manifest.yml"),
        )
        .expect("copy repo pack");
        fs::copy(
            source_repo_root().join(".octon/framework/capabilities/packs/git/manifest.yml"),
            octon_dir.join("framework/capabilities/packs/git/manifest.yml"),
        )
        .expect("copy git pack");
        fs::copy(
            source_repo_root().join(".octon/framework/capabilities/packs/shell/manifest.yml"),
            octon_dir.join("framework/capabilities/packs/shell/manifest.yml"),
        )
        .expect("copy shell pack");
        fs::copy(
            source_repo_root().join(".octon/framework/capabilities/packs/telemetry/manifest.yml"),
            octon_dir.join("framework/capabilities/packs/telemetry/manifest.yml"),
        )
        .expect("copy telemetry pack");
        fs::write(
            octon_dir.join("state/control/execution/missions/sample-mission/lease.yml"),
            "schema_version: \"mission-control-lease-v1\"\nmission_id: \"sample-mission\"\nlease_id: \"lease-sample\"\nstate: \"active\"\nissued_by: \"operator://fixtures\"\nissued_at: \"2026-03-23T00:00:00Z\"\nexpires_at: \"2099-03-30T00:00:00Z\"\ncontinuation_scope:\n  summary: \"Fixture continuation\"\n  allowed_execution_postures:\n    - \"continuous\"\n  max_concurrent_runs: 1\n  allowed_action_classes:\n    - \"repo-maintenance\"\n  default_safing_subset:\n    - \"observe_only\"\n    - \"stage_only\"\nrevocation_reason: null\nlast_reviewed_at: \"2026-03-23T00:00:00Z\"\n",
        )
        .expect("write lease");
        fs::write(
            octon_dir.join("state/control/execution/missions/sample-mission/mode-state.yml"),
            "schema_version: \"mode-state-v1\"\nmission_id: \"sample-mission\"\noversight_mode: \"feedback_window\"\nexecution_posture: \"continuous\"\nsafety_state: \"active\"\nphase: \"planning\"\nactive_run_ref: null\ncurrent_slice_ref: null\nnext_safe_interrupt_boundary_id: null\neffective_scenario_resolution_ref: null\nautonomy_burn_state: \"healthy\"\nbreaker_state: \"clear\"\nupdated_at: \"2026-03-23T00:00:00Z\"\n",
        )
        .expect("write mode state");
        fs::write(
            octon_dir.join("state/control/execution/missions/sample-mission/intent-register.yml"),
            "schema_version: \"intent-register-v1\"\nmission_id: \"sample-mission\"\nrevision: 1\ngenerated_from:\n  - \"kernel-pipeline-fixture\"\nentries:\n  - slice_ref:\n      id: \"slice-1\"\n    intent_ref:\n      id: \"intent://test/sample-workflow\"\n      version: \"1.0.0\"\n    action_class: \"git.commit\"\n    target_ref:\n      id: \"sample-workflow\"\n    rationale: \"fixture\"\n    status: \"published\"\n    predicted_acp: \"ACP-1\"\n    planned_reversibility_class: \"reversible\"\n    safe_interrupt_boundary_id: \"task-boundary\"\n    boundary_class: \"task_boundary\"\n    expected_blast_radius: \"small\"\n    expected_budget_impact: {}\n    required_authorize_updates: []\n    rollback_plan_ref: \"plan://rollback\"\n    compensation_plan_ref: null\n    finalize_policy_ref: \"policy://finalize\"\n    earliest_start_at: \"2026-03-23T00:00:00Z\"\n    feedback_deadline_at: \"2026-03-23T00:30:00Z\"\n    default_on_silence: \"feedback_window\"\n",
        )
        .expect("write intent register");
        fs::write(
            octon_dir.join("state/control/execution/missions/sample-mission/directives.yml"),
            "schema_version: \"control-directive-v1\"\nmission_id: \"sample-mission\"\nrevision: 1\ndirectives: []\n",
        )
        .expect("write directives");
        fs::write(
            octon_dir.join("state/control/execution/missions/sample-mission/schedule.yml"),
            "schema_version: \"schedule-control-v1\"\nmission_id: \"sample-mission\"\nschedule_source: \"fixture\"\ncadence_or_trigger: \"continuous\"\nnext_planned_run_at: null\nsuspended_future_runs: false\npause_active_run_requested: false\noverlap_policy: \"skip\"\nbackfill_policy: \"latest_only\"\npause_on_failure_rules:\n  enabled: true\n  triggers: []\npreview_lead: null\nfeedback_window_default: null\nquiet_hours: null\ndigest_route_override: null\nlast_schedule_mutation_ref: null\n",
        )
        .expect("write schedule");
        fs::write(
            octon_dir.join("state/control/execution/missions/sample-mission/autonomy-budget.yml"),
            "schema_version: \"autonomy-budget-v1\"\nmission_id: \"sample-mission\"\nstate: \"healthy\"\nwindow: \"PT24H\"\nthreshold_profile_ref: \"fixture\"\nlast_state_change_at: \"2026-03-23T00:00:00Z\"\napplied_mode_adjustments: []\nupdated_at: \"2026-03-23T00:00:00Z\"\ncounters: {}\n",
        )
        .expect("write autonomy budget");
        fs::write(
            octon_dir.join("state/control/execution/missions/sample-mission/circuit-breakers.yml"),
            "schema_version: \"circuit-breaker-v1\"\nmission_id: \"sample-mission\"\nstate: \"clear\"\ntrip_reasons: []\ntrip_conditions_snapshot: {}\napplied_actions: []\ntripped_at: null\nreset_requirements: []\nreset_ref: null\nupdated_at: \"2026-03-23T00:00:00Z\"\ntripped_breakers: []\n",
        )
        .expect("write circuit breakers");
        fs::write(
            octon_dir.join("state/control/execution/missions/sample-mission/subscriptions.yml"),
            "schema_version: \"subscriptions-v1\"\nmission_id: \"sample-mission\"\nowners:\n  - \"operator://fixtures\"\nwatchers: []\ndigest_recipients:\n  - \"operator://fixtures\"\nalert_recipients:\n  - \"operator://fixtures\"\nrouting_policy_ref: \".octon/instance/governance/ownership/registry.yml\"\nlast_routing_evaluation_at: \"2026-03-23T00:00:00Z\"\n",
        )
        .expect("write subscriptions");
        fs::write(
            octon_dir.join("generated/effective/orchestration/missions/sample-mission/scenario-resolution.yml"),
            "schema_version: \"scenario-resolution-v1\"\nmission_id: \"sample-mission\"\nsource_refs: {}\neffective:\n  scenario_family: \"maintenance.repo_housekeeping\"\n  mission_class: \"maintenance\"\n  effective_scenario_family: \"maintenance.repo_housekeeping\"\n  effective_action_class: \"git.commit\"\n  scenario_family_source: \"mission_class.default\"\n  boundary_source: \"action_class.default\"\n  recovery_source: \"deny_by_default_policy\"\n  tightening_overlays: []\n  oversight_mode: \"feedback_window\"\n  execution_posture: \"continuous\"\n  preview_policy: {}\n  feedback_window_required: true\n  proceed_on_silence_allowed: false\n  approval_required: false\n  safe_interrupt_boundary_class: \"task_boundary\"\n  overlap_policy: \"skip\"\n  backfill_policy: \"latest_only\"\n  pause_on_failure:\n    enabled: true\n    triggers: []\n  digest_route: \"preview_plus_closure_digest\"\n  alert_route: \"owners-first-digest\"\n  required_quorum: \"1\"\n  recovery_profile:\n    action_class: \"git.commit\"\n    primitive: \"git.revert_commit\"\n    rollback_handle_type: \"git-commit\"\n    recovery_window: \"P30D\"\n    reversibility_class: \"reversible\"\n  finalize_policy:\n    approval_required: false\n    block_finalize: false\n    break_glass_required: false\n  safing_subset:\n    - \"observe_only\"\nrationale:\n  - \"fixture\"\ngenerated_at: \"2026-03-23T00:00:00Z\"\nfresh_until: \"2099-03-30T00:00:00Z\"\n",
        )
        .expect("write scenario resolution");
        fs::write(
            workflows_dir.join("stages/01-analyze.md"),
            "# Analyze\n\nInspect the fixture.\n",
        )
        .expect("write stage 01");
        fs::write(
            workflows_dir.join("stages/02-mutate.md"),
            "# Mutate\n\nWrite a synthetic mutation.\n",
        )
        .expect("write stage 02");
        octon_dir
    }

    #[test]
    fn mock_generic_workflow_materializes_workflow_bundle_contract() {
        let _guard = acquire_pipeline_test_lock();
        let root = make_temp_root("mock");
        let octon_dir = seed_generic_workflow_fixture(&root);

        let result = run_pipeline_from_octon_dir(
            &octon_dir,
            RunPipelineOptions {
                pipeline_id: "sample-workflow".to_string(),
                run_id: None,
                mission_id: Some("sample-mission".to_string()),
                resume_existing: false,
                executor: ExecutorKind::Mock,
                executor_bin: None,
                output_slug: Some("fixture".to_string()),
                model: None,
                prepare_only: false,
                input_overrides: HashMap::new(),
            },
        )
        .expect("mock workflow run should succeed");

        let metadata =
            fs::read_to_string(result.bundle_root.join("bundle.yml")).expect("bundle metadata");
        let summary =
            fs::read_to_string(result.bundle_root.join("summary.md")).expect("bundle summary");
        let commands =
            fs::read_to_string(result.bundle_root.join("commands.md")).expect("commands log");
        let inventory =
            fs::read_to_string(result.bundle_root.join("inventory.md")).expect("inventory log");
        let workflow_request: serde_json::Value = serde_json::from_str(
            &fs::read_to_string(
                result
                    .bundle_root
                    .join("workflow-execution/execution-request.json"),
            )
            .expect("workflow request should exist"),
        )
        .expect("workflow request should parse");

        assert_eq!(result.summary_report, result.bundle_root.join("summary.md"));
        assert!(result
            .bundle_root
            .to_string_lossy()
            .contains(".octon/state/evidence/runs/workflows/"));
        assert!(metadata.contains("kind: workflow-execution-bundle"));
        assert!(metadata.contains("summary: summary.md"));
        assert!(metadata.contains("reports_dir: reports"));
        assert!(summary.contains("final_verdict: `mock-executed`"));
        assert!(commands.contains("executor=`mock`"));
        assert!(inventory.contains("stage `02`") || inventory.contains("`02` | kind=`mutation`"));
        assert_eq!(
            workflow_request["request"]["scope_constraints"]["write"][0],
            WORKFLOW_REPORTS_ROOT_REL
        );
        assert!(result.bundle_root.join("validation.md").is_file());
        assert!(result.bundle_root.join("reports/01-report.md").is_file());
        assert!(result.bundle_root.join("reports/02-report.md").is_file());
        assert!(result
            .bundle_root
            .join("stage-inputs/01-packet.md")
            .is_file());
        assert!(result
            .bundle_root
            .join("stage-logs/01-executor.log")
            .is_file());

        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn validate_run_id_accepts_canonical_value() {
        let run_id = validate_run_id("workflow-20260330-1").expect("canonical run id should pass");
        assert_eq!(run_id, "workflow-20260330-1");
    }

    #[test]
    fn validate_run_id_rejects_path_traversal() {
        let error = validate_run_id("../escape").expect_err("path traversal must fail");
        assert!(error
            .to_string()
            .contains("must not contain path separators"));
    }

    #[test]
    fn generic_workflow_rejects_invalid_run_id() {
        let _guard = acquire_pipeline_test_lock();
        let root = make_temp_root("invalid-run-id");
        let octon_dir = seed_generic_workflow_fixture(&root);

        let error = run_pipeline_from_octon_dir(
            &octon_dir,
            RunPipelineOptions {
                pipeline_id: "sample-workflow".to_string(),
                run_id: Some("../escape".to_string()),
                mission_id: None,
                resume_existing: false,
                executor: ExecutorKind::Mock,
                executor_bin: None,
                output_slug: Some("invalid-run-id".to_string()),
                model: None,
                prepare_only: false,
                input_overrides: HashMap::new(),
            },
        )
        .expect_err("invalid run id must fail before execution");

        assert!(error
            .to_string()
            .contains("must not contain path separators"));
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn generic_workflow_rejects_reused_run_id() {
        let _guard = acquire_pipeline_test_lock();
        let root = make_temp_root("reused-run-id");
        let octon_dir = seed_generic_workflow_fixture(&root);
        let runtime_cfg = ConfigLoader::load(&octon_dir).expect("runtime config should load");
        let reused_run_id = "workflow-20260330-1";

        fs::create_dir_all(runtime_cfg.run_control_root(reused_run_id))
            .expect("existing control root should be seeded");

        let error = run_pipeline_from_octon_dir(
            &octon_dir,
            RunPipelineOptions {
                pipeline_id: "sample-workflow".to_string(),
                run_id: Some(reused_run_id.to_string()),
                mission_id: None,
                resume_existing: false,
                executor: ExecutorKind::Mock,
                executor_bin: None,
                output_slug: Some("reused-run-id".to_string()),
                model: None,
                prepare_only: false,
                input_overrides: HashMap::new(),
            },
        )
        .expect_err("reused run id must fail before execution");

        assert!(error
            .to_string()
            .contains("already exists in canonical execution artifacts"));
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn generic_workflow_allows_reused_run_id_when_resuming() {
        let _guard = acquire_pipeline_test_lock();
        let root = make_temp_root("resume-run-id");
        let octon_dir = seed_generic_workflow_fixture(&root);
        let runtime_cfg = ConfigLoader::load(&octon_dir).expect("runtime config should load");
        let reused_run_id = "workflow-20260330-1";

        fs::create_dir_all(runtime_cfg.run_control_root(reused_run_id))
            .expect("existing control root should be seeded");

        let result = run_pipeline_from_octon_dir(
            &octon_dir,
            RunPipelineOptions {
                pipeline_id: "sample-workflow".to_string(),
                run_id: Some(reused_run_id.to_string()),
                mission_id: None,
                resume_existing: true,
                executor: ExecutorKind::Mock,
                executor_bin: None,
                output_slug: Some("resume-run-id".to_string()),
                model: None,
                prepare_only: true,
                input_overrides: HashMap::new(),
            },
        )
        .expect("resume_existing should allow a reused run id");

        assert_eq!(result.final_verdict, "prepared-only");
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn generic_workflow_without_mission_id_uses_role_mediated_mode() {
        let _guard = acquire_pipeline_test_lock();
        let root = make_temp_root("role-mediated");
        let octon_dir = seed_generic_workflow_fixture(&root);

        let result = run_pipeline_from_octon_dir(
            &octon_dir,
            RunPipelineOptions {
                pipeline_id: "sample-workflow".to_string(),
                run_id: None,
                mission_id: None,
                resume_existing: false,
                executor: ExecutorKind::Mock,
                executor_bin: None,
                output_slug: Some("role-mediated".to_string()),
                model: None,
                prepare_only: true,
                input_overrides: HashMap::new(),
            },
        )
        .expect("workflow without mission id should run in role-mediated mode");

        let workflow_receipt: serde_json::Value = serde_json::from_str(
            &fs::read_to_string(
                result
                    .bundle_root
                    .join("workflow-execution/execution-receipt.json"),
            )
            .expect("workflow receipt should exist"),
        )
        .expect("workflow receipt should parse");
        assert_eq!(workflow_receipt["workflow_mode"], "role-mediated");
        assert!(workflow_receipt["mission_ref"].is_null());

        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn prepare_only_generic_workflow_still_writes_bundle_contract_files() {
        let _guard = acquire_pipeline_test_lock();
        let root = make_temp_root("prepare-only");
        let octon_dir = seed_generic_workflow_fixture(&root);

        let result = run_pipeline_from_octon_dir(
            &octon_dir,
            RunPipelineOptions {
                pipeline_id: "sample-workflow".to_string(),
                run_id: None,
                mission_id: Some("sample-mission".to_string()),
                resume_existing: false,
                executor: ExecutorKind::Auto,
                executor_bin: None,
                output_slug: Some("prepare".to_string()),
                model: None,
                prepare_only: true,
                input_overrides: HashMap::new(),
            },
        )
        .expect("prepare-only workflow run should succeed");

        let metadata =
            fs::read_to_string(result.bundle_root.join("bundle.yml")).expect("bundle metadata");
        let log =
            fs::read_to_string(result.bundle_root.join("stage-logs/01-executor.log")).expect("log");

        assert_eq!(result.final_verdict, "prepared-only");
        assert!(metadata.contains("prepare_only: true"));
        assert!(metadata.contains("final_verdict: prepared-only"));
        assert!(result.bundle_root.join("summary.md").is_file());
        assert!(result.bundle_root.join("commands.md").is_file());
        assert!(result.bundle_root.join("validation.md").is_file());
        assert!(result.bundle_root.join("inventory.md").is_file());
        assert!(log.contains("prepare-only"));

        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn mock_generic_workflow_writes_execution_artifacts() {
        let _guard = acquire_pipeline_test_lock();
        let root = make_temp_root("artifact-receipts");
        let octon_dir = seed_generic_workflow_fixture(&root);

        let result = run_pipeline_from_octon_dir(
            &octon_dir,
            RunPipelineOptions {
                pipeline_id: "sample-workflow".to_string(),
                run_id: None,
                mission_id: Some("sample-mission".to_string()),
                resume_existing: false,
                executor: ExecutorKind::Mock,
                executor_bin: None,
                output_slug: Some("artifact-receipts".to_string()),
                model: None,
                prepare_only: false,
                input_overrides: HashMap::new(),
            },
        )
        .expect("mock workflow run should succeed");

        for path in [
            result
                .bundle_root
                .join("workflow-execution/execution-receipt.json"),
            result
                .bundle_root
                .join("workflow-execution/grant-bundle.json"),
            result.bundle_root.join("stages/01/execution-receipt.json"),
            result.bundle_root.join("stages/01/grant-bundle.json"),
            result.bundle_root.join("stages/02/execution-receipt.json"),
            result.bundle_root.join("stages/02/grant-bundle.json"),
        ] {
            assert!(
                path.is_file(),
                "expected execution artifact {}",
                path.display()
            );
        }

        let receipt: serde_json::Value = serde_json::from_str(
            &fs::read_to_string(result.bundle_root.join("stages/02/execution-receipt.json"))
                .expect("stage receipt should exist"),
        )
        .expect("stage receipt should parse");
        assert_eq!(receipt["schema_version"], "execution-receipt-v2");
        assert_eq!(receipt["workflow_mode"], "autonomous");
        assert!(receipt["reason_codes"]
            .as_array()
            .map(|v| !v.is_empty())
            .unwrap_or(false));

        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn auto_executor_budget_metadata_uses_filename_inference() {
        let metadata = execution_budget_metadata(
            ExecutorKind::Auto,
            Some(Path::new("/tmp/claude-wrapper")),
            Some("claude-3-5-sonnet-20241022"),
            1024,
        )
        .expect("metadata should infer claude from wrapper filename");

        assert_eq!(
            metadata.get("executor_kind").map(String::as_str),
            Some("claude")
        );
        assert_eq!(
            metadata.get("budget_provider").map(String::as_str),
            Some("anthropic")
        );
    }

    #[test]
    fn aggregated_workflow_side_effects_keep_read_only_workflows_out_of_repo_consequential_mode() {
        let contract: PipelineContract = serde_yaml::from_str(
            r#"name: "read-only"
description: "Fixture"
version: "1.0.0"
entry_mode: "human"
execution_profile: "core"
inputs: []
stages:
  - id: "inline"
    asset: "stages/01-inline.md"
    kind: "analysis"
    mutation_scope: []
    authorization:
      action_type: "execute_stage"
      requested_capabilities: ["workflow.stage.execute", "evidence.write"]
      side_effects:
        write_repo: false
        write_evidence: true
        shell: true
        network: false
        model_invoke: true
        state_mutation: false
        publication: false
        branch_mutation: false
      risk_tier: "low"
      scope:
        read: ["workflow-scope"]
        write: ["workflow-evidence"]
      review_requirements:
        human_approval: false
        quorum: false
        rollback_metadata: false
      allowed_executor_profiles: ["read_only_analysis"]
"#,
        )
        .expect("fixture contract should parse");

        let side_effects = aggregated_workflow_side_effects(&contract, false);
        assert!(!side_effects.write_repo);
        assert!(side_effects.write_evidence);
        assert!(!side_effects.shell);
        assert!(!side_effects.model_invoke);
        assert_eq!(aggregated_workflow_risk_tier(&contract, false), "low");
    }

    #[test]
    fn aggregated_workflow_side_effects_propagate_mutating_stage_requirements() {
        let contract: PipelineContract = serde_yaml::from_str(
            r#"name: "mutating"
description: "Fixture"
version: "1.0.0"
entry_mode: "human"
execution_profile: "core"
inputs: []
stages:
  - id: "inline"
    asset: "stages/01-inline.md"
    kind: "mutation"
    mutation_scope: ["workflow-scope"]
    authorization:
      action_type: "execute_stage"
      requested_capabilities: ["workflow.stage.execute", "repo.write", "evidence.write"]
      side_effects:
        write_repo: true
        write_evidence: true
        shell: true
        network: false
        model_invoke: false
        state_mutation: false
        publication: false
        branch_mutation: true
      risk_tier: "high"
      scope:
        read: ["workflow-scope"]
        write: ["workflow-scope"]
      review_requirements:
        human_approval: false
        quorum: false
        rollback_metadata: false
      allowed_executor_profiles: ["scoped_repo_mutation"]
"#,
        )
        .expect("fixture contract should parse");

        let side_effects = aggregated_workflow_side_effects(&contract, false);
        assert!(side_effects.write_repo);
        assert!(!side_effects.shell);
        assert!(side_effects.branch_mutation);
        assert_eq!(aggregated_workflow_risk_tier(&contract, false), "high");
    }
}
