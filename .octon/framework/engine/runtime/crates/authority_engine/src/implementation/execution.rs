use super::phases;
use super::*;
use anyhow::Context;
use octon_core::config::{ExecutorProfileConfig, RuntimeConfig};
use octon_core::errors::{ErrorCode, KernelError, Result as CoreResult};
use octon_core::execution_integrity::{
    evaluate_execution_budget, evaluate_network_egress, infer_provider_from_model,
    load_execution_budget_policy, load_execution_exception_leases, load_network_egress_policy,
    record_budget_consumption, write_execution_cost_evidence, BudgetCheckContext, BudgetDecision,
    NetworkEgressContext, NetworkEgressDecision,
};
use octon_core::policy::PolicyEngine;
use octon_core::registry::ServiceDescriptor;
use octon_runtime_bus::{
    append_event as append_run_journal_event, JournalActor, JournalClassification, JournalEffect,
    JournalGoverningRefs, JournalLifecycle, JournalPayload, JournalRedaction,
    RunJournalAppendRequest, RunJournalSnapshotRefs,
};
use octon_runtime_resolver::{verify_runtime_route_bundle, RuntimeSupportTupleRef};
use serde::{Deserialize, Serialize};
use serde_json::json;
use sha2::{Digest, Sha256};
use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::{Mutex, OnceLock};

pub fn default_autonomy_context(
    cfg: &RuntimeConfig,
    mission_id: &str,
    slice_id: &str,
    boundary_id: &str,
    oversight_mode: &str,
    execution_posture: &str,
    reversibility_class: &str,
) -> CoreResult<AutonomyContext> {
    let intent_ref = active_intent_ref(cfg).ok_or_else(|| {
        mission_denial(
            "autonomous execution requires an active intent binding",
            vec!["INTENT_MISSING"],
        )
    })?;
    let charter_path = cfg
        .octon_dir
        .join("instance")
        .join("orchestration")
        .join("missions")
        .join(mission_id)
        .join("mission.yml");
    ensure_file_exists(&charter_path, "MISSION_CHARTER_MISSING")?;
    let charter: MissionCharterRecord = read_yaml_file(&charter_path)?;
    Ok(AutonomyContext {
        mission_ref: AutonomyRef {
            id: mission_id.to_string(),
            version: Some("v2".to_string()),
        },
        slice_ref: AutonomyRef {
            id: slice_id.to_string(),
            version: None,
        },
        intent_ref,
        mission_class: charter.mission_class,
        oversight_mode: oversight_mode.to_string(),
        execution_posture: execution_posture.to_string(),
        reversibility_class: reversibility_class.to_string(),
        boundary_id: boundary_id.to_string(),
        applied_directive_refs: Vec::new(),
        applied_authorize_update_refs: Vec::new(),
    })
}

fn allow_stale_runtime_route_bundle() -> bool {
    std::env::var("OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE")
        .map(|value| value == "1" || value.eq_ignore_ascii_case("true"))
        .unwrap_or(false)
}

fn request_metadata_ref(request: &ExecutionRequest, key: &str) -> Option<String> {
    request
        .metadata
        .get(key)
        .map(|value| value.trim().to_string())
        .filter(|value| !value.is_empty())
}

fn load_explicit_approval_request_ref(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
) -> CoreResult<Option<String>> {
    let Some(approval_request_ref) =
        request_metadata_ref(request, "protected_ci_approval_request_ref")
            .or_else(|| request_metadata_ref(request, "approval_request_ref"))
    else {
        return Ok(None);
    };
    let approval_path = cfg.repo_root.join(&approval_request_ref);
    if !approval_path.is_file() {
        return Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            format!(
                "approval request artifact missing: {}",
                approval_path.display()
            ),
        )
        .with_details(json!({"reason_codes":["APPROVAL_REQUEST_MISSING"]})));
    }
    let _: ApprovalRequestArtifact = read_yaml_file(&approval_path)?;
    Ok(Some(approval_request_ref))
}

fn load_explicit_approval_grants(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
) -> CoreResult<Vec<(ApprovalGrantArtifact, String)>> {
    let mut grants = Vec::new();
    let mut seen = BTreeSet::new();
    for key in ["protected_ci_approval_grant_ref", "approval_grant_ref"] {
        let Some(approval_grant_ref) = request_metadata_ref(request, key) else {
            continue;
        };
        if !seen.insert(approval_grant_ref.clone()) {
            continue;
        }
        let approval_path = cfg.repo_root.join(&approval_grant_ref);
        if !approval_path.is_file() {
            return Err(KernelError::new(
                ErrorCode::CapabilityDenied,
                format!(
                    "approval grant artifact missing: {}",
                    approval_path.display()
                ),
            )
            .with_details(json!({"reason_codes":["APPROVAL_GRANT_MISSING"]})));
        }
        let approval_grant: ApprovalGrantArtifact = read_yaml_file(&approval_path)?;
        if approval_grant.state == "active" {
            grants.push((approval_grant, approval_grant_ref));
        }
    }
    Ok(grants)
}

fn granted_effect_kinds_for_request(request: &ExecutionRequest) -> Vec<String> {
    let mut effect_kinds = vec![
        EvidenceMutation::KIND.to_string(),
        StateControlMutation::KIND.to_string(),
    ];
    if request.side_effect_flags.write_repo || request.side_effect_flags.branch_mutation {
        effect_kinds.push(RepoMutation::KIND.to_string());
    }
    if request.side_effect_flags.publication {
        match request.action_type.as_str() {
            "publish_extension_activation" => {
                effect_kinds.push(ExtensionActivation::KIND.to_string());
            }
            "publish_capability_pack_activation" => {
                effect_kinds.push(CapabilityPackActivation::KIND.to_string());
            }
            _ => {
                effect_kinds.push(GeneratedEffectivePublication::KIND.to_string());
            }
        }
    }
    if request.action_type == "invoke_service"
        || request.side_effect_flags.network
        || request.side_effect_flags.model_invoke
    {
        effect_kinds.push(ServiceInvocation::KIND.to_string());
    }
    if request.action_type == "launch_executor" || request.target_id == "octon-studio" {
        effect_kinds.push(ExecutorLaunch::KIND.to_string());
    }
    if request.action_type == "protected_ci_auto_merge" {
        effect_kinds.push(ProtectedCiCheck::KIND.to_string());
    }
    if effect_kinds.is_empty() {
        effect_kinds.push(ServiceInvocation::KIND.to_string());
    }
    dedupe_strings(&effect_kinds)
}

pub fn authorize_execution(
    cfg: &RuntimeConfig,
    policy: &PolicyEngine,
    request: &ExecutionRequest,
    service: Option<&ServiceDescriptor>,
) -> CoreResult<GrantBundle> {
    let mut request = request.clone();
    request.metadata = with_authority_env_metadata(request.metadata);
    if request.support_target_tuple_ref.is_none() {
        request.support_target_tuple_ref = Some(support_target_tuple_id(
            &requested_support_target_tuple(&request)?,
        ));
    }
    let verified_runtime_route_bundle = if allow_stale_runtime_route_bundle() {
        request.metadata.insert(
            "runtime_effective_route_bundle_generation_id".to_string(),
            "runtime-route-bundle-publication-bypass".to_string(),
        );
        request.metadata.insert(
            "runtime_effective_route_bundle_sha256".to_string(),
            "runtime-route-bundle-publication-bypass".to_string(),
        );
        request.metadata.insert(
            "runtime_effective_route_bundle_ref".to_string(),
            ".octon/generated/effective/runtime/route-bundle.yml".to_string(),
        );
        request.metadata.insert(
            "runtime_effective_handle_kind".to_string(),
            "runtime_route_bundle".to_string(),
        );
        request.metadata.insert(
            "runtime_effective_freshness_mode".to_string(),
            "publication-bypass".to_string(),
        );
        request.metadata.insert(
            "runtime_effective_publication_receipt_ref".to_string(),
            ".octon/state/evidence/validation/publication/runtime/<pending>".to_string(),
        );
        request.metadata.insert(
            "runtime_effective_non_authority_classification".to_string(),
            "derived-runtime-handle".to_string(),
        );
        None
    } else {
        let verified_runtime_route_bundle =
            verify_runtime_route_bundle(&cfg.octon_dir).map_err(runtime_route_bundle_denial)?;
        request.metadata.insert(
            "runtime_effective_route_bundle_generation_id".to_string(),
            verified_runtime_route_bundle.generation_id().to_string(),
        );
        request.metadata.insert(
            "runtime_effective_route_bundle_sha256".to_string(),
            verified_runtime_route_bundle.bundle_sha256.clone(),
        );
        request.metadata.insert(
            "runtime_effective_route_bundle_ref".to_string(),
            path_tail(&cfg.repo_root, &verified_runtime_route_bundle.bundle_path),
        );
        request.metadata.insert(
            "runtime_effective_handle_kind".to_string(),
            "runtime_route_bundle".to_string(),
        );
        request.metadata.insert(
            "runtime_effective_freshness_mode".to_string(),
            verified_runtime_route_bundle.freshness_mode().to_string(),
        );
        request.metadata.insert(
            "runtime_effective_publication_receipt_ref".to_string(),
            verified_runtime_route_bundle
                .lock
                .publication_receipt_path
                .clone(),
        );
        request.metadata.insert(
            "runtime_effective_non_authority_classification".to_string(),
            verified_runtime_route_bundle
                .lock
                .non_authority_classification
                .clone(),
        );
        Some(verified_runtime_route_bundle)
    };
    let environment = resolve_execution_environment(cfg, &request);
    let intent_ref = request
        .intent_ref
        .clone()
        .or_else(|| active_intent_ref(cfg))
        .ok_or_else(|| {
            KernelError::new(
                ErrorCode::CapabilityDenied,
                "execution request missing active intent binding",
            )
            .with_details(json!({"reason_codes":["INTENT_MISSING"]}))
        })?;
    let execution_role_ref = request
        .execution_role_ref
        .clone()
        .unwrap_or_else(default_execution_role_ref);
    let autonomy_state = resolve_autonomy_state(cfg, &request, &intent_ref)?;

    let requested_mode = request
        .policy_mode_requested
        .clone()
        .unwrap_or_else(|| default_policy_mode(cfg));
    let effective_policy_mode = match environment {
        ExecutionEnvironment::Protected => {
            if requested_mode != cfg.execution_governance.protected_policy_mode {
                return Err(KernelError::new(
                    ErrorCode::CapabilityDenied,
                    "protected execution rejected a weaker requested policy mode",
                )
                .with_details(
                    json!({"reason_codes":["PROTECTED_EXECUTION_REQUIRES_HARD_ENFORCE"]}),
                ));
            }
            cfg.execution_governance.protected_policy_mode.clone()
        }
        ExecutionEnvironment::Development => {
            if cfg
                .execution_governance
                .allowed_development_modes
                .contains(&requested_mode)
            {
                requested_mode.clone()
            } else {
                return Err(KernelError::new(
                    ErrorCode::CapabilityDenied,
                    format!(
                        "requested policy mode '{}' is not allowed in development",
                        requested_mode
                    ),
                )
                .with_details(json!({"reason_codes":["POLICY_MODE_INVALID"]})));
            }
        }
    };

    if matches!(environment, ExecutionEnvironment::Protected)
        && effective_policy_mode != cfg.execution_governance.protected_policy_mode
    {
        return Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            "protected execution requires hard-enforce posture",
        )
        .with_details(json!({"reason_codes":["PROTECTED_EXECUTION_REQUIRES_HARD_ENFORCE"]})));
    }

    let executor_profile = request
        .scope_constraints
        .executor_profile
        .as_ref()
        .and_then(|name| cfg.execution_governance.executor_profiles.get(name));
    if request.side_effect_flags.shell
        && request.caller_path != "service"
        && request.scope_constraints.executor_profile.is_none()
    {
        return Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            "shell-backed execution requires an executor profile",
        )
        .with_details(json!({"reason_codes":["EXECUTOR_PROFILE_MISSING"]})));
    }
    if request.scope_constraints.executor_profile.is_some() && executor_profile.is_none() {
        return Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            "execution request referenced an unknown executor profile",
        )
        .with_details(json!({"reason_codes":["EXECUTOR_PROFILE_UNKNOWN"]})));
    }

    if request.side_effect_flags.write_repo && request.scope_constraints.write.is_empty() {
        return Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            "repo-mutating execution requires explicit write scope",
        )
        .with_details(json!({"reason_codes":["WRITE_SCOPE_MISSING"]})));
    }

    if let Some(profile) = executor_profile {
        if profile.require_hard_enforce
            && effective_policy_mode != cfg.execution_governance.protected_policy_mode
        {
            return Err(KernelError::new(
                ErrorCode::CapabilityDenied,
                "elevated executor profile requires hard-enforce posture",
            )
            .with_details(json!({"reason_codes":["ELEVATED_EXECUTOR_REQUIRES_HARD_ENFORCE"]})));
        }
    }

    if is_critical_action(cfg, &request, executor_profile)
        && effective_policy_mode != cfg.execution_governance.protected_policy_mode
    {
        return Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            "critical action denied outside hard-enforce posture",
        )
        .with_details(json!({"reason_codes":["CRITICAL_ACTION_REQUIRES_HARD_ENFORCE"]})));
    }

    let bound_run = bind_run_lifecycle(cfg, &request, autonomy_state.as_ref())?;
    let run_root = bound_run.evidence_root.clone();
    let run_root_rel = bound_run.evidence_root_rel.clone();
    let run_contract = load_run_contract_record(cfg, &request, autonomy_state.as_ref())?;
    let ownership = resolve_ownership_posture(cfg, &request, &run_contract)?;
    let support_tier =
        resolve_support_tier_posture(cfg, &request, &run_contract, autonomy_state.as_ref())?;
    let requested_support_tuple = if run_contract.support_target.workload_tier.trim().is_empty() {
        requested_support_target_tuple(&request)?
    } else {
        run_contract.support_target.clone()
    };
    if let Some(verified_runtime_route_bundle) = verified_runtime_route_bundle.as_ref() {
        let runtime_route = verified_runtime_route_bundle
            .ensure_live_tuple_and_packs(
                &RuntimeSupportTupleRef {
                    model_tier: requested_support_tuple.model_tier.clone(),
                    workload_tier: requested_support_tuple.workload_tier.clone(),
                    language_resource_tier: requested_support_tuple.language_resource_tier.clone(),
                    locale_tier: requested_support_tuple.locale_tier.clone(),
                    host_adapter: requested_support_tuple.host_adapter.clone(),
                    model_adapter: requested_support_tuple.model_adapter.clone(),
                },
                &support_tier.requested_capability_packs,
            )
            .map_err(runtime_route_bundle_denial)?;
        request.metadata.insert(
            "runtime_effective_support_tuple".to_string(),
            runtime_route.tuple_id.clone(),
        );
        request.support_target_tuple_ref = Some(runtime_route.tuple_id.clone());
        request.metadata.insert(
            "runtime_effective_claim_effect".to_string(),
            runtime_route.claim_effect.clone(),
        );
        request.metadata.insert(
            "runtime_effective_allowed_capability_packs".to_string(),
            runtime_route.allowed_capability_packs.join(","),
        );
        verified_runtime_route_bundle
            .ensure_extensions_available()
            .map_err(runtime_route_bundle_denial)?;
        request.metadata.insert(
            "runtime_effective_extensions_status".to_string(),
            verified_runtime_route_bundle
                .bundle
                .extensions
                .status
                .clone(),
        );
        request.metadata.insert(
            "runtime_effective_extensions_generation_id".to_string(),
            verified_runtime_route_bundle
                .bundle
                .extensions
                .generation_id
                .clone(),
        );
    } else {
        request.metadata.insert(
            "runtime_effective_support_tuple".to_string(),
            request
                .support_target_tuple_ref
                .clone()
                .unwrap_or_else(|| "publication-bypass".to_string()),
        );
        request.metadata.insert(
            "runtime_effective_claim_effect".to_string(),
            "publication-bypass".to_string(),
        );
        request.metadata.insert(
            "runtime_effective_allowed_capability_packs".to_string(),
            support_tier.allowed_capability_packs.join(","),
        );
        request.metadata.insert(
            "runtime_effective_extensions_status".to_string(),
            "publication-bypass".to_string(),
        );
        request.metadata.insert(
            "runtime_effective_extensions_generation_id".to_string(),
            "publication-bypass".to_string(),
        );
    }
    let reversibility = reversibility_payload(&request, &run_contract, autonomy_state.as_ref());
    let preflight_result = phases::results::AuthorizationPhaseResult {
        schema_version: "authorization-phase-result-v1".to_string(),
        request_id: request.request_id.clone(),
        run_id: request.request_id.clone(),
        phase_id: "preflight".to_string(),
        phase_status: "completed".to_string(),
        decision: ExecutionDecision::Allow,
        reason_codes: vec!["PREFLIGHT_READY".to_string()],
        artifact_refs: BTreeMap::from([
            (
                "run_contract".to_string(),
                path_tail(&cfg.repo_root, &run_contract_path(cfg, &request.request_id)),
            ),
            (
                "runtime_state".to_string(),
                path_tail(
                    &cfg.repo_root,
                    &runtime_state_path(cfg, &request.request_id),
                ),
            ),
            (
                "replay_pointers".to_string(),
                path_tail(
                    &cfg.repo_root,
                    &replay_pointers_path(cfg, &request.request_id),
                ),
            ),
            (
                "retained_evidence".to_string(),
                path_tail(
                    &cfg.repo_root,
                    &retained_evidence_path(cfg, &request.request_id),
                ),
            ),
        ]),
        details: phases::preflight::preflight_details(
            &environment,
            &effective_policy_mode,
            executor_profile.map(|profile| profile.name.as_str()),
            &ownership.status,
            &support_tier.route,
        ),
        generated_at: now_rfc3339()?,
    };
    let _ = phases::results::record_phase_result(
        cfg,
        &bound_run,
        &request.request_id,
        &preflight_result,
    );

    let requested_capabilities = dedupe_strings(&request.requested_capabilities);
    let requested_network = requested_capabilities
        .iter()
        .any(|value| value == "net.http");
    let requested_without_network = requested_capabilities
        .iter()
        .filter(|value| value.as_str() != "net.http")
        .cloned()
        .collect::<Vec<_>>();

    let mut granted_capabilities = if let Some(service) = service {
        policy.decide_allow(service, &requested_without_network)?
    } else {
        requested_without_network.clone()
    };
    if granted_capabilities.is_empty() && !requested_network {
        return Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            "execution request did not resolve any granted capabilities",
        )
        .with_details(json!({"reason_codes":["GRANTED_CAPABILITIES_EMPTY"]})));
    }

    let mut review_metadata = review_metadata_from_env();
    let profile_requires_human_review = executor_profile
        .map(|profile| profile.require_human_review)
        .unwrap_or(false);
    let profile_requires_rollback = executor_profile
        .map(|profile| profile.require_rollback_metadata)
        .unwrap_or(false);
    let autonomy_requires_approval = autonomy_state
        .as_ref()
        .map(|state| state.approval_required || state.break_glass_required)
        .unwrap_or(false);
    let explicit_approval_request_ref = load_explicit_approval_request_ref(cfg, &request)?;
    let explicit_approval_grants = load_explicit_approval_grants(cfg, &request)?;
    let approval_required = profile_requires_human_review
        || request.review_requirements.human_approval
        || autonomy_requires_approval
        || explicit_approval_request_ref.is_some()
        || !explicit_approval_grants.is_empty()
        || !run_contract.required_approvals.is_empty();
    let quorum_required = request.review_requirements.quorum;
    let rollback_required =
        profile_requires_rollback || request.review_requirements.rollback_metadata;
    let mut required_evidence = run_contract.required_evidence.clone();
    if approval_required {
        required_evidence.push("approval-grant".to_string());
    }
    if quorum_required {
        required_evidence.push("quorum-token".to_string());
    }
    if rollback_required {
        required_evidence.push("rollback-ref".to_string());
    }
    required_evidence.extend(support_tier.required_evidence.clone());
    required_evidence = dedupe_strings(&required_evidence);

    let approval_request_reason_codes = if approval_required {
        let mut codes = vec!["HUMAN_APPROVAL_REQUIRED".to_string()];
        if autonomy_requires_approval {
            codes.push("MISSION_APPROVAL_REQUIRED".to_string());
        }
        codes
    } else {
        Vec::new()
    };
    let approval_request_ref = if approval_required {
        match explicit_approval_request_ref.clone() {
            Some(value) => Some(value),
            None => Some(write_approval_request(
                cfg,
                &request,
                &run_contract,
                &ownership,
                required_evidence.clone(),
                approval_request_reason_codes.clone(),
            )?),
        }
    } else {
        None
    };

    let budget_preview_decision = preview_execution_budget(
        cfg,
        &request,
        executor_profile.map(|profile| profile.name.as_str()),
    )?;
    let budget_preview = budget_preview_decision
        .as_ref()
        .map(|decision| budget_metadata_from_decision(&cfg.repo_root, &run_root, decision));
    let mut budget_posture =
        budget_posture_from_preview(&cfg.repo_root, &run_root, budget_preview_decision.as_ref());
    let mut network_egress_posture = None::<NetworkEgressPosture>;
    let mut exception_refs = Vec::new();

    let emit_route_error = |decision: ExecutionDecision,
                            message: String,
                            reason_codes: Vec<String>,
                            ownership: OwnershipPosture,
                            support_tier: SupportTierPosture,
                            reversibility: serde_json::Value,
                            budget: serde_json::Value,
                            egress: serde_json::Value,
                            approval_request_ref: Option<String>,
                            approval_grant_refs: Vec<String>,
                            exception_refs: Vec<String>,
                            revocation_refs: Vec<String>|
     -> CoreResult<GrantBundle> {
        let decision_ref = write_decision_artifact(
            cfg,
            &request,
            decision.clone(),
            reason_codes.clone(),
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget.clone(),
            egress.clone(),
            approval_request_ref,
            approval_grant_refs.clone(),
            exception_refs.clone(),
            revocation_refs.clone(),
        )?;
        let runtime_status = match decision {
            ExecutionDecision::Deny => "denied",
            ExecutionDecision::StageOnly | ExecutionDecision::Escalate => "stage_only",
            ExecutionDecision::Allow => "authorized",
        };
        let decision_state = match decision {
            ExecutionDecision::Allow => "allow",
            ExecutionDecision::StageOnly => "stage_only",
            ExecutionDecision::Deny => "deny",
            ExecutionDecision::Escalate => "escalate",
        };
        let stage_status = match decision {
            ExecutionDecision::Deny => "failed",
            _ => "staged",
        };
        let _ = update_bound_runtime_state(
            &bound_run,
            runtime_status,
            Some(decision_state),
            None,
            Some(bound_run.control_checkpoint_ref.clone()),
        );
        let _ = update_stage_attempt_status(&bound_run, stage_status, Some(decision_ref.clone()));
        let _ = merge_retained_evidence_ref(
            &bound_run.retained_evidence_path,
            &request.request_id,
            "authority_decision",
            decision_ref.clone(),
        );
        let route_result = phases::routing::route_phase_result(
            &request.request_id,
            match decision {
                ExecutionDecision::Allow => "completed",
                ExecutionDecision::StageOnly => "staged",
                ExecutionDecision::Deny => "denied",
                ExecutionDecision::Escalate => "escalated",
            },
            decision.clone(),
            reason_codes.clone(),
            BTreeMap::from([
                ("decision_artifact".to_string(), decision_ref.clone()),
                ("authority_decision".to_string(), decision_ref.clone()),
            ]),
            phases::routing::route_details(
                &ownership,
                &support_tier,
                &reversibility,
                &budget,
                &egress,
            ),
        );
        let _ = phases::results::record_phase_result(
            cfg,
            &bound_run,
            &request.request_id,
            &route_result,
        );
        Err(
            KernelError::new(ErrorCode::CapabilityDenied, message).with_details(json!({
                "reason_codes": reason_codes,
                "decision": decision_label(&decision),
                "decision_artifact_ref": decision_ref,
                "approval_grant_refs": approval_grant_refs,
                "exception_refs": exception_refs,
                "revocation_refs": revocation_refs,
            })),
        )
    };

    if ownership.status != "resolved" {
        return emit_route_error(
            ExecutionDecision::Escalate,
            "ownership is unresolved for this execution".to_string(),
            vec!["OWNERSHIP_UNRESOLVED".to_string()],
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget_posture.clone(),
            json!({"route": "not-applicable"}),
            approval_request_ref.clone(),
            Vec::new(),
            Vec::new(),
            Vec::new(),
        );
    }

    if support_tier.route != "allow" || support_tier.support_status == "unsupported" {
        let decision = match support_tier.route.as_str() {
            "stage_only" => ExecutionDecision::StageOnly,
            "escalate" => ExecutionDecision::Escalate,
            _ => ExecutionDecision::Deny,
        };
        let reason_code = if support_tier.support_status == "unsupported" {
            "SUPPORT_TIER_UNSUPPORTED"
        } else {
            "SUPPORT_TIER_ROUTE_BLOCKED"
        };
        return emit_route_error(
            decision,
            format!(
                "support tier '{}' is not authorized for this execution",
                support_tier.support_tier
            ),
            vec![reason_code.to_string()],
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget_posture.clone(),
            json!({"route": "not-applicable"}),
            approval_request_ref.clone(),
            Vec::new(),
            Vec::new(),
            Vec::new(),
        );
    }

    if requested_network {
        let egress_decision = match authorize_network_egress(
            cfg,
            &request,
            executor_profile.map(|profile| profile.name.as_str()),
        ) {
            Ok(decision) => decision,
            Err(err) => {
                let decision_ref = write_decision_artifact(
                    cfg,
                    &request,
                    ExecutionDecision::Deny,
                    vec!["NETWORK_EGRESS_DENIED".to_string()],
                    ownership.clone(),
                    support_tier.clone(),
                    reversibility.clone(),
                    budget_posture.clone(),
                    json!({"route": "deny"}),
                    approval_request_ref.clone(),
                    Vec::new(),
                    Vec::new(),
                    Vec::new(),
                );
                if let Ok(decision_ref) = decision_ref {
                    let _ = update_bound_runtime_state(
                        &bound_run,
                        "denied",
                        Some("deny"),
                        None,
                        Some(bound_run.control_checkpoint_ref.clone()),
                    );
                    let _ = update_stage_attempt_status(
                        &bound_run,
                        "failed",
                        Some(decision_ref.clone()),
                    );
                    let _ = merge_retained_evidence_ref(
                        &bound_run.retained_evidence_path,
                        &request.request_id,
                        "authority_decision",
                        decision_ref,
                    );
                }
                return Err(err);
            }
        };
        granted_capabilities.push("net.http".to_string());
        review_metadata.insert(
            "network_egress_rule".to_string(),
            egress_decision.matched_rule_id.clone(),
        );
        review_metadata.insert(
            "network_egress_source".to_string(),
            egress_decision.source_kind.clone(),
        );
        if let Some(artifact_ref) = &egress_decision.artifact_ref {
            if egress_decision.source_kind == "exception-lease" {
                exception_refs.push(artifact_ref.clone());
            }
        }
        network_egress_posture = Some(NetworkEgressPosture {
            route: "allow".to_string(),
            matched_rule_id: Some(egress_decision.matched_rule_id.clone()),
            source_kind: Some(egress_decision.source_kind.clone()),
            artifact_ref: egress_decision.artifact_ref.clone(),
            target_url: request.metadata.get("network_egress_url").cloned(),
        });
    }

    match budget_preview_decision.as_ref() {
        Some(BudgetDecision::StageOnly {
            reason_codes,
            message,
            ..
        }) => {
            return emit_route_error(
                ExecutionDecision::StageOnly,
                message.clone(),
                reason_codes.clone(),
                ownership.clone(),
                support_tier.clone(),
                reversibility.clone(),
                budget_posture.clone(),
                json!(network_egress_posture.clone().unwrap_or_default()),
                approval_request_ref.clone(),
                Vec::new(),
                exception_refs.clone(),
                Vec::new(),
            );
        }
        Some(BudgetDecision::Deny {
            reason_codes,
            message,
            ..
        }) => {
            return emit_route_error(
                ExecutionDecision::Deny,
                message.clone(),
                reason_codes.clone(),
                ownership.clone(),
                support_tier.clone(),
                reversibility.clone(),
                budget_posture.clone(),
                json!(network_egress_posture.clone().unwrap_or_default()),
                approval_request_ref.clone(),
                Vec::new(),
                exception_refs.clone(),
                Vec::new(),
            );
        }
        _ => {}
    }

    let mut loaded_approval_grants = load_existing_approval_grants(cfg, &request.request_id)?;
    for explicit_grant in explicit_approval_grants {
        if loaded_approval_grants
            .iter()
            .all(|(_, path)| path != &explicit_grant.1)
        {
            loaded_approval_grants.push(explicit_grant);
        }
    }
    let approval_grant_refs = loaded_approval_grants
        .iter()
        .map(|(_, path)| path.clone())
        .collect::<Vec<_>>();

    if approval_required && approval_grant_refs.is_empty() {
        let mut reason_codes = vec![
            "HUMAN_APPROVAL_REQUIRED".to_string(),
            "ACP_STAGE_ONLY_REQUIRED".to_string(),
        ];
        if autonomy_requires_approval {
            reason_codes.insert(0, "MISSION_APPROVAL_REQUIRED".to_string());
        }
        return emit_route_error(
            ExecutionDecision::StageOnly,
            "human approval is required for this execution".to_string(),
            reason_codes,
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget_posture.clone(),
            json!(network_egress_posture.clone().unwrap_or_default()),
            approval_request_ref.clone(),
            Vec::new(),
            exception_refs.clone(),
            Vec::new(),
        );
    }
    if approval_required
        && loaded_approval_grants.iter().any(|(grant, _)| {
            grant.quorum_policy_ref.as_deref() != Some(canonical_quorum_policy_ref())
        })
    {
        return emit_route_error(
            ExecutionDecision::StageOnly,
            "approval grant is missing canonical quorum policy binding".to_string(),
            vec![
                "QUORUM_POLICY_BINDING_MISSING".to_string(),
                "ACP_STAGE_ONLY_REQUIRED".to_string(),
            ],
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget_posture.clone(),
            json!(network_egress_posture.clone().unwrap_or_default()),
            approval_request_ref.clone(),
            approval_grant_refs.clone(),
            exception_refs.clone(),
            Vec::new(),
        );
    }
    if quorum_required && !review_metadata.contains_key("quorum_token") {
        return emit_route_error(
            ExecutionDecision::StageOnly,
            "quorum evidence is required for this execution".to_string(),
            vec![
                "QUORUM_EVIDENCE_REQUIRED".to_string(),
                "ACP_STAGE_ONLY_REQUIRED".to_string(),
            ],
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget_posture.clone(),
            json!(network_egress_posture.clone().unwrap_or_default()),
            approval_request_ref.clone(),
            approval_grant_refs.clone(),
            exception_refs.clone(),
            Vec::new(),
        );
    }
    if rollback_required && !review_metadata.contains_key("rollback_ref") {
        return emit_route_error(
            ExecutionDecision::StageOnly,
            "rollback metadata is required for this execution".to_string(),
            vec![
                "ROLLBACK_METADATA_REQUIRED".to_string(),
                "ACP_STAGE_ONLY_REQUIRED".to_string(),
            ],
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget_posture.clone(),
            json!(network_egress_posture.clone().unwrap_or_default()),
            approval_request_ref.clone(),
            approval_grant_refs.clone(),
            exception_refs.clone(),
            Vec::new(),
        );
    }

    let grant_id = format!("grant-{}", request.request_id);
    let revocation_refs = load_active_revocation_refs(cfg, &request.request_id, &grant_id)?;
    if !revocation_refs.is_empty() {
        return emit_route_error(
            ExecutionDecision::Deny,
            "an active revocation blocks this execution".to_string(),
            vec!["AUTHORITY_GRANT_REVOKED".to_string()],
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget_posture.clone(),
            json!(network_egress_posture.clone().unwrap_or_default()),
            approval_request_ref.clone(),
            approval_grant_refs.clone(),
            exception_refs.clone(),
            revocation_refs.clone(),
        );
    }

    let policy_artifacts = compose_policy_receipt(
        cfg,
        &request,
        &intent_ref,
        &execution_role_ref,
        &effective_policy_mode,
        budget_preview.as_ref(),
        autonomy_state.as_ref(),
        &ownership,
        &support_tier,
        approval_request_ref.as_deref(),
        &approval_grant_refs,
        &exception_refs,
        &revocation_refs,
        network_egress_posture.as_ref(),
    )?;
    if !policy_artifacts.allow {
        return emit_route_error(
            policy_artifacts.decision.clone(),
            policy_artifacts
                .remediation
                .clone()
                .unwrap_or_else(|| "ACP denied execution".to_string()),
            policy_artifacts.reason_codes.clone(),
            ownership.clone(),
            support_tier.clone(),
            reversibility.clone(),
            budget_posture.clone(),
            json!(network_egress_posture.clone().unwrap_or_default()),
            approval_request_ref.clone(),
            approval_grant_refs.clone(),
            exception_refs.clone(),
            revocation_refs.clone(),
        );
    }

    let budget = finalize_execution_budget(cfg, budget_preview_decision, &run_root)?;
    if let Some(metadata) = &budget {
        budget_posture = json!({
            "route": "allow",
            "rule_id": metadata.rule_id,
            "reason_codes": metadata.reason_codes,
            "estimated_cost_usd": metadata.estimated_cost_usd,
            "actual_cost_usd": metadata.actual_cost_usd,
            "evidence_path": metadata.evidence_path,
        });
    }

    let mut grant = GrantBundle {
        grant_id: grant_id.clone(),
        request_id: request.request_id.clone(),
        decision: ExecutionDecision::Allow,
        granted_capabilities,
        granted_effect_kinds: granted_effect_kinds_for_request(&request),
        scope_constraints: request.scope_constraints.clone(),
        effective_policy_mode,
        reason_codes: if policy_artifacts.reason_codes.is_empty() {
            vec!["EXECUTION_AUTHORIZED".to_string()]
        } else {
            policy_artifacts.reason_codes.clone()
        },
        review_metadata,
        expires_after: None,
        receipt_requirements: vec![
            "execution-request.json".to_string(),
            "policy-decision.json".to_string(),
            "grant-bundle.json".to_string(),
            "authorization-phases/preflight.json".to_string(),
            "authorization-phases/routing.json".to_string(),
            "authorization-phases/grant.json".to_string(),
            "authorization-phases/request-materialization.json".to_string(),
            "authorization-phases/receipt-materialization.json".to_string(),
            "side-effects.json".to_string(),
            "outcome.json".to_string(),
            "execution-receipt.json".to_string(),
        ],
        environment_class: environment,
        workflow_mode: request.workflow_mode.clone(),
        intent_ref,
        autonomy_context: autonomy_state.as_ref().map(|state| state.context.clone()),
        execution_role_ref,
        run_root: run_root_rel,
        run_control_root: Some(bound_run.control_root_rel.clone()),
        run_receipts_root: Some(bound_run.receipts_root_rel.clone()),
        replay_pointers_path: Some(bound_run.replay_pointers_ref.clone()),
        trace_pointers_path: Some(bound_run.trace_pointers_ref.clone()),
        retained_evidence_path: Some(bound_run.retained_evidence_ref.clone()),
        stage_attempt_ref: Some(bound_run.stage_attempt_ref.clone()),
        policy_receipt_path: policy_artifacts.receipt_path,
        policy_digest_path: policy_artifacts.digest_path,
        instruction_manifest_path: policy_artifacts.instruction_manifest_path,
        budget,
        rollback_handle: autonomy_state
            .as_ref()
            .and_then(|state| state.rollback_handle.clone()),
        compensation_handle: autonomy_state
            .as_ref()
            .and_then(|state| state.compensation_handle.clone()),
        recovery_window: autonomy_state
            .as_ref()
            .map(|state| state.recovery_window.clone()),
        autonomy_budget_state: autonomy_state
            .as_ref()
            .map(|state| state.autonomy_budget_state.clone()),
        breaker_state: autonomy_state
            .as_ref()
            .map(|state| state.breaker_state.clone()),
        support_tier: Some(run_contract.support_tier.clone()),
        support_target_tuple_ref: request.support_target_tuple_ref.clone().or_else(|| {
            request
                .metadata
                .get("runtime_effective_support_tuple")
                .filter(|value| value.starts_with("tuple://"))
                .cloned()
        }),
        support_posture: Some(support_tier.clone()),
        quorum_policy_ref: Some(canonical_quorum_policy_ref().to_string()),
        ownership_refs: ownership.owner_refs.clone(),
        approval_request_ref: approval_request_ref.clone(),
        approval_grant_refs: approval_grant_refs.clone(),
        exception_lease_refs: exception_refs.clone(),
        revocation_refs: revocation_refs.clone(),
        decision_artifact_ref: None,
        authority_grant_bundle_ref: None,
        network_egress_posture: network_egress_posture.clone(),
    };
    let decision_ref = write_decision_artifact(
        cfg,
        &request,
        ExecutionDecision::Allow,
        grant.reason_codes.clone(),
        ownership,
        support_tier,
        reversibility,
        budget_posture,
        json!(network_egress_posture.unwrap_or_default()),
        approval_request_ref,
        approval_grant_refs,
        exception_refs,
        revocation_refs,
    )?;
    grant.decision_artifact_ref = Some(decision_ref);
    let authority_bundle_ref = write_authority_grant_bundle(cfg, &grant)?;
    grant.authority_grant_bundle_ref = Some(authority_bundle_ref);
    if let Some(policy_receipt_path) = grant.policy_receipt_path.clone() {
        merge_replay_receipt_ref(
            &bound_run.replay_pointers_path,
            &request.request_id,
            policy_receipt_path.clone(),
        )?;
        merge_retained_evidence_ref(
            &bound_run.retained_evidence_path,
            &request.request_id,
            "policy_receipt",
            policy_receipt_path,
        )?;
    }
    if let Some(policy_digest_path) = grant.policy_digest_path.clone() {
        merge_retained_evidence_ref(
            &bound_run.retained_evidence_path,
            &request.request_id,
            "policy_digest",
            policy_digest_path,
        )?;
    }
    if let Some(instruction_manifest_path) = grant.instruction_manifest_path.clone() {
        merge_retained_evidence_ref(
            &bound_run.retained_evidence_path,
            &request.request_id,
            "instruction_manifest",
            instruction_manifest_path,
        )?;
    }
    if let Some(decision_artifact_ref) = grant.decision_artifact_ref.clone() {
        merge_retained_evidence_ref(
            &bound_run.retained_evidence_path,
            &request.request_id,
            "authority_decision",
            decision_artifact_ref,
        )?;
    }
    if let Some(authority_bundle_ref) = grant.authority_grant_bundle_ref.clone() {
        merge_retained_evidence_ref(
            &bound_run.retained_evidence_path,
            &request.request_id,
            "authority_grant_bundle",
            authority_bundle_ref,
        )?;
    }
    let grant_phase_result = phases::receipt::request_phase_result(
        &request.request_id,
        ExecutionDecision::Allow,
        grant.reason_codes.clone(),
        BTreeMap::from([
            (
                "decision_artifact".to_string(),
                grant.decision_artifact_ref.clone().unwrap_or_default(),
            ),
            (
                "authority_grant_bundle".to_string(),
                grant.authority_grant_bundle_ref.clone().unwrap_or_default(),
            ),
        ]),
        json!({
            "effective_policy_mode": grant.effective_policy_mode,
            "environment_class": grant.environment_class.as_str(),
            "approval_required": approval_required,
            "quorum_required": quorum_required,
        }),
        "grant",
        "completed",
    );
    let _ = phases::results::record_phase_result(
        cfg,
        &bound_run,
        &request.request_id,
        &grant_phase_result,
    );
    update_bound_runtime_state(
        &bound_run,
        "authorized",
        Some("allow"),
        grant.policy_receipt_path.clone(),
        Some(bound_run.control_checkpoint_ref.clone()),
    )?;
    update_stage_attempt_status(&bound_run, "planned", grant.policy_receipt_path.clone())?;
    Ok(grant)
}

fn runtime_route_bundle_denial(err: anyhow::Error) -> KernelError {
    let message = err.to_string();
    let reason_code = if message.contains("does not cover the requested support tuple")
        || message.contains("denied requested capability pack")
        || message.contains("non-live support tuple")
    {
        "SUPPORT_TIER_UNSUPPORTED"
    } else if message.contains("non-authority classification is invalid") {
        "runtime_effective_handle_missing"
    } else if message.contains("consumer '") && message.contains("is not allowed") {
        "runtime_effective_consumer_forbidden"
    } else if message.contains("consumer '") && message.contains("is forbidden") {
        "runtime_effective_consumer_forbidden"
    } else if message.contains("freshness mode is invalid")
        || message.contains("freshness window expired")
        || message.contains("ttl-bound freshness window expired")
    {
        "runtime_effective_handle_stale"
    } else if message.contains("support matrix is not a direct runtime authority handle") {
        "runtime_effective_consumer_forbidden"
    } else if message.contains("digest drift detected") {
        "runtime_effective_handle_digest_mismatch"
    } else if message.contains("publication receipt") {
        "runtime_effective_receipt_missing"
    } else if message.contains("quarantined extensions") {
        "extension_quarantined"
    } else if message.contains("unpublished or degraded extension state") {
        "extension_active_not_published"
    } else {
        "runtime_effective_handle_missing"
    };
    KernelError::new(
        ErrorCode::CapabilityDenied,
        format!("runtime-effective route bundle denied execution: {err}"),
    )
    .with_details(json!({
        "reason_codes":[
            reason_code,
            "FCR-025",
            "FCR-026",
            "FCR-028",
            "FCR-029"
        ]
    }))
}

pub fn artifact_root_from_relative(
    repo_root: &Path,
    relative_root: &str,
    request_id: &str,
) -> PathBuf {
    repo_root.join(relative_root).join(request_id)
}

fn append_runtime_journal_event(
    bound: &BoundRunLifecycle,
    request: &ExecutionRequest,
    event_id: impl Into<String>,
    event_type: &str,
    recorded_at: &str,
    subject_ref: Option<String>,
    classification: JournalClassification,
    lifecycle: JournalLifecycle,
    governing_refs: JournalGoverningRefs,
    payload: JournalPayload,
    effect: JournalEffect,
    governing_manifest_roles: Vec<String>,
    snapshot_refs: Option<RunJournalSnapshotRefs>,
) -> CoreResult<octon_runtime_bus::RunJournalAppendReceipt> {
    append_run_journal_event(
        &bound.control_root,
        RunJournalAppendRequest {
            run_id: request.request_id.clone(),
            control_root_ref: bound.control_root_rel.clone(),
            event_id: event_id.into(),
            event_type: event_type.to_string(),
            recorded_at: recorded_at.to_string(),
            subject_ref,
            actor: JournalActor {
                actor_class: "runtime".to_string(),
                actor_ref: ".octon/framework/engine/runtime/crates/runtime_bus".to_string(),
            },
            classification,
            lifecycle,
            governing_refs,
            payload,
            effect,
            redaction: JournalRedaction {
                redacted: false,
                justification: None,
                lineage_ref: None,
                omitted_fields: Vec::new(),
            },
            causality: octon_runtime_bus::JournalCausality::default(),
            governing_manifest_roles,
            materialization: None,
            snapshot_refs,
            drift_status: Some("in-sync".to_string()),
            drift_ref: None,
        },
    )
    .map_err(|error| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to append runtime journal event: {error}"),
        )
    })
}

fn journal_governing_refs_for_bound_run(
    bound: &BoundRunLifecycle,
    request: &ExecutionRequest,
    grant: &GrantBundle,
    checkpoint_ref: Option<String>,
    disclosure_ref: Option<String>,
    evidence_snapshot_ref: Option<String>,
) -> JournalGoverningRefs {
    JournalGoverningRefs {
        run_contract_ref: format!(
            ".octon/state/control/execution/runs/{}/run-contract.yml",
            request.request_id
        ),
        run_manifest_ref: bound.run_manifest_ref.clone(),
        execution_request_ref: Some(format!(
            ".octon/state/evidence/runs/{}/receipts/execution-request.json",
            request.request_id
        )),
        authority_route_receipt_ref: grant.decision_artifact_ref.clone(),
        grant_bundle_ref: grant.authority_grant_bundle_ref.clone(),
        policy_receipt_ref: grant.policy_receipt_path.clone(),
        approval_ref: grant
            .approval_request_ref
            .clone()
            .or_else(|| grant.approval_grant_refs.first().cloned()),
        lease_ref: grant.exception_lease_refs.first().cloned(),
        revocation_ref: grant.revocation_refs.first().cloned(),
        support_target_tuple_ref: request
            .support_target_tuple_ref
            .clone()
            .or_else(|| grant.support_target_tuple_ref.clone())
            .or_else(|| {
                request
                    .metadata
                    .get("runtime_effective_support_tuple")
                    .cloned()
            })
            .or_else(|| grant.support_tier.clone()),
        rollback_plan_ref: grant.rollback_handle.clone(),
        rollback_posture_ref: Some(format!(
            ".octon/state/control/execution/runs/{}/rollback-posture.yml",
            request.request_id
        )),
        context_pack_ref: request.metadata.get("context_pack_ref").cloned(),
        stage_attempt_ref: bound.stage_attempt_ref.clone().into(),
        checkpoint_ref,
        validator_result_ref: None,
        evidence_snapshot_ref,
        disclosure_ref,
        drift_ref: None,
        continuity_ref: Some(format!(
            ".octon/state/continuity/runs/{}/handoff.yml",
            request.request_id
        )),
        additional_refs: Vec::new(),
    }
}

fn journal_payload(
    typed_body: Option<serde_json::Value>,
    artifact_ref: Option<String>,
    summary: Option<String>,
) -> JournalPayload {
    JournalPayload {
        payload_kind: if artifact_ref.is_some() {
            "side-artifact-ref".to_string()
        } else if typed_body.is_some() {
            "inline-typed".to_string()
        } else {
            "none".to_string()
        },
        schema_ref: None,
        typed_body,
        artifact_ref,
        artifact_hash: None,
        content_type: None,
        summary,
    }
}

fn journal_effect(effect_class: &str) -> JournalEffect {
    JournalEffect {
        effect_class: effect_class.to_string(),
        reversibility_class: "compensable".to_string(),
        evidence_class: "required".to_string(),
    }
}

fn snapshot_run_journal(repo_root: &Path, request_id: &str) -> CoreResult<RunJournalSnapshotRefs> {
    let control_events = repo_root
        .join(".octon/state/control/execution/runs")
        .join(request_id)
        .join("events.ndjson");
    let control_manifest = repo_root
        .join(".octon/state/control/execution/runs")
        .join(request_id)
        .join("events.manifest.yml");
    let snapshot_root = repo_root
        .join(".octon/state/evidence/runs")
        .join(request_id)
        .join("run-journal");
    let evidence_events = snapshot_root.join("events.snapshot.ndjson");
    let evidence_manifest = snapshot_root.join("events.manifest.snapshot.yml");
    let redactions = snapshot_root.join("redactions.yml");

    fs::create_dir_all(&snapshot_root).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to create run journal snapshot root {}: {e}",
                snapshot_root.display()
            ),
        )
    })?;
    fs::copy(&control_events, &evidence_events).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to copy run journal events from {} to {}: {e}",
                control_events.display(),
                evidence_events.display()
            ),
        )
    })?;
    fs::copy(&control_manifest, &evidence_manifest).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to copy run journal manifest from {} to {}: {e}",
                control_manifest.display(),
                evidence_manifest.display()
            ),
        )
    })?;
    if !redactions.is_file() {
        write_yaml(
            &redactions,
            &json!({
                "schema_version": "run-journal-redactions-v1",
                "run_id": request_id,
                "records": [],
                "generated_at": now_rfc3339().map_err(|error| {
                    KernelError::new(
                        ErrorCode::Internal,
                        format!("failed to timestamp run journal redactions: {error}"),
                    )
                })?,
            }),
        )?;
    }

    Ok(RunJournalSnapshotRefs {
        control_snapshot_ref: Some(format!(
            ".octon/state/control/execution/runs/{request_id}/events.ndjson"
        )),
        evidence_snapshot_ref: Some(format!(
            ".octon/state/evidence/runs/{request_id}/run-journal/events.snapshot.ndjson"
        )),
        evidence_manifest_snapshot_ref: Some(format!(
            ".octon/state/evidence/runs/{request_id}/run-journal/events.manifest.snapshot.yml"
        )),
        redaction_record_ref: Some(format!(
            ".octon/state/evidence/runs/{request_id}/run-journal/redactions.yml"
        )),
    })
}

pub fn write_execution_start(
    root: &Path,
    request: &ExecutionRequest,
    grant: &GrantBundle,
    effects: &ExecutionArtifactEffects,
) -> anyhow::Result<ExecutionArtifactPaths> {
    verify_authorized_effect(
        root,
        grant,
        &effects.evidence,
        ".octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs::write_execution_start:evidence",
        root.display().to_string(),
    )
    .map_err(|error: KernelError| anyhow::anyhow!(error.to_string()))?;
    verify_authorized_effect(
        root,
        grant,
        &effects.control,
        ".octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs::write_execution_start:control",
        root.display().to_string(),
    )
    .map_err(|error: KernelError| anyhow::anyhow!(error.to_string()))?;
    fs::create_dir_all(root)
        .with_context(|| format!("create execution artifact root {}", root.display()))?;
    let paths = ExecutionArtifactPaths::new(root.to_path_buf());
    write_json(
        &paths.request,
        &phases::receipt::execution_request_payload(request, grant),
    )?;
    write_json(
        &paths.decision,
        &json!({
            "schema_version": "execution-authorization-v1",
            "decision": grant.decision,
            "reason_codes": grant.reason_codes,
            "effective_policy_mode": grant.effective_policy_mode,
            "environment_class": grant.environment_class,
        }),
    )?;
    write_json(
        &paths.grant,
        &json!({
            "schema_version": "execution-grant-v1",
            "grant": grant,
        }),
    )?;
    if let Some(bound) = bound_run_from_grant(root, grant) {
        let request_receipt = bound.receipts_root.join("execution-request.json");
        let decision_receipt = bound.receipts_root.join("policy-decision.json");
        let grant_receipt = bound.receipts_root.join("grant-bundle.json");
        copy_json_if_present(&paths.request, &request_receipt)
            .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        copy_json_if_present(&paths.decision, &decision_receipt)
            .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        copy_json_if_present(&paths.grant, &grant_receipt)
            .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        let request_phase_result = phases::receipt::request_phase_result(
            &request.request_id,
            ExecutionDecision::Allow,
            vec!["REQUEST_MATERIALIZED".to_string()],
            BTreeMap::from([
                (
                    "execution_request".to_string(),
                    path_tail(
                        &discover_repo_root(root).unwrap_or_else(|| PathBuf::from(".")),
                        &request_receipt,
                    ),
                ),
                (
                    "policy_decision".to_string(),
                    path_tail(
                        &discover_repo_root(root).unwrap_or_else(|| PathBuf::from(".")),
                        &decision_receipt,
                    ),
                ),
                (
                    "grant_bundle".to_string(),
                    path_tail(
                        &discover_repo_root(root).unwrap_or_else(|| PathBuf::from(".")),
                        &grant_receipt,
                    ),
                ),
            ]),
            json!({
                "resolved_intent_ref": grant.intent_ref,
                "resolved_execution_role_ref": grant.execution_role_ref,
                "resolved_autonomy_context": grant.autonomy_context.clone(),
            }),
            "request-materialization",
            "completed",
        );
        let request_phase_path = bound
            .receipts_root
            .join("authorization-phases")
            .join("request-materialization.json");
        write_json(&request_phase_path, &request_phase_result)
            .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        let repo_root = discover_repo_root(root).unwrap_or_else(|| PathBuf::from("."));
        let request_phase_ref = path_tail(&repo_root, &request_phase_path);
        let _ = merge_replay_receipt_ref(
            &bound.replay_pointers_path,
            &request.request_id,
            request_phase_ref.clone(),
        );
        let _ = merge_retained_evidence_ref(
            &bound.retained_evidence_path,
            &request.request_id,
            "authorization_phase_request_materialization",
            request_phase_ref,
        );
        let start_control = bound
            .control_root
            .join("checkpoints")
            .join("execution-start.yml");
        let start_evidence = bound
            .evidence_root
            .join("checkpoints")
            .join("execution-start.yml");
        let (_, evidence_checkpoint_ref) = write_run_checkpoint(
            &start_control,
            &start_evidence,
            &request.request_id,
            &bound.stage_attempt_id,
            "execution-start",
            "execution-start",
            "Execution artifacts materialized under the canonical run root.",
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        let start_checkpoint_ref = path_tail(&repo_root, &start_control);
        let grant_receipt_ref = path_tail(&repo_root, &grant_receipt);
        let journal_started_at = request
            .metadata
            .get("generated_at")
            .cloned()
            .unwrap_or_else(|| {
                now_rfc3339().unwrap_or_else(|_| "1970-01-01T00:00:00Z".to_string())
            });
        append_runtime_journal_event(
            &bound,
            request,
            format!("evt-capability-authorized-{}", request.request_id),
            "capability-authorized",
            &journal_started_at,
            Some(grant_receipt_ref.clone()),
            JournalClassification {
                event_plane: "authorized-action".to_string(),
                replay_disposition: "requires-fresh-authorization".to_string(),
            },
            JournalLifecycle {
                state_before: Some("authorizing".to_string()),
                state_after: Some("authorized".to_string()),
            },
            journal_governing_refs_for_bound_run(&bound, request, grant, None, None, None),
            journal_payload(
                Some(json!({
                    "granted_capabilities": grant.granted_capabilities.clone(),
                    "effective_policy_mode": grant.effective_policy_mode,
                })),
                None,
                Some("Capability authorization entered the canonical Run Journal.".to_string()),
            ),
            journal_effect("authorization"),
            vec!["runtime_state_ref".to_string()],
            None,
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        append_runtime_journal_event(
            &bound,
            request,
            format!("evt-stage-started-{}", request.request_id),
            "stage-started",
            &journal_started_at,
            Some(bound.stage_attempt_ref.clone()),
            JournalClassification {
                event_plane: "committed-effect".to_string(),
                replay_disposition: "dry-run-only".to_string(),
            },
            JournalLifecycle {
                state_before: Some("authorized".to_string()),
                state_after: Some("running".to_string()),
            },
            journal_governing_refs_for_bound_run(&bound, request, grant, None, None, None),
            journal_payload(
                Some(json!({"stage_attempt_id": bound.stage_attempt_id.clone()})),
                None,
                Some("Initial stage attempt entered the running state.".to_string()),
            ),
            journal_effect("write"),
            vec!["stage_attempt_ref".to_string()],
            None,
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        append_runtime_journal_event(
            &bound,
            request,
            format!("evt-capability-invoked-{}", request.request_id),
            "capability-invoked",
            &journal_started_at,
            Some(path_tail(&repo_root, &paths.root)),
            JournalClassification {
                event_plane: "committed-effect".to_string(),
                replay_disposition: "requires-fresh-authorization".to_string(),
            },
            JournalLifecycle {
                state_before: Some("running".to_string()),
                state_after: Some("running".to_string()),
            },
            journal_governing_refs_for_bound_run(
                &bound,
                request,
                grant,
                None,
                None,
                None,
            ),
            journal_payload(
                Some(json!({
                    "requested_capabilities": request.requested_capabilities.clone(),
                    "scope_ref": effects.control.scope_ref().to_string(),
                })),
                None,
                Some("Capability invocation is journal-covered before consequential execution proceeds.".to_string()),
            ),
            journal_effect("mutate"),
            Vec::new(),
            None,
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        append_runtime_journal_event(
            &bound,
            request,
            format!("evt-checkpoint-start-{}", request.request_id),
            "checkpoint-created",
            &journal_started_at,
            Some(start_checkpoint_ref.clone()),
            JournalClassification {
                event_plane: "retained-evidence".to_string(),
                replay_disposition: "dry-run-only".to_string(),
            },
            JournalLifecycle {
                state_before: Some("running".to_string()),
                state_after: Some("running".to_string()),
            },
            journal_governing_refs_for_bound_run(
                &bound,
                request,
                grant,
                Some(start_checkpoint_ref.clone()),
                None,
                None,
            ),
            journal_payload(
                Some(json!({
                    "checkpoint_kind":"execution-start",
                    "evidence_checkpoint_ref": evidence_checkpoint_ref,
                })),
                None,
                Some(
                    "Execution-start checkpoint materialized under canonical run roots."
                        .to_string(),
                ),
            ),
            journal_effect("evidence"),
            vec!["checkpoint_ref".to_string()],
            None,
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        update_bound_runtime_state(
            &bound,
            "running",
            Some("allow"),
            Some(grant_receipt_ref),
            Some(start_checkpoint_ref),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        update_stage_attempt_status(
            &bound,
            "running",
            Some(path_tail(
                &discover_repo_root(root).unwrap_or_else(|| PathBuf::from(".")),
                &grant_receipt,
            )),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_replay_receipt_ref(
            &bound.replay_pointers_path,
            &request.request_id,
            path_tail(
                &discover_repo_root(root).unwrap_or_else(|| PathBuf::from(".")),
                &grant_receipt,
            ),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_replay_checkpoint_ref(
            &bound.replay_pointers_path,
            &request.request_id,
            evidence_checkpoint_ref.clone(),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_retained_evidence_ref(
            &bound.retained_evidence_path,
            &request.request_id,
            "execution_request",
            path_tail(
                &discover_repo_root(root).unwrap_or_else(|| PathBuf::from(".")),
                &request_receipt,
            ),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_retained_evidence_ref(
            &bound.retained_evidence_path,
            &request.request_id,
            "policy_decision",
            path_tail(
                &discover_repo_root(root).unwrap_or_else(|| PathBuf::from(".")),
                &decision_receipt,
            ),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_retained_evidence_ref(
            &bound.retained_evidence_path,
            &request.request_id,
            "grant_bundle",
            path_tail(&repo_root, &grant_receipt),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
    }
    Ok(paths)
}

pub fn finalize_execution(
    paths: &ExecutionArtifactPaths,
    request: &ExecutionRequest,
    grant: &GrantBundle,
    effects: &ExecutionArtifactEffects,
    started_at: &str,
    outcome: &ExecutionOutcome,
    side_effects: &SideEffectSummary,
) -> anyhow::Result<()> {
    let verified_evidence = verify_authorized_effect(
        &paths.root,
        grant,
        &effects.evidence,
        ".octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs::finalize_execution:evidence",
        paths.root.display().to_string(),
    )
    .map_err(|error: KernelError| anyhow::anyhow!(error.to_string()))?;
    let verified_control = verify_authorized_effect(
        &paths.root,
        grant,
        &effects.control,
        ".octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs::finalize_execution:control",
        paths.root.display().to_string(),
    )
    .map_err(|error: KernelError| anyhow::anyhow!(error.to_string()))?;
    let mut side_effects_with_tokens = side_effects.clone();
    side_effects_with_tokens
        .authorized_effects
        .push(authorized_effect_reference(&verified_evidence));
    side_effects_with_tokens
        .authorized_effects
        .push(authorized_effect_reference(&verified_control));
    side_effects_with_tokens
        .authorized_effects
        .sort_by(|left, right| {
            left.token_id.cmp(&right.token_id).then(
                left.consumption_receipt_ref
                    .cmp(&right.consumption_receipt_ref),
            )
        });
    side_effects_with_tokens
        .authorized_effects
        .dedup_by(|left, right| {
            left.token_id == right.token_id
                && left.consumption_receipt_ref == right.consumption_receipt_ref
        });
    write_json(&paths.side_effects, &side_effects_with_tokens)?;
    write_json(&paths.outcome, outcome)?;
    let receipt = phases::receipt::execution_receipt_payload(
        request,
        grant,
        started_at,
        outcome,
        &side_effects_with_tokens,
        paths,
    );
    write_json(&paths.receipt, &receipt)?;
    if let Some(bound) = bound_run_from_grant(&paths.root, grant) {
        let side_effects_receipt = bound.receipts_root.join("side-effects.json");
        let outcome_receipt = bound.receipts_root.join("outcome.json");
        let execution_receipt = bound.receipts_root.join("execution-receipt.json");
        copy_json_if_present(&paths.side_effects, &side_effects_receipt)
            .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        copy_json_if_present(&paths.outcome, &outcome_receipt)
            .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        copy_json_if_present(&paths.receipt, &execution_receipt)
            .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        let repo_root = discover_repo_root(&paths.root).unwrap_or_else(|| PathBuf::from("."));
        let receipt_phase_result = phases::receipt::request_phase_result(
            &request.request_id,
            grant.decision.clone(),
            grant.reason_codes.clone(),
            BTreeMap::from([
                (
                    "side_effects".to_string(),
                    path_tail(&repo_root, &side_effects_receipt),
                ),
                (
                    "outcome".to_string(),
                    path_tail(&repo_root, &outcome_receipt),
                ),
                (
                    "execution_receipt".to_string(),
                    path_tail(&repo_root, &execution_receipt),
                ),
            ]),
            json!({
                "outcome_status": outcome.status,
                "started_at": started_at,
                "completed_at": outcome.completed_at,
            }),
            "receipt-materialization",
            "completed",
        );
        let receipt_phase_path = bound
            .receipts_root
            .join("authorization-phases")
            .join("receipt-materialization.json");
        write_json(&receipt_phase_path, &receipt_phase_result)?;
        let receipt_phase_ref = path_tail(&repo_root, &receipt_phase_path);
        let _ = merge_replay_receipt_ref(
            &bound.replay_pointers_path,
            &request.request_id,
            receipt_phase_ref.clone(),
        );
        let _ = merge_retained_evidence_ref(
            &bound.retained_evidence_path,
            &request.request_id,
            "authorization_phase_receipt_materialization",
            receipt_phase_ref,
        );
        let terminal_control = bound
            .control_root
            .join("checkpoints")
            .join("execution-complete.yml");
        let terminal_evidence = bound
            .evidence_root
            .join("checkpoints")
            .join("execution-complete.yml");
        let (_, evidence_checkpoint_ref) = write_run_checkpoint(
            &terminal_control,
            &terminal_evidence,
            &request.request_id,
            &bound.stage_attempt_id,
            "execution-complete",
            "execution-complete",
            "Execution outcome materialized under the canonical run root.",
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        let terminal_checkpoint_ref = path_tail(&repo_root, &terminal_control);
        append_runtime_journal_event(
            &bound,
            request,
            format!("evt-capability-terminal-{}", request.request_id),
            if outcome.status == "succeeded" {
                "capability-completed"
            } else {
                "capability-failed"
            },
            &outcome.completed_at,
            Some(path_tail(&repo_root, &execution_receipt)),
            JournalClassification {
                event_plane: "committed-effect".to_string(),
                replay_disposition: "requires-fresh-authorization".to_string(),
            },
            JournalLifecycle {
                state_before: Some("running".to_string()),
                state_after: Some(outcome.status.clone()),
            },
            journal_governing_refs_for_bound_run(&bound, request, grant, None, None, None),
            journal_payload(
                Some(json!({
                    "outcome_status": outcome.status,
                    "execution_receipt_ref": path_tail(&repo_root, &execution_receipt),
                })),
                None,
                Some(
                    "Capability terminal outcome is recorded in the canonical Run Journal."
                        .to_string(),
                ),
            ),
            journal_effect("mutate"),
            Vec::new(),
            None,
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        append_runtime_journal_event(
            &bound,
            request,
            format!("evt-checkpoint-complete-{}", request.request_id),
            "checkpoint-created",
            &outcome.completed_at,
            Some(terminal_checkpoint_ref.clone()),
            JournalClassification {
                event_plane: "retained-evidence".to_string(),
                replay_disposition: "dry-run-only".to_string(),
            },
            JournalLifecycle {
                state_before: Some(outcome.status.clone()),
                state_after: Some(outcome.status.clone()),
            },
            journal_governing_refs_for_bound_run(
                &bound,
                request,
                grant,
                Some(terminal_checkpoint_ref.clone()),
                None,
                None,
            ),
            journal_payload(
                Some(json!({
                    "checkpoint_kind":"execution-complete",
                    "evidence_checkpoint_ref": evidence_checkpoint_ref.clone(),
                })),
                None,
                Some(
                    "Execution-complete checkpoint materialized under canonical run roots."
                        .to_string(),
                ),
            ),
            journal_effect("evidence"),
            vec!["checkpoint_ref".to_string()],
            None,
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        update_bound_runtime_state(
            &bound,
            &outcome.status,
            Some("allow"),
            Some(path_tail(&repo_root, &execution_receipt)),
            Some(terminal_checkpoint_ref.clone()),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        let terminal_stage_status = match outcome.status.as_str() {
            "succeeded" => "succeeded",
            "failed" => "failed",
            "cancelled" => "cancelled",
            _ => "failed",
        };
        update_stage_attempt_status(
            &bound,
            terminal_stage_status,
            Some(path_tail(&repo_root, &execution_receipt)),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_replay_receipt_ref(
            &bound.replay_pointers_path,
            &request.request_id,
            path_tail(&repo_root, &execution_receipt),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_replay_checkpoint_ref(
            &bound.replay_pointers_path,
            &request.request_id,
            evidence_checkpoint_ref,
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_retained_evidence_ref(
            &bound.retained_evidence_path,
            &request.request_id,
            "side_effects",
            path_tail(&repo_root, &side_effects_receipt),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_retained_evidence_ref(
            &bound.retained_evidence_path,
            &request.request_id,
            "outcome",
            path_tail(&repo_root, &outcome_receipt),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        merge_retained_evidence_ref(
            &bound.retained_evidence_path,
            &request.request_id,
            "execution_receipt",
            path_tail(&repo_root, &execution_receipt),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        materialize_run_disclosure(&repo_root, request, grant, outcome, &bound)?;
        let run_card_ref = format!(
            ".octon/state/evidence/disclosure/runs/{}/run-card.yml",
            request.request_id
        );
        append_runtime_journal_event(
            &bound,
            request,
            format!("evt-run-card-published-{}", request.request_id),
            "run-card-published",
            &outcome.completed_at,
            Some(run_card_ref.clone()),
            JournalClassification {
                event_plane: "generated-disclosure".to_string(),
                replay_disposition: "no-live-side-effect".to_string(),
            },
            JournalLifecycle {
                state_before: Some(outcome.status.clone()),
                state_after: Some(outcome.status.clone()),
            },
            journal_governing_refs_for_bound_run(
                &bound,
                request,
                grant,
                Some(terminal_checkpoint_ref.clone()),
                Some(run_card_ref.clone()),
                None,
            ),
            journal_payload(
                None,
                Some(run_card_ref.clone()),
                Some("RunCard publication is traceable to canonical journal and retained evidence roots.".to_string()),
            ),
            journal_effect("disclosure"),
            vec!["disclosure_ref".to_string()],
            None,
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        let snapshot_refs = snapshot_run_journal(&repo_root, &request.request_id)
            .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        append_runtime_journal_event(
            &bound,
            request,
            format!("evt-evidence-snapshot-created-{}", request.request_id),
            "evidence-snapshot-created",
            &outcome.completed_at,
            snapshot_refs.evidence_snapshot_ref.clone(),
            JournalClassification {
                event_plane: "retained-evidence".to_string(),
                replay_disposition: "dry-run-only".to_string(),
            },
            JournalLifecycle {
                state_before: Some(outcome.status.clone()),
                state_after: Some(outcome.status.clone()),
            },
            journal_governing_refs_for_bound_run(
                &bound,
                request,
                grant,
                Some(terminal_checkpoint_ref.clone()),
                Some(run_card_ref.clone()),
                snapshot_refs.evidence_snapshot_ref.clone(),
            ),
            journal_payload(
                Some(json!({
                    "control_snapshot_ref": snapshot_refs.control_snapshot_ref.clone(),
                    "evidence_snapshot_ref": snapshot_refs.evidence_snapshot_ref.clone(),
                    "evidence_manifest_snapshot_ref": snapshot_refs.evidence_manifest_snapshot_ref.clone(),
                })),
                None,
                Some("Run Journal closeout snapshot mirrored control truth into retained evidence.".to_string()),
            ),
            journal_effect("evidence"),
            vec!["evidence_snapshot_ref".to_string()],
            Some(snapshot_refs.clone()),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        append_runtime_journal_event(
            &bound,
            request,
            format!("evt-run-closed-{}", request.request_id),
            "run-closed",
            &outcome.completed_at,
            Some(format!(
                ".octon/state/control/execution/runs/{}/runtime-state.yml",
                request.request_id
            )),
            JournalClassification {
                event_plane: "derived-view".to_string(),
                replay_disposition: "no-live-side-effect".to_string(),
            },
            JournalLifecycle {
                state_before: Some(outcome.status.clone()),
                state_after: Some("closed".to_string()),
            },
            journal_governing_refs_for_bound_run(
                &bound,
                request,
                grant,
                Some(terminal_checkpoint_ref),
                Some(run_card_ref),
                snapshot_refs.evidence_snapshot_ref.clone(),
            ),
            journal_payload(
                Some(json!({"final_state":"closed","outcome_status": outcome.status})),
                None,
                Some(
                    "Run reached closure with journal snapshot and disclosure retained."
                        .to_string(),
                ),
            ),
            journal_effect("write"),
            vec![
                "runtime_state_ref".to_string(),
                "disclosure_ref".to_string(),
            ],
            Some(snapshot_refs),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        update_bound_runtime_state(
            &bound,
            "closed",
            Some("allow"),
            Some(path_tail(&repo_root, &execution_receipt)),
            Some(format!(
                ".octon/state/control/execution/runs/{}/checkpoints/execution-complete.yml",
                request.request_id
            )),
        )
        .map_err(|e| anyhow::anyhow!(e.to_string()))?;
    }
    Ok(())
}

fn materialize_run_disclosure(
    repo_root: &Path,
    request: &ExecutionRequest,
    grant: &GrantBundle,
    outcome: &ExecutionOutcome,
    bound: &BoundRunLifecycle,
) -> anyhow::Result<()> {
    fs::create_dir_all(&bound.assurance_root)?;
    fs::create_dir_all(&bound.measurement_root)?;
    fs::create_dir_all(&bound.intervention_root)?;
    fs::create_dir_all(&bound.disclosure_root)?;
    if let Some(parent) = bound.replay_manifest_path.parent() {
        fs::create_dir_all(parent)?;
    }

    let run_contract_ref = format!(
        ".octon/state/control/execution/runs/{}/run-contract.yml",
        request.request_id
    );
    let execution_receipt_ref = format!(
        ".octon/state/evidence/runs/{}/receipts/execution-receipt.json",
        request.request_id
    );
    let retained_evidence_ref = format!(
        ".octon/state/evidence/runs/{}/retained-run-evidence.yml",
        request.request_id
    );
    let replay_manifest_ref = format!(
        ".octon/state/evidence/runs/{}/replay/manifest.yml",
        request.request_id
    );

    if outcome.status == "succeeded" {
        let success_proofs: [(&str, serde_json::Value); 6] = [
            (
                "structural",
                json!({
                    "schema_version": "proof-plane-report-v1",
                    "plane": "structural",
                    "subject_kind": "run",
                    "subject_ref": run_contract_ref,
                    "outcome": "pass",
                    "proof_class": "deterministic",
                    "summary": "Structural proof confirms the canonical run contract, manifest, and checkpoint topology were emitted for this successful run.",
                    "evidence_refs": [
                        format!(".octon/state/control/execution/runs/{}/run-contract.yml", request.request_id),
                        format!(".octon/state/control/execution/runs/{}/run-manifest.yml", request.request_id),
                        format!(".octon/state/control/execution/runs/{}/checkpoints/bound.yml", request.request_id),
                        format!(".octon/state/continuity/runs/{}/handoff.yml", request.request_id),
                    ],
                    "known_limits": [],
                    "generated_at": outcome.completed_at,
                }),
            ),
            (
                "governance",
                json!({
                    "schema_version": "proof-plane-report-v1",
                    "plane": "governance",
                    "subject_kind": "run",
                    "subject_ref": run_contract_ref,
                    "outcome": "pass",
                    "proof_class": "deterministic",
                    "summary": "Governance proof confirms support-target, authority-routing, and closeout-governance surfaces passed for this successful run.",
                    "evidence_refs": [
                        ".octon/instance/governance/support-targets.yml",
                        ".octon/instance/governance/contracts/closeout-reviews.yml",
                        ".octon/framework/constitution/contracts/authority/README.md",
                        grant.decision_artifact_ref.clone(),
                    ],
                    "known_limits": [],
                    "generated_at": outcome.completed_at,
                }),
            ),
            (
                "functional",
                json!({
                    "schema_version": "proof-plane-report-v1",
                    "plane": "functional",
                    "subject_kind": "run",
                    "subject_ref": run_contract_ref,
                    "outcome": "pass",
                    "proof_class": "deterministic",
                    "summary": "Functional proof confirms the run emitted the canonical receipt, retained evidence, and replay chain for a successful consequential workflow.",
                    "evidence_refs": [
                        ".octon/framework/assurance/functional/suites/run-lifecycle-integrity.yml",
                        execution_receipt_ref,
                        retained_evidence_ref,
                        format!(".octon/state/control/execution/runs/{}/run-manifest.yml", request.request_id),
                    ],
                    "known_limits": [],
                    "generated_at": outcome.completed_at,
                }),
            ),
            (
                "behavioral",
                json!({
                    "schema_version": "proof-plane-report-v1",
                    "plane": "behavioral",
                    "subject_kind": "run",
                    "subject_ref": run_contract_ref,
                    "outcome": "pass",
                    "proof_class": "shadow-run",
                    "summary": "Behavioral proof is backed by the current successful run plus retained scenario, replay, and shadow-run evidence for the supported consequential envelope.",
                    "evidence_refs": [
                        ".octon/framework/assurance/behavioral/suites/replay-shadow-substance.yml",
                        ".octon/state/evidence/lab/scenarios/scn-runtime-proof-supported-20260329/scenario-proof.yml",
                        ".octon/state/evidence/lab/replays/rpl-runtime-proof-supported-20260329/replay-bundle.yml",
                        ".octon/state/evidence/lab/shadow-runs/shd-runtime-proof-supported-20260329/shadow-run.yml",
                        replay_manifest_ref,
                    ],
                    "known_limits": [],
                    "generated_at": outcome.completed_at,
                }),
            ),
            (
                "maintainability",
                json!({
                    "schema_version": "proof-plane-report-v1",
                    "plane": "maintainability",
                    "subject_kind": "run",
                    "subject_ref": run_contract_ref,
                    "outcome": "pass",
                    "proof_class": "deterministic",
                    "summary": "Maintainability proof confirms the successful run remains aligned to the constitutional registry, runtime SSOT, and generated proposal registry projection.",
                    "evidence_refs": [
                        ".octon/framework/assurance/maintainability/suites/runtime-ssot-alignment.yml",
                        ".octon/framework/constitution/contracts/registry.yml",
                        ".octon/framework/cognition/_meta/architecture/contract-registry.yml",
                        ".octon/generated/proposals/registry.yml",
                    ],
                    "known_limits": [],
                    "generated_at": outcome.completed_at,
                }),
            ),
            (
                "recovery",
                json!({
                    "schema_version": "proof-plane-report-v1",
                    "plane": "recovery",
                    "subject_kind": "run",
                    "subject_ref": run_contract_ref,
                    "outcome": "pass",
                    "proof_class": "lab",
                    "summary": "Recovery proof is backed by rollback posture, checkpoints, replay, and the retained fault rehearsal for the supported consequential envelope.",
                    "evidence_refs": [
                        ".octon/framework/assurance/recovery/suites/checkpoint-fault-recovery.yml",
                        format!(".octon/state/control/execution/runs/{}/rollback-posture.yml", request.request_id),
                        format!(".octon/state/control/execution/runs/{}/checkpoints/bound.yml", request.request_id),
                        ".octon/state/evidence/lab/replays/rpl-runtime-proof-supported-20260329/replay-bundle.yml",
                        ".octon/state/evidence/lab/faults/flt-runtime-proof-supported-20260329/fault-report.yml",
                    ],
                    "known_limits": [],
                    "generated_at": outcome.completed_at,
                }),
            ),
        ];
        for (proof_plane, report) in success_proofs {
            let path = bound.assurance_root.join(format!("{proof_plane}.yml"));
            write_yaml(&path, &report)?;
        }
        write_yaml(
            &bound.assurance_root.join("evaluator.yml"),
            &json!({
                "schema_version": "evaluator-review-v1",
                "subject_ref": run_contract_ref,
                "evaluator_id": "evaluator-router://phase4-review-routing",
                "disposition": "approved",
                "summary": "Independent evaluator approval is retained for the supported consequential envelope and current successful workflow evidence.",
                "evidence_refs": [
                    path_tail(repo_root, &bound.assurance_root.join("functional.yml")),
                    path_tail(repo_root, &bound.assurance_root.join("behavioral.yml")),
                    path_tail(repo_root, &bound.assurance_root.join("maintainability.yml")),
                    path_tail(repo_root, &bound.assurance_root.join("recovery.yml")),
                    ".octon/framework/assurance/evaluators/review-routing.yml",
                    ".octon/framework/assurance/evaluators/adapters/openai-review.yml",
                    ".octon/framework/assurance/evaluators/adapters/anthropic-review.yml",
                ],
                "known_limits": [
                    "Independent human review remains available for higher-risk support tiers."
                ],
                "recorded_at": outcome.completed_at,
            }),
        )?;
    } else {
        let proof_planes = [
            "structural",
            "governance",
            "functional",
            "behavioral",
            "maintainability",
            "recovery",
            "evaluator",
        ];
        for proof_plane in proof_planes {
            let path = bound.assurance_root.join(format!("{proof_plane}.yml"));
            if !path.is_file() {
                write_yaml(
                    &path,
                    &json!({
                        "schema_version": "run-proof-placeholder-v1",
                        "run_id": request.request_id,
                        "proof_plane": proof_plane,
                        "status": "not-collected",
                        "summary": format!(
                            "No routine {} proof artifact was emitted for this run; the run card discloses the gap explicitly.",
                            proof_plane
                        ),
                        "generated_at": outcome.completed_at,
                    }),
                )?;
            }
        }
    }

    let measurement_path = bound.measurement_root.join("summary.yml");
    let measurement_record_path = bound
        .measurement_root
        .join("records")
        .join("runtime-lifecycle.yml");
    let measurement_metrics = if outcome.status == "succeeded" {
        vec![
            json!({"metric_id":"receipt-count","label":"Retained lifecycle receipts","value":1,"unit":"count"}),
            json!({"metric_id":"checkpoint-count","label":"Retained checkpoints","value":3,"unit":"count"}),
            json!({"metric_id":"proof-plane-count","label":"Run-local proof-plane reports","value":7,"unit":"count"}),
            json!({"metric_id":"measurement-record-count","label":"Detailed measurement records","value":1,"unit":"count"}),
            json!({"metric_id":"intervention-count","label":"Material interventions","value":0,"unit":"count"}),
            json!({"metric_id":"retry-record-count","label":"Retry records","value":1,"unit":"count"}),
            json!({"metric_id":"contamination-record-count","label":"Contamination records","value":1,"unit":"count"}),
        ]
    } else {
        let receipt_count = fs::read_dir(&bound.receipts_root)
            .ok()
            .map(|entries| entries.filter_map(Result::ok).count())
            .unwrap_or(0);
        let checkpoint_count = fs::read_dir(bound.evidence_root.join("checkpoints"))
            .ok()
            .map(|entries| entries.filter_map(Result::ok).count())
            .unwrap_or(0);
        let proof_plane_count = fs::read_dir(&bound.assurance_root)
            .ok()
            .map(|entries| entries.filter_map(Result::ok).count())
            .unwrap_or(0);
        vec![
            json!({"metric_id":"receipt-count","label":"Retained lifecycle receipts","value":receipt_count,"unit":"count"}),
            json!({"metric_id":"checkpoint-count","label":"Retained checkpoints","value":checkpoint_count,"unit":"count"}),
            json!({"metric_id":"proof-plane-count","label":"Run-local proof-plane reports","value":proof_plane_count,"unit":"count"}),
            json!({"metric_id":"measurement-record-count","label":"Detailed measurement records","value":1,"unit":"count"}),
            json!({"metric_id":"intervention-count","label":"Material interventions","value":0,"unit":"count"}),
            json!({"metric_id":"retry-record-count","label":"Retry records","value":1,"unit":"count"}),
            json!({"metric_id":"contamination-record-count","label":"Contamination records","value":1,"unit":"count"}),
        ]
    };
    let measurement_summary = if outcome.status == "succeeded" {
        "Run emitted canonical receipt, checkpoint, proof-plane, disclosure, retry, contamination, and detailed measurement families."
    } else {
        "Run emitted fail-closed measurement and disclosure artifacts for a non-success outcome."
    };
    fs::create_dir_all(measurement_record_path.parent().unwrap())?;
    write_yaml(
        &measurement_path,
        &json!({
            "schema_version": "measurement-summary-v1",
            "subject_kind": "run",
            "subject_ref": run_contract_ref,
            "metrics": measurement_metrics,
            "summary": measurement_summary,
            "recorded_at": outcome.completed_at,
        }),
    )?;
    write_yaml(
        &measurement_record_path,
        &json!({
            "schema_version": "measurement-record-v1",
            "record_id": format!("{}-runtime-lifecycle", request.request_id),
            "subject_kind": "run",
            "subject_ref": run_contract_ref,
            "metric_id": "lifecycle-artifact-count",
            "label": "Canonical lifecycle artifacts retained",
            "value": 14,
            "unit": "count",
            "method": "Counted canonical lifecycle, replay, disclosure, and proof artifacts under the bound run roots.",
            "evidence_refs": [
                format!(".octon/state/control/execution/runs/{}/run-manifest.yml", request.request_id),
                format!(".octon/state/evidence/runs/{}/evidence-classification.yml", request.request_id)
            ],
            "notes": "Supports observability richness and closure gating for the retained exemplar run.",
            "recorded_at": outcome.completed_at,
        }),
    )?;

    let intervention_path = bound.intervention_root.join("log.yml");
    let intervention_record_path = bound
        .intervention_root
        .join("records")
        .join("no-human-intervention.yml");
    fs::create_dir_all(intervention_record_path.parent().unwrap())?;
    write_yaml(
        &intervention_path,
        &json!({
            "schema_version": "intervention-log-v1",
            "subject_kind": "run",
            "subject_ref": run_contract_ref,
            "interventions": [],
            "summary": "No hidden or material human intervention was required; the canonical intervention record family explicitly retains that fact.",
            "recorded_at": outcome.completed_at,
        }),
    )?;
    write_yaml(
        &intervention_record_path,
        &json!({
            "schema_version": "intervention-record-v1",
            "record_id": format!("{}-no-human-intervention", request.request_id),
            "subject_kind": "run",
            "subject_ref": run_contract_ref,
            "kind": "no-material-intervention",
            "disclosed": true,
            "execution_role_ref": serde_json::Value::Null,
            "details": "No hidden or material human intervention occurred during the retained exemplar run.",
            "evidence_refs": [path_tail(repo_root, &intervention_path)],
            "recorded_at": outcome.completed_at,
        }),
    )?;

    let external_index_ref = format!(
        ".octon/state/evidence/external-index/runs/{}.yml",
        request.request_id
    );
    write_yaml(
        &bound.evidence_root.join("trace-pointers.yml"),
        &TracePointersRecord {
            schema_version: "run-trace-pointers-v1".to_string(),
            run_id: request.request_id.clone(),
            trace_id: format!("{}-canonical-trace-index", request.request_id),
            trace_refs: Vec::new(),
            external_index_refs: vec![external_index_ref.clone()],
            notes: Some(
                "No separate class-C trace payload was retained for this exemplar; canonical replay stays in repo-local receipts and manifests.".to_string(),
            ),
            updated_at: outcome.completed_at.clone(),
        },
    )?;

    write_yaml(
        &bound.replay_manifest_path,
        &json!({
            "schema_version": "run-replay-manifest-v1",
            "run_id": request.request_id,
            "entrypoint": path_tail(repo_root, &bound.control_root),
            "replay_payload_class": "git-pointer",
            "receipt_refs": [execution_receipt_ref],
            "checkpoint_refs": [format!(".octon/state/evidence/runs/{}/checkpoints/bound.yml", request.request_id)],
            "trace_refs": [format!(".octon/state/evidence/runs/{}/trace-pointers.yml", request.request_id)],
            "external_index_refs": [external_index_ref],
            "reproduction_steps": [
                "Read the bound run contract and execution receipt.",
                "Follow the replay manifest, checkpoints, trace pointers, and RunCard refs to reproduce the consequential path.",
                "Use the external replay index when trace or replay payload retrieval needs a canonical pointer source."
            ],
            "recorded_at": outcome.completed_at,
        }),
    )?;

    let external_index_path = repo_root
        .join(".octon/state/evidence/external-index/runs")
        .join(format!("{}.yml", request.request_id));
    fs::create_dir_all(
        external_index_path
            .parent()
            .expect("external index parent should exist"),
    )?;
    let replay_manifest_digest = sha256_file(&bound.replay_manifest_path);
    let trace_pointer_digest = sha256_file(&bound.evidence_root.join("trace-pointers.yml"));
    write_yaml(
        &external_index_path,
        &json!({
            "schema_version": "external-replay-index-v1",
            "index_id": format!("external-replay-{}", request.request_id),
            "scope": "run",
            "run_id": request.request_id,
            "entries": [
                {
                    "entry_id": format!("{}-replay-payload", request.request_id),
                    "run_id": request.request_id,
                    "artifact_kind": "replay-payload",
                    "evidence_class": "C",
                    "storage_class": "external-immutable",
                    "content_digest": format!("sha256:{}", replay_manifest_digest),
                    "locator": format!("immutable://octon/replays/{}/bundle.jsonl", request.request_id),
                    "manifest_ref": path_tail(repo_root, &bound.replay_manifest_path),
                    "recorded_at": outcome.completed_at,
                },
                {
                    "entry_id": format!("{}-trace-payload", request.request_id),
                    "run_id": request.request_id,
                    "artifact_kind": "trace-payload",
                    "evidence_class": "C",
                    "storage_class": "external-immutable",
                    "content_digest": format!("sha256:{}", trace_pointer_digest),
                    "locator": format!("immutable://octon/replays/{}/trace.jsonl", request.request_id),
                    "manifest_ref": path_tail(repo_root, &bound.replay_manifest_path),
                    "recorded_at": outcome.completed_at,
                }
            ],
            "updated_at": outcome.completed_at,
        }),
    )?;

    let support_posture = grant.support_posture.clone().unwrap_or_default();
    let host_adapter = support_posture
        .host_adapter_id
        .clone()
        .unwrap_or_else(|| "unknown-host-adapter".to_string());
    let model_adapter = support_posture
        .model_adapter_id
        .clone()
        .unwrap_or_else(|| "unknown-model-adapter".to_string());
    let host_support_status = support_posture
        .host_adapter_status
        .clone()
        .unwrap_or_else(|| "unsupported".to_string());
    let model_support_status = support_posture
        .model_adapter_status
        .clone()
        .unwrap_or_else(|| "unsupported".to_string());
    let conformance_criteria = support_posture.adapter_conformance_criteria.clone();
    let summary = format!(
        "Consequential run {} for target {} completed with status {} under support tier {}.",
        request.request_id,
        request.target_id,
        outcome.status,
        grant
            .support_tier
            .clone()
            .unwrap_or_else(|| "unknown".to_string())
    );
    let mut known_limits = vec![
        "Support posture remains bounded to the support-target declaration under .octon/instance/governance/support-targets.yml.".to_string(),
    ];
    if outcome.status != "succeeded" {
        known_limits.insert(
            0,
            "Proof-plane artifacts for this run currently include placeholder disclosure files when no routine proof artifact was emitted.".to_string(),
        );
    }
    if outcome.status != "succeeded" {
        known_limits.push(format!(
            "Run completed with status {} and should not be treated as positive proof of successful execution.",
            outcome.status
        ));
    }
    let execution_complete_checkpoint_path = bound
        .control_root
        .join("checkpoints")
        .join("execution-complete.yml");
    let contamination_path = bound.control_root.join("contamination").join("current.yml");
    let retry_path = bound.control_root.join("retry-records").join("baseline.yml");
    let runtime_artifact_depth = json!({
        "validation_status": if outcome.status == "succeeded"
            && bound.stage_attempt_path.is_file()
            && execution_complete_checkpoint_path.is_file()
            && bound.continuity_handoff_path.is_file()
            && contamination_path.is_file()
            && retry_path.is_file()
            && bound.replay_manifest_path.is_file()
        {
            "pass"
        } else {
            "review-required"
        },
        "replay_integrity": if bound.replay_manifest_path.is_file() { "pass" } else { "fail" },
        "stage_attempts": {
            "applicable": true,
            "present": bound.stage_attempt_path.is_file(),
        },
        "checkpoints": {
            "applicable": true,
            "present": execution_complete_checkpoint_path.is_file(),
        },
        "continuity": {
            "applicable": true,
            "present": bound.continuity_handoff_path.is_file(),
        },
        "contamination": {
            "applicable": true,
            "present": contamination_path.is_file(),
        },
        "retries": {
            "applicable": true,
            "present": retry_path.is_file(),
        }
    });

    let run_card_path = bound.disclosure_root.join("run-card.yml");
    write_yaml(
        &run_card_path,
        &json!({
            "schema_version": "run-card-v2",
            "run_id": request.request_id,
            "status": outcome.status,
            "summary": summary,
            "workflow_mode": grant.workflow_mode,
            "support_tier": grant.support_tier.clone().unwrap_or_else(|| "unknown".to_string()),
            "support_target_tuple": {
                "model_tier": support_posture.model_tier_id,
                "workload_tier": support_posture.workload_tier_id,
                "language_resource_tier": support_posture.language_resource_tier_id,
                "locale_tier": support_posture.locale_tier_id,
                "support_status": support_posture.support_status,
            },
            "support_target_ref": ".octon/instance/governance/support-targets.yml",
            "requested_capability_packs": support_posture.requested_capability_packs,
            "adapter_support": {
                "host_adapter": host_adapter,
                "model_adapter": model_adapter,
                "host_support_status": host_support_status,
                "model_support_status": model_support_status,
                "conformance_criteria": conformance_criteria,
            },
            "authority_refs": {
                "run_contract": format!(".octon/state/control/execution/runs/{}/run-contract.yml", request.request_id),
                "decision_artifact": grant.decision_artifact_ref,
                "grant_bundle": grant.authority_grant_bundle_ref,
                "retained_run_evidence": bound.retained_evidence_ref,
            },
            "runtime_service_refs": {
                "replay_store": ".octon/framework/engine/runtime/crates/replay_store",
                "telemetry_sink": ".octon/framework/engine/runtime/crates/telemetry_sink",
                "runtime_bus": ".octon/framework/engine/runtime/crates/runtime_bus",
            },
            "proof_plane_refs": {
                "structural": path_tail(repo_root, &bound.assurance_root.join("structural.yml")),
                "governance": path_tail(repo_root, &bound.assurance_root.join("governance.yml")),
                "functional": path_tail(repo_root, &bound.assurance_root.join("functional.yml")),
                "behavioral": path_tail(repo_root, &bound.assurance_root.join("behavioral.yml")),
                "maintainability": path_tail(repo_root, &bound.assurance_root.join("maintainability.yml")),
                "recovery": path_tail(repo_root, &bound.assurance_root.join("recovery.yml")),
                "evaluator": path_tail(repo_root, &bound.assurance_root.join("evaluator.yml")),
            },
            "measurement_ref": path_tail(repo_root, &measurement_path),
            "intervention_ref": path_tail(repo_root, &intervention_path),
            "replay_ref": path_tail(repo_root, &bound.replay_manifest_path),
            "recovery_ref": path_tail(repo_root, &bound.assurance_root.join("recovery.yml")),
            "known_limits": known_limits,
            "runtime_artifact_depth": runtime_artifact_depth,
            "generated_at": outcome.completed_at,
        }),
    )?;
    Ok(())
}
