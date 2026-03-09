use anyhow::{bail, Context, Result};
use serde::Deserialize;
use std::collections::{BTreeMap, HashMap};
use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use time::format_description;

use crate::workflow::{self, ExecutorKind, PipelineMode, RunDesignPackageOptions};

const PIPELINE_REPORTS_ROOT_REL: &str = ".harmony/output/reports/pipelines";

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

#[derive(Debug, Deserialize)]
struct PipelineCollectionManifest {
    pipelines: Vec<PipelineManifestEntry>,
}

#[derive(Debug, Deserialize)]
struct PipelineManifestEntry {
    id: String,
    path: String,
    execution_profile: Option<String>,
}

#[derive(Debug, Deserialize)]
struct PipelineRegistry {
    pipelines: BTreeMap<String, PipelineRegistryEntry>,
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

pub fn list_pipelines_from_harmony_dir(harmony_dir: &Path) -> Result<Vec<PipelineListEntry>> {
    let (manifest, registry, _) = load_pipeline_collection(harmony_dir)?;
    let mut entries = Vec::new();
    for pipeline in manifest.pipelines {
        let reg = registry
            .pipelines
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

pub fn validate_pipelines_from_harmony_dir(
    harmony_dir: &Path,
    pipeline_id: Option<&str>,
) -> Result<()> {
    let script = harmony_dir
        .join("orchestration")
        .join("runtime")
        .join("pipelines")
        .join("_ops")
        .join("scripts")
        .join("validate-pipelines.sh");
    let mut command = Command::new("bash");
    command.arg(script);
    if let Some(pipeline_id) = pipeline_id {
        command.arg("--pipeline-id").arg(pipeline_id);
    }
    let status = command
        .current_dir(harmony_dir.parent().unwrap_or(harmony_dir))
        .status()
        .context("failed to run validate-pipelines.sh")?;
    if !status.success() {
        bail!("pipeline validation failed with status {}", status);
    }
    Ok(())
}

pub fn run_pipeline_from_harmony_dir(
    harmony_dir: &Path,
    options: RunPipelineOptions,
) -> Result<RunPipelineResult> {
    if options.pipeline_id == "audit-design-package-workflow" {
        return run_design_package_pipeline(harmony_dir, options);
    }
    run_generic_pipeline(harmony_dir, options)
}

fn run_design_package_pipeline(
    harmony_dir: &Path,
    options: RunPipelineOptions,
) -> Result<RunPipelineResult> {
    let package_path = options
        .input_overrides
        .get("package_path")
        .cloned()
        .ok_or_else(|| {
            anyhow::anyhow!(
                "pipeline 'audit-design-package-workflow' requires --set package_path=<path>"
            )
        })?;

    let mode = match options
        .input_overrides
        .get("mode")
        .map(String::as_str)
        .unwrap_or("rigorous")
    {
        "rigorous" => PipelineMode::Rigorous,
        "short" => PipelineMode::Short,
        other => bail!("unsupported design-package pipeline mode '{other}'"),
    };

    let result = workflow::run_design_package_from_harmony_dir(
        harmony_dir,
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

fn run_generic_pipeline(
    harmony_dir: &Path,
    options: RunPipelineOptions,
) -> Result<RunPipelineResult> {
    let (entry, _, pipeline_dir) = load_pipeline_definition(harmony_dir, &options.pipeline_id)?;
    let contract: PipelineContract = serde_yaml::from_str(
        &fs::read_to_string(pipeline_dir.join("pipeline.yml"))
            .with_context(|| format!("read {}", pipeline_dir.join("pipeline.yml").display()))?,
    )
    .with_context(|| format!("parse {}", pipeline_dir.join("pipeline.yml").display()))?;

    let repo_root = harmony_dir
        .parent()
        .context("failed to resolve repository root from .harmony directory")?
        .canonicalize()
        .context("failed to canonicalize repository root")?;

    let reports_root = repo_root.join(PIPELINE_REPORTS_ROOT_REL);
    fs::create_dir_all(&reports_root)?;

    let date = today_string()?;
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

    let input_map = resolve_inputs(&contract, &options.input_overrides)?;
    let target_root = input_map
        .get("package_path")
        .or_else(|| input_map.get("subsystem"))
        .or_else(|| input_map.get("docs_root"))
        .map(|value| resolve_relative_to_repo(&repo_root, value))
        .transpose()?;

    let mut summary = format!(
        "# Pipeline Run Summary\n\n- pipeline_id: `{}`\n- version: `{}`\n- entry_mode: `{}`\n- description: `{}`\n- execution_profile: `{}`\n- canonical_path: `{}`\n- bundle_root: `{}`\n- prepare_only: `{}`\n",
        entry.id,
        contract.version,
        contract.entry_mode,
        contract.description,
        entry.execution_profile.clone().unwrap_or_else(|| contract.execution_profile.clone()),
        pipeline_dir.strip_prefix(&repo_root).unwrap_or(&pipeline_dir).display(),
        bundle_root.display(),
        options.prepare_only
    );

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

        if options.prepare_only {
            fs::write(
                &report_path,
                format!(
                    "# Planned Stage Report\n\n- stage: `{}`\n- kind: `{}`\n- asset: `{}`\n",
                    stage.id, stage.kind, stage.asset
                ),
            )?;
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
                fs::write(
                    stage_logs_dir.join(format!("{}-executor.log", stage.id)),
                    &output.stderr,
                )?;
                fs::write(&report_path, &output.stdout)?;
            }
        }

        summary.push_str(&format!(
            "- stage `{}` -> `{}`\n",
            stage.id,
            report_path
                .strip_prefix(&repo_root)
                .unwrap_or(&report_path)
                .display()
        ));
    }

    fs::write(&summary_report, summary)?;

    Ok(RunPipelineResult {
        bundle_root,
        summary_report,
        final_verdict: if options.prepare_only {
            "prepared-only".to_string()
        } else if options.executor == ExecutorKind::Mock {
            "mock-executed".to_string()
        } else {
            "manual-review-required".to_string()
        },
    })
}

fn load_pipeline_collection(
    harmony_dir: &Path,
) -> Result<(PipelineCollectionManifest, PipelineRegistry, PathBuf)> {
    let pipelines_root = harmony_dir
        .join("orchestration")
        .join("runtime")
        .join("pipelines");
    let manifest: PipelineCollectionManifest = serde_yaml::from_str(
        &fs::read_to_string(pipelines_root.join("manifest.yml"))
            .with_context(|| format!("read {}", pipelines_root.join("manifest.yml").display()))?,
    )
    .with_context(|| "parse pipeline manifest")?;
    let registry: PipelineRegistry = serde_yaml::from_str(
        &fs::read_to_string(pipelines_root.join("registry.yml"))
            .with_context(|| format!("read {}", pipelines_root.join("registry.yml").display()))?,
    )
    .with_context(|| "parse pipeline registry")?;
    Ok((manifest, registry, pipelines_root))
}

fn load_pipeline_definition(
    harmony_dir: &Path,
    pipeline_id: &str,
) -> Result<(PipelineManifestEntry, PipelineRegistryEntry, PathBuf)> {
    let (manifest, registry, pipelines_root) = load_pipeline_collection(harmony_dir)?;
    let entry = manifest
        .pipelines
        .into_iter()
        .find(|entry| entry.id == pipeline_id)
        .ok_or_else(|| anyhow::anyhow!("unknown pipeline id '{}'", pipeline_id))?;
    let registry_entry = registry
        .pipelines
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
                "missing required pipeline input '{}'; pass it with --set {}=<value>",
                input.name,
                input.name
            );
        }
    }
    Ok(resolved)
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
    if let Some(path) = std::env::var_os("HARMONY_DESIGN_PACKAGE_EXECUTOR") {
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
