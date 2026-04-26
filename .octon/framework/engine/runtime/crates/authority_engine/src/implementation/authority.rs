use super::*;
use octon_core::config::RuntimeConfig;
use octon_core::errors::{ErrorCode, KernelError, Result as CoreResult};
use octon_core::execution_integrity::BudgetDecision;
use serde_json::json;
use std::collections::BTreeMap;
use std::fs;
use std::path::Path;

pub(crate) fn review_metadata_from_env() -> BTreeMap<String, String> {
    let mut review_metadata = BTreeMap::new();
    if let Ok(value) = std::env::var("OCTON_EXECUTION_QUORUM_TOKEN") {
        if !value.trim().is_empty() {
            review_metadata.insert("quorum_token".to_string(), value);
        }
    }
    if let Ok(value) = std::env::var("OCTON_EXECUTION_ROLLBACK_REF") {
        if !value.trim().is_empty() {
            review_metadata.insert("rollback_ref".to_string(), value);
        }
    }
    review_metadata
}

pub(crate) fn approval_projection_sources(request: &ExecutionRequest) -> Vec<AuthorityProjection> {
    let mut projections = Vec::new();
    for key in [
        "approval_projection_label",
        "approval_projection_comment",
        "approval_projection_check",
    ] {
        if let Some(value) = request.metadata.get(key) {
            projections.push(AuthorityProjection {
                kind: key.replace("approval_projection_", "host-"),
                ref_id: value.clone(),
                notes: Some("Host projection recorded for traceability only.".to_string()),
            });
        }
    }
    projections
}

pub fn with_authority_env_metadata(
    mut metadata: BTreeMap<String, String>,
) -> BTreeMap<String, String> {
    for (env_key, meta_key) in [
        ("OCTON_SUPPORT_TIER", "support_tier"),
        ("OCTON_SUPPORT_HOST_ADAPTER", "support_host_adapter"),
        ("OCTON_SUPPORT_MODEL_ADAPTER", "support_model_adapter"),
        ("OCTON_SUPPORT_MODEL_TIER", "support_model_tier"),
        (
            "OCTON_SUPPORT_LANGUAGE_RESOURCE_TIER",
            "support_language_resource_tier",
        ),
        ("OCTON_SUPPORT_LOCALE_TIER", "support_locale_tier"),
        (
            "OCTON_APPROVAL_PROJECTION_LABEL",
            "approval_projection_label",
        ),
        (
            "OCTON_APPROVAL_PROJECTION_COMMENT",
            "approval_projection_comment",
        ),
        (
            "OCTON_APPROVAL_PROJECTION_CHECK",
            "approval_projection_check",
        ),
    ] {
        if !metadata.contains_key(meta_key) {
            if let Ok(value) = std::env::var(env_key) {
                if !value.trim().is_empty() {
                    metadata.insert(meta_key.to_string(), value);
                }
            }
        }
    }
    metadata
}

pub(crate) fn write_approval_request(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    run_contract: &RunContractRecord,
    ownership: &OwnershipPosture,
    required_evidence: Vec<String>,
    reason_codes: Vec<String>,
) -> CoreResult<String> {
    let now = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute approval timestamp: {e}"),
        )
    })?;
    let artifact = ApprovalRequestArtifact {
        schema_version: "authority-approval-request-v1".to_string(),
        request_id: request.request_id.clone(),
        run_id: request.request_id.clone(),
        status: "pending".to_string(),
        target_id: request.target_id.clone(),
        action_type: request.action_type.clone(),
        workflow_mode: request.workflow_mode.clone(),
        support_tier: run_contract.support_tier.clone(),
        quorum_policy_ref: Some(canonical_quorum_policy_ref().to_string()),
        ownership_refs: ownership.owner_refs.clone(),
        reversibility_class: Some(run_contract.reversibility_class.clone()),
        reason_codes,
        required_evidence,
        projection_sources: approval_projection_sources(request),
        created_at: now.clone(),
        updated_at: now,
    };
    let path = approval_request_path(cfg, &request.request_id);
    write_yaml(&path, &artifact).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write approval request artifact {}: {e}",
                path.display()
            ),
        )
    })?;
    Ok(path_tail(&cfg.repo_root, &path))
}

pub(crate) fn load_existing_approval_grants(
    cfg: &RuntimeConfig,
    request_id: &str,
) -> CoreResult<Vec<(ApprovalGrantArtifact, String)>> {
    let path = approval_grant_path(cfg, request_id);
    if !path.is_file() {
        return Ok(Vec::new());
    }
    let grant: ApprovalGrantArtifact = read_yaml_file(&path)?;
    if grant.state != "active" {
        return Ok(Vec::new());
    }
    Ok(vec![(grant, path_tail(&cfg.repo_root, &path))])
}

pub(crate) fn load_active_revocation_refs(
    cfg: &RuntimeConfig,
    request_id: &str,
    grant_id: &str,
) -> CoreResult<Vec<String>> {
    let canonical_dir = revocation_directory_path(cfg);
    if canonical_dir.is_dir() {
        let mut refs = Vec::new();
        for entry in fs::read_dir(&canonical_dir).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!(
                    "failed to read canonical revocation dir {}: {e}",
                    canonical_dir.display()
                ),
            )
        })? {
            let entry = entry.map_err(|e| {
                KernelError::new(
                    ErrorCode::Internal,
                    format!("failed to read canonical revocation entry: {e}"),
                )
            })?;
            let path = entry.path();
            if path.extension().and_then(|value| value.to_str()) != Some("yml") {
                continue;
            }
            if path.file_name().and_then(|value| value.to_str()) == Some("grants.yml") {
                continue;
            }
            let revocation: RevocationArtifact = read_yaml_file(&path)?;
            if revocation.state == "active"
                && (revocation.request_id.as_deref() == Some(request_id)
                    || revocation.grant_id.as_deref() == Some(grant_id))
            {
                refs.push(path_tail(&cfg.repo_root, &path));
            }
        }
        if !refs.is_empty() {
            return Ok(refs);
        }
    }

    let path = revocation_registry_path(cfg);
    let registry: RevocationRegistry = read_yaml_or_default(&path)?;
    Ok(registry
        .revocations
        .into_iter()
        .filter(|revocation| {
            revocation.state == "active"
                && (revocation.request_id.as_deref() == Some(request_id)
                    || revocation.grant_id.as_deref() == Some(grant_id))
        })
        .map(|revocation| {
            format!(
                "{}#{}",
                path_tail(&cfg.repo_root, &path),
                revocation.revocation_id
            )
        })
        .collect())
}

pub(crate) fn budget_posture_from_preview(
    repo_root: &Path,
    run_root: &Path,
    decision: Option<&BudgetDecision>,
) -> serde_json::Value {
    match decision {
        Some(BudgetDecision::Allow {
            rule_id,
            reason_codes,
            evidence,
        }) => json!({
            "route": "allow",
            "rule_id": rule_id,
            "reason_codes": reason_codes,
            "estimated_cost_usd": evidence.estimated_cost_usd,
            "evidence_path": path_tail(repo_root, &run_root.join("cost.json")),
        }),
        Some(BudgetDecision::StageOnly {
            rule_id,
            reason_codes,
            evidence,
            ..
        }) => json!({
            "route": "stage_only",
            "rule_id": rule_id,
            "reason_codes": reason_codes,
            "estimated_cost_usd": evidence.estimated_cost_usd,
            "evidence_path": path_tail(repo_root, &run_root.join("cost.json")),
        }),
        Some(BudgetDecision::Deny {
            rule_id,
            reason_codes,
            evidence,
            ..
        }) => json!({
            "route": "deny",
            "rule_id": rule_id,
            "reason_codes": reason_codes,
            "estimated_cost_usd": evidence.estimated_cost_usd,
            "evidence_path": path_tail(repo_root, &run_root.join("cost.json")),
        }),
        _ => json!({"route": "not-applicable"}),
    }
}

pub(crate) fn reversibility_payload(
    request: &ExecutionRequest,
    run_contract: &RunContractRecord,
    autonomy_state: Option<&ResolvedAutonomyState>,
) -> serde_json::Value {
    json!({
        "requested": run_contract.reversibility_class,
        "effective": autonomy_state
            .map(|state| state.context.reversibility_class.clone())
            .unwrap_or_else(|| run_contract.reversibility_class.clone()),
        "rollback_ref_present": std::env::var("OCTON_EXECUTION_ROLLBACK_REF")
            .map(|value| !value.trim().is_empty())
            .unwrap_or(false),
        "workflow_mode": request.workflow_mode,
    })
}

pub(crate) fn write_decision_artifact(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    decision: ExecutionDecision,
    reason_codes: Vec<String>,
    ownership: OwnershipPosture,
    support_tier: SupportTierPosture,
    reversibility: serde_json::Value,
    budget: serde_json::Value,
    egress: serde_json::Value,
    approval_request_ref: Option<String>,
    approval_grant_refs: Vec<String>,
    exception_refs: Vec<String>,
    revocation_refs: Vec<String>,
) -> CoreResult<String> {
    let generated_at = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute decision timestamp: {e}"),
        )
    })?;
    let artifact = DecisionArtifact {
        schema_version: "authority-decision-artifact-v1".to_string(),
        decision_id: format!("decision-{}", request.request_id),
        request_id: request.request_id.clone(),
        run_id: request.request_id.clone(),
        decision,
        reason_codes,
        ownership,
        support_tier,
        reversibility,
        budget,
        egress,
        approval_request_ref,
        approval_grant_refs,
        exception_refs,
        revocation_refs,
        generated_at,
    };
    let path = decision_artifact_path(cfg, &request.request_id);
    write_yaml(&path, &artifact).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write decision artifact {}: {e}", path.display()),
        )
    })?;
    Ok(path_tail(&cfg.repo_root, &path))
}

pub(crate) fn write_authority_grant_bundle(
    cfg: &RuntimeConfig,
    grant: &GrantBundle,
) -> CoreResult<String> {
    let path = authority_grant_bundle_path(cfg, &grant.request_id);
    write_yaml(
        &path,
        &json!({
            "schema_version": "authority-grant-bundle-v1",
            "grant_id": grant.grant_id,
            "request_id": grant.request_id,
            "run_id": grant.request_id,
            "workflow_mode": grant.workflow_mode,
            "support_tier": grant.support_tier,
            "support_target": grant.support_posture.as_ref().map(|posture| json!({
                "model_tier": posture.model_tier_id,
                "workload_tier": posture.workload_tier_id,
                "language_resource_tier": posture.language_resource_tier_id,
                "locale_tier": posture.locale_tier_id,
                "host_adapter": posture.host_adapter_id,
                "model_adapter": posture.model_adapter_id,
                "support_status": posture.support_status,
                "route": posture.route,
            })),
            "requested_capability_packs": grant
                .support_posture
                .as_ref()
                .map(|posture| posture.requested_capability_packs.clone())
                .unwrap_or_default(),
            "quorum_policy_ref": grant.quorum_policy_ref,
            "approval_request_ref": grant.approval_request_ref,
            "approval_grant_refs": grant.approval_grant_refs,
            "exception_refs": grant.exception_lease_refs,
            "revocation_refs": grant.revocation_refs,
            "decision_artifact_ref": grant.decision_artifact_ref,
            "route_id": grant.route_id,
            "runtime_effective_route_bundle_ref": grant.runtime_effective_route_bundle_ref,
            "runtime_effective_route_bundle_sha256": grant.runtime_effective_route_bundle_sha256,
            "runtime_effective_route_generation_id": grant.runtime_effective_route_generation_id,
            "runtime_effective_freshness_mode": grant.runtime_effective_freshness_mode,
            "runtime_effective_publication_receipt_ref": grant.runtime_effective_publication_receipt_ref,
            "runtime_effective_non_authority_classification": grant.runtime_effective_non_authority_classification,
            "runtime_effective_claim_effect": grant.runtime_effective_claim_effect,
            "runtime_effective_extensions_status": grant.runtime_effective_extensions_status,
            "runtime_effective_extensions_generation_id": grant.runtime_effective_extensions_generation_id,
            "rollback_posture_ref": grant.rollback_posture_ref,
            "network_egress_posture": grant.network_egress_posture,
            "generated_at": time::OffsetDateTime::now_utc()
                .format(&time::format_description::well_known::Rfc3339)
                .unwrap_or_else(|_| "1970-01-01T00:00:00Z".to_string()),
        }),
    )
    .map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write authority grant bundle {}: {e}",
                path.display()
            ),
        )
    })?;
    Ok(path_tail(&cfg.repo_root, &path))
}
