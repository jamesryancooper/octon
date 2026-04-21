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
use serde::{Deserialize, Serialize};
use serde_json::json;
use sha2::{Digest, Sha256};
use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::{Mutex, OnceLock};

pub(crate) fn resolve_autonomy_state(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    resolved_intent_ref: &IntentRef,
) -> CoreResult<Option<ResolvedAutonomyState>> {
    if !is_autonomous_request(request) {
        return Ok(None);
    }

    let context = request.autonomy_context.clone().ok_or_else(|| {
        mission_denial(
            "autonomous execution requires autonomy_context",
            vec!["MISSION_AUTONOMY_CONTEXT_MISSING"],
        )
    })?;

    if context.intent_ref.id != resolved_intent_ref.id
        || context.intent_ref.version != resolved_intent_ref.version
    {
        return Err(mission_denial(
            "autonomous execution intent binding does not match the resolved active intent",
            vec!["MISSION_AUTONOMY_INTENT_MISMATCH"],
        ));
    }

    let mission_id = context.mission_ref.id.clone();
    let mission_dir = cfg
        .octon_dir
        .join("instance")
        .join("orchestration")
        .join("missions")
        .join(&mission_id);
    let charter_path = mission_dir.join("mission.yml");
    let policy_path = cfg
        .octon_dir
        .join("instance")
        .join("governance")
        .join("policies")
        .join("mission-autonomy.yml");
    let ownership_path = cfg
        .octon_dir
        .join("instance")
        .join("governance")
        .join("ownership")
        .join("registry.yml");
    let control_dir = cfg
        .execution_control_root
        .join("missions")
        .join(&mission_id);
    let lease_path = control_dir.join("lease.yml");
    let mode_state_path = control_dir.join("mode-state.yml");
    let intent_register_path = control_dir.join("intent-register.yml");
    let directives_path = control_dir.join("directives.yml");
    let schedule_path = control_dir.join("schedule.yml");
    let autonomy_budget_path = control_dir.join("autonomy-budget.yml");
    let circuit_breakers_path = control_dir.join("circuit-breakers.yml");
    let subscriptions_path = control_dir.join("subscriptions.yml");
    let scenario_resolution_path = cfg
        .octon_dir
        .join("generated/effective/orchestration/missions")
        .join(&mission_id)
        .join("scenario-resolution.yml");

    for (path, reason_code) in [
        (&charter_path, "MISSION_CHARTER_MISSING"),
        (&policy_path, "MISSION_AUTONOMY_POLICY_MISSING"),
        (&ownership_path, "OWNERSHIP_REGISTRY_MISSING"),
        (&lease_path, "MISSION_CONTROL_LEASE_MISSING"),
        (&mode_state_path, "MISSION_MODE_STATE_MISSING"),
        (&intent_register_path, "MISSION_INTENT_REGISTER_MISSING"),
        (&directives_path, "MISSION_DIRECTIVES_MISSING"),
        (&schedule_path, "MISSION_SCHEDULE_MISSING"),
        (&autonomy_budget_path, "MISSION_AUTONOMY_BUDGET_MISSING"),
        (&circuit_breakers_path, "MISSION_CIRCUIT_BREAKERS_MISSING"),
        (&subscriptions_path, "MISSION_SUBSCRIPTIONS_MISSING"),
    ] {
        ensure_file_exists(path, reason_code)?;
    }
    if !scenario_resolution_path.is_file() {
        return Err(mission_stage_only(
            "mission scenario resolution is missing",
            vec![
                "MISSION_SCENARIO_RESOLUTION_MISSING",
                "ACP_STAGE_ONLY_REQUIRED",
            ],
        ));
    }

    let charter: MissionCharterRecord = read_yaml_file(&charter_path)?;
    if charter.mission_id != mission_id {
        return Err(mission_denial(
            "mission charter id does not match autonomy_context mission_ref",
            vec!["MISSION_CHARTER_ID_MISMATCH"],
        ));
    }
    if charter.mission_class != context.mission_class {
        return Err(mission_denial(
            "autonomy_context mission_class does not match mission charter",
            vec!["MISSION_CLASS_MISMATCH"],
        ));
    }

    let lease: MissionLeaseRecord = read_yaml_file(&lease_path)?;
    if !lease.expires_at.trim().is_empty()
        && parse_rfc3339(&lease.expires_at)? <= time::OffsetDateTime::now_utc()
    {
        return Err(mission_denial(
            "mission continuation lease has expired",
            vec!["MISSION_LEASE_EXPIRED"],
        ));
    }
    match lease.state.as_str() {
        "active" => {}
        "paused" => {
            return Err(mission_stage_only(
                "mission continuation lease is paused",
                vec!["MISSION_LEASE_PAUSED", "ACP_STAGE_ONLY_REQUIRED"],
            ));
        }
        "revoked" | "expired" => {
            return Err(mission_denial(
                "mission continuation lease is not active",
                vec!["MISSION_LEASE_INACTIVE"],
            ));
        }
        _ => {
            return Err(mission_denial(
                "mission continuation lease state is invalid",
                vec!["MISSION_LEASE_INVALID"],
            ));
        }
    }

    let autonomy_budget: MissionAutonomyBudgetRecord = read_yaml_file(&autonomy_budget_path)?;
    let mode_state: MissionModeStateRecord = read_yaml_file(&mode_state_path)?;
    let schedule_state: MissionScheduleRecord = read_yaml_file(&schedule_path)?;
    let breaker_record: MissionCircuitBreakersRecord = read_yaml_file(&circuit_breakers_path)?;
    let scenario_resolution: ScenarioResolutionRecord = read_yaml_file(&scenario_resolution_path)?;
    if scenario_resolution.mission_id != mission_id {
        return Err(mission_denial(
            "scenario resolution mission_id does not match autonomy_context mission_ref",
            vec!["MISSION_SCENARIO_RESOLUTION_MISMATCH"],
        ));
    }
    if scenario_resolution.fresh_until.trim().is_empty() {
        return Err(mission_stage_only(
            "mission scenario resolution is missing freshness metadata",
            vec![
                "MISSION_SCENARIO_RESOLUTION_STALE",
                "ACP_STAGE_ONLY_REQUIRED",
            ],
        ));
    }
    if parse_rfc3339(&scenario_resolution.fresh_until)? <= time::OffsetDateTime::now_utc() {
        return Err(mission_stage_only(
            "mission scenario resolution is stale",
            vec![
                "MISSION_SCENARIO_RESOLUTION_STALE",
                "ACP_STAGE_ONLY_REQUIRED",
            ],
        ));
    }
    let breaker_state = breaker_record.state.clone().unwrap_or_else(|| {
        if breaker_record.tripped_breakers.is_empty() {
            "clear".to_string()
        } else {
            "tripped".to_string()
        }
    });

    let mut context = context;
    if !scenario_resolution
        .effective
        .oversight_mode
        .trim()
        .is_empty()
    {
        context.oversight_mode = scenario_resolution.effective.oversight_mode.clone();
    } else if !mode_state.oversight_mode.trim().is_empty() {
        context.oversight_mode = mode_state.oversight_mode.clone();
    }
    if !scenario_resolution
        .effective
        .execution_posture
        .trim()
        .is_empty()
    {
        context.execution_posture = scenario_resolution.effective.execution_posture.clone();
    } else if !mode_state.execution_posture.trim().is_empty() {
        context.execution_posture = mode_state.execution_posture.clone();
    }
    let autonomy_budget_state = if !mode_state.autonomy_burn_state.trim().is_empty() {
        mode_state.autonomy_burn_state.clone()
    } else {
        autonomy_budget.state.clone()
    };
    if schedule_state.suspended_future_runs {
        return Err(mission_stage_only(
            "mission schedule has suspended future runs",
            vec!["MISSION_SCHEDULE_SUSPENDED", "ACP_STAGE_ONLY_REQUIRED"],
        ));
    }
    if schedule_state.pause_active_run_requested {
        return Err(mission_stage_only(
            "mission schedule requests pause at the next safe boundary",
            vec![
                "MISSION_SCHEDULE_PAUSE_REQUESTED",
                "ACP_STAGE_ONLY_REQUIRED",
            ],
        ));
    }

    if context.oversight_mode == "proceed_on_silence" {
        if !scenario_resolution.effective.proceed_on_silence_allowed {
            return Err(mission_stage_only(
                "proceed_on_silence is blocked by effective scenario routing",
                vec![
                    "MISSION_PROCEED_ON_SILENCE_BLOCKED",
                    "ACP_STAGE_ONLY_REQUIRED",
                ],
            ));
        }
    }
    if scenario_resolution.effective.finalize_policy.block_finalize
        && (request.action_type.contains("finalize")
            || context.reversibility_class == "irreversible")
    {
        return Err(mission_stage_only(
            "mission finalize policy is currently blocking irreversible progression",
            vec!["MISSION_FINALIZE_BLOCKED", "ACP_STAGE_ONLY_REQUIRED"],
        ));
    }
    let action_class = if scenario_resolution
        .effective
        .recovery_profile
        .action_class
        .trim()
        .is_empty()
    {
        return Err(mission_stage_only(
            "mission route could not derive an action class for material work",
            vec!["MISSION_ACTION_CLASS_MISSING", "ACP_STAGE_ONLY_REQUIRED"],
        ));
    } else {
        scenario_resolution
            .effective
            .recovery_profile
            .action_class
            .clone()
    };
    let recovery_window = scenario_resolution
        .effective
        .recovery_profile
        .recovery_window
        .clone();
    if recovery_window.trim().is_empty() {
        return Err(mission_stage_only(
            "mission route could not derive recovery metadata for material work",
            vec![
                "MISSION_RECOVERY_METADATA_MISSING",
                "ACP_STAGE_ONLY_REQUIRED",
            ],
        ));
    }
    let primitive = if scenario_resolution
        .effective
        .recovery_profile
        .primitive
        .trim()
        .is_empty()
    {
        None
    } else {
        Some(
            scenario_resolution
                .effective
                .recovery_profile
                .primitive
                .clone(),
        )
    };
    let rollback_handle = if context.reversibility_class == "reversible" {
        let rollback_handle_prefix = if scenario_resolution
            .effective
            .recovery_profile
            .rollback_handle_type
            .trim()
            .is_empty()
        {
            "rollback"
        } else {
            scenario_resolution
                .effective
                .recovery_profile
                .rollback_handle_type
                .trim()
        };
        Some(format!(
            "{}-{}-{}",
            rollback_handle_prefix, mission_id, context.slice_ref.id
        ))
    } else {
        None
    };
    let compensation_handle = if context.reversibility_class == "compensable" {
        Some(format!(
            "compensate-{}-{}",
            mission_id, context.slice_ref.id
        ))
    } else {
        None
    };

    Ok(Some(ResolvedAutonomyState {
        context,
        action_class,
        rollback_handle,
        compensation_handle,
        recovery_window,
        reversibility_primitive: primitive,
        autonomy_budget_state,
        breaker_state,
        approval_required: scenario_resolution.effective.approval_required
            || scenario_resolution
                .effective
                .finalize_policy
                .approval_required,
        break_glass_required: scenario_resolution
            .effective
            .finalize_policy
            .break_glass_required,
    }))
}
