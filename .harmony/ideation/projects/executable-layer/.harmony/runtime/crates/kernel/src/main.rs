mod context;
mod scaffold;
mod stdio;

use clap::{Parser, Subcommand};
use harmony_core::errors::{ErrorCode, KernelError};
use harmony_core::trace::TraceWriter;
use harmony_wasm_host::policy::GrantSet;
use std::sync::Arc;

use crate::context::KernelContext;

#[derive(Parser)]
#[command(name = "harmony", version, about = "Harmony executable runtime layer (v1)")]
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

    /// Validate services under .harmony/capabilities/services.
    Validate,

    /// Run the NDJSON stdio server.
    ServeStdio,

    /// Guest service scaffolding.
    Service {
        #[command(subcommand)]
        cmd: ServiceCmd,
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
    Build { category: String, name: String },
}

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();

    match cli.cmd {
        Command::Info => cmd_info(),
        Command::Services { cmd } => cmd_services(cmd),
        Command::Tool { service, op, json } => cmd_tool(&service, &op, json.as_deref()),
        Command::Validate => cmd_validate(),
        Command::ServeStdio => cmd_serve_stdio(),
        Command::Service { cmd } => cmd_service(cmd),
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
        Some(s) => serde_json::from_str(s)
            .map_err(|e| KernelError::new(ErrorCode::MalformedJson, format!("invalid --json: {e}")))?,
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

fn cmd_service(cmd: ServiceCmd) -> anyhow::Result<()> {
    let harmony_dir = harmony_core::root::RootResolver::resolve()?;
    match cmd {
        ServiceCmd::New { category, name } => {
            scaffold::service_new(&harmony_dir, &category, &name)?;
            println!("created service scaffold at .harmony/capabilities/services/{category}/{name}");
        }
        ServiceCmd::Build { category, name } => {
            scaffold::service_build(&harmony_dir, &category, &name)?;
            println!("built service and updated integrity: {category}/{name}");
        }
    }
    Ok(())
}
