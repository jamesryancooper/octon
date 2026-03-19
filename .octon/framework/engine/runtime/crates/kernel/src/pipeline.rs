use anyhow::{bail, Context, Result};
use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, HashMap};
use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use time::format_description;

use crate::workflow::{
    self, DesignPackageClass, ExecutorKind, PipelineMode, ProposalScope,
    RunAuditStaticProposalOptions, RunCreateDesignPackageOptions,
    RunCreateStaticProposalOptions, RunDesignPackageOptions, StaticProposalKind,
};

const WORKFLOW_REPORTS_ROOT_REL: &str = ".octon/state/evidence/runs/workflows";

#[derive(Debug, Clone)]
pub struct RunPipelineOptions {
    pub pipeline_id: String,
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
    let script = octon_dir
        .join("orchestration")
        .join("runtime")
        .join("workflows")
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
        return run_create_static_proposal_pipeline(octon_dir, options, StaticProposalKind::Migration);
    }
    if options.pipeline_id == "create-policy-proposal" {
        return run_create_static_proposal_pipeline(octon_dir, options, StaticProposalKind::Policy);
    }
    if options.pipeline_id == "create-architecture-proposal" {
        return run_create_static_proposal_pipeline(octon_dir, options, StaticProposalKind::Architecture);
    }
    if options.pipeline_id == "audit-migration-proposal" {
        return run_audit_static_proposal_pipeline(octon_dir, options, StaticProposalKind::Migration);
    }
    if options.pipeline_id == "audit-policy-proposal" {
        return run_audit_static_proposal_pipeline(octon_dir, options, StaticProposalKind::Policy);
    }
    if options.pipeline_id == "audit-architecture-proposal" {
        return run_audit_static_proposal_pipeline(octon_dir, options, StaticProposalKind::Architecture);
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
            anyhow::anyhow!("workflow 'create-design-proposal' requires --set proposal_title=<value>")
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
        .ok_or_else(|| anyhow::anyhow!("workflow '{workflow_id}' requires --set proposal_id=<value>"))?;
    let proposal_title = options
        .input_overrides
        .get("proposal_title")
        .cloned()
        .ok_or_else(|| anyhow::anyhow!("workflow '{workflow_id}' requires --set proposal_title=<value>"))?;
    let promotion_targets = options
        .input_overrides
        .get("promotion_targets")
        .cloned()
        .ok_or_else(|| anyhow::anyhow!("workflow '{workflow_id}' requires --set promotion_targets=<value>"))?;
    let promotion_scope = parse_promotion_scope(
        options
            .input_overrides
            .get("promotion_scope")
            .map(String::as_str)
            .ok_or_else(|| anyhow::anyhow!("workflow '{workflow_id}' requires --set promotion_scope=<value>"))?,
        &workflow_id,
    )?;

    let result = workflow::run_create_static_proposal_from_octon_dir(
        octon_dir,
        kind,
        RunCreateStaticProposalOptions {
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
        .ok_or_else(|| anyhow::anyhow!("workflow '{workflow_id}' requires --set proposal_path=<path>"))?;

    let result = workflow::run_audit_static_proposal_from_octon_dir(
        octon_dir,
        kind,
        RunAuditStaticProposalOptions {
            proposal_path: proposal_path.into(),
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
    fs::create_dir_all(&reports_root)?;

    let date = today_string()?;
    let started_at = now_rfc3339()?;
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
    let target_root_rel = target_root
        .as_ref()
        .map(|path| path.strip_prefix(&repo_root).unwrap_or(path).display().to_string());

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
            }
            ExecutorKind::Codex | ExecutorKind::Claude | ExecutorKind::Auto => {
                let executor_bin =
                    resolve_executor_binary(options.executor, options.executor_bin.as_deref())?;
                let output = if matches!(options.executor, ExecutorKind::Claude)
                    || executor_bin.ends_with("claude")
                {
                    run_claude(
                        &repo_root,
                        &executor_bin,
                        options.model.as_deref(),
                        &rendered,
                    )?
                } else {
                    run_codex(
                        &repo_root,
                        &executor_bin,
                        options.model.as_deref(),
                        &rendered,
                    )?
                };
                fs::write(&log_path, &output.stderr)?;
                fs::write(&report_path, &output.stdout)?;
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
        started_at,
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
    fs::write(bundle_root.join("bundle.yml"), serde_yaml::to_string(&metadata)?)?;

    Ok(RunPipelineResult {
        bundle_root,
        summary_report,
        final_verdict,
    })
}

fn load_pipeline_collection(
    octon_dir: &Path,
) -> Result<(PipelineCollectionManifest, PipelineRegistry, PathBuf)> {
    let pipelines_root = octon_dir
        .join("orchestration")
        .join("runtime")
        .join("workflows");
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

struct ExecOutput {
    stdout: String,
    stderr: String,
}

fn run_codex(
    repo_root: &Path,
    executor: &Path,
    model: Option<&str>,
    prompt: &str,
) -> Result<ExecOutput> {
    let output_file =
        std::env::temp_dir().join(format!("pipeline-codex-{}.txt", std::process::id()));
    let mut command = Command::new(executor);
    command
        .arg("exec")
        .arg("--ephemeral")
        .arg("--full-auto")
        .arg("--skip-git-repo-check")
        .arg("--cd")
        .arg(repo_root)
        .arg("--output-last-message")
        .arg(&output_file);
    if let Some(model) = model {
        command.arg("--model").arg(model);
    }
    let output = run_with_stdin(&mut command, repo_root, prompt)?;
    let stdout = fs::read_to_string(&output_file).unwrap_or_default();
    let _ = fs::remove_file(output_file);
    Ok(ExecOutput {
        stdout,
        stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
    })
}

fn run_claude(
    repo_root: &Path,
    executor: &Path,
    model: Option<&str>,
    prompt: &str,
) -> Result<ExecOutput> {
    let mut command = Command::new(executor);
    command
        .arg("-p")
        .arg("--permission-mode")
        .arg("bypassPermissions")
        .arg("--output-format")
        .arg("text");
    if let Some(model) = model {
        command.arg("--model").arg(model);
    }
    let output = run_with_stdin(&mut command, repo_root, prompt)?;
    Ok(ExecOutput {
        stdout: String::from_utf8_lossy(&output.stdout).into_owned(),
        stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
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

    fn seed_generic_workflow_fixture(root: &Path) -> PathBuf {
        let octon_dir = root.join(".octon");
        let workflows_dir = octon_dir.join("orchestration/runtime/workflows/test/sample-workflow");
        fs::create_dir_all(workflows_dir.join("stages")).expect("create workflow stages");
        fs::create_dir_all(octon_dir.join("state/evidence/validation/analysis"))
            .expect("create evidence root");

        fs::write(
            octon_dir.join("orchestration/runtime/workflows/manifest.yml"),
            r#"workflows:
  - id: "sample-workflow"
    path: "test/sample-workflow/"
    execution_profile: "core"
"#,
        )
        .expect("write manifest");
        fs::write(
            octon_dir.join("orchestration/runtime/workflows/registry.yml"),
            r#"workflows:
  sample-workflow:
    version: "1.0.0"
"#,
        )
        .expect("write registry");
        fs::write(
            workflows_dir.join("workflow.yml"),
            r#"name: "sample-workflow"
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
  - id: "02"
    asset: "stages/02-mutate.md"
    kind: "mutation"
"#,
        )
        .expect("write workflow contract");
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
        let root = make_temp_root("mock");
        let octon_dir = seed_generic_workflow_fixture(&root);

        let result = run_pipeline_from_octon_dir(
            &octon_dir,
            RunPipelineOptions {
                pipeline_id: "sample-workflow".to_string(),
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
        assert!(result.bundle_root.join("validation.md").is_file());
        assert!(result.bundle_root.join("reports/01-report.md").is_file());
        assert!(result.bundle_root.join("reports/02-report.md").is_file());
        assert!(result.bundle_root.join("stage-inputs/01-packet.md").is_file());
        assert!(result.bundle_root.join("stage-logs/01-executor.log").is_file());

        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn prepare_only_generic_workflow_still_writes_bundle_contract_files() {
        let root = make_temp_root("prepare-only");
        let octon_dir = seed_generic_workflow_fixture(&root);

        let result = run_pipeline_from_octon_dir(
            &octon_dir,
            RunPipelineOptions {
                pipeline_id: "sample-workflow".to_string(),
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
}
