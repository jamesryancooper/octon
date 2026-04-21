use super::*;
use serde_json::json;
use std::collections::BTreeMap;

pub(crate) fn execution_request_payload(
    request: &ExecutionRequest,
    grant: &GrantBundle,
) -> serde_json::Value {
    json!({
        "schema_version": "execution-request-v3",
        "request": request,
        "resolved_intent_ref": grant.intent_ref,
        "resolved_execution_role_ref": grant.execution_role_ref,
        "resolved_autonomy_context": grant.autonomy_context.clone(),
        "context_pack_ref": request
            .context_pack_ref
            .clone()
            .unwrap_or_else(|| ".octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json".to_string()),
        "risk_materiality_ref": request
            .risk_materiality_ref
            .clone()
            .unwrap_or_else(|| ".octon/framework/constitution/contracts/authority/risk-materiality-v1.schema.json".to_string()),
        "support_target_tuple_ref": request
            .support_target_tuple_ref
            .clone()
            .unwrap_or_else(|| {
                grant
                    .run_control_root
                    .as_deref()
                    .map(|root| format!("{root}/run-manifest.yml#support_target"))
                    .unwrap_or_else(|| ".octon/state/control/execution/runs/unknown/run-manifest.yml#support_target".to_string())
            }),
        "rollback_plan_ref": request
            .rollback_plan_ref
            .clone()
            .unwrap_or_else(|| ".octon/framework/constitution/contracts/runtime/rollback-plan-v1.schema.json".to_string()),
        "browser_ui_execution_ref": request.browser_ui_execution_ref.clone(),
        "api_egress_ref": request.api_egress_ref.clone(),
    })
}

pub(crate) fn execution_receipt_payload(
    request: &ExecutionRequest,
    grant: &GrantBundle,
    started_at: &str,
    outcome: &ExecutionOutcome,
    side_effects: &SideEffectSummary,
    paths: &ExecutionArtifactPaths,
) -> ExecutionReceipt {
    let requested_capability_packs = grant
        .support_posture
        .as_ref()
        .map(|posture| posture.requested_capability_packs.clone())
        .unwrap_or_default();
    let granted_capability_packs = grant
        .support_posture
        .as_ref()
        .map(|posture| posture.allowed_capability_packs.clone())
        .unwrap_or_default();
    let browser_ui_record_refs = request
        .browser_ui_execution_ref
        .clone()
        .into_iter()
        .collect::<Vec<_>>();
    let api_egress_record_refs = request
        .api_egress_ref
        .clone()
        .into_iter()
        .collect::<Vec<_>>();
    let context_pack_ref = request.context_pack_ref.clone().unwrap_or_else(|| {
        ".octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json".to_string()
    });
    let risk_materiality_ref = request.risk_materiality_ref.clone().unwrap_or_else(|| {
        ".octon/framework/constitution/contracts/authority/risk-materiality-v1.schema.json"
            .to_string()
    });
    let support_target_tuple_ref = request.support_target_tuple_ref.clone().unwrap_or_else(|| {
        format!(
            "{}#support_target_tuple",
            grant
                .run_control_root
                .as_deref()
                .unwrap_or(".octon/state/control/execution/runs")
        )
    });
    let rollback_plan_ref = request.rollback_plan_ref.clone().unwrap_or_else(|| {
        ".octon/framework/constitution/contracts/runtime/rollback-plan-v1.schema.json".to_string()
    });
    ExecutionReceipt {
        schema_version: "execution-receipt-v3".to_string(),
        request_id: request.request_id.clone(),
        grant_id: grant.grant_id.clone(),
        target_id: request.target_id.clone(),
        action_type: request.action_type.clone(),
        path_type: request.caller_path.clone(),
        environment_class: grant.environment_class.as_str().to_string(),
        workflow_mode: grant.workflow_mode.clone(),
        requested_capability_packs,
        granted_capability_packs,
        requested_capabilities: request.requested_capabilities.clone(),
        granted_capabilities: grant.granted_capabilities.clone(),
        policy_mode_requested: request
            .policy_mode_requested
            .clone()
            .unwrap_or_else(|| grant.effective_policy_mode.clone()),
        policy_mode_effective: grant.effective_policy_mode.clone(),
        decision: grant.decision.clone(),
        reason_codes: grant.reason_codes.clone(),
        execution_role_ref: grant.execution_role_ref.clone(),
        context_pack_ref,
        risk_materiality_ref,
        support_target_tuple_ref,
        rollback_plan_ref,
        browser_ui_record_refs,
        api_egress_record_refs,
        side_effects: side_effects.clone(),
        mission_ref: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.mission_ref.clone()),
        slice_ref: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.slice_ref.clone()),
        intent_ref: grant.intent_ref.clone(),
        mission_class: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.mission_class.clone()),
        oversight_mode: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.oversight_mode.clone()),
        execution_posture: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.execution_posture.clone()),
        reversibility_class: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.reversibility_class.clone()),
        boundary_id: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.boundary_id.clone()),
        rollback_handle: grant.rollback_handle.clone(),
        compensation_handle: grant.compensation_handle.clone(),
        recovery_window: grant.recovery_window.clone(),
        autonomy_budget_state: grant.autonomy_budget_state.clone(),
        breaker_state: grant.breaker_state.clone(),
        applied_directive_refs: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.applied_directive_refs.clone())
            .unwrap_or_default(),
        applied_authorize_update_refs: grant
            .autonomy_context
            .as_ref()
            .map(|context| context.applied_authorize_update_refs.clone())
            .unwrap_or_default(),
        touched_scope: side_effects.touched_scope.clone(),
        override_requested: request
            .policy_mode_requested
            .as_ref()
            .map(|value| value != &grant.effective_policy_mode)
            .unwrap_or(false),
        override_accepted: request
            .policy_mode_requested
            .as_ref()
            .map(|value| value == &grant.effective_policy_mode)
            .unwrap_or(true),
        ai_review_enforced: env_bool("AI_GATE_ENFORCE") || env_bool("OCTON_AI_GATE_ENFORCE"),
        autonomy_policy_enforced: env_bool("AUTONOMY_POLICY_ENFORCE")
            || env_bool("OCTON_AUTONOMY_POLICY_ENFORCE"),
        evidence_links: evidence_links(paths, grant),
        budget: grant.budget.clone(),
        support_tier: grant.support_tier.clone(),
        ownership_refs: grant.ownership_refs.clone(),
        approval_request_ref: grant.approval_request_ref.clone(),
        approval_grant_refs: grant.approval_grant_refs.clone(),
        exception_lease_refs: grant.exception_lease_refs.clone(),
        revocation_refs: grant.revocation_refs.clone(),
        decision_artifact_ref: grant.decision_artifact_ref.clone(),
        authority_grant_bundle_ref: grant.authority_grant_bundle_ref.clone(),
        network_egress_posture: grant.network_egress_posture.clone(),
        evidence_completeness_status: None,
        timestamps: ReceiptTimestamps {
            started_at: started_at.to_string(),
            completed_at: outcome.completed_at.clone(),
        },
    }
}

pub(crate) fn request_phase_result(
    request_id: &str,
    decision: ExecutionDecision,
    reason_codes: Vec<String>,
    artifact_refs: BTreeMap<String, String>,
    details: serde_json::Value,
    phase_id: &str,
    phase_status: &str,
) -> AuthorizationPhaseResult {
    AuthorizationPhaseResult {
        schema_version: "authorization-phase-result-v1".to_string(),
        request_id: request_id.to_string(),
        run_id: request_id.to_string(),
        phase_id: phase_id.to_string(),
        phase_status: phase_status.to_string(),
        decision,
        reason_codes,
        artifact_refs,
        details,
        generated_at: now_rfc3339().unwrap_or_else(|_| "1970-01-01T00:00:00Z".to_string()),
    }
}
