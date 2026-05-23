use crate::errors::{LifecycleErrorClass, LifecycleExecutionError};
use crate::observer;
use crate::request::{LifecycleDelegationContract, LifecycleRouteExecutionRequest};
use crate::result::{LifecycleRouteExecutionResult, ReceiptObservation};
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};
use time::OffsetDateTime;

const DELEGATED_EXECUTION: &str = "delegated-execution";
const NEW_GOVERNANCE_DECISION: &str = "new-governance-decision";

#[derive(Clone, Debug, Serialize, Deserialize)]
struct DelegationProof {
    schema_version: String,
    run_id: String,
    lifecycle_id: String,
    route_id: String,
    contract_opt_in: bool,
    invocation_authority: BTreeMap<String, String>,
    target: String,
    declared_write_scope: Vec<String>,
    declared_write_scope_source: String,
    authority_zone_decision: BTreeMap<String, String>,
    evidence_gate_results: BTreeMap<String, String>,
    replay_idempotency_proof: BTreeMap<String, String>,
    expected_receipts: Vec<String>,
    required_receipts_before_dispatch: BTreeMap<String, String>,
    failure_policy: String,
    authority_provenance: Vec<String>,
    recorded_at: String,
}

pub fn authorize_before_dispatch(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
    manifest_status_before: Option<String>,
    receipts: Vec<ReceiptObservation>,
) -> Result<PathBuf, LifecycleRouteExecutionResult> {
    match build_and_write_proof(repo_root, request, &receipts) {
        Ok(path) => Ok(path),
        Err(error) => {
            let result = authorization_blocked_result(
                repo_root,
                request,
                manifest_status_before,
                receipts,
                error,
            )
            .unwrap_or_else(|fallback| fallback);
            Err(result)
        }
    }
}

fn build_and_write_proof(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
    receipts: &[ReceiptObservation],
) -> Result<PathBuf, LifecycleExecutionError> {
    let contract = request.route.delegation_contract.as_ref().ok_or_else(|| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            "route lacks delegation_contract",
        )
    })?;
    validate_invocation(request)?;
    let grant_consumption = request.policy.invocation_authority.mode == "grant-consumption";
    validate_contract(contract, grant_consumption)?;
    validate_evidence_gates(request, contract)?;
    let required_receipts = validate_required_receipts(receipts, contract)?;
    let declared_scope = declared_write_scope(request)?;
    let proof_root = repo_root
        .join(".octon/state/evidence/runs")
        .join(&request.run_id)
        .join("authorization");
    fs::create_dir_all(&proof_root)?;
    let proof_path = proof_root.join(format!(
        "{}-delegation-proof.yml",
        sanitize_route_id(&request.route.route_id)?
    ));
    let mut invocation = BTreeMap::new();
    invocation.insert(
        "mode".to_string(),
        request.policy.invocation_authority.mode.clone(),
    );
    invocation.insert(
        "provenance".to_string(),
        request.policy.invocation_authority.provenance.clone(),
    );
    if let Some(authority_ref) = request.policy.invocation_authority.authority_ref.as_ref() {
        invocation.insert("authority_ref".to_string(), authority_ref.clone());
    }
    let mut authority_zone_decision = BTreeMap::new();
    authority_zone_decision.insert("status".to_string(), "allowed-by-contract".to_string());
    authority_zone_decision.insert(
        "allowed_zones".to_string(),
        contract.authority_zones_allowed.join(","),
    );
    authority_zone_decision.insert(
        "generated_outputs_are_authority".to_string(),
        "false".to_string(),
    );
    let mut replay = BTreeMap::new();
    replay.insert("replay_class".to_string(), contract.replay_class.clone());
    replay.insert("dispatch_safe".to_string(), "true".to_string());
    replay.insert(
        "basis".to_string(),
        if grant_consumption && !replay_class_dispatch_safe(&contract.replay_class) {
            "typed human exception grant accepts non-machine replay boundary".to_string()
        } else {
            "delegation_contract.replay_class is dispatch-safe".to_string()
        },
    );
    let proof = DelegationProof {
        schema_version: "octon-lifecycle-route-delegation-proof-v1".to_string(),
        run_id: request.run_id.clone(),
        lifecycle_id: request.lifecycle_id.clone(),
        route_id: request.route.route_id.clone(),
        contract_opt_in: grant_consumption
            || (contract.safe_delegation && contract.decision_class == DELEGATED_EXECUTION),
        invocation_authority: invocation,
        target: request.target.display().to_string(),
        declared_write_scope: declared_scope,
        declared_write_scope_source: contract.declared_write_scope_source.clone(),
        authority_zone_decision,
        evidence_gate_results: request.evidence_gate_results.clone(),
        replay_idempotency_proof: replay,
        expected_receipts: request.expected_receipts.clone(),
        required_receipts_before_dispatch: required_receipts,
        failure_policy: fail_closed_policy(contract),
        authority_provenance: authority_provenance(request, contract),
        recorded_at: now_rfc3339(),
    };
    fs::write(&proof_path, serde_yaml::to_string(&proof)?)?;
    let retained: DelegationProof = serde_yaml::from_slice(&fs::read(&proof_path)?)?;
    if retained.run_id != request.run_id || retained.route_id != request.route.route_id {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            "retained delegation proof did not round-trip for this route",
        ));
    }
    Ok(proof_path)
}

fn validate_contract(
    contract: &LifecycleDelegationContract,
    grant_consumption: bool,
) -> Result<(), LifecycleExecutionError> {
    if !grant_consumption
        && (contract.decision_class == NEW_GOVERNANCE_DECISION || !contract.safe_delegation)
    {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::HumanBoundaryRequired,
            "route delegation_contract marks this route as human-only or not safe for delegation",
        ));
    }
    if contract.decision_class != DELEGATED_EXECUTION
        && !(grant_consumption && contract.decision_class == NEW_GOVERNANCE_DECISION)
    {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            format!(
                "unsupported delegation decision_class: {}",
                contract.decision_class
            ),
        ));
    }
    if contract.authority_zones_allowed.is_empty() {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            "delegation_contract.authority_zones_allowed is empty",
        ));
    }
    if contract.declared_write_scope_source.trim().is_empty() {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            "delegation_contract.declared_write_scope_source is empty",
        ));
    }
    if !grant_consumption && !replay_class_dispatch_safe(&contract.replay_class) {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::HumanBoundaryRequired,
            format!(
                "route replay_class is not machine-dispatch-safe: {}",
                contract.replay_class
            ),
        ));
    }
    if contract.automated_recovery_policy.trim().is_empty() {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            "delegation_contract.automated_recovery_policy is empty",
        ));
    }
    if contract.human_only_boundaries.is_empty() {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            "delegation_contract.human_only_boundaries is empty",
        ));
    }
    Ok(())
}

fn validate_invocation(
    request: &LifecycleRouteExecutionRequest,
) -> Result<(), LifecycleExecutionError> {
    match request.policy.invocation_authority.mode.as_str() {
        "unattended" | "grant-consumption" => Ok(()),
        other => Err(LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            format!("unsupported invocation_authority mode: {other}"),
        )),
    }
}

fn validate_evidence_gates(
    request: &LifecycleRouteExecutionRequest,
    contract: &LifecycleDelegationContract,
) -> Result<(), LifecycleExecutionError> {
    for gate in &contract.required_evidence_gates {
        match request.evidence_gate_results.get(gate).map(String::as_str) {
            Some("pass") => {}
            Some(other) => {
                return Err(LifecycleExecutionError::new(
                    LifecycleErrorClass::AuthorizationProofFailed,
                    format!("required evidence gate {gate} did not pass: {other}"),
                ));
            }
            None => {
                return Err(LifecycleExecutionError::new(
                    LifecycleErrorClass::AuthorizationProofFailed,
                    format!("required evidence gate {gate} missing from invocation proof"),
                ));
            }
        }
    }
    Ok(())
}

fn validate_required_receipts(
    receipts: &[ReceiptObservation],
    contract: &LifecycleDelegationContract,
) -> Result<BTreeMap<String, String>, LifecycleExecutionError> {
    let mut result = BTreeMap::new();
    for required in &contract.required_receipts_before_dispatch {
        let Some(receipt) = receipts
            .iter()
            .find(|receipt| receipt.receipt_id == *required)
        else {
            return Err(LifecycleExecutionError::new(
                LifecycleErrorClass::AuthorizationProofFailed,
                format!("required receipt {required} is not declared in request"),
            ));
        };
        if !receipt.exists || !receipt.complete {
            return Err(LifecycleExecutionError::new(
                LifecycleErrorClass::AuthorizationProofFailed,
                format!("required receipt {required} is missing or incomplete"),
            ));
        }
        result.insert(
            required.clone(),
            receipt
                .verdict
                .clone()
                .unwrap_or_else(|| "present".to_string()),
        );
    }
    Ok(result)
}

fn declared_write_scope(
    request: &LifecycleRouteExecutionRequest,
) -> Result<Vec<String>, LifecycleExecutionError> {
    let mut scope = Vec::new();
    scope.push(request.target.display().to_string());
    scope.extend(request.expected_paths.iter().cloned());
    scope.extend(
        request
            .expected_receipts
            .iter()
            .map(|receipt| format!("receipt:{receipt}")),
    );
    if scope.is_empty() {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            "declared write scope is empty",
        ));
    }
    Ok(scope)
}

fn authorization_blocked_result(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
    manifest_status_before: Option<String>,
    receipts: Vec<ReceiptObservation>,
    error: LifecycleExecutionError,
) -> Result<LifecycleRouteExecutionResult, LifecycleRouteExecutionResult> {
    let now = now_rfc3339();
    let proof_root = repo_root
        .join(".octon/state/evidence/runs")
        .join(&request.run_id)
        .join("authorization");
    let failure_path = proof_root.join(format!(
        "{}-delegation-proof-failed.yml",
        sanitize_route_id(&request.route.route_id).map_err(|_| fallback_result(
            request,
            manifest_status_before.clone(),
            receipts.clone(),
            &error
        ))?
    ));
    if fs::create_dir_all(&proof_root)
        .and_then(|_| {
            fs::write(
                &failure_path,
                format!(
                    "schema_version: octon-lifecycle-route-delegation-proof-failed-v1\nrun_id: {}\nlifecycle_id: {}\nroute_id: {}\nstatus: {}\nerror_class: {}\nmessage: {}\nrecorded_at: {}\n",
                    request.run_id,
                    request.lifecycle_id,
                    request.route.route_id,
                    if error.class == LifecycleErrorClass::HumanBoundaryRequired {
                        "human-boundary-blocked"
                    } else {
                        "authorization-proof-failed"
                    },
                    error.class.as_str(),
                    yaml_string(&error.message),
                    now,
                ),
            )
        })
        .is_err()
    {
        return Err(LifecycleRouteExecutionResult {
            schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
            run_id: request.run_id.clone(),
            route_id: request.route.route_id.clone(),
            phase_id: request.phase_id.clone(),
            executor_used: request.executor.clone(),
            status: "authorization-proof-failed".to_string(),
            started_at: now.clone(),
            ended_at: now,
            manifest_status_before,
            manifest_status_after: None,
            receipts_observed: receipts,
            evidence_paths: Vec::new(),
            stdout_path: None,
            stderr_path: None,
            prompt_packet_path: None,
            retryable: false,
            next_action: "manual-intervention".to_string(),
            error_class: Some(LifecycleErrorClass::AuthorizationProofFailed),
            error_message: Some(error.message),
        });
    }
    Ok(LifecycleRouteExecutionResult {
        schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
        run_id: request.run_id.clone(),
        route_id: request.route.route_id.clone(),
        phase_id: request.phase_id.clone(),
        executor_used: request.executor.clone(),
        status: if error.class == LifecycleErrorClass::HumanBoundaryRequired {
            "human-boundary-blocked".to_string()
        } else {
            "authorization-proof-failed".to_string()
        },
        started_at: now.clone(),
        ended_at: now,
        manifest_status_before: manifest_status_before.clone(),
        manifest_status_after: observer::manifest_status(
            &request.target,
            &request.manifest_path,
            &request.status_field,
        )
        .map_err(|_| fallback_result(request, manifest_status_before, receipts.clone(), &error))?,
        receipts_observed: receipts,
        evidence_paths: vec![failure_path],
        stdout_path: None,
        stderr_path: None,
        prompt_packet_path: None,
        retryable: false,
        next_action: "manual-intervention".to_string(),
        error_class: Some(error.class),
        error_message: Some(error.message),
    })
}

fn fallback_result(
    request: &LifecycleRouteExecutionRequest,
    manifest_status_before: Option<String>,
    receipts: Vec<ReceiptObservation>,
    error: &LifecycleExecutionError,
) -> LifecycleRouteExecutionResult {
    let now = now_rfc3339();
    LifecycleRouteExecutionResult {
        schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
        run_id: request.run_id.clone(),
        route_id: request.route.route_id.clone(),
        phase_id: request.phase_id.clone(),
        executor_used: request.executor.clone(),
        status: "authorization-proof-failed".to_string(),
        started_at: now.clone(),
        ended_at: now,
        manifest_status_before,
        manifest_status_after: None,
        receipts_observed: receipts,
        evidence_paths: Vec::new(),
        stdout_path: None,
        stderr_path: None,
        prompt_packet_path: None,
        retryable: false,
        next_action: "manual-intervention".to_string(),
        error_class: Some(LifecycleErrorClass::AuthorizationProofFailed),
        error_message: Some(error.message.clone()),
    }
}

fn replay_class_dispatch_safe(replay_class: &str) -> bool {
    matches!(
        replay_class,
        "inspect-only" | "idempotent" | "idempotent-rerun" | "bounded-retry" | "no-op-safe"
    )
}

fn fail_closed_policy(contract: &LifecycleDelegationContract) -> String {
    format!(
        "fail-closed; recovery={}; human_only_boundaries={}",
        contract.automated_recovery_policy,
        contract.human_only_boundaries.join(",")
    )
}

fn authority_provenance(
    request: &LifecycleRouteExecutionRequest,
    contract: &LifecycleDelegationContract,
) -> Vec<String> {
    let mut provenance = vec![
        "route.delegation_contract".to_string(),
        format!(
            "invocation_authority:{}",
            request.policy.invocation_authority.mode
        ),
        format!("decision_class:{}", contract.decision_class),
        format!("replay_class:{}", contract.replay_class),
    ];
    if let Some(authority_ref) = request.policy.invocation_authority.authority_ref.as_ref() {
        provenance.push(format!("authority_ref:{authority_ref}"));
    }
    provenance
}

fn sanitize_route_id(route_id: &str) -> Result<String, LifecycleExecutionError> {
    if route_id
        .chars()
        .all(|ch| ch.is_ascii_lowercase() || ch.is_ascii_digit() || ch == '-')
    {
        Ok(route_id.to_string())
    } else {
        Err(LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            format!("route id is not safe for proof path: {route_id}"),
        ))
    }
}

fn yaml_string(value: &str) -> String {
    serde_yaml::to_string(value)
        .map(|value| value.trim().to_string())
        .unwrap_or_else(|_| format!("{value:?}"))
}

pub fn now_rfc3339() -> String {
    OffsetDateTime::now_utc()
        .format(&time::format_description::well_known::Rfc3339)
        .unwrap_or_else(|_| "unknown".to_string())
}
