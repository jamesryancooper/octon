use clap::{Args, Parser, Subcommand};
use policy_engine::{
    doctor, evaluate_acp_enforce, evaluate_acp_preflight, evaluate_enforce, evaluate_grant,
    evaluate_preflight, validate_receipt, AcpDecisionKind, AcpRequest, DoctorRequest,
    EnforceRequest, GrantEvalRequest, PreflightRequest, ReceiptValidateRequest, ScopeKind,
};
use serde::Serialize;
use std::fs;
use std::path::PathBuf;

const DEFAULT_POLICY_PATH: &str = ".octon/capabilities/governance/policy/deny-by-default.v2.yml";
const DEFAULT_SCHEMA_PATH: &str =
    ".octon/capabilities/governance/policy/deny-by-default.v2.schema.json";
const DEFAULT_REASON_CODES_PATH: &str = ".octon/capabilities/governance/policy/reason-codes.md";

#[derive(Parser, Debug)]
#[command(name = "octon-policy")]
#[command(about = "Octon deny-by-default policy engine")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand, Debug)]
enum Commands {
    Preflight(PreflightArgs),
    Enforce(EnforceArgs),
    AcpPreflight(AcpArgs),
    AcpEnforce(AcpArgs),
    ReceiptValidate(ReceiptValidateArgs),
    GrantEval(GrantEvalArgs),
    Doctor(DoctorArgs),
}

#[derive(Args, Debug)]
struct AcpArgs {
    #[arg(long, default_value = DEFAULT_POLICY_PATH)]
    policy: PathBuf,

    #[arg(long)]
    request: PathBuf,
}

#[derive(Args, Debug)]
struct CommonPolicyArgs {
    #[arg(long)]
    kind: String,

    #[arg(long)]
    id: String,

    #[arg(long)]
    manifest: PathBuf,

    #[arg(long)]
    artifact: PathBuf,

    #[arg(long, default_value = DEFAULT_POLICY_PATH)]
    policy: PathBuf,

    #[arg(long)]
    exceptions: Option<PathBuf>,

    #[arg(long)]
    caller_skill_id: Option<String>,

    #[arg(long)]
    caller_skill_manifest: Option<PathBuf>,

    #[arg(long)]
    caller_skill_artifact: Option<PathBuf>,
}

#[derive(Args, Debug)]
struct PreflightArgs {
    #[command(flatten)]
    common: CommonPolicyArgs,
}

#[derive(Args, Debug)]
struct EnforceArgs {
    #[command(flatten)]
    common: CommonPolicyArgs,

    #[arg(long)]
    requested_command: Option<String>,

    #[arg(long)]
    risk_tier: Option<String>,

    #[arg(long)]
    agent_id: Option<String>,

    #[arg(long)]
    agent_ids: Option<String>,

    #[arg(long)]
    review_agent_id: Option<String>,

    #[arg(long)]
    quorum_token: Option<String>,

    #[arg(long)]
    rollback_plan_id: Option<String>,

    #[arg(long)]
    category: Option<String>,
}

#[derive(Args, Debug)]
struct GrantEvalArgs {
    #[arg(long, default_value = DEFAULT_POLICY_PATH)]
    policy: PathBuf,

    #[arg(long, default_value = "low")]
    tier: String,

    #[arg(long = "tool")]
    tools: Vec<String>,

    #[arg(long = "write-scope")]
    write_scopes: Vec<String>,

    #[arg(long)]
    ttl_seconds: Option<u64>,

    #[arg(long, default_value_t = false)]
    has_review_evidence: bool,

    #[arg(long, default_value_t = false)]
    has_quorum_evidence: bool,

    #[arg(long)]
    request_id: Option<String>,

    #[arg(long)]
    agent_id: Option<String>,

    #[arg(long)]
    plan_step_id: Option<String>,
}

#[derive(Args, Debug)]
struct DoctorArgs {
    #[arg(long, default_value = DEFAULT_POLICY_PATH)]
    policy: PathBuf,

    #[arg(long, default_value = DEFAULT_SCHEMA_PATH)]
    schema: PathBuf,

    #[arg(long, default_value = DEFAULT_REASON_CODES_PATH)]
    reason_codes: PathBuf,
}

#[derive(Args, Debug)]
struct ReceiptValidateArgs {
    #[arg(long, default_value = DEFAULT_POLICY_PATH)]
    policy: PathBuf,

    #[arg(long)]
    receipt: PathBuf,
}

#[derive(Debug, Serialize)]
struct RuntimeErrorPayload {
    allow: bool,
    mode: String,
    deny: ErrorDeny,
}

#[derive(Debug, Serialize)]
struct ErrorDeny {
    code: String,
    message: String,
    remediation_hint: String,
}

fn main() {
    let cli = Cli::parse();
    match cli.command {
        Commands::Preflight(args) => run_preflight(args),
        Commands::Enforce(args) => run_enforce(args),
        Commands::AcpPreflight(args) => run_acp_preflight(args),
        Commands::AcpEnforce(args) => run_acp_enforce(args),
        Commands::ReceiptValidate(args) => run_receipt_validate(args),
        Commands::GrantEval(args) => run_grant_eval(args),
        Commands::Doctor(args) => run_doctor(args),
    }
}

fn run_preflight(args: PreflightArgs) {
    let request = match to_preflight_request(args.common) {
        Ok(value) => value,
        Err(err) => {
            emit_runtime_error(&err.to_string());
            std::process::exit(2);
        }
    };

    match evaluate_preflight(&request) {
        Ok(decision) => {
            emit_json(&decision);
            if decision.allow {
                std::process::exit(0);
            }
            std::process::exit(13);
        }
        Err(err) => {
            emit_runtime_error(&err.to_string());
            std::process::exit(2);
        }
    }
}

fn run_enforce(args: EnforceArgs) {
    let preflight = match to_preflight_request(args.common) {
        Ok(value) => value,
        Err(err) => {
            emit_runtime_error(&err.to_string());
            std::process::exit(2);
        }
    };

    let request = EnforceRequest {
        preflight,
        requested_command: args.requested_command,
        risk_tier: env_or_string(args.risk_tier, "OCTON_RISK_TIER", "low"),
        agent_id: env_or_optional(args.agent_id, "OCTON_AGENT_ID"),
        agent_ids_csv: env_or_optional(args.agent_ids, "OCTON_AGENT_IDS"),
        review_agent_id: env_or_optional(args.review_agent_id, "OCTON_REVIEW_AGENT_ID"),
        quorum_token: env_or_optional(args.quorum_token, "OCTON_QUORUM_TOKEN"),
        rollback_plan_id: env_or_optional(args.rollback_plan_id, "OCTON_ROLLBACK_PLAN_ID"),
        category: args.category,
    };

    match evaluate_enforce(&request) {
        Ok(decision) => {
            emit_json(&decision);
            if decision.allow {
                std::process::exit(0);
            }
            std::process::exit(13);
        }
        Err(err) => {
            emit_runtime_error(&err.to_string());
            std::process::exit(2);
        }
    }
}

fn run_grant_eval(args: GrantEvalArgs) {
    let request = GrantEvalRequest {
        policy_path: args.policy,
        tier: args.tier,
        requested_tools: args.tools,
        requested_write_scopes: args.write_scopes,
        requested_ttl_seconds: args.ttl_seconds,
        has_review_evidence: args.has_review_evidence,
        has_quorum_evidence: args.has_quorum_evidence,
        request_id: args.request_id,
        agent_id: args.agent_id,
        plan_step_id: args.plan_step_id,
    };

    match evaluate_grant(&request) {
        Ok(result) => {
            emit_json(&result);
            if result.allow {
                std::process::exit(0);
            }
            std::process::exit(13);
        }
        Err(err) => {
            emit_runtime_error(&err.to_string());
            std::process::exit(2);
        }
    }
}

fn run_acp_preflight(args: AcpArgs) {
    let request = match load_acp_request(&args.request) {
        Ok(value) => value,
        Err(err) => {
            emit_runtime_error(&err.to_string());
            std::process::exit(2);
        }
    };

    match evaluate_acp_preflight(&args.policy, &request) {
        Ok(decision) => {
            emit_json(&decision);
            if matches!(
                decision.decision,
                AcpDecisionKind::Allow | AcpDecisionKind::StageOnly
            ) {
                std::process::exit(0);
            }
            std::process::exit(13);
        }
        Err(err) => {
            emit_runtime_error(&err.to_string());
            std::process::exit(2);
        }
    }
}

fn run_acp_enforce(args: AcpArgs) {
    let request = match load_acp_request(&args.request) {
        Ok(value) => value,
        Err(err) => {
            emit_runtime_error(&err.to_string());
            std::process::exit(2);
        }
    };

    match evaluate_acp_enforce(&args.policy, &request) {
        Ok(decision) => {
            emit_json(&decision);
            if matches!(decision.decision, AcpDecisionKind::Allow) {
                std::process::exit(0);
            }
            std::process::exit(13);
        }
        Err(err) => {
            emit_runtime_error(&err.to_string());
            std::process::exit(2);
        }
    }
}

fn run_doctor(args: DoctorArgs) {
    let request = DoctorRequest {
        policy_path: args.policy,
        schema_path: args.schema,
        reason_codes_path: Some(args.reason_codes),
    };

    match doctor(&request) {
        Ok(report) => {
            emit_json(&report);
            if report.valid {
                std::process::exit(0);
            }
            std::process::exit(1);
        }
        Err(err) => {
            emit_runtime_error(&err.to_string());
            std::process::exit(2);
        }
    }
}

fn run_receipt_validate(args: ReceiptValidateArgs) {
    let request = ReceiptValidateRequest {
        policy_path: args.policy,
        receipt_path: args.receipt,
    };

    match validate_receipt(&request) {
        Ok(report) => {
            emit_json(&report);
            if report.valid {
                std::process::exit(0);
            }
            std::process::exit(1);
        }
        Err(err) => {
            emit_runtime_error(&err.to_string());
            std::process::exit(2);
        }
    }
}

fn to_preflight_request(common: CommonPolicyArgs) -> Result<PreflightRequest, String> {
    let kind = parse_scope_kind(&common.kind)?;
    Ok(PreflightRequest {
        kind,
        target_id: common.id,
        manifest_path: common.manifest,
        artifact_path: common.artifact,
        policy_path: common.policy,
        exceptions_path: common.exceptions,
        caller_skill_id: common.caller_skill_id,
        caller_skill_manifest_path: common.caller_skill_manifest,
        caller_skill_artifact_path: common.caller_skill_artifact,
    })
}

fn parse_scope_kind(value: &str) -> Result<ScopeKind, String> {
    match value.to_lowercase().as_str() {
        "service" => Ok(ScopeKind::Service),
        "skill" => Ok(ScopeKind::Skill),
        _ => Err(format!(
            "invalid --kind value '{value}' (expected service|skill)"
        )),
    }
}

fn env_or_string(explicit: Option<String>, key: &str, fallback: &str) -> String {
    if let Some(value) = explicit {
        if !value.trim().is_empty() {
            return value;
        }
    }

    if let Ok(value) = std::env::var(key) {
        if !value.trim().is_empty() {
            return value;
        }
    }

    fallback.to_string()
}

fn env_or_optional(explicit: Option<String>, key: &str) -> Option<String> {
    if explicit
        .as_deref()
        .is_some_and(|value| !value.trim().is_empty())
    {
        return explicit;
    }

    std::env::var(key)
        .ok()
        .filter(|value| !value.trim().is_empty())
}

fn emit_json<T: Serialize>(value: &T) {
    match serde_json::to_string_pretty(value) {
        Ok(json) => println!("{json}"),
        Err(err) => {
            eprintln!("failed to serialize JSON output: {err}");
            std::process::exit(2);
        }
    }
}

fn emit_runtime_error(message: &str) {
    let payload = RuntimeErrorPayload {
        allow: false,
        mode: "hard-enforce".to_string(),
        deny: ErrorDeny {
            code: "DDB025_RUNTIME_DECISION_ENGINE_ERROR".to_string(),
            message: message.to_string(),
            remediation_hint: "Inspect policy input and engine diagnostics".to_string(),
        },
    };
    emit_json(&payload);
}

fn load_acp_request(path: &PathBuf) -> Result<AcpRequest, String> {
    let content = fs::read_to_string(path)
        .map_err(|err| format!("failed to read ACP request {}: {err}", path.display()))?;
    serde_json::from_str::<AcpRequest>(&content)
        .map_err(|err| format!("failed to parse ACP request {}: {err}", path.display()))
}
