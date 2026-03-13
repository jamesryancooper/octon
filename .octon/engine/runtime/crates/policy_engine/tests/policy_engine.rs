use policy_engine::{
    doctor, evaluate_acp_enforce, evaluate_enforce, evaluate_grant, evaluate_preflight,
    validate_receipt, AcpActor, AcpAttestation, AcpDecisionKind, AcpEvidence, AcpOperation,
    AcpRequest, AcpReversibilityProof, DoctorRequest, EnforceRequest, GrantEvalRequest,
    PreflightRequest, ReceiptValidateRequest, ScopeKind,
};
use serde_json::{json, Value};
use std::collections::HashMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::sync::atomic::{AtomicU64, Ordering};
use std::time::{SystemTime, UNIX_EPOCH};

static TEMP_POLICY_COUNTER: AtomicU64 = AtomicU64::new(0);

fn fixture_path(name: &str) -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests")
        .join("fixtures")
        .join(name)
}

fn repo_root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("../../../../..")
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
        caller_skill_id: None,
        caller_skill_manifest_path: None,
        caller_skill_artifact_path: None,
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
        caller_skill_id: None,
        caller_skill_manifest_path: None,
        caller_skill_artifact_path: None,
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

    let golden_text = fs::read_to_string(fixture_path("preflight_deny_unscoped_bash.golden.json"))
        .expect("golden deny fixture");
    let golden: Value = serde_json::from_str(&golden_text).expect("golden deny parse");
    assert_eq!(actual, golden);
}

#[test]
fn preflight_service_allows_declared_caller_skill_service_access() {
    let request = PreflightRequest {
        kind: ScopeKind::Service,
        target_id: "agent".to_string(),
        manifest_path: fixture_path("services-manifest.yml"),
        artifact_path: fixture_path("service-allow.SERVICE.md"),
        policy_path: fixture_path("policy.yml"),
        exceptions_path: Some(fixture_path("exceptions.yml")),
        caller_skill_id: Some("caller-allow".to_string()),
        caller_skill_manifest_path: Some(fixture_path("skills-manifest.yml")),
        caller_skill_artifact_path: Some(fixture_path("skill-caller-allow.SKILL.md")),
    };

    let decision = evaluate_preflight(&request).expect("preflight should succeed");
    assert!(decision.allow);
}

#[test]
fn preflight_service_denies_undeclared_caller_skill_service_access() {
    let request = PreflightRequest {
        kind: ScopeKind::Service,
        target_id: "agent".to_string(),
        manifest_path: fixture_path("services-manifest.yml"),
        artifact_path: fixture_path("service-allow.SERVICE.md"),
        policy_path: fixture_path("policy.yml"),
        exceptions_path: Some(fixture_path("exceptions.yml")),
        caller_skill_id: Some("caller-deny".to_string()),
        caller_skill_manifest_path: Some(fixture_path("skills-manifest.yml")),
        caller_skill_artifact_path: Some(fixture_path("skill-caller-deny.SKILL.md")),
    };

    let decision = evaluate_preflight(&request).expect("preflight should succeed");
    assert!(!decision.allow);
    let deny = decision.deny.expect("deny payload");
    assert_eq!(deny.code, "DDB030_SKILL_SERVICE_NOT_DECLARED");
}

#[test]
fn preflight_skill_denies_unknown_allowed_service() {
    let request = PreflightRequest {
        kind: ScopeKind::Skill,
        target_id: "caller-unknown".to_string(),
        manifest_path: fixture_path("skills-manifest.yml"),
        artifact_path: fixture_path("skill-caller-unknown.SKILL.md"),
        policy_path: fixture_path("policy.yml"),
        exceptions_path: Some(fixture_path("exceptions.yml")),
        caller_skill_id: None,
        caller_skill_manifest_path: None,
        caller_skill_artifact_path: None,
    };

    let decision = evaluate_preflight(&request).expect("preflight should succeed");
    assert!(!decision.allow);
    let deny = decision.deny.expect("deny payload");
    assert_eq!(deny.code, "DDB027_UNKNOWN_ALLOWED_SERVICE");
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
            caller_skill_id: None,
            caller_skill_manifest_path: None,
            caller_skill_artifact_path: None,
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

fn acp_request_base(class: &str) -> AcpRequest {
    AcpRequest {
        run_id: "run-1".to_string(),
        actor: AcpActor {
            id: "agent.proposer".to_string(),
            r#type: Some("agent".to_string()),
        },
        profile: "operate".to_string(),
        phase: "promote".to_string(),
        operation: AcpOperation {
            class: class.to_string(),
            targets: Vec::new(),
            resources: Vec::new(),
            target: Default::default(),
        },
        acp_claim: None,
        break_glass: false,
        reversibility: Some(AcpReversibilityProof {
            reversible: true,
            primitive: Some("git.revert_commit".to_string()),
            rollback_handle: Some("git:revert:abc123".to_string()),
            recovery_window: Some("P30D".to_string()),
            rollback_proof: Some("artifacts/rollback.log".to_string()),
        }),
        evidence: vec![
            AcpEvidence {
                r#type: "diff".to_string(),
                r#ref: "artifacts/diff.patch".to_string(),
                sha256: Some("aaa".to_string()),
            },
            AcpEvidence {
                r#type: "tests".to_string(),
                r#ref: "artifacts/tests.json".to_string(),
                sha256: Some("bbb".to_string()),
            },
            AcpEvidence {
                r#type: "docs.spec".to_string(),
                r#ref: "docs/specs/example/spec.md".to_string(),
                sha256: Some("ccc".to_string()),
            },
            AcpEvidence {
                r#type: "docs.adr".to_string(),
                r#ref: "docs/adr/ADR-0001-example.md".to_string(),
                sha256: Some("ddd".to_string()),
            },
            AcpEvidence {
                r#type: "docs.runbook".to_string(),
                r#ref: "docs/runbooks/example.md".to_string(),
                sha256: Some("eee".to_string()),
            },
        ],
        attestations: Vec::new(),
        budgets: Default::default(),
        counters: Default::default(),
        circuit_signals: Vec::new(),
        plan_hash: Some("plan-hash-1".to_string()),
        evidence_hash: Some("evidence-hash-1".to_string()),
        intent: Some("test-intent".to_string()),
        boundaries: Some("test-boundaries".to_string()),
    }
}

#[test]
fn acp1_allow_with_evidence_and_rollback_handle() {
    let mut request = acp_request_base("git.commit");
    request.profile = "refactor".to_string();
    request.counters = HashMap::from([
        ("repo.max_files_touched".to_string(), 4.0),
        ("repo.max_loc_delta".to_string(), 120.0),
    ]);

    let decision = evaluate_acp_enforce(&fixture_path("policy.yml"), &request)
        .expect("acp enforce should evaluate");
    assert!(matches!(decision.decision, AcpDecisionKind::Allow));
    assert!(decision.allow);
    assert!(decision
        .reason_codes
        .contains(&"ACP_ALLOW_POLICY_PASS".to_string()));
    assert!(!decision.remediation.is_empty());
    assert!(!decision.remediation_steps.is_empty());
}

#[test]
fn acp2_stage_only_when_quorum_missing() {
    let mut request = acp_request_base("git.merge");
    request
        .operation
        .target
        .insert("branch".to_string(), json!("main"));
    request.reversibility = Some(AcpReversibilityProof {
        reversible: true,
        primitive: Some("git.revert_merge".to_string()),
        rollback_handle: Some("git:revert:merge123".to_string()),
        recovery_window: Some("P30D".to_string()),
        rollback_proof: Some("artifacts/rollback.log".to_string()),
    });
    request.counters = HashMap::from([
        ("repo.max_files_touched".to_string(), 20.0),
        ("repo.max_loc_delta".to_string(), 600.0),
    ]);

    let decision = evaluate_acp_enforce(&fixture_path("policy.yml"), &request)
        .expect("acp enforce should evaluate");
    assert!(matches!(decision.decision, AcpDecisionKind::StageOnly));
    assert!(decision
        .reason_codes
        .contains(&"ACP_QUORUM_MISSING".to_string()));
    assert!(decision
        .reason_codes
        .contains(&"ACP_PROTECTED_TARGET".to_string()));
    assert!(decision
        .reason_codes
        .contains(&"ACP_STAGE_ONLY_REQUIRED".to_string()));
}

#[test]
fn acp2_allow_with_quorum_and_rollback_proof() {
    let mut request = acp_request_base("git.merge");
    request
        .operation
        .target
        .insert("branch".to_string(), json!("main"));
    request.reversibility = Some(AcpReversibilityProof {
        reversible: true,
        primitive: Some("git.revert_merge".to_string()),
        rollback_handle: Some("git:revert:merge123".to_string()),
        recovery_window: Some("P30D".to_string()),
        rollback_proof: Some("artifacts/rollback.log".to_string()),
    });
    request.attestations = vec![
        AcpAttestation {
            role: "proposer".to_string(),
            actor_id: "agent.a".to_string(),
            timestamp: Some("2026-02-19T00:00:00Z".to_string()),
            plan_hash: Some("plan-hash-1".to_string()),
            evidence_hash: Some("evidence-hash-1".to_string()),
            signature: Some("sig-a".to_string()),
        },
        AcpAttestation {
            role: "verifier".to_string(),
            actor_id: "agent.b".to_string(),
            timestamp: Some("2026-02-19T00:01:00Z".to_string()),
            plan_hash: Some("plan-hash-1".to_string()),
            evidence_hash: Some("evidence-hash-1".to_string()),
            signature: Some("sig-b".to_string()),
        },
    ];
    request.counters = HashMap::from([
        ("repo.max_files_touched".to_string(), 20.0),
        ("repo.max_loc_delta".to_string(), 600.0),
    ]);

    let decision = evaluate_acp_enforce(&fixture_path("policy.yml"), &request)
        .expect("acp enforce should evaluate");
    assert!(matches!(decision.decision, AcpDecisionKind::Allow));
    assert!(decision.allow);
    assert!(decision
        .reason_codes
        .contains(&"ACP_PROTECTED_TARGET".to_string()));
}

#[test]
fn acp_soft_delete_local_maps_to_acp1_allow() {
    let mut request = acp_request_base("fs.soft_delete");
    request
        .operation
        .target
        .insert("scope".to_string(), json!("local"));
    request.reversibility = Some(AcpReversibilityProof {
        reversible: true,
        primitive: Some("fs.move_to_trash".to_string()),
        rollback_handle: Some("fs:trash:local123".to_string()),
        recovery_window: Some("P30D".to_string()),
        rollback_proof: None,
    });
    request.counters = HashMap::from([("fs.max_paths_deleted".to_string(), 1.0)]);

    let decision = evaluate_acp_enforce(&fixture_path("policy.yml"), &request)
        .expect("acp enforce should evaluate");
    assert!(matches!(decision.decision, AcpDecisionKind::Allow));
    assert!(decision.allow);
    assert_eq!(decision.effective_acp, "ACP-1");
}

#[test]
fn acp3_denies_irreversible_primitive() {
    let mut request = acp_request_base("fs.soft_delete");
    request.reversibility = Some(AcpReversibilityProof {
        reversible: true,
        primitive: Some("fs.hard_delete".to_string()),
        rollback_handle: Some("fs:irreversible".to_string()),
        recovery_window: Some("P1D".to_string()),
        rollback_proof: Some("artifacts/rollback.log".to_string()),
    });
    request.attestations = vec![
        AcpAttestation {
            role: "proposer".to_string(),
            actor_id: "agent.a".to_string(),
            timestamp: Some("2026-02-19T00:00:00Z".to_string()),
            plan_hash: Some("plan-hash-1".to_string()),
            evidence_hash: Some("evidence-hash-1".to_string()),
            signature: Some("sig-a".to_string()),
        },
        AcpAttestation {
            role: "verifier".to_string(),
            actor_id: "agent.b".to_string(),
            timestamp: Some("2026-02-19T00:01:00Z".to_string()),
            plan_hash: Some("plan-hash-1".to_string()),
            evidence_hash: Some("evidence-hash-1".to_string()),
            signature: Some("sig-b".to_string()),
        },
        AcpAttestation {
            role: "recovery".to_string(),
            actor_id: "agent.c".to_string(),
            timestamp: Some("2026-02-19T00:02:00Z".to_string()),
            plan_hash: Some("plan-hash-1".to_string()),
            evidence_hash: Some("evidence-hash-1".to_string()),
            signature: Some("sig-c".to_string()),
        },
    ];
    request.counters = HashMap::from([("fs.max_paths_deleted".to_string(), 2.0)]);

    let decision = evaluate_acp_enforce(&fixture_path("policy.yml"), &request)
        .expect("acp enforce should evaluate");
    assert!(matches!(decision.decision, AcpDecisionKind::Deny));
    assert!(decision
        .reason_codes
        .contains(&"ACP_IRREVERSIBLE_BLOCKED".to_string()));
}

#[test]
fn acp_stage_only_when_budget_exceeded() {
    let mut request = acp_request_base("git.commit");
    request.profile = "refactor".to_string();
    request.counters = HashMap::from([
        ("repo.max_files_touched".to_string(), 20.0),
        ("repo.max_loc_delta".to_string(), 4000.0),
    ]);

    let decision = evaluate_acp_enforce(&fixture_path("policy.yml"), &request)
        .expect("acp enforce should evaluate");
    assert!(matches!(decision.decision, AcpDecisionKind::StageOnly));
    assert!(decision
        .reason_codes
        .contains(&"ACP_BUDGET_EXCEEDED".to_string()));
    assert!(decision
        .reason_codes
        .contains(&"ACP_STAGE_ONLY_REQUIRED".to_string()));
}

#[test]
fn acp_repo_stage_breaker_enforces_stage_only_action() {
    let mut request = acp_request_base("git.commit");
    request.profile = "refactor".to_string();
    request.counters = HashMap::from([
        ("repo.max_files_touched".to_string(), 4.0),
        ("repo.max_loc_delta".to_string(), 120.0),
    ]);
    request.circuit_signals = vec!["tests.failed".to_string()];

    let decision = evaluate_acp_enforce(&fixture_path("policy.yml"), &request)
        .expect("acp enforce should evaluate");
    assert!(matches!(decision.decision, AcpDecisionKind::StageOnly));
    assert!(decision
        .reason_codes
        .contains(&"ACP_CIRCUIT_BREAKER_TRIPPED".to_string()));
    assert!(decision
        .requirements
        .breaker_actions
        .contains(&"stop_and_stage_only".to_string()));
}

#[test]
fn acp_repo_promote_breaker_enforces_deny_action() {
    let mut request = acp_request_base("git.merge");
    request
        .operation
        .target
        .insert("branch".to_string(), json!("main"));
    request.reversibility = Some(AcpReversibilityProof {
        reversible: true,
        primitive: Some("git.revert_merge".to_string()),
        rollback_handle: Some("git:revert:merge123".to_string()),
        recovery_window: Some("P30D".to_string()),
        rollback_proof: Some("artifacts/rollback.log".to_string()),
    });
    request.attestations = vec![
        AcpAttestation {
            role: "proposer".to_string(),
            actor_id: "agent.a".to_string(),
            timestamp: Some("2026-02-19T00:00:00Z".to_string()),
            plan_hash: Some("plan-hash-1".to_string()),
            evidence_hash: Some("evidence-hash-1".to_string()),
            signature: Some("sig-a".to_string()),
        },
        AcpAttestation {
            role: "verifier".to_string(),
            actor_id: "agent.b".to_string(),
            timestamp: Some("2026-02-19T00:01:00Z".to_string()),
            plan_hash: Some("plan-hash-1".to_string()),
            evidence_hash: Some("evidence-hash-1".to_string()),
            signature: Some("sig-b".to_string()),
        },
    ];
    request.counters = HashMap::from([
        ("repo.max_files_touched".to_string(), 20.0),
        ("repo.max_loc_delta".to_string(), 600.0),
    ]);
    request.circuit_signals = vec!["ci.failed".to_string()];

    let decision = evaluate_acp_enforce(&fixture_path("policy.yml"), &request)
        .expect("acp enforce should evaluate");
    assert!(matches!(decision.decision, AcpDecisionKind::Deny));
    assert!(decision
        .reason_codes
        .contains(&"ACP_CIRCUIT_BREAKER_TRIPPED".to_string()));
    assert!(decision
        .requirements
        .breaker_actions
        .contains(&"auto_rollback_and_trip_killswitch".to_string()));
}

#[test]
fn receipt_validate_enforces_required_fields() {
    let root = repo_root();
    let unique = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("system time should be after unix epoch")
        .as_nanos();
    let receipt_path = std::env::temp_dir().join(format!("policy-engine-receipt-{unique}.json"));

    fs::write(
        &receipt_path,
        serde_json::to_vec(&json!({
            "schema_version":"policy-receipt-v1",
            "run_id":"run-x",
            "timestamp":"2026-02-19T00:00:00Z",
            "actor":{"id":"agent.a","type":"agent"},
            "profile":"operate",
            "intent":"test",
            "boundaries":"test",
            "operation":{"class":"git.commit","target":{"material_side_effect":true,"telemetry_profile":"minimal"}},
            "phase":"promote",
            "material_side_effect":true,
            "telemetry_profile":"minimal",
            "effective_acp":"ACP-1",
            "decision":"ALLOW",
            "reason_codes":["ACP_ALLOW_POLICY_PASS"],
            "reason_details":[{"code":"ACP_ALLOW_POLICY_PASS","remediation":"No additional remediation required beyond retaining the receipt and evidence bundle."}],
            "remediation":"No additional remediation required beyond retaining the receipt and evidence bundle.",
            "intent_ref":"intent://test",
            "boundary_id":"boundary-test",
            "boundary_set_version":"1.0.0",
            "workflow_mode":"iterate",
            "capability_classification":"skill",
            "evidence":[{"type":"diff","ref":"a","sha256":"h"}],
            "attestations":[],
            "rollback_handle":"git:revert:abc",
            "recovery_window":"P30D",
            "budgets":{},
            "counters":{}
        }))
        .expect("serialize receipt"),
    )
    .expect("write temp receipt");

    let valid_request = ReceiptValidateRequest {
        policy_path: root.join(".octon/capabilities/governance/policy/deny-by-default.v2.yml"),
        receipt_path: receipt_path.clone(),
    };
    let valid_report = validate_receipt(&valid_request).expect("receipt validate should run");
    assert!(valid_report.valid, "errors: {:?}", valid_report.errors);

    fs::write(&receipt_path, b"{\"run_id\":\"x\"}").expect("write invalid receipt");
    let invalid_report = validate_receipt(&valid_request).expect("receipt validate should run");
    assert!(!invalid_report.valid);
    assert!(invalid_report
        .reason_codes
        .contains(&"ACP_RECEIPT_INVALID".to_string()));

    let _ = fs::remove_file(receipt_path);
}

#[test]
fn receipt_validate_fails_when_telemetry_profile_missing_for_acp1_promote() {
    let root = repo_root();
    let unique = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("system time should be after unix epoch")
        .as_nanos();
    let receipt_path = std::env::temp_dir().join(format!(
        "policy-engine-receipt-telemetry-missing-{unique}.json"
    ));

    fs::write(
        &receipt_path,
        serde_json::to_vec(&json!({
            "schema_version":"policy-receipt-v1",
            "run_id":"run-telemetry-missing",
            "timestamp":"2026-02-19T00:00:00Z",
            "actor":{"id":"agent.a","type":"agent"},
            "profile":"operate",
            "intent":"test",
            "boundaries":"test",
            "operation":{"class":"git.commit","target":{"material_side_effect":true}},
            "phase":"promote",
            "material_side_effect":true,
            "effective_acp":"ACP-1",
            "decision":"ALLOW",
            "reason_codes":["ACP_ALLOW_POLICY_PASS"],
            "reason_details":[{"code":"ACP_ALLOW_POLICY_PASS","remediation":"No additional remediation required beyond retaining the receipt and evidence bundle."}],
            "remediation":"No additional remediation required beyond retaining the receipt and evidence bundle.",
            "evidence":[{"type":"diff","ref":"a","sha256":"h"}],
            "attestations":[],
            "rollback_handle":"git:revert:abc",
            "recovery_window":"P30D",
            "budgets":{},
            "counters":{}
        }))
        .expect("serialize receipt"),
    )
    .expect("write temp receipt");

    let request = ReceiptValidateRequest {
        policy_path: root.join(".octon/capabilities/governance/policy/deny-by-default.v2.yml"),
        receipt_path: receipt_path.clone(),
    };
    let report = validate_receipt(&request).expect("receipt validate should run");
    assert!(!report.valid);
    assert!(report
        .reason_codes
        .contains(&"ACP_TELEMETRY_PROFILE_MISSING".to_string()));

    let _ = fs::remove_file(receipt_path);
}

#[test]
fn receipt_validate_fails_when_flag_metadata_invalid_for_flag_change() {
    let root = repo_root();
    let unique = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("system time should be after unix epoch")
        .as_nanos();
    let receipt_path =
        std::env::temp_dir().join(format!("policy-engine-receipt-flag-metadata-{unique}.json"));

    fs::write(
        &receipt_path,
        serde_json::to_vec(&json!({
            "schema_version":"policy-receipt-v1",
            "run_id":"run-flag-metadata-invalid",
            "timestamp":"2026-02-19T00:00:00Z",
            "actor":{"id":"agent.a","type":"agent"},
            "profile":"operate",
            "intent":"test",
            "boundaries":"test",
            "operation":{"class":"git.commit","target":{"material_side_effect":true,"telemetry_profile":"minimal","has_flags":true,"flag_metadata_valid":false}},
            "phase":"promote",
            "material_side_effect":true,
            "telemetry_profile":"minimal",
            "effective_acp":"ACP-1",
            "decision":"ALLOW",
            "reason_codes":["ACP_ALLOW_POLICY_PASS"],
            "reason_details":[{"code":"ACP_ALLOW_POLICY_PASS","remediation":"No additional remediation required beyond retaining the receipt and evidence bundle."}],
            "remediation":"No additional remediation required beyond retaining the receipt and evidence bundle.",
            "evidence":[{"type":"diff","ref":"a","sha256":"h"},{"type":"flags.metadata","ref":"flags","sha256":"f"}],
            "attestations":[],
            "rollback_handle":"git:revert:abc",
            "recovery_window":"P30D",
            "budgets":{},
            "counters":{}
        }))
        .expect("serialize receipt"),
    )
    .expect("write temp receipt");

    let request = ReceiptValidateRequest {
        policy_path: root.join(".octon/capabilities/governance/policy/deny-by-default.v2.yml"),
        receipt_path: receipt_path.clone(),
    };
    let report = validate_receipt(&request).expect("receipt validate should run");
    assert!(!report.valid);
    assert!(report
        .reason_codes
        .contains(&"ACP_FLAG_METADATA_INVALID".to_string()));

    let _ = fs::remove_file(receipt_path);
}

#[test]
fn doctor_validates_repo_policy_contract() {
    let root = repo_root();
    let request = DoctorRequest {
        policy_path: root.join(".octon/capabilities/governance/policy/deny-by-default.v2.yml"),
        schema_path: root.join(".octon/capabilities/governance/policy/deny-by-default.v2.schema.json"),
        reason_codes_path: Some(root.join(".octon/capabilities/governance/policy/reason-codes.md")),
    };

    let report = doctor(&request).expect("doctor should run");
    assert!(
        report.valid,
        "doctor reported invalid: schema={:?} semantic={:?}",
        report.schema_errors, report.semantic_errors
    );
}

fn temp_policy_path(prefix: &str) -> PathBuf {
    let nanos = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("clock should be monotonic")
        .as_nanos();
    let counter = TEMP_POLICY_COUNTER.fetch_add(1, Ordering::Relaxed);
    std::env::temp_dir().join(format!("octon-policy-{prefix}-{nanos}-{counter}.yml"))
}

fn fixture_policy_with_replacement(from: &str, to: &str) -> PathBuf {
    let policy_path = fixture_path("policy.yml");
    let policy_text = fs::read_to_string(&policy_path).expect("fixture policy should exist");
    let replaced = policy_text.replacen(from, to, 1);
    let output = temp_policy_path("fixture");
    fs::write(&output, replaced).expect("temp policy write should succeed");
    output
}

fn acp2_complete_request() -> AcpRequest {
    let mut request = acp_request_base("git.merge");
    request.profile = "operate".to_string();
    request
        .operation
        .target
        .insert("branch".to_string(), json!("main"));
    request.reversibility = Some(AcpReversibilityProof {
        reversible: true,
        primitive: Some("git.revert_merge".to_string()),
        rollback_handle: Some("git:revert:merge123".to_string()),
        recovery_window: Some("P30D".to_string()),
        rollback_proof: Some("artifacts/rollback.log".to_string()),
    });
    request.attestations = vec![
        AcpAttestation {
            role: "proposer".to_string(),
            actor_id: "agent.a".to_string(),
            timestamp: Some("2026-02-19T00:00:00Z".to_string()),
            plan_hash: Some("plan-hash-1".to_string()),
            evidence_hash: Some("evidence-hash-1".to_string()),
            signature: Some("sig-a".to_string()),
        },
        AcpAttestation {
            role: "verifier".to_string(),
            actor_id: "agent.b".to_string(),
            timestamp: Some("2026-02-19T00:01:00Z".to_string()),
            plan_hash: Some("plan-hash-1".to_string()),
            evidence_hash: Some("evidence-hash-1".to_string()),
            signature: Some("sig-b".to_string()),
        },
    ];
    request.counters = HashMap::from([
        ("repo.max_files_touched".to_string(), 20.0),
        ("repo.max_loc_delta".to_string(), 600.0),
    ]);
    request
}

fn acp3_complete_request() -> AcpRequest {
    let mut request = acp_request_base("fs.soft_delete");
    request.profile = "operate".to_string();
    request.operation.target.insert(
        "path".to_string(),
        json!(".octon/output/old-artifact.txt"),
    );
    request.reversibility = Some(AcpReversibilityProof {
        reversible: true,
        primitive: Some("fs.move_to_trash".to_string()),
        rollback_handle: Some("fs:trash:run-1".to_string()),
        recovery_window: Some("P7D".to_string()),
        rollback_proof: Some("artifacts/rollback.log".to_string()),
    });
    request.attestations = vec![
        AcpAttestation {
            role: "proposer".to_string(),
            actor_id: "agent.a".to_string(),
            timestamp: Some("2026-02-19T00:00:00Z".to_string()),
            plan_hash: Some("plan-hash-1".to_string()),
            evidence_hash: Some("evidence-hash-1".to_string()),
            signature: Some("sig-a".to_string()),
        },
        AcpAttestation {
            role: "verifier".to_string(),
            actor_id: "agent.b".to_string(),
            timestamp: Some("2026-02-19T00:01:00Z".to_string()),
            plan_hash: Some("plan-hash-1".to_string()),
            evidence_hash: Some("evidence-hash-1".to_string()),
            signature: Some("sig-b".to_string()),
        },
        AcpAttestation {
            role: "recovery".to_string(),
            actor_id: "agent.c".to_string(),
            timestamp: Some("2026-02-19T00:02:00Z".to_string()),
            plan_hash: Some("plan-hash-1".to_string()),
            evidence_hash: Some("evidence-hash-1".to_string()),
            signature: Some("sig-c".to_string()),
        },
    ];
    request.counters = HashMap::from([("fs.max_paths_deleted".to_string(), 2.0)]);
    request
}

fn omit_attestation_field(attestation: &mut AcpAttestation, field: &str) {
    match field {
        "role" => attestation.role = String::new(),
        "actor_id" => attestation.actor_id = String::new(),
        "timestamp" => attestation.timestamp = None,
        "plan_hash" => attestation.plan_hash = None,
        "evidence_hash" => attestation.evidence_hash = None,
        "signature" => attestation.signature = None,
        _ => {}
    }
}

fn strip_docs_gate_evidence(request: &mut AcpRequest) {
    request.evidence.retain(|entry| {
        !matches!(
            entry.r#type.as_str(),
            "docs.spec" | "docs.adr" | "docs.runbook"
        )
    });
}

#[test]
fn acp_breaker_halt_and_notify_escalates() {
    let policy_path =
        fixture_policy_with_replacement("action: stop_and_stage_only", "action: halt_and_notify");
    let mut request = acp_request_base("git.commit");
    request.profile = "refactor".to_string();
    request.counters = HashMap::from([
        ("repo.max_files_touched".to_string(), 4.0),
        ("repo.max_loc_delta".to_string(), 120.0),
    ]);
    request.circuit_signals = vec!["tests.failed".to_string()];

    let decision =
        evaluate_acp_enforce(&policy_path, &request).expect("acp enforce should evaluate");
    assert!(matches!(decision.decision, AcpDecisionKind::Escalate));
    assert!(decision
        .reason_codes
        .contains(&"ACP_CIRCUIT_BREAKER_TRIPPED".to_string()));
    fs::remove_file(policy_path).expect("temp policy cleanup");
}

#[test]
fn acp_breaker_rollback_and_trip_killswitch_denies() {
    let policy_path = fixture_policy_with_replacement(
        "action: auto_rollback_and_trip_killswitch",
        "action: rollback_and_trip_killswitch",
    );
    let mut request = acp_request_base("git.merge");
    request.profile = "operate".to_string();
    request
        .operation
        .target
        .insert("branch".to_string(), json!("main"));
    request.circuit_signals = vec!["ci.failed".to_string()];
    request.counters = HashMap::from([
        ("repo.max_files_touched".to_string(), 20.0),
        ("repo.max_loc_delta".to_string(), 600.0),
    ]);

    let decision =
        evaluate_acp_enforce(&policy_path, &request).expect("acp enforce should evaluate");
    assert!(matches!(decision.decision, AcpDecisionKind::Deny));
    assert!(decision
        .reason_codes
        .contains(&"ACP_CIRCUIT_BREAKER_TRIPPED".to_string()));
    fs::remove_file(policy_path).expect("temp policy cleanup");
}

#[test]
fn acp_breaker_invalid_action_fails_closed() {
    let policy_path = fixture_policy_with_replacement(
        "action: stop_and_stage_only",
        "action: unsupported_action",
    );
    let mut request = acp_request_base("git.commit");
    request.profile = "refactor".to_string();
    request.counters = HashMap::from([
        ("repo.max_files_touched".to_string(), 4.0),
        ("repo.max_loc_delta".to_string(), 120.0),
    ]);
    request.circuit_signals = vec!["tests.failed".to_string()];

    let decision =
        evaluate_acp_enforce(&policy_path, &request).expect("acp enforce should evaluate");
    assert!(matches!(decision.decision, AcpDecisionKind::Deny));
    assert!(decision
        .reason_codes
        .contains(&"ACP_CIRCUIT_BREAKER_INVALID_ACTION".to_string()));
    fs::remove_file(policy_path).expect("temp policy cleanup");
}

#[test]
fn acp2_missing_required_attestation_fields_stage_only() {
    let required_fields = [
        "role",
        "actor_id",
        "timestamp",
        "plan_hash",
        "evidence_hash",
        "signature",
    ];

    for field in required_fields {
        let mut request = acp2_complete_request();
        omit_attestation_field(&mut request.attestations[0], field);
        let decision = evaluate_acp_enforce(&fixture_path("policy.yml"), &request)
            .expect("acp enforce should evaluate");
        assert!(
            matches!(
                decision.decision,
                AcpDecisionKind::StageOnly | AcpDecisionKind::Deny
            ),
            "expected stage-only/deny for missing field {field}, got {:?}",
            decision.decision
        );
        assert!(decision
            .reason_codes
            .contains(&"ACP_ATTESTATION_FIELD_MISSING".to_string()));
    }
}

#[test]
fn acp3_missing_required_attestation_fields_stage_only() {
    let required_fields = [
        "role",
        "actor_id",
        "timestamp",
        "plan_hash",
        "evidence_hash",
        "signature",
    ];

    for field in required_fields {
        let mut request = acp3_complete_request();
        omit_attestation_field(&mut request.attestations[0], field);
        let decision = evaluate_acp_enforce(&fixture_path("policy.yml"), &request)
            .expect("acp enforce should evaluate");
        assert!(
            matches!(
                decision.decision,
                AcpDecisionKind::StageOnly | AcpDecisionKind::Deny
            ),
            "expected stage-only/deny for missing field {field}, got {:?}",
            decision.decision
        );
        assert!(decision
            .reason_codes
            .contains(&"ACP_ATTESTATION_FIELD_MISSING".to_string()));
    }
}

#[test]
fn acp_docs_gate_missing_stage_only_for_acp1() {
    let mut request = acp_request_base("git.commit");
    request.profile = "refactor".to_string();
    request.counters = HashMap::from([
        ("repo.max_files_touched".to_string(), 4.0),
        ("repo.max_loc_delta".to_string(), 120.0),
    ]);
    strip_docs_gate_evidence(&mut request);

    let decision = evaluate_acp_enforce(&fixture_path("policy.yml"), &request)
        .expect("acp enforce should evaluate");
    assert!(matches!(decision.decision, AcpDecisionKind::StageOnly));
    assert!(decision
        .reason_codes
        .contains(&"ACP_DOCS_EVIDENCE_MISSING".to_string()));
    assert!(decision
        .reason_codes
        .contains(&"ACP_STAGE_ONLY_REQUIRED".to_string()));
}

#[test]
fn acp_docs_gate_missing_denies_for_acp2() {
    let mut request = acp2_complete_request();
    strip_docs_gate_evidence(&mut request);

    let decision = evaluate_acp_enforce(&fixture_path("policy.yml"), &request)
        .expect("acp enforce should evaluate");
    assert!(matches!(decision.decision, AcpDecisionKind::Deny));
    assert!(decision
        .reason_codes
        .contains(&"ACP_DOCS_EVIDENCE_MISSING".to_string()));
}

#[test]
fn acp_owner_attestation_missing_stage_only_with_retry_metadata() {
    let mut request = acp2_complete_request();
    request
        .operation
        .target
        .insert("boundary_exception".to_string(), json!(true));

    let decision = evaluate_acp_enforce(&fixture_path("policy.yml"), &request)
        .expect("acp enforce should evaluate");

    assert!(matches!(decision.decision, AcpDecisionKind::StageOnly));
    assert!(decision
        .reason_codes
        .contains(&"ACP_OWNER_ATTESTATION_MISSING".to_string()));

    let owner_req = decision
        .requirements
        .owner_attestation
        .expect("owner attestation requirements should be captured");
    assert!(owner_req.required);
    assert!(!owner_req.exhausted);
    assert_eq!(owner_req.retry_max_attempts, 3);
}

#[test]
fn acp_owner_attestation_exhausted_escalates_when_configured() {
    let mut request = acp2_complete_request();
    request
        .operation
        .target
        .insert("boundary_exception".to_string(), json!(true));
    request
        .operation
        .target
        .insert("owner_attestation_retry".to_string(), json!(3));
    request
        .operation
        .target
        .insert("owner_attestation_elapsed_seconds".to_string(), json!(1200));

    let decision = evaluate_acp_enforce(&fixture_path("policy.yml"), &request)
        .expect("acp enforce should evaluate");
    assert!(matches!(decision.decision, AcpDecisionKind::Escalate));
    assert!(decision
        .reason_codes
        .contains(&"ACP_OWNER_ATTESTATION_TIMEOUT".to_string()));
    assert!(decision
        .reason_codes
        .contains(&"ACP_ESCALATE_POLICY".to_string()));
}
