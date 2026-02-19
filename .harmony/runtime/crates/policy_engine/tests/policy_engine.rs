use policy_engine::{
    doctor, evaluate_enforce, evaluate_grant, evaluate_preflight, DoctorRequest, EnforceRequest,
    GrantEvalRequest, PreflightRequest, ScopeKind,
};
use serde_json::{json, Value};
use std::fs;
use std::path::{Path, PathBuf};

fn fixture_path(name: &str) -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests")
        .join("fixtures")
        .join(name)
}

fn repo_root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("../../../..")
}

#[test]
fn preflight_service_allow_matches_golden() {
    let request = PreflightRequest {
        kind: ScopeKind::Service,
        target_id: "agent".to_string(),
        manifest_path: fixture_path("services-manifest.yml"),
        artifact_path: fixture_path("service-allow.SERVICE.md"),
        policy_path: fixture_path("policy.yml"),
        exceptions_path: Some(fixture_path("exceptions.yml")),
    };

    let decision = evaluate_preflight(&request).expect("preflight should succeed");
    assert!(decision.allow);

    let actual = json!({
        "allow": decision.allow,
        "mode": decision.mode,
        "notes": decision.notes,
    });

    let golden_text = fs::read_to_string(fixture_path("preflight_allow.golden.json"))
        .expect("golden allow fixture");
    let golden: Value = serde_json::from_str(&golden_text).expect("golden allow parse");
    assert_eq!(actual, golden);
}

#[test]
fn preflight_service_denies_unscoped_bash_matches_golden() {
    let request = PreflightRequest {
        kind: ScopeKind::Service,
        target_id: "agent".to_string(),
        manifest_path: fixture_path("services-manifest.yml"),
        artifact_path: fixture_path("service-unscoped-bash.SERVICE.md"),
        policy_path: fixture_path("policy.yml"),
        exceptions_path: Some(fixture_path("exceptions.yml")),
    };

    let decision = evaluate_preflight(&request).expect("preflight should succeed");
    assert!(!decision.allow);
    let deny = decision.deny.expect("deny payload");

    let actual = json!({
        "allow": false,
        "mode": decision.mode,
        "deny": {
            "code": deny.code,
            "scope": deny.scope,
            "target": deny.target,
        }
    });

    let golden_text =
        fs::read_to_string(fixture_path("preflight_deny_unscoped_bash.golden.json"))
            .expect("golden deny fixture");
    let golden: Value = serde_json::from_str(&golden_text).expect("golden deny parse");
    assert_eq!(actual, golden);
}

#[test]
fn enforce_denies_command_outside_bash_scope() {
    let request = EnforceRequest {
        preflight: PreflightRequest {
            kind: ScopeKind::Service,
            target_id: "agent".to_string(),
            manifest_path: fixture_path("services-manifest.yml"),
            artifact_path: fixture_path("service-allow.SERVICE.md"),
            policy_path: fixture_path("policy.yml"),
            exceptions_path: Some(fixture_path("exceptions.yml")),
        },
        requested_command: Some("bash execution/guard/impl/guard.sh".to_string()),
        risk_tier: "low".to_string(),
        agent_id: Some("agent-a".to_string()),
        agent_ids_csv: Some("agent-a".to_string()),
        review_agent_id: None,
        quorum_token: None,
        rollback_plan_id: None,
        category: None,
    };

    let decision = evaluate_enforce(&request).expect("enforce should return decision");
    assert!(!decision.allow);
    let deny = decision.deny.expect("deny payload");
    assert_eq!(deny.code, "DDB007_BASH_SCOPE_DENIED");
}

#[test]
fn grant_eval_enforces_tier_and_provenance_rules() {
    let deny_request = GrantEvalRequest {
        policy_path: fixture_path("policy.yml"),
        tier: "medium".to_string(),
        requested_tools: vec!["Read".to_string()],
        requested_write_scopes: vec!["src/*".to_string()],
        requested_ttl_seconds: Some(900),
        has_review_evidence: false,
        has_quorum_evidence: false,
        request_id: Some("req-1".to_string()),
        agent_id: Some("agent-a".to_string()),
        plan_step_id: Some("step-1".to_string()),
    };

    let deny_result = evaluate_grant(&deny_request).expect("grant eval should run");
    assert!(!deny_result.allow);
    assert_eq!(
        deny_result.deny.expect("deny payload").code,
        "DDB022_GRANT_TIER_REVIEW_REQUIRED"
    );

    let allow_request = GrantEvalRequest {
        policy_path: fixture_path("policy.yml"),
        tier: "low".to_string(),
        requested_tools: vec!["Read".to_string(), "Bash(rg *)".to_string()],
        requested_write_scopes: vec!["src/*".to_string()],
        requested_ttl_seconds: Some(600),
        has_review_evidence: false,
        has_quorum_evidence: false,
        request_id: Some("req-2".to_string()),
        agent_id: Some("agent-a".to_string()),
        plan_step_id: Some("step-2".to_string()),
    };

    let allow_result = evaluate_grant(&allow_request).expect("grant eval should run");
    assert!(allow_result.allow);
    assert_eq!(allow_result.effective_ttl_seconds, Some(600));
}

#[test]
fn doctor_validates_repo_policy_contract() {
    let root = repo_root();
    let request = DoctorRequest {
        policy_path: root.join(".harmony/capabilities/_ops/policy/deny-by-default.v2.yml"),
        schema_path: root.join(".harmony/capabilities/_ops/policy/deny-by-default.v2.schema.json"),
        reason_codes_path: Some(root.join(".harmony/capabilities/_ops/policy/reason-codes.md")),
    };

    let report = doctor(&request).expect("doctor should run");
    assert!(
        report.valid,
        "doctor reported invalid: schema={:?} semantic={:?}",
        report.schema_errors,
        report.semantic_errors
    );
}
