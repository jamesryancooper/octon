use crate::context_pack::LifecycleContextPackBinding;
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
    context_evidence_binding: BTreeMap<String, String>,
    replay_idempotency_proof: BTreeMap<String, String>,
    expected_receipts: Vec<String>,
    interaction_context: BTreeMap<String, String>,
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
    context_binding: &LifecycleContextPackBinding,
) -> Result<PathBuf, LifecycleRouteExecutionResult> {
    match build_and_write_proof(repo_root, request, &receipts, context_binding) {
        Ok(path) => Ok(path),
        Err(error) => {
            let result =
                blocked_result(repo_root, request, manifest_status_before, receipts, error)
                    .unwrap_or_else(|fallback| fallback);
            Err(result)
        }
    }
}

fn build_and_write_proof(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
    receipts: &[ReceiptObservation],
    context_binding: &LifecycleContextPackBinding,
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
    validate_context_binding(context_binding)?;
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
        context_evidence_binding: context_binding.proof_fields(),
        replay_idempotency_proof: replay,
        expected_receipts: request.expected_receipts.clone(),
        interaction_context: interaction_context(request),
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
    materialize_lifecycle_rollback_posture(repo_root, request, &proof_path)?;
    Ok(proof_path)
}

/// Materializes the rollback prerequisite owned by consequential lifecycle
/// dispatch. This is derived only after delegation, evidence, context, and
/// write-scope gates pass; callers cannot supply its contents.
fn materialize_lifecycle_rollback_posture(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
    proof_path: &Path,
) -> Result<(), LifecycleExecutionError> {
    if request.route.route_id != "run-packet-implementation" {
        return Ok(());
    }
    let run_root = repo_root
        .join(".octon/state/control/execution/runs")
        .join(&request.run_id);
    let path = run_root.join("rollback-posture.yml");
    let proof_ref = proof_path
        .strip_prefix(repo_root)
        .map_err(|error| {
            LifecycleExecutionError::new(
                LifecycleErrorClass::AuthorizationProofFailed,
                format!("delegation proof is outside repository root: {error}"),
            )
        })?
        .to_string_lossy()
        .replace('\\', "/");
    let rollback_plan = [
        request.target.join("architecture/rollback-plan.md"),
        request.target.join("architecture/implementation-plan.md"),
    ]
    .into_iter()
    .find(|candidate| {
        candidate.is_file()
            && fs::read_to_string(candidate)
                .map(|body| body.to_ascii_lowercase().contains("## rollback"))
                .unwrap_or(false)
    })
    .ok_or_else(|| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            "packet implementation requires a canonical architecture rollback plan or an explicit rollback section in architecture/implementation-plan.md before run admission",
        )
    })?;
    let rollback_ref = rollback_plan
        .strip_prefix(repo_root)
        .map_err(|error| {
            LifecycleExecutionError::new(
                LifecycleErrorClass::AuthorizationProofFailed,
                format!("packet rollback plan is outside repository root: {error}"),
            )
        })?
        .to_string_lossy()
        .replace('\\', "/");
    let posture = serde_json::json!({
        "schema_version": "run-rollback-posture-v1",
        "run_id": request.run_id,
        "reversibility_class": "reversible",
        "rollback_strategy": "checkpoint_restore",
        "rollback_ref": rollback_ref,
        "rollback_handle": null,
        "compensation_handle": null,
        "recovery_window": null,
        "contamination_state": "clean",
        "retry_record_ref": proof_ref,
        "contamination_record_ref": proof_ref,
        "resume_allowed": true,
        "reset_action": "Restore the pre-route lifecycle checkpoint and revert only the digest-bound authorized write scope.",
        "invalidated_artifacts": [],
        "hard_reset_required": false,
        "posture_source": "lifecycle-delegation-proof",
        "updated_at": now_rfc3339(),
    });
    if path.exists() {
        let existing: serde_yaml::Value =
            serde_yaml::from_slice(&fs::read(&path).map_err(|error| {
                LifecycleExecutionError::new(
                    LifecycleErrorClass::AuthorizationProofFailed,
                    format!("cannot read rollback posture: {error}"),
                )
            })?)
            .map_err(|error| {
                LifecycleExecutionError::new(
                    LifecycleErrorClass::AuthorizationProofFailed,
                    format!("cannot parse rollback posture: {error}"),
                )
            })?;
        if existing.get("run_id").and_then(serde_yaml::Value::as_str)
            != Some(request.run_id.as_str())
            || existing
                .get("posture_source")
                .and_then(serde_yaml::Value::as_str)
                != Some("lifecycle-delegation-proof")
            || existing
                .get("resume_allowed")
                .and_then(serde_yaml::Value::as_bool)
                != Some(true)
            || existing
                .get("hard_reset_required")
                .and_then(serde_yaml::Value::as_bool)
                != Some(false)
        {
            return Err(LifecycleExecutionError::new(
                LifecycleErrorClass::AuthorizationProofFailed,
                "conflicting existing lifecycle rollback posture",
            ));
        }
        return Ok(());
    }
    fs::create_dir_all(&run_root).map_err(|error| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            format!("cannot create lifecycle run root: {error}"),
        )
    })?;
    fs::write(
        &path,
        serde_yaml::to_string(&posture).map_err(|error| {
            LifecycleExecutionError::new(
                LifecycleErrorClass::AuthorizationProofFailed,
                format!("cannot serialize rollback posture: {error}"),
            )
        })?,
    )
    .map_err(|error| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            format!("cannot write rollback posture: {error}"),
        )
    })?;
    Ok(())
}

pub fn blocked_result(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
    manifest_status_before: Option<String>,
    receipts: Vec<ReceiptObservation>,
    error: LifecycleExecutionError,
) -> Result<LifecycleRouteExecutionResult, LifecycleRouteExecutionResult> {
    authorization_blocked_result(repo_root, request, manifest_status_before, receipts, error)
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

fn validate_context_binding(
    binding: &LifecycleContextPackBinding,
) -> Result<(), LifecycleExecutionError> {
    if binding.verification_status != "valid" {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            format!(
                "context pack verification status is not valid: {}",
                binding.verification_status
            ),
        ));
    }
    for (label, value) in [
        ("context_pack_ref", binding.context_pack_ref.as_str()),
        (
            "context_pack_receipt_ref",
            binding.context_pack_receipt_ref.as_str(),
        ),
        (
            "model_visible_context_ref",
            binding.model_visible_context_ref.as_str(),
        ),
        ("context_pack_sha256", binding.context_pack_sha256.as_str()),
        (
            "model_visible_context_sha256",
            binding.model_visible_context_sha256.as_str(),
        ),
    ] {
        if value.trim().is_empty() {
            return Err(LifecycleExecutionError::new(
                LifecycleErrorClass::AuthorizationProofFailed,
                format!("context evidence binding is missing {label}"),
            ));
        }
    }
    if binding.context_policy_ref != ".octon/instance/governance/policies/context-packing.yml" {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            "context evidence binding does not use the active context packing policy",
        ));
    }
    if binding.builder_version != "context-pack-builder-v1" {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            "context evidence binding does not use Context Pack Builder v1",
        ));
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
    scope.extend(authorized_promotion_targets(request)?);
    if scope.is_empty() {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            "declared write scope is empty",
        ));
    }
    Ok(scope)
}

/// Resolves the only proposal-owned scope expansion used by implementation routes.
/// Both retained delegation evidence and executor workspace exposure consume this
/// function so the effective write boundary cannot drift between them.
pub(crate) fn authorized_promotion_targets(
    request: &LifecycleRouteExecutionRequest,
) -> Result<Vec<String>, LifecycleExecutionError> {
    let enabled = request
        .route
        .delegation_contract
        .as_ref()
        .map(|contract| {
            contract.declared_write_scope_source == "route-completion-target-and-promotion-targets"
        })
        .unwrap_or(false);
    if !enabled {
        return Ok(Vec::new());
    }
    if request.route.route_id != "run-packet-implementation" {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            "promotion-target scope source is only valid for packet implementation",
        ));
    }
    let manifest_path = request.target.join(&request.manifest_path);
    let bytes = fs::read(&manifest_path).map_err(|error| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            format!("cannot read proposal manifest for scope binding: {error}"),
        )
    })?;
    let manifest: serde_yaml::Value = serde_yaml::from_slice(&bytes).map_err(|error| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            format!("cannot parse proposal manifest for scope binding: {error}"),
        )
    })?;
    let targets = manifest
        .get("promotion_targets")
        .and_then(serde_yaml::Value::as_sequence)
        .ok_or_else(|| {
            LifecycleExecutionError::new(
                LifecycleErrorClass::AuthorizationProofFailed,
                "proposal manifest has no promotion_targets sequence",
            )
        })?;
    let mut result = Vec::new();
    for value in targets {
        let raw = value.as_str().ok_or_else(|| {
            LifecycleExecutionError::new(
                LifecycleErrorClass::AuthorizationProofFailed,
                "promotion target must be a string",
            )
        })?;
        let path = Path::new(raw);
        if path.is_absolute()
            || path.components().any(|component| {
                matches!(
                    component,
                    std::path::Component::ParentDir
                        | std::path::Component::RootDir
                        | std::path::Component::Prefix(_)
                )
            })
        {
            return Err(LifecycleExecutionError::new(
                LifecycleErrorClass::AuthorizationProofFailed,
                format!("promotion target escapes the repo write boundary: {raw}"),
            ));
        }
        result.push(raw.to_string());
    }
    result.sort();
    result.dedup();
    Ok(result)
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
    if !request.interaction_request_refs.is_empty() || !request.interaction_return_refs.is_empty() {
        provenance.push("interaction_context:non-authorizing".to_string());
    }
    provenance
}

fn interaction_context(request: &LifecycleRouteExecutionRequest) -> BTreeMap<String, String> {
    let mut context = BTreeMap::new();
    context.insert(
        "authority".to_string(),
        "non-authorizing-context".to_string(),
    );
    context.insert("target_gates_required".to_string(), "true".to_string());
    context.insert(
        "request_refs".to_string(),
        request.interaction_request_refs.join(","),
    );
    context.insert(
        "return_refs".to_string(),
        request.interaction_return_refs.join(","),
    );
    context
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

#[cfg(test)]
mod tests {
    use super::*;
    use crate::request::{
        LifecycleExecutionPolicy, LifecycleInvocationAuthority, LifecycleRouteSpec,
    };
    use std::time::{SystemTime, UNIX_EPOCH};

    fn temp_root(name: &str) -> PathBuf {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_nanos();
        let root = std::env::temp_dir().join(format!(
            "octon-lifecycle-authorization-{name}-{}-{nanos}",
            std::process::id()
        ));
        fs::create_dir_all(&root).unwrap();
        root
    }

    fn request_with_interaction_context(root: &Path) -> LifecycleRouteExecutionRequest {
        LifecycleRouteExecutionRequest {
            schema_version: "octon-lifecycle-route-execution-request-v1".to_string(),
            run_id: "run-1".to_string(),
            lifecycle_id: "proposal-packet".to_string(),
            owner_extension: "test-extension".to_string(),
            phase_id: Some("archival".to_string()),
            target: root.join("packet"),
            manifest_path: "proposal.yml".to_string(),
            status_field: "status".to_string(),
            executor: "mock".to_string(),
            route: LifecycleRouteSpec {
                route_id: "archive-proposal".to_string(),
                route_type: "workflow".to_string(),
                command_id: None,
                skill_id: None,
                prompt_set_id: None,
                required_inputs: Vec::new(),
                completion_replan_required: true,
                delegation_contract: Some(LifecycleDelegationContract {
                    decision_class: "delegated-execution".to_string(),
                    safe_delegation: true,
                    authority_zones_allowed: vec!["workspace-declared".to_string()],
                    declared_write_scope_source: "route-completion-and-target".to_string(),
                    required_evidence_gates: Vec::new(),
                    required_receipts_before_dispatch: vec!["proposal-closeout".to_string()],
                    required_receipts_before_completion: vec!["proposal-closeout".to_string()],
                    replay_class: "no-op-safe".to_string(),
                    automated_recovery_policy: "fail-closed".to_string(),
                    human_only_boundaries: vec!["scope-expansion".to_string()],
                }),
            },
            effective_extension_catalog: root
                .join(".octon/generated/effective/extensions/catalog.effective.yml"),
            runtime_route_bundle: root.join(".octon/generated/effective/runtime/route-bundle.yml"),
            bound_inputs: BTreeMap::new(),
            receipts: Vec::new(),
            expected_receipts: vec!["proposal-closeout".to_string()],
            expected_paths: Vec::new(),
            expected_manifest_status: Some("archived".to_string()),
            expected_target_change: true,
            evidence_root: root.join(".octon/state/evidence/runs/workflows/run-1"),
            checkpoint_path: root
                .join(".octon/state/control/execution/runs/run-1/lifecycle-checkpoint.yml"),
            interaction_request_refs: vec![
                ".octon/state/evidence/runs/workflows/run-0/interaction-request.json".to_string(),
            ],
            interaction_return_refs: Vec::new(),
            policy: LifecycleExecutionPolicy {
                timeout_seconds: 30,
                cancellation_token: None,
                retry_attempt: 0,
                invocation_authority: LifecycleInvocationAuthority {
                    mode: "unattended".to_string(),
                    provenance: "test".to_string(),
                    authority_ref: None,
                },
            },
            human_boundary_context: None,
            evidence_gate_results: BTreeMap::new(),
        }
    }

    #[test]
    fn interaction_context_cannot_satisfy_required_dispatch_receipts() {
        let root = temp_root("interaction-context-no-authority");
        fs::create_dir_all(root.join("packet")).unwrap();
        fs::write(root.join("packet/proposal.yml"), "status: implemented\n").unwrap();
        let request = request_with_interaction_context(&root);
        let context_binding = LifecycleContextPackBinding {
            context_pack_ref: ".octon/state/evidence/runs/run-1/context/context-pack.json"
                .to_string(),
            context_pack_receipt_ref:
                ".octon/state/evidence/runs/run-1/context/context-pack-receipt.json".to_string(),
            context_pack_sha256:
                "sha256:1111111111111111111111111111111111111111111111111111111111111111"
                    .to_string(),
            context_pack_receipt_sha256:
                "sha256:2222222222222222222222222222222222222222222222222222222222222222"
                    .to_string(),
            model_visible_context_ref:
                ".octon/state/evidence/runs/run-1/context/model-visible-context.json".to_string(),
            model_visible_context_sha256:
                "sha256:3333333333333333333333333333333333333333333333333333333333333333"
                    .to_string(),
            source_manifest_ref: ".octon/state/evidence/runs/run-1/context/source-manifest.json"
                .to_string(),
            omissions_ref: ".octon/state/evidence/runs/run-1/context/omissions.json".to_string(),
            redactions_ref: ".octon/state/evidence/runs/run-1/context/redactions.json".to_string(),
            invalidation_events_ref:
                ".octon/state/evidence/runs/run-1/context/invalidation-events.json".to_string(),
            context_policy_ref: ".octon/instance/governance/policies/context-packing.yml"
                .to_string(),
            builder_spec_ref: ".octon/framework/engine/runtime/spec/context-pack-builder-v1.md"
                .to_string(),
            builder_version: "context-pack-builder-v1".to_string(),
            verification_status: "valid".to_string(),
            evidence_paths: Vec::new(),
        };

        let result = authorize_before_dispatch(
            &root,
            &request,
            Some("implemented".to_string()),
            Vec::new(),
            &context_binding,
        );

        assert!(result.is_err());
        let blocked = result.err().unwrap();
        assert_eq!(blocked.status, "authorization-proof-failed");
        assert!(blocked
            .error_message
            .as_deref()
            .unwrap_or_default()
            .contains("required receipt proposal-closeout"));
        let _ = fs::remove_dir_all(root);
    }
}
