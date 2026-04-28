use super::{
    engagement, path_to_repo_ref, CapabilityCmd, ConnectorAdmitCmd, ConnectorCmd,
    ConnectorDecisionCmd, ConnectorInspectCmd, ConnectorListCmd, ConnectorOperationCmd,
    ContinueCmd, DecisionListCmd, DecisionResolveCmd, MissionCmd, MissionOpenCmd, SupportCmd,
    SupportProofSubject,
};
use crate::workflow::ExecutorKind;
use anyhow::{anyhow, bail, Context, Result};
use octon_authority_engine::now_rfc3339;
use serde::Serialize;
use serde_json::{json, Map, Value};
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};
use time::{format_description::well_known::Rfc3339, Duration, OffsetDateTime};

const MISSION_CONTINUATION_POLICY_REF: &str =
    ".octon/instance/governance/policies/mission-continuation.yml";
const AUTONOMY_WINDOW_POLICY_REF: &str = ".octon/instance/governance/policies/autonomy-window.yml";
const CONNECTOR_ADMISSION_POLICY_REF: &str =
    ".octon/instance/governance/policies/connector-admission.yml";
const CONNECTOR_CREDENTIAL_POLICY_REF: &str =
    ".octon/instance/governance/policies/connector-credentials.yml";
const CONNECTOR_DATA_BOUNDARY_POLICY_REF: &str =
    ".octon/instance/governance/policies/connector-data-boundaries.yml";
const CONNECTOR_EVIDENCE_PROFILE_POLICY_REF: &str =
    ".octon/instance/governance/policies/connector-evidence-profiles.yml";
const NETWORK_EGRESS_POLICY_REF: &str = ".octon/instance/governance/policies/network-egress.yml";
const EXECUTION_BUDGET_POLICY_REF: &str =
    ".octon/instance/governance/policies/execution-budgets.yml";
const MISSION_CLOSEOUT_POLICY_REF: &str =
    ".octon/instance/governance/policies/mission-closeout.yml";
const CONNECTOR_REGISTRY_REF: &str = ".octon/instance/governance/connectors/registry.yml";
const CONNECTOR_POSTURE_REF: &str = ".octon/instance/governance/connectors/posture.yml";
const SUPPORT_TARGET_REF: &str = ".octon/instance/governance/support-targets.yml";
const CAPABILITY_PACK_REGISTRY_REF: &str =
    ".octon/instance/governance/capability-packs/registry.yml";
const CONTEXT_PACK_POLICY_REF: &str = ".octon/instance/governance/policies/context-packing.yml";
const PROJECT_PROFILE_REF: &str = ".octon/instance/locality/project-profile.yml";
const DEFAULT_WORKFLOW_ID: &str = "agent-led-happy-path";

#[derive(Debug, Clone, Serialize)]
struct MissionReport {
    command: &'static str,
    status: String,
    engagement_id: Option<String>,
    mission_id: Option<String>,
    refs: BTreeMap<String, String>,
    outcome: String,
    next_command: String,
}

pub(super) fn cmd_continue(args: ContinueCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let engagement_id = match args.engagement_id {
        Some(id) => id,
        None => find_single_active_engagement(&octon_dir)?,
    };
    let mission_id = match args.mission_id {
        Some(id) => id,
        None => resolve_engagement_active_mission(&octon_dir, &engagement_id)?,
    };
    let report = continue_mission(&octon_dir, &mission_id, args.start_run)?;
    print_report(&report)
}

pub(super) fn cmd_mission(cmd: MissionCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let report = match cmd {
        MissionCmd::Open(args) => open_mission(&octon_dir, &args)?,
        MissionCmd::Status(args) => status_mission(&octon_dir, &args.mission_id)?,
        MissionCmd::Continue(args) => {
            continue_mission(&octon_dir, &args.mission_id, args.start_run)?
        }
        MissionCmd::Pause(args) => set_mission_state(&octon_dir, &args.mission_id, "paused")?,
        MissionCmd::Resume(args) => resume_mission(&octon_dir, &args.mission_id)?,
        MissionCmd::Revoke(args) => set_mission_state(&octon_dir, &args.mission_id, "revoked")?,
        MissionCmd::Close(args) => close_mission(&octon_dir, &args.mission_id)?,
        MissionCmd::Queue(args) => queue_mission(&octon_dir, &args.mission_id)?,
        MissionCmd::Next(args) => next_mission(&octon_dir, &args.mission_id)?,
    };
    print_report(&report)
}

pub(super) fn cmd_decision_list(args: DecisionListCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let mut decisions = Vec::new();
    let root = repo_root(&octon_dir);
    if let Some(engagement_id) = args.engagement_id {
        collect_decisions(
            &root
                .join(".octon/state/control/engagements")
                .join(engagement_id)
                .join("decisions"),
            &mut decisions,
        )?;
    } else if let Some(mission_id) = args.mission_id {
        collect_decisions(
            &root
                .join(".octon/state/control/execution/missions")
                .join(mission_id)
                .join("decisions"),
            &mut decisions,
        )?;
    } else {
        collect_decisions(
            &root.join(".octon/state/control/engagements"),
            &mut decisions,
        )?;
        collect_decisions(
            &root.join(".octon/state/control/execution/missions"),
            &mut decisions,
        )?;
        collect_decisions(
            &root.join(".octon/state/control/connectors"),
            &mut decisions,
        )?;
    }
    println!(
        "{}",
        serde_json::to_string_pretty(&json!({
            "schema_version": "decision-request-list-v1",
            "authority_notice": "Decision state is read from state/control roots; generated views and host comments are not authority.",
            "decisions": decisions
        }))?
    );
    Ok(())
}

pub(super) fn cmd_decision_resolve(args: DecisionResolveCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let response = args.response.as_resolution();
    let report = if let Some(mission_id) = args
        .mission_id
        .or_else(|| find_mission_for_decision(&octon_dir, &args.decision_id).ok())
    {
        resolve_mission_decision(&octon_dir, &mission_id, &args.decision_id, response)?
    } else if let Some((connector_id, decision_path)) =
        find_connector_for_decision(&octon_dir, &args.decision_id).ok()
    {
        resolve_connector_decision(
            &octon_dir,
            &connector_id,
            &decision_path,
            &args.decision_id,
            response,
        )?
    } else {
        bail!(
            "Decision Request not found in mission or connector control roots: {}",
            args.decision_id
        );
    };
    print_report(&report)
}

pub(super) fn mission_decision_exists(mission_id: Option<&str>, decision_id: &str) -> Result<bool> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    if let Some(mission_id) = mission_id {
        return Ok(mission_control_root(&octon_dir, mission_id)
            .join("decisions")
            .join(format!("{decision_id}.yml"))
            .is_file());
    }
    Ok(find_mission_for_decision(&octon_dir, decision_id).is_ok())
}

pub(super) fn cmd_connector(cmd: ConnectorCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let report = match cmd {
        ConnectorCmd::List(args) => list_connectors(&octon_dir, args)?,
        ConnectorCmd::Inspect(args) => inspect_connector(&octon_dir, args)?,
        ConnectorCmd::Status(args) => connector_status(&octon_dir, args)?,
        ConnectorCmd::Validate(args) => validate_connector_operation(&octon_dir, args)?,
        ConnectorCmd::Admit(args) => admit_connector(&octon_dir, args)?,
        ConnectorCmd::Stage(args) => stage_connector(&octon_dir, args)?,
        ConnectorCmd::Quarantine(args) => quarantine_connector(&octon_dir, args)?,
        ConnectorCmd::Retire(args) => retire_connector(&octon_dir, args)?,
        ConnectorCmd::Dossier(args) => connector_dossier(&octon_dir, args)?,
        ConnectorCmd::Evidence(args) => connector_evidence(&octon_dir, args)?,
        ConnectorCmd::Drift(args) => connector_drift(&octon_dir, args)?,
        ConnectorCmd::Decision(args) => connector_decision(&octon_dir, args)?,
    };
    print_report(&report)
}

pub(super) fn cmd_support(cmd: SupportCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let report = match cmd {
        SupportCmd::Proof(args) => match args.subject {
            SupportProofSubject::Connector(args) => connector_support_proof(&octon_dir, args)?,
        },
        SupportCmd::ValidateConnector(args) => validate_connector_operation(&octon_dir, args)?,
    };
    print_report(&report)
}

pub(super) fn cmd_capability(cmd: CapabilityCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let report = match cmd {
        CapabilityCmd::MapConnector(args) => connector_capability_map(&octon_dir, args)?,
    };
    print_report(&report)
}

fn open_mission(octon_dir: &Path, args: &MissionOpenCmd) -> Result<MissionReport> {
    validate_id(&args.engagement_id, "engagement_id")?;
    ensure_required_v1(octon_dir, &args.engagement_id)?;
    ensure_machine_policies(octon_dir)?;
    let mission_id = args
        .mission_id
        .clone()
        .unwrap_or_else(|| format!("mission-{}", args.engagement_id));
    validate_id(&mission_id, "mission_id")?;
    let now = now_rfc3339()?;
    let engagement_root = repo_root(octon_dir)
        .join(".octon/state/control/engagements")
        .join(&args.engagement_id);
    let work_package = read_yaml_value(&engagement_root.join("work-package.yml"))?;
    let objective_summary = work_package
        .get("implementation_plan_summary")
        .and_then(Value::as_str)
        .unwrap_or("Continue bounded governed mission work.");
    let mission_root = mission_control_root(octon_dir, &mission_id);
    let evidence_root = mission_evidence_root(octon_dir, &mission_id);
    let continuity_root = mission_continuity_root(octon_dir, &mission_id);
    let generated_root =
        repo_root(octon_dir).join(".octon/generated/cognition/projections/materialized/missions");
    fs::create_dir_all(&mission_root)?;
    fs::create_dir_all(&evidence_root)?;
    fs::create_dir_all(&continuity_root)?;
    fs::create_dir_all(&generated_root)?;

    let mission_instance_ref =
        format!(".octon/instance/orchestration/missions/{mission_id}/mission.yml");
    let mission_instance_path = repo_root(octon_dir).join(&mission_instance_ref);
    if !mission_instance_path.is_file() {
        write_yaml(
            &mission_instance_path,
            &json!({
                "schema_version": "octon-mission-v2",
                "mission_id": mission_id,
                "title": format!("Mission: {mission_id}"),
                "summary": objective_summary,
                "status": "active",
                "mission_class": "maintenance",
                "owner_ref": "operator://octon-maintainers",
                "created_at": now,
                "risk_ceiling": "ACP-1",
                "allowed_action_classes": ["repo-maintenance", "validation", "documentation"],
                "default_safing_subset": ["observe_only", "stage_only"],
                "default_schedule_hint": "interruptible_scheduled",
                "default_overlap_policy": "skip",
                "scope_ids": ["octon-harness"],
                "success_criteria": ["Mission queue reaches a resolved terminal disposition."],
                "failure_conditions": ["A required mission gate cannot be satisfied without operator decision."],
                "objective_binding": {
                    "workspace_charter_ref": ".octon/instance/charter/workspace.yml",
                    "execution_unit": "run-contract",
                    "run_control_root": ".octon/state/control/execution/runs",
                    "mission_role": "continuity-container",
                    "mission_required_for": ["multi-run-continuation"]
                },
                "notes_ref": "mission.md"
            }),
        )?;
    }

    write_yaml(
        &engagement_root.join("active-mission.yml"),
        &json!({
            "schema_version": "engagement-active-mission-v1",
            "engagement_id": args.engagement_id,
            "mission_id": mission_id,
            "mission_control_ref": format!(".octon/state/control/execution/missions/{mission_id}/mission.yml"),
            "mission_authority_ref": mission_instance_ref,
            "status": "active",
            "one_active_mission_per_engagement": true,
            "updated_at": now
        }),
    )?;
    write_yaml(
        &mission_root.join("mission.yml"),
        &json!({
            "schema_version": "mission-runtime-state-v1",
            "mission_id": mission_id,
            "engagement_id": args.engagement_id,
            "status": "active",
            "mission_authority_ref": mission_instance_ref,
            "engagement_ref": format!(".octon/state/control/engagements/{}/engagement.yml", args.engagement_id),
            "work_package_ref": format!(".octon/state/control/engagements/{}/work-package.yml", args.engagement_id),
            "autonomy_window_ref": format!(".octon/state/control/execution/missions/{mission_id}/autonomy-window.yml"),
            "queue_ref": format!(".octon/state/control/execution/missions/{mission_id}/queue.yml"),
            "runs_ref": format!(".octon/state/control/execution/missions/{mission_id}/runs.yml"),
            "closeout_ref": format!(".octon/state/control/execution/missions/{mission_id}/closeout.yml"),
            "created_at": now,
            "updated_at": now
        }),
    )?;
    write_autonomy_window(octon_dir, &mission_id, &args.engagement_id, &now, "active")?;
    write_budget(octon_dir, &mission_id, &now, "healthy")?;
    write_breakers(octon_dir, &mission_id, &now, "clear", Vec::<String>::new())?;
    write_queue(octon_dir, &mission_id, &args.engagement_id, &now)?;
    write_runs_ledger(octon_dir, &mission_id, &now)?;
    write_closeout_state(octon_dir, &mission_id, &now, "open", &[])?;
    write_mission_evidence_profile(octon_dir, &mission_id, &now, "mission_repo_consequential")?;
    write_mission_evidence_snapshot(octon_dir, &mission_id, "autonomy-window", "opened", &now)?;
    write_mission_continuity(octon_dir, &mission_id, &args.engagement_id, &now, "open")?;
    write_mission_evidence_baseline(octon_dir, &mission_id, &now)?;
    write_generated_mission_projection(
        octon_dir,
        &mission_id,
        &args.engagement_id,
        "active",
        &now,
    )?;

    Ok(report(
        "mission-open",
        "active",
        Some(args.engagement_id.clone()),
        Some(mission_id.clone()),
        BTreeMap::from([
            (
                "active_mission_ref".to_string(),
                format!(
                    ".octon/state/control/engagements/{}/active-mission.yml",
                    args.engagement_id
                ),
            ),
            (
                "mission_control_ref".to_string(),
                format!(".octon/state/control/execution/missions/{mission_id}/mission.yml"),
            ),
            (
                "autonomy_window_ref".to_string(),
                format!(".octon/state/control/execution/missions/{mission_id}/autonomy-window.yml"),
            ),
            (
                "queue_ref".to_string(),
                format!(".octon/state/control/execution/missions/{mission_id}/queue.yml"),
            ),
        ]),
        "ready",
        format!("octon mission continue --mission-id {mission_id}"),
    ))
}

pub(super) fn open_mission_for_stewardship(
    octon_dir: &Path,
    engagement_id: &str,
    mission_id: Option<String>,
) -> Result<(String, String)> {
    let args = MissionOpenCmd {
        engagement_id: engagement_id.to_string(),
        mission_id,
    };
    let report = open_mission(octon_dir, &args)?;
    let mission_id = report
        .mission_id
        .clone()
        .ok_or_else(|| anyhow!("mission open did not return a mission_id"))?;
    let mission_ref = report
        .refs
        .get("mission_control_ref")
        .cloned()
        .unwrap_or_else(|| {
            format!(".octon/state/control/execution/missions/{mission_id}/mission.yml")
        });
    Ok((mission_id, mission_ref))
}

fn continue_mission(octon_dir: &Path, mission_id: &str, start_run: bool) -> Result<MissionReport> {
    validate_id(mission_id, "mission_id")?;
    ensure_machine_policies(octon_dir)?;
    let mission_root = mission_control_root(octon_dir, mission_id);
    let mission = read_yaml_value(&mission_root.join("mission.yml"))?;
    let engagement_id = yaml_string(&mission, "engagement_id")?.to_string();
    let now = now_rfc3339()?;
    let mut blockers = Vec::new();
    evaluate_autonomy_window(octon_dir, mission_id, &mut blockers)?;
    evaluate_lease(octon_dir, mission_id, &engagement_id, &mut blockers)?;
    evaluate_budget(octon_dir, mission_id, &mut blockers)?;
    evaluate_breakers(octon_dir, mission_id, &mut blockers)?;
    evaluate_context_support_capability(octon_dir, &engagement_id, mission_id, &mut blockers)?;
    let selected_slice = select_next_slice(octon_dir, mission_id, &mut blockers)?;
    if !blockers.is_empty() {
        let decision_id = ensure_mission_decision(
            octon_dir,
            mission_id,
            &engagement_id,
            "mission-continuation-blocked",
            "approval_required",
            &blockers,
            &now,
        )?;
        let continuation_ref = write_continuation_decision(
            octon_dir,
            mission_id,
            &engagement_id,
            selected_slice.as_deref(),
            None,
            "pause",
            &blockers,
            Some(&decision_id),
            &now,
        )?;
        return Ok(report(
            "mission-continue",
            "requires_decision",
            Some(engagement_id),
            Some(mission_id.to_string()),
            BTreeMap::from([
                ("continuation_decision_ref".to_string(), continuation_ref),
                ("decision_request_ref".to_string(), format!(".octon/state/control/execution/missions/{mission_id}/decisions/{decision_id}.yml")),
            ]),
            "requires_decision",
            format!("octon decide resolve {decision_id} --mission-id {mission_id} --response approve"),
        ));
    }
    let slice_id = selected_slice.ok_or_else(|| anyhow!("no selectable Action Slice"))?;
    let candidate_ref = match existing_slice_candidate_ref(octon_dir, mission_id, &slice_id)? {
        Some(existing_ref) => {
            let existing_path = repo_root(octon_dir).join(&existing_ref);
            if !existing_path.is_file() {
                bail!(
                    "Action Slice {slice_id} references missing run-contract candidate {existing_ref}"
                );
            }
            existing_ref
        }
        None => compile_next_candidate(octon_dir, mission_id, &engagement_id, &slice_id, &now)?,
    };
    let decision_id = ensure_mission_decision(
        octon_dir,
        mission_id,
        &engagement_id,
        &format!("authorize-{slice_id}"),
        "approval_required",
        &["mission-run-contract-candidate-requires-operator-resolution".to_string()],
        &now,
    )?;
    let decision_status = mission_decision_status(octon_dir, mission_id, &decision_id)?;
    update_slice_status(
        octon_dir,
        mission_id,
        &slice_id,
        "ready_for_authorization",
        Some(&candidate_ref),
        &now,
    )?;
    update_runs_ledger_candidate(octon_dir, mission_id, &slice_id, &candidate_ref, &now)?;
    let decision_open = decision_status != "resolved";
    let blockers = if decision_open {
        vec!["decision-request-open".to_string()]
    } else {
        Vec::new()
    };
    let continuation_ref = write_continuation_decision(
        octon_dir,
        mission_id,
        &engagement_id,
        Some(&slice_id),
        Some(&candidate_ref),
        if decision_open { "stage" } else { "continue" },
        &blockers,
        if decision_open {
            Some(&decision_id)
        } else {
            None
        },
        &now,
    )?;
    write_mission_evidence_snapshot(
        octon_dir,
        mission_id,
        "continuation-decisions",
        "candidate-prepared",
        &now,
    )?;
    if !decision_open {
        if start_run {
            let descriptor = engagement::materialize_run_candidate_for_start(
                octon_dir,
                &repo_root(octon_dir).join(&candidate_ref),
            )?;
            update_runs_ledger_canonical(
                octon_dir,
                mission_id,
                &candidate_ref,
                &descriptor.run_id,
                &descriptor.run_contract_ref,
                &now,
            )?;
            super::run_descriptor_start(
                octon_dir,
                descriptor,
                false,
                ExecutorKind::Auto,
                None,
                None,
                true,
            )?;
        }
        return Ok(report(
            "mission-continue",
            if start_run { "prepared_run" } else { "ready" },
            Some(engagement_id),
            Some(mission_id.to_string()),
            BTreeMap::from([
                ("action_slice_id".to_string(), slice_id),
                ("run_contract_candidate_ref".to_string(), candidate_ref),
                ("continuation_decision_ref".to_string(), continuation_ref),
            ]),
            if start_run { "prepared_run" } else { "ready" },
            "octon run start --contract <run-contract>".to_string(),
        ));
    }
    if start_run {
        bail!(
            "mission runner prepared {candidate_ref}; resolve Decision Request {decision_id} before run start"
        );
    }
    Ok(report(
        "mission-continue",
        "requires_decision",
        Some(engagement_id),
        Some(mission_id.to_string()),
        BTreeMap::from([
            ("action_slice_id".to_string(), slice_id),
            ("run_contract_candidate_ref".to_string(), candidate_ref),
            ("continuation_decision_ref".to_string(), continuation_ref),
            ("decision_request_ref".to_string(), format!(".octon/state/control/execution/missions/{mission_id}/decisions/{decision_id}.yml")),
        ]),
        "stage",
        format!("octon decide resolve {decision_id} --mission-id {mission_id} --response approve"),
    ))
}

fn status_mission(octon_dir: &Path, mission_id: &str) -> Result<MissionReport> {
    let mission_root = mission_control_root(octon_dir, mission_id);
    let mission = read_yaml_value(&mission_root.join("mission.yml"))?;
    let engagement_id = yaml_string(&mission, "engagement_id")?.to_string();
    let status = mission
        .get("status")
        .and_then(Value::as_str)
        .unwrap_or("unknown")
        .to_string();
    Ok(report(
        "mission-status",
        &status,
        Some(engagement_id),
        Some(mission_id.to_string()),
        BTreeMap::from([
            (
                "mission_control_ref".to_string(),
                format!(".octon/state/control/execution/missions/{mission_id}/mission.yml"),
            ),
            (
                "autonomy_window_ref".to_string(),
                format!(".octon/state/control/execution/missions/{mission_id}/autonomy-window.yml"),
            ),
            (
                "queue_ref".to_string(),
                format!(".octon/state/control/execution/missions/{mission_id}/queue.yml"),
            ),
            (
                "runs_ref".to_string(),
                format!(".octon/state/control/execution/missions/{mission_id}/runs.yml"),
            ),
        ]),
        &status,
        format!("octon mission next --mission-id {mission_id}"),
    ))
}

fn queue_mission(octon_dir: &Path, mission_id: &str) -> Result<MissionReport> {
    let queue_path = mission_control_root(octon_dir, mission_id).join("queue.yml");
    let queue = read_yaml_value(&queue_path)?;
    println!("{}", serde_json::to_string_pretty(&queue)?);
    status_mission(octon_dir, mission_id)
}

fn next_mission(octon_dir: &Path, mission_id: &str) -> Result<MissionReport> {
    let mut blockers = Vec::new();
    let next = select_next_slice(octon_dir, mission_id, &mut blockers)?;
    println!(
        "{}",
        serde_json::to_string_pretty(&json!({
            "schema_version": "mission-next-action-slice-v1",
            "mission_id": mission_id,
            "next_action_slice_id": next,
            "blockers": blockers
        }))?
    );
    status_mission(octon_dir, mission_id)
}

fn resume_mission(octon_dir: &Path, mission_id: &str) -> Result<MissionReport> {
    let mission_root = mission_control_root(octon_dir, mission_id);
    let mission = read_yaml_value(&mission_root.join("mission.yml"))?;
    let engagement_id = yaml_string(&mission, "engagement_id")?.to_string();
    let mut blockers = Vec::new();
    let lease = read_yaml_value(&mission_root.join("lease.yml"))?;
    match lease
        .get("state")
        .and_then(Value::as_str)
        .unwrap_or("expired")
    {
        "paused" | "active" => {}
        "expired" => {
            blockers.push("mission-control-lease-expired-requires-extension-decision".to_string())
        }
        "revoked" => {
            blockers.push("mission-control-lease-revoked-requires-new-authority".to_string())
        }
        other => blockers.push(format!("mission-control-lease-invalid-state-{other}")),
    }
    enforce_timestamp_not_expired(
        &lease,
        "expires_at",
        "mission-control-lease-expired",
        &mut blockers,
    )?;
    evaluate_budget(octon_dir, mission_id, &mut blockers)?;
    evaluate_breakers(octon_dir, mission_id, &mut blockers)?;
    evaluate_context_support_capability(octon_dir, &engagement_id, mission_id, &mut blockers)?;
    if !blockers.is_empty() {
        let now = now_rfc3339()?;
        let decision_id = ensure_mission_decision(
            octon_dir,
            mission_id,
            &engagement_id,
            "mission-resume-blocked",
            "mission_lease_extension",
            &blockers,
            &now,
        )?;
        return Ok(report(
            "mission-resume",
            "requires_decision",
            Some(engagement_id),
            Some(mission_id.to_string()),
            BTreeMap::from([(
                "decision_request_ref".to_string(),
                format!(
                    ".octon/state/control/execution/missions/{mission_id}/decisions/{decision_id}.yml"
                ),
            )]),
            "requires_decision",
            format!("octon decide resolve {decision_id} --mission-id {mission_id} --response approve"),
        ));
    }
    set_mission_state(octon_dir, mission_id, "active")
}

fn set_mission_state(octon_dir: &Path, mission_id: &str, state: &str) -> Result<MissionReport> {
    let mission_root = mission_control_root(octon_dir, mission_id);
    let now = now_rfc3339()?;
    let mut mission = read_yaml_object(&mission_root.join("mission.yml"))?;
    upsert(&mut mission, "status", json!(state));
    upsert(&mut mission, "updated_at", json!(now));
    write_yaml(
        &mission_root.join("mission.yml"),
        &Value::Object(mission.clone()),
    )?;
    if mission_root.join("lease.yml").is_file() {
        let mut lease = read_yaml_object(&mission_root.join("lease.yml"))?;
        if state == "active"
            && matches!(
                lease
                    .get("state")
                    .and_then(Value::as_str)
                    .unwrap_or("expired"),
                "expired" | "revoked"
            )
        {
            bail!(
                "refusing to resume expired or revoked mission-control lease without new authority"
            );
        }
        upsert(
            &mut lease,
            "state",
            json!(match state {
                "active" => "active",
                "revoked" => "revoked",
                _ => "paused",
            }),
        );
        if state == "revoked" {
            upsert(
                &mut lease,
                "revocation_reason",
                json!("operator mission revoke command"),
            );
        }
        upsert(&mut lease, "last_reviewed_at", json!(now));
        write_yaml(&mission_root.join("lease.yml"), &Value::Object(lease))?;
    }
    if mission_root.join("autonomy-window.yml").is_file() {
        let mut window = read_yaml_object(&mission_root.join("autonomy-window.yml"))?;
        upsert(&mut window, "state", json!(state));
        upsert(&mut window, "updated_at", json!(now));
        write_yaml(
            &mission_root.join("autonomy-window.yml"),
            &Value::Object(window),
        )?;
    }
    let engagement_id = mission
        .get("engagement_id")
        .and_then(Value::as_str)
        .unwrap_or("")
        .to_string();
    write_mission_evidence_snapshot(octon_dir, mission_id, "autonomy-window", state, &now)?;
    Ok(report(
        "mission-state",
        state,
        Some(engagement_id),
        Some(mission_id.to_string()),
        BTreeMap::from([(
            "mission_control_ref".to_string(),
            format!(".octon/state/control/execution/missions/{mission_id}/mission.yml"),
        )]),
        state,
        format!("octon mission status --mission-id {mission_id}"),
    ))
}

fn close_mission(octon_dir: &Path, mission_id: &str) -> Result<MissionReport> {
    let now = now_rfc3339()?;
    let mission_root = mission_control_root(octon_dir, mission_id);
    let mission = read_yaml_value(&mission_root.join("mission.yml"))?;
    let engagement_id = yaml_string(&mission, "engagement_id")?.to_string();
    let blockers = closeout_blockers(octon_dir, mission_id)?;
    if !blockers.is_empty() {
        write_closeout_state(octon_dir, mission_id, &now, "blocked", &blockers)?;
        let decision_id = ensure_mission_decision(
            octon_dir,
            mission_id,
            &engagement_id,
            "mission-closeout-acceptance",
            "mission_closeout_acceptance",
            &blockers,
            &now,
        )?;
        return Ok(report(
            "mission-close",
            "blocked",
            Some(engagement_id),
            Some(mission_id.to_string()),
            BTreeMap::from([
                ("closeout_ref".to_string(), format!(".octon/state/control/execution/missions/{mission_id}/closeout.yml")),
                ("decision_request_ref".to_string(), format!(".octon/state/control/execution/missions/{mission_id}/decisions/{decision_id}.yml")),
            ]),
            "requires_decision",
            format!("octon decide resolve {decision_id} --mission-id {mission_id} --response close"),
        ));
    }
    write_closeout_state(octon_dir, mission_id, &now, "closed", &[])?;
    set_mission_state(octon_dir, mission_id, "closed")
}

fn list_connectors(octon_dir: &Path, args: ConnectorListCmd) -> Result<MissionReport> {
    let root = repo_root(octon_dir);
    let registry = read_yaml_value(&root.join(CONNECTOR_REGISTRY_REF))?;
    let identities = collect_connector_identities(&root, args.connector_id.as_deref())?;
    println!(
        "{}",
        serde_json::to_string_pretty(&json!({
            "schema_version": "connector-list-v1",
            "non_authority_notice": "This is an operator view over instance/governance connector authority.",
            "connector_filter": args.connector_id,
            "registry_ref": CONNECTOR_REGISTRY_REF,
            "registry": registry,
            "connectors": identities
        }))?
    );
    Ok(report(
        "connector-list",
        "inspected",
        None,
        None,
        BTreeMap::from([(
            "connector_registry_ref".to_string(),
            CONNECTOR_REGISTRY_REF.to_string(),
        )]),
        "inspected",
        "octon connector inspect --connector <id>".to_string(),
    ))
}

fn inspect_connector(octon_dir: &Path, args: ConnectorInspectCmd) -> Result<MissionReport> {
    let root = repo_root(octon_dir);
    let registry = read_yaml_value(&root.join(CONNECTOR_REGISTRY_REF))?;
    let posture = read_yaml_value(&root.join(CONNECTOR_POSTURE_REF))?;
    let admissions = collect_connector_admissions(&root, args.connector_id.as_deref())?;
    let identities = collect_connector_identities(&root, args.connector_id.as_deref())?;
    let operations = collect_connector_operations(
        &root,
        args.connector_id.as_deref(),
        args.operation_id.as_deref(),
    )?;
    println!(
        "{}",
        serde_json::to_string_pretty(&json!({
            "schema_version": "connector-inspection-v1",
            "authority_notice": "Connector policy and admissions are instance/governance authority; generated views are not authority.",
            "connector_filter": args.connector_id,
            "operation_filter": args.operation_id,
            "registry": registry,
            "posture": posture,
            "connector_identities": identities,
            "operations": operations,
            "admissions": admissions
        }))?
    );
    Ok(report(
        "connector-inspect",
        "inspected",
        None,
        None,
        BTreeMap::from([
            (
                "connector_registry_ref".to_string(),
                CONNECTOR_REGISTRY_REF.to_string(),
            ),
            (
                "connector_posture_ref".to_string(),
                CONNECTOR_POSTURE_REF.to_string(),
            ),
        ]),
        "inspected",
        "octon connector admit --stage-only --connector <id> --operation <op>".to_string(),
    ))
}

fn admit_connector(octon_dir: &Path, args: ConnectorAdmitCmd) -> Result<MissionReport> {
    validate_id(&args.connector_id, "connector_id")?;
    validate_id(&args.operation_id, "operation_id")?;
    let requested_modes = [
        args.observe_only,
        args.read_only,
        args.stage_only,
        args.live,
    ]
    .iter()
    .filter(|enabled| **enabled)
    .count();
    if requested_modes > 1 {
        bail!("choose exactly one connector admission mode");
    }
    ensure_connector_contracts(octon_dir, &args.connector_id, &args.operation_id)?;
    if connector_quarantine_active(octon_dir, &args.connector_id, &args.operation_id)? {
        let decision_ref = write_connector_decision_request(
            octon_dir,
            &args.connector_id,
            &args.operation_id,
            "connector_quarantine_reset_required",
            "Connector operation is quarantined; reset requires retained evidence and required operator/quorum approval before admission can change.",
        )?;
        return Ok(report(
            "connector-admit",
            "requires_decision",
            None,
            None,
            BTreeMap::from([("connector_decision_ref".to_string(), decision_ref)]),
            "requires_decision",
            "octon connector decision --connector <id> --operation <op> --type connector_quarantine_reset_required".to_string(),
        ));
    }
    let mode = if args.live {
        "live_effectful"
    } else if args.observe_only {
        "observe_only"
    } else if args.read_only {
        "read_only"
    } else {
        "stage_only"
    };
    if !connector_operation_allows_mode(octon_dir, &args.connector_id, &args.operation_id, mode)? {
        let decision_ref = write_connector_decision_request(
            octon_dir,
            &args.connector_id,
            &args.operation_id,
            "connector_admission_requested",
            &format!(
                "Requested connector admission mode `{mode}` is outside the operation contract allowed_modes; support, capability, and policy treatment must be resolved before the admission can change."
            ),
        )?;
        return Ok(report(
            "connector-admit",
            "requires_decision",
            None,
            None,
            BTreeMap::from([("connector_decision_ref".to_string(), decision_ref)]),
            "requires_decision",
            "octon connector decision --connector <id> --operation <op> --type connector_admission_requested".to_string(),
        ));
    }
    if args.live {
        let decision_ref = write_connector_decision_request(
            octon_dir,
            &args.connector_id,
            &args.operation_id,
            "connector_operation_live_effectful_admission",
            "Live-effectful connector admission requires support-target proof, trust dossier sufficiency, policy approval, run authorization, and effect-token readiness.",
        );
        let refs = BTreeMap::from([("connector_decision_ref".to_string(), decision_ref?)]);
        return Ok(report(
            "connector-admit",
            "requires_decision",
            None,
            None,
            refs,
            "requires_decision",
            "octon connector decision --connector <id> --operation <op>".to_string(),
        ));
    }
    let now = now_rfc3339()?;
    let root = repo_root(octon_dir);
    let previous_digest = connector_recorded_digest(&root, &args.connector_id, &args.operation_id)?;
    let admission_ref = write_connector_admission_record(
        octon_dir,
        &args.connector_id,
        &args.operation_id,
        mode,
        &now,
    )?;
    write_connector_operation_state(
        octon_dir,
        &args.connector_id,
        &args.operation_id,
        mode,
        &now,
    )?;
    refresh_connector_drift_baseline(
        octon_dir,
        &args.connector_id,
        &args.operation_id,
        previous_digest,
        "baseline_refreshed_after_admission",
        &now,
    )?;
    write_connector_evidence_receipt(
        octon_dir,
        &args.connector_id,
        &args.operation_id,
        "admissions",
        mode,
        &admission_ref,
        &now,
    )?;
    write_connector_generated_projection(
        octon_dir,
        &args.connector_id,
        &args.operation_id,
        mode,
        &now,
    )?;
    Ok(report(
        "connector-admit",
        mode,
        None,
        None,
        BTreeMap::from([("connector_admission_ref".to_string(), admission_ref)]),
        mode,
        "octon connector inspect".to_string(),
    ))
}

fn stage_connector(octon_dir: &Path, args: ConnectorOperationCmd) -> Result<MissionReport> {
    admit_connector(
        octon_dir,
        ConnectorAdmitCmd {
            connector_id: args.connector_id,
            operation_id: args.operation_id,
            observe_only: false,
            read_only: false,
            stage_only: true,
            live: false,
        },
    )
}

fn connector_status(octon_dir: &Path, args: ConnectorOperationCmd) -> Result<MissionReport> {
    validate_id(&args.connector_id, "connector_id")?;
    validate_id(&args.operation_id, "operation_id")?;
    let root = repo_root(octon_dir);
    let status_ref = connector_operation_status_ref(&args.connector_id, &args.operation_id);
    let status_path = root.join(&status_ref);
    let admission = read_yaml_value(&root.join(connector_admission_ref(
        &args.connector_id,
        &args.operation_id,
    )))
    .ok();
    let status = read_yaml_value(&status_path).ok();
    println!(
        "{}",
        serde_json::to_string_pretty(&json!({
            "schema_version": "connector-status-view-v1",
            "non_authority_notice": "Status views do not authorize connector execution.",
            "connector_id": args.connector_id,
            "operation_id": args.operation_id,
            "status_ref": status_ref,
            "status": status,
            "admission": admission
        }))?
    );
    Ok(report(
        "connector-status",
        "inspected",
        None,
        None,
        BTreeMap::from([("connector_status_ref".to_string(), status_ref)]),
        "inspected",
        "octon connector validate --connector <id> --operation <op>".to_string(),
    ))
}

fn validate_connector_operation(
    octon_dir: &Path,
    args: ConnectorOperationCmd,
) -> Result<MissionReport> {
    validate_id(&args.connector_id, "connector_id")?;
    validate_id(&args.operation_id, "operation_id")?;
    ensure_connector_contracts(octon_dir, &args.connector_id, &args.operation_id)?;
    let root = repo_root(octon_dir);
    let operation_ref = connector_operation_ref(&args.connector_id, &args.operation_id);
    let operation = read_yaml_value(&root.join(&operation_ref))?;
    let required_packs = operation
        .get("capability_packs_consumed")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default();
    let mut missing_packs = Vec::new();
    for pack in required_packs {
        if let Some(pack_id) = pack.as_str() {
            if !capability_pack_exists(&root, pack_id)? {
                missing_packs.push(pack_id.to_string());
            }
        }
    }
    if !missing_packs.is_empty() {
        bail!(
            "connector operation references unknown capability packs: {}",
            missing_packs.join(", ")
        );
    }
    let now = now_rfc3339()?;
    let validation_ref = format!(
        ".octon/state/evidence/connectors/{}/validation/{}/validation.yml",
        args.connector_id, args.operation_id
    );
    write_yaml(
        &root.join(&validation_ref),
        &json!({
            "schema_version": "connector-validation-receipt-v1",
            "connector_id": args.connector_id,
            "operation_id": args.operation_id,
            "operation_contract_ref": operation_ref,
            "capability_pack_registry_ref": CAPABILITY_PACK_REGISTRY_REF,
            "material_effect_inventory_ref": ".octon/framework/engine/runtime/spec/material-side-effect-inventory.yml",
            "support_target_ref": SUPPORT_TARGET_REF,
            "live_effectful_execution_authorized": false,
            "validated_at": now
        }),
    )?;
    Ok(report(
        "connector-validate",
        "validated",
        None,
        None,
        BTreeMap::from([("connector_validation_ref".to_string(), validation_ref)]),
        "validated",
        "octon connector status --connector <id> --operation <op>".to_string(),
    ))
}

fn quarantine_connector(octon_dir: &Path, args: ConnectorOperationCmd) -> Result<MissionReport> {
    set_connector_safing_state(octon_dir, args, "quarantined", "quarantine")
}

fn retire_connector(octon_dir: &Path, args: ConnectorOperationCmd) -> Result<MissionReport> {
    set_connector_safing_state(octon_dir, args, "retired", "retire")
}

fn connector_dossier(octon_dir: &Path, args: ConnectorOperationCmd) -> Result<MissionReport> {
    validate_id(&args.connector_id, "connector_id")?;
    validate_id(&args.operation_id, "operation_id")?;
    let dossier_ref = connector_dossier_ref(&args.connector_id, &args.operation_id);
    let dossier = read_yaml_value(&repo_root(octon_dir).join(&dossier_ref))?;
    println!("{}", serde_json::to_string_pretty(&dossier)?);
    Ok(report(
        "connector-dossier",
        "inspected",
        None,
        None,
        BTreeMap::from([("connector_dossier_ref".to_string(), dossier_ref)]),
        "inspected",
        "octon connector evidence --connector <id> --operation <op>".to_string(),
    ))
}

fn connector_evidence(octon_dir: &Path, args: ConnectorOperationCmd) -> Result<MissionReport> {
    validate_id(&args.connector_id, "connector_id")?;
    validate_id(&args.operation_id, "operation_id")?;
    let evidence_root = format!(".octon/state/evidence/connectors/{}", args.connector_id);
    let refs = collect_connector_evidence_refs(
        &repo_root(octon_dir).join(&evidence_root),
        &args.operation_id,
    )?;
    println!(
        "{}",
        serde_json::to_string_pretty(&json!({
            "schema_version": "connector-evidence-view-v1",
            "non_authority_notice": "Evidence views summarize retained evidence and do not authorize connector operations.",
            "connector_id": args.connector_id,
            "operation_id": args.operation_id,
            "evidence_root": evidence_root,
            "evidence_refs": refs
        }))?
    );
    Ok(report(
        "connector-evidence",
        "inspected",
        None,
        None,
        BTreeMap::from([("connector_evidence_root".to_string(), evidence_root)]),
        "inspected",
        "octon connector drift --connector <id> --operation <op>".to_string(),
    ))
}

fn connector_drift(octon_dir: &Path, args: ConnectorOperationCmd) -> Result<MissionReport> {
    validate_id(&args.connector_id, "connector_id")?;
    validate_id(&args.operation_id, "operation_id")?;
    ensure_connector_contracts(octon_dir, &args.connector_id, &args.operation_id)?;
    let root = repo_root(octon_dir);
    let now = now_rfc3339()?;
    let digest = connector_posture_digest(&root, &args.connector_id, &args.operation_id)?;
    let drift_ref = connector_drift_ref(&args.connector_id, &args.operation_id);
    let previous_digest = read_yaml_value(&root.join(&drift_ref))
        .ok()
        .and_then(|value| {
            value
                .get("current_digest")
                .and_then(Value::as_str)
                .map(str::to_owned)
        });
    let drift_detected = previous_digest
        .as_deref()
        .map(|previous| previous != digest)
        .unwrap_or(false);
    let route = if drift_detected {
        "quarantine"
    } else {
        "current"
    };
    write_yaml(
        &root.join(&drift_ref),
        &json!({
            "schema_version": "connector-drift-record-v1",
            "connector_id": args.connector_id,
            "operation_id": args.operation_id,
            "checked_at": now,
            "current_digest": digest,
            "previous_digest": previous_digest,
            "drift_detected": drift_detected,
            "route": route,
            "quarantine_required": drift_detected,
            "drift_dimensions": [
              "connector manifest",
              "operation schema",
              "support posture",
              "egress destination",
              "credential class",
              "capability mapping",
              "evidence obligations",
              "rollback posture",
              "allowed mode",
              "failure taxonomy",
              "rate/budget class"
            ],
            "connector_availability_is_authority": false,
            "admission_decision_authorizes_execution": false
        }),
    )?;
    if drift_detected {
        write_connector_operation_state(
            octon_dir,
            &args.connector_id,
            &args.operation_id,
            "quarantined",
            &now,
        )?;
        write_connector_quarantine_control(
            octon_dir,
            &args.connector_id,
            &args.operation_id,
            true,
            "connector drift detected",
            &now,
        )?;
    }
    write_connector_evidence_receipt(
        octon_dir,
        &args.connector_id,
        &args.operation_id,
        "drift",
        route,
        &drift_ref,
        &now,
    )?;
    Ok(report(
        "connector-drift",
        route,
        None,
        None,
        BTreeMap::from([("connector_drift_ref".to_string(), drift_ref)]),
        route,
        "octon connector status --connector <id> --operation <op>".to_string(),
    ))
}

fn connector_decision(octon_dir: &Path, args: ConnectorDecisionCmd) -> Result<MissionReport> {
    validate_id(&args.connector_id, "connector_id")?;
    validate_id(&args.operation_id, "operation_id")?;
    let decision_ref = write_connector_decision_request(
        octon_dir,
        &args.connector_id,
        &args.operation_id,
        &args.decision_type,
        "Connector operation requires operator resolution before any posture widening or material effect.",
    )?;
    Ok(report(
        "connector-decision",
        "requires_decision",
        None,
        None,
        BTreeMap::from([("connector_decision_ref".to_string(), decision_ref)]),
        "requires_decision",
        "octon connector status --connector <id> --operation <op>".to_string(),
    ))
}

fn connector_support_proof(octon_dir: &Path, args: ConnectorOperationCmd) -> Result<MissionReport> {
    validate_id(&args.connector_id, "connector_id")?;
    validate_id(&args.operation_id, "operation_id")?;
    ensure_connector_contracts(octon_dir, &args.connector_id, &args.operation_id)?;
    let proof_ref = connector_support_proof_ref(&args.connector_id, &args.operation_id);
    println!(
        "{}",
        serde_json::to_string_pretty(&json!({
            "schema_version": "connector-support-proof-view-v1",
            "connector_id": args.connector_id,
            "operation_id": args.operation_id,
            "support_proof_map_ref": proof_ref,
            "support_target_ref": SUPPORT_TARGET_REF,
            "support_card_projection_is_authority": false,
            "generated_support_matrix_can_widen_support": false
        }))?
    );
    Ok(report(
        "support-proof-connector",
        "inspected",
        None,
        None,
        BTreeMap::from([("connector_support_proof_ref".to_string(), proof_ref)]),
        "inspected",
        "octon support validate-connector --connector <id> --operation <op>".to_string(),
    ))
}

fn connector_capability_map(
    octon_dir: &Path,
    args: ConnectorOperationCmd,
) -> Result<MissionReport> {
    validate_id(&args.connector_id, "connector_id")?;
    validate_id(&args.operation_id, "operation_id")?;
    let map_ref = connector_capability_map_ref(&args.connector_id, &args.operation_id);
    let map = read_yaml_value(&repo_root(octon_dir).join(&map_ref))?;
    println!("{}", serde_json::to_string_pretty(&map)?);
    Ok(report(
        "capability-map-connector",
        "inspected",
        None,
        None,
        BTreeMap::from([("connector_capability_map_ref".to_string(), map_ref)]),
        "inspected",
        "octon connector validate --connector <id> --operation <op>".to_string(),
    ))
}

fn connector_identity_ref(connector_id: &str) -> String {
    format!(".octon/instance/governance/connectors/{connector_id}/connector.yml")
}

fn connector_operation_ref(connector_id: &str, operation_id: &str) -> String {
    format!(".octon/instance/governance/connectors/{connector_id}/operations/{operation_id}.yml")
}

fn connector_admission_ref(connector_id: &str, operation_id: &str) -> String {
    format!(".octon/instance/governance/connector-admissions/{connector_id}/{operation_id}/admission.yml")
}

fn connector_colocated_admission_ref(connector_id: &str, operation_id: &str) -> String {
    format!(".octon/instance/governance/connectors/{connector_id}/admissions/{operation_id}.yml")
}

fn connector_dossier_ref(connector_id: &str, operation_id: &str) -> String {
    format!(
        ".octon/instance/governance/connectors/{connector_id}/trust-dossiers/{operation_id}/dossier.yml"
    )
}

fn connector_capability_map_ref(connector_id: &str, operation_id: &str) -> String {
    format!(
        ".octon/instance/governance/connectors/{connector_id}/capability-maps/{operation_id}.yml"
    )
}

fn connector_support_proof_ref(connector_id: &str, operation_id: &str) -> String {
    format!(
        ".octon/instance/governance/connectors/{connector_id}/support-proof-maps/{operation_id}.yml"
    )
}

fn connector_operation_status_ref(connector_id: &str, operation_id: &str) -> String {
    format!(".octon/state/control/connectors/{connector_id}/operations/{operation_id}/status.yml")
}

fn connector_admission_state_ref(connector_id: &str, operation_id: &str) -> String {
    format!(
        ".octon/state/control/connectors/{connector_id}/operations/{operation_id}/admission-state.yml"
    )
}

fn connector_quarantine_ref(connector_id: &str, operation_id: &str) -> String {
    format!(
        ".octon/state/control/connectors/{connector_id}/operations/{operation_id}/quarantine.yml"
    )
}

fn connector_drift_ref(connector_id: &str, operation_id: &str) -> String {
    format!(".octon/state/control/connectors/{connector_id}/operations/{operation_id}/drift.yml")
}

fn ensure_connector_contracts(
    octon_dir: &Path,
    connector_id: &str,
    operation_id: &str,
) -> Result<()> {
    let root = repo_root(octon_dir);
    let required = [
        connector_identity_ref(connector_id),
        connector_operation_ref(connector_id, operation_id),
        connector_dossier_ref(connector_id, operation_id),
        connector_capability_map_ref(connector_id, operation_id),
        connector_support_proof_ref(connector_id, operation_id),
        CONNECTOR_ADMISSION_POLICY_REF.to_string(),
        CONNECTOR_CREDENTIAL_POLICY_REF.to_string(),
        CONNECTOR_DATA_BOUNDARY_POLICY_REF.to_string(),
        CONNECTOR_EVIDENCE_PROFILE_POLICY_REF.to_string(),
        NETWORK_EGRESS_POLICY_REF.to_string(),
        EXECUTION_BUDGET_POLICY_REF.to_string(),
        CONNECTOR_REGISTRY_REF.to_string(),
        CONNECTOR_POSTURE_REF.to_string(),
        SUPPORT_TARGET_REF.to_string(),
        CAPABILITY_PACK_REGISTRY_REF.to_string(),
        ".octon/framework/engine/runtime/spec/material-side-effect-inventory.yml".to_string(),
        ".octon/framework/engine/runtime/spec/execution-authorization-v1.md".to_string(),
        ".octon/framework/engine/runtime/spec/authorized-effect-token-v2.schema.json".to_string(),
    ];
    let missing: Vec<_> = required
        .iter()
        .filter(|path| !root.join(path).exists())
        .cloned()
        .collect();
    if !missing.is_empty() {
        bail!(
            "connector admission blocked; missing required connector authority/proof surfaces: {}",
            missing.join(", ")
        );
    }
    let operation =
        read_yaml_value(&root.join(connector_operation_ref(connector_id, operation_id)))?;
    for field in [
        "input_schema_ref",
        "output_schema_ref",
        "side_effect_class",
        "material_effect_class",
        "capability_packs_consumed",
        "credential_class",
        "egress_requirements",
        "replayability",
        "rollback_compensation_posture",
        "evidence_obligations",
        "allowed_modes",
        "timeout_budget_class",
        "support_posture",
        "privacy_data_handling",
        "failure_taxonomy",
    ] {
        if operation.get(field).is_none() {
            bail!(
                "connector admission blocked; operation contract {} is missing required field `{field}`",
                connector_operation_ref(connector_id, operation_id)
            );
        }
    }
    for policy_ref in [
        CONNECTOR_CREDENTIAL_POLICY_REF,
        CONNECTOR_DATA_BOUNDARY_POLICY_REF,
        NETWORK_EGRESS_POLICY_REF,
    ] {
        let policy = read_yaml_value(&root.join(policy_ref))?;
        if policy
            .get("default_route")
            .and_then(Value::as_str)
            .unwrap_or("")
            != "deny"
        {
            bail!("connector admission blocked; policy {policy_ref} must default_route deny");
        }
    }
    Ok(())
}

fn connector_quarantine_active(
    octon_dir: &Path,
    connector_id: &str,
    operation_id: &str,
) -> Result<bool> {
    let path = repo_root(octon_dir).join(connector_quarantine_ref(connector_id, operation_id));
    if !path.is_file() {
        return Ok(false);
    }
    let value = read_yaml_value(&path)?;
    Ok(value
        .get("active")
        .and_then(Value::as_bool)
        .unwrap_or(false)
        || value.get("status").and_then(Value::as_str) == Some("quarantined"))
}

fn connector_operation_allows_mode(
    octon_dir: &Path,
    connector_id: &str,
    operation_id: &str,
    mode: &str,
) -> Result<bool> {
    let operation = read_yaml_value(
        &repo_root(octon_dir).join(connector_operation_ref(connector_id, operation_id)),
    )?;
    let allowed_modes = operation
        .get("allowed_modes")
        .and_then(Value::as_array)
        .ok_or_else(|| anyhow!("connector operation contract is missing allowed_modes"))?;
    Ok(allowed_modes
        .iter()
        .any(|allowed| allowed.as_str() == Some(mode)))
}

fn collect_connector_identities(root: &Path, connector: Option<&str>) -> Result<Vec<Value>> {
    let mut out = Vec::new();
    let base = root.join(".octon/instance/governance/connectors");
    let scan_root = connector
        .map(|id| base.join(id).join("connector.yml"))
        .unwrap_or(base);
    collect_yaml_by_schema(&scan_root, "connector-identity-v1", &mut out)?;
    Ok(out)
}

fn collect_connector_operations(
    root: &Path,
    connector: Option<&str>,
    operation: Option<&str>,
) -> Result<Vec<Value>> {
    let mut out = Vec::new();
    let base = root.join(".octon/instance/governance/connectors");
    let scan_root = match (connector, operation) {
        (Some(connector), Some(operation)) => base
            .join(connector)
            .join("operations")
            .join(format!("{operation}.yml")),
        (Some(connector), None) => base.join(connector).join("operations"),
        (None, _) => base,
    };
    collect_yaml_by_schema(&scan_root, "connector-operation-v1", &mut out)?;
    Ok(out)
}

fn capability_pack_exists(root: &Path, pack_id: &str) -> Result<bool> {
    validate_id(pack_id, "capability_pack_id")?;
    Ok(root
        .join(".octon/instance/governance/capability-packs")
        .join(format!("{pack_id}.yml"))
        .is_file())
}

fn write_connector_admission_record(
    octon_dir: &Path,
    connector_id: &str,
    operation_id: &str,
    mode: &str,
    now: &str,
) -> Result<String> {
    let root = repo_root(octon_dir);
    let operation_ref = connector_operation_ref(connector_id, operation_id);
    let operation = read_yaml_value(&root.join(&operation_ref))?;
    let dossier_ref = connector_dossier_ref(connector_id, operation_id);
    let support_proof_ref = connector_support_proof_ref(connector_id, operation_id);
    let capability_map_ref = connector_capability_map_ref(connector_id, operation_id);
    let admission_ref = connector_admission_ref(connector_id, operation_id);
    let input_schema_ref = required_string_field(&operation, "input_schema_ref")?;
    let output_schema_ref = required_string_field(&operation, "output_schema_ref")?;
    let side_effect_class = required_string_field(&operation, "side_effect_class")?;
    let material_effect_class = required_string_field(&operation, "material_effect_class")?;
    let credential_class = required_string_field(&operation, "credential_class")?;
    let replayability = required_string_field(&operation, "replayability")?;
    let rollback_compensation_posture =
        required_string_field(&operation, "rollback_compensation_posture")?;
    let timeout_budget_class = required_string_field(&operation, "timeout_budget_class")?;
    let support_posture = required_string_field(&operation, "support_posture")?;
    let capability_packs = required_field_value(&operation, "capability_packs_consumed")?;
    let egress_requirements = required_field_value(&operation, "egress_requirements")?;
    let evidence_obligations = required_field_value(&operation, "evidence_obligations")?;
    let record = json!({
        "schema_version": "connector-admission-v1",
        "connector_id": connector_id,
        "operation_id": operation_id,
        "admission_state": mode,
        "admission_mode": mode,
        "live_effects_authorized": false,
        "connector_availability_is_authority": false,
        "admission_authorizes_execution": false,
        "allowed_modes": [mode],
        "operation_contract_ref": operation_ref,
        "connector_dossier_ref": dossier_ref,
        "support_proof_map_ref": support_proof_ref,
        "capability_map_ref": capability_map_ref,
        "input_schema_ref": input_schema_ref,
        "output_schema_ref": output_schema_ref,
        "side_effect_class": side_effect_class,
        "material_effect_class": material_effect_class,
        "capability_packs_consumed": capability_packs,
        "credential_class": credential_class,
        "egress_requirements": egress_requirements,
        "replayability": replayability,
        "rollback_compensation_posture": rollback_compensation_posture,
        "evidence_obligations": evidence_obligations,
        "timeout_budget_class": timeout_budget_class,
        "support_posture": support_posture,
        "policy_ref": CONNECTOR_ADMISSION_POLICY_REF,
        "connector_registry_ref": CONNECTOR_REGISTRY_REF,
        "support_target_ref": SUPPORT_TARGET_REF,
        "capability_pack_registry_ref": CAPABILITY_PACK_REGISTRY_REF,
        "context_pack_inclusion_required": true,
        "authorization_grant_required_for_material_effects": true,
        "effect_token_verification_required_for_material_operations": true,
        "retained_receipts_required": true,
        "broad_effectful_connector_autonomy": "deferred",
        "material_execution_entrypoint": "octon run start --contract <run-contract>",
        "created_at": now,
        "updated_at": now
    });
    write_yaml(&root.join(&admission_ref), &record)?;
    write_yaml(
        &root.join(connector_colocated_admission_ref(
            connector_id,
            operation_id,
        )),
        &record,
    )?;
    Ok(admission_ref)
}

fn required_string_field(value: &Value, key: &str) -> Result<String> {
    value
        .get(key)
        .and_then(Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| {
            anyhow!("connector operation contract is missing required string field `{key}`")
        })
}

fn required_field_value(value: &Value, key: &str) -> Result<Value> {
    value
        .get(key)
        .cloned()
        .ok_or_else(|| anyhow!("connector operation contract is missing required field `{key}`"))
}

fn write_connector_operation_state(
    octon_dir: &Path,
    connector_id: &str,
    operation_id: &str,
    state: &str,
    now: &str,
) -> Result<()> {
    let root = repo_root(octon_dir);
    write_yaml(
        &root
            .join(".octon/state/control/connectors")
            .join(connector_id)
            .join("status.yml"),
        &json!({
            "schema_version": "connector-status-v1",
            "connector_id": connector_id,
            "status": "active",
            "updated_at": now,
            "connector_identity_ref": connector_identity_ref(connector_id),
            "connector_availability_is_authority": false
        }),
    )?;
    write_yaml(
        &root.join(connector_operation_status_ref(connector_id, operation_id)),
        &json!({
            "schema_version": "connector-operation-status-v1",
            "connector_id": connector_id,
            "operation_id": operation_id,
            "status": state,
            "live_effects_authorized": false,
            "operation_contract_ref": connector_operation_ref(connector_id, operation_id),
            "admission_state_ref": connector_admission_state_ref(connector_id, operation_id),
            "updated_at": now
        }),
    )?;
    write_yaml(
        &root.join(connector_admission_state_ref(connector_id, operation_id)),
        &json!({
            "schema_version": "connector-operation-admission-state-v1",
            "connector_id": connector_id,
            "operation_id": operation_id,
            "admission_state": state,
            "live_effects_authorized": false,
            "run_lifecycle_bypass_allowed": false,
            "execution_authorization_bypass_allowed": false,
            "updated_at": now
        }),
    )
}

fn write_connector_quarantine_control(
    octon_dir: &Path,
    connector_id: &str,
    operation_id: &str,
    active: bool,
    reason: &str,
    now: &str,
) -> Result<()> {
    write_yaml(
        &repo_root(octon_dir).join(connector_quarantine_ref(connector_id, operation_id)),
        &json!({
            "schema_version": "connector-quarantine-v1",
            "connector_id": connector_id,
            "operation_id": operation_id,
            "status": if active { "quarantined" } else { "not_quarantined" },
            "active": active,
            "reason": reason,
            "live_effects_authorized": false,
            "reset_requires_evidence": true,
            "reset_requires_human_approval": true,
            "reset_evidence_refs": [],
            "reset_approval_refs": [],
            "created_at": now,
            "updated_at": now
        }),
    )
}

fn set_connector_safing_state(
    octon_dir: &Path,
    args: ConnectorOperationCmd,
    state: &str,
    command: &'static str,
) -> Result<MissionReport> {
    validate_id(&args.connector_id, "connector_id")?;
    validate_id(&args.operation_id, "operation_id")?;
    let root = repo_root(octon_dir);
    let now = now_rfc3339()?;
    let state_ref = if state == "quarantined" {
        connector_quarantine_ref(&args.connector_id, &args.operation_id)
    } else {
        format!(
            ".octon/state/control/connectors/{}/operations/{}/retirement.yml",
            args.connector_id, args.operation_id
        )
    };
    if state == "quarantined" {
        write_connector_quarantine_control(
            octon_dir,
            &args.connector_id,
            &args.operation_id,
            true,
            &format!("operator {command} command"),
            &now,
        )?;
    } else {
        write_yaml(
            &root.join(&state_ref),
            &json!({
                "schema_version": "connector-retirement-v1",
                "connector_id": args.connector_id,
                "operation_id": args.operation_id,
                "status": state,
                "active": false,
                "reason": format!("operator {command} command"),
                "live_effects_authorized": false,
                "created_at": now,
                "updated_at": now
            }),
        )?;
    }
    write_connector_operation_state(
        octon_dir,
        &args.connector_id,
        &args.operation_id,
        state,
        &now,
    )?;
    write_connector_evidence_receipt(
        octon_dir,
        &args.connector_id,
        &args.operation_id,
        command,
        state,
        &state_ref,
        &now,
    )?;
    write_connector_generated_projection(
        octon_dir,
        &args.connector_id,
        &args.operation_id,
        state,
        &now,
    )?;
    Ok(report(
        command,
        state,
        None,
        None,
        BTreeMap::from([("connector_state_ref".to_string(), state_ref)]),
        state,
        "octon connector status --connector <id> --operation <op>".to_string(),
    ))
}

fn write_connector_evidence_receipt(
    octon_dir: &Path,
    connector_id: &str,
    operation_id: &str,
    family: &str,
    outcome: &str,
    subject_ref: &str,
    now: &str,
) -> Result<String> {
    let receipt_ref = format!(
        ".octon/state/evidence/connectors/{connector_id}/{family}/{operation_id}/receipt.yml"
    );
    write_yaml(
        &repo_root(octon_dir).join(&receipt_ref),
        &json!({
            "schema_version": "connector-evidence-receipt-v1",
            "connector_id": connector_id,
            "operation_id": operation_id,
            "family": family,
            "outcome": outcome,
            "subject_ref": subject_ref,
            "retained_evidence": true,
            "generated_projection_substitute": false,
            "connector_evidence_replaces_run_evidence": false,
            "run_evidence_link_required_for_material_operations": true,
            "captured_at": now
        }),
    )?;
    Ok(receipt_ref)
}

fn write_connector_generated_projection(
    octon_dir: &Path,
    connector_id: &str,
    operation_id: &str,
    status: &str,
    now: &str,
) -> Result<()> {
    let root =
        repo_root(octon_dir).join(".octon/generated/cognition/projections/materialized/connectors");
    write_yaml(
        &root.join("status.yml"),
        &json!({
            "schema_version": "connector-generated-status-v1",
            "non_authority_notice": "Generated connector projection only; canonical connector authority is under .octon/instance/governance/connectors and state/control/evidence roots.",
            "freshness_mode": "source_traceable_snapshot",
            "allowed_consumers": ["operators", "docs"],
            "forbidden_consumers": ["runtime_authorization", "connector_admission", "support_widening"],
            "connector_id": connector_id,
            "operation_id": operation_id,
            "status": status,
            "source_control_ref": connector_operation_status_ref(connector_id, operation_id),
            "source_admission_ref": connector_admission_ref(connector_id, operation_id),
            "source_digest_ref": connector_drift_ref(connector_id, operation_id),
            "receipt_refs": [format!(".octon/state/evidence/connectors/{connector_id}/admissions/{operation_id}/receipt.yml")],
            "updated_at": now
        }),
    )?;
    write_yaml(
        &root
            .join("support-cards")
            .join(format!("{connector_id}-{operation_id}.yml")),
        &json!({
            "schema_version": "connector-support-card-projection-v1",
            "non_authority_notice": "Support-card projection cannot widen support or authorize connector execution.",
            "freshness_mode": "source_traceable_snapshot",
            "allowed_consumers": ["operators", "docs"],
            "forbidden_consumers": ["runtime_authorization", "connector_admission", "support_widening"],
            "connector_id": connector_id,
            "operation_id": operation_id,
            "support_proof_map_ref": connector_support_proof_ref(connector_id, operation_id),
            "source_admission_ref": connector_admission_ref(connector_id, operation_id),
            "source_digest_ref": connector_drift_ref(connector_id, operation_id),
            "receipt_refs": [format!(".octon/state/evidence/connectors/{connector_id}/trust-dossiers/{operation_id}/proof-bundle.yml")],
            "generated_support_matrix_can_widen_support": false,
            "updated_at": now
        }),
    )
}

fn write_connector_decision_request(
    octon_dir: &Path,
    connector_id: &str,
    operation_id: &str,
    decision_type: &str,
    question: &str,
) -> Result<String> {
    let now = now_rfc3339()?;
    let decision_id = stable_id(&format!(
        "{connector_id}-{operation_id}-{decision_type}-{now}"
    ));
    let decision_ref =
        format!(".octon/state/control/connectors/{connector_id}/decisions/{decision_id}.yml");
    write_yaml(
        &repo_root(octon_dir).join(&decision_ref),
        &json!({
            "schema_version": "decision-request-v1",
            "decision_request_id": decision_id,
            "decision_id": decision_id,
            "engagement_id": "connector-runtime-v4",
            "decision_type": canonical_connector_decision_type(decision_type),
            "connector_decision_type": decision_type,
            "status": "open",
            "question": question,
            "connector_id": connector_id,
            "operation_id": operation_id,
            "allowed_resolutions": [
                "approval",
                "denial",
                "exception_lease",
                "risk_acceptance",
                "revocation",
                "policy_clarification",
                "support_scope_decision",
                "capability_admission_decision",
                "closure_acceptance"
            ],
            "subject_refs": {
                "connector_identity_ref": connector_identity_ref(connector_id),
                "connector_operation_ref": connector_operation_ref(connector_id, operation_id),
                "connector_admission_ref": connector_admission_ref(connector_id, operation_id),
                "connector_dossier_ref": connector_dossier_ref(connector_id, operation_id)
            },
            "canonical_resolution_targets": {
                "approvals_root": ".octon/state/control/execution/approvals/requests/**",
                "exceptions_root": ".octon/state/control/execution/exceptions/**",
                "revocations_root": ".octon/state/control/execution/revocations/**",
                "support_decisions_root": ".octon/instance/governance/support-target-admissions/**",
                "capability_decisions_root": ".octon/instance/governance/capability-packs/**",
                "connector_admission_root": ".octon/instance/governance/connector-admissions/**"
            },
            "evidence_root": format!(".octon/state/evidence/connectors/{connector_id}/decisions/{decision_id}"),
            "host_comments_labels_chat_are_authority": false,
            "generated_summaries_are_authority": false,
            "decision_request_authorizes_material_execution": false,
            "created_at": now
        }),
    )?;
    write_connector_evidence_receipt(
        octon_dir,
        connector_id,
        operation_id,
        "decisions",
        "requires_decision",
        &decision_ref,
        &now,
    )?;
    Ok(decision_ref)
}

fn canonical_connector_decision_type(connector_decision_type: &str) -> &'static str {
    match connector_decision_type {
        "support_target_widening_requested" => "support_scope_decision",
        "capability_admission_requested" | "connector_operation_live_effectful_admission" => {
            "capability_admission_decision"
        }
        "risk_acceptance_required" | "shared_risk_acceptance" => "risk_acceptance",
        "connector_quarantine_reset_required" => "approval",
        "connector_retirement" => "revocation",
        _ => "approval",
    }
}

fn collect_connector_evidence_refs(root: &Path, operation_id: &str) -> Result<Vec<String>> {
    let mut refs = Vec::new();
    collect_connector_evidence_refs_inner(root, operation_id, &mut refs)?;
    refs.sort();
    Ok(refs)
}

fn collect_connector_evidence_refs_inner(
    root: &Path,
    operation_id: &str,
    out: &mut Vec<String>,
) -> Result<()> {
    if !root.exists() {
        return Ok(());
    }
    if root.is_dir() {
        for entry in fs::read_dir(root)? {
            collect_connector_evidence_refs_inner(&entry?.path(), operation_id, out)?;
        }
    } else if root
        .to_string_lossy()
        .contains(&format!("/{operation_id}/"))
        || root
            .file_name()
            .and_then(|name| name.to_str())
            .map(|name| name.contains(operation_id))
            .unwrap_or(false)
    {
        out.push(root.to_string_lossy().to_string());
    }
    Ok(())
}

fn connector_posture_digest(root: &Path, connector_id: &str, operation_id: &str) -> Result<String> {
    let refs = [
        connector_identity_ref(connector_id),
        connector_operation_ref(connector_id, operation_id),
        connector_admission_ref(connector_id, operation_id),
        connector_dossier_ref(connector_id, operation_id),
        connector_capability_map_ref(connector_id, operation_id),
        connector_support_proof_ref(connector_id, operation_id),
        CONNECTOR_REGISTRY_REF.to_string(),
        CONNECTOR_POSTURE_REF.to_string(),
        CONNECTOR_ADMISSION_POLICY_REF.to_string(),
        CONNECTOR_CREDENTIAL_POLICY_REF.to_string(),
        CONNECTOR_DATA_BOUNDARY_POLICY_REF.to_string(),
        CONNECTOR_EVIDENCE_PROFILE_POLICY_REF.to_string(),
        NETWORK_EGRESS_POLICY_REF.to_string(),
        EXECUTION_BUDGET_POLICY_REF.to_string(),
        SUPPORT_TARGET_REF.to_string(),
        CAPABILITY_PACK_REGISTRY_REF.to_string(),
        ".octon/framework/engine/runtime/spec/material-side-effect-inventory.yml".to_string(),
        ".octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml".to_string(),
    ];
    let mut hasher = Sha256::new();
    for rel in refs {
        let path = root.join(rel);
        if path.exists() {
            hasher.update(fs::read(&path).with_context(|| format!("read {}", path.display()))?);
        }
    }
    Ok(format!("{:x}", hasher.finalize()))
}

fn connector_recorded_digest(
    root: &Path,
    connector_id: &str,
    operation_id: &str,
) -> Result<Option<String>> {
    Ok(
        read_yaml_value(&root.join(connector_drift_ref(connector_id, operation_id)))
            .ok()
            .and_then(|value| {
                value
                    .get("current_digest")
                    .and_then(Value::as_str)
                    .map(str::to_owned)
            }),
    )
}

fn refresh_connector_drift_baseline(
    octon_dir: &Path,
    connector_id: &str,
    operation_id: &str,
    previous_digest: Option<String>,
    route: &str,
    now: &str,
) -> Result<()> {
    let root = repo_root(octon_dir);
    let current_digest = connector_posture_digest(&root, connector_id, operation_id)?;
    write_connector_drift_record(
        octon_dir,
        connector_id,
        operation_id,
        current_digest,
        previous_digest,
        false,
        route,
        false,
        now,
    )
}

fn write_connector_drift_record(
    octon_dir: &Path,
    connector_id: &str,
    operation_id: &str,
    current_digest: String,
    previous_digest: Option<String>,
    drift_detected: bool,
    route: &str,
    quarantine_required: bool,
    now: &str,
) -> Result<()> {
    write_yaml(
        &repo_root(octon_dir).join(connector_drift_ref(connector_id, operation_id)),
        &json!({
            "schema_version": "connector-drift-record-v1",
            "connector_id": connector_id,
            "operation_id": operation_id,
            "checked_at": now,
            "current_digest": current_digest,
            "previous_digest": previous_digest,
            "drift_detected": drift_detected,
            "route": route,
            "quarantine_required": quarantine_required,
            "drift_dimensions": [
              "connector manifest",
              "operation schema",
              "support posture",
              "egress destination",
              "credential class",
              "capability mapping",
              "evidence obligations",
              "rollback posture",
              "allowed mode",
              "failure taxonomy",
              "rate/budget class"
            ],
            "connector_availability_is_authority": false,
            "admission_decision_authorizes_execution": false
        }),
    )
}

fn stable_id(seed: &str) -> String {
    let mut hasher = Sha256::new();
    hasher.update(seed.as_bytes());
    format!(
        "connector-decision-{}",
        &format!("{:x}", hasher.finalize())[..12]
    )
}

fn ensure_required_v1(octon_dir: &Path, engagement_id: &str) -> Result<()> {
    let root = repo_root(octon_dir);
    let engagement_root = root
        .join(".octon/state/control/engagements")
        .join(engagement_id);
    let required = [
        engagement_root.join("engagement.yml"),
        engagement_root.join("work-package.yml"),
        root.join(PROJECT_PROFILE_REF),
        root.join(".octon/framework/engine/runtime/spec/work-package-v1.schema.json"),
        root.join(".octon/framework/engine/runtime/spec/decision-request-v1.schema.json"),
        root.join(".octon/framework/engine/runtime/spec/evidence-profile-v1.schema.json"),
        root.join(".octon/framework/engine/runtime/spec/preflight-evidence-lane-v1.md"),
        root.join(CONNECTOR_POSTURE_REF),
    ];
    let missing: Vec<String> = required
        .iter()
        .filter(|path| !path.exists())
        .map(|path| {
            path_to_repo_ref(octon_dir, path).unwrap_or_else(|_| path.display().to_string())
        })
        .collect();
    if missing.is_empty() {
        Ok(())
    } else {
        bail!(
            "Mission Autonomy Runtime v2 requires v1 Engagement/Profile/Work Package surfaces; missing: {}",
            missing.join(", ")
        )
    }
}

fn ensure_machine_policies(octon_dir: &Path) -> Result<()> {
    for reference in [
        MISSION_CONTINUATION_POLICY_REF,
        AUTONOMY_WINDOW_POLICY_REF,
        CONNECTOR_ADMISSION_POLICY_REF,
        MISSION_CLOSEOUT_POLICY_REF,
        CONNECTOR_REGISTRY_REF,
        CONNECTOR_POSTURE_REF,
    ] {
        let path = repo_root(octon_dir).join(reference);
        if !path.is_file() {
            bail!("required v2 policy or registry is missing: {reference}");
        }
        let value = read_yaml_value(&path)?;
        if value
            .get("schema_version")
            .and_then(Value::as_str)
            .is_none()
        {
            bail!("required v2 policy or registry lacks schema_version: {reference}");
        }
    }
    Ok(())
}

fn write_autonomy_window(
    octon_dir: &Path,
    mission_id: &str,
    engagement_id: &str,
    now: &str,
    state: &str,
) -> Result<()> {
    let mission_root = mission_control_root(octon_dir, mission_id);
    write_yaml(
        &mission_root.join("lease.yml"),
        &json!({
            "schema_version": "mission-control-lease-v1",
            "mission_id": mission_id,
            "engagement_id": engagement_id,
            "work_package_ref": format!(".octon/state/control/engagements/{engagement_id}/work-package.yml"),
            "lease_id": format!("{mission_id}-lease"),
            "state": state,
            "issued_by": "operator://octon-mission-runtime-v2",
            "issued_at": now,
            "expires_at": "2099-01-01T00:00:00Z",
            "continuation_scope": {
                "summary": "Mission Autonomy Runtime v2 bounded continuation scope",
                "allowed_execution_postures": ["interruptible_scheduled", "stage_only"],
                "max_concurrent_runs": 1,
                "allowed_action_classes": ["repo-maintenance", "validation", "documentation"],
                "default_safing_subset": ["observe_only", "stage_only"]
            },
            "revocation_reason": null,
            "last_reviewed_at": now
        }),
    )?;
    write_yaml(
        &mission_root.join("autonomy-window.yml"),
        &json!({
            "schema_version": "autonomy-window-v1",
            "mission_id": mission_id,
            "engagement_id": engagement_id,
            "state": state,
            "mission_charter_ref": format!(".octon/instance/orchestration/missions/{mission_id}/mission.yml"),
            "mission_control_lease_ref": format!(".octon/state/control/execution/missions/{mission_id}/lease.yml"),
            "autonomy_budget_ref": format!(".octon/state/control/execution/missions/{mission_id}/autonomy-budget.yml"),
            "circuit_breakers_ref": format!(".octon/state/control/execution/missions/{mission_id}/circuit-breakers.yml"),
            "allowed_execution_postures": ["interruptible_scheduled", "stage_only"],
            "allowed_action_classes": ["repo-maintenance", "validation", "documentation"],
            "max_concurrent_runs": 1,
            "context_freshness_policy": {
                "project_profile_required": true,
                "work_package_required": true,
                "context_pack_required_per_run": true,
                "stale_posture_route": "pause_or_decision_request"
            },
            "connector_posture": {
                "connector_posture_ref": CONNECTOR_POSTURE_REF,
                "connector_admission_policy_ref": CONNECTOR_ADMISSION_POLICY_REF,
                "live_effectful_broad_connectors": "deferred"
            },
            "stop_conditions": [
                "expired-or-paused-lease",
                "exhausted-budget",
                "tripped-or-latched-breaker",
                "stale-context",
                "support-or-capability-drift",
                "connector-drift",
                "unresolved-blocking-decision-request",
                "progress-stall",
                "closeout-gate-blocked"
            ],
            "review_cadence": {
                "review_required": true,
                "last_reviewed_at": now
            },
            "closeout_rules_ref": MISSION_CLOSEOUT_POLICY_REF,
            "authority_boundary": {
                "autonomy_window_authorizes_execution": false,
                "run_contract_required": true,
                "execution_authorization_required": true
            },
            "created_at": now,
            "updated_at": now
        }),
    )
}

fn write_budget(octon_dir: &Path, mission_id: &str, now: &str, state: &str) -> Result<()> {
    write_yaml(
        &mission_control_root(octon_dir, mission_id).join("autonomy-budget.yml"),
        &json!({
            "schema_version": "autonomy-budget-v1",
            "mission_id": mission_id,
            "state": state,
            "window": "PT24H",
            "counters": {
                "continuation_attempts": 0,
                "validation_failures": 0,
                "authorization_denials": 0,
                "run_failures": 0,
                "breaker_trips": 0,
                "queue_churn": 0
            },
            "threshold_profile_ref": "mission-autonomy-runtime-v2.default",
            "last_state_change_at": now,
            "last_recomputed_at": now,
            "recompute_receipt_ref": "mission-open-initial",
            "applied_mode_adjustments": [],
            "updated_at": now
        }),
    )
}

fn write_breakers(
    octon_dir: &Path,
    mission_id: &str,
    now: &str,
    state: &str,
    reasons: Vec<String>,
) -> Result<()> {
    write_yaml(
        &mission_control_root(octon_dir, mission_id).join("circuit-breakers.yml"),
        &json!({
            "schema_version": "circuit-breaker-v1",
            "mission_id": mission_id,
            "state": state,
            "trip_reasons": reasons,
            "trip_conditions_snapshot": {
                "repeated_validation_failure": false,
                "repeated_authorization_denial": false,
                "repeated_run_failure": false,
                "support_posture_drift": false,
                "connector_posture_drift": false,
                "stale_context": false,
                "rollback_posture_loss": false,
                "evidence_emission_failure": false,
                "unexpected_material_side_effect_attempt": false,
                "budget_exhaustion": false,
                "unresolved_high_priority_decision_request": false
            },
            "applied_actions": [],
            "tripped_at": null,
            "reset_requirements": ["operator-review-before-reset"],
            "reset_ref": null,
            "tripped_breakers": [],
            "last_recomputed_at": now,
            "recompute_receipt_ref": "mission-open-initial",
            "updated_at": now
        }),
    )
}

fn write_queue(octon_dir: &Path, mission_id: &str, engagement_id: &str, now: &str) -> Result<()> {
    write_yaml(
        &mission_control_root(octon_dir, mission_id).join("queue.yml"),
        &json!({
            "schema_version": "mission-queue-v1",
            "mission_id": mission_id,
            "engagement_id": engagement_id,
            "status": "open",
            "selection_policy": {
                "one_active_run_at_a_time": true,
                "skip_blocked_dependencies": true,
                "skip_unresolved_decision_requests": true,
                "risk_ceiling": "ACP-1",
                "progress_gate": "fail_closed_on_repeated_non_progress"
            },
            "action_slices": [
                {
                    "schema_version": "action-slice-v1",
                    "slice_id": format!("{mission_id}-slice-1"),
                    "mission_id": mission_id,
                    "engagement_id": engagement_id,
                    "title": "Continue the v1 Work Package as one bounded governed run candidate",
                    "objective_ref": format!(".octon/state/control/engagements/{engagement_id}/objective/objective-brief.yml"),
                    "work_package_ref": format!(".octon/state/control/engagements/{engagement_id}/work-package.yml"),
                    "status": "pending",
                    "action_class": "repo-maintenance",
                    "scope_ids": ["octon-harness"],
                    "dependencies": [],
                    "risk_materiality": {
                        "predicted_acp": "ACP-1",
                        "materiality": "repo-consequential",
                        "reversibility_class": "reversible"
                    },
                    "predicted_acp": "ACP-1",
                    "reversibility_class": "reversible",
                    "rollback_primitive": "canonical-run-rollback-posture",
                    "safe_interrupt_boundary_class": "task_boundary",
                    "expected_blast_radius": "repo-local",
                    "expected_externality_class": "none-before-run-authorization",
                    "executor_profile": "role-mediated",
                    "approval_required": true,
                    "owner_attestation_required": false,
                    "rationale": "Mission continuation must compile one bounded run-contract candidate without bypassing run lifecycle.",
                    "required_capability_packs": ["repo", "telemetry"],
                    "required_connectors": [],
                    "validation_requirements": ["runtime validators pass or fail closed with evidence"],
                    "rollback_expectations": ["run-level rollback posture retained after run start"],
                    "evidence_profile": "mission_repo_consequential",
                    "decision_request_dependencies": [],
                    "run_contract_candidate_ref": null,
                    "terminal_disposition": null,
                    "created_at": now,
                    "updated_at": now
                }
            ],
            "created_at": now,
            "updated_at": now
        }),
    )
}

fn write_runs_ledger(octon_dir: &Path, mission_id: &str, now: &str) -> Result<()> {
    write_yaml(
        &mission_control_root(octon_dir, mission_id).join("runs.yml"),
        &json!({
            "schema_version": "mission-run-ledger-v1",
            "mission_id": mission_id,
            "role": "mission-level-index-not-run-journal",
            "run_journal_authority_ref": ".octon/state/control/execution/runs/<run-id>/events.ndjson",
            "runs": [],
            "created_at": now,
            "updated_at": now
        }),
    )
}

fn write_closeout_state(
    octon_dir: &Path,
    mission_id: &str,
    now: &str,
    status: &str,
    blockers: &[String],
) -> Result<()> {
    let evaluated = status != "open";
    let gate_clear =
        |blocker: &str| evaluated && blockers.iter().all(|existing| existing != blocker);
    write_yaml(
        &mission_control_root(octon_dir, mission_id).join("closeout.yml"),
        &json!({
            "schema_version": "mission-closeout-v1",
            "mission_id": mission_id,
            "status": status,
            "policy_ref": MISSION_CLOSEOUT_POLICY_REF,
            "all_relevant_runs_terminal": gate_clear("non-terminal-runs-present"),
            "run_level_closeout_complete": gate_clear("run-level-closeout-incomplete"),
            "mission_success_or_failure_criteria_satisfied_or_accepted": gate_clear("mission-criteria-unaccepted"),
            "mission_queue_resolved": gate_clear("mission-queue-not-resolved"),
            "mission_evidence_bundle_complete": gate_clear("mission-evidence-incomplete"),
            "replay_disclosure_status_known": gate_clear("replay-disclosure-status-unknown"),
            "rollback_compensation_disposition_known": gate_clear("rollback-disposition-unknown"),
            "continuity_updated": gate_clear("continuity-not-updated"),
            "no_unresolved_blocking_decision_requests": gate_clear("unresolved-blocking-decision-requests"),
            "blockers": blockers,
            "updated_at": now
        }),
    )
}

fn write_mission_evidence_profile(
    octon_dir: &Path,
    mission_id: &str,
    now: &str,
    profile: &str,
) -> Result<()> {
    write_yaml(
        &mission_control_root(octon_dir, mission_id).join("evidence-profile.yml"),
        &json!({
            "schema_version": "mission-evidence-profile-v1",
            "mission_id": mission_id,
            "selected_profile": profile,
            "allowed_profiles": [
                "mission_observe",
                "mission_repo_consequential",
                "mission_boundary_sensitive_stage_only",
                "mission_connector_limited",
                "mission_closeout_required"
            ],
            "required_evidence": [
                "autonomy-window-snapshots",
                "lease-snapshots",
                "budget-snapshots",
                "breaker-snapshots",
                "mission-queue-snapshots",
                "continuation-decisions",
                "decision-request-trail",
                "connector-posture-trail",
                "mission-run-ledger",
                "rollback-aggregation",
                "mission-level-disclosure",
                "continuity-update",
                "closeout-evidence"
            ],
            "updated_at": now
        }),
    )
}

fn write_mission_evidence_baseline(octon_dir: &Path, mission_id: &str, now: &str) -> Result<()> {
    for (family, status) in [
        ("lease", "opened"),
        ("budget", "opened"),
        ("circuit-breakers", "opened"),
        ("queue", "opened"),
        ("mission-run-ledger", "opened"),
        ("connectors", "stage-only-posture-recorded"),
        ("rollback", "run-level-rollback-required-after-start"),
        ("disclosure", "mission-level-disclosure-pending-closeout"),
        ("continuity", "initial-continuity-written"),
        ("closeout", "open-not-ready"),
    ] {
        write_mission_evidence_snapshot(octon_dir, mission_id, family, status, now)?;
    }
    Ok(())
}

fn evaluate_autonomy_window(
    octon_dir: &Path,
    mission_id: &str,
    blockers: &mut Vec<String>,
) -> Result<()> {
    let mission_root = mission_control_root(octon_dir, mission_id);
    let window = read_yaml_value(&mission_root.join("autonomy-window.yml"))?;
    if window.get("state").and_then(Value::as_str) != Some("active") {
        blockers.push("autonomy-window-not-active".to_string());
    }
    for (field, blocker) in [
        (
            "mission_control_lease_ref",
            "autonomy-window-lease-ref-missing",
        ),
        ("autonomy_budget_ref", "autonomy-window-budget-ref-missing"),
        (
            "circuit_breakers_ref",
            "autonomy-window-breaker-ref-missing",
        ),
        (
            "closeout_rules_ref",
            "autonomy-window-closeout-policy-ref-missing",
        ),
    ] {
        let Some(reference) = window.get(field).and_then(Value::as_str) else {
            blockers.push(blocker.to_string());
            continue;
        };
        if !repo_root(octon_dir).join(reference).exists() {
            blockers.push(format!("{blocker}-target"));
        }
    }
    if window
        .get("max_concurrent_runs")
        .and_then(Value::as_i64)
        .unwrap_or(0)
        != 1
    {
        blockers.push("autonomy-window-max-concurrent-runs-not-one".to_string());
    }
    if !window
        .get("context_freshness_policy")
        .and_then(|policy| policy.get("context_pack_required_per_run"))
        .and_then(Value::as_bool)
        .unwrap_or(false)
    {
        blockers.push("autonomy-window-context-pack-not-required".to_string());
    }
    if window
        .get("authority_boundary")
        .and_then(|v| v.get("autonomy_window_authorizes_execution"))
        .and_then(Value::as_bool)
        .unwrap_or(true)
    {
        blockers.push("autonomy-window-claims-execution-authority".to_string());
    }
    Ok(())
}

fn evaluate_lease(
    octon_dir: &Path,
    mission_id: &str,
    engagement_id: &str,
    blockers: &mut Vec<String>,
) -> Result<()> {
    let lease = read_yaml_value(&mission_control_root(octon_dir, mission_id).join("lease.yml"))?;
    if lease.get("state").and_then(Value::as_str) != Some("active") {
        blockers.push("mission-control-lease-not-active".to_string());
    }
    if lease.get("engagement_id").and_then(Value::as_str) != Some(engagement_id) {
        blockers.push("mission-control-lease-engagement-scope-mismatch".to_string());
    }
    let expected_work_package_ref =
        format!(".octon/state/control/engagements/{engagement_id}/work-package.yml");
    if lease.get("work_package_ref").and_then(Value::as_str)
        != Some(expected_work_package_ref.as_str())
    {
        blockers.push("mission-control-lease-work-package-scope-mismatch".to_string());
    }
    enforce_timestamp_not_expired(
        &lease,
        "expires_at",
        "mission-control-lease-expired",
        blockers,
    )?;
    enforce_recent_timestamp(
        &lease,
        "last_reviewed_at",
        7,
        "mission-control-lease-review-stale",
        blockers,
    )?;
    if lease
        .get("continuation_scope")
        .and_then(|s| s.get("max_concurrent_runs"))
        .and_then(Value::as_i64)
        .unwrap_or(0)
        > 1
    {
        blockers.push("mission-lease-allows-too-many-concurrent-runs".to_string());
    }
    Ok(())
}

fn evaluate_budget(octon_dir: &Path, mission_id: &str, blockers: &mut Vec<String>) -> Result<()> {
    let budget =
        read_yaml_value(&mission_control_root(octon_dir, mission_id).join("autonomy-budget.yml"))?;
    if budget.get("mission_id").and_then(Value::as_str) != Some(mission_id) {
        blockers.push("autonomy-budget-mission-scope-mismatch".to_string());
    }
    match budget
        .get("state")
        .and_then(Value::as_str)
        .unwrap_or("exhausted")
    {
        "healthy" => {}
        "warning" => {
            blockers.push("autonomy-budget-warning-requires-narrowing-or-decision".to_string())
        }
        "exhausted" => blockers.push("autonomy-budget-exhausted".to_string()),
        other => blockers.push(format!("autonomy-budget-invalid-state-{other}")),
    }
    enforce_recent_timestamp(
        &budget,
        "last_recomputed_at",
        1,
        "autonomy-budget-recompute-stale",
        blockers,
    )?;
    Ok(())
}

fn evaluate_breakers(octon_dir: &Path, mission_id: &str, blockers: &mut Vec<String>) -> Result<()> {
    let breakers =
        read_yaml_value(&mission_control_root(octon_dir, mission_id).join("circuit-breakers.yml"))?;
    if breakers.get("mission_id").and_then(Value::as_str) != Some(mission_id) {
        blockers.push("circuit-breaker-mission-scope-mismatch".to_string());
    }
    match breakers
        .get("state")
        .and_then(Value::as_str)
        .unwrap_or("tripped")
    {
        "clear" => {}
        "tripped" => blockers.push("circuit-breaker-tripped".to_string()),
        "latched" => blockers.push("circuit-breaker-latched".to_string()),
        other => blockers.push(format!("circuit-breaker-invalid-state-{other}")),
    }
    enforce_recent_timestamp(
        &breakers,
        "last_recomputed_at",
        1,
        "circuit-breaker-recompute-stale",
        blockers,
    )?;
    Ok(())
}

fn evaluate_context_support_capability(
    octon_dir: &Path,
    engagement_id: &str,
    mission_id: &str,
    blockers: &mut Vec<String>,
) -> Result<()> {
    let root = repo_root(octon_dir);
    for (reference, blocker) in [
        (PROJECT_PROFILE_REF, "project-profile-stale-or-missing"),
        (SUPPORT_TARGET_REF, "support-target-posture-missing"),
        (CAPABILITY_PACK_REGISTRY_REF, "capability-posture-missing"),
        (CONNECTOR_POSTURE_REF, "connector-posture-missing"),
        (CONTEXT_PACK_POLICY_REF, "context-pack-policy-missing"),
    ] {
        if !root.join(reference).exists() {
            blockers.push(blocker.to_string());
        }
    }
    let work_package_path = root
        .join(".octon/state/control/engagements")
        .join(engagement_id)
        .join("work-package.yml");
    if !work_package_path.is_file() {
        blockers.push("work-package-missing".to_string());
    }
    let queue_path = mission_control_root(octon_dir, mission_id).join("queue.yml");
    if !queue_path.is_file() {
        blockers.push("mission-queue-missing".to_string());
    }
    Ok(())
}

fn select_next_slice(
    octon_dir: &Path,
    mission_id: &str,
    blockers: &mut Vec<String>,
) -> Result<Option<String>> {
    let queue_path = mission_control_root(octon_dir, mission_id).join("queue.yml");
    let queue = read_yaml_value(&queue_path)?;
    let mut selected = None;
    if let Some(slices) = queue.get("action_slices").and_then(Value::as_array) {
        for slice in slices {
            let status = slice.get("status").and_then(Value::as_str).unwrap_or("");
            if status != "pending" && status != "ready_for_authorization" {
                continue;
            }
            let unresolved_deps = slice
                .get("decision_request_dependencies")
                .and_then(Value::as_array)
                .map(|items| !items.is_empty())
                .unwrap_or(false);
            if unresolved_deps {
                continue;
            }
            selected = slice
                .get("slice_id")
                .and_then(Value::as_str)
                .map(ToString::to_string);
            break;
        }
    }
    if selected.is_none() {
        blockers.push("no-selectable-action-slice".to_string());
    }
    Ok(selected)
}

fn existing_slice_candidate_ref(
    octon_dir: &Path,
    mission_id: &str,
    slice_id: &str,
) -> Result<Option<String>> {
    let queue = read_yaml_value(&mission_control_root(octon_dir, mission_id).join("queue.yml"))?;
    Ok(queue
        .get("action_slices")
        .and_then(Value::as_array)
        .and_then(|slices| {
            slices.iter().find_map(|slice| {
                if slice.get("slice_id").and_then(Value::as_str) == Some(slice_id) {
                    slice
                        .get("run_contract_candidate_ref")
                        .and_then(Value::as_str)
                        .map(ToString::to_string)
                } else {
                    None
                }
            })
        }))
}

fn compile_next_candidate(
    octon_dir: &Path,
    mission_id: &str,
    engagement_id: &str,
    slice_id: &str,
    now: &str,
) -> Result<String> {
    let run_id = next_mission_run_id(octon_dir, mission_id)?;
    validate_id(&run_id, "run_id")?;
    let candidate_root = mission_control_root(octon_dir, mission_id)
        .join("run-candidates")
        .join(&run_id);
    fs::create_dir_all(&candidate_root)?;
    let candidate_ref = path_to_repo_ref(
        octon_dir,
        &candidate_root.join("run-contract.candidate.yml"),
    )?;
    let decision_index_ref =
        format!(".octon/state/control/execution/missions/{mission_id}/decisions/index.yml");
    write_yaml(
        &candidate_root.join("run-contract.candidate.yml"),
        &json!({
            "schema_version": "run-contract-v3",
            "run_id": run_id,
            "workflow_id": DEFAULT_WORKFLOW_ID,
            "status": "candidate",
            "mission_id": mission_id,
            "requires_mission": true,
            "mission_mode": "mission-continuation",
            "action_slice_id": slice_id,
            "direct_execution_allowed": false,
            "handoff": {
                "entrypoint": "octon run start --contract",
                "bypass_run_start": false,
                "prepare_only_required_for_candidate_submission": true
            },
            "workflow_mode": "role-mediated",
            "objective_refs": {
                "engagement_ref": format!(".octon/state/control/engagements/{engagement_id}/engagement.yml"),
                "project_profile_ref": PROJECT_PROFILE_REF,
                "work_package_ref": format!(".octon/state/control/engagements/{engagement_id}/work-package.yml"),
                "mission_ref": format!(".octon/state/control/execution/missions/{mission_id}/mission.yml"),
                "mission_queue_ref": format!(".octon/state/control/execution/missions/{mission_id}/queue.yml"),
                "action_slice_ref": format!(".octon/state/control/execution/missions/{mission_id}/queue.yml#action_slices/{slice_id}")
            },
            "objective_summary": "Execute one bounded Mission Queue Action Slice through the governed run lifecycle.",
            "scope_in": [
                format!(".octon/state/control/engagements/{engagement_id}/work-package.yml"),
                format!(".octon/state/control/execution/missions/{mission_id}/queue.yml"),
                format!(".octon/state/control/execution/missions/{mission_id}/autonomy-window.yml")
            ],
            "scope_out": [
                format!(".octon/state/evidence/runs/{run_id}"),
                format!(".octon/state/evidence/control/execution/missions/{mission_id}/continuation-decisions")
            ],
            "done_when": ["Run lifecycle reaches a terminal state and mission ledger is updated."],
            "acceptance_criteria": ["Run starts only via octon run start --contract and authorization gates."],
            "materiality": "bounded-consequential",
            "risk_class": "low",
            "reversibility_class": "reversible",
            "requested_capabilities": ["workflow.execute", "evidence.write"],
            "requested_capability_packs": ["repo", "telemetry"],
            "support_target_ref": SUPPORT_TARGET_REF,
            "support_tier": "repo-consequential",
            "connector_posture_ref": CONNECTOR_POSTURE_REF,
            "evidence_profile_ref": format!(".octon/state/control/execution/missions/{mission_id}/evidence-profile.yml"),
            "context_pack_request_ref": format!(".octon/state/control/execution/missions/{mission_id}/context/context-pack-request.yml"),
            "decision_request_set_ref": decision_index_ref,
            "required_evidence": [
                "mission-autonomy-window-snapshot",
                "mission-queue-snapshot",
                "mission-continuation-decision",
                "execution-receipt-after-run-start"
            ],
            "rollback_posture_ref": format!(".octon/state/control/execution/runs/{run_id}/rollback-posture.yml"),
            "stage_attempt_root": format!(".octon/state/control/execution/runs/{run_id}/stage-attempts"),
            "checkpoint_root": format!(".octon/state/control/execution/runs/{run_id}/checkpoints"),
            "continuity_root_ref": format!(".octon/state/continuity/runs/{run_id}/handoff.yml"),
            "run_manifest_ref": format!(".octon/state/control/execution/runs/{run_id}/run-manifest.yml"),
            "runtime_state_ref": format!(".octon/state/control/execution/runs/{run_id}/runtime-state.yml"),
            "run_card_ref": format!(".octon/state/evidence/disclosure/runs/{run_id}/run-card.yml"),
            "created_at": now,
            "updated_at": now
        }),
    )?;
    write_yaml(
        &mission_control_root(octon_dir, mission_id)
            .join("context")
            .join("context-pack-request.yml"),
        &json!({
            "schema_version": "context-pack-request-v1",
            "mission_id": mission_id,
            "run_id": run_id,
            "policy_ref": CONTEXT_PACK_POLICY_REF,
            "status": "request_prepared",
            "receipt_required_before_material_effects": true,
            "source_refs": [
                format!(".octon/state/control/execution/missions/{mission_id}/queue.yml"),
                format!(".octon/state/control/execution/missions/{mission_id}/autonomy-window.yml"),
                format!(".octon/state/control/execution/missions/{mission_id}/runs.yml")
            ],
            "recorded_at": now
        }),
    )?;
    Ok(candidate_ref)
}

fn next_mission_run_id(octon_dir: &Path, mission_id: &str) -> Result<String> {
    let ledger_path = mission_control_root(octon_dir, mission_id).join("runs.yml");
    let mut ordinal = read_yaml_value(&ledger_path)
        .ok()
        .and_then(|ledger| {
            ledger
                .get("runs")
                .and_then(Value::as_array)
                .map(|runs| runs.len() + 1)
        })
        .unwrap_or(1);
    loop {
        let run_id = format!("{mission_id}-run-{ordinal}");
        let candidate_exists = mission_control_root(octon_dir, mission_id)
            .join("run-candidates")
            .join(&run_id)
            .join("run-contract.candidate.yml")
            .exists();
        let canonical_exists = repo_root(octon_dir)
            .join(".octon/state/control/execution/runs")
            .join(&run_id)
            .join("run-contract.yml")
            .exists();
        if !candidate_exists && !canonical_exists {
            return Ok(run_id);
        }
        ordinal += 1;
    }
}

fn ensure_mission_decision(
    octon_dir: &Path,
    mission_id: &str,
    engagement_id: &str,
    suffix: &str,
    decision_type: &str,
    blockers: &[String],
    now: &str,
) -> Result<String> {
    let decision_id = format!("{mission_id}-{suffix}");
    validate_id(&decision_id, "decision_id")?;
    let decision_root = mission_control_root(octon_dir, mission_id).join("decisions");
    let decision_path = decision_root.join(format!("{decision_id}.yml"));
    let decision_ref =
        format!(".octon/state/control/execution/missions/{mission_id}/decisions/{decision_id}.yml");
    if decision_path.is_file() {
        let existing = read_yaml_value(&decision_path)?;
        let status = existing
            .get("status")
            .and_then(Value::as_str)
            .unwrap_or("open");
        update_decision_index(
            octon_dir,
            mission_id,
            &decision_id,
            &decision_ref,
            status,
            now,
        )?;
        return Ok(decision_id);
    }
    let evidence_root = mission_evidence_root(octon_dir, mission_id)
        .join("decision-requests")
        .join(&decision_id);
    fs::create_dir_all(&decision_root)?;
    fs::create_dir_all(&evidence_root)?;
    let allowed_resolutions = allowed_resolutions_for_mission_decision(decision_type);
    write_yaml(
        &decision_path,
        &json!({
            "schema_version": "decision-request-v1",
            "decision_request_id": decision_id,
            "engagement_id": engagement_id,
            "mission_id": mission_id,
            "status": "open",
            "decision_type": canonical_decision_type(decision_type),
            "mission_decision_type": decision_type,
            "mission_aware_scope": [
                "action_slice",
                "run",
                "capability",
                "connector_operation",
                "mission_continuation",
                "mission_lease_extension",
                "mission_closeout"
            ],
            "question": "Resolve mission continuation gate before the Mission Runner may proceed.",
            "allowed_resolutions": allowed_resolutions,
            "subject_refs": {
                "mission_ref": format!(".octon/state/control/execution/missions/{mission_id}/mission.yml"),
                "queue_ref": format!(".octon/state/control/execution/missions/{mission_id}/queue.yml"),
                "autonomy_window_ref": format!(".octon/state/control/execution/missions/{mission_id}/autonomy-window.yml")
            },
            "blocking_reasons": blockers,
            "canonical_resolution_targets": {
                "approval_request_root": ".octon/state/control/execution/approvals/requests",
                "approval_grant_root": ".octon/state/control/execution/approvals/grants",
                "exception_lease_root": ".octon/state/control/execution/exceptions/leases",
                "revocation_root": ".octon/state/control/execution/revocations",
                "connector_admission_root": ".octon/instance/governance/connector-admissions"
            },
            "evidence_root": format!(".octon/state/evidence/control/execution/missions/{mission_id}/decision-requests/{decision_id}"),
            "created_at": now,
            "updated_at": now
        }),
    )?;
    update_decision_index(
        octon_dir,
        mission_id,
        &decision_id,
        &decision_ref,
        "open",
        now,
    )?;
    write_yaml(
        &evidence_root.join("request.yml"),
        &json!({
            "schema_version": "mission-decision-request-evidence-v1",
            "decision_request_id": decision_id,
            "mission_id": mission_id,
            "decision_request_ref": decision_ref,
            "blocking_reasons": blockers,
            "recorded_at": now
        }),
    )?;
    Ok(decision_id)
}

fn mission_decision_status(
    octon_dir: &Path,
    mission_id: &str,
    decision_id: &str,
) -> Result<String> {
    let path = mission_control_root(octon_dir, mission_id)
        .join("decisions")
        .join(format!("{decision_id}.yml"));
    Ok(read_yaml_value(&path)?
        .get("status")
        .and_then(Value::as_str)
        .unwrap_or("open")
        .to_string())
}

fn canonical_decision_type(mission_decision_type: &str) -> &'static str {
    match mission_decision_type {
        "approval_required" => "approval",
        "risk_acceptance_required" => "risk_acceptance",
        "support_widening_requested" => "support_scope_decision",
        "capability_admission_requested" | "connector_admission_requested" => {
            "capability_admission_decision"
        }
        "rollback_gap_detected"
        | "validation_gap_detected"
        | "budget_warning"
        | "breaker_reset_required"
        | "mission-continuation-blocked"
        | "mission_lease_extension" => "policy_clarification",
        "mission_scope_change" => "mission_scope_decision",
        "mission_closeout_acceptance" => "closure_acceptance",
        _ => "policy_clarification",
    }
}

fn allowed_resolutions_for_mission_decision(mission_decision_type: &str) -> Vec<&'static str> {
    match mission_decision_type {
        "mission_closeout_acceptance" => vec!["closure_acceptance", "denial", "risk_acceptance"],
        "mission_lease_extension" => vec!["approval", "denial", "exception_lease", "revocation"],
        "risk_acceptance_required" => vec!["risk_acceptance", "denial", "policy_clarification"],
        "support_widening_requested" => {
            vec!["support_scope_decision", "denial", "policy_clarification"]
        }
        "capability_admission_requested" => {
            vec![
                "capability_admission_decision",
                "denial",
                "policy_clarification",
            ]
        }
        "connector_admission_requested" => {
            vec![
                "capability_admission_decision",
                "denial",
                "policy_clarification",
            ]
        }
        "mission_scope_change" => vec!["mission_scope_decision", "denial", "policy_clarification"],
        _ => vec!["approval", "denial", "policy_clarification", "revocation"],
    }
}

fn update_decision_index(
    octon_dir: &Path,
    mission_id: &str,
    decision_id: &str,
    decision_ref: &str,
    status: &str,
    now: &str,
) -> Result<()> {
    let index_path = mission_control_root(octon_dir, mission_id)
        .join("decisions")
        .join("index.yml");
    let mut requests = Vec::new();
    if index_path.is_file() {
        let value = read_yaml_value(&index_path)?;
        if let Some(existing) = value.get("decision_requests").and_then(Value::as_array) {
            requests = existing.clone();
        }
    }
    if !requests
        .iter()
        .any(|item| item.get("decision_request_id").and_then(Value::as_str) == Some(decision_id))
    {
        requests.push(json!({
            "decision_request_id": decision_id,
            "decision_request_ref": decision_ref,
            "status": status,
            "required_before": "mission-continuation"
        }));
    } else {
        for item in &mut requests {
            if item.get("decision_request_id").and_then(Value::as_str) == Some(decision_id) {
                if let Some(object) = item.as_object_mut() {
                    object.insert("status".to_string(), json!(status));
                    object.insert("updated_at".to_string(), json!(now));
                }
            }
        }
    }
    write_yaml(
        &index_path,
        &json!({
            "schema_version": "mission-decision-request-set-v1",
            "mission_id": mission_id,
            "decision_requests": requests,
            "canonical_low_level_roots": {
                "approvals": ".octon/state/control/execution/approvals/**",
                "exceptions": ".octon/state/control/execution/exceptions/**",
                "revocations": ".octon/state/control/execution/revocations/**"
            },
            "updated_at": now
        }),
    )
}

fn write_continuation_decision(
    octon_dir: &Path,
    mission_id: &str,
    engagement_id: &str,
    slice_id: Option<&str>,
    candidate_ref: Option<&str>,
    decision: &str,
    blockers: &[String],
    decision_request_id: Option<&str>,
    now: &str,
) -> Result<String> {
    let decisions_root = mission_control_root(octon_dir, mission_id).join("continuation-decisions");
    fs::create_dir_all(&decisions_root)?;
    let id = format!(
        "{mission_id}-continuation-{}",
        sha256_short(&format!("{now}{decision}{:?}", slice_id))
    );
    let decision_ref = format!(
        ".octon/state/control/execution/missions/{mission_id}/continuation-decisions/{id}.yml"
    );
    write_yaml(
        &decisions_root.join(format!("{id}.yml")),
        &json!({
            "schema_version": "mission-continuation-decision-v1",
            "continuation_decision_id": id,
            "mission_id": mission_id,
            "engagement_id": engagement_id,
            "decision": decision,
            "action_slice_id": slice_id,
            "run_contract_candidate_ref": candidate_ref,
            "run_outcome": "not_started",
            "validation_result": "not_run",
            "budget_state_ref": format!(".octon/state/control/execution/missions/{mission_id}/autonomy-budget.yml"),
            "breaker_state_ref": format!(".octon/state/control/execution/missions/{mission_id}/circuit-breakers.yml"),
            "lease_state_ref": format!(".octon/state/control/execution/missions/{mission_id}/lease.yml"),
            "context_freshness": "context-pack-request-prepared",
            "support_posture_ref": SUPPORT_TARGET_REF,
            "capability_posture_ref": CAPABILITY_PACK_REGISTRY_REF,
            "connector_posture_ref": CONNECTOR_POSTURE_REF,
            "unresolved_decision_request_id": decision_request_id,
            "mission_success_failure_criteria_ref": format!(".octon/instance/orchestration/missions/{mission_id}/mission.yml"),
            "queue_state_ref": format!(".octon/state/control/execution/missions/{mission_id}/queue.yml"),
            "rollback_posture": "run-level-rollback-required-after-start",
            "evidence_completeness": "mission-decision-retained",
            "blockers": blockers,
            "authorization_boundary": {
                "continuation_decision_authorizes_execution": false,
                "run_contract_required": true,
                "execution_authorization_required": true
            },
            "created_at": now
        }),
    )?;
    write_yaml(
        &mission_evidence_root(octon_dir, mission_id)
            .join("continuation-decisions")
            .join(format!("{id}.yml")),
        &json!({
            "schema_version": "mission-continuation-decision-evidence-v1",
            "mission_id": mission_id,
            "continuation_decision_ref": decision_ref,
            "decision": decision,
            "blockers": blockers,
            "recorded_at": now
        }),
    )?;
    Ok(decision_ref)
}

fn update_slice_status(
    octon_dir: &Path,
    mission_id: &str,
    slice_id: &str,
    status: &str,
    candidate_ref: Option<&str>,
    now: &str,
) -> Result<()> {
    let queue_path = mission_control_root(octon_dir, mission_id).join("queue.yml");
    let mut queue = read_yaml_object(&queue_path)?;
    if let Some(slices) = queue.get_mut("action_slices").and_then(Value::as_array_mut) {
        for slice in slices {
            if slice.get("slice_id").and_then(Value::as_str) == Some(slice_id) {
                if let Some(object) = slice.as_object_mut() {
                    object.insert("status".to_string(), json!(status));
                    if let Some(candidate_ref) = candidate_ref {
                        object.insert(
                            "run_contract_candidate_ref".to_string(),
                            json!(candidate_ref),
                        );
                    }
                    object.insert("updated_at".to_string(), json!(now));
                }
            }
        }
    }
    upsert(&mut queue, "updated_at", json!(now));
    write_yaml(&queue_path, &Value::Object(queue))
}

fn update_runs_ledger_candidate(
    octon_dir: &Path,
    mission_id: &str,
    slice_id: &str,
    candidate_ref: &str,
    now: &str,
) -> Result<()> {
    let path = mission_control_root(octon_dir, mission_id).join("runs.yml");
    let mut ledger = read_yaml_object(&path)?;
    let runs_value = ledger
        .entry("runs".to_string())
        .or_insert_with(|| Value::Array(Vec::new()));
    if let Some(runs) = runs_value.as_array_mut() {
        if !runs.iter().any(|run| {
            run.get("run_contract_candidate_ref")
                .and_then(Value::as_str)
                == Some(candidate_ref)
        }) {
            let run_id = candidate_ref
                .split("/run-candidates/")
                .nth(1)
                .and_then(|suffix| suffix.split('/').next())
                .unwrap_or("unknown-run")
                .to_string();
            runs.push(json!({
                "run_id": run_id,
                "action_slice_id": slice_id,
                "run_contract_candidate_ref": candidate_ref,
                "canonical_run_contract_ref": null,
                "run_status": "candidate",
                "run_closeout_state": "not_started",
                "evidence_completeness": "pending-run-start",
                "rollback_disposition": "pending-run-start",
                "replay_readiness": "pending-run-start",
                "disclosure_readiness": "pending-run-start",
                "continuity_update_refs": [],
                "journal_authority_ref": format!(".octon/state/control/execution/runs/{run_id}/events.ndjson")
            }));
        }
    }
    upsert(&mut ledger, "updated_at", json!(now));
    write_yaml(&path, &Value::Object(ledger))
}

fn update_runs_ledger_canonical(
    octon_dir: &Path,
    mission_id: &str,
    candidate_ref: &str,
    run_id: &str,
    canonical_ref: &str,
    now: &str,
) -> Result<()> {
    let path = mission_control_root(octon_dir, mission_id).join("runs.yml");
    let mut ledger = read_yaml_object(&path)?;
    if let Some(runs) = ledger.get_mut("runs").and_then(Value::as_array_mut) {
        for run in runs {
            let row_candidate_ref = run
                .get("run_contract_candidate_ref")
                .and_then(Value::as_str);
            let row_run_id = run.get("run_id").and_then(Value::as_str);
            if row_candidate_ref == Some(candidate_ref) && row_run_id == Some(run_id) {
                if let Some(object) = run.as_object_mut() {
                    object.insert(
                        "canonical_run_contract_ref".to_string(),
                        json!(canonical_ref),
                    );
                    object.insert(
                        "run_status".to_string(),
                        json!("canonical_contract_prepared"),
                    );
                    object.insert("run_closeout_state".to_string(), json!("not_started"));
                }
            }
        }
    }
    upsert(&mut ledger, "updated_at", json!(now));
    write_yaml(&path, &Value::Object(ledger))
}

fn resolve_mission_decision(
    octon_dir: &Path,
    mission_id: &str,
    decision_id: &str,
    response: &str,
) -> Result<MissionReport> {
    let now = now_rfc3339()?;
    let decision_path = mission_control_root(octon_dir, mission_id)
        .join("decisions")
        .join(format!("{decision_id}.yml"));
    let mut decision = read_yaml_object(&decision_path)?;
    let engagement_id = decision
        .get("engagement_id")
        .and_then(Value::as_str)
        .unwrap_or("")
        .to_string();
    let allowed = decision
        .get("allowed_resolutions")
        .and_then(Value::as_array)
        .ok_or_else(|| anyhow!("Decision Request lacks allowed_resolutions"))?;
    if !allowed.iter().any(|item| item.as_str() == Some(response)) {
        bail!("response `{response}` is not allowed for Decision Request {decision_id}");
    }
    let status = match response {
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
        _ => bail!("unsupported Decision Request response: {response}"),
    };
    let canonical_refs = write_mission_decision_resolution_refs(
        octon_dir,
        mission_id,
        &engagement_id,
        decision_id,
        response,
        &now,
    )?;
    upsert(&mut decision, "status", json!(status));
    upsert(
        &mut decision,
        "resolution",
        json!({
            "response": response,
            "canonical_refs": canonical_refs,
            "recorded_at": now
        }),
    );
    upsert(&mut decision, "updated_at", json!(now));
    write_yaml(&decision_path, &Value::Object(decision))?;
    update_decision_index(
        octon_dir,
        mission_id,
        decision_id,
        &format!(
            ".octon/state/control/execution/missions/{mission_id}/decisions/{decision_id}.yml"
        ),
        status,
        &now,
    )?;
    let resolution_ref = format!(".octon/state/evidence/control/execution/missions/{mission_id}/decision-requests/{decision_id}/resolution.yml");
    write_yaml(
        &repo_root(octon_dir).join(&resolution_ref),
        &json!({
            "schema_version": "mission-decision-request-resolution-v1",
            "mission_id": mission_id,
            "decision_request_id": decision_id,
            "response": response,
            "canonical_refs": canonical_refs,
            "material_execution_authorized": false,
            "continuation_decision_authorized": false,
            "notes": "Resolution unblocks mission control state only; run execution remains under run start and execution authorization.",
            "recorded_at": now
        }),
    )?;
    Ok(report(
        "decision-resolve",
        status,
        Some(engagement_id),
        Some(mission_id.to_string()),
        BTreeMap::from([
            ("decision_request_ref".to_string(), format!(".octon/state/control/execution/missions/{mission_id}/decisions/{decision_id}.yml")),
            ("decision_resolution_ref".to_string(), resolution_ref),
        ]),
        status,
        format!("octon mission status --mission-id {mission_id}"),
    ))
}

fn resolve_connector_decision(
    octon_dir: &Path,
    connector_id: &str,
    decision_path: &Path,
    decision_id: &str,
    response: &str,
) -> Result<MissionReport> {
    let now = now_rfc3339()?;
    let mut decision = read_yaml_object(decision_path)?;
    let allowed = decision
        .get("allowed_resolutions")
        .and_then(Value::as_array)
        .ok_or_else(|| anyhow!("Connector Decision Request lacks allowed_resolutions"))?;
    if !allowed.iter().any(|item| item.as_str() == Some(response)) {
        bail!("response `{response}` is not allowed for connector Decision Request {decision_id}");
    }
    let status = match response {
        "approval"
        | "exception_lease"
        | "risk_acceptance"
        | "policy_clarification"
        | "support_scope_decision"
        | "capability_admission_decision"
        | "closure_acceptance" => "resolved",
        "denial" => "denied",
        "revocation" => "revoked",
        _ => bail!("unsupported connector Decision Request response: {response}"),
    };
    let operation_id = decision
        .get("operation_id")
        .and_then(Value::as_str)
        .unwrap_or("unknown")
        .to_string();
    let canonical_refs = write_connector_decision_resolution_refs(
        octon_dir,
        connector_id,
        &operation_id,
        decision_id,
        response,
        &now,
    )?;
    upsert(&mut decision, "status", json!(status));
    upsert(
        &mut decision,
        "resolution",
        json!({
            "response": response,
            "canonical_refs": canonical_refs,
            "recorded_at": now,
            "connector_decision_authorizes_material_execution": false
        }),
    );
    upsert(&mut decision, "updated_at", json!(now));
    write_yaml(decision_path, &Value::Object(decision))?;
    let resolution_ref = format!(
        ".octon/state/evidence/connectors/{connector_id}/decisions/{decision_id}/resolution.yml"
    );
    write_yaml(
        &repo_root(octon_dir).join(&resolution_ref),
        &json!({
            "schema_version": "connector-decision-request-resolution-v1",
            "connector_id": connector_id,
            "operation_id": operation_id,
            "decision_request_id": decision_id,
            "response": response,
            "canonical_refs": canonical_refs,
            "connector_admission_authorized": false,
            "material_execution_authorized": false,
            "notes": "Resolution satisfies one human-control gate only; connector execution still requires run contract, context pack, execution authorization, and authorized-effect token verification.",
            "recorded_at": now
        }),
    )?;
    Ok(report(
        "decision-resolve",
        status,
        None,
        None,
        BTreeMap::from([
            (
                "decision_request_ref".to_string(),
                path_to_repo_ref(octon_dir, decision_path)
                    .unwrap_or_else(|_| decision_path.display().to_string()),
            ),
            ("decision_resolution_ref".to_string(), resolution_ref),
        ]),
        status,
        format!("octon connector status --connector {connector_id} --operation {operation_id}"),
    ))
}

fn write_connector_decision_resolution_refs(
    octon_dir: &Path,
    connector_id: &str,
    operation_id: &str,
    decision_id: &str,
    response: &str,
    now: &str,
) -> Result<BTreeMap<String, String>> {
    let root = repo_root(octon_dir);
    let mut refs = BTreeMap::new();
    match response {
        "approval" | "support_scope_decision" | "capability_admission_decision" => {
            let approval_ref =
                format!(".octon/state/control/execution/approvals/requests/{decision_id}.yml");
            write_yaml(
                &root.join(&approval_ref),
                &json!({
                    "schema_version": "execution-approval-request-v1",
                    "request_id": decision_id,
                    "source_decision_request_id": decision_id,
                    "subject": "connector-operation-gate",
                    "connector_id": connector_id,
                    "operation_id": operation_id,
                    "response": response,
                    "approval_authorizes_execution": false,
                    "material_execution_still_requires_run_authorization": true,
                    "created_at": now
                }),
            )?;
            refs.insert("approval_request_ref".to_string(), approval_ref);
        }
        "exception_lease" | "risk_acceptance" => {
            let lease_ref =
                format!(".octon/state/control/execution/exceptions/leases/lease-{decision_id}.yml");
            write_yaml(
                &root.join(&lease_ref),
                &json!({
                    "schema_version": "exception-lease-v1",
                    "lease_id": format!("lease-{decision_id}"),
                    "source_decision_request_id": decision_id,
                    "subject": "connector-operation-gate",
                    "connector_id": connector_id,
                    "operation_id": operation_id,
                    "response": response,
                    "exception_authorizes_execution": false,
                    "material_execution_still_requires_run_authorization": true,
                    "issued_at": now
                }),
            )?;
            refs.insert("exception_lease_ref".to_string(), lease_ref);
        }
        "revocation" | "denial" => {
            let revocation_ref =
                format!(".octon/state/control/execution/revocations/revoke-{decision_id}.yml");
            write_yaml(
                &root.join(&revocation_ref),
                &json!({
                    "schema_version": "revocation-v1",
                    "revocation_id": format!("revoke-{decision_id}"),
                    "source_decision_request_id": decision_id,
                    "subject": "connector-operation-gate",
                    "connector_id": connector_id,
                    "operation_id": operation_id,
                    "response": response,
                    "live_connector_effects_revoked": true,
                    "recorded_at": now
                }),
            )?;
            refs.insert("revocation_ref".to_string(), revocation_ref);
        }
        "policy_clarification" | "closure_acceptance" => {
            refs.insert(
                "connector_decision_resolution_ref".to_string(),
                format!(
                    ".octon/state/evidence/connectors/{connector_id}/decisions/{decision_id}/resolution.yml"
                ),
            );
        }
        _ => {}
    }
    Ok(refs)
}

fn write_mission_decision_resolution_refs(
    octon_dir: &Path,
    mission_id: &str,
    engagement_id: &str,
    decision_id: &str,
    response: &str,
    now: &str,
) -> Result<Value> {
    let root = repo_root(octon_dir);
    let mut refs = Map::new();
    match response {
        "approval" => {
            let request_ref =
                format!(".octon/state/control/execution/approvals/requests/{decision_id}.yml");
            let mission_control_ref = format!(
                ".octon/state/control/execution/mission-decisions/{mission_id}/{decision_id}/approval.yml"
            );
            write_yaml(
                &root.join(&request_ref),
                &json!({
                    "schema_version": "authority-approval-request-v1",
                    "request_id": decision_id,
                    "mission_id": mission_id,
                    "engagement_id": engagement_id,
                    "status": "mission-control-recorded",
                    "action_type": "mission-continuation-control-unblock",
                    "material_execution_authorized": false,
                    "created_at": now,
                    "updated_at": now
                }),
            )?;
            write_yaml(
                &root.join(&mission_control_ref),
                &json!({
                    "schema_version": "mission-control-approval-record-v1",
                    "request_id": decision_id,
                    "mission_id": mission_id,
                    "engagement_id": engagement_id,
                    "state": "recorded",
                    "material_execution_authorized": false,
                    "approval_grant_emitted": false,
                    "notes": "Mission-control approval records do not create active execution approval grants.",
                    "recorded_at": now
                }),
            )?;
            refs.insert("approval_request_ref".to_string(), json!(request_ref));
            refs.insert(
                "mission_control_approval_ref".to_string(),
                json!(mission_control_ref),
            );
        }
        "revocation" => {
            let revocation_ref =
                format!(".octon/state/control/execution/revocations/revoke-{decision_id}.yml");
            write_yaml(
                &root.join(&revocation_ref),
                &json!({
                    "schema_version": "authority-revocation-v1",
                    "revocation_id": format!("revoke-{decision_id}"),
                    "mission_id": mission_id,
                    "source_decision_request_id": decision_id,
                    "state": "active",
                    "created_at": now,
                    "updated_at": now
                }),
            )?;
            refs.insert("revocation_ref".to_string(), json!(revocation_ref));
        }
        "exception_lease" => {
            let lease_ref =
                format!(".octon/state/control/execution/exceptions/leases/lease-{decision_id}.yml");
            write_yaml(
                &root.join(&lease_ref),
                &json!({
                    "schema_version": "authority-exception-lease-v1",
                    "lease_id": format!("lease-{decision_id}"),
                    "mission_id": mission_id,
                    "source_decision_request_id": decision_id,
                    "state": "staged",
                    "material_effects_authorized": false,
                    "created_at": now,
                    "updated_at": now
                }),
            )?;
            refs.insert("exception_lease_ref".to_string(), json!(lease_ref));
        }
        _ => {
            refs.insert(
                "mission_decision_record_ref".to_string(),
                json!(format!(
                    ".octon/state/evidence/control/execution/missions/{mission_id}/decision-requests/{decision_id}/resolution.yml"
                )),
            );
        }
    }
    Ok(Value::Object(refs))
}

fn closeout_blockers(octon_dir: &Path, mission_id: &str) -> Result<Vec<String>> {
    let mut blockers = Vec::new();
    let queue = read_yaml_value(&mission_control_root(octon_dir, mission_id).join("queue.yml"))?;
    if queue
        .get("action_slices")
        .and_then(Value::as_array)
        .map(|slices| {
            slices.iter().any(|slice| {
                !matches!(
                    slice.get("status").and_then(Value::as_str).unwrap_or(""),
                    "done" | "skipped" | "denied"
                )
            })
        })
        .unwrap_or(true)
    {
        blockers.push("mission-queue-not-resolved".to_string());
    }
    let decisions = mission_control_root(octon_dir, mission_id).join("decisions");
    if has_open_decision(&decisions)? {
        blockers.push("unresolved-blocking-decision-requests".to_string());
    }
    let runs = read_yaml_value(&mission_control_root(octon_dir, mission_id).join("runs.yml"))?;
    let run_items = runs
        .get("runs")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default();
    if run_items.iter().any(|run| {
        !matches!(
            run.get("run_status").and_then(Value::as_str).unwrap_or(""),
            "succeeded" | "failed" | "closed" | "denied"
        )
    }) {
        blockers.push("non-terminal-runs-present".to_string());
    }
    if run_items.iter().any(|run| {
        !matches!(
            run.get("run_closeout_state")
                .and_then(Value::as_str)
                .unwrap_or(""),
            "complete" | "closed"
        )
    }) {
        blockers.push("run-level-closeout-incomplete".to_string());
    }
    if run_items.iter().any(|run| {
        run.get("replay_readiness").and_then(Value::as_str) != Some("ready")
            || run.get("disclosure_readiness").and_then(Value::as_str) != Some("ready")
    }) {
        blockers.push("replay-disclosure-status-unknown".to_string());
    }
    if run_items.iter().any(|run| {
        !matches!(
            run.get("rollback_disposition")
                .and_then(Value::as_str)
                .unwrap_or(""),
            "complete" | "not_required" | "known"
        )
    }) {
        blockers.push("rollback-disposition-unknown".to_string());
    }
    if !missing_mission_evidence_requirements(octon_dir, mission_id)?.is_empty() {
        blockers.push("mission-evidence-incomplete".to_string());
    }
    if !mission_continuity_root(octon_dir, mission_id)
        .join("summary.yml")
        .is_file()
    {
        blockers.push("continuity-not-updated".to_string());
    }
    Ok(blockers)
}

fn missing_mission_evidence_requirements(
    octon_dir: &Path,
    mission_id: &str,
) -> Result<Vec<String>> {
    let profile =
        read_yaml_value(&mission_control_root(octon_dir, mission_id).join("evidence-profile.yml"))?;
    let evidence_root = mission_evidence_root(octon_dir, mission_id);
    let mut missing = Vec::new();
    if let Some(requirements) = profile.get("required_evidence").and_then(Value::as_array) {
        for requirement in requirements.iter().filter_map(Value::as_str) {
            let family = mission_evidence_family(requirement);
            let family_root = evidence_root.join(family);
            let has_receipt = family_root.is_dir()
                && fs::read_dir(&family_root)
                    .map(|entries| {
                        entries.filter_map(|entry| entry.ok()).any(|entry| {
                            entry
                                .path()
                                .extension()
                                .and_then(|extension| extension.to_str())
                                == Some("yml")
                        })
                    })
                    .unwrap_or(false);
            if !has_receipt {
                missing.push(requirement.to_string());
            }
        }
    }
    Ok(missing)
}

fn mission_evidence_family(requirement: &str) -> &str {
    match requirement {
        "autonomy-window-snapshots" => "autonomy-window",
        "lease-snapshots" => "lease",
        "budget-snapshots" => "budget",
        "breaker-snapshots" => "circuit-breakers",
        "mission-queue-snapshots" => "queue",
        "continuation-decisions" => "continuation-decisions",
        "decision-request-trail" => "decision-requests",
        "connector-posture-trail" => "connectors",
        "mission-run-ledger" => "mission-run-ledger",
        "rollback-aggregation" => "rollback",
        "mission-level-disclosure" => "disclosure",
        "continuity-update" => "continuity",
        "closeout-evidence" => "closeout",
        _ => requirement,
    }
}

fn write_mission_evidence_snapshot(
    octon_dir: &Path,
    mission_id: &str,
    family: &str,
    status: &str,
    now: &str,
) -> Result<()> {
    write_yaml(
        &mission_evidence_root(octon_dir, mission_id)
            .join(family)
            .join(format!(
                "{}.yml",
                sha256_short(&format!("{family}{status}{now}"))
            )),
        &json!({
            "schema_version": "mission-evidence-snapshot-v1",
            "mission_id": mission_id,
            "family": family,
            "status": status,
            "retained_proof": true,
            "recorded_at": now
        }),
    )
}

fn write_mission_continuity(
    octon_dir: &Path,
    mission_id: &str,
    engagement_id: &str,
    now: &str,
    status: &str,
) -> Result<()> {
    let root = mission_continuity_root(octon_dir, mission_id);
    write_yaml(
        &root.join("summary.yml"),
        &json!({
            "schema_version": "mission-continuity-summary-v1",
            "mission_id": mission_id,
            "engagement_id": engagement_id,
            "status": status,
            "authority_status": "resumable-context-not-authority",
            "updated_at": now
        }),
    )?;
    write_yaml(
        &root.join("next-actions.yml"),
        &json!({
            "schema_version": "mission-continuity-next-actions-v1",
            "mission_id": mission_id,
            "actions": [format!("octon mission continue --mission-id {mission_id}")],
            "authority_status": "resumable-context-not-authority",
            "updated_at": now
        }),
    )?;
    write_yaml(
        &root.join("open-threads.yml"),
        &json!({
            "schema_version": "mission-continuity-open-threads-v1",
            "mission_id": mission_id,
            "threads": [],
            "authority_status": "resumable-context-not-authority",
            "updated_at": now
        }),
    )?;
    write_yaml(
        &root.join("learned-constraints.yml"),
        &json!({
            "schema_version": "mission-continuity-learned-constraints-v1",
            "mission_id": mission_id,
            "constraints": [
                "mission-queue-does-not-replace-run-lifecycle",
                "continuation-decisions-do-not-authorize-execution",
                "mission-run-ledger-does-not-replace-run-journals"
            ],
            "authority_status": "resumable-context-not-authority",
            "updated_at": now
        }),
    )
}

fn write_generated_mission_projection(
    octon_dir: &Path,
    mission_id: &str,
    engagement_id: &str,
    status: &str,
    now: &str,
) -> Result<()> {
    write_yaml(
        &repo_root(octon_dir)
            .join(".octon/generated/cognition/projections/materialized/missions")
            .join(format!("{mission_id}.yml")),
        &json!({
            "schema_version": "mission-operator-read-model-v1",
            "non_authority_notice": "Generated projection only; mission control truth lives under .octon/state/control/execution/missions.",
            "mission_id": mission_id,
            "engagement_id": engagement_id,
            "status": status,
            "updated_at": now
        }),
    )
}

fn collect_decisions(root: &Path, out: &mut Vec<Value>) -> Result<()> {
    if !root.exists() {
        return Ok(());
    }
    if root.is_file() {
        return Ok(());
    }
    for entry in fs::read_dir(root).with_context(|| format!("read {}", root.display()))? {
        let entry = entry?;
        let path = entry.path();
        if path.is_dir() {
            collect_decisions(&path, out)?;
        } else if path.file_name().and_then(|name| name.to_str()) != Some("index.yml")
            && path.extension().and_then(|ext| ext.to_str()) == Some("yml")
        {
            if let Ok(value) = read_yaml_value(&path) {
                if value.get("schema_version").and_then(Value::as_str)
                    == Some("decision-request-v1")
                {
                    out.push(value);
                }
            }
        }
    }
    Ok(())
}

fn collect_connector_admissions(root: &Path, connector: Option<&str>) -> Result<Vec<Value>> {
    let mut out = Vec::new();
    let base = root.join(".octon/instance/governance/connector-admissions");
    let scan_root = connector.map(|id| base.join(id)).unwrap_or(base);
    collect_yaml_by_schema(&scan_root, "connector-admission-v1", &mut out)?;
    Ok(out)
}

fn collect_yaml_by_schema(root: &Path, schema: &str, out: &mut Vec<Value>) -> Result<()> {
    if !root.exists() {
        return Ok(());
    }
    if root.is_dir() {
        for entry in fs::read_dir(root)? {
            collect_yaml_by_schema(&entry?.path(), schema, out)?;
        }
    } else if root.extension().and_then(|ext| ext.to_str()) == Some("yml") {
        if let Ok(value) = read_yaml_value(root) {
            if value.get("schema_version").and_then(Value::as_str) == Some(schema) {
                out.push(value);
            }
        }
    }
    Ok(())
}

fn has_open_decision(root: &Path) -> Result<bool> {
    let mut decisions = Vec::new();
    collect_decisions(root, &mut decisions)?;
    Ok(decisions.iter().any(|decision| {
        matches!(
            decision
                .get("status")
                .and_then(Value::as_str)
                .unwrap_or("open"),
            "open" | "requires_decision"
        )
    }))
}

fn find_single_active_engagement(octon_dir: &Path) -> Result<String> {
    let engagements_root = repo_root(octon_dir).join(".octon/state/control/engagements");
    let mut ids = Vec::new();
    if engagements_root.is_dir() {
        for entry in fs::read_dir(&engagements_root)? {
            let entry = entry?;
            if entry.path().join("engagement.yml").is_file() {
                if let Some(id) = entry.file_name().to_str() {
                    ids.push(id.to_string());
                }
            }
        }
    }
    match ids.len() {
        1 => Ok(ids.remove(0)),
        0 => bail!("no active Engagement found; run `octon mission open --engagement <id>`"),
        _ => bail!("multiple Engagements found; pass --engagement-id explicitly"),
    }
}

fn resolve_engagement_active_mission(octon_dir: &Path, engagement_id: &str) -> Result<String> {
    let path = repo_root(octon_dir)
        .join(".octon/state/control/engagements")
        .join(engagement_id)
        .join("active-mission.yml");
    let value = read_yaml_value(&path)?;
    Ok(yaml_string(&value, "mission_id")?.to_string())
}

fn find_mission_for_decision(octon_dir: &Path, decision_id: &str) -> Result<String> {
    let root = repo_root(octon_dir).join(".octon/state/control/execution/missions");
    if root.is_dir() {
        for entry in fs::read_dir(&root)? {
            let entry = entry?;
            if entry
                .path()
                .join("decisions")
                .join(format!("{decision_id}.yml"))
                .is_file()
            {
                return Ok(entry.file_name().to_string_lossy().to_string());
            }
        }
    }
    bail!("mission-aware Decision Request not found: {decision_id}")
}

fn find_connector_for_decision(octon_dir: &Path, decision_id: &str) -> Result<(String, PathBuf)> {
    let root = repo_root(octon_dir).join(".octon/state/control/connectors");
    if root.is_dir() {
        for entry in fs::read_dir(&root)? {
            let entry = entry?;
            let path = entry
                .path()
                .join("decisions")
                .join(format!("{decision_id}.yml"));
            if path.is_file() {
                return Ok((entry.file_name().to_string_lossy().to_string(), path));
            }
        }
    }
    bail!("connector Decision Request not found: {decision_id}")
}

fn repo_root(octon_dir: &Path) -> PathBuf {
    octon_dir.parent().unwrap_or(octon_dir).to_path_buf()
}

fn mission_control_root(octon_dir: &Path, mission_id: &str) -> PathBuf {
    repo_root(octon_dir)
        .join(".octon/state/control/execution/missions")
        .join(mission_id)
}

fn mission_evidence_root(octon_dir: &Path, mission_id: &str) -> PathBuf {
    repo_root(octon_dir)
        .join(".octon/state/evidence/control/execution/missions")
        .join(mission_id)
}

fn mission_continuity_root(octon_dir: &Path, mission_id: &str) -> PathBuf {
    repo_root(octon_dir)
        .join(".octon/state/continuity/repo/missions")
        .join(mission_id)
}

fn write_yaml<T: Serialize + ?Sized>(path: &Path, value: &T) -> Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent).with_context(|| format!("create {}", parent.display()))?;
    }
    fs::write(path, serde_yaml::to_string(value)?)
        .with_context(|| format!("write {}", path.display()))?;
    Ok(())
}

fn read_yaml_value(path: &Path) -> Result<Value> {
    let text = fs::read_to_string(path).with_context(|| format!("read {}", path.display()))?;
    Ok(serde_yaml::from_str(&text).with_context(|| format!("parse {}", path.display()))?)
}

fn read_yaml_object(path: &Path) -> Result<Map<String, Value>> {
    read_yaml_value(path)?
        .as_object()
        .cloned()
        .ok_or_else(|| anyhow!("{} must be a mapping", path.display()))
}

fn yaml_string<'a>(value: &'a Value, key: &str) -> Result<&'a str> {
    value
        .get(key)
        .and_then(Value::as_str)
        .ok_or_else(|| anyhow!("missing string field `{key}`"))
}

fn enforce_timestamp_not_expired(
    value: &Value,
    key: &str,
    blocker: &str,
    blockers: &mut Vec<String>,
) -> Result<()> {
    let Some(raw) = value.get(key).and_then(Value::as_str) else {
        blockers.push(format!("{blocker}-missing"));
        return Ok(());
    };
    let Ok(parsed) = parse_rfc3339(raw) else {
        blockers.push(format!("{blocker}-invalid"));
        return Ok(());
    };
    if parsed < OffsetDateTime::now_utc() {
        blockers.push(blocker.to_string());
    }
    Ok(())
}

fn enforce_recent_timestamp(
    value: &Value,
    key: &str,
    max_age_days: i64,
    blocker: &str,
    blockers: &mut Vec<String>,
) -> Result<()> {
    let Some(raw) = value.get(key).and_then(Value::as_str) else {
        blockers.push(format!("{blocker}-missing"));
        return Ok(());
    };
    let Ok(parsed) = parse_rfc3339(raw) else {
        blockers.push(format!("{blocker}-invalid"));
        return Ok(());
    };
    if OffsetDateTime::now_utc() - parsed > Duration::days(max_age_days) {
        blockers.push(blocker.to_string());
    }
    Ok(())
}

fn parse_rfc3339(value: &str) -> Result<OffsetDateTime, time::error::Parse> {
    OffsetDateTime::parse(value, &Rfc3339)
}

fn upsert(object: &mut Map<String, Value>, key: &str, value: Value) {
    object.insert(key.to_string(), value);
}

fn report(
    command: &'static str,
    status: &str,
    engagement_id: Option<String>,
    mission_id: Option<String>,
    refs: BTreeMap<String, String>,
    outcome: &str,
    next_command: String,
) -> MissionReport {
    MissionReport {
        command,
        status: status.to_string(),
        engagement_id,
        mission_id,
        refs,
        outcome: outcome.to_string(),
        next_command,
    }
}

fn print_report(report: &MissionReport) -> Result<()> {
    println!("{}", serde_json::to_string_pretty(report)?);
    Ok(())
}

fn validate_id(value: &str, field: &str) -> Result<()> {
    if value.is_empty()
        || !value
            .bytes()
            .all(|byte| byte.is_ascii_lowercase() || byte.is_ascii_digit() || byte == b'-')
        || value.starts_with('-')
        || value.ends_with('-')
        || value.contains("--")
    {
        bail!("{field} must use canonical lowercase hyphen-separated id syntax");
    }
    Ok(())
}

fn sha256_short(value: &str) -> String {
    let digest = Sha256::digest(value.as_bytes());
    hex::encode(&digest[..8])
}
