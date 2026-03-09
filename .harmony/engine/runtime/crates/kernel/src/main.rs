mod context;
mod pipeline;
mod scaffold;
mod stdio;
mod workflow;

use clap::{Parser, Subcommand};
use harmony_core::errors::{ErrorCode, KernelError};
use harmony_core::tiers::validate_runtime_discovery_tiers;
use harmony_core::trace::TraceWriter;
use harmony_wasm_host::policy::GrantSet;
use std::process::Command as ProcessCommand;
use std::sync::Arc;

use crate::context::KernelContext;
use crate::pipeline::RunPipelineOptions;
use crate::workflow::{ExecutorKind, PipelineMode, RunDesignPackageOptions};

#[derive(Parser)]
#[command(
    name = "harmony",
    version,
    about = "Harmony executable runtime layer (v1)"
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

    /// Validate services under .harmony/capabilities/runtime/services.
    Validate,

    /// Run the NDJSON stdio server.
    ServeStdio,

    /// Launch Harmony Studio desktop UI.
    Studio,

    /// Guest service scaffolding.
    Service {
        #[command(subcommand)]
        cmd: ServiceCmd,
    },

    /// Workflow execution entry points.
    Workflow {
        #[command(subcommand)]
        cmd: WorkflowCmd,
    },

    /// Canonical pipeline execution entry points.
    Pipeline {
        #[command(subcommand)]
        cmd: PipelineCmd,
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
    /// Run the architecture validation pipeline against a design package.
    RunDesignPackage {
        /// Path to the target design package.
        #[arg(long = "package-path")]
        package_path: String,
        /// Pipeline mode.
        #[arg(long, value_enum, default_value_t = PipelineMode::Rigorous)]
        mode: PipelineMode,
        /// Executor used for prompt stages.
        #[arg(long, value_enum, default_value_t = ExecutorKind::Auto)]
        executor: ExecutorKind,
        /// Optional explicit executor binary path.
        #[arg(long = "executor-bin")]
        executor_bin: Option<String>,
        /// Optional output slug override for the bounded bundle.
        #[arg(long = "output-slug")]
        output_slug: Option<String>,
        /// Optional model override passed to the executor.
        #[arg(long)]
        model: Option<String>,
        /// Materialize the bundle and prompt packets without invoking the executor.
        #[arg(long = "prepare-only", default_value_t = false)]
        prepare_only: bool,
    },
}

#[derive(Subcommand)]
enum PipelineCmd {
    /// List canonical pipelines.
    List,
    /// Run a canonical pipeline.
    Run {
        /// Canonical pipeline id.
        pipeline_id: String,
        /// Input override in the form key=value. Repeatable.
        #[arg(long = "set")]
        set: Vec<String>,
        /// Executor used for stage execution.
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
    /// Validate canonical pipelines.
    Validate {
        /// Optional pipeline id to validate semantically after collection checks.
        pipeline_id: Option<String>,
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
        Command::Pipeline { cmd } => cmd_pipeline(cmd),
    }
}

fn cmd_info() -> anyhow::Result<()> {
    let ctx = KernelContext::load()?;
    println!("harmony kernel v{}", env!("CARGO_PKG_VERSION"));
    println!("repo_root: {}", ctx.cfg.repo_root.display());
    println!("harmony_dir: {}", ctx.cfg.harmony_dir.display());
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

    if let Some(report) = validate_runtime_discovery_tiers(&ctx.cfg.harmony_dir, &ctx.registry)? {
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
    let harmony_dir = harmony_core::root::RootResolver::resolve()?;
    let runtime_dir = harmony_dir.join("engine").join("runtime");
    let manifest_path = runtime_dir.join("crates").join("Cargo.toml");
    let target_dir = harmony_dir
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
        .arg("harmony_studio")
        .arg("--bin")
        .arg("harmony-studio")
        .current_dir(&harmony_dir)
        .env("CARGO_TARGET_DIR", target_dir)
        .status()?;

    if !status.success() {
        anyhow::bail!("harmony studio exited with status {}", status);
    }

    Ok(())
}

fn cmd_service(cmd: ServiceCmd) -> anyhow::Result<()> {
    let harmony_dir = harmony_core::root::RootResolver::resolve()?;
    match cmd {
        ServiceCmd::New { category, name } => {
            scaffold::service_new(&harmony_dir, &category, &name)?;
            println!(
                "created service scaffold at .harmony/capabilities/runtime/services/{category}/{name}"
            );
        }
        ServiceCmd::Build { target, name } => {
            let (category, name) = parse_category_name(&target, name.as_deref())?;
            scaffold::service_build(&harmony_dir, &category, &name)?;
            println!("built service and updated integrity: {category}/{name}");
        }
    }
    Ok(())
}

fn cmd_workflow(cmd: WorkflowCmd) -> anyhow::Result<()> {
    let harmony_dir = harmony_core::root::RootResolver::resolve()?;
    match cmd {
        WorkflowCmd::RunDesignPackage {
            package_path,
            mode,
            executor,
            executor_bin,
            output_slug,
            model,
            prepare_only,
        } => {
            let result = workflow::run_design_package_from_harmony_dir(
                &harmony_dir,
                RunDesignPackageOptions {
                    package_path: package_path.into(),
                    mode,
                    executor,
                    executor_bin: executor_bin.map(Into::into),
                    output_slug,
                    model,
                    prepare_only,
                },
            )?;
            println!("bundle_root: {}", result.bundle_root.display());
            println!("summary_report: {}", result.summary_report.display());
            println!("final_verdict: {}", result.final_verdict);
        }
    }
    Ok(())
}

fn cmd_pipeline(cmd: PipelineCmd) -> anyhow::Result<()> {
    let harmony_dir = harmony_core::root::RootResolver::resolve()?;
    match cmd {
        PipelineCmd::List => {
            for pipeline in pipeline::list_pipelines_from_harmony_dir(&harmony_dir)? {
                println!(
                    "{} @ {} ({}, {})",
                    pipeline.id, pipeline.version, pipeline.path, pipeline.execution_profile
                );
            }
        }
        PipelineCmd::Run {
            pipeline_id,
            set,
            executor,
            executor_bin,
            output_slug,
            model,
            prepare_only,
        } => {
            let input_overrides = parse_kv_overrides(&set)?;
            let result = pipeline::run_pipeline_from_harmony_dir(
                &harmony_dir,
                RunPipelineOptions {
                    pipeline_id,
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
        PipelineCmd::Validate { pipeline_id } => {
            pipeline::validate_pipelines_from_harmony_dir(&harmony_dir, pipeline_id.as_deref())?;
            if let Some(pipeline_id) = pipeline_id {
                println!("validated canonical pipeline: {pipeline_id}");
            }
        }
    }
    Ok(())
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

#[cfg(test)]
mod tests {
    use super::{Cli, Command, PipelineCmd, WorkflowCmd};
    use crate::workflow::{ExecutorKind, PipelineMode};
    use clap::{CommandFactory, Parser};

    #[test]
    fn cli_parses_studio_subcommand() {
        let cli = Cli::try_parse_from(["harmony", "studio"])
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
            help.contains("Launch Harmony Studio desktop UI"),
            "help output should include studio description"
        );
    }

    #[test]
    fn cli_parses_workflow_run_design_package_subcommand() {
        let cli = Cli::try_parse_from([
            "harmony",
            "workflow",
            "run-design-package",
            "--package-path",
            ".design-packages/orchestration-domain-design-package",
            "--mode",
            "short",
            "--prepare-only",
        ])
        .expect("workflow run-design-package should parse successfully");

        match cli.cmd {
            Command::Workflow {
                cmd:
                    WorkflowCmd::RunDesignPackage {
                        package_path,
                        mode,
                        prepare_only,
                        ..
                    },
            } => {
                assert_eq!(
                    package_path,
                    ".design-packages/orchestration-domain-design-package"
                );
                assert_eq!(mode, PipelineMode::Short);
                assert!(prepare_only);
            }
            _ => panic!("parsed command should be workflow run-design-package"),
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
            help.contains("Workflow execution entry points"),
            "help output should include workflow command description"
        );
    }

    #[test]
    fn cli_parses_pipeline_run_subcommand() {
        let cli = Cli::try_parse_from([
            "harmony",
            "pipeline",
            "run",
            "audit-design-package-workflow",
            "--set",
            "package_path=.design-packages/orchestration-domain-design-package",
            "--executor",
            "mock",
            "--prepare-only",
        ])
        .expect("pipeline run should parse successfully");

        match cli.cmd {
            Command::Pipeline {
                cmd:
                    PipelineCmd::Run {
                        pipeline_id,
                        executor,
                        prepare_only,
                        ..
                    },
            } => {
                assert_eq!(pipeline_id, "audit-design-package-workflow");
                assert_eq!(executor, ExecutorKind::Mock);
                assert!(prepare_only);
            }
            _ => panic!("parsed command should be pipeline run"),
        }
    }
}
