use super::mission;
use super::path_to_repo_ref;
use super::{DecisionListCmd, DecisionResolveCmd};
use crate::{
    StewardAdmitCmd, StewardCmd, StewardIdleCmd, StewardObserveCmd, StewardOpenCmd, StewardRenewCmd,
};
use anyhow::{anyhow, bail, Context, Result};
use octon_authority_engine::now_rfc3339;
use serde::Serialize;
use serde_json::{json, Map, Value};
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};
use time::{format_description::well_known::Rfc3339, Duration, OffsetDateTime};

const DEFAULT_PROGRAM_ID: &str = "octon-continuous-stewardship";
const CAMPAIGN_PROMOTION_CRITERIA_REF: &str =
    ".octon/framework/orchestration/practices/campaign-promotion-criteria.md";
const SUPPORT_TARGET_REF: &str = ".octon/instance/governance/support-targets.yml";
const PROJECT_PROFILE_REF: &str = ".octon/instance/locality/project-profile.yml";
const CONNECTOR_POSTURE_REF: &str = ".octon/instance/governance/connectors/posture.yml";

#[derive(Debug, Clone, Serialize)]
struct StewardReport {
    command: &'static str,
    status: String,
    program_id: Option<String>,
    epoch_id: Option<String>,
    trigger_id: Option<String>,
    refs: BTreeMap<String, String>,
    outcome: String,
    next_command: String,
}

pub(super) fn cmd_steward(cmd: StewardCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let report = match cmd {
        StewardCmd::Open(args) => open_program(&octon_dir, args)?,
        StewardCmd::Status(args) => status_program(&octon_dir, &args.program_id)?,
        StewardCmd::Observe(args) => observe_trigger(&octon_dir, args)?,
        StewardCmd::Admit(args) => admit_trigger(&octon_dir, args)?,
        StewardCmd::Idle(args) => idle_program(&octon_dir, args)?,
        StewardCmd::Renew(args) => renew_epoch(&octon_dir, args)?,
        StewardCmd::Pause(args) => set_program_state(&octon_dir, &args.program_id, "paused")?,
        StewardCmd::Resume(args) => resume_program(&octon_dir, &args.program_id)?,
        StewardCmd::Revoke(args) => set_program_state(&octon_dir, &args.program_id, "revoked")?,
        StewardCmd::Close(args) => close_program(&octon_dir, &args.program_id)?,
        StewardCmd::Ledger(args) => print_state_file(
            &octon_dir,
            &args.program_id,
            "steward-ledger",
            stewardship_control_root(&octon_dir, &args.program_id).join("ledger.yml"),
        )?,
        StewardCmd::Triggers(args) => print_dir_index(
            &octon_dir,
            &args.program_id,
            "steward-triggers",
            stewardship_control_root(&octon_dir, &args.program_id).join("triggers"),
        )?,
        StewardCmd::Epochs(args) => print_dir_index(
            &octon_dir,
            &args.program_id,
            "steward-epochs",
            stewardship_control_root(&octon_dir, &args.program_id).join("epochs"),
        )?,
        StewardCmd::Decisions(args) => print_dir_index(
            &octon_dir,
            &args.program_id,
            "steward-decisions",
            stewardship_control_root(&octon_dir, &args.program_id).join("decisions"),
        )?,
    };
    print_report(&report)
}

pub(super) fn cmd_decision_list(args: DecisionListCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let program_id = args
        .program_id
        .unwrap_or_else(|| DEFAULT_PROGRAM_ID.to_string());
    let mut decisions = Vec::new();
    collect_yaml_files(
        &stewardship_control_root(&octon_dir, &program_id).join("decisions"),
        &mut decisions,
    )?;
    println!(
        "{}",
        serde_json::to_string_pretty(&json!({
            "schema_version": "stewardship-decision-request-list-v1",
            "authority_notice": "Stewardship Decision Requests are read from state/control/stewardship; generated views, host comments, and chat are not authority.",
            "program_id": program_id,
            "decisions": decisions
        }))?
    );
    Ok(())
}

pub(super) fn cmd_decision_resolve(args: DecisionResolveCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let program_id = args
        .program_id
        .or_else(|| find_program_for_decision(&octon_dir, &args.decision_id).ok())
        .ok_or_else(|| {
            anyhow!("--program-id is required for stewardship-aware Decision Requests")
        })?;
    let report = resolve_stewardship_decision(
        &octon_dir,
        &program_id,
        &args.decision_id,
        args.response.as_resolution(),
    )?;
    print_report(&report)
}

pub(super) fn stewardship_decision_exists(
    program_id: Option<&str>,
    decision_id: &str,
) -> Result<bool> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    if let Some(program_id) = program_id {
        return Ok(stewardship_control_root(&octon_dir, program_id)
            .join("decisions")
            .join(format!("{decision_id}.yml"))
            .is_file());
    }
    Ok(find_program_for_decision(&octon_dir, decision_id).is_ok())
}

fn open_program(octon_dir: &Path, args: StewardOpenCmd) -> Result<StewardReport> {
    validate_id(&args.program_id, "program_id")?;
    ensure_v1_v2_dependencies(octon_dir)?;
    ensure_campaign_boundary(octon_dir)?;
    let now = now_rfc3339()?;
    let epoch_id = args
        .epoch_id
        .clone()
        .unwrap_or_else(|| format!("{}-epoch-1", args.program_id));
    validate_id(&epoch_id, "epoch_id")?;

    ensure_program_authority(octon_dir, &args.program_id)?;
    let control_root = stewardship_control_root(octon_dir, &args.program_id);
    let evidence_root = stewardship_evidence_root(octon_dir, &args.program_id);
    let continuity_root = stewardship_continuity_root(octon_dir, &args.program_id);
    fs::create_dir_all(&control_root)?;
    fs::create_dir_all(&evidence_root)?;
    fs::create_dir_all(&continuity_root)?;

    write_status(octon_dir, &args.program_id, "active", Some(&epoch_id), &now)?;
    write_epoch(octon_dir, &args.program_id, &epoch_id, "active", &now)?;
    write_stewardship_evidence_profile(octon_dir, &args.program_id, &now)?;
    write_ledger(octon_dir, &args.program_id, &now, None)?;
    write_continuity(octon_dir, &args.program_id, Some(&epoch_id), "active", &now)?;
    write_evidence_snapshot(octon_dir, &args.program_id, "program", "opened", &now)?;
    write_evidence_snapshot(octon_dir, &args.program_id, "epochs", &epoch_id, &now)?;
    write_evidence_snapshot(
        octon_dir,
        &args.program_id,
        "stewardship-ledger",
        "current",
        &now,
    )?;
    write_evidence_snapshot(
        octon_dir,
        &args.program_id,
        "mission-handoff",
        "not-admitted",
        &now,
    )?;
    write_evidence_snapshot(
        octon_dir,
        &args.program_id,
        "disclosure-status",
        "current",
        &now,
    )?;
    write_evidence_snapshot(
        octon_dir,
        &args.program_id,
        "closeout-evidence",
        &epoch_id,
        &now,
    )?;
    write_generated_projection(octon_dir, &args.program_id, Some(&epoch_id), "active", &now)?;

    Ok(report(
        "steward-open",
        "active",
        Some(args.program_id.clone()),
        Some(epoch_id.clone()),
        None,
        BTreeMap::from([
            (
                "program_authority_ref".to_string(),
                format!(
                    ".octon/instance/stewardship/programs/{}/program.yml",
                    args.program_id
                ),
            ),
            (
                "program_status_ref".to_string(),
                format!(
                    ".octon/state/control/stewardship/programs/{}/status.yml",
                    args.program_id
                ),
            ),
            (
                "epoch_ref".to_string(),
                format!(
                    ".octon/state/control/stewardship/programs/{}/epochs/{epoch_id}/epoch.yml",
                    args.program_id
                ),
            ),
            (
                "ledger_ref".to_string(),
                format!(
                    ".octon/state/control/stewardship/programs/{}/ledger.yml",
                    args.program_id
                ),
            ),
        ]),
        "ready",
        format!("octon steward observe --program-id {}", args.program_id),
    ))
}

fn status_program(octon_dir: &Path, program_id: &str) -> Result<StewardReport> {
    validate_id(program_id, "program_id")?;
    let status =
        read_yaml_value(&stewardship_control_root(octon_dir, program_id).join("status.yml"))?;
    let state = status
        .get("status")
        .and_then(Value::as_str)
        .unwrap_or("unknown")
        .to_string();
    let epoch_id = status
        .get("active_epoch_id")
        .and_then(Value::as_str)
        .map(ToString::to_string);
    Ok(report(
        "steward-status",
        &state,
        Some(program_id.to_string()),
        epoch_id,
        None,
        standard_refs(program_id),
        &state,
        format!("octon steward triggers --program-id {program_id}"),
    ))
}

fn observe_trigger(octon_dir: &Path, args: StewardObserveCmd) -> Result<StewardReport> {
    validate_id(&args.program_id, "program_id")?;
    ensure_program_active(octon_dir, &args.program_id)?;
    let epoch_id = active_epoch_id(octon_dir, &args.program_id)?;
    ensure_epoch_active(octon_dir, &args.program_id, &epoch_id)?;
    let now = now_rfc3339()?;
    let trigger_type = args.trigger_type.as_str();
    let summary = args
        .summary
        .clone()
        .unwrap_or_else(|| default_trigger_summary(trigger_type).to_string());
    let trigger_id = format!(
        "{}-{}",
        trigger_type.replace('_', "-"),
        short_hash(&format!(
            "{}:{}:{}:{}",
            args.program_id, epoch_id, trigger_type, now
        ))
    );
    validate_id(&trigger_id, "trigger_id")?;
    let supported_in_mvp = matches!(
        trigger_type,
        "scheduled_review" | "human_objective" | "prior_mission_followup"
    );
    let trigger_path = stewardship_control_root(octon_dir, &args.program_id)
        .join("triggers")
        .join(format!("{trigger_id}.yml"));
    write_yaml(
        &trigger_path,
        &json!({
            "schema_version": "stewardship-trigger-v1",
            "program_id": args.program_id,
            "epoch_id": epoch_id,
            "trigger_id": trigger_id,
            "trigger_type": trigger_type,
            "recognized": true,
            "supported_in_v3_mvp": supported_in_mvp,
            "status": "pending_admission",
            "summary": summary,
            "source_ref": args.source_ref,
            "source_authority": "non_authoritative_observation_input",
            "trigger_authorizes_work": false,
            "material_execution_allowed": false,
            "admission_required_before_work": true,
            "created_at": now,
            "updated_at": now
        }),
    )?;
    write_evidence_snapshot(octon_dir, &args.program_id, "triggers", &trigger_id, &now)?;
    append_ledger_event(
        octon_dir,
        &args.program_id,
        &now,
        json!({
            "event_type": "trigger_observed",
            "trigger_id": trigger_id,
            "epoch_id": epoch_id,
            "evidence_ref": format!(".octon/state/evidence/stewardship/programs/{}/triggers/{trigger_id}/observed.yml", args.program_id)
        }),
    )?;
    write_generated_projection(octon_dir, &args.program_id, Some(&epoch_id), "active", &now)?;

    Ok(report(
        "steward-observe",
        "pending_admission",
        Some(args.program_id.clone()),
        Some(epoch_id),
        Some(trigger_id.clone()),
        BTreeMap::from([(
            "trigger_ref".to_string(),
            path_to_repo_ref(octon_dir, &trigger_path)?,
        )]),
        "observed",
        format!(
            "octon steward admit --program-id {} --trigger-id {}",
            args.program_id, trigger_id
        ),
    ))
}

fn admit_trigger(octon_dir: &Path, args: StewardAdmitCmd) -> Result<StewardReport> {
    validate_id(&args.program_id, "program_id")?;
    ensure_program_active(octon_dir, &args.program_id)?;
    let epoch_id = active_epoch_id(octon_dir, &args.program_id)?;
    ensure_epoch_active(octon_dir, &args.program_id, &epoch_id)?;
    let trigger_id = match args.trigger_id {
        Some(id) => id,
        None => find_pending_trigger(octon_dir, &args.program_id)?,
    };
    validate_id(&trigger_id, "trigger_id")?;
    let now = now_rfc3339()?;
    let trigger_path = stewardship_control_root(octon_dir, &args.program_id)
        .join("triggers")
        .join(format!("{trigger_id}.yml"));
    let trigger = read_yaml_value(&trigger_path)?;
    let trigger_type = yaml_string(&trigger, "trigger_type")?;
    let supported_in_mvp = trigger
        .get("supported_in_v3_mvp")
        .and_then(Value::as_bool)
        .unwrap_or(false);

    let mut blockers = Vec::new();
    evaluate_stewardship_gates(octon_dir, &args.program_id, &epoch_id, &mut blockers)?;
    let (outcome, mission_handoff_ref, decision_request_id) = if !blockers.is_empty() {
        let decision_id = ensure_stewardship_decision(
            octon_dir,
            &args.program_id,
            &epoch_id,
            &trigger_id,
            "stewardship_gate_blocked",
            &blockers,
            &now,
        )?;
        ("decision_request", None, Some(decision_id))
    } else if args.campaign_candidate {
        let decision_id = ensure_stewardship_decision(
            octon_dir,
            &args.program_id,
            &epoch_id,
            &trigger_id,
            "campaign_candidate_promotion",
            &[
                "campaigns-remain-deferred-by-default".to_string(),
                "campaign-promotion-criteria-evidence-required".to_string(),
            ],
            &now,
        )?;
        ("campaign_candidate", None, Some(decision_id))
    } else {
        match trigger_type {
            "scheduled_review" => ("idle", None, None),
            "human_objective" => {
                if let Some(engagement_id) = args.engagement_id.as_deref() {
                    let mission_id =
                        format!("mission-{}-{}", args.program_id, short_hash(&trigger_id));
                    let (opened_mission_id, mission_ref) = mission::open_mission_for_stewardship(
                        octon_dir,
                        engagement_id,
                        Some(mission_id),
                    )?;
                    let handoff_ref = write_mission_handoff(
                        octon_dir,
                        &args.program_id,
                        &epoch_id,
                        &trigger_id,
                        engagement_id,
                        &opened_mission_id,
                        &mission_ref,
                        &now,
                    )?;
                    ("mission_candidate", Some(handoff_ref), None)
                } else {
                    let decision_id = ensure_stewardship_decision(
                        octon_dir,
                        &args.program_id,
                        &epoch_id,
                        &trigger_id,
                        "mission_creation",
                        &["human-objective-requires-engagement-work-package-handoff".to_string()],
                        &now,
                    )?;
                    ("decision_request", None, Some(decision_id))
                }
            }
            "prior_mission_followup" => {
                let decision_id = ensure_stewardship_decision(
                    octon_dir,
                    &args.program_id,
                    &epoch_id,
                    &trigger_id,
                    "mission_creation",
                    &["prior-mission-followup-requires-operator-selected-engagement".to_string()],
                    &now,
                )?;
                ("decision_request", None, Some(decision_id))
            }
            _ if supported_in_mvp => ("deferred", None, None),
            _ => ("deferred", None, None),
        }
    };
    let decision_id = format!("{}-admission-{}", trigger_id, short_hash(&now));
    let admission_path = stewardship_control_root(octon_dir, &args.program_id)
        .join("admission-decisions")
        .join(format!("{decision_id}.yml"));
    write_yaml(
        &admission_path,
        &json!({
            "schema_version": "stewardship-admission-decision-v1",
            "program_id": args.program_id,
            "epoch_id": epoch_id,
            "trigger_id": trigger_id,
            "decision_id": decision_id,
            "admission_outcome": outcome,
            "trigger_evidence_ref": format!(".octon/state/evidence/stewardship/programs/{}/triggers/{trigger_id}/observed.yml", args.program_id),
            "support_posture_ref": SUPPORT_TARGET_REF,
            "context_freshness": "checked_for_mvp_required_refs",
            "project_profile_ref": PROJECT_PROFILE_REF,
            "work_package_assumption_freshness": "requires_v1_work_package_for_mission_handoff",
            "governance_constraints": {
                "stewardship_trigger_authorizes_work": false,
                "admission_decision_authorizes_material_execution": false,
                "run_gate_required": true,
                "v2_mission_gate_required": true
            },
            "mission_availability": if mission_handoff_ref.is_some() { "mission_control_opened" } else { "not_handed_off" },
            "mission_handoff_ref": mission_handoff_ref,
            "campaign_promotion_criteria_ref": CAMPAIGN_PROMOTION_CRITERIA_REF,
            "campaign_candidate_allowed_without_go_decision": false,
            "required_decision_requests": decision_request_id.iter().map(|id| {
                format!(".octon/state/control/stewardship/programs/{}/decisions/{id}.yml", args.program_id)
            }).collect::<Vec<_>>(),
            "created_at": now,
            "updated_at": now
        }),
    )?;
    set_trigger_status(
        octon_dir,
        &args.program_id,
        &trigger_id,
        match outcome {
            "idle" => "admitted_idle",
            "mission_candidate" => "converted_to_mission_candidate",
            "decision_request" => "blocked_by_decision_request",
            "campaign_candidate" => "blocked_campaign_candidate",
            "deferred" => "deferred",
            _ => outcome,
        },
        &now,
    )?;
    write_evidence_snapshot(
        octon_dir,
        &args.program_id,
        "admission-decisions",
        &decision_id,
        &now,
    )?;
    write_evidence_snapshot(
        octon_dir,
        &args.program_id,
        "stewardship-ledger",
        "current",
        &now,
    )?;
    if outcome == "idle" {
        write_idle_decision(
            octon_dir,
            &args.program_id,
            &epoch_id,
            Some(&trigger_id),
            "scheduled-review-found-no-admissible-work",
            &now,
        )?;
    }
    append_ledger_event(
        octon_dir,
        &args.program_id,
        &now,
        json!({
            "event_type": "admission_decision_emitted",
            "trigger_id": trigger_id,
            "admission_decision_id": decision_id,
            "outcome": outcome,
            "admission_decision_authorizes_material_execution": false
        }),
    )?;
    write_generated_projection(octon_dir, &args.program_id, Some(&epoch_id), outcome, &now)?;
    let next_command = match outcome {
        "mission_candidate" => "octon mission continue --mission-id <mission-id>".to_string(),
        "decision_request" | "campaign_candidate" => {
            format!("octon steward decisions --program-id {}", args.program_id)
        }
        "idle" => format!("octon steward idle --program-id {}", args.program_id),
        _ => format!("octon steward status --program-id {}", args.program_id),
    };

    Ok(report(
        "steward-admit",
        outcome,
        Some(args.program_id.clone()),
        Some(epoch_id),
        Some(trigger_id),
        BTreeMap::from([(
            "admission_decision_ref".to_string(),
            path_to_repo_ref(octon_dir, &admission_path)?,
        )]),
        outcome,
        next_command,
    ))
}

fn idle_program(octon_dir: &Path, args: StewardIdleCmd) -> Result<StewardReport> {
    validate_id(&args.program_id, "program_id")?;
    ensure_program_active(octon_dir, &args.program_id)?;
    let epoch_id = active_epoch_id(octon_dir, &args.program_id)?;
    let now = now_rfc3339()?;
    let reason = args
        .reason
        .as_deref()
        .unwrap_or("no-admissible-stewardship-work");
    let idle_ref = write_idle_decision(octon_dir, &args.program_id, &epoch_id, None, reason, &now)?;
    set_epoch_state(octon_dir, &args.program_id, &epoch_id, "idle", &now)?;
    write_status(octon_dir, &args.program_id, "idle", Some(&epoch_id), &now)?;
    write_evidence_snapshot(
        octon_dir,
        &args.program_id,
        "stewardship-ledger",
        "current",
        &now,
    )?;
    write_generated_projection(octon_dir, &args.program_id, Some(&epoch_id), "idle", &now)?;
    Ok(report(
        "steward-idle",
        "idle",
        Some(args.program_id.clone()),
        Some(epoch_id),
        None,
        BTreeMap::from([("idle_decision_ref".to_string(), idle_ref)]),
        "idle",
        format!("octon steward renew --program-id {}", args.program_id),
    ))
}

fn renew_epoch(octon_dir: &Path, args: StewardRenewCmd) -> Result<StewardReport> {
    validate_id(&args.program_id, "program_id")?;
    ensure_program_exists(octon_dir, &args.program_id)?;
    let epoch_id = active_epoch_id(octon_dir, &args.program_id)?;
    let now = now_rfc3339()?;
    let outcome = args.outcome.as_str();
    let blockers = renewal_blockers(octon_dir, &args.program_id, &epoch_id)?;
    if outcome == "renew" && !blockers.is_empty() {
        write_epoch_closeout(
            octon_dir,
            &args.program_id,
            &epoch_id,
            "blocked",
            &blockers,
            &now,
        )?;
        let decision_id = ensure_stewardship_decision(
            octon_dir,
            &args.program_id,
            &epoch_id,
            "epoch-renewal",
            "epoch_renewal",
            &blockers,
            &now,
        )?;
        let renewal_ref = write_renewal_decision(
            octon_dir,
            &args.program_id,
            &epoch_id,
            "pause",
            &blockers,
            &now,
        )?;
        return Ok(report(
            "steward-renew",
            "requires_decision",
            Some(args.program_id.clone()),
            Some(epoch_id),
            None,
            BTreeMap::from([
                ("renewal_decision_ref".to_string(), renewal_ref),
                (
                    "decision_request_ref".to_string(),
                    format!(
                        ".octon/state/control/stewardship/programs/{}/decisions/{decision_id}.yml",
                        args.program_id
                    ),
                ),
            ]),
            "requires_decision",
            format!(
                "octon decide resolve {decision_id} --program-id {} --response approve",
                args.program_id
            ),
        ));
    }
    let renewal_ref = write_renewal_decision(
        octon_dir,
        &args.program_id,
        &epoch_id,
        outcome,
        &blockers,
        &now,
    )?;
    match outcome {
        "renew" => {
            write_epoch_closeout(octon_dir, &args.program_id, &epoch_id, "closed", &[], &now)?;
            set_epoch_state(octon_dir, &args.program_id, &epoch_id, "closed", &now)?;
            let next_epoch = next_epoch_id(octon_dir, &args.program_id)?;
            write_epoch(octon_dir, &args.program_id, &next_epoch, "active", &now)?;
            write_status(
                octon_dir,
                &args.program_id,
                "active",
                Some(&next_epoch),
                &now,
            )?;
            write_continuity(
                octon_dir,
                &args.program_id,
                Some(&next_epoch),
                "renewed",
                &now,
            )?;
            write_generated_projection(
                octon_dir,
                &args.program_id,
                Some(&next_epoch),
                "active",
                &now,
            )?;
        }
        "close" => {
            write_epoch_closeout(octon_dir, &args.program_id, &epoch_id, "closed", &[], &now)?;
            set_epoch_state(octon_dir, &args.program_id, &epoch_id, "closed", &now)?;
            write_status(octon_dir, &args.program_id, "closed", None, &now)?;
            write_generated_projection(octon_dir, &args.program_id, None, "closed", &now)?;
        }
        "pause" | "escalate" | "revoke" | "idle_until_next_trigger" => {
            let state = if outcome == "idle_until_next_trigger" {
                "idle"
            } else {
                outcome
            };
            set_epoch_state(octon_dir, &args.program_id, &epoch_id, state, &now)?;
            write_status(octon_dir, &args.program_id, state, Some(&epoch_id), &now)?;
            write_generated_projection(octon_dir, &args.program_id, Some(&epoch_id), state, &now)?;
        }
        _ => {}
    }
    append_ledger_event(
        octon_dir,
        &args.program_id,
        &now,
        json!({
            "event_type": "renewal_decision_emitted",
            "epoch_id": epoch_id,
            "outcome": outcome,
            "silent_authority_widening": false
        }),
    )?;
    write_evidence_snapshot(
        octon_dir,
        &args.program_id,
        "stewardship-ledger",
        "current",
        &now,
    )?;
    Ok(report(
        "steward-renew",
        outcome,
        Some(args.program_id.clone()),
        Some(epoch_id),
        None,
        BTreeMap::from([("renewal_decision_ref".to_string(), renewal_ref)]),
        outcome,
        format!("octon steward status --program-id {}", args.program_id),
    ))
}

fn resume_program(octon_dir: &Path, program_id: &str) -> Result<StewardReport> {
    validate_id(program_id, "program_id")?;
    let epoch_id = active_epoch_id(octon_dir, program_id)?;
    let mut blockers = Vec::new();
    evaluate_stewardship_gates(octon_dir, program_id, &epoch_id, &mut blockers)?;
    let now = now_rfc3339()?;
    if !blockers.is_empty() {
        let decision_id = ensure_stewardship_decision(
            octon_dir,
            program_id,
            &epoch_id,
            "stewardship-resume",
            "epoch_opening",
            &blockers,
            &now,
        )?;
        return Ok(report(
            "steward-resume",
            "requires_decision",
            Some(program_id.to_string()),
            Some(epoch_id),
            None,
            BTreeMap::from([(
                "decision_request_ref".to_string(),
                format!(".octon/state/control/stewardship/programs/{program_id}/decisions/{decision_id}.yml"),
            )]),
            "requires_decision",
            format!("octon decide resolve {decision_id} --program-id {program_id} --response approve"),
        ));
    }
    set_program_state(octon_dir, program_id, "active")
}

fn set_program_state(octon_dir: &Path, program_id: &str, state: &str) -> Result<StewardReport> {
    validate_id(program_id, "program_id")?;
    ensure_program_exists(octon_dir, program_id)?;
    let now = now_rfc3339()?;
    let epoch_id = active_epoch_id(octon_dir, program_id).ok();
    write_status(octon_dir, program_id, state, epoch_id.as_deref(), &now)?;
    if let Some(epoch_id) = epoch_id.as_deref() {
        set_epoch_state(octon_dir, program_id, epoch_id, state, &now)?;
    }
    write_evidence_snapshot(octon_dir, program_id, "program", state, &now)?;
    write_generated_projection(octon_dir, program_id, epoch_id.as_deref(), state, &now)?;
    Ok(report(
        "steward-state",
        state,
        Some(program_id.to_string()),
        epoch_id,
        None,
        standard_refs(program_id),
        state,
        format!("octon steward status --program-id {program_id}"),
    ))
}

fn close_program(octon_dir: &Path, program_id: &str) -> Result<StewardReport> {
    validate_id(program_id, "program_id")?;
    let epoch_id = active_epoch_id(octon_dir, program_id)?;
    let now = now_rfc3339()?;
    let blockers = renewal_blockers(octon_dir, program_id, &epoch_id)?;
    if !blockers.is_empty() {
        write_epoch_closeout(octon_dir, program_id, &epoch_id, "blocked", &blockers, &now)?;
        let decision_id = ensure_stewardship_decision(
            octon_dir,
            program_id,
            &epoch_id,
            "program-closure",
            "idle_closure_acceptance",
            &blockers,
            &now,
        )?;
        return Ok(report(
            "steward-close",
            "requires_decision",
            Some(program_id.to_string()),
            Some(epoch_id),
            None,
            BTreeMap::from([(
                "decision_request_ref".to_string(),
                format!(".octon/state/control/stewardship/programs/{program_id}/decisions/{decision_id}.yml"),
            )]),
            "requires_decision",
            format!("octon decide resolve {decision_id} --program-id {program_id} --response close"),
        ));
    }
    write_epoch_closeout(octon_dir, program_id, &epoch_id, "closed", &[], &now)?;
    set_program_state(octon_dir, program_id, "closed")
}

fn resolve_stewardship_decision(
    octon_dir: &Path,
    program_id: &str,
    decision_id: &str,
    resolution: &str,
) -> Result<StewardReport> {
    validate_id(program_id, "program_id")?;
    validate_id(decision_id, "decision_id")?;
    let decision_path = stewardship_control_root(octon_dir, program_id)
        .join("decisions")
        .join(format!("{decision_id}.yml"));
    let mut decision = read_yaml_object(&decision_path)?;
    let allowed = decision
        .get("allowed_resolutions")
        .and_then(Value::as_array)
        .map(|items| items.iter().any(|item| item.as_str() == Some(resolution)))
        .unwrap_or(false);
    if !allowed {
        bail!(
            "resolution {resolution} is not allowed for stewardship Decision Request {decision_id}"
        );
    }
    let now = now_rfc3339()?;
    let status = match resolution {
        "approval"
        | "exception_lease"
        | "risk_acceptance"
        | "policy_clarification"
        | "support_scope_decision"
        | "capability_admission_decision"
        | "mission_scope_decision"
        | "closure_acceptance" => "resolved",
        "denial" => "denied",
        "revocation" => "revoked",
        _ => bail!("unsupported stewardship Decision Request resolution: {resolution}"),
    };
    let canonical_refs = write_stewardship_decision_resolution_refs(
        octon_dir,
        program_id,
        decision_id,
        resolution,
        &now,
    )?;
    let resolution_ref = format!(
        ".octon/state/evidence/stewardship/programs/{program_id}/decision-requests/{decision_id}/resolution.yml"
    );
    upsert(&mut decision, "status", json!(status));
    upsert(
        &mut decision,
        "resolution",
        json!({
            "response": resolution,
            "canonical_refs": canonical_refs,
            "evidence_ref": resolution_ref,
            "recorded_at": now
        }),
    );
    upsert(&mut decision, "resolved_at", json!(now));
    upsert(
        &mut decision,
        "canonical_resolution_note",
        json!("Stewardship resolution is control-state only and does not authorize material execution."),
    );
    write_yaml(&decision_path, &Value::Object(decision))?;
    write_yaml(
        &repo_root(octon_dir).join(&resolution_ref),
        &json!({
            "schema_version": "stewardship-decision-request-resolution-v1",
            "program_id": program_id,
            "decision_request_id": decision_id,
            "response": resolution,
            "canonical_refs": canonical_refs,
            "material_execution_authorized": false,
            "stewardship_admission_authorized": false,
            "notes": "Resolution records stewardship control disposition only. Material work still requires v2 Mission Runner, run contract, and execution authorization.",
            "recorded_at": now
        }),
    )?;
    write_evidence_snapshot(
        octon_dir,
        program_id,
        "decision-requests",
        decision_id,
        &now,
    )?;
    Ok(report(
        "steward-decision-resolve",
        status,
        Some(program_id.to_string()),
        active_epoch_id(octon_dir, program_id).ok(),
        None,
        BTreeMap::from([
            (
                "decision_request_ref".to_string(),
                path_to_repo_ref(octon_dir, &decision_path)?,
            ),
            ("decision_resolution_ref".to_string(), resolution_ref),
        ]),
        status,
        format!("octon steward status --program-id {program_id}"),
    ))
}

fn write_stewardship_decision_resolution_refs(
    octon_dir: &Path,
    program_id: &str,
    decision_id: &str,
    resolution: &str,
    now: &str,
) -> Result<Value> {
    let root = repo_root(octon_dir);
    let mut refs = Map::new();
    match resolution {
        "approval" => {
            let request_ref =
                format!(".octon/state/control/execution/approvals/requests/{decision_id}.yml");
            let stewardship_control_ref = format!(
                ".octon/state/control/stewardship/programs/{program_id}/decision-resolutions/{decision_id}/approval.yml"
            );
            write_yaml(
                &root.join(&request_ref),
                &json!({
                    "schema_version": "authority-approval-request-v1",
                    "request_id": decision_id,
                    "program_id": program_id,
                    "status": "stewardship-control-recorded",
                    "action_type": "stewardship-control-unblock",
                    "material_execution_authorized": false,
                    "approval_grant_emitted": false,
                    "created_at": now,
                    "updated_at": now
                }),
            )?;
            write_yaml(
                &root.join(&stewardship_control_ref),
                &json!({
                    "schema_version": "stewardship-control-approval-record-v1",
                    "request_id": decision_id,
                    "program_id": program_id,
                    "state": "recorded",
                    "material_execution_authorized": false,
                    "approval_grant_emitted": false,
                    "notes": "Stewardship approval records do not create active execution grants.",
                    "recorded_at": now
                }),
            )?;
            refs.insert("approval_request_ref".to_string(), json!(request_ref));
            refs.insert(
                "stewardship_control_approval_ref".to_string(),
                json!(stewardship_control_ref),
            );
        }
        "exception_lease" => {
            let lease_ref =
                format!(".octon/state/control/execution/exceptions/leases/lease-{decision_id}.yml");
            write_yaml(
                &root.join(&lease_ref),
                &json!({
                    "schema_version": "authority-exception-lease-v1",
                    "lease_id": format!("lease-{decision_id}"),
                    "program_id": program_id,
                    "source_decision_request_id": decision_id,
                    "state": "staged",
                    "material_effects_authorized": false,
                    "created_at": now,
                    "updated_at": now
                }),
            )?;
            refs.insert("exception_lease_ref".to_string(), json!(lease_ref));
        }
        "revocation" => {
            let revocation_ref =
                format!(".octon/state/control/execution/revocations/revoke-{decision_id}.yml");
            write_yaml(
                &root.join(&revocation_ref),
                &json!({
                    "schema_version": "authority-revocation-v1",
                    "revocation_id": format!("revoke-{decision_id}"),
                    "program_id": program_id,
                    "source_decision_request_id": decision_id,
                    "state": "active",
                    "created_at": now,
                    "updated_at": now
                }),
            )?;
            refs.insert("revocation_ref".to_string(), json!(revocation_ref));
        }
        _ => {
            refs.insert(
                "stewardship_decision_record_ref".to_string(),
                json!(format!(
                    ".octon/state/evidence/stewardship/programs/{program_id}/decision-requests/{decision_id}/resolution.yml"
                )),
            );
        }
    }
    Ok(Value::Object(refs))
}

fn write_status(
    octon_dir: &Path,
    program_id: &str,
    status: &str,
    active_epoch_id: Option<&str>,
    now: &str,
) -> Result<()> {
    write_yaml(
        &stewardship_control_root(octon_dir, program_id).join("status.yml"),
        &json!({
            "schema_version": "stewardship-program-status-v1",
            "program_id": program_id,
            "status": status,
            "active_epoch_id": active_epoch_id,
            "program_authority_ref": format!(".octon/instance/stewardship/programs/{program_id}/program.yml"),
            "one_active_program_per_workspace": true,
            "one_active_epoch_per_program": true,
            "service_may_be_indefinite": true,
            "work_may_be_unbounded": false,
            "updated_at": now
        }),
    )
}

fn write_epoch(
    octon_dir: &Path,
    program_id: &str,
    epoch_id: &str,
    state: &str,
    now: &str,
) -> Result<()> {
    let start = OffsetDateTime::now_utc();
    let end = (start + Duration::days(7)).format(&Rfc3339)?;
    let review = (start + Duration::days(6)).format(&Rfc3339)?;
    write_yaml(
        &stewardship_control_root(octon_dir, program_id)
            .join("epochs")
            .join(epoch_id)
            .join("epoch.yml"),
        &json!({
            "schema_version": "stewardship-epoch-v1",
            "program_id": program_id,
            "epoch_id": epoch_id,
            "status": state,
            "program_authority_ref": format!(".octon/instance/stewardship/programs/{program_id}/program.yml"),
            "start_at": now,
            "end_at": end,
            "review_deadline_at": review,
            "allowed_mission_classes": ["maintenance", "validation", "documentation"],
            "allowed_action_classes": ["repo-maintenance", "validation", "documentation"],
            "max_missions": 1,
            "max_runs": 1,
            "budget_profile": "stewardship-mvp-low",
            "circuit_breaker_profile": "stewardship-mvp-fail-closed",
            "event_triggers": ["scheduled_review", "human_objective", "prior_mission_followup"],
            "idle_threshold": "no-admissible-work",
            "closeout_requirements": [
                "all-admitted-triggers-dispositioned",
                "spawned-missions-closed-or-carried-forward",
                "stewardship-evidence-complete",
                "rollback-and-replay-disclosure-known",
                "continuity-updated",
                "renewal-decision-emitted"
            ],
            "renewal_eligibility": {
                "operator_command_required": true,
                "prior_closeout_required": true,
                "silent_authority_widening_forbidden": true
            },
            "epoch_replaces_mission_control_lease": false,
            "material_execution_allowed": false,
            "created_at": now,
            "updated_at": now
        }),
    )?;
    write_epoch_closeout(octon_dir, program_id, epoch_id, "open", &[], now)
}

fn write_epoch_closeout(
    octon_dir: &Path,
    program_id: &str,
    epoch_id: &str,
    status: &str,
    blockers: &[String],
    now: &str,
) -> Result<()> {
    let evaluated = status != "open";
    let gate_clear =
        |blocker: &str| evaluated && blockers.iter().all(|existing| existing != blocker);
    write_yaml(
        &stewardship_control_root(octon_dir, program_id)
            .join("epochs")
            .join(epoch_id)
            .join("closeout.yml"),
        &json!({
            "schema_version": "stewardship-epoch-closeout-v1",
            "program_id": program_id,
            "epoch_id": epoch_id,
            "status": status,
            "all_admitted_triggers_dispositioned": gate_clear("unresolved-triggers-present"),
            "spawned_missions_closed_or_carried_forward": gate_clear("spawned-missions-unclosed"),
            "evidence_complete": gate_clear("stewardship-evidence-incomplete"),
            "rollback_compensation_posture_known": gate_clear("rollback-compensation-posture-unknown"),
            "replay_disclosure_status_known": gate_clear("replay-disclosure-status-unknown"),
            "continuity_updated": gate_clear("continuity-not-updated"),
            "renewal_decision_emitted": status == "closed",
            "no_unresolved_blocking_decision_requests": gate_clear("unresolved-blocking-decision-requests"),
            "blockers": blockers,
            "updated_at": now
        }),
    )?;
    write_evidence_snapshot(octon_dir, program_id, "closeout-evidence", epoch_id, now)
}

fn write_stewardship_evidence_profile(octon_dir: &Path, program_id: &str, now: &str) -> Result<()> {
    write_yaml(
        &stewardship_control_root(octon_dir, program_id).join("evidence-profile.yml"),
        &json!({
            "schema_version": "stewardship-evidence-profile-v1",
            "program_id": program_id,
            "selected_profile": "stewardship_maintenance",
            "allowed_profiles": [
                "stewardship_observe",
                "stewardship_maintenance",
                "stewardship_repo_consequential",
                "stewardship_campaign_coordination",
                "stewardship_closeout_required"
            ],
            "required_evidence": [
                "program-snapshots",
                "epoch-snapshots",
                "trigger-evidence",
                "admission-decisions",
                "idle-decisions",
                "mission-handoff",
                "campaign-coordination-if-used",
                "renewal-decisions",
                "stewardship-ledger",
                "continuity-update",
                "disclosure-status",
                "closeout-evidence"
            ],
            "updated_at": now
        }),
    )
}

fn write_ledger(
    octon_dir: &Path,
    program_id: &str,
    now: &str,
    events: Option<Vec<Value>>,
) -> Result<()> {
    write_yaml(
        &stewardship_control_root(octon_dir, program_id).join("ledger.yml"),
        &json!({
            "schema_version": "stewardship-ledger-v1",
            "program_id": program_id,
            "role": "stewardship-level-index-not-mission-or-run-evidence",
            "mission_run_ledger_authority_ref": ".octon/state/control/execution/missions/<mission-id>/runs.yml",
            "run_journal_authority_ref": ".octon/state/control/execution/runs/<run-id>/events.ndjson",
            "program_refs": [format!(".octon/instance/stewardship/programs/{program_id}/program.yml")],
            "epoch_refs": [],
            "trigger_refs": [],
            "admission_decision_refs": [],
            "idle_decision_refs": [],
            "mission_refs": [],
            "campaign_refs": [],
            "renewal_decision_refs": [],
            "unresolved_risks": [],
            "events": events.unwrap_or_default(),
            "created_at": now,
            "updated_at": now
        }),
    )
}

fn append_ledger_event(octon_dir: &Path, program_id: &str, now: &str, event: Value) -> Result<()> {
    let ledger_path = stewardship_control_root(octon_dir, program_id).join("ledger.yml");
    let mut ledger = read_yaml_object(&ledger_path)?;
    let mut events = ledger
        .remove("events")
        .and_then(|v| v.as_array().cloned())
        .unwrap_or_default();
    events.push(event);
    upsert(&mut ledger, "events", json!(events));
    upsert(&mut ledger, "updated_at", json!(now));
    write_yaml(&ledger_path, &Value::Object(ledger))
}

fn write_idle_decision(
    octon_dir: &Path,
    program_id: &str,
    epoch_id: &str,
    trigger_id: Option<&str>,
    reason: &str,
    now: &str,
) -> Result<String> {
    let decision_id = format!(
        "idle-{}",
        short_hash(&format!("{program_id}:{epoch_id}:{reason}:{now}"))
    );
    let path = stewardship_control_root(octon_dir, program_id)
        .join("idle-decisions")
        .join(format!("{decision_id}.yml"));
    write_yaml(
        &path,
        &json!({
            "schema_version": "stewardship-idle-decision-v1",
            "program_id": program_id,
            "epoch_id": epoch_id,
            "decision_id": decision_id,
            "reason": reason,
            "trigger_id": trigger_id,
            "trigger_or_review_source": trigger_id.unwrap_or("operator_or_scheduled_review"),
            "evidence_ref": format!(".octon/state/evidence/stewardship/programs/{program_id}/idle-decisions/{decision_id}/idle.yml"),
            "next_review_time_or_trigger_condition": "next scheduled review or human objective trigger",
            "unresolved_blockers": [],
            "no_work_executed": true,
            "idle_is_successful_governed_state": true,
            "created_at": now,
            "updated_at": now
        }),
    )?;
    write_evidence_snapshot(octon_dir, program_id, "idle-decisions", &decision_id, now)?;
    append_ledger_event(
        octon_dir,
        program_id,
        now,
        json!({
            "event_type": "idle_decision_emitted",
            "idle_decision_id": decision_id,
            "trigger_id": trigger_id,
            "no_work_executed": true
        }),
    )?;
    path_to_repo_ref(octon_dir, &path)
}

fn write_renewal_decision(
    octon_dir: &Path,
    program_id: &str,
    epoch_id: &str,
    outcome: &str,
    blockers: &[String],
    now: &str,
) -> Result<String> {
    let decision_id = format!(
        "renewal-{}",
        short_hash(&format!("{program_id}:{epoch_id}:{outcome}:{now}"))
    );
    let path = stewardship_control_root(octon_dir, program_id)
        .join("renewal-decisions")
        .join(format!("{decision_id}.yml"));
    write_yaml(
        &path,
        &json!({
            "schema_version": "stewardship-renewal-decision-v1",
            "program_id": program_id,
            "epoch_id": epoch_id,
            "decision_id": decision_id,
            "outcome": outcome,
            "epoch_closeout_evidence_ref": format!(".octon/state/evidence/stewardship/programs/{program_id}/closeout/{epoch_id}/closeout.yml"),
            "budget_status": "reviewed",
            "breaker_status": "reviewed",
            "support_posture_ref": SUPPORT_TARGET_REF,
            "context_profile_freshness": "required_refs_present",
            "unresolved_risk_review": blockers,
            "decision_request_status": if blockers.is_empty() { "clear" } else { "requires_decision" },
            "silent_authority_widening": false,
            "renewal_policy_conformance": blockers.is_empty(),
            "renewal_decision_authorizes_material_execution": false,
            "created_at": now,
            "updated_at": now
        }),
    )?;
    write_evidence_snapshot(
        octon_dir,
        program_id,
        "renewal-decisions",
        &decision_id,
        now,
    )?;
    path_to_repo_ref(octon_dir, &path)
}

fn ensure_stewardship_decision(
    octon_dir: &Path,
    program_id: &str,
    epoch_id: &str,
    subject_id: &str,
    decision_type: &str,
    blockers: &[String],
    now: &str,
) -> Result<String> {
    let decision_id = format!(
        "{}-{}",
        decision_type.replace('_', "-"),
        short_hash(subject_id)
    );
    let path = stewardship_control_root(octon_dir, program_id)
        .join("decisions")
        .join(format!("{decision_id}.yml"));
    if path.is_file() {
        return Ok(decision_id);
    }
    write_yaml(
        &path,
        &json!({
            "schema_version": "decision-request-v1",
            "decision_request_id": decision_id,
            "decision_id": decision_id,
            "scope": "stewardship",
            "program_id": program_id,
            "epoch_id": epoch_id,
            "subject_id": subject_id,
            "decision_type": canonical_stewardship_decision_type(decision_type),
            "stewardship_decision_type": decision_type,
            "status": "open",
            "question": format!("Resolve stewardship {decision_type} for {subject_id}."),
            "blockers": blockers,
            "allowed_resolutions": [
                "approval",
                "denial",
                "exception_lease",
                "risk_acceptance",
                "revocation",
                "policy_clarification",
                "support_scope_decision",
                "capability_admission_decision",
                "mission_scope_decision",
                "closure_acceptance"
            ],
            "subject_refs": {
                "program_authority_ref": format!(".octon/instance/stewardship/programs/{program_id}/program.yml"),
                "program_status_ref": format!(".octon/state/control/stewardship/programs/{program_id}/status.yml"),
                "epoch_ref": format!(".octon/state/control/stewardship/programs/{program_id}/epochs/{epoch_id}/epoch.yml"),
                "subject_ref": subject_ref(program_id, subject_id)
            },
            "canonical_resolution_targets": {
                "approval_request_root": ".octon/state/control/execution/approvals/requests",
                "approval_grant_root": ".octon/state/control/execution/approvals/grants",
                "exception_lease_root": ".octon/state/control/execution/exceptions/leases",
                "revocation_root": ".octon/state/control/execution/revocations",
                "mission_control_root": ".octon/state/control/execution/missions",
                "stewardship_resolution_root": format!(".octon/state/control/stewardship/programs/{program_id}/decision-resolutions")
            },
            "evidence_root": format!(".octon/state/evidence/stewardship/programs/{program_id}/decision-requests/{decision_id}"),
            "host_comments_labels_chat_are_authority": false,
            "generated_summaries_are_authority": false,
            "decision_request_authorizes_material_execution": false,
            "created_at": now,
            "updated_at": now
        }),
    )?;
    write_evidence_snapshot(
        octon_dir,
        program_id,
        "decision-requests",
        &decision_id,
        now,
    )?;
    Ok(decision_id)
}

fn canonical_stewardship_decision_type(stewardship_decision_type: &str) -> &'static str {
    match stewardship_decision_type {
        "support_posture_widening" => "support_scope_decision",
        "recurring_connector_use" => "capability_admission_decision",
        "mission_creation" | "campaign_candidate_promotion" => "mission_scope_decision",
        "risk_acceptance_across_epochs" => "risk_acceptance",
        "idle_closure_acceptance" => "closure_acceptance",
        "stewardship_scope_change" | "epoch_renewal" | "program_opening" | "epoch_opening" => {
            "approval"
        }
        _ => "policy_clarification",
    }
}

fn subject_ref(program_id: &str, subject_id: &str) -> String {
    if subject_id == "epoch-renewal"
        || subject_id == "program-closure"
        || subject_id == "stewardship-resume"
    {
        format!(".octon/state/control/stewardship/programs/{program_id}/status.yml")
    } else {
        format!(".octon/state/control/stewardship/programs/{program_id}/triggers/{subject_id}.yml")
    }
}

fn write_mission_handoff(
    octon_dir: &Path,
    program_id: &str,
    epoch_id: &str,
    trigger_id: &str,
    engagement_id: &str,
    mission_id: &str,
    mission_ref: &str,
    now: &str,
) -> Result<String> {
    let handoff_id = format!("handoff-{trigger_id}");
    let path = stewardship_control_root(octon_dir, program_id)
        .join("mission-handoffs")
        .join(format!("{handoff_id}.yml"));
    write_yaml(
        &path,
        &json!({
            "schema_version": "stewardship-mission-handoff-v1",
            "program_id": program_id,
            "epoch_id": epoch_id,
            "trigger_id": trigger_id,
            "handoff_id": handoff_id,
            "engagement_id": engagement_id,
            "mission_id": mission_id,
            "mission_control_ref": mission_ref,
            "handoff_entrypoint": "octon mission continue",
            "v2_mission_runner_required": true,
            "run_lifecycle_required": true,
            "stewardship_material_execution_allowed": false,
            "created_at": now,
            "updated_at": now
        }),
    )?;
    write_evidence_snapshot(octon_dir, program_id, "mission-handoff", &handoff_id, now)?;
    append_ledger_event(
        octon_dir,
        program_id,
        now,
        json!({
            "event_type": "mission_handoff_created",
            "trigger_id": trigger_id,
            "mission_id": mission_id,
            "mission_control_ref": mission_ref
        }),
    )?;
    write_evidence_snapshot(octon_dir, program_id, "stewardship-ledger", "current", now)?;
    path_to_repo_ref(octon_dir, &path)
}

fn evaluate_stewardship_gates(
    octon_dir: &Path,
    program_id: &str,
    epoch_id: &str,
    blockers: &mut Vec<String>,
) -> Result<()> {
    let root = repo_root(octon_dir);
    for (reference, blocker) in [
        (
            format!(".octon/instance/stewardship/programs/{program_id}/program.yml"),
            "program-authority-missing",
        ),
        (
            format!(".octon/state/control/stewardship/programs/{program_id}/status.yml"),
            "program-status-missing",
        ),
        (
            format!(".octon/state/control/stewardship/programs/{program_id}/epochs/{epoch_id}/epoch.yml"),
            "epoch-control-missing",
        ),
        (SUPPORT_TARGET_REF.to_string(), "support-target-posture-missing"),
        (PROJECT_PROFILE_REF.to_string(), "project-profile-missing"),
        (CONNECTOR_POSTURE_REF.to_string(), "connector-posture-missing"),
        (
            CAMPAIGN_PROMOTION_CRITERIA_REF.to_string(),
            "campaign-promotion-criteria-missing",
        ),
    ] {
        if !root.join(reference).exists() {
            blockers.push(blocker.to_string());
        }
    }
    let epoch = read_yaml_value(
        &stewardship_control_root(octon_dir, program_id)
            .join("epochs")
            .join(epoch_id)
            .join("epoch.yml"),
    )?;
    if epoch.get("status").and_then(Value::as_str) != Some("active") {
        blockers.push("epoch-not-active".to_string());
    }
    if epoch
        .get("material_execution_allowed")
        .and_then(Value::as_bool)
        .unwrap_or(true)
    {
        blockers.push("epoch-claims-material-execution-authority".to_string());
    }
    enforce_timestamp_not_expired(&epoch, "end_at", "epoch-expired", blockers)?;
    evaluate_progress_gates(octon_dir, program_id, blockers)?;
    Ok(())
}

fn evaluate_progress_gates(
    octon_dir: &Path,
    program_id: &str,
    blockers: &mut Vec<String>,
) -> Result<()> {
    let control_root = stewardship_control_root(octon_dir, program_id);
    let mut trigger_counts: BTreeMap<String, usize> = BTreeMap::new();
    for path in collect_files(&control_root.join("triggers"))? {
        let value = read_yaml_value(&path)?;
        let trigger_type = value
            .get("trigger_type")
            .and_then(Value::as_str)
            .unwrap_or("unknown")
            .to_string();
        let status = value.get("status").and_then(Value::as_str).unwrap_or("");
        if matches!(
            status,
            "pending_admission" | "blocked_by_decision_request" | "deferred"
        ) {
            *trigger_counts.entry(trigger_type).or_insert(0) += 1;
        }
    }
    if trigger_counts.values().any(|count| *count >= 3) {
        blockers.push("progress-gate-repeated-trigger-without-resolution".to_string());
    }

    let renewal_count = collect_files(&control_root.join("renewal-decisions"))?
        .into_iter()
        .filter_map(|path| read_yaml_value(&path).ok())
        .filter(|value| value.get("outcome").and_then(Value::as_str) == Some("renew"))
        .count();
    let mission_handoff_count = collect_files(&control_root.join("mission-handoffs"))?.len();
    if renewal_count >= 3 && mission_handoff_count == 0 {
        blockers.push("progress-gate-repeated-renewal-without-bounded-work".to_string());
    }
    Ok(())
}

fn renewal_blockers(octon_dir: &Path, program_id: &str, epoch_id: &str) -> Result<Vec<String>> {
    let mut blockers = Vec::new();
    evaluate_stewardship_gates(octon_dir, program_id, epoch_id, &mut blockers)?;
    let control_root = stewardship_control_root(octon_dir, program_id);
    let unresolved_triggers = collect_files(&control_root.join("triggers"))?
        .into_iter()
        .filter_map(|path| read_yaml_value(&path).ok())
        .filter(|v| {
            matches!(
                v.get("status").and_then(Value::as_str),
                Some("pending_admission") | Some("blocked_by_decision_request")
            )
        })
        .count();
    if unresolved_triggers > 0 {
        blockers.push("unresolved-triggers-present".to_string());
    }
    let unresolved_decisions = collect_files(&control_root.join("decisions"))?
        .into_iter()
        .filter_map(|path| read_yaml_value(&path).ok())
        .filter(|v| v.get("status").and_then(Value::as_str) == Some("open"))
        .count();
    if unresolved_decisions > 0 {
        blockers.push("unresolved-blocking-decision-requests".to_string());
    }
    Ok(blockers)
}

fn ensure_v1_v2_dependencies(octon_dir: &Path) -> Result<()> {
    let root = repo_root(octon_dir);
    let required = [
        ".octon/framework/engine/runtime/spec/engagement-v1.schema.json",
        ".octon/framework/engine/runtime/spec/work-package-v1.schema.json",
        ".octon/framework/engine/runtime/spec/decision-request-v1.schema.json",
        ".octon/framework/engine/runtime/spec/evidence-profile-v1.schema.json",
        ".octon/framework/engine/runtime/spec/autonomy-window-v1.schema.json",
        ".octon/framework/engine/runtime/spec/mission-queue-v1.schema.json",
        ".octon/framework/engine/runtime/spec/mission-continuation-decision-v1.schema.json",
        ".octon/framework/engine/runtime/spec/mission-run-ledger-v1.schema.json",
        ".octon/framework/engine/runtime/spec/mission-evidence-profile-v1.schema.json",
        ".octon/framework/engine/runtime/spec/mission-autonomy-runtime-v2.md",
    ];
    let missing: Vec<&str> = required
        .iter()
        .copied()
        .filter(|reference| !root.join(reference).exists())
        .collect();
    if missing.is_empty() {
        Ok(())
    } else {
        bail!(
            "Continuous Stewardship Runtime v3 requires v1/v2 surfaces and fails closed; missing: {}",
            missing.join(", ")
        )
    }
}

fn ensure_campaign_boundary(octon_dir: &Path) -> Result<()> {
    let criteria = repo_root(octon_dir).join(CAMPAIGN_PROMOTION_CRITERIA_REF);
    if !criteria.is_file() {
        bail!("campaign promotion criteria are required to keep campaign hooks non-executing")
    }
    let text = fs::read_to_string(&criteria)?;
    if !text.contains("current live decision is still `no-go`")
        || !text.contains("must not launch workflows")
        || !text.contains("must not become required for normal-path execution")
    {
        bail!("campaign promotion criteria must preserve the current no-go, non-execution boundary")
    }
    Ok(())
}

fn ensure_program_authority(octon_dir: &Path, program_id: &str) -> Result<()> {
    let root = stewardship_instance_root(octon_dir, program_id);
    for file in [
        "program.yml",
        "policy.yml",
        "trigger-rules.yml",
        "review-cadence.yml",
        "campaign-policy.yml",
    ] {
        let path = root.join(file);
        if !path.is_file() {
            bail!(
                "Stewardship Program durable authority is missing: {}",
                path.display()
            );
        }
        let value = read_yaml_value(&path)?;
        if value
            .get("schema_version")
            .and_then(Value::as_str)
            .is_none()
        {
            bail!(
                "Stewardship Program authority lacks schema_version: {}",
                path.display()
            );
        }
    }
    ensure_campaign_policy_contract(&root.join("campaign-policy.yml"))?;
    Ok(())
}

fn ensure_campaign_policy_contract(path: &Path) -> Result<()> {
    let policy = read_yaml_value(path)?;
    let criteria_ref = policy
        .get("campaign_promotion_criteria_ref")
        .and_then(Value::as_str)
        .unwrap_or("");
    if criteria_ref != CAMPAIGN_PROMOTION_CRITERIA_REF {
        bail!(
            "Stewardship campaign policy must reference {CAMPAIGN_PROMOTION_CRITERIA_REF}: {}",
            path.display()
        );
    }
    if policy.get("standing_decision").and_then(Value::as_str) != Some("deferred_by_default") {
        bail!(
            "Stewardship campaign policy must keep campaigns deferred by default: {}",
            path.display()
        );
    }
    for field in [
        "campaigns_are_execution_containers",
        "campaigns_may_launch_workflows",
        "campaigns_may_claim_queue_items",
        "campaigns_may_own_runs",
        "campaigns_may_own_incidents",
        "campaigns_may_replace_missions",
        "campaigns_may_replace_stewardship",
        "campaigns_required_for_normal_stewardship",
    ] {
        if policy.get(field).and_then(Value::as_bool) != Some(false) {
            bail!("Stewardship campaign policy must set {field}: false");
        }
    }
    if policy
        .get("campaign_candidate_requires_evidence_backed_go_decision")
        .and_then(Value::as_bool)
        != Some(true)
    {
        bail!(
            "Stewardship campaign policy must require evidence-backed go decisions for campaign candidates"
        );
    }
    Ok(())
}

fn ensure_program_exists(octon_dir: &Path, program_id: &str) -> Result<()> {
    let program_ref = stewardship_instance_root(octon_dir, program_id).join("program.yml");
    if program_ref.is_file() {
        Ok(())
    } else {
        bail!(
            "Stewardship Program authority missing: {}",
            program_ref.display()
        )
    }
}

fn ensure_program_active(octon_dir: &Path, program_id: &str) -> Result<()> {
    ensure_program_exists(octon_dir, program_id)?;
    let status =
        read_yaml_value(&stewardship_control_root(octon_dir, program_id).join("status.yml"))?;
    match status
        .get("status")
        .and_then(Value::as_str)
        .unwrap_or("missing")
    {
        "active" | "idle" => Ok(()),
        other => bail!("Stewardship Program is not active: {other}"),
    }
}

fn ensure_epoch_active(octon_dir: &Path, program_id: &str, epoch_id: &str) -> Result<()> {
    let epoch = read_yaml_value(
        &stewardship_control_root(octon_dir, program_id)
            .join("epochs")
            .join(epoch_id)
            .join("epoch.yml"),
    )?;
    if epoch.get("status").and_then(Value::as_str) == Some("active") {
        Ok(())
    } else {
        bail!("no stewardship work may occur outside an active Stewardship Epoch")
    }
}

fn active_epoch_id(octon_dir: &Path, program_id: &str) -> Result<String> {
    let status =
        read_yaml_value(&stewardship_control_root(octon_dir, program_id).join("status.yml"))?;
    status
        .get("active_epoch_id")
        .and_then(Value::as_str)
        .map(ToString::to_string)
        .ok_or_else(|| anyhow!("no active Stewardship Epoch is bound for {program_id}"))
}

fn find_pending_trigger(octon_dir: &Path, program_id: &str) -> Result<String> {
    for path in collect_files(&stewardship_control_root(octon_dir, program_id).join("triggers"))? {
        let value = read_yaml_value(&path)?;
        if value.get("status").and_then(Value::as_str) == Some("pending_admission") {
            return yaml_string(&value, "trigger_id").map(ToString::to_string);
        }
    }
    bail!("no pending Stewardship Trigger exists for program {program_id}")
}

fn set_trigger_status(
    octon_dir: &Path,
    program_id: &str,
    trigger_id: &str,
    status: &str,
    now: &str,
) -> Result<()> {
    let path = stewardship_control_root(octon_dir, program_id)
        .join("triggers")
        .join(format!("{trigger_id}.yml"));
    let mut trigger = read_yaml_object(&path)?;
    upsert(&mut trigger, "status", json!(status));
    upsert(&mut trigger, "updated_at", json!(now));
    write_yaml(&path, &Value::Object(trigger))
}

fn set_epoch_state(
    octon_dir: &Path,
    program_id: &str,
    epoch_id: &str,
    status: &str,
    now: &str,
) -> Result<()> {
    let path = stewardship_control_root(octon_dir, program_id)
        .join("epochs")
        .join(epoch_id)
        .join("epoch.yml");
    let mut epoch = read_yaml_object(&path)?;
    upsert(&mut epoch, "status", json!(status));
    upsert(&mut epoch, "updated_at", json!(now));
    write_yaml(&path, &Value::Object(epoch))
}

fn next_epoch_id(octon_dir: &Path, program_id: &str) -> Result<String> {
    let epochs = stewardship_control_root(octon_dir, program_id).join("epochs");
    let count = if epochs.is_dir() {
        fs::read_dir(&epochs)?
            .filter_map(|entry| entry.ok())
            .count()
    } else {
        0
    };
    Ok(format!("{program_id}-epoch-{}", count + 1))
}

fn write_continuity(
    octon_dir: &Path,
    program_id: &str,
    epoch_id: Option<&str>,
    status: &str,
    now: &str,
) -> Result<()> {
    let root = stewardship_continuity_root(octon_dir, program_id);
    write_yaml(
        &root.join("summary.yml"),
        &json!({
            "schema_version": "stewardship-continuity-summary-v1",
            "non_authority_notice": "Continuity is resumable context only and cannot mint stewardship authority.",
            "program_id": program_id,
            "active_epoch_id": epoch_id,
            "status": status,
            "updated_at": now
        }),
    )?;
    write_yaml(
        &root.join("open-threads.yml"),
        &json!({"schema_version": "stewardship-open-threads-v1", "threads": [], "updated_at": now}),
    )?;
    write_yaml(
        &root.join("recurring-risks.yml"),
        &json!({"schema_version": "stewardship-recurring-risks-v1", "risks": ["infinite-loop-prevented-by-epoch-admission-idle-renewal-gates"], "updated_at": now}),
    )?;
    write_yaml(
        &root.join("next-review.yml"),
        &json!({"schema_version": "stewardship-next-review-v1", "next_review": "next scheduled review or human objective trigger", "updated_at": now}),
    )?;
    write_evidence_snapshot(octon_dir, program_id, "continuity", "updated", now)
}

fn write_evidence_snapshot(
    octon_dir: &Path,
    program_id: &str,
    family: &str,
    id: &str,
    now: &str,
) -> Result<()> {
    let root = stewardship_evidence_root(octon_dir, program_id)
        .join(family)
        .join(id);
    let file_name = match family {
        "triggers" => "observed.yml",
        "idle-decisions" => "idle.yml",
        "renewal-decisions" => "renewal.yml",
        "admission-decisions" => "admission.yml",
        "closeout-evidence" => "closeout.yml",
        "disclosure-status" => "disclosure.yml",
        "stewardship-ledger" => "ledger.yml",
        _ => "snapshot.yml",
    };
    let source_ref = control_snapshot_ref(program_id, family, id);
    let source_path = repo_root(octon_dir).join(&source_ref);
    let source_sha256 = if source_path.is_file() {
        Some(file_sha256(&source_path)?)
    } else {
        None
    };
    write_yaml(
        &root.join(file_name),
        &json!({
            "schema_version": "stewardship-evidence-receipt-v1",
            "program_id": program_id,
            "family": family,
            "subject_id": id,
            "retained_evidence": true,
            "generated_projection_substitute": false,
            "actor": "octon-runtime",
            "command_provenance": "octon steward",
            "outcome": "recorded",
            "control_snapshot_ref": source_ref,
            "control_snapshot_sha256": source_sha256,
            "source_refs": standard_refs(program_id),
            "replay_readiness": "control-snapshot-digest-recorded-when-source-exists",
            "rollback_compensation_posture": "not-material-execution",
            "disclosure_status": "stewardship-level-disclosure-required-before-program-closure",
            "captured_at": now
        }),
    )
}

fn control_snapshot_ref(program_id: &str, family: &str, id: &str) -> String {
    match family {
        "program" => format!(".octon/state/control/stewardship/programs/{program_id}/status.yml"),
        "epochs" => {
            format!(".octon/state/control/stewardship/programs/{program_id}/epochs/{id}/epoch.yml")
        }
        "triggers" => {
            format!(".octon/state/control/stewardship/programs/{program_id}/triggers/{id}.yml")
        }
        "admission-decisions" => format!(
            ".octon/state/control/stewardship/programs/{program_id}/admission-decisions/{id}.yml"
        ),
        "idle-decisions" => format!(
            ".octon/state/control/stewardship/programs/{program_id}/idle-decisions/{id}.yml"
        ),
        "renewal-decisions" => format!(
            ".octon/state/control/stewardship/programs/{program_id}/renewal-decisions/{id}.yml"
        ),
        "decision-requests" => {
            format!(".octon/state/control/stewardship/programs/{program_id}/decisions/{id}.yml")
        }
        "mission-handoff" => format!(
            ".octon/state/control/stewardship/programs/{program_id}/mission-handoffs/{id}.yml"
        ),
        "stewardship-ledger" => {
            format!(".octon/state/control/stewardship/programs/{program_id}/ledger.yml")
        }
        "closeout-evidence" => format!(
            ".octon/state/control/stewardship/programs/{program_id}/epochs/{id}/closeout.yml"
        ),
        "disclosure-status" => {
            format!(".octon/state/control/stewardship/programs/{program_id}/ledger.yml")
        }
        "continuity" => {
            format!(".octon/state/continuity/stewardship/programs/{program_id}/summary.yml")
        }
        _ => format!(".octon/state/control/stewardship/programs/{program_id}/status.yml"),
    }
}

fn file_sha256(path: &Path) -> Result<String> {
    let bytes = fs::read(path).with_context(|| format!("read {}", path.display()))?;
    let digest = Sha256::digest(&bytes);
    Ok(format!("{digest:x}"))
}

fn write_generated_projection(
    octon_dir: &Path,
    program_id: &str,
    epoch_id: Option<&str>,
    status: &str,
    now: &str,
) -> Result<()> {
    let root = repo_root(octon_dir)
        .join(".octon/generated/cognition/projections/materialized/stewardship");
    fs::create_dir_all(&root)?;
    let base = json!({
        "schema_version": "stewardship-generated-projection-v1",
        "non_authority_notice": "Generated stewardship projections are derived read models only. They never replace instance authority, state/control truth, or retained evidence.",
        "program_id": program_id,
        "active_epoch_id": epoch_id,
        "status": status,
        "source_refs": standard_refs(program_id),
        "updated_at": now
    });
    write_yaml(&root.join("status.yml"), &base)?;
    write_yaml(&root.join("calendar.yml"), &base)?;
    write_yaml(&root.join("health.yml"), &base)?;
    write_yaml(&root.join("open-decisions.yml"), &base)?;
    write_yaml(&root.join("ledger-summary.yml"), &base)
}

fn print_state_file(
    octon_dir: &Path,
    program_id: &str,
    command: &'static str,
    path: PathBuf,
) -> Result<StewardReport> {
    let value = read_yaml_value(&path)?;
    println!("{}", serde_json::to_string_pretty(&value)?);
    Ok(report(
        command,
        "inspected",
        Some(program_id.to_string()),
        active_epoch_id(octon_dir, program_id).ok(),
        None,
        BTreeMap::from([(
            "inspected_ref".to_string(),
            path_to_repo_ref(octon_dir, &path)?,
        )]),
        "inspected",
        format!("octon steward status --program-id {program_id}"),
    ))
}

fn print_dir_index(
    octon_dir: &Path,
    program_id: &str,
    command: &'static str,
    path: PathBuf,
) -> Result<StewardReport> {
    let mut values = Vec::new();
    collect_yaml_files(&path, &mut values)?;
    println!(
        "{}",
        serde_json::to_string_pretty(&json!({
            "schema_version": format!("{command}-index-v1"),
            "program_id": program_id,
            "items": values
        }))?
    );
    Ok(report(
        command,
        "inspected",
        Some(program_id.to_string()),
        active_epoch_id(octon_dir, program_id).ok(),
        None,
        BTreeMap::from([(
            "inspected_root".to_string(),
            path_to_repo_ref(octon_dir, &path)?,
        )]),
        "inspected",
        format!("octon steward status --program-id {program_id}"),
    ))
}

fn collect_yaml_files(root: &Path, out: &mut Vec<Value>) -> Result<()> {
    for path in collect_files(root)? {
        out.push(read_yaml_value(&path)?);
    }
    Ok(())
}

fn collect_files(root: &Path) -> Result<Vec<PathBuf>> {
    let mut files = Vec::new();
    if !root.exists() {
        return Ok(files);
    }
    if root.is_file() {
        files.push(root.to_path_buf());
        return Ok(files);
    }
    for entry in fs::read_dir(root)? {
        let entry = entry?;
        let path = entry.path();
        if path.is_dir() {
            files.extend(collect_files(&path)?);
        } else if path.extension().and_then(|ext| ext.to_str()) == Some("yml") {
            files.push(path);
        }
    }
    files.sort();
    Ok(files)
}

fn find_program_for_decision(octon_dir: &Path, decision_id: &str) -> Result<String> {
    let root = repo_root(octon_dir).join(".octon/state/control/stewardship/programs");
    for path in collect_files(&root)? {
        if let Ok(value) = read_yaml_value(&path) {
            let matches_request = value
                .get("decision_request_id")
                .or_else(|| value.get("decision_id"))
                .and_then(Value::as_str)
                == Some(decision_id);
            if matches_request {
                if let Some(program_id) = value.get("program_id").and_then(Value::as_str) {
                    return Ok(program_id.to_string());
                }
            }
        }
        if path.file_name().and_then(|name| name.to_str()) == Some(&format!("{decision_id}.yml")) {
            if let Ok(relative) = path.strip_prefix(&root) {
                if let Some(program_id) = relative
                    .components()
                    .next()
                    .and_then(|component| component.as_os_str().to_str())
                {
                    return Ok(program_id.to_string());
                }
            }
        }
    }
    bail!("stewardship Decision Request not found: {decision_id}")
}

fn standard_refs(program_id: &str) -> BTreeMap<String, String> {
    BTreeMap::from([
        (
            "program_authority_ref".to_string(),
            format!(".octon/instance/stewardship/programs/{program_id}/program.yml"),
        ),
        (
            "program_status_ref".to_string(),
            format!(".octon/state/control/stewardship/programs/{program_id}/status.yml"),
        ),
        (
            "ledger_ref".to_string(),
            format!(".octon/state/control/stewardship/programs/{program_id}/ledger.yml"),
        ),
        (
            "evidence_root".to_string(),
            format!(".octon/state/evidence/stewardship/programs/{program_id}"),
        ),
    ])
}

fn default_trigger_summary(trigger_type: &str) -> &'static str {
    match trigger_type {
        "scheduled_review" => "Scheduled stewardship review.",
        "human_objective" => "Human objective entered stewardship admission.",
        "prior_mission_followup" => "Prior mission follow-up requires admission review.",
        _ => "Recognized stewardship trigger routed through fail-closed admission.",
    }
}

fn repo_root(octon_dir: &Path) -> PathBuf {
    octon_dir.parent().unwrap_or(octon_dir).to_path_buf()
}

fn stewardship_instance_root(octon_dir: &Path, program_id: &str) -> PathBuf {
    repo_root(octon_dir)
        .join(".octon/instance/stewardship/programs")
        .join(program_id)
}

fn stewardship_control_root(octon_dir: &Path, program_id: &str) -> PathBuf {
    repo_root(octon_dir)
        .join(".octon/state/control/stewardship/programs")
        .join(program_id)
}

fn stewardship_evidence_root(octon_dir: &Path, program_id: &str) -> PathBuf {
    repo_root(octon_dir)
        .join(".octon/state/evidence/stewardship/programs")
        .join(program_id)
}

fn stewardship_continuity_root(octon_dir: &Path, program_id: &str) -> PathBuf {
    repo_root(octon_dir)
        .join(".octon/state/continuity/stewardship/programs")
        .join(program_id)
}

fn write_yaml<T: Serialize + ?Sized>(path: &Path, value: &T) -> Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    let mut yaml = serde_yaml::to_string(value)?;
    if yaml.starts_with("---\n") {
        yaml = yaml.trim_start_matches("---\n").to_string();
    }
    fs::write(path, yaml).with_context(|| format!("write {}", path.display()))
}

fn read_yaml_value(path: &Path) -> Result<Value> {
    let text = fs::read_to_string(path).with_context(|| format!("read {}", path.display()))?;
    Ok(serde_yaml::from_str(&text).with_context(|| format!("parse YAML {}", path.display()))?)
}

fn read_yaml_object(path: &Path) -> Result<Map<String, Value>> {
    match read_yaml_value(path)? {
        Value::Object(map) => Ok(map),
        _ => bail!("{} must be a YAML object", path.display()),
    }
}

fn yaml_string<'a>(value: &'a Value, field: &str) -> Result<&'a str> {
    value
        .get(field)
        .and_then(Value::as_str)
        .ok_or_else(|| anyhow!("missing string field {field}"))
}

fn upsert(object: &mut Map<String, Value>, key: &str, value: Value) {
    object.insert(key.to_string(), value);
}

fn enforce_timestamp_not_expired(
    value: &Value,
    field: &str,
    blocker: &str,
    blockers: &mut Vec<String>,
) -> Result<()> {
    let Some(raw) = value.get(field).and_then(Value::as_str) else {
        blockers.push(format!("{blocker}-missing"));
        return Ok(());
    };
    match OffsetDateTime::parse(raw, &Rfc3339) {
        Ok(timestamp) if timestamp > OffsetDateTime::now_utc() => Ok(()),
        Ok(_) => {
            blockers.push(blocker.to_string());
            Ok(())
        }
        Err(err) => bail!("invalid RFC3339 timestamp in {field}: {err}"),
    }
}

fn short_hash(input: &str) -> String {
    let digest = Sha256::digest(input.as_bytes());
    format!("{digest:x}").chars().take(12).collect()
}

fn report(
    command: &'static str,
    status: &str,
    program_id: Option<String>,
    epoch_id: Option<String>,
    trigger_id: Option<String>,
    refs: BTreeMap<String, String>,
    outcome: &str,
    next_command: String,
) -> StewardReport {
    StewardReport {
        command,
        status: status.to_string(),
        program_id,
        epoch_id,
        trigger_id,
        refs,
        outcome: outcome.to_string(),
        next_command,
    }
}

fn print_report(report: &StewardReport) -> Result<()> {
    println!("{}", serde_json::to_string_pretty(report)?);
    Ok(())
}

fn validate_id(value: &str, field: &str) -> Result<()> {
    if value.is_empty()
        || !value
            .chars()
            .all(|ch| ch.is_ascii_alphanumeric() || ch == '-' || ch == '_' || ch == '.')
    {
        bail!("{field} must contain only ASCII letters, digits, dash, underscore, or dot")
    }
    Ok(())
}
