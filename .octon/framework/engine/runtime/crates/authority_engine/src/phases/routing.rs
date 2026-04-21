use super::*;
use serde_json::json;
use std::collections::BTreeMap;

pub(crate) fn route_phase_result(
    request_id: &str,
    phase_status: &str,
    decision: ExecutionDecision,
    reason_codes: Vec<String>,
    artifact_refs: BTreeMap<String, String>,
    details: serde_json::Value,
) -> AuthorizationPhaseResult {
    AuthorizationPhaseResult {
        schema_version: "authorization-phase-result-v1".to_string(),
        request_id: request_id.to_string(),
        run_id: request_id.to_string(),
        phase_id: "routing".to_string(),
        phase_status: phase_status.to_string(),
        decision,
        reason_codes,
        artifact_refs,
        details,
        generated_at: now_rfc3339().unwrap_or_else(|_| "1970-01-01T00:00:00Z".to_string()),
    }
}

pub(crate) fn route_details(
    ownership: &OwnershipPosture,
    support_tier: &SupportTierPosture,
    reversibility: &serde_json::Value,
    budget: &serde_json::Value,
    egress: &serde_json::Value,
) -> serde_json::Value {
    json!({
        "ownership": ownership,
        "support_tier": support_tier,
        "reversibility": reversibility,
        "budget": budget,
        "egress": egress,
    })
}
