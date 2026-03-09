use anyhow::{bail, Context, Result};
use clap::ValueEnum;
use serde::Serialize;
use sha2::{Digest, Sha256};
use std::collections::{BTreeMap, BTreeSet};
use std::ffi::OsStr;
use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use time::format_description;
use walkdir::WalkDir;

const WORKFLOW_ID: &str = "audit-design-package-workflow";
const PIPELINE_ROOT_REL: &str =
    ".harmony/orchestration/runtime/pipelines/audit/audit-design-package-workflow";
const REPORTS_ROOT_REL: &str = ".harmony/output/reports";
const AUDIT_BUNDLES_REL: &str = ".harmony/output/reports/audits";

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
    fn as_str(self) -> &'static str {
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
        report_file: "01-design-package-audit.md",
        class: StageClass::Evaluative,
    },
    StageDefinition {
        id: "03",
        prompt_file: "03-remediation-track.md",
        report_file: "03-design-red-team.md",
        class: StageClass::Evaluative,
    },
    StageDefinition {
        id: "04",
        prompt_file: "03-remediation-track.md",
        report_file: "04-design-hardening.md",
        class: StageClass::FileWriting,
    },
    StageDefinition {
        id: "05",
        prompt_file: "03-remediation-track.md",
        report_file: "05-design-integration.md",
        class: StageClass::FileWriting,
    },
    StageDefinition {
        id: "06",
        prompt_file: "04-implementation-simulation.md",
        report_file: "06-implementation-simulation.md",
        class: StageClass::Evaluative,
    },
    StageDefinition {
        id: "07",
        prompt_file: "05-specification-closure.md",
        report_file: "07-specification-closure.md",
        class: StageClass::FileWriting,
    },
    StageDefinition {
        id: "08",
        prompt_file: "06-extract-blueprint.md",
        report_file: "08-minimal-implementation-architecture-blueprint.md",
        class: StageClass::Guidance,
    },
    StageDefinition {
        id: "09",
        prompt_file: "07-first-implementation-plan.md",
        report_file: "09-first-implementation-plan.md",
        class: StageClass::Guidance,
    },
];

const SHORT_STAGES: &[StageDefinition] = &[
    StageDefinition {
        id: "01",
        prompt_file: "02-design-audit.md",
        report_file: "01-design-package-audit.md",
        class: StageClass::Evaluative,
    },
    StageDefinition {
        id: "02",
        prompt_file: "03-remediation-track.md",
        report_file: "02-design-package-remediation.md",
        class: StageClass::FileWriting,
    },
    StageDefinition {
        id: "06",
        prompt_file: "04-implementation-simulation.md",
        report_file: "06-implementation-simulation.md",
        class: StageClass::Evaluative,
    },
    StageDefinition {
        id: "07",
        prompt_file: "05-specification-closure.md",
        report_file: "07-specification-closure.md",
        class: StageClass::FileWriting,
    },
    StageDefinition {
        id: "08",
        prompt_file: "06-extract-blueprint.md",
        report_file: "08-minimal-implementation-architecture-blueprint.md",
        class: StageClass::Guidance,
    },
    StageDefinition {
        id: "09",
        prompt_file: "07-first-implementation-plan.md",
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
    workflow_id: String,
    package_path: String,
    mode: String,
    executor: String,
    prepare_only: bool,
    slug: String,
    started_at: String,
    completed_at: String,
    selected_stages: Vec<String>,
    report_paths: BTreeMap<String, String>,
    changed_files: BTreeMap<String, Vec<String>>,
    plan: String,
    inventory: String,
    commands: String,
    validation: String,
    summary_report: String,
    final_verdict: String,
}

#[derive(Clone, Debug)]
struct Runner {
    repo_root: PathBuf,
    target_package: PathBuf,
    pipeline_root: PathBuf,
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

pub fn run_design_package_from_harmony_dir(
    harmony_dir: &Path,
    options: RunDesignPackageOptions,
) -> Result<RunDesignPackageResult> {
    let runner = Runner::new(harmony_dir, options)?;
    runner.run()
}

impl Runner {
    fn new(harmony_dir: &Path, options: RunDesignPackageOptions) -> Result<Self> {
        let repo_root = harmony_dir
            .parent()
            .context("failed to resolve repository root from .harmony directory")?
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

        let pipeline_root = repo_root.join(PIPELINE_ROOT_REL);
        let reports_root = repo_root.join(REPORTS_ROOT_REL);
        let audit_bundles_root = repo_root.join(AUDIT_BUNDLES_REL);
        fs::create_dir_all(&reports_root)
            .with_context(|| format!("create reports root {}", reports_root.display()))?;
        fs::create_dir_all(&audit_bundles_root).with_context(|| {
            format!("create audit bundles root {}", audit_bundles_root.display())
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

        let bundle_root = unique_directory(&audit_bundles_root, &format!("{date}-{target_slug}"))?;
        let reports_dir = bundle_root.join("reports");
        let stage_inputs_dir = bundle_root.join("stage-inputs");
        let stage_logs_dir = bundle_root.join("stage-logs");
        fs::create_dir_all(&reports_dir)?;
        fs::create_dir_all(&stage_inputs_dir)?;
        fs::create_dir_all(&stage_logs_dir)?;

        let summary_report = unique_file(
            &reports_root,
            &format!("{date}-audit-design-package-workflow"),
            "md",
        )?;

        let stages = match options.mode {
            PipelineMode::Rigorous => RIGOROUS_STAGES,
            PipelineMode::Short => SHORT_STAGES,
        };

        Ok(Self {
            repo_root,
            target_package,
            pipeline_root,
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
        self.ensure_pipeline_files()?;

        let mut validation_notes = Vec::new();
        let mut report_paths = BTreeMap::new();
        let mut report_bodies = BTreeMap::new();
        let mut stage_outcomes = BTreeMap::<String, StageOutcome>::new();
        let mut changed_files = BTreeMap::<String, Vec<String>>::new();
        let mut command_log = Vec::new();

        let package_inventory = snapshot_package(&self.target_package)?;
        self.write_inventory(&package_inventory)?;
        self.write_plan()?;

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
            Err(error) => {
                validation_notes.push(format!("stage execution failed: {error}"));
                self.write_package_delta(&stage_outcomes)?;
                self.write_commands_log(&command_log)?;
                self.write_validation("failed", &report_paths, &stage_outcomes, &validation_notes)?;
                self.write_summary("failed", &report_paths, &stage_outcomes, &validation_notes)?;
                return Err(error);
            }
        };

        self.write_package_delta(&stage_outcomes)?;
        self.write_commands_log(&command_log)?;
        self.write_validation(
            &final_verdict,
            &report_paths,
            &stage_outcomes,
            &validation_notes,
        )?;
        self.write_summary(
            &final_verdict,
            &report_paths,
            &stage_outcomes,
            &validation_notes,
        )?;
        self.write_bundle_metadata(&report_paths, &changed_files, &final_verdict)?;

        Ok(RunDesignPackageResult {
            bundle_root: self.bundle_root,
            summary_report: self.summary_report,
            final_verdict,
        })
    }

    fn ensure_pipeline_files(&self) -> Result<()> {
        let required_paths = [
            self.pipeline_root.join("pipeline.yml"),
            self.pipeline_root.join("stages"),
        ];
        for path in required_paths {
            if !path.exists() {
                bail!("required pipeline path is missing: {}", path.display());
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

    fn execute_stages(
        &self,
        report_paths: &mut BTreeMap<String, String>,
        report_bodies: &mut BTreeMap<String, String>,
        stage_outcomes: &mut BTreeMap<String, StageOutcome>,
        changed_files: &mut BTreeMap<String, Vec<String>>,
        command_log: &mut Vec<String>,
    ) -> Result<()> {
        for stage in self.stages {
            let prompt_markdown = self.render_stage_prompt(stage, report_paths, report_bodies)?;
            let prompt_packet_path = self.stage_inputs_dir.join(format!(
                "{}-{}.prompt.md",
                stage.id,
                trim_md_suffix(stage.report_file)
            ));
            fs::write(&prompt_packet_path, &prompt_markdown)
                .with_context(|| format!("write prompt packet {}", prompt_packet_path.display()))?;

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
                Some(snapshot_package(&self.target_package)?)
            } else {
                None
            };

            let report_path = self.reports_dir.join(stage.report_file);
            let log_path = self.stage_logs_dir.join(format!(
                "{}-{}.log",
                stage.id,
                trim_md_suffix(stage.report_file)
            ));
            let executor_used =
                self.execute_stage(stage, &prompt_markdown, &report_path, &log_path)?;

            let report_body = fs::read_to_string(&report_path)
                .with_context(|| format!("read stage report {}", report_path.display()))?;
            if report_body.trim().is_empty() {
                bail!("stage {} produced an empty report", stage.id);
            }

            if stage.class.is_file_writing() && !report_has_change_receipt(&report_body) {
                bail!(
                    "stage {} report does not include a change manifest or explicit zero-change receipt",
                    stage.id
                );
            }

            let mut outcome = StageOutcome::default();
            if let Some(before) = package_before {
                let after = snapshot_package(&self.target_package)?;
                outcome.changed_files = diff_snapshots(&before, &after);
                let changed = outcome
                    .changed_files
                    .iter()
                    .map(|change| format!("{}:{}", change.kind, change.path))
                    .collect::<Vec<_>>();
                changed_files.insert(stage.id.to_string(), changed);
            }

            command_log.push(format!(
                "- stage {} | executor={} | prompt_packet={} | report={} | log={}",
                stage.id,
                executor_used,
                rel_path(&self.repo_root, &prompt_packet_path),
                rel_path(&self.repo_root, &report_path),
                rel_path(&self.repo_root, &log_path)
            ));

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
    ) -> Result<String> {
        match resolve_executor(self.options.executor, self.options.executor_bin.as_deref())? {
            ResolvedExecutor::Mock => {
                self.execute_stage_mock(stage, prompt_markdown, report_path, log_path)?;
                Ok("mock".to_string())
            }
            ResolvedExecutor::Codex(executor_bin) => {
                self.execute_stage_codex(
                    stage,
                    prompt_markdown,
                    report_path,
                    log_path,
                    &executor_bin,
                )?;
                Ok("codex".to_string())
            }
            ResolvedExecutor::Claude(executor_bin) => {
                self.execute_stage_claude(
                    stage,
                    prompt_markdown,
                    report_path,
                    log_path,
                    &executor_bin,
                )?;
                Ok("claude".to_string())
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
    ) -> Result<()> {
        let mut command = Command::new(executor_bin);
        command
            .arg("exec")
            .arg("--ephemeral")
            .arg("--full-auto")
            .arg("--skip-git-repo-check")
            .arg("--cd")
            .arg(&self.repo_root)
            .arg("--output-last-message")
            .arg(report_path);

        if let Some(model) = &self.options.model {
            command.arg("--model").arg(model);
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
        )?;
        if !output.status.success() {
            bail!(
                "stage {} executor failed with status {} (see {})",
                stage.id,
                output.status,
                log_path.display()
            );
        }
        Ok(())
    }

    fn execute_stage_claude(
        &self,
        stage: &StageDefinition,
        prompt_markdown: &str,
        report_path: &Path,
        log_path: &Path,
        executor_bin: &Path,
    ) -> Result<()> {
        let mut command = Command::new(executor_bin);
        command
            .arg("-p")
            .arg("--permission-mode")
            .arg("bypassPermissions")
            .arg("--output-format")
            .arg("text");

        if let Some(model) = &self.options.model {
            command.arg("--model").arg(model);
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
        Ok(())
    }

    fn execute_stage_mock(
        &self,
        stage: &StageDefinition,
        prompt_markdown: &str,
        report_path: &Path,
        log_path: &Path,
    ) -> Result<()> {
        let mock_root = self.target_package.join(".harmony-mock-runner");
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
                            "Injected by Harmony runner from `{report_path}`. Full content is appended below."
                        ),
                    );
                    injected_sections.push(format!(
                        "### {placeholder}\n\nSource: `{report_path}`\n\n````md\n{report_body}\n````\n"
                    ));
                } else if self.options.prepare_only {
                    prompt = prompt.replace(
                        placeholder,
                        &format!(
                            "Pending output from stage `{source_stage}`. Harmony runner will inject the full report during execution."
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
        rendered.push_str("# Harmony Runner Envelope\n\n");
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
        self.pipeline_root.join("stages").join(stage.prompt_file)
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
    ) -> Result<()> {
        let mut body = String::new();
        body.push_str("# Validation\n\n");
        body.push_str(&format!(
            "- final_verdict: `{final_verdict}`\n- prepare_only: `{}`\n\n",
            self.options.prepare_only
        ));
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
        fs::write(&self.summary_report, body)
            .with_context(|| format!("write summary {}", self.summary_report.display()))
    }

    fn write_bundle_metadata(
        &self,
        report_paths: &BTreeMap<String, String>,
        changed_files: &BTreeMap<String, Vec<String>>,
        final_verdict: &str,
    ) -> Result<()> {
        let metadata = BundleMetadata {
            workflow_id: WORKFLOW_ID.to_string(),
            package_path: rel_path(&self.repo_root, &self.target_package),
            mode: self.options.mode.as_str().to_string(),
            executor: self.options.executor.as_str().to_string(),
            prepare_only: self.options.prepare_only,
            slug: self.slug.clone(),
            started_at: self.started_at.clone(),
            completed_at: now_rfc3339()?,
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
        };
        let yaml = serde_yaml::to_string(&metadata)?;
        fs::write(self.bundle_root.join("bundle.yml"), yaml).with_context(|| {
            format!(
                "write bundle metadata {}",
                self.bundle_root.join("bundle.yml").display()
            )
        })
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

    if let Some(path) = std::env::var_os("HARMONY_DESIGN_PACKAGE_EXECUTOR") {
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
    use std::time::{SystemTime, UNIX_EPOCH};

    fn make_temp_root(label: &str) -> PathBuf {
        let stamp = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("time should move forward")
            .as_nanos();
        let root = std::env::temp_dir().join(format!(
            "harmony-kernel-workflow-{label}-{}-{stamp}",
            std::process::id()
        ));
        fs::create_dir_all(&root).expect("temp root should be created");
        root
    }

    fn write_file(path: &Path, contents: &str) {
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).expect("parent directory should exist");
        }
        fs::write(path, contents).expect("file should be written");
    }

    fn seed_pipeline_fixture(root: &Path) -> (PathBuf, PathBuf) {
        let harmony_dir = root.join(".harmony");
        fs::create_dir_all(&harmony_dir).expect(".harmony dir should exist");

        let target_package = root.join(".design-packages").join("target-package");
        fs::create_dir_all(&target_package).expect("target package should exist");
        write_file(&target_package.join("README.md"), "# Target Package\n");

        let pipeline_root = root.join(PIPELINE_ROOT_REL);
        fs::create_dir_all(pipeline_root.join("stages"))
            .expect("pipeline stages dir should exist");
        write_file(&pipeline_root.join("pipeline.yml"), "name: audit-design-package-workflow\n");

        for name in [
            "02-design-audit.md",
            "03-remediation-track.md",
            "04-implementation-simulation.md",
            "05-specification-closure.md",
            "06-extract-blueprint.md",
            "07-first-implementation-plan.md",
        ] {
            let body = match name {
                "03-remediation-track.md" => {
                    "Target: <PACKAGE_PATH>\nAudit: <AUDIT_REPORT>\nCHANGE MANIFEST"
                }
                "04-implementation-simulation.md" => "Target: <PACKAGE_PATH>",
                "05-specification-closure.md" => {
                    "Target: <PACKAGE_PATH>\nSimulation: <IMPLEMENTATION_SIMULATION_REPORT>\nzero-change receipt"
                }
                "07-first-implementation-plan.md" => {
                    "Target: <PACKAGE_PATH>\nBlueprint: <BLUEPRINT_REPORT>"
                }
                _ => "Target: <PACKAGE_PATH>",
            };
            write_file(&pipeline_root.join("stages").join(name), body);
        }

        (harmony_dir, target_package)
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
        let (harmony_dir, target_package) = seed_pipeline_fixture(&root);
        let runner = Runner::new(
            &harmony_dir,
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
            "reports/01-design-package-audit.md".to_string(),
        );
        let mut report_bodies = BTreeMap::new();
        report_bodies.insert("01".to_string(), "# Audit Report\n\nbody".to_string());

        let rendered = runner
            .render_stage_prompt(stage, &report_paths, &report_bodies)
            .expect("render should succeed");

        assert!(rendered.contains("Injected by Harmony runner"));
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
        let (harmony_dir, target_package) = seed_pipeline_fixture(&root);

        let result = run_design_package_from_harmony_dir(
            &harmony_dir,
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
                .join("stage-inputs/02-02-design-package-remediation.prompt.md"),
        )
        .expect("stage 02 prompt packet should exist");

        assert!(validation.contains("prepared-only"));
        assert!(summary.contains("prepared-only"));
        assert!(prompt_packet.contains("Final Answer Requirement"));
        assert!(result.bundle_root.join("plan.md").is_file());
        assert!(result.bundle_root.join("bundle.yml").is_file());
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn mock_executor_run_materializes_reports_and_package_delta() {
        let root = make_temp_root("mock-run");
        let (harmony_dir, target_package) = seed_pipeline_fixture(&root);

        let result = run_design_package_from_harmony_dir(
            &harmony_dir,
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
                .join("reports/02-design-package-remediation.md"),
        )
        .expect("stage report should exist");

        assert_eq!(result.final_verdict, "mock-executed");
        assert!(summary.contains("mock-executed"));
        assert!(validation.contains("mock-executed"));
        assert!(package_delta.contains("synthetic-remediation.md"));
        assert!(stage_report.contains("CHANGE MANIFEST"));
        assert!(target_package
            .join(".harmony-mock-runner/synthetic-remediation.md")
            .is_file());
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
}
