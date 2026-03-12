use anyhow::{bail, Context, Result};
use clap::ValueEnum;
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

const WORKFLOW_ID: &str = "audit-design-package";
const WORKFLOW_ROOT_REL: &str =
    ".harmony/orchestration/runtime/workflows/audit/audit-design-package";
const REPORTS_ROOT_REL: &str = ".harmony/output/reports";
const WORKFLOW_REPORTS_ROOT_REL: &str = ".harmony/output/reports/workflows";
const STANDARD_DESIGN_PACKAGE_VALIDATOR_REL: &str =
    ".harmony/assurance/runtime/_ops/scripts/validate-design-package-standard.sh";
const DESIGN_PACKAGE_TEMPLATE_ROOT_REL: &str = ".harmony/scaffolding/runtime/templates";
const DESIGN_PACKAGES_ROOT_REL: &str = ".design-packages";

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
            Self::DomainRuntime => "design-package-domain-runtime",
            Self::ExperienceProduct => "design-package-experience-product",
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
        report_file: "01-design-package-audit.md",
        class: StageClass::Evaluative,
    },
    StageDefinition {
        id: "02",
        prompt_file: "03-design-package-remediation.md",
        report_file: "02-design-package-remediation.md",
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

#[derive(Clone, Debug, Default, Deserialize, Serialize)]
struct DesignPackageRegistry {
    schema_version: String,
    active: Vec<ActiveRegistryEntry>,
    archived: Vec<ArchivedRegistryEntry>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct ActiveRegistryEntry {
    id: String,
    path: String,
    title: String,
    package_class: String,
    status: String,
    implementation_targets: Vec<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
struct ArchivedRegistryEntry {
    id: String,
    path: String,
    title: String,
    package_class: String,
    status: String,
    disposition: String,
    archived_at: String,
    archived_from_status: String,
    original_path: String,
    implementation_targets: Vec<String>,
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

pub fn run_design_package_from_harmony_dir(
    harmony_dir: &Path,
    options: RunDesignPackageOptions,
) -> Result<RunDesignPackageResult> {
    let runner = Runner::new(harmony_dir, options)?;
    runner.run()
}

pub fn run_create_design_package_from_harmony_dir(
    harmony_dir: &Path,
    options: RunCreateDesignPackageOptions,
) -> Result<RunCreateDesignPackageResult> {
    let repo_root = harmony_dir
        .parent()
        .context("failed to resolve repository root from .harmony directory")?
        .canonicalize()
        .context("failed to canonicalize repository root")?;

    let design_packages_root = repo_root.join(DESIGN_PACKAGES_ROOT_REL);
    fs::create_dir_all(&design_packages_root)
        .with_context(|| format!("create {}", design_packages_root.display()))?;
    let reports_root = repo_root.join(REPORTS_ROOT_REL);
    fs::create_dir_all(&reports_root)
        .with_context(|| format!("create {}", reports_root.display()))?;
    let workflow_bundles_root = repo_root.join(WORKFLOW_REPORTS_ROOT_REL);
    fs::create_dir_all(&workflow_bundles_root)
        .with_context(|| format!("create {}", workflow_bundles_root.display()))?;

    let date = today_string()?;
    let started_at = now_rfc3339()?;
    let bundle_root = unique_directory(
        &workflow_bundles_root,
        &format!(
            "{date}-{}",
            slugify(&format!("create-design-package-{}", options.package_id))
        ),
    )?;
    fs::create_dir_all(bundle_root.join("reports"))?;
    fs::create_dir_all(bundle_root.join("stage-inputs"))?;
    fs::create_dir_all(bundle_root.join("stage-logs"))?;
    let summary_report =
        unique_file(&reports_root, &format!("{date}-create-design-package"), "md")?;

    let package_root = design_packages_root.join(&options.package_id);
    let package_rel = rel_path(&repo_root, &package_root);

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
        format!("{package_rel}/conformance/validate_scenarios.py")
    } else {
        "null".to_string()
    };

    let replacements = build_design_package_replacements(
        &options,
        &package_summary,
        &exit_expectation,
        &package_rel,
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
            "# Validate Request\n\n- package_id: `{}`\n- package_title: `{}`\n- package_class: `{}`\n- implementation_targets: `{}`\n",
            options.package_id,
            options.package_title.trim(),
            options.package_class.as_str(),
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
    } else if package_root.exists() {
        failure = Some(CreateDesignPackageFailure {
            class: CreateDesignPackageFailureClass::RequestValidation,
            failed_stage: "validate-request",
            message: format!("target design package already exists: {}", package_root.display()),
        });
    }

    write_create_stage_log(
        &bundle_root,
        "01",
        "validate-request",
        if failure.is_some() { "failed" } else { "passed" },
        &format!("- package_root: `{}`\n", package_root.display()),
    )?;
    command_log.push(format!(
        "- stage validate-request | status={} | input={} | package_root={}",
        if failure.is_some() { "failed" } else { "passed" },
        rel_path(&repo_root, &stage01_input),
        package_root.display()
    ));

    if failure.is_none() {
        let stage02_input = write_create_stage_input(
            &bundle_root,
            "02",
            "select-bundles",
            &format!(
                "# Select Bundles\n\n- package_class: `{}`\n- include_contracts: `{}`\n- include_conformance: `{}`\n- include_canonicalization: `{}`\n- selected_modules: `{}`\n",
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
                "# Scaffold Package\n\n- package_root: `{}`\n- package_rel: `{}`\n- selected_modules: `{}`\n",
                package_root.display(),
                package_rel,
                selected_modules.join(", ")
            ),
        )?;
        let scaffold_result: Result<()> = (|| {
            fs::create_dir_all(&package_root)
                .with_context(|| format!("create {}", package_root.display()))?;
            apply_template_bundle(
                &template_root.join("design-package-core"),
                &package_root,
                &replacements,
            )?;
            apply_template_bundle(
                &template_root.join(options.package_class.template_name()),
                &package_root,
                &replacements,
            )?;
            if include_contracts {
                apply_template_bundle(
                    &template_root.join("design-package-contracts"),
                    &package_root,
                    &replacements,
                )?;
            }
            if include_conformance {
                apply_template_bundle(
                    &template_root.join("design-package-conformance"),
                    &package_root,
                    &replacements,
                )?;
            }
            if include_canonicalization {
                apply_template_bundle(
                    &template_root.join("design-package-canonicalization"),
                    &package_root,
                    &replacements,
                )?;
            }
            fs::write(
                package_root.join("design-package.yml"),
                build_design_package_manifest(
                    &options,
                    &package_summary,
                    &exit_expectation,
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
                    package_root.join("design-package.yml").display()
                )
            })?;
            fs::write(
                package_root.join("navigation/source-of-truth-map.md"),
                build_source_of_truth_map(&options, &selected_modules),
            )
            .with_context(|| {
                format!(
                    "write {}",
                    package_root
                        .join("navigation/source-of-truth-map.md")
                        .display()
                )
            })?;
            fs::write(
                package_root.join("navigation/artifact-catalog.md"),
                build_artifact_catalog(&package_root, &options.package_id, &package_rel)?,
            )
            .with_context(|| {
                format!(
                    "write {}",
                    package_root
                        .join("navigation/artifact-catalog.md")
                        .display()
                )
            })?;
            upsert_design_package_registry(
                &repo_root,
                &options.package_id,
                &package_rel,
                options.package_title.trim(),
                options.package_class.as_str(),
                &options.implementation_targets,
            )?;
            registry_synced = true;
            Ok(())
        })();

        if let Err(error) = scaffold_result {
            let class = if error.to_string().contains(".design-packages/registry.yml") {
                CreateDesignPackageFailureClass::RegistryUpdate
            } else {
                CreateDesignPackageFailureClass::Scaffold
            };
            failure = Some(CreateDesignPackageFailure {
                class,
                failed_stage: "scaffold-package",
                message: error.to_string(),
            });
        }
        write_create_stage_log(
            &bundle_root,
            "03",
            "scaffold-package",
            if failure.is_some() { "failed" } else { "passed" },
            &format!(
                "- package_root: `{}`\n- registry_synced: `{}`\n",
                package_root.display(),
                registry_synced
            ),
        )?;
        command_log.push(format!(
            "- stage scaffold-package | status={} | input={} | package_root={}",
            if failure.is_some() { "failed" } else { "passed" },
            rel_path(&repo_root, &stage03_input),
            package_root.display()
        ));
    }

    write_create_inventory(&bundle_root, &package_root)?;

    if failure.is_none() {
        let stage04_input = write_create_stage_input(
            &bundle_root,
            "04",
            "validate-package",
            &format!(
                "# Validate Package\n\n- package_path: `{}`\n- validator: `bash .harmony/assurance/runtime/_ops/scripts/validate-design-package-standard.sh --package {}`\n",
                package_root.display(),
                package_rel
            ),
        )?;
        match run_standard_design_package_validator(&repo_root, &package_root, &bundle_root) {
            Ok(log_path) => {
                validator_log = Some(log_path.clone());
                write_create_stage_log(
                    &bundle_root,
                    "04",
                    "validate-package",
                    "passed",
                    &format!("- validator_log: `{}`\n", rel_path(&repo_root, &log_path)),
                )?;
                command_log.push(format!(
                    "- stage validate-package | status=passed | input={} | validator_log={}",
                    rel_path(&repo_root, &stage04_input),
                    rel_path(&repo_root, &log_path)
                ));
            }
            Err(error) => {
                failure = Some(CreateDesignPackageFailure {
                    class: CreateDesignPackageFailureClass::StandardValidator,
                    failed_stage: "validate-package",
                    message: error.to_string(),
                });
                write_create_stage_log(
                    &bundle_root,
                    "04",
                    "validate-package",
                    "failed",
                    &format!("- error: `{}`\n", error),
                )?;
                command_log.push(format!(
                    "- stage validate-package | status=failed | input={}",
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
        &package_root,
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
        &package_root,
        final_verdict,
        failure.as_ref(),
        validator_log.as_deref(),
        registry_synced,
        &notes,
    )?;

    if let Some(failure) = failure {
        bail!(
            "{} at stage {}: {}",
            failure.class.as_str(),
            failure.failed_stage,
            failure.message
        );
    }

    Ok(RunCreateDesignPackageResult {
        bundle_root,
        summary_report,
        final_verdict: final_verdict.to_string(),
    })
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
            unique_file(&reports_root, &format!("{date}-audit-design-package"), "md")?;

        let stages = match options.mode {
            PipelineMode::Rigorous => RIGOROUS_STAGES,
            PipelineMode::Short => SHORT_STAGES,
        };

        Ok(Self {
            repo_root,
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
                        "target package has no design-package.yml; standard validator skipped"
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
        if self.options.prepare_only || !self.target_package.join("design-package.yml").is_file() {
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

    fn execute_stages(
        &self,
        report_paths: &mut BTreeMap<String, String>,
        report_bodies: &mut BTreeMap<String, String>,
        stage_outcomes: &mut BTreeMap<String, StageOutcome>,
        changed_files: &mut BTreeMap<String, Vec<String>>,
        command_log: &mut Vec<String>,
    ) -> std::result::Result<(), RunFailure> {
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
            let executor_used = match self.execute_stage(stage, &prompt_markdown, &report_path, &log_path) {
                Ok(executor_used) => executor_used,
                Err(error) => {
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
        if self.target_package.join("design-package.yml").is_file() {
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
    package_rel: &str,
    selected_modules: &[&str],
    conformance_validator_path: &str,
) -> BTreeMap<String, String> {
    let mut replacements = BTreeMap::new();
    replacements.insert("PACKAGE_ID".to_string(), options.package_id.clone());
    replacements.insert(
        "PACKAGE_TITLE".to_string(),
        options.package_title.trim().to_string(),
    );
    replacements.insert("PACKAGE_SUMMARY".to_string(), package_summary.to_string());
    replacements.insert(
        "PACKAGE_CLASS".to_string(),
        options.package_class.as_str().to_string(),
    );
    replacements.insert("PACKAGE_PATH".to_string(), package_rel.to_string());
    replacements.insert(
        "SELECTED_MODULES_YAML".to_string(),
        format_yaml_list(selected_modules.iter().copied()),
    );
    replacements.insert(
        "IMPLEMENTATION_TARGETS_YAML".to_string(),
        format_yaml_list(options.implementation_targets.iter().map(String::as_str)),
    );
    replacements.insert(
        "IMPLEMENTATION_TARGETS_BULLETS".to_string(),
        format_markdown_bullets(options.implementation_targets.iter().map(String::as_str)),
    );
    replacements.insert(
        "SELECTED_MODULES_BULLETS".to_string(),
        format_markdown_bullets(selected_modules.iter().copied()),
    );
    replacements.insert("EXIT_EXPECTATION".to_string(), exit_expectation.to_string());
    replacements.insert("DEFAULT_AUDIT_MODE".to_string(), "rigorous".to_string());
    replacements.insert("PACKAGE_VALIDATOR_PATH".to_string(), "null".to_string());
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

fn build_design_package_manifest(
    options: &RunCreateDesignPackageOptions,
    package_summary: &str,
    exit_expectation: &str,
    selected_modules: &[&str],
    conformance_validator_path: Option<&str>,
) -> String {
    format!(
        "schema_version: \"design-package-v1\"\npackage_id: \"{}\"\ntitle: \"{}\"\nsummary: \"{}\"\npackage_class: \"{}\"\nselected_modules:\n{}implementation_targets:\n{}status: \"draft\"\nlifecycle:\n  temporary: true\n  exit_expectation: \"{}\"\nvalidation:\n  default_audit_mode: \"rigorous\"\n  package_validator_path: null\n  conformance_validator_path: {}\n",
        options.package_id,
        options.package_title.trim().replace('"', "\\\""),
        package_summary.replace('"', "\\\""),
        options.package_class.as_str(),
        format_yaml_list(selected_modules.iter().copied()),
        format_yaml_list(options.implementation_targets.iter().map(String::as_str)),
        exit_expectation.replace('"', "\\\""),
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
        "# Package Reading And Precedence Map\n\n## Purpose\n\nThis file defines the package-local reading order and document precedence for implementers using this temporary design package. It does not make the package a canonical repository authority.\n\n## External Authorities\n\nRepository-wide governance and durable runtime/documentation surfaces remain higher-precedence than this temporary package.\n\n## Primary Package Inputs\n\n### Core\n\n- `design-package.yml`\n- `implementation/README.md`\n- `implementation/minimal-implementation-blueprint.md`\n- `implementation/first-implementation-plan.md`\n\n### Class-Specific Normative Docs\n\n{}\n\n### Optional Modules\n\n{}\n\n## Conflict Resolution\n\n1. repository-wide governance and durable authorities\n2. `design-package.yml`\n3. class-specific normative docs\n4. optional module docs\n5. reference and history material\n",
        primary_docs, optional_docs
    )
}

fn build_artifact_catalog(
    package_root: &Path,
    package_id: &str,
    package_rel: &str,
) -> Result<String> {
    let inventory = snapshot_package(package_root)?;
    let entries = if inventory.is_empty() {
        "- no files recorded".to_string()
    } else {
        format_markdown_bullets(inventory.keys().map(String::as_str))
    };
    Ok(format!(
        "# Artifact Catalog\n\nThis catalog lists the files currently present in the package. Regenerate it whenever files are added, removed, or reorganized.\n\n## Package\n\n- `package_id`: `{}`\n- `package_path`: `{}`\n\n## Files\n\n{}\n",
        package_id, package_rel, entries
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
    let script = repo_root.join(STANDARD_DESIGN_PACKAGE_VALIDATOR_REL);
    if !script.is_file() {
        bail!(
            "missing standard design-package validator: {}",
            script.display()
        );
    }

    let package_rel = rel_path(repo_root, package_root);
    let output = Command::new("bash")
        .arg(&script)
        .arg("--package")
        .arg(&package_rel)
        .current_dir(repo_root)
        .output()
        .with_context(|| format!("run standard validator for {}", package_root.display()))?;

    let log_path = bundle_root.join("standard-validator.log");
    let mut log = String::new();
    log.push_str(&format!(
        "# Standard Design Package Validator\n\n- package: `{}`\n- status: `{}`\n\n## stdout\n\n```\n{}\n```\n\n## stderr\n\n```\n{}\n```\n",
        package_rel,
        output.status,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    ));
    fs::write(&log_path, log).with_context(|| format!("write {}", log_path.display()))?;

    if !output.status.success() {
        bail!(
            "standard design-package validator failed for {} (see {})",
            package_rel,
            log_path.display()
        );
    }

    Ok(log_path)
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
        "- workflow_id: `create-design-package`\n- package_path: `{}`\n- package_class: `{}`\n- final_verdict: `{}`\n- bundle_root: `{}`\n- summary_report: `{}`\n",
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
            "1. Fill in the package-specific normative and implementation details.\n2. Run `/audit-design-package package_path=\"{}\"` to mature the package.\n3. Promote durable outputs into the listed implementation targets before archiving the package.\n",
            rel_path(repo_root, package_root),
        ));
    } else {
        body.push_str(
            "1. Inspect `validation.md`, `commands.md`, and any stage logs in the workflow bundle.\n2. Fix the recorded failure cause.\n3. Re-run `/create-design-package` with the same request after the failure is resolved.\n",
        );
    }
    body
}

fn upsert_design_package_registry(
    repo_root: &Path,
    package_id: &str,
    package_rel: &str,
    package_title: &str,
    package_class: &str,
    implementation_targets: &[String],
) -> Result<()> {
    let registry_path = repo_root.join(".design-packages/registry.yml");
    let mut registry = if registry_path.is_file() {
        let contents = fs::read_to_string(&registry_path)
            .with_context(|| format!("read {}", registry_path.display()))?;
        serde_yaml::from_str::<DesignPackageRegistry>(&contents)
            .with_context(|| format!("parse {}", registry_path.display()))?
    } else {
        DesignPackageRegistry {
            schema_version: "design-package-registry-v1".to_string(),
            active: Vec::new(),
            archived: Vec::new(),
        }
    };

    if registry.schema_version.is_empty() {
        registry.schema_version = "design-package-registry-v1".to_string();
    }

    registry.active.retain(|entry| entry.id != package_id);
    registry.archived.retain(|entry| entry.id != package_id);
    registry.active.push(ActiveRegistryEntry {
        id: package_id.to_string(),
        path: package_rel.to_string(),
        title: package_title.to_string(),
        package_class: package_class.to_string(),
        status: "draft".to_string(),
        implementation_targets: implementation_targets.to_vec(),
    });
    registry.active.sort_by(|left, right| left.id.cmp(&right.id));

    let yaml = serde_yaml::to_string(&registry)?;
    if let Some(parent) = registry_path.parent() {
        fs::create_dir_all(parent)
            .with_context(|| format!("create {}", parent.display()))?;
    }
    fs::write(&registry_path, yaml).with_context(|| format!("write {}", registry_path.display()))
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
        body.push_str("# Scaffolded Package Inventory\n\n");
        body.push_str(&format!(
            "- package_path: `{}`\n- file_count: `{}`\n\n",
            package_root.display(),
            inventory.len()
        ));
        for path in inventory.keys() {
            body.push_str(&format!("- `{path}`\n"));
        }
        body
    } else {
        "# Scaffolded Package Inventory\n\n- package_path: `not-created`\n- file_count: `0`\n"
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
        "- [{}] scaffolded package directory exists under `.design-packages/`\n",
        if package_root.is_dir() { "x" } else { " " }
    ));
    body.push_str(&format!(
        "- [{}] `design-package.yml` is present\n",
        if package_root.join("design-package.yml").is_file() {
            "x"
        } else {
            " "
        }
    ));
    body.push_str(&format!(
        "- [{}] `registry.yml` includes the scaffolded package\n",
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
        workflow_id: "create-design-package".to_string(),
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

        let workflow_root = root.join(WORKFLOW_ROOT_REL);
        fs::create_dir_all(workflow_root.join("stages")).expect("workflow stages dir should exist");
        write_file(
            &workflow_root.join("workflow.yml"),
            "name: audit-design-package\n",
        );

        for name in [
            "02-design-audit.md",
            "03-design-package-remediation.md",
            "04-design-red-team.md",
            "05-design-hardening.md",
            "06-design-integration.md",
            "07-implementation-simulation.md",
            "08-specification-closure.md",
            "09-extract-blueprint.md",
            "10-first-implementation-plan.md",
        ] {
            let body = match name {
                "03-design-package-remediation.md" => {
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

        (harmony_dir, target_package)
    }

    fn source_repo_root() -> PathBuf {
        PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("../../../../..")
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
        let harmony_dir = root.join(".harmony");
        fs::create_dir_all(&harmony_dir).expect(".harmony dir should exist");

        let source_root = source_repo_root();
        copy_tree(
            &source_root.join(".harmony/scaffolding/runtime/templates"),
            &root.join(".harmony/scaffolding/runtime/templates"),
        );
        copy_tree(
            &source_root.join(".harmony/assurance/runtime/_ops/scripts"),
            &root.join(".harmony/assurance/runtime/_ops/scripts"),
        );

        harmony_dir
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
        assert!(result
            .bundle_root
            .to_string_lossy()
            .contains(".harmony/output/reports/workflows/"));
        assert!(result.bundle_root.join("summary.md").is_file());
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
        assert!(result
            .bundle_root
            .to_string_lossy()
            .contains(".harmony/output/reports/workflows/"));
        assert!(result.bundle_root.join("summary.md").is_file());
        assert!(result.bundle_root.join("commands.md").is_file());
        assert!(result.bundle_root.join("inventory.md").is_file());
        assert!(result.bundle_root.join("stage-inputs").is_dir());
        assert!(result.bundle_root.join("stage-logs").is_dir());
        assert!(package_delta.contains("synthetic-remediation.md"));
        assert!(stage_report.contains("CHANGE MANIFEST"));
        assert!(target_package
            .join(".harmony-mock-runner/synthetic-remediation.md")
            .is_file());
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn rigorous_mock_executor_run_materializes_rigorous_reports() {
        let root = make_temp_root("mock-rigorous");
        let (harmony_dir, target_package) = seed_pipeline_fixture(&root);

        let result = run_design_package_from_harmony_dir(
            &harmony_dir,
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
        let (harmony_dir, target_package) = seed_pipeline_fixture(&root);

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

        let error = run_design_package_from_harmony_dir(
            &harmony_dir,
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

        let bundles_root = root.join(".harmony/output/reports/workflows");
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
        let harmony_dir = seed_create_design_package_fixture(&root);

        let result = run_create_design_package_from_harmony_dir(
            &harmony_dir,
            RunCreateDesignPackageOptions {
                package_id: "runtime-package".to_string(),
                package_title: "Runtime Package".to_string(),
                package_class: DesignPackageClass::DomainRuntime,
                implementation_targets: vec![
                    ".harmony/orchestration/runtime/example.md".to_string()
                ],
                include_contracts: None,
                include_conformance: None,
                include_canonicalization: None,
            },
        )
        .expect("create-design-package should succeed");

        let package_root = root.join(".design-packages/runtime-package");
        let manifest =
            fs::read_to_string(package_root.join("design-package.yml")).expect("manifest exists");
        let summary = fs::read_to_string(&result.summary_report).expect("summary should exist");

        assert!(package_root.join("contracts/README.md").is_file());
        assert!(package_root.join("conformance/README.md").is_file());
        assert!(package_root
            .join("navigation/canonicalization-target-map.md")
            .is_file());
        assert!(manifest.contains("package_class: \"domain-runtime\""));
        assert!(manifest.contains("- \"contracts\""));
        assert!(manifest.contains("- \"conformance\""));
        assert!(manifest.contains("- \"canonicalization\""));
        assert!(summary.contains("final_verdict: `scaffolded`"));
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
            fs::read_to_string(root.join(".design-packages/registry.yml"))
                .expect("registry should exist")
                .contains("runtime-package")
        );
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn create_design_package_scaffolds_experience_product_defaults() {
        let root = make_temp_root("create-experience");
        let harmony_dir = seed_create_design_package_fixture(&root);

        let result = run_create_design_package_from_harmony_dir(
            &harmony_dir,
            RunCreateDesignPackageOptions {
                package_id: "experience-package".to_string(),
                package_title: "Experience Package".to_string(),
                package_class: DesignPackageClass::ExperienceProduct,
                implementation_targets: vec![".harmony/scaffolding/runtime/example.md".to_string()],
                include_contracts: None,
                include_conformance: None,
                include_canonicalization: None,
            },
        )
        .expect("create-design-package should succeed");

        let package_root = root.join(".design-packages/experience-package");
        let manifest =
            fs::read_to_string(package_root.join("design-package.yml")).expect("manifest exists");

        assert!(package_root
            .join("normative/experience/user-journeys.md")
            .is_file());
        assert!(package_root.join("reference/README.md").is_file());
        assert!(!package_root.join("contracts/README.md").exists());
        assert!(!package_root.join("conformance/README.md").exists());
        assert!(manifest.contains("package_class: \"experience-product\""));
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
        let harmony_dir = seed_create_design_package_fixture(&root);

        run_create_design_package_from_harmony_dir(
            &harmony_dir,
            RunCreateDesignPackageOptions {
                package_id: "duplicate-package".to_string(),
                package_title: "Duplicate Package".to_string(),
                package_class: DesignPackageClass::DomainRuntime,
                implementation_targets: vec![
                    ".harmony/orchestration/runtime/example.md".to_string()
                ],
                include_contracts: None,
                include_conformance: None,
                include_canonicalization: None,
            },
        )
        .expect("first create-design-package run should succeed");

        let error = run_create_design_package_from_harmony_dir(
            &harmony_dir,
            RunCreateDesignPackageOptions {
                package_id: "duplicate-package".to_string(),
                package_title: "Duplicate Package".to_string(),
                package_class: DesignPackageClass::DomainRuntime,
                implementation_targets: vec![
                    ".harmony/orchestration/runtime/example.md".to_string()
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

        let bundles_root = root.join(".harmony/output/reports/workflows");
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
}
