use super::*;
use serde_json::{json, Value};

pub(crate) fn preflight_phase_result(
    phase_status: &str,
    decision: ExecutionDecision,
    reason_codes: Vec<String>,
    details: Value,
) -> AuthorizationPhaseResult {
    AuthorizationPhaseResult {
        schema_version: "authorization-phase-result-v1".to_string(),
        request_id: String::new(),
        run_id: String::new(),
        phase_id: "preflight".to_string(),
        phase_status: phase_status.to_string(),
        decision,
        reason_codes,
        artifact_refs: Default::default(),
        details,
        generated_at: now_rfc3339().unwrap_or_else(|_| "1970-01-01T00:00:00Z".to_string()),
    }
}

pub(crate) fn preflight_details(
    environment: &ExecutionEnvironment,
    effective_policy_mode: &str,
    executor_profile: Option<&str>,
    ownership_status: &str,
    support_route: &str,
) -> Value {
    json!({
        "environment_class": environment.as_str(),
        "effective_policy_mode": effective_policy_mode,
        "executor_profile": executor_profile,
        "ownership_status": ownership_status,
        "support_route": support_route,
    })
}
