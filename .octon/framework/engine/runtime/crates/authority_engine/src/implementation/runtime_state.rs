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
    append_event as append_run_journal_event, load_journal as load_run_journal, JournalActor,
    JournalCausality, JournalClassification, JournalEffect, JournalGoverningRefs, JournalLifecycle,
    JournalPayload, JournalRedaction, RunJournalAppendRequest, RunJournalMaterialization,
    RunJournalSnapshotRefs,
};
use serde::{Deserialize, Serialize};
use serde_json::json;
use sha2::{Digest, Sha256};
use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::{Mutex, OnceLock};

pub(crate) fn bind_run_lifecycle(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    autonomy_state: Option<&ResolvedAutonomyState>,
) -> CoreResult<BoundRunLifecycle> {
    let run_id = request.request_id.as_str();
    let control_root = cfg.run_control_root(run_id);
    let evidence_root = cfg.run_root(run_id);
    let continuity_root = cfg.run_continuity_path(run_id);
    let run_contract_path = run_contract_path(cfg, run_id);
    let run_manifest_path = run_manifest_path(cfg, run_id);
    let continuity_handoff_path = run_continuity_handoff_path(cfg, run_id);
    let runtime_state_path = runtime_state_path(cfg, run_id);
    let rollback_posture_path = rollback_posture_path(cfg, run_id);
    let control_checkpoint_path = control_checkpoint_path(cfg, run_id, "bound");
    let evidence_checkpoint_path = evidence_checkpoint_path(cfg, run_id, "bound");
    let receipts_root = evidence_receipts_root(cfg, run_id);
    let replay_pointers_path = replay_pointers_path(cfg, run_id);
    let trace_pointers_path = trace_pointers_path(cfg, run_id);
    let retained_evidence_path = retained_evidence_path(cfg, run_id);
    let evidence_classification_path = evidence_classification_path(cfg, run_id);
    let stage_attempt_id = stage_attempt_id_for_request(request);
    let stage_attempt_path = stage_attempt_file_path(cfg, run_id, &stage_attempt_id);
    let stage_attempt_root = stage_attempt_dir_path(cfg, run_id);
    let now = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute run binding timestamp: {e}"),
        )
    })?;

    for dir in [
        &control_root,
        &stage_attempt_root,
        &control_root.join("checkpoints"),
        &continuity_root,
        &evidence_root,
        &receipts_root,
        &evidence_root.join("checkpoints"),
        &evidence_root.join("replay"),
    ] {
        fs::create_dir_all(dir).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!(
                    "failed to create canonical run family {}: {e}",
                    dir.display()
                ),
            )
        })?;
    }

    let support_target = requested_support_target_tuple(request)?;
    let support_tier = support_target.workload_tier.clone();
    let requested_capability_packs = infer_requested_capability_packs(request);
    let resolved_intent_ref = request
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
    let resolved_execution_role_ref = request
        .execution_role_ref
        .clone()
        .unwrap_or_else(default_execution_role_ref);
    let reversibility_class = autonomy_state
        .map(|state| state.context.reversibility_class.clone())
        .unwrap_or_else(|| "reversible".to_string());
    let profile_requires_human_review = request
        .scope_constraints
        .executor_profile
        .as_ref()
        .and_then(|profile_name| cfg.execution_governance.executor_profiles.get(profile_name))
        .map(|profile| profile.require_human_review)
        .unwrap_or(false);
    let approval_expected = request.review_requirements.human_approval
        || profile_requires_human_review
        || autonomy_state
            .map(|state| state.approval_required || state.break_glass_required)
            .unwrap_or(false);
    let approval_request_ref =
        format!(".octon/state/control/execution/approvals/requests/{run_id}.yml");
    let expected_approval_ref =
        format!(".octon/state/control/execution/approvals/grants/grant-{run_id}.yml");
    let mission_id = autonomy_state
        .map(|state| state.context.mission_ref.id.clone())
        .or_else(|| request.metadata.get("mission_id").cloned());
    let parent_run_ref = request
        .parent_run_ref
        .as_ref()
        .map(|parent| format!(".octon/state/control/execution/runs/{parent}/run-contract.yml"));
    let rollback_ref = std::env::var("OCTON_EXECUTION_ROLLBACK_REF")
        .ok()
        .filter(|value| !value.trim().is_empty());

    let control_root_rel = path_tail(&cfg.repo_root, &control_root);
    let evidence_root_rel = path_tail(&cfg.repo_root, &evidence_root);
    let run_contract_ref = path_tail(&cfg.repo_root, &run_contract_path);
    let run_manifest_ref = path_tail(&cfg.repo_root, &run_manifest_path);
    let decision_artifact_ref =
        format!(".octon/state/evidence/control/execution/authority-decision-{run_id}.yml");
    let authority_grant_bundle_ref =
        format!(".octon/state/evidence/control/execution/authority-grant-bundle-{run_id}.yml");
    let run_card_ref = format!(".octon/state/evidence/disclosure/runs/{run_id}/run-card.yml");
    let replay_manifest_ref = format!(".octon/state/evidence/runs/{run_id}/replay/manifest.yml");
    let external_replay_index_ref =
        format!(".octon/state/evidence/external-index/runs/{run_id}.yml");
    let host_adapter_ref = format!(
        ".octon/framework/engine/runtime/adapters/host/{}.yml",
        support_target.host_adapter
    );
    let model_adapter_ref = format!(
        ".octon/framework/engine/runtime/adapters/model/{}.yml",
        support_target.model_adapter
    );
    let runtime_state_ref = path_tail(&cfg.repo_root, &runtime_state_path);
    let rollback_posture_ref = path_tail(&cfg.repo_root, &rollback_posture_path);
    let control_checkpoint_ref = path_tail(&cfg.repo_root, &control_checkpoint_path);
    let evidence_checkpoint_ref = path_tail(&cfg.repo_root, &evidence_checkpoint_path);
    let retry_record_path = control_root.join("retry-records").join("baseline.yml");
    let contamination_record_path = control_root.join("contamination").join("current.yml");
    let retry_record_ref = path_tail(&cfg.repo_root, &retry_record_path);
    let contamination_record_ref = path_tail(&cfg.repo_root, &contamination_record_path);
    let receipts_root_rel = path_tail(&cfg.repo_root, &receipts_root);
    let replay_pointers_ref = path_tail(&cfg.repo_root, &replay_pointers_path);
    let trace_pointers_ref = path_tail(&cfg.repo_root, &trace_pointers_path);
    let retained_evidence_ref = path_tail(&cfg.repo_root, &retained_evidence_path);
    let evidence_classification_ref = path_tail(&cfg.repo_root, &evidence_classification_path);
    let stage_attempt_ref = path_tail(&cfg.repo_root, &stage_attempt_path);

    if !run_contract_path.is_file() {
        let scope_in = if request.scope_constraints.read.is_empty() {
            vec![request.caller_path.clone()]
        } else {
            dedupe_strings(&request.scope_constraints.read)
        };
        let mut required_approvals = Vec::<String>::new();
        if approval_expected {
            required_approvals.push(expected_approval_ref.clone());
        }
        let mut required_evidence = vec![
            "decision-artifact".to_string(),
            "execution-receipt".to_string(),
            "policy-receipt".to_string(),
            "replay-pointers".to_string(),
            "trace-pointers".to_string(),
        ];
        if approval_expected {
            required_evidence.push("approval-grant".to_string());
        }
        let required_evidence = dedupe_strings(&required_evidence);
        let mut objective_refs = serde_json::Map::new();
        objective_refs.insert(
            "workspace_objective_ref".to_string(),
            json!(".octon/instance/charter/workspace.md"),
        );
        objective_refs.insert(
            "workspace_machine_charter_ref".to_string(),
            json!(".octon/instance/charter/workspace.yml"),
        );
        if let Some(mission_id) = mission_id.as_ref() {
            objective_refs.insert("mission_id".to_string(), json!(mission_id));
            objective_refs.insert(
                "mission_ref".to_string(),
                json!(format!(
                    ".octon/instance/orchestration/missions/{mission_id}/mission.yml"
                )),
            );
        }
        write_yaml(
            &run_contract_path,
            &json!({
                "schema_version": "run-contract-v1",
                "run_id": run_id,
                "mission_mode": if mission_id.is_some() { "required" } else { "none" },
                "objective_refs": objective_refs,
                "objective_summary": format!("Execute {} under the canonical run-first constitutional runtime.", request.target_id),
                "scope_in": scope_in,
                "scope_out": dedupe_strings(&request.scope_constraints.write),
                "exclusions": [".octon/inputs/exploratory/ideation/**"],
                "done_when": [
                    "The bound run reaches a terminal status with canonical evidence and disclosure artifacts retained.",
                    "The retained run bundle validates against support-target and replay/disclosure gates."
                ],
                "acceptance_criteria": [
                    "Canonical replay, trace, and disclosure references resolve from the run root.",
                    "Authority and support-target posture remain bounded to the declared supported envelope."
                ],
                "materiality": request.risk_tier,
                "protected_zones": [
                    ".octon/framework/constitution/**",
                    ".octon/instance/governance/**"
                ],
                "requested_capabilities": dedupe_strings(&request.requested_capabilities),
                "requested_capability_packs": requested_capability_packs.clone(),
                "risk_class": request.risk_tier,
                "intent_ref": {
                    "id": resolved_intent_ref.id,
                    "version": resolved_intent_ref.version,
                },
                "execution_role_ref": {
                    "kind": resolved_execution_role_ref.kind,
                    "id": resolved_execution_role_ref.id,
                },
                "reversibility_class": reversibility_class,
                "support_tier": support_tier,
                "support_target": {
                    "model_tier": support_target.model_tier.clone(),
                    "workload_tier": support_target.workload_tier.clone(),
                    "language_resource_tier": support_target.language_resource_tier.clone(),
                    "locale_tier": support_target.locale_tier.clone(),
                    "host_adapter": support_target.host_adapter.clone(),
                    "model_adapter": support_target.model_adapter.clone(),
                },
                "support_target_ref": ".octon/instance/governance/support-targets.yml",
                "required_approvals": required_approvals,
                "required_evidence": required_evidence,
                "start_conditions": [
                    "Canonical support-target tuple remains admitted for the selected host and model adapters.",
                    "Canonical run control, evidence, and disclosure roots are writable before consequential execution starts."
                ],
                "stop_conditions": [
                    "Stop immediately on STAGE_ONLY, ESCALATE, or DENY authority routes.",
                    "Stop if replay, trace, or disclosure references cannot be materialized under canonical run roots."
                ],
                "retry_class": "manual_review_required",
                "closure_conditions": [
                    "Run binds canonical runtime-state, rollback-posture, checkpoints, and evidence roots before consequential side effects.",
                    "Canonical receipts and replay pointers remain linked to the run root."
                ],
                "disclosure_expectations": [
                    "Emit RunCard, replay manifest, replay pointers, trace pointers, and evidence classification.",
                    "Retain detailed measurement and intervention records before any claim promotion."
                ],
                "stage_attempt_root": path_tail(&cfg.repo_root, &stage_attempt_root),
                "run_manifest_ref": run_manifest_ref,
                "decision_artifact_ref": decision_artifact_ref,
                "authority_grant_bundle_ref": authority_grant_bundle_ref,
                "run_card_ref": run_card_ref,
                "host_adapter_ref": host_adapter_ref,
                "model_adapter_ref": model_adapter_ref,
                "external_replay_index_ref": external_replay_index_ref,
                "control_checkpoint_root": path_tail(&cfg.repo_root, &control_root.join("checkpoints")),
                "runtime_state_ref": runtime_state_ref,
                "rollback_posture_ref": rollback_posture_ref,
                "evidence_root": evidence_root_rel,
                "receipt_root": receipts_root_rel,
                "replay_pointers_ref": replay_pointers_ref,
                "rollback_or_compensation_expectation": "Wave 3 binds rollback posture and contamination state under the canonical run root before consequential side effects.",
                "contract_version": "1.1.0",
                "issued_at": now,
                "expires_at": serde_json::Value::Null,
                "status": "bound",
                "created_at": now,
                "updated_at": now,
                "notes_ref": stage_attempt_ref
            }),
        )
        .map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to write canonical run contract {}: {e}", run_contract_path.display()),
            )
        })?;
    }

    write_yaml(
        &run_manifest_path,
        &json!({
            "schema_version": "run-manifest-v2",
            "run_id": run_id,
            "run_contract_ref": run_contract_ref,
            "authority_bundle_ref": authority_grant_bundle_ref,
            "intent_ref": {
                "id": resolved_intent_ref.id,
                "version": resolved_intent_ref.version,
            },
            "execution_role_ref": {
                "kind": resolved_execution_role_ref.kind,
                "id": resolved_execution_role_ref.id,
            },
            "support_tier": support_tier,
            "support_target": {
                "model_tier": support_target.model_tier.clone(),
                "workload_tier": support_target.workload_tier.clone(),
                "language_resource_tier": support_target.language_resource_tier.clone(),
                "locale_tier": support_target.locale_tier.clone(),
                "host_adapter": support_target.host_adapter.clone(),
                "model_adapter": support_target.model_adapter.clone(),
            },
            "support_target_ref": ".octon/instance/governance/support-targets.yml",
            "requested_capability_packs": requested_capability_packs.clone(),
            "decision_artifact_ref": decision_artifact_ref,
            "authority_grant_bundle_ref": authority_grant_bundle_ref,
            "approval_request_ref": if approval_expected { Some(approval_request_ref.clone()) } else { None },
            "approval_grant_refs": if approval_expected { vec![expected_approval_ref.clone()] } else { Vec::<String>::new() },
            "host_adapter_ref": host_adapter_ref,
            "model_adapter_ref": model_adapter_ref,
            "runtime_state_ref": runtime_state_ref,
            "run_continuity_ref": path_tail(&cfg.repo_root, &continuity_handoff_path),
            "stage_attempt_root": path_tail(&cfg.repo_root, &stage_attempt_root),
            "control_checkpoint_root": path_tail(&cfg.repo_root, &control_root.join("checkpoints")),
            "rollback_posture_ref": rollback_posture_ref,
            "evidence_root": evidence_root_rel,
            "receipt_root": receipts_root_rel,
            "assurance_root": format!(".octon/state/evidence/runs/{run_id}/assurance"),
            "measurement_root": format!(".octon/state/evidence/runs/{run_id}/measurements"),
            "intervention_root": format!(".octon/state/evidence/runs/{run_id}/interventions"),
            "disclosure_root": format!(".octon/state/evidence/disclosure/runs/{run_id}"),
            "retained_evidence_ref": retained_evidence_ref,
            "replay_pointers_ref": replay_pointers_ref,
            "trace_pointers_ref": trace_pointers_ref,
            "evidence_classification_ref": evidence_classification_ref,
            "run_card_ref": run_card_ref,
            "external_replay_index_ref": external_replay_index_ref,
            "created_at": now,
            "updated_at": now,
            "mission_id": mission_id,
            "parent_run_ref": parent_run_ref
        }),
    )
    .map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write canonical run manifest {}: {e}", run_manifest_path.display()),
        )
    })?;

    if !stage_attempt_path.is_file() {
        write_yaml(
            &stage_attempt_path,
            &json!({
                "schema_version": "stage-attempt-v1",
                "run_id": run_id,
                "stage_attempt_id": stage_attempt_id,
                "stage_ref": stage_ref_for_request(request),
                "attempt_kind": "initial",
                "status": "planned",
                "objective_ref": run_contract_ref,
                "objective_slice": format!("Stage {} for target {}", stage_ref_for_request(request), request.target_id),
                "entry_criteria": [
                    "Run contract is bound under the canonical run root.",
                    "Support-target tuple remains admitted for the bounded consequential envelope."
                ],
                "exit_criteria": [
                    "Stage receipts, replay refs, and disclosure refs are retained under canonical run roots.",
                    "Stage status reaches a terminal state that agrees with the decision artifact."
                ],
                "requested_capabilities": dedupe_strings(&request.requested_capabilities),
                "allowed_capabilities": dedupe_strings(&request.requested_capabilities),
                "allowed_zones": dedupe_strings(&vec![
                    path_tail(&cfg.repo_root, &control_root),
                    evidence_root_rel.clone()
                ]),
                "retry_class": "manual_review_required",
                "predecessor_refs": [],
                "successor_refs": [],
                "evidence_refs": [],
                "completion_status": "criteria-pending",
                "rollback_candidate": reversibility_class != "irreversible",
                "rollback_notes": "Restore from the canonical checkpoint and reissue the stage if retained evidence becomes inconsistent.",
                "issued_by": resolved_execution_role_ref.id,
                "validated_by": "octon-kernel",
                "created_at": now,
                "updated_at": now
            }),
        )
        .map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!(
                    "failed to write canonical stage attempt {}: {e}",
                    stage_attempt_path.display()
                ),
            )
        })?;
    }

    let mut runtime_state: RuntimeStateRecord = read_yaml_or_default(&runtime_state_path)?;
    if runtime_state.created_at.trim().is_empty() {
        runtime_state.created_at = now.clone();
    }
    runtime_state.schema_version = "runtime-state-v2".to_string();
    runtime_state.run_id = run_id.to_string();
    runtime_state.status = "authorizing".to_string();
    runtime_state.workflow_mode = request.workflow_mode.clone();
    runtime_state.decision_state = Some("pending".to_string());
    runtime_state.run_contract_ref = run_contract_ref.clone();
    runtime_state.run_manifest_ref = run_manifest_ref.clone();
    runtime_state.current_stage_attempt_id = Some(stage_attempt_id.clone());
    runtime_state.last_checkpoint_ref = Some(control_checkpoint_ref.clone());
    runtime_state.mission_id = mission_id.clone();
    runtime_state.parent_run_ref = parent_run_ref.clone();
    runtime_state.source_ledger_ref =
        Some(path_tail(&cfg.repo_root, &run_journal_path(cfg, run_id)));
    runtime_state.source_ledger_manifest_ref = Some(path_tail(
        &cfg.repo_root,
        &run_journal_manifest_path(cfg, run_id),
    ));
    runtime_state.rollback_posture_ref = Some(rollback_posture_ref.clone());
    runtime_state.updated_at = now.clone();

    let rollback_strategy = if rollback_ref.is_some() || reversibility_class == "reversible" {
        "rollback"
    } else if reversibility_class == "compensable" {
        "compensate"
    } else {
        "observe_only"
    };
    let rollback_posture = RollbackPostureRecord {
        schema_version: "run-rollback-posture-v1".to_string(),
        run_id: run_id.to_string(),
        reversibility_class: reversibility_class.clone(),
        rollback_strategy: if rollback_ref.is_some() {
            "checkpoint_restore".to_string()
        } else {
            rollback_strategy.to_string()
        },
        rollback_ref: rollback_ref.clone(),
        rollback_handle: autonomy_state.and_then(|state| state.rollback_handle.clone()),
        compensation_handle: autonomy_state.and_then(|state| state.compensation_handle.clone()),
        recovery_window: autonomy_state.map(|state| state.recovery_window.clone()),
        contamination_state: "clean".to_string(),
        retry_record_ref: retry_record_ref.clone(),
        contamination_record_ref: contamination_record_ref.clone(),
        resume_allowed: true,
        reset_action: "No reset required; canonical run evidence remained coherent.".to_string(),
        invalidated_artifacts: Vec::new(),
        hard_reset_required: false,
        posture_source: Some(if autonomy_state.is_some() {
            "mission-autonomy".to_string()
        } else {
            "run-contract-default".to_string()
        }),
        updated_at: now.clone(),
    };
    write_yaml(&rollback_posture_path, &rollback_posture).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write rollback posture {}: {e}",
                rollback_posture_path.display()
            ),
        )
    })?;

    fs::create_dir_all(retry_record_path.parent().unwrap()).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to create retry-record directory {}: {e}",
                retry_record_path.parent().unwrap().display()
            ),
        )
    })?;
    write_yaml(
        &retry_record_path,
        &json!({
            "schema_version": "run-retry-record-v1",
            "retry_id": format!("{run_id}-baseline"),
            "run_id": run_id,
            "stage_attempt_id": stage_attempt_id,
            "retry_class": "manual_review_required",
            "attempt_counter": 1,
            "attempt_limit": 1,
            "route_taken": "allow",
            "result": "not-needed",
            "triggering_artifact_ref": stage_attempt_ref,
            "notes": "The initial stage attempt completed without requiring a retry.",
            "recorded_at": now,
        }),
    )?;
    fs::create_dir_all(contamination_record_path.parent().unwrap()).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to create contamination directory {}: {e}",
                contamination_record_path.parent().unwrap().display()
            ),
        )
    })?;
    write_yaml(
        &contamination_record_path,
        &json!({
            "schema_version": "run-contamination-record-v1",
            "contamination_id": format!("{run_id}-current"),
            "run_id": run_id,
            "subject_ref": control_checkpoint_ref,
            "contamination_state": "clean",
            "contamination_class": "none",
            "reset_action": "No reset required; canonical run evidence remained coherent.",
            "invalidated_artifacts": [],
            "replay_continuity": "preserved",
            "approved_by": serde_json::Value::Null,
            "notes": "No contamination or reset event was recorded for the retained run bundle.",
            "recorded_at": now,
        }),
    )?;

    let checkpoint = RunCheckpointRecord {
        schema_version: "run-checkpoint-v1".to_string(),
        run_id: run_id.to_string(),
        checkpoint_id: "bound".to_string(),
        stage_attempt_id: stage_attempt_id.clone(),
        checkpoint_kind: "binding".to_string(),
        status: "materialized".to_string(),
        control_ref: control_checkpoint_ref.clone(),
        evidence_ref: Some(evidence_checkpoint_ref.clone()),
        notes: Some("Canonical run root bound before consequential side effects.".to_string()),
        created_at: now.clone(),
        updated_at: now.clone(),
    };
    write_yaml(&control_checkpoint_path, &checkpoint).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write control checkpoint {}: {e}",
                control_checkpoint_path.display()
            ),
        )
    })?;
    write_yaml(&evidence_checkpoint_path, &checkpoint).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write evidence checkpoint {}: {e}",
                evidence_checkpoint_path.display()
            ),
        )
    })?;

    let replay = ReplayPointersRecord {
        schema_version: "run-replay-pointers-v1".to_string(),
        run_id: run_id.to_string(),
        replay_manifest_refs: vec![replay_manifest_ref],
        receipt_refs: Vec::new(),
        checkpoint_refs: vec![evidence_checkpoint_ref.clone()],
        trace_refs: vec![trace_pointers_ref.clone()],
        external_index_refs: vec![external_replay_index_ref.clone()],
        updated_at: now.clone(),
    };
    write_yaml(&replay_pointers_path, &replay).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write replay pointers {}: {e}",
                replay_pointers_path.display()
            ),
        )
    })?;
    write_yaml(
        &trace_pointers_path,
        &TracePointersRecord {
            schema_version: "run-trace-pointers-v1".to_string(),
            run_id: run_id.to_string(),
            trace_id: format!("{run_id}-trace-index"),
            trace_refs: Vec::new(),
            external_index_refs: vec![external_replay_index_ref.clone()],
            notes: Some(
                "No separate class-C trace payload was retained at bind time; canonical trace pointers are updated as the run completes.".to_string(),
            ),
            updated_at: now.clone(),
        },
    )?;

    let retained = RetainedRunEvidenceRecord {
        schema_version: "retained-run-evidence-v1".to_string(),
        run_id: run_id.to_string(),
        evidence_refs: BTreeMap::from([
            ("run_contract".to_string(), run_contract_ref.clone()),
            ("run_manifest".to_string(), run_manifest_ref.clone()),
            ("runtime_state".to_string(), runtime_state_ref.clone()),
            ("rollback_posture".to_string(), rollback_posture_ref.clone()),
            ("retry_record".to_string(), retry_record_ref.clone()),
            (
                "contamination_record".to_string(),
                contamination_record_ref.clone(),
            ),
            (
                "control_checkpoint".to_string(),
                control_checkpoint_ref.clone(),
            ),
            (
                "evidence_checkpoint".to_string(),
                evidence_checkpoint_ref.clone(),
            ),
            ("replay_pointers".to_string(), replay_pointers_ref.clone()),
            ("trace_pointers".to_string(), trace_pointers_ref.clone()),
        ]),
        updated_at: now.clone(),
    };
    write_yaml(&retained_evidence_path, &retained).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write retained run evidence manifest {}: {e}",
                retained_evidence_path.display()
            ),
        )
    })?;
    write_yaml(
        &evidence_classification_path,
        &json!({
            "schema_version": "run-evidence-classification-v1",
            "run_id": run_id,
            "artifacts": [
                {
                    "artifact_id": "run-contract",
                    "artifact_ref": run_contract_ref,
                    "evidence_class": "A",
                    "storage_class": "git-inline"
                },
                {
                "artifact_id": "run-manifest",
                "artifact_ref": run_manifest_ref,
                "evidence_class": "A",
                "storage_class": "git-inline"
            },
            {
                "artifact_id": "runtime-state",
                "artifact_ref": runtime_state_ref,
                "evidence_class": "A",
                "storage_class": "git-inline"
            },
            {
                "artifact_id": "retry-record",
                "artifact_ref": retry_record_ref,
                "evidence_class": "A",
                "storage_class": "git-inline"
            },
            {
                "artifact_id": "contamination-record",
                "artifact_ref": contamination_record_ref,
                "evidence_class": "A",
                "storage_class": "git-inline"
            },
            {
                "artifact_id": "replay-pointers",
                "artifact_ref": replay_pointers_ref,
                "evidence_class": "B",
                "storage_class": "git-pointer"
            },
            {
                "artifact_id": "trace-pointers",
                "artifact_ref": trace_pointers_ref,
                "evidence_class": "B",
                "storage_class": "git-pointer"
            },
            {
                "artifact_id": "external-replay-index",
                "artifact_ref": external_replay_index_ref,
                "evidence_class": "B",
                "storage_class": "git-pointer"
            }
            ],
            "updated_at": now
        }),
    )
    .map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write evidence classification {}: {e}",
                evidence_classification_path.display()
            ),
        )
    })?;
    let journal_materialization = initialize_run_journal(
        cfg,
        run_id,
        &control_root,
        &control_root_rel,
        &run_contract_ref,
        &run_manifest_ref,
        &runtime_state_ref,
        &rollback_posture_ref,
        &control_checkpoint_ref,
        &stage_attempt_ref,
        &support_target,
        &now,
    )?;
    runtime_state.schema_version = "runtime-state-v2".to_string();
    runtime_state.source_ledger_ref =
        Some(path_tail(&cfg.repo_root, &run_journal_path(cfg, run_id)));
    runtime_state.source_ledger_manifest_ref = Some(path_tail(
        &cfg.repo_root,
        &run_journal_manifest_path(cfg, run_id),
    ));
    runtime_state.support_target_tuple_ref = Some(support_target_tuple_id(&support_target));
    runtime_state.rollback_posture_ref = Some(rollback_posture_ref.clone());
    runtime_state.last_applied_event_id = journal_materialization.last_applied_event_id.clone();
    runtime_state.last_applied_sequence = journal_materialization.last_applied_sequence;
    runtime_state.last_applied_event_hash = journal_materialization.last_applied_event_hash.clone();
    runtime_state.materialized_at = journal_materialization.materialized_at.clone();
    runtime_state.materialized_by = Some(RuntimeStateMaterializedByRecord {
        actor_class: "runtime".to_string(),
        actor_ref: ".octon/framework/engine/runtime/crates/runtime_bus".to_string(),
    });
    runtime_state.drift_status = Some("in-sync".to_string());
    write_yaml(&runtime_state_path, &runtime_state).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to rewrite runtime-state {} after journal materialization: {e}",
                runtime_state_path.display()
            ),
        )
    })?;
    sync_run_continuity(
        &RunContinuityRecord {
            schema_version: "run-continuity-v1".to_string(),
            run_id: run_id.to_string(),
            status: "authorizing".to_string(),
            run_contract_ref: run_contract_ref.clone(),
            run_manifest_ref: run_manifest_ref.clone(),
            retained_evidence_ref: retained_evidence_ref.clone(),
            replay_pointers_ref: replay_pointers_ref.clone(),
            evidence_classification_ref: evidence_classification_ref.clone(),
            last_receipt_ref: None,
            last_checkpoint_ref: control_checkpoint_ref.clone(),
            resume_from_stage_attempt_id: Some(stage_attempt_id.clone()),
            mission_id: mission_id.clone(),
            parent_run_ref: parent_run_ref.clone(),
            next_action: next_action_for_run_status("authorizing"),
            updated_at: now.clone(),
        },
        &continuity_handoff_path,
    )?;

    let assurance_root = evidence_root.join("assurance");
    let measurement_root = evidence_root.join("measurements");
    let intervention_root = evidence_root.join("interventions");
    let replay_manifest_path = evidence_root.join("replay").join("manifest.yml");
    Ok(BoundRunLifecycle {
        control_root,
        evidence_root,
        assurance_root,
        measurement_root,
        intervention_root,
        disclosure_root: cfg
            .repo_root
            .join(".octon/state/evidence/disclosure/runs")
            .join(run_id),
        replay_manifest_path,
        continuity_handoff_path,
        _run_manifest_path: run_manifest_path,
        runtime_state_path,
        receipts_root,
        replay_pointers_path,
        _evidence_classification_path: evidence_classification_path,
        retained_evidence_path,
        stage_attempt_path,
        control_root_rel,
        evidence_root_rel,
        control_checkpoint_ref,
        run_manifest_ref,
        receipts_root_rel,
        replay_pointers_ref,
        trace_pointers_ref,
        evidence_classification_ref,
        retained_evidence_ref,
        stage_attempt_ref,
        stage_attempt_id,
    })
}

fn initialize_run_journal(
    cfg: &RuntimeConfig,
    run_id: &str,
    control_root: &Path,
    control_root_rel: &str,
    run_contract_ref: &str,
    run_manifest_ref: &str,
    runtime_state_ref: &str,
    rollback_posture_ref: &str,
    control_checkpoint_ref: &str,
    stage_attempt_ref: &str,
    support_target: &SupportTargetTuple,
    recorded_at: &str,
) -> CoreResult<RunJournalMaterialization> {
    let support_target_tuple_ref = Some(support_target_tuple_id(support_target));

    let created = append_run_journal(
        control_root,
        RunJournalAppendRequest {
            run_id: run_id.to_string(),
            control_root_ref: control_root_rel.to_string(),
            event_id: format!("evt-001-run-created-{run_id}"),
            event_type: "run-created".to_string(),
            recorded_at: recorded_at.to_string(),
            subject_ref: Some(run_contract_ref.to_string()),
            actor: runtime_bus_actor("authority-engine"),
            classification: JournalClassification {
                event_plane: "committed-effect".to_string(),
                replay_disposition: "dry-run-only".to_string(),
            },
            lifecycle: JournalLifecycle {
                state_before: Some("created".to_string()),
                state_after: Some("bound".to_string()),
            },
            governing_refs: journal_governing_refs(
                run_contract_ref,
                run_manifest_ref,
                support_target_tuple_ref.clone(),
                Some(rollback_posture_ref.to_string()),
                None,
                None,
            ),
            payload: inline_payload(
                Some(serde_json::json!({
                    "summary": "Canonical run root created for the bound consequential execution unit.",
                    "run_control_root_ref": control_root_rel,
                })),
                Some("Run created.".to_string()),
            ),
            effect: journal_effect("write"),
            redaction: unredacted(),
            causality: JournalCausality::default(),
            governing_manifest_roles: vec!["run_contract_ref".to_string()],
            materialization: None,
            snapshot_refs: None,
            drift_status: Some("in-sync".to_string()),
            drift_ref: None,
        },
    )?;

    let bound = append_run_journal(
        control_root,
        RunJournalAppendRequest {
            run_id: run_id.to_string(),
            control_root_ref: control_root_rel.to_string(),
            event_id: format!("evt-002-run-bound-{run_id}"),
            event_type: "run-bound".to_string(),
            recorded_at: recorded_at.to_string(),
            subject_ref: Some(run_manifest_ref.to_string()),
            actor: runtime_bus_actor("authority-engine"),
            classification: JournalClassification {
                event_plane: "committed-effect".to_string(),
                replay_disposition: "dry-run-only".to_string(),
            },
            lifecycle: JournalLifecycle {
                state_before: Some("bound".to_string()),
                state_after: Some("bound".to_string()),
            },
            governing_refs: journal_governing_refs(
                run_contract_ref,
                run_manifest_ref,
                support_target_tuple_ref.clone(),
                Some(rollback_posture_ref.to_string()),
                Some(stage_attempt_ref.to_string()),
                None,
            ),
            payload: inline_payload(
                Some(serde_json::json!({
                    "stage_attempt_ref": stage_attempt_ref,
                    "runtime_state_ref": runtime_state_ref,
                })),
                Some("Run binding became authoritative.".to_string()),
            ),
            effect: journal_effect("write"),
            redaction: unredacted(),
            causality: JournalCausality::default(),
            governing_manifest_roles: vec!["run_manifest_ref".to_string()],
            materialization: None,
            snapshot_refs: None,
            drift_status: Some("in-sync".to_string()),
            drift_ref: None,
        },
    )?;

    let _requested = append_run_journal(
        control_root,
        RunJournalAppendRequest {
            run_id: run_id.to_string(),
            control_root_ref: control_root_rel.to_string(),
            event_id: format!("evt-003-authority-requested-{run_id}"),
            event_type: "authority-requested".to_string(),
            recorded_at: recorded_at.to_string(),
            subject_ref: Some(runtime_state_ref.to_string()),
            actor: runtime_bus_actor("authority-engine"),
            classification: JournalClassification {
                event_plane: "requested-action".to_string(),
                replay_disposition: "not-applicable".to_string(),
            },
            lifecycle: JournalLifecycle {
                state_before: Some("bound".to_string()),
                state_after: Some("authorizing".to_string()),
            },
            governing_refs: journal_governing_refs(
                run_contract_ref,
                run_manifest_ref,
                support_target_tuple_ref.clone(),
                Some(rollback_posture_ref.to_string()),
                Some(stage_attempt_ref.to_string()),
                None,
            ),
            payload: inline_payload(
                Some(serde_json::json!({
                    "runtime_state_ref": runtime_state_ref,
                    "support_target_tuple_ref": support_target_tuple_ref,
                })),
                Some("Authorization routing entered the canonical journal.".to_string()),
            ),
            effect: journal_effect("authorization"),
            redaction: unredacted(),
            causality: JournalCausality::default(),
            governing_manifest_roles: vec!["runtime_state_ref".to_string()],
            materialization: None,
            snapshot_refs: None,
            drift_status: Some("in-sync".to_string()),
            drift_ref: None,
        },
    )?;

    let checkpoint = append_run_journal(
        control_root,
        RunJournalAppendRequest {
            run_id: run_id.to_string(),
            control_root_ref: control_root_rel.to_string(),
            event_id: format!("evt-004-checkpoint-bound-{run_id}"),
            event_type: "checkpoint-created".to_string(),
            recorded_at: recorded_at.to_string(),
            subject_ref: Some(control_checkpoint_ref.to_string()),
            actor: runtime_bus_actor("runtime"),
            classification: JournalClassification {
                event_plane: "retained-evidence".to_string(),
                replay_disposition: "dry-run-only".to_string(),
            },
            lifecycle: JournalLifecycle {
                state_before: Some("authorizing".to_string()),
                state_after: Some("authorizing".to_string()),
            },
            governing_refs: journal_governing_refs(
                run_contract_ref,
                run_manifest_ref,
                support_target_tuple_ref,
                Some(rollback_posture_ref.to_string()),
                Some(stage_attempt_ref.to_string()),
                Some(control_checkpoint_ref.to_string()),
            ),
            payload: inline_payload(
                Some(serde_json::json!({"checkpoint_kind":"binding"})),
                Some("Binding checkpoint materialized.".to_string()),
            ),
            effect: journal_effect("evidence"),
            redaction: unredacted(),
            causality: JournalCausality::default(),
            governing_manifest_roles: vec!["checkpoint_ref".to_string()],
            materialization: None,
            snapshot_refs: None,
            drift_status: Some("in-sync".to_string()),
            drift_ref: None,
        },
    )?;

    Ok(materialization_for_event(
        runtime_state_ref,
        ".octon/framework/engine/runtime/crates/runtime_bus",
        &checkpoint.event,
    ))
}

fn append_run_journal(
    control_root: &Path,
    request: RunJournalAppendRequest,
) -> CoreResult<octon_runtime_bus::RunJournalAppendReceipt> {
    append_run_journal_event(control_root, request).map_err(|error| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to append canonical run journal event: {error}"),
        )
    })
}

fn runtime_bus_actor(actor_class: &str) -> JournalActor {
    JournalActor {
        actor_class: actor_class.to_string(),
        actor_ref: ".octon/framework/engine/runtime/crates/runtime_bus".to_string(),
    }
}

fn journal_governing_refs(
    run_contract_ref: &str,
    run_manifest_ref: &str,
    support_target_tuple_ref: Option<String>,
    rollback_posture_ref: Option<String>,
    stage_attempt_ref: Option<String>,
    checkpoint_ref: Option<String>,
) -> JournalGoverningRefs {
    JournalGoverningRefs {
        run_contract_ref: run_contract_ref.to_string(),
        run_manifest_ref: run_manifest_ref.to_string(),
        execution_request_ref: None,
        authority_route_receipt_ref: None,
        grant_bundle_ref: None,
        policy_receipt_ref: None,
        approval_ref: None,
        lease_ref: None,
        revocation_ref: None,
        support_target_tuple_ref,
        rollback_plan_ref: None,
        rollback_posture_ref,
        context_pack_ref: None,
        stage_attempt_ref,
        checkpoint_ref,
        validator_result_ref: None,
        evidence_snapshot_ref: None,
        disclosure_ref: None,
        drift_ref: None,
        continuity_ref: None,
        additional_refs: Vec::new(),
    }
}

fn inline_payload(
    typed_body: Option<serde_json::Value>,
    summary: Option<String>,
) -> JournalPayload {
    JournalPayload {
        payload_kind: if typed_body.is_some() {
            "inline-typed".to_string()
        } else {
            "none".to_string()
        },
        schema_ref: None,
        typed_body,
        artifact_ref: None,
        artifact_hash: None,
        content_type: None,
        summary,
    }
}

fn journal_effect(effect_class: &str) -> JournalEffect {
    JournalEffect {
        effect_class: effect_class.to_string(),
        reversibility_class: "reversible".to_string(),
        evidence_class: "required".to_string(),
    }
}

fn unredacted() -> JournalRedaction {
    JournalRedaction {
        redacted: false,
        justification: None,
        lineage_ref: None,
        omitted_fields: Vec::new(),
    }
}

fn materialization_for_event(
    runtime_state_ref: &str,
    materialized_by_ref: &str,
    event: &octon_runtime_bus::RunJournalEvent,
) -> RunJournalMaterialization {
    RunJournalMaterialization {
        runtime_state_ref: Some(runtime_state_ref.to_string()),
        last_applied_event_id: Some(event.event_id.clone()),
        last_applied_sequence: Some(event.sequence),
        last_applied_event_hash: Some(event.integrity.event_hash.clone()),
        materialized_at: Some(event.recorded_at.clone()),
        materialized_by_ref: Some(materialized_by_ref.to_string()),
    }
}

pub(crate) fn update_bound_runtime_state(
    bound: &BoundRunLifecycle,
    status: &str,
    decision_state: Option<&str>,
    last_receipt_ref: Option<String>,
    last_checkpoint_ref: Option<String>,
) -> CoreResult<()> {
    let mut state: RuntimeStateRecord = read_yaml_or_default(&bound.runtime_state_path)?;
    if state.created_at.trim().is_empty() {
        state.created_at = now_rfc3339().map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to compute runtime-state timestamp: {e}"),
            )
        })?;
    }
    state.schema_version = "runtime-state-v2".to_string();
    state.run_id = bound
        .control_root
        .file_name()
        .and_then(|value| value.to_str())
        .unwrap_or_default()
        .to_string();
    state.status = status.to_string();
    if state.run_manifest_ref.trim().is_empty() {
        state.run_manifest_ref = bound.run_manifest_ref.clone();
    }
    if state.source_ledger_ref.is_none() {
        state.source_ledger_ref = Some(format!(
            ".octon/state/control/execution/runs/{}/events.ndjson",
            state.run_id
        ));
    }
    if state.source_ledger_manifest_ref.is_none() {
        state.source_ledger_manifest_ref = Some(format!(
            ".octon/state/control/execution/runs/{}/events.manifest.yml",
            state.run_id
        ));
    }
    if state.drift_status.is_none() {
        state.drift_status = Some("in-sync".to_string());
    }
    if state.context_pack_ref.is_none() {
        let context_pack = bound
            .evidence_root
            .join("context")
            .join("context-pack.json");
        if context_pack.is_file() {
            state.context_pack_ref = Some(format!(
                ".octon/state/evidence/runs/{}/context/context-pack.json",
                state.run_id
            ));
        }
    }
    state.decision_state = decision_state
        .map(ToOwned::to_owned)
        .or(state.decision_state);
    if let Some(value) = last_receipt_ref {
        state.last_receipt_ref = Some(value);
    }
    if let Some(value) = last_checkpoint_ref {
        state.last_checkpoint_ref = Some(value);
    }
    state.updated_at = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute runtime-state timestamp: {e}"),
        )
    })?;
    state.materialized_at = Some(state.updated_at.clone());
    state.materialized_by = Some(RuntimeStateMaterializedByRecord {
        actor_class: "runtime".to_string(),
        actor_ref: ".octon/framework/engine/runtime/crates/runtime_bus".to_string(),
    });
    if let Ok(journal) = load_run_journal(&bound.control_root) {
        if let Some(last_event) = journal.events.last() {
            state.last_applied_event_id = Some(last_event.event_id.clone());
            state.last_applied_sequence = Some(last_event.sequence);
            state.last_applied_event_hash = Some(last_event.integrity.event_hash.clone());
            state.source_ledger_ref = Some(journal.manifest.ledger_ref.clone());
            state.source_ledger_manifest_ref = Some(journal.manifest.manifest_ref.clone());
        }
        state.drift_status = Some(journal.manifest.drift_status.clone());
        state.drift_ref = journal.manifest.drift_ref.clone();
    }
    write_yaml(&bound.runtime_state_path, &state).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to update runtime-state {}: {e}",
                bound.runtime_state_path.display()
            ),
        )
    })?;
    sync_run_continuity(
        &RunContinuityRecord {
            schema_version: "run-continuity-v1".to_string(),
            run_id: state.run_id.clone(),
            status: state.status.clone(),
            run_contract_ref: state.run_contract_ref.clone(),
            run_manifest_ref: bound.run_manifest_ref.clone(),
            retained_evidence_ref: bound.retained_evidence_ref.clone(),
            replay_pointers_ref: bound.replay_pointers_ref.clone(),
            evidence_classification_ref: bound.evidence_classification_ref.clone(),
            last_receipt_ref: state.last_receipt_ref.clone(),
            last_checkpoint_ref: state
                .last_checkpoint_ref
                .clone()
                .unwrap_or_else(|| bound.control_checkpoint_ref.clone()),
            resume_from_stage_attempt_id: state.current_stage_attempt_id.clone(),
            mission_id: state.mission_id.clone(),
            parent_run_ref: state.parent_run_ref.clone(),
            next_action: next_action_for_run_status(&state.status),
            updated_at: state.updated_at.clone(),
        },
        &bound.continuity_handoff_path,
    )?;
    Ok(())
}

pub(crate) fn next_action_for_run_status(status: &str) -> Option<String> {
    match status {
        "authorizing" => Some(
            "Complete authority routing before any consequential side effects.".to_string(),
        ),
        "authorized" | "running" => Some(
            "Resume from the current stage attempt using the retained receipt and checkpoint roots."
                .to_string(),
        ),
        "stage_only" => Some(
            "Supply the required approval or evidence bundle before reauthorizing this run."
                .to_string(),
        ),
        "denied" => Some(
            "Do not resume this run; open a new request if the authority posture changes."
                .to_string(),
        ),
        _ => None,
    }
}

pub(crate) fn sync_run_continuity(record: &RunContinuityRecord, path: &Path) -> CoreResult<()> {
    write_yaml(path, record).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write run continuity {}: {e}", path.display()),
        )
    })
}

pub(crate) fn update_stage_attempt_status(
    bound: &BoundRunLifecycle,
    status: &str,
    evidence_ref: Option<String>,
) -> CoreResult<()> {
    let mut attempt: serde_yaml::Value = read_yaml_or_default(&bound.stage_attempt_path)?;
    let now = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute stage-attempt timestamp: {e}"),
        )
    })?;
    if let Some(mapping) = attempt.as_mapping_mut() {
        mapping.insert(
            serde_yaml::Value::from("status"),
            serde_yaml::Value::from(status),
        );
        mapping.insert(
            serde_yaml::Value::from("updated_at"),
            serde_yaml::Value::from(now.clone()),
        );
        if let Some(evidence_ref) = evidence_ref {
            let key = serde_yaml::Value::from("evidence_refs");
            let existing = mapping
                .get(&key)
                .and_then(|value| value.as_sequence())
                .cloned()
                .unwrap_or_default();
            let mut values = existing
                .iter()
                .filter_map(|value| value.as_str().map(ToOwned::to_owned))
                .collect::<Vec<_>>();
            values.push(evidence_ref);
            values = dedupe_strings(&values);
            mapping.insert(
                key,
                serde_yaml::Value::Sequence(
                    values.into_iter().map(serde_yaml::Value::from).collect(),
                ),
            );
        }
    }
    write_yaml(&bound.stage_attempt_path, &attempt).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to update stage attempt {}: {e}",
                bound.stage_attempt_path.display()
            ),
        )
    })?;
    Ok(())
}

pub(crate) fn write_run_checkpoint(
    control_path: &Path,
    evidence_path: &Path,
    run_id: &str,
    stage_attempt_id: &str,
    checkpoint_id: &str,
    checkpoint_kind: &str,
    notes: &str,
) -> CoreResult<(String, String)> {
    let created_at = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute checkpoint timestamp: {e}"),
        )
    })?;
    let record = RunCheckpointRecord {
        schema_version: "run-checkpoint-v1".to_string(),
        run_id: run_id.to_string(),
        checkpoint_id: checkpoint_id.to_string(),
        stage_attempt_id: stage_attempt_id.to_string(),
        checkpoint_kind: checkpoint_kind.to_string(),
        status: "materialized".to_string(),
        control_ref: control_path.display().to_string(),
        evidence_ref: Some(evidence_path.display().to_string()),
        notes: Some(notes.to_string()),
        created_at: created_at.clone(),
        updated_at: created_at,
    };
    write_yaml(control_path, &record).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write control checkpoint {}: {e}",
                control_path.display()
            ),
        )
    })?;
    write_yaml(evidence_path, &record).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write evidence checkpoint {}: {e}",
                evidence_path.display()
            ),
        )
    })?;
    Ok((
        control_path.display().to_string(),
        evidence_path.display().to_string(),
    ))
}

pub(crate) fn merge_replay_receipt_ref(
    path: &Path,
    run_id: &str,
    ref_id: String,
) -> CoreResult<()> {
    let mut replay: ReplayPointersRecord = read_yaml_or_default(path)?;
    replay.schema_version = "run-replay-pointers-v1".to_string();
    replay.run_id = run_id.to_string();
    replay.receipt_refs.push(ref_id);
    replay.receipt_refs = dedupe_strings(&replay.receipt_refs);
    replay.updated_at = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute replay pointer timestamp: {e}"),
        )
    })?;
    write_yaml(path, &replay).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to update replay pointers {}: {e}", path.display()),
        )
    })?;
    Ok(())
}

pub(crate) fn merge_replay_checkpoint_ref(
    path: &Path,
    run_id: &str,
    ref_id: String,
) -> CoreResult<()> {
    let mut replay: ReplayPointersRecord = read_yaml_or_default(path)?;
    replay.schema_version = "run-replay-pointers-v1".to_string();
    replay.run_id = run_id.to_string();
    replay.checkpoint_refs.push(ref_id);
    replay.checkpoint_refs = dedupe_strings(&replay.checkpoint_refs);
    replay.updated_at = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute replay pointer timestamp: {e}"),
        )
    })?;
    write_yaml(path, &replay).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to update replay pointers {}: {e}", path.display()),
        )
    })?;
    Ok(())
}

pub(crate) fn merge_retained_evidence_ref(
    path: &Path,
    run_id: &str,
    key: &str,
    ref_id: String,
) -> CoreResult<()> {
    let mut retained: RetainedRunEvidenceRecord = read_yaml_or_default(path)?;
    retained.schema_version = "retained-run-evidence-v1".to_string();
    retained.run_id = run_id.to_string();
    retained.evidence_refs.insert(key.to_string(), ref_id);
    retained.updated_at = now_rfc3339().map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute retained-evidence timestamp: {e}"),
        )
    })?;
    write_yaml(path, &retained).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to update retained run evidence {}: {e}",
                path.display()
            ),
        )
    })?;
    Ok(())
}

pub(crate) fn discover_repo_root(path: &Path) -> Option<PathBuf> {
    let mut current = if path.is_dir() {
        path.to_path_buf()
    } else {
        path.parent()?.to_path_buf()
    };
    loop {
        if current.join(".octon").is_dir() {
            return Some(current);
        }
        if !current.pop() {
            return None;
        }
    }
}

pub(crate) fn resolve_relative_from_runtime_path(
    runtime_path: &Path,
    relative: &str,
) -> Option<PathBuf> {
    let repo_root = discover_repo_root(runtime_path)?;
    let relative_path = PathBuf::from(relative);
    Some(if relative_path.is_absolute() {
        relative_path
    } else {
        repo_root.join(relative_path)
    })
}

pub(crate) fn copy_json_if_present(src: &Path, dst: &Path) -> CoreResult<()> {
    if let Some(parent) = dst.parent() {
        fs::create_dir_all(parent).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!(
                    "failed to create canonical receipt directory {}: {e}",
                    parent.display()
                ),
            )
        })?;
    }
    let bytes = fs::read(src).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to read execution artifact {}: {e}", src.display()),
        )
    })?;
    fs::write(dst, bytes).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to write canonical receipt {}: {e}", dst.display()),
        )
    })?;
    Ok(())
}

pub(crate) fn bound_run_from_grant(
    runtime_path: &Path,
    grant: &GrantBundle,
) -> Option<BoundRunLifecycle> {
    let repo_root = discover_repo_root(runtime_path)?;
    let control_root_rel = grant.run_control_root.clone()?;
    let control_root = resolve_relative_from_runtime_path(runtime_path, &control_root_rel)?;
    let evidence_root = resolve_relative_from_runtime_path(runtime_path, &grant.run_root)?;
    let assurance_root = evidence_root.join("assurance");
    let measurement_root = evidence_root.join("measurements");
    let intervention_root = evidence_root.join("interventions");
    let disclosure_root = repo_root
        .join(".octon/state/evidence/disclosure/runs")
        .join(&grant.request_id);
    let replay_manifest_path = evidence_root.join("replay").join("manifest.yml");
    let continuity_handoff_path = repo_root
        .join(".octon/state/continuity/runs")
        .join(&grant.request_id)
        .join("handoff.yml");
    let run_manifest_path = control_root.join("run-manifest.yml");
    let runtime_state_path = control_root.join("runtime-state.yml");
    let control_checkpoint_path = control_root.join("checkpoints").join("bound.yml");
    let receipts_root = if let Some(rel) = &grant.run_receipts_root {
        resolve_relative_from_runtime_path(runtime_path, rel)?
    } else {
        evidence_root.join("receipts")
    };
    let replay_pointers_path = if let Some(rel) = &grant.replay_pointers_path {
        resolve_relative_from_runtime_path(runtime_path, rel)?
    } else {
        evidence_root.join("replay-pointers.yml")
    };
    let trace_pointers_path = if let Some(rel) = &grant.trace_pointers_path {
        resolve_relative_from_runtime_path(runtime_path, rel)?
    } else {
        evidence_root.join("trace-pointers.yml")
    };
    let retained_evidence_path = if let Some(rel) = &grant.retained_evidence_path {
        resolve_relative_from_runtime_path(runtime_path, rel)?
    } else {
        evidence_root.join("retained-run-evidence.yml")
    };
    let evidence_classification_path = evidence_root.join("evidence-classification.yml");
    let stage_attempt_path = if let Some(rel) = &grant.stage_attempt_ref {
        resolve_relative_from_runtime_path(runtime_path, rel)?
    } else {
        control_root.join("stage-attempts").join("initial.yml")
    };
    let stage_attempt_id = stage_attempt_path
        .file_stem()
        .and_then(|value| value.to_str())
        .unwrap_or("initial")
        .to_string();
    Some(BoundRunLifecycle {
        control_root: control_root.clone(),
        evidence_root: evidence_root.clone(),
        assurance_root,
        measurement_root,
        intervention_root,
        disclosure_root,
        replay_manifest_path,
        continuity_handoff_path: continuity_handoff_path.clone(),
        _run_manifest_path: run_manifest_path.clone(),
        runtime_state_path: runtime_state_path.clone(),
        receipts_root: receipts_root.clone(),
        replay_pointers_path: replay_pointers_path.clone(),
        _evidence_classification_path: evidence_classification_path.clone(),
        retained_evidence_path: retained_evidence_path.clone(),
        stage_attempt_path: stage_attempt_path.clone(),
        control_root_rel,
        evidence_root_rel: path_tail(&repo_root, &evidence_root),
        control_checkpoint_ref: path_tail(&repo_root, &control_checkpoint_path),
        run_manifest_ref: path_tail(&repo_root, &run_manifest_path),
        receipts_root_rel: path_tail(&repo_root, &receipts_root),
        replay_pointers_ref: path_tail(&repo_root, &replay_pointers_path),
        trace_pointers_ref: path_tail(&repo_root, &trace_pointers_path),
        evidence_classification_ref: path_tail(&repo_root, &evidence_classification_path),
        retained_evidence_ref: path_tail(&repo_root, &retained_evidence_path),
        stage_attempt_ref: path_tail(&repo_root, &stage_attempt_path),
        stage_attempt_id,
    })
}

pub(crate) fn read_yaml_or_default<T>(path: &Path) -> CoreResult<T>
where
    T: Default + for<'de> Deserialize<'de>,
{
    if !path.is_file() {
        return Ok(T::default());
    }
    read_yaml_file(path)
}

pub(crate) fn load_run_contract_record(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    autonomy_state: Option<&ResolvedAutonomyState>,
) -> CoreResult<RunContractRecord> {
    let path = run_contract_path(cfg, &request.request_id);
    let mut record: RunContractRecord = read_yaml_or_default(&path)?;
    let request_support_target = requested_support_target_tuple(request)?;
    if record.support_tier.trim().is_empty() {
        record.support_tier = request_support_target.workload_tier.clone();
    }
    if record.support_target.workload_tier.trim().is_empty() {
        record.support_target = request_support_target;
    }
    if record.requested_capability_packs.is_empty() {
        record.requested_capability_packs = infer_requested_capability_packs(request);
    }
    if record.intent_ref.is_none() {
        record.intent_ref = request
            .intent_ref
            .clone()
            .or_else(|| active_intent_ref(cfg));
    }
    if record.execution_role_ref.is_none() {
        record.execution_role_ref = Some(
            request
                .execution_role_ref
                .clone()
                .unwrap_or_else(default_execution_role_ref),
        );
    }
    if record.reversibility_class.trim().is_empty() {
        record.reversibility_class = autonomy_state
            .map(|state| state.context.reversibility_class.clone())
            .unwrap_or_else(|| "reversible".to_string());
    }
    Ok(record)
}
