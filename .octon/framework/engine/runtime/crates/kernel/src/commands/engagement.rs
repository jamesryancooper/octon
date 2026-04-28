use super::{
    path_to_repo_ref, ArmCmd, DecisionResolveCmd, PlanCmd, ProfileCmd, RunDescriptor, StartCmd,
    StatusCmd,
};
use anyhow::{anyhow, bail, Context, Result};
use octon_authority_engine::now_rfc3339;
use serde::Serialize;
use serde_json::{json, Map, Value};
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

const DEFAULT_INTENT: &str = "Prepare a governed Octon Work Package.";
const DEFAULT_WORKFLOW_ID: &str = "agent-led-happy-path";
const SUPPORT_TARGET_REF: &str = ".octon/instance/governance/support-targets.yml";
const GOVERNANCE_EXCLUSIONS_REF: &str = ".octon/instance/governance/exclusions/action-classes.yml";
const COMPILER_POLICY_REF: &str =
    ".octon/instance/governance/policies/engagement-work-package-compiler.yml";
const EVIDENCE_PROFILES_POLICY_REF: &str =
    ".octon/instance/governance/policies/evidence-profiles.yml";
const PREFLIGHT_EVIDENCE_LANE_POLICY_REF: &str =
    ".octon/instance/governance/policies/preflight-evidence-lane.yml";
const CONNECTOR_POSTURE_REF: &str = ".octon/instance/governance/connectors/posture.yml";
const CONTEXT_PACKING_POLICY_REF: &str = ".octon/instance/governance/policies/context-packing.yml";
const WORKSPACE_CHARTER_REF: &str = ".octon/instance/charter/workspace.md";
const WORKSPACE_CHARTER_MACHINE_REF: &str = ".octon/instance/charter/workspace.yml";
const PROJECT_PROFILE_REF: &str = ".octon/instance/locality/project-profile.yml";

#[derive(Debug, Clone, Serialize)]
struct CommandReport {
    command: &'static str,
    engagement_id: String,
    status: String,
    refs: BTreeMap<String, String>,
    next_command: String,
}

pub(super) fn cmd_start(args: StartCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let report = start_engagement(
        &octon_dir,
        args.engagement_id,
        args.intent,
        args.prepare_only,
    )?;
    print_report(&report)
}

pub(super) fn cmd_profile(args: ProfileCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let report = profile_engagement(&octon_dir, &args.engagement_id)?;
    print_report(&report)
}

pub(super) fn cmd_plan(args: PlanCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let report = plan_engagement(&octon_dir, &args.engagement_id)?;
    print_report(&report)
}

pub(super) fn cmd_arm(args: ArmCmd) -> Result<()> {
    if !args.prepare_only {
        bail!("engagement compiler v1 only supports `octon arm --prepare-only`");
    }
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let report = arm_engagement(&octon_dir, &args.engagement_id, &args.workflow_id)?;
    print_report(&report)
}

pub(super) fn cmd_status(args: StatusCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let report = status_engagement(&octon_dir, &args.engagement_id)?;
    print_report(&report)
}

pub(super) fn cmd_decide(args: DecisionResolveCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let engagement_id = args
        .engagement_id
        .ok_or_else(|| anyhow!("--engagement-id is required for Engagement Decision Requests"))?;
    let report = decide_engagement(
        &octon_dir,
        &engagement_id,
        &args.decision_id,
        args.response.as_resolution(),
    )?;
    print_report(&report)
}

pub(super) fn is_run_candidate_contract(path: &Path) -> bool {
    path.file_name().and_then(|name| name.to_str()) == Some("run-contract.candidate.yml")
        && path
            .components()
            .any(|component| component.as_os_str() == "run-candidates")
}

pub(super) fn materialize_run_candidate_for_start(
    octon_dir: &Path,
    candidate_path: &Path,
) -> Result<RunDescriptor> {
    if !is_run_candidate_contract(candidate_path) {
        bail!(
            "run candidate contract must be named run-contract.candidate.yml under run-candidates: {}",
            candidate_path.display()
        );
    }
    let candidate = read_yaml_value(candidate_path)?;
    let run_id = yaml_string(&candidate, "run_id")?.to_string();
    validate_id(&run_id, "run_id")?;
    let workflow_id = yaml_optional_string(&candidate, "workflow_id")
        .unwrap_or_else(|| DEFAULT_WORKFLOW_ID.to_string());
    validate_workflow_known(octon_dir, &workflow_id)?;
    ensure_candidate_decisions_resolved(octon_dir, &candidate)?;

    let repo_root = repo_root(octon_dir);
    let run_root = repo_root
        .join(".octon/state/control/execution/runs")
        .join(&run_id);
    let canonical_contract = run_root.join("run-contract.yml");
    if canonical_contract.exists() {
        bail!(
            "run candidate already has a canonical run contract at {}; use that contract for start/resume",
            canonical_contract.display()
        );
    }
    fs::create_dir_all(&run_root).with_context(|| format!("create {}", run_root.display()))?;

    let mut canonical = candidate
        .as_object()
        .cloned()
        .ok_or_else(|| anyhow!("run contract candidate must be a mapping"))?;
    canonical.insert(
        "candidate_source_ref".to_string(),
        json!(path_to_repo_ref(octon_dir, candidate_path)?),
    );
    canonical.insert("status".to_string(), json!("candidate-submitted"));
    canonical.insert("updated_at".to_string(), json!(now_rfc3339()?));
    write_yaml(&canonical_contract, &Value::Object(canonical))?;

    let run_manifest_ref = format!(".octon/state/control/execution/runs/{run_id}/run-manifest.yml");
    let runtime_state_ref =
        format!(".octon/state/control/execution/runs/{run_id}/runtime-state.yml");
    let continuity_ref = format!(".octon/state/continuity/runs/{run_id}/handoff.yml");
    let replay_manifest_ref = format!(".octon/state/evidence/runs/{run_id}/replay/manifest.yml");
    let run_card_ref = format!(".octon/state/evidence/disclosure/runs/{run_id}/run-card.yml");
    let last_checkpoint_ref =
        format!(".octon/state/control/execution/runs/{run_id}/checkpoints/bound.yml");
    let mission_id = yaml_optional_string(&candidate, "mission_id")
        .filter(|value| !value.trim().is_empty() && value != "null");

    Ok(RunDescriptor {
        run_id,
        workflow_id,
        run_contract_ref: path_to_repo_ref(octon_dir, &canonical_contract)?,
        run_manifest_ref,
        runtime_state_ref,
        continuity_ref,
        replay_manifest_ref,
        run_card_ref,
        last_checkpoint_ref,
        mission_id,
    })
}

fn start_engagement(
    octon_dir: &Path,
    explicit_engagement_id: Option<String>,
    intent: Option<String>,
    prepare_only: bool,
) -> Result<CommandReport> {
    if !prepare_only {
        bail!("engagement compiler v1 only supports prepare-only start");
    }
    let engagement_id = explicit_engagement_id.unwrap_or_else(|| new_id("engagement"));
    validate_id(&engagement_id, "engagement_id")?;
    let now = now_rfc3339()?;
    let intent_text = intent
        .map(|value| value.trim().to_string())
        .filter(|value| !value.is_empty())
        .unwrap_or_else(|| DEFAULT_INTENT.to_string());
    let control_root = engagement_control_root(octon_dir, &engagement_id);
    let evidence_root = engagement_evidence_root(octon_dir, &engagement_id);
    let continuity_ref = format!(".octon/state/continuity/engagements/{engagement_id}/handoff.yml");
    let continuity_path = repo_root(octon_dir).join(&continuity_ref);
    let orientation_root_ref =
        format!(".octon/state/evidence/orientation/{engagement_id}-orientation");
    let project_profile_evidence_root_ref =
        format!(".octon/state/evidence/project-profiles/{engagement_id}-project-profile");
    let work_package_evidence_root_ref =
        format!(".octon/state/evidence/engagements/{engagement_id}/work-packages");
    let decision_evidence_root_ref = ".octon/state/evidence/decisions".to_string();
    let run_readiness_root_ref =
        format!(".octon/state/evidence/engagements/{engagement_id}/run-contract-readiness");
    if control_root.exists() || evidence_root.exists() {
        bail!("engagement id already exists: {engagement_id}");
    }
    fs::create_dir_all(&control_root)?;
    fs::create_dir_all(evidence_root.join("preflight"))?;
    fs::create_dir_all(continuity_path.parent().unwrap_or(&continuity_path))?;

    let engagement_ref = repo_ref(octon_dir, &control_root.join("engagement.yml"))?;
    let seed_intent_ref = repo_ref(octon_dir, &control_root.join("seed-intent.yml"))?;
    let preflight_ref = repo_ref(
        octon_dir,
        &evidence_root
            .join("preflight")
            .join("adoption-classification.yml"),
    )?;
    let projection_path = repo_root(octon_dir)
        .join(".octon/generated/cognition/projections/materialized/engagements")
        .join(format!("{engagement_id}.yml"));
    let projection_ref = repo_ref(octon_dir, &projection_path)?;

    write_yaml(
        &control_root.join("seed-intent.yml"),
        &json!({
            "schema_version": "engagement-seed-intent-v1",
            "engagement_id": engagement_id,
            "intent": intent_text,
            "source": "octon start",
            "authority_class": "operator-supplied-seed",
            "created_at": now,
        }),
    )?;
    write_yaml(
        &evidence_root
            .join("preflight")
            .join("adoption-classification.yml"),
        &json!({
            "schema_version": "engagement-adoption-classification-v1",
            "engagement_id": engagement_id,
            "classification": "octon-managed-repository",
            "lane_policy_ref": PREFLIGHT_EVIDENCE_LANE_POLICY_REF,
            "material_effects": "none",
            "project_code_mutation": false,
            "external_side_effects": false,
            "generated_effective_publication": false,
            "recorded_at": now,
        }),
    )?;
    write_yaml(
        &control_root.join("engagement.yml"),
        &json!({
            "schema_version": "engagement-v1",
            "engagement_id": engagement_id,
            "repo_root": repo_root(octon_dir).display().to_string(),
            "status": "draft",
            "stage": "start-engagement",
            "prepare_only": true,
            "seed_intent": intent_text,
            "seed_intent_ref": seed_intent_ref,
            "adoption_classification_ref": preflight_ref,
            "objective_brief_schema_ref": ".octon/framework/engine/runtime/spec/engagement-objective-brief-v1.schema.json",
            "objective_control_root": null,
            "objective_brief_ref": null,
            "project_profile_ref": null,
            "work_package_ref": null,
            "run_contract_candidate_ref": null,
            "canonical_run_contract_ref": null,
            "decision_request_refs": [],
            "authority_binding": authority_refs(),
            "evidence_roots": {
                "engagement": format!(".octon/state/evidence/engagements/{engagement_id}"),
                "preflight": format!(".octon/state/evidence/engagements/{engagement_id}/preflight"),
                "orientation": orientation_root_ref,
                "project_profile_source_facts": format!("{project_profile_evidence_root_ref}/source-facts"),
                "work_package_compilation": work_package_evidence_root_ref,
                "decisions": decision_evidence_root_ref,
                "run_contract_readiness": run_readiness_root_ref,
                "objective": format!(".octon/state/evidence/engagements/{engagement_id}/objective")
            },
            "continuity_ref": continuity_ref,
            "generated_projection_policy": {
                "projections_optional": true,
                "authority_status": "non_authoritative"
            },
            "closeout_state": "open",
            "refs": {
                "seed_intent_ref": seed_intent_ref,
                "preflight_evidence_ref": preflight_ref,
                "operator_projection_ref": projection_ref,
                "continuity_ref": continuity_ref,
            },
            "outcome": "stage_only",
            "next_action": format!("octon profile --engagement-id {engagement_id}"),
            "created_at": now,
            "updated_at": now,
        }),
    )?;
    write_yaml(
        &continuity_path,
        &json!({
            "schema_version": "engagement-continuity-v1",
            "engagement_id": engagement_id,
            "stage": "start-engagement",
            "resume_command": format!("octon profile --engagement-id {engagement_id}"),
            "authority_status": "resumption-context-not-runtime-authority",
            "recorded_at": now,
        }),
    )?;
    write_projection(
        &projection_path,
        &engagement_id,
        "draft",
        &BTreeMap::from([
            ("engagement_ref".to_string(), engagement_ref.clone()),
            ("preflight_evidence_ref".to_string(), preflight_ref.clone()),
        ]),
    )?;

    Ok(report(
        "start",
        &engagement_id,
        "draft",
        BTreeMap::from([
            ("engagement_ref".to_string(), engagement_ref),
            ("seed_intent_ref".to_string(), seed_intent_ref),
            ("preflight_evidence_ref".to_string(), preflight_ref),
            ("operator_projection_ref".to_string(), projection_ref),
        ]),
        format!("octon profile --engagement-id {engagement_id}"),
    ))
}

fn profile_engagement(octon_dir: &Path, engagement_id: &str) -> Result<CommandReport> {
    validate_id(engagement_id, "engagement_id")?;
    let control_root = engagement_control_root(octon_dir, engagement_id);
    let engagement_path = control_root.join("engagement.yml");
    let mut engagement = read_yaml_object(&engagement_path)?;
    let now = now_rfc3339()?;
    let orientation_id = format!("{engagement_id}-orientation");
    let profile_id = format!("{engagement_id}-project-profile");
    let orientation_root = repo_root(octon_dir)
        .join(".octon/state/evidence/orientation")
        .join(&orientation_id);
    let profile_evidence_root = repo_root(octon_dir)
        .join(".octon/state/evidence/project-profiles")
        .join(&profile_id);
    let source_facts_root = profile_evidence_root.join("source-facts");
    fs::create_dir_all(&orientation_root)?;
    fs::create_dir_all(&source_facts_root)?;
    fs::create_dir_all(repo_root(octon_dir).join(".octon/instance/locality"))?;

    let scan_ref = repo_ref(octon_dir, &orientation_root.join("repo-scan.yml"))?;
    let source_fact_evidence_root_ref = repo_ref(octon_dir, &source_facts_root)?;
    let profile_evidence_ref = repo_ref(octon_dir, &source_facts_root.join("source-facts.yml"))?;
    let project_profile_path = repo_root(octon_dir).join(PROJECT_PROFILE_REF);
    let project_profile_ref = PROJECT_PROFILE_REF.to_string();
    let source_digests = source_digests(octon_dir)?;
    let toolchains = detected_toolchains(octon_dir);

    write_yaml(
        &orientation_root.join("repo-scan.yml"),
        &json!({
            "schema_version": "orientation-scan-evidence-v1",
            "orientation_id": orientation_id,
            "engagement_id": engagement_id,
            "lane_policy_ref": PREFLIGHT_EVIDENCE_LANE_POLICY_REF,
            "detected_project_type": "octon-harness",
            "detected_toolchains": toolchains,
            "source_digests": source_digests,
            "forbidden_actions_observed": [],
            "recorded_at": now,
        }),
    )?;
    write_yaml(
        &source_facts_root.join("source-facts.yml"),
        &json!({
            "schema_version": "project-profile-source-facts-evidence-v1",
            "profile_id": profile_id,
            "engagement_id": engagement_id,
            "orientation_evidence_ref": scan_ref,
            "source_digests": source_digests,
            "fact_classes": [
                "repo-structure",
                "language-toolchain-discovery",
                "build-test-lint-typecheck-discovery",
                "governance-relevant-paths"
            ],
            "recorded_at": now,
        }),
    )?;
    write_yaml(
        &project_profile_path,
        &json!({
            "schema_version": "project-profile-v1",
            "profile_id": profile_id,
            "status": "active",
            "repo_root": repo_root(octon_dir).display().to_string(),
            "profile_scope": "repo-local",
            "evidence_refs": {
                "orientation_evidence_ref": scan_ref,
                "source_fact_evidence_ref": profile_evidence_ref
            },
            "source_fact_evidence_root": source_fact_evidence_root_ref,
            "repo_structure": {
                "project_type": "octon-harness",
                "primary_octon_root": ".octon"
            },
            "language_toolchain_discovery": toolchains,
            "build_test_lint_typecheck_discovery": {
                "runtime_cli": "cargo test -p octon_kernel",
                "runtime_workspace": "cargo test -p octon_kernel -p octon_authority_engine"
            },
            "ci_release_posture": {
                "release_state": "pre-1.0",
                "change_profile": "atomic"
            },
            "dependencies": [],
            "ownership_hints": [
                "Octon governance",
                "runtime"
            ],
            "workspace_charter_ref": WORKSPACE_CHARTER_REF,
            "workspace_machine_charter_ref": WORKSPACE_CHARTER_MACHINE_REF,
            "protected_zones": [
                ".octon/framework/constitution/**",
                ".octon/instance/governance/**",
                ".octon/state/control/execution/**"
            ],
            "governance_relevant_paths": [
                ".octon/framework/engine/runtime/**",
                ".octon/instance/governance/**",
                ".octon/state/control/**",
                ".octon/state/evidence/**"
            ],
            "validation_strategy": [
                "cargo test -p octon_kernel",
                "bash .octon/framework/assurance/runtime/_ops/scripts/validate-engagement-work-package-compiler.sh"
            ],
            "rollback_constraints": [
                "Do not revert unrelated user or parallel-agent edits.",
                "Run-contract handoff remains under octon run start --contract."
            ],
            "known_risks": [],
            "current_adoption_state": "octon-managed-repository",
            "updated_at": now,
        }),
    )?;

    set_status_and_ref(
        &mut engagement,
        "profiled",
        &[
            ("project_profile_ref", project_profile_ref.as_str()),
            ("orientation_evidence_ref", scan_ref.as_str()),
            (
                "project_profile_source_evidence_ref",
                profile_evidence_ref.as_str(),
            ),
        ],
        &now,
    );
    write_yaml(&engagement_path, &Value::Object(engagement))?;

    Ok(report(
        "profile",
        engagement_id,
        "profiled",
        BTreeMap::from([
            ("project_profile_ref".to_string(), project_profile_ref),
            ("orientation_evidence_ref".to_string(), scan_ref),
            (
                "project_profile_source_evidence_ref".to_string(),
                profile_evidence_ref,
            ),
        ]),
        format!("octon plan --engagement-id {engagement_id}"),
    ))
}

fn plan_engagement(octon_dir: &Path, engagement_id: &str) -> Result<CommandReport> {
    validate_id(engagement_id, "engagement_id")?;
    let control_root = engagement_control_root(octon_dir, engagement_id);
    let engagement_path = control_root.join("engagement.yml");
    let mut engagement = read_yaml_object(&engagement_path)?;
    require_ref(&engagement, "project_profile_ref")?;
    let now = now_rfc3339()?;
    let objective_root = control_root.join("objective");
    let plan_root = control_root.join("plan");
    fs::create_dir_all(&objective_root)?;
    fs::create_dir_all(&plan_root)?;

    let objective_ref = repo_ref(octon_dir, &objective_root.join("objective-brief.yml"))?;
    let charter_reconciliation_ref = repo_ref(
        octon_dir,
        &objective_root.join("charter-reconciliation.yml"),
    )?;
    let risk_ref = repo_ref(octon_dir, &plan_root.join("risk-materiality.yml"))?;
    let validation_ref = repo_ref(octon_dir, &plan_root.join("validation-plan.yml"))?;
    let rollback_ref = repo_ref(octon_dir, &plan_root.join("rollback-plan.yml"))?;
    let work_package_ref = repo_ref(octon_dir, &control_root.join("work-package.yml"))?;
    let work_package_id = format!("{engagement_id}-work-package");
    let objective_evidence_path = repo_root(octon_dir)
        .join(".octon/state/evidence/engagements")
        .join(engagement_id)
        .join("objective")
        .join("objective-brief-source.yml");
    let work_package_evidence_path = repo_root(octon_dir)
        .join(".octon/state/evidence/engagements")
        .join(engagement_id)
        .join("work-packages")
        .join(&work_package_id)
        .join("compilation-receipt.yml");
    let run_readiness_evidence_path = repo_root(octon_dir)
        .join(".octon/state/evidence/engagements")
        .join(engagement_id)
        .join("run-contract-readiness")
        .join("pre-arm.yml");
    let objective_evidence_ref = repo_ref(octon_dir, &objective_evidence_path)?;
    let work_package_evidence_ref = repo_ref(octon_dir, &work_package_evidence_path)?;
    let run_readiness_evidence_ref = repo_ref(octon_dir, &run_readiness_evidence_path)?;
    let seed_intent = engagement
        .get("seed_intent")
        .and_then(Value::as_str)
        .unwrap_or(DEFAULT_INTENT);

    write_yaml(
        &objective_root.join("objective-brief.yml"),
        &json!({
            "schema_version": "engagement-objective-brief-v1",
            "objective_brief_id": format!("{engagement_id}-objective-brief"),
            "engagement_id": engagement_id,
            "objective_layer": "engagement-control-candidate",
            "authority_status": "candidate-control-not-workspace-authority",
            "workspace_charter_substitution_allowed": false,
            "status": "candidate",
            "control_binding": {
                "objective_control_root": format!(".octon/state/control/engagements/{engagement_id}/objective"),
                "objective_control_ref": objective_ref,
                "engagement_control_ref": repo_ref(octon_dir, &engagement_path)?
            },
            "objective_summary": seed_intent,
            "scope_in": [
                PROJECT_PROFILE_REF,
                format!(".octon/state/control/engagements/{engagement_id}/seed-intent.yml")
            ],
            "scope_out": [
                format!(".octon/state/control/engagements/{engagement_id}/work-package.yml"),
                format!(".octon/state/evidence/engagements/{engagement_id}/work-packages/**")
            ],
            "done_when": [
                "Work Package is compiled with support, capability, connector, evidence, context, rollback, validation, and placement posture."
            ],
            "acceptance_criteria": [
                "Objective Brief remains per-engagement candidate control state.",
                "Material execution is only reachable through octon run start --contract."
            ],
            "workspace_charter_refs": {
                "workspace_charter_ref": WORKSPACE_CHARTER_REF,
                "workspace_machine_charter_ref": WORKSPACE_CHARTER_MACHINE_REF
            },
            "backing_evidence_refs": [objective_evidence_ref],
            "authority_boundary": {
                "objective_brief_is_workspace_charter_authority": false,
                "may_rewrite_workspace_charter": false,
                "material_execution_authorized_by_objective_brief": false
            },
            "created_at": now,
            "updated_at": now,
        }),
    )?;
    write_yaml(
        &objective_root.join("charter-reconciliation.yml"),
        &json!({
            "schema_version": "workspace-charter-reconciliation-v1",
            "engagement_id": engagement_id,
            "workspace_charter_ref": WORKSPACE_CHARTER_REF,
            "workspace_machine_charter_ref": WORKSPACE_CHARTER_MACHINE_REF,
            "release_state": "pre-1.0",
            "change_profile": "atomic",
            "result": "aligned",
            "notes": [
                "Engagement compiler remains subordinate to workspace charter and run-contract execution."
            ],
            "recorded_at": now,
        }),
    )?;
    write_yaml(
        &plan_root.join("risk-materiality.yml"),
        &json!({
            "schema_version": "risk-materiality-classification-v1",
            "engagement_id": engagement_id,
            "risk_class": "low",
            "materiality": "bounded-consequential",
            "reversibility_class": "reversible",
            "policy_ref": ".octon/instance/governance/policies/risk-materiality.yml",
            "recorded_at": now,
        }),
    )?;
    write_yaml(
        &plan_root.join("validation-plan.yml"),
        &json!({
            "schema_version": "validation-plan-v1",
            "engagement_id": engagement_id,
            "commands": [
                "cargo test -p octon_kernel"
            ],
            "done_gate": [
                "Engagement compiler commands parse.",
                "Run-contract candidate remains under engagement control state until octon run start --contract."
            ],
            "recorded_at": now,
        }),
    )?;
    write_yaml(
        &plan_root.join("rollback-plan.yml"),
        &json!({
            "schema_version": "rollback-plan-v1",
            "engagement_id": engagement_id,
            "reversibility_class": "reversible",
            "strategy": "remove prepared engagement artifacts before run start, or use canonical run rollback after handoff",
            "do_not_revert_unrelated_changes": true,
            "recorded_at": now,
        }),
    )?;
    write_yaml(
        &objective_evidence_path,
        &json!({
            "schema_version": "objective-brief-source-evidence-v1",
            "engagement_id": engagement_id,
            "objective_brief_ref": objective_ref,
            "seed_intent_ref": engagement.get("seed_intent_ref").and_then(Value::as_str).unwrap_or(""),
            "authority_boundary": {
                "objective_brief_is_workspace_charter_authority": false,
                "may_rewrite_workspace_charter": false,
                "material_execution_authorized_by_objective_brief": false
            },
            "recorded_at": now,
        }),
    )?;
    write_yaml(
        &work_package_evidence_path,
        &json!({
            "schema_version": "work-package-compilation-evidence-v1",
            "engagement_id": engagement_id,
            "work_package_id": work_package_id,
            "compiler_policy_ref": COMPILER_POLICY_REF,
            "input_refs": {
                "project_profile_ref": PROJECT_PROFILE_REF,
                "objective_brief_ref": objective_ref,
                "risk_materiality_ref": risk_ref,
                "validation_plan_ref": validation_ref,
                "rollback_plan_ref": rollback_ref
            },
            "material_effects_authorized": false,
            "recorded_at": now,
        }),
    )?;
    write_yaml(
        &run_readiness_evidence_path,
        &json!({
            "schema_version": "run-contract-readiness-evidence-v1",
            "engagement_id": engagement_id,
            "work_package_id": work_package_id,
            "candidate_status": "not_prepared",
            "material_execution_entrypoint": "octon run start --contract",
            "recorded_at": now,
        }),
    )?;
    write_yaml(
        &control_root.join("work-package.yml"),
        &json!({
            "schema_version": "work-package-v1",
            "work_package_id": work_package_id,
            "engagement_ref": repo_ref(octon_dir, &engagement_path)?,
            "project_profile_ref": PROJECT_PROFILE_REF,
            "objective_brief_schema_ref": ".octon/framework/engine/runtime/spec/engagement-objective-brief-v1.schema.json",
            "objective_control_root": format!(".octon/state/control/engagements/{engagement_id}/objective"),
            "objective_brief_ref": objective_ref,
            "objective_brief_evidence_refs": [objective_evidence_ref],
            "objective_brief_authority_boundary": {
                "objective_brief_is_workspace_charter_authority": false,
                "material_execution_authorized_by_objective_brief": false
            },
            "authority_binding": {
                "compiler_policy_ref": COMPILER_POLICY_REF,
                "workspace_charter_ref": WORKSPACE_CHARTER_REF,
                "workspace_machine_charter_ref": WORKSPACE_CHARTER_MACHINE_REF,
                "support_targets_ref": SUPPORT_TARGET_REF,
                "governance_exclusions_ref": GOVERNANCE_EXCLUSIONS_REF
            },
            "implementation_plan_summary": "Prepare a first governed run-contract candidate from the Project Profile and Objective Brief without executing material effects.",
            "impact_map": {
                "authority_roots": ["framework", "instance"],
                "control_roots": [format!(".octon/state/control/engagements/{engagement_id}")],
                "evidence_roots": [format!(".octon/state/evidence/engagements/{engagement_id}")],
                "generated_roots": [".octon/generated/cognition/projections/materialized/engagements"],
                "material_effects_before_run_start": false
            },
            "support_posture": {
                "status": "not_reconciled",
                "route": "stage_only",
                "support_target_ref": SUPPORT_TARGET_REF
            },
            "capability_posture": {
                "status": "not_reconciled",
                "route": "stage_only",
                "pack_ids": [],
                "requested_capability_packs": []
            },
            "connector_posture": {
                "connector_posture_schema_ref": ".octon/framework/engine/runtime/spec/tool-connector-posture-v1.schema.json",
                "connector_policy_schema_ref": ".octon/framework/engine/runtime/spec/connector-posture-policy-v1.schema.json",
                "connector_registry_schema_ref": ".octon/framework/engine/runtime/spec/connector-posture-registry-v1.schema.json",
                "connector_policy_ref": CONNECTOR_POSTURE_REF,
                "connector_registry_ref": ".octon/instance/governance/connectors/registry.yml",
                "readme_authority_allowed": false,
                "status": "stage_only",
                "connectors": []
            },
            "evidence_profile": {
                "profile_id": "stage-only",
                "policy_ref": EVIDENCE_PROFILES_POLICY_REF,
                "required_evidence": [
                    objective_evidence_ref,
                    work_package_evidence_ref,
                    run_readiness_evidence_ref
                ]
            },
            "context_pack": {
                "status": "not_prepared",
                "policy_ref": CONTEXT_PACKING_POLICY_REF,
                "receipt_required_before_material_effects": true
            },
            "decision_requests": [],
            "rollback": {
                "rollback_plan_ref": rollback_ref,
                "plan_ref": rollback_ref
            },
            "validation": {
                "validation_plan_ref": validation_ref
            },
            "risk_materiality": {
                "risk_materiality_ref": risk_ref,
                "materiality": "bounded-consequential",
                "risk_class": "low",
                "reversibility_class": "reversible"
            },
            "placement": {
                "path_family_registry_ref": ".octon/instance/governance/engagements/path-families.yml",
                "runtime_write_family_refs": [
                    "engagement-control",
                    "work-package-control",
                    "objective-brief-control",
                    "decision-request-control",
                    "engagement-evidence",
                    "objective-brief-evidence",
                    "orientation-evidence",
                    "project-profile-evidence",
                    "project-profile-source-fact-evidence",
                    "work-package-compilation-evidence",
                    "decision-evidence",
                    "run-contract-readiness-evidence",
                    "engagement-continuity",
                    "project-profile-authority"
                ]
            },
            "run_contract_candidate": {
                "status": "not_prepared",
                "candidate_ref": null
            },
            "run_contract_readiness_evidence_refs": [run_readiness_evidence_ref],
            "autonomy_envelope": {
                "mode": "run-only",
                "mission_required": false,
                "v1_boundary": "merged-into-work-package"
            },
            "outcome": "stage_only",
            "blockers": [
                "run-contract-candidate-not-prepared"
            ],
            "created_at": now,
            "updated_at": now,
        }),
    )?;

    set_status_and_ref(
        &mut engagement,
        "planned",
        &[
            ("objective_brief_ref", objective_ref.as_str()),
            (
                "charter_reconciliation_ref",
                charter_reconciliation_ref.as_str(),
            ),
            ("risk_materiality_ref", risk_ref.as_str()),
            ("validation_plan_ref", validation_ref.as_str()),
            ("rollback_plan_ref", rollback_ref.as_str()),
            ("work_package_ref", work_package_ref.as_str()),
        ],
        &now,
    );
    write_yaml(&engagement_path, &Value::Object(engagement))?;

    Ok(report(
        "plan",
        engagement_id,
        "planned",
        BTreeMap::from([
            ("objective_brief_ref".to_string(), objective_ref),
            (
                "charter_reconciliation_ref".to_string(),
                charter_reconciliation_ref,
            ),
            ("risk_materiality_ref".to_string(), risk_ref),
            ("validation_plan_ref".to_string(), validation_ref),
            ("rollback_plan_ref".to_string(), rollback_ref),
            ("work_package_ref".to_string(), work_package_ref),
        ]),
        format!("octon arm --engagement-id {engagement_id} --prepare-only"),
    ))
}

fn arm_engagement(
    octon_dir: &Path,
    engagement_id: &str,
    workflow_id: &str,
) -> Result<CommandReport> {
    validate_id(engagement_id, "engagement_id")?;
    validate_id(workflow_id, "workflow_id")?;
    validate_workflow_known(octon_dir, workflow_id)?;
    ensure_machine_policy(octon_dir, COMPILER_POLICY_REF)?;
    ensure_machine_policy(octon_dir, EVIDENCE_PROFILES_POLICY_REF)?;
    ensure_machine_policy(octon_dir, PREFLIGHT_EVIDENCE_LANE_POLICY_REF)?;
    ensure_machine_policy(octon_dir, CONNECTOR_POSTURE_REF)?;
    let connector_policy = read_yaml_value(&repo_root(octon_dir).join(CONNECTOR_POSTURE_REF))?;
    let control_root = engagement_control_root(octon_dir, engagement_id);
    let engagement_path = control_root.join("engagement.yml");
    let mut engagement = read_yaml_object(&engagement_path)?;
    require_ref(&engagement, "work_package_ref")?;
    let mut work_package = read_yaml_object(&control_root.join("work-package.yml"))?;
    let now = now_rfc3339()?;
    let run_id = format!("{engagement_id}-run-1");
    validate_id(&run_id, "run_id")?;

    let connector_ref = repo_ref(
        octon_dir,
        &control_root.join("connectors").join("posture.yml"),
    )?;
    let support_ref = repo_ref(
        octon_dir,
        &control_root.join("support-capability-posture.yml"),
    )?;
    let evidence_profile_ref = repo_ref(octon_dir, &control_root.join("evidence-profile.yml"))?;
    let context_request_ref = repo_ref(
        octon_dir,
        &control_root
            .join("context")
            .join("context-pack-request.yml"),
    )?;
    let decision_index_ref =
        repo_ref(octon_dir, &control_root.join("decisions").join("index.yml"))?;
    let candidate_root = control_root.join("run-candidates").join(&run_id);
    let candidate_ref = repo_ref(
        octon_dir,
        &candidate_root.join("run-contract.candidate.yml"),
    )?;
    let decision_id = format!("{engagement_id}-authorize-run");
    let decision_path = control_root
        .join("decisions")
        .join(format!("{decision_id}.yml"));
    let decision_ref = repo_ref(octon_dir, &decision_path)?;
    let decision_evidence_root = repo_root(octon_dir)
        .join(".octon/state/evidence/decisions")
        .join(&decision_id);
    let decision_evidence_ref = repo_ref(octon_dir, &decision_evidence_root.join("request.yml"))?;
    let run_readiness_evidence_path = repo_root(octon_dir)
        .join(".octon/state/evidence/engagements")
        .join(engagement_id)
        .join("run-contract-readiness")
        .join("candidate-prepared.yml");
    let run_readiness_evidence_ref = repo_ref(octon_dir, &run_readiness_evidence_path)?;
    fs::create_dir_all(control_root.join("connectors"))?;
    fs::create_dir_all(control_root.join("decisions"))?;
    fs::create_dir_all(&candidate_root)?;
    fs::create_dir_all(&decision_evidence_root)?;

    write_yaml(
        &control_root.join("connectors").join("posture.yml"),
        &json!({
            "schema_version": "engagement-connector-posture-selection-v1",
            "engagement_id": engagement_id,
            "source_policy_ref": CONNECTOR_POSTURE_REF,
            "policy_id": connector_policy.get("policy_id").cloned().unwrap_or(json!("engagement-connector-posture")),
            "selected_posture": "stage_only",
            "live_connector_invocation_allowed": false,
            "connector_classes": connector_policy.get("connector_classes").cloned().unwrap_or(json!([])),
            "recorded_at": now,
        }),
    )?;
    write_yaml(
        &control_root.join("support-capability-posture.yml"),
        &json!({
            "schema_version": "support-capability-posture-v1",
            "engagement_id": engagement_id,
            "support_target_ref": SUPPORT_TARGET_REF,
            "governance_exclusions_ref": GOVERNANCE_EXCLUSIONS_REF,
            "support_target_tuple": support_tuple(),
            "requested_capability_packs": ["repo", "telemetry"],
            "requested_capabilities": ["workflow.execute", "evidence.write"],
            "route": "ready_for_authorization",
            "live_connector_invocation_allowed": false,
            "recorded_at": now,
        }),
    )?;
    write_yaml(
        &control_root.join("evidence-profile.yml"),
        &json!({
            "schema_version": "evidence-profile-selection-v1",
            "engagement_id": engagement_id,
            "selected_profile": "repo-consequential",
            "policy_ref": EVIDENCE_PROFILES_POLICY_REF,
            "runtime_authorization_required": true,
            "material_effects_allowed_by_compiler": false,
            "selection_rationale": "Repo-local run-contract candidate handoff is prepared; live effects remain gated by octon run start --contract.",
            "recorded_at": now,
        }),
    )?;
    write_yaml(
        &control_root
            .join("context")
            .join("context-pack-request.yml"),
        &json!({
            "schema_version": "context-pack-request-v1",
            "engagement_id": engagement_id,
            "run_id": run_id,
            "policy_ref": CONTEXT_PACKING_POLICY_REF,
            "status": "request_prepared",
            "receipt_required_before_material_effects": true,
            "source_refs": [
                PROJECT_PROFILE_REF,
                format!(".octon/state/control/engagements/{engagement_id}/objective/objective-brief.yml"),
                format!(".octon/state/control/engagements/{engagement_id}/work-package.yml")
            ],
            "recorded_at": now,
        }),
    )?;
    write_yaml(
        &control_root.join("decisions").join("index.yml"),
        &json!({
            "schema_version": "decision-request-set-v1",
            "engagement_id": engagement_id,
            "decision_requests": [
                {
                    "decision_request_id": decision_id,
                    "decision_request_ref": decision_ref,
                    "status": "open",
                    "decision_type": "approval",
                    "required_before": "run-contract-candidate-submission"
                }
            ],
            "canonical_low_level_roots": {
                "approvals": ".octon/state/control/execution/approvals/**",
                "exceptions": ".octon/state/control/execution/exceptions/**",
                "revocations": ".octon/state/control/execution/revocations/**"
            },
            "recorded_at": now,
        }),
    )?;
    write_yaml(
        &decision_path,
        &json!({
            "schema_version": "decision-request-v1",
            "decision_request_id": decision_id,
            "engagement_id": engagement_id,
            "status": "open",
            "decision_type": "approval",
            "question": "Approve submission of this prepared run-contract candidate through the existing octon run start --contract authorization boundary?",
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
                "engagement_ref": repo_ref(octon_dir, &engagement_path)?,
                "work_package_ref": repo_ref(octon_dir, &control_root.join("work-package.yml"))?,
                "run_contract_candidate_ref": candidate_ref,
                "context_pack_request_ref": context_request_ref,
                "support_capability_posture_ref": support_ref,
                "connector_posture_ref": connector_ref
            },
            "canonical_resolution_targets": {
                "approval_request_ref": format!(".octon/state/control/execution/approvals/requests/{decision_id}.yml"),
                "approval_grant_ref": format!(".octon/state/control/execution/approvals/grants/grant-{decision_id}.yml"),
                "exception_lease_root": ".octon/state/control/execution/exceptions/leases",
                "revocation_root": ".octon/state/control/execution/revocations"
            },
            "evidence_root": format!(".octon/state/evidence/decisions/{decision_id}"),
            "created_at": now,
            "updated_at": now,
        }),
    )?;
    write_yaml(
        &decision_evidence_root.join("request.yml"),
        &json!({
            "schema_version": "decision-request-evidence-v1",
            "decision_request_id": decision_id,
            "engagement_id": engagement_id,
            "decision_request_ref": decision_ref,
            "work_package_ref": repo_ref(octon_dir, &control_root.join("work-package.yml"))?,
            "run_contract_candidate_ref": candidate_ref,
            "recorded_at": now,
        }),
    )?;
    write_yaml(
        &candidate_root.join("run-contract.candidate.yml"),
        &run_contract_candidate(
            octon_dir,
            engagement_id,
            &run_id,
            workflow_id,
            &support_ref,
            &evidence_profile_ref,
            &context_request_ref,
            &decision_index_ref,
            &now,
        )?,
    )?;
    write_yaml(
        &run_readiness_evidence_path,
        &json!({
            "schema_version": "run-contract-readiness-evidence-v1",
            "engagement_id": engagement_id,
            "run_id": run_id,
            "candidate_ref": candidate_ref,
            "decision_request_ref": decision_ref,
            "decision_status": "open",
            "material_execution_entrypoint": "octon run start --contract",
            "direct_execution_allowed": false,
            "recorded_at": now,
        }),
    )?;

    upsert(
        &mut work_package,
        "support_posture",
        json!({
            "support_capability_posture_ref": support_ref,
            "support_target_ref": SUPPORT_TARGET_REF,
            "tuple_id": "tuple://repo-local-governed/repo-consequential/reference-owned/english-primary/repo-shell",
            "claim_effect": "admitted-live-claim",
            "route": "requires_decision"
        }),
    );
    upsert(
        &mut work_package,
        "capability_posture",
        json!({
            "pack_ids": ["repo", "telemetry"],
            "requested_capability_packs": ["repo", "telemetry"],
            "route": "requires_decision"
        }),
    );
    upsert(
        &mut work_package,
        "connector_posture",
        json!({
            "connector_posture_schema_ref": ".octon/framework/engine/runtime/spec/tool-connector-posture-v1.schema.json",
            "connector_policy_schema_ref": ".octon/framework/engine/runtime/spec/connector-posture-policy-v1.schema.json",
            "connector_registry_schema_ref": ".octon/framework/engine/runtime/spec/connector-posture-registry-v1.schema.json",
            "connector_policy_ref": CONNECTOR_POSTURE_REF,
            "connector_registry_ref": ".octon/instance/governance/connectors/registry.yml",
            "readme_authority_allowed": false,
            "connector_posture_ref": connector_ref,
            "connectors": [],
            "live_connector_invocation_allowed": false
        }),
    );
    upsert(
        &mut work_package,
        "evidence_profile",
        json!({
            "evidence_profile_ref": evidence_profile_ref,
            "profile_id": "repo-consequential",
            "selected_profile": "repo-consequential",
            "policy_ref": EVIDENCE_PROFILES_POLICY_REF,
            "required_evidence": [
                "support-target-reconciliation",
                "capability-admission-posture",
                "connector-posture-selection",
                "context-pack-request",
                "rollback-plan",
                "validation-plan",
                "run-contract-candidate",
                "Decision Request resolution before handoff"
            ]
        }),
    );
    upsert(
        &mut work_package,
        "context_pack",
        json!({
            "context_pack_request_ref": context_request_ref,
            "receipt_required_before_material_effects": true,
            "receipt_ref": null,
            "missing_receipt_route": "stage_only"
        }),
    );
    upsert(
        &mut work_package,
        "decision_requests",
        json!([
            {
                "decision_request_id": decision_id,
                "decision_request_ref": decision_ref,
                "evidence_ref": decision_evidence_ref,
                "status": "open"
            }
        ]),
    );
    upsert(
        &mut work_package,
        "run_contract_candidate",
        json!({
            "run_id": run_id,
            "candidate_ref": candidate_ref,
            "handoff_command": format!("octon run start --contract {candidate_ref}"),
            "direct_execution_allowed": false,
            "requires_decision_request_ref": decision_ref
        }),
    );
    upsert(
        &mut work_package,
        "run_contract_readiness_evidence_refs",
        json!([run_readiness_evidence_ref]),
    );
    upsert(&mut work_package, "outcome", json!("requires_decision"));
    upsert(
        &mut work_package,
        "blockers",
        json!([
            "decision-request-open",
            "context-pack-receipt-required-before-material-effects"
        ]),
    );
    upsert(&mut work_package, "updated_at", json!(now));
    write_yaml(
        &control_root.join("work-package.yml"),
        &Value::Object(work_package),
    )?;

    set_status_and_ref(
        &mut engagement,
        "requires_decision",
        &[
            ("support_capability_posture_ref", support_ref.as_str()),
            ("connector_posture_ref", connector_ref.as_str()),
            ("evidence_profile_ref", evidence_profile_ref.as_str()),
            ("context_pack_request_ref", context_request_ref.as_str()),
            ("decision_request_set_ref", decision_index_ref.as_str()),
            ("decision_request_ref", decision_ref.as_str()),
            ("run_contract_candidate_ref", candidate_ref.as_str()),
        ],
        &now,
    );
    upsert(&mut engagement, "outcome", json!("requires_decision"));
    upsert(
        &mut engagement,
        "decision_request_refs",
        json!([decision_ref]),
    );
    upsert(
        &mut engagement,
        "next_action",
        json!(format!(
            "octon decide resolve {decision_id} --engagement-id {engagement_id} --response approve"
        )),
    );
    write_yaml(&engagement_path, &Value::Object(engagement))?;

    Ok(report(
        "arm",
        engagement_id,
        "requires_decision",
        BTreeMap::from([
            ("support_capability_posture_ref".to_string(), support_ref),
            ("connector_posture_ref".to_string(), connector_ref),
            ("evidence_profile_ref".to_string(), evidence_profile_ref),
            ("context_pack_request_ref".to_string(), context_request_ref),
            ("decision_request_set_ref".to_string(), decision_index_ref),
            ("decision_request_ref".to_string(), decision_ref.clone()),
            (
                "run_contract_candidate_ref".to_string(),
                candidate_ref.clone(),
            ),
        ]),
        format!(
            "octon decide resolve {decision_id} --engagement-id {engagement_id} --response approve"
        ),
    ))
}

fn status_engagement(octon_dir: &Path, engagement_id: &str) -> Result<CommandReport> {
    validate_id(engagement_id, "engagement_id")?;
    let engagement_path = engagement_control_root(octon_dir, engagement_id).join("engagement.yml");
    let engagement = read_yaml_object(&engagement_path)?;
    let status = engagement
        .get("status")
        .and_then(Value::as_str)
        .unwrap_or("unknown")
        .to_string();
    let mut refs = BTreeMap::from([(
        "engagement_ref".to_string(),
        repo_ref(octon_dir, &engagement_path)?,
    )]);
    if let Some(object) = engagement.get("refs").and_then(Value::as_object) {
        for (key, value) in object {
            if let Some(reference) = value.as_str() {
                refs.insert(key.clone(), reference.to_string());
            }
        }
    }
    let next_command = engagement
        .get("next_action")
        .and_then(Value::as_str)
        .unwrap_or("octon status --engagement-id <id>")
        .to_string();
    Ok(report("status", engagement_id, &status, refs, next_command))
}

fn decide_engagement(
    octon_dir: &Path,
    engagement_id: &str,
    decision_id: &str,
    response: &str,
) -> Result<CommandReport> {
    validate_id(engagement_id, "engagement_id")?;
    validate_id(decision_id, "decision_id")?;
    let control_root = engagement_control_root(octon_dir, engagement_id);
    let decision_path = control_root
        .join("decisions")
        .join(format!("{decision_id}.yml"));
    let decision_index_path = control_root.join("decisions").join("index.yml");
    let mut decision = read_yaml_object(&decision_path)?;
    let now = now_rfc3339()?;
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
        _ => "resolved",
    };
    let resolution_ref = format!(".octon/state/evidence/decisions/{decision_id}/resolution.yml");
    let resolution_path = repo_root(octon_dir).join(&resolution_ref);
    let canonical_refs = write_canonical_decision_resolution(
        octon_dir,
        engagement_id,
        decision_id,
        response,
        &decision,
        &now,
    )?;
    upsert(&mut decision, "status", json!(status));
    upsert(
        &mut decision,
        "resolution",
        json!({
            "response": response,
            "canonical_refs": canonical_refs,
            "evidence_ref": resolution_ref,
            "recorded_at": now
        }),
    );
    upsert(&mut decision, "updated_at", json!(now));
    write_yaml(&decision_path, &Value::Object(decision))?;
    write_yaml(
        &resolution_path,
        &json!({
            "schema_version": "decision-request-resolution-v1",
            "engagement_id": engagement_id,
            "decision_request_id": decision_id,
            "response": response,
            "canonical_refs": canonical_refs,
            "material_effects_authorized": false,
            "notes": "Resolution is operator-facing compiler control state; low-level execution authority remains under canonical execution control roots.",
            "recorded_at": now,
        }),
    )?;
    update_decision_index_status(&decision_index_path, decision_id, status, response, &now)?;
    update_work_package_after_decision(
        octon_dir,
        engagement_id,
        decision_id,
        status,
        response,
        &now,
    )?;
    update_engagement_after_decision(octon_dir, engagement_id, status, response, &now)?;
    let decision_ref = repo_ref(octon_dir, &decision_path)?;
    Ok(report(
        "decide",
        engagement_id,
        status,
        BTreeMap::from([
            ("decision_request_ref".to_string(), decision_ref),
            ("decision_resolution_ref".to_string(), resolution_ref),
        ]),
        format!("octon status --engagement-id {engagement_id}"),
    ))
}

fn write_canonical_decision_resolution(
    octon_dir: &Path,
    engagement_id: &str,
    decision_id: &str,
    response: &str,
    decision: &Map<String, Value>,
    now: &str,
) -> Result<Value> {
    let run_id = decision
        .get("subject_refs")
        .and_then(Value::as_object)
        .and_then(|refs| refs.get("run_contract_candidate_ref"))
        .and_then(Value::as_str)
        .and_then(|reference| reference.split("/run-candidates/").nth(1))
        .and_then(|suffix| suffix.split('/').next())
        .unwrap_or("pending-run-candidate");
    let repo_root = repo_root(octon_dir);
    let mut refs = Map::new();

    match response {
        "approval" => {
            let request_ref =
                format!(".octon/state/control/execution/approvals/requests/{decision_id}.yml");
            let grant_ref =
                format!(".octon/state/control/execution/approvals/grants/grant-{decision_id}.yml");
            write_yaml(
                &repo_root.join(&request_ref),
                &json!({
                    "schema_version": "authority-approval-request-v1",
                    "request_id": decision_id,
                    "run_id": run_id,
                    "status": "granted",
                    "target_id": engagement_id,
                    "action_type": "engagement-run-contract-candidate-handoff",
                    "workflow_mode": "role-mediated",
                    "support_tier": "repo-consequential",
                    "reason_codes": ["engagement-work-package-compiler-v1"],
                    "required_evidence": [
                        format!(".octon/state/evidence/decisions/{decision_id}/request.yml"),
                        format!(".octon/state/evidence/decisions/{decision_id}/resolution.yml")
                    ],
                    "created_at": now,
                    "updated_at": now,
                }),
            )?;
            write_yaml(
                &repo_root.join(&grant_ref),
                &json!({
                    "schema_version": "authority-approval-grant-v1",
                    "grant_id": format!("grant-{decision_id}"),
                    "request_id": decision_id,
                    "run_id": run_id,
                    "state": "active",
                    "issued_by": "octon-decision-request-v1",
                    "issued_at": now,
                    "expires_at": null,
                    "required_evidence": [
                        format!(".octon/state/evidence/decisions/{decision_id}/resolution.yml")
                    ]
                }),
            )?;
            refs.insert("approval_request_ref".to_string(), json!(request_ref));
            refs.insert("approval_grant_ref".to_string(), json!(grant_ref));
        }
        "exception_lease" => {
            let lease_ref =
                format!(".octon/state/control/execution/exceptions/leases/lease-{decision_id}.yml");
            write_yaml(
                &repo_root.join(&lease_ref),
                &json!({
                    "schema_version": "authority-exception-lease-v1",
                    "lease_id": format!("lease-{decision_id}"),
                    "source_decision_request_id": decision_id,
                    "engagement_id": engagement_id,
                    "state": "staged",
                    "material_effects_authorized": false,
                    "created_at": now,
                    "updated_at": now,
                }),
            )?;
            refs.insert("exception_lease_ref".to_string(), json!(lease_ref));
        }
        "revocation" => {
            let revocation_ref =
                format!(".octon/state/control/execution/revocations/revoke-{decision_id}.yml");
            write_yaml(
                &repo_root.join(&revocation_ref),
                &json!({
                    "schema_version": "authority-revocation-v1",
                    "revocation_id": format!("revoke-{decision_id}"),
                    "source_decision_request_id": decision_id,
                    "engagement_id": engagement_id,
                    "state": "active",
                    "created_at": now,
                    "updated_at": now,
                }),
            )?;
            refs.insert("revocation_ref".to_string(), json!(revocation_ref));
        }
        "denial" => {
            refs.insert(
                "denial_record_ref".to_string(),
                json!(format!(
                    ".octon/state/evidence/decisions/{decision_id}/resolution.yml"
                )),
            );
        }
        _ => {
            refs.insert(
                "decision_record_ref".to_string(),
                json!(format!(
                    ".octon/state/evidence/decisions/{decision_id}/resolution.yml"
                )),
            );
        }
    }

    Ok(Value::Object(refs))
}

fn update_decision_index_status(
    decision_index_path: &Path,
    decision_id: &str,
    status: &str,
    response: &str,
    now: &str,
) -> Result<()> {
    let mut index = read_yaml_object(decision_index_path)?;
    if let Some(requests) = index
        .get_mut("decision_requests")
        .and_then(Value::as_array_mut)
    {
        for request in requests {
            if request.get("decision_request_id").and_then(Value::as_str) == Some(decision_id) {
                if let Some(object) = request.as_object_mut() {
                    object.insert("status".to_string(), json!(status));
                    object.insert("resolution".to_string(), json!(response));
                    object.insert("resolved_at".to_string(), json!(now));
                }
            }
        }
    }
    upsert(&mut index, "updated_at", json!(now));
    write_yaml(decision_index_path, &Value::Object(index))
}

fn update_engagement_after_decision(
    octon_dir: &Path,
    engagement_id: &str,
    status: &str,
    response: &str,
    now: &str,
) -> Result<()> {
    let engagement_path = engagement_control_root(octon_dir, engagement_id).join("engagement.yml");
    let mut engagement = read_yaml_object(&engagement_path)?;
    let next_status = match (status, response) {
        ("resolved", "approval") => "stage_only",
        ("denied", _) => "denied",
        ("revoked", _) => "denied",
        _ => "requires_decision",
    };
    upsert(&mut engagement, "status", json!(next_status));
    upsert(&mut engagement, "stage", json!("decision-resolved"));
    upsert(&mut engagement, "outcome", json!(next_status));
    upsert(&mut engagement, "updated_at", json!(now));
    if next_status == "stage_only" {
        let next_action = engagement
            .get("refs")
            .and_then(Value::as_object)
            .and_then(|refs| refs.get("run_contract_candidate_ref"))
            .and_then(Value::as_str)
            .map(|candidate_ref| format!("octon run start --contract {candidate_ref}"))
            .unwrap_or_else(|| format!("octon status --engagement-id {engagement_id}"));
        upsert(&mut engagement, "next_action", json!(next_action));
    } else {
        upsert(
            &mut engagement,
            "next_action",
            json!(format!("octon status --engagement-id {engagement_id}")),
        );
    }
    write_yaml(&engagement_path, &Value::Object(engagement))
}

fn update_work_package_after_decision(
    octon_dir: &Path,
    engagement_id: &str,
    decision_id: &str,
    status: &str,
    response: &str,
    now: &str,
) -> Result<()> {
    let work_package_path =
        engagement_control_root(octon_dir, engagement_id).join("work-package.yml");
    if !work_package_path.is_file() {
        return Ok(());
    }
    let mut work_package = read_yaml_object(&work_package_path)?;
    if let Some(requests) = work_package
        .get_mut("decision_requests")
        .and_then(Value::as_array_mut)
    {
        for request in requests {
            if request.get("decision_request_id").and_then(Value::as_str) == Some(decision_id) {
                if let Some(object) = request.as_object_mut() {
                    object.insert("status".to_string(), json!(status));
                    object.insert("resolution".to_string(), json!(response));
                    object.insert("resolved_at".to_string(), json!(now));
                }
            }
        }
    }

    match (status, response) {
        ("resolved", "approval") => {
            upsert(&mut work_package, "outcome", json!("stage_only"));
            upsert(
                &mut work_package,
                "blockers",
                json!(["context-pack-receipt-required-before-material-effects"]),
            );
            if let Some(support) = work_package
                .get_mut("support_posture")
                .and_then(Value::as_object_mut)
            {
                support.insert("route".to_string(), json!("stage_only"));
            }
            if let Some(capability) = work_package
                .get_mut("capability_posture")
                .and_then(Value::as_object_mut)
            {
                capability.insert("route".to_string(), json!("stage_only"));
            }
        }
        ("denied", _) | ("revoked", _) => {
            upsert(&mut work_package, "outcome", json!("denied"));
            upsert(
                &mut work_package,
                "blockers",
                json!(["decision-request-denied"]),
            );
        }
        _ => {
            upsert(&mut work_package, "outcome", json!("requires_decision"));
        }
    }
    upsert(&mut work_package, "updated_at", json!(now));
    write_yaml(&work_package_path, &Value::Object(work_package))
}

fn ensure_candidate_decisions_resolved(octon_dir: &Path, candidate: &Value) -> Result<()> {
    let decision_index_ref = yaml_optional_string(candidate, "decision_request_set_ref")
        .ok_or_else(|| anyhow!("run candidate is missing decision_request_set_ref"))?;
    let decision_index = read_yaml_value(&repo_root(octon_dir).join(&decision_index_ref))?;
    let requests = decision_index
        .get("decision_requests")
        .and_then(Value::as_array)
        .ok_or_else(|| anyhow!("Decision Request index must contain decision_requests"))?;
    let unresolved: Vec<String> = requests
        .iter()
        .filter_map(|request| {
            let status = request
                .get("status")
                .and_then(Value::as_str)
                .unwrap_or("open");
            if status == "resolved" {
                None
            } else {
                request
                    .get("decision_request_id")
                    .and_then(Value::as_str)
                    .map(ToString::to_string)
            }
        })
        .collect();
    if unresolved.is_empty() {
        Ok(())
    } else {
        bail!(
            "run candidate has unresolved Decision Requests: {}; resolve them with `octon decide` before run start",
            unresolved.join(", ")
        )
    }
}

fn run_contract_candidate(
    octon_dir: &Path,
    engagement_id: &str,
    run_id: &str,
    workflow_id: &str,
    support_ref: &str,
    evidence_profile_ref: &str,
    context_request_ref: &str,
    decision_index_ref: &str,
    now: &str,
) -> Result<Value> {
    let control_root = format!(".octon/state/control/execution/runs/{run_id}");
    let evidence_root = format!(".octon/state/evidence/runs/{run_id}");
    let objective_ref =
        format!(".octon/state/control/engagements/{engagement_id}/objective/objective-brief.yml");
    let work_package_ref =
        format!(".octon/state/control/engagements/{engagement_id}/work-package.yml");
    let engagement_ref = format!(".octon/state/control/engagements/{engagement_id}/engagement.yml");
    let support_target = support_tuple();
    Ok(json!({
        "schema_version": "run-contract-v3",
        "run_id": run_id,
        "workflow_id": workflow_id,
        "status": "candidate",
        "direct_execution_allowed": false,
        "handoff": {
            "entrypoint": "octon run start --contract",
            "bypass_run_start": false,
            "prepare_only_required_for_candidate_submission": true
        },
        "workflow_mode": "role-mediated",
        "objective_refs": {
            "workspace_objective_ref": WORKSPACE_CHARTER_REF,
            "workspace_machine_charter_ref": WORKSPACE_CHARTER_MACHINE_REF,
            "engagement_ref": engagement_ref,
            "project_profile_ref": PROJECT_PROFILE_REF,
            "objective_brief_ref": objective_ref,
            "work_package_ref": work_package_ref
        },
        "objective_summary": engagement_seed_intent(octon_dir, engagement_id)?,
        "scope_in": [
            "workflow-contract",
            PROJECT_PROFILE_REF,
            objective_ref,
            work_package_ref
        ],
        "scope_out": [
            evidence_root.clone(),
            format!(".octon/state/evidence/disclosure/runs/{run_id}")
        ],
        "done_when": [
            "Existing octon run lifecycle reaches terminal state with retained evidence.",
            "RunCard, replay pointers, and trace pointers resolve under canonical run roots."
        ],
        "acceptance_criteria": [
            "Material execution enters through octon run start --contract.",
            "Support, connector, evidence, context, validation, and rollback posture remain bounded by the Work Package."
        ],
        "materiality": "bounded-consequential",
        "risk_class": "low",
        "reversibility_class": "reversible",
        "requested_capabilities": [
            "workflow.execute",
            "evidence.write"
        ],
        "requested_capability_packs": [
            "repo",
            "telemetry"
        ],
        "protected_zone_scope": [
            ".octon/framework/constitution/**",
            ".octon/instance/governance/**"
        ],
        "support_target_ref": SUPPORT_TARGET_REF,
        "support_target_tuple": support_target.clone(),
        "support_target": support_target,
        "support_tier": "repo-consequential",
        "support_capability_posture_ref": support_ref,
        "connector_posture_ref": format!(".octon/state/control/engagements/{engagement_id}/connectors/posture.yml"),
        "evidence_profile_ref": evidence_profile_ref,
        "context_pack_request_ref": context_request_ref,
        "decision_request_set_ref": decision_index_ref,
        "mission_id": null,
        "requires_mission": false,
        "mission_mode": "run-only",
        "required_approvals": [],
        "required_evidence": [
            "run-contract-candidate",
            "support-target-reconciliation",
            "capability-admission-posture",
            "context-pack-request",
            "rollback-plan",
            "validation-plan",
            "risk-materiality-classification",
            "execution-receipt-after-run-start"
        ],
        "retry_class": "manual_review_required",
        "rollback_posture_ref": format!("{control_root}/rollback-posture.yml"),
        "stage_attempt_root": format!("{control_root}/stage-attempts"),
        "checkpoint_root": format!("{control_root}/checkpoints"),
        "continuity_root_ref": format!(".octon/state/continuity/runs/{run_id}/handoff.yml"),
        "authority_bundle_ref": format!(".octon/state/evidence/control/execution/authority-grant-bundle-{run_id}.yml"),
        "run_manifest_ref": format!("{control_root}/run-manifest.yml"),
        "runtime_state_ref": format!("{control_root}/runtime-state.yml"),
        "run_card_ref": format!(".octon/state/evidence/disclosure/runs/{run_id}/run-card.yml"),
        "created_at": now,
        "updated_at": now,
    }))
}

fn engagement_seed_intent(octon_dir: &Path, engagement_id: &str) -> Result<String> {
    let path = engagement_control_root(octon_dir, engagement_id).join("seed-intent.yml");
    let value = read_yaml_value(&path)?;
    Ok(value
        .get("intent")
        .and_then(Value::as_str)
        .unwrap_or(DEFAULT_INTENT)
        .to_string())
}

fn authority_refs() -> Value {
    json!({
        "compiler_policy_ref": COMPILER_POLICY_REF,
        "evidence_profiles_policy_ref": EVIDENCE_PROFILES_POLICY_REF,
        "preflight_evidence_lane_policy_ref": PREFLIGHT_EVIDENCE_LANE_POLICY_REF,
        "connector_posture_ref": CONNECTOR_POSTURE_REF,
        "support_target_ref": SUPPORT_TARGET_REF,
        "governance_exclusions_ref": GOVERNANCE_EXCLUSIONS_REF,
        "workspace_charter_ref": WORKSPACE_CHARTER_REF,
        "workspace_machine_charter_ref": WORKSPACE_CHARTER_MACHINE_REF,
    })
}

fn support_tuple() -> Value {
    json!({
        "model_tier": "repo-local-governed",
        "workload_tier": "repo-consequential",
        "language_resource_tier": "reference-owned",
        "locale_tier": "english-primary",
        "host_adapter": "repo-shell",
        "model_adapter": "repo-local-governed",
    })
}

fn report(
    command: &'static str,
    engagement_id: &str,
    status: &str,
    refs: BTreeMap<String, String>,
    next_command: String,
) -> CommandReport {
    CommandReport {
        command,
        engagement_id: engagement_id.to_string(),
        status: status.to_string(),
        refs,
        next_command,
    }
}

fn print_report(report: &CommandReport) -> Result<()> {
    println!("{}", serde_json::to_string_pretty(report)?);
    Ok(())
}

fn engagement_control_root(octon_dir: &Path, engagement_id: &str) -> PathBuf {
    repo_root(octon_dir)
        .join(".octon/state/control/engagements")
        .join(engagement_id)
}

fn engagement_evidence_root(octon_dir: &Path, engagement_id: &str) -> PathBuf {
    repo_root(octon_dir)
        .join(".octon/state/evidence/engagements")
        .join(engagement_id)
}

fn repo_root(octon_dir: &Path) -> PathBuf {
    octon_dir.parent().unwrap_or(octon_dir).to_path_buf()
}

fn repo_ref(octon_dir: &Path, path: &Path) -> Result<String> {
    path_to_repo_ref(octon_dir, path)
}

fn write_yaml<T: Serialize + ?Sized>(path: &Path, value: &T) -> Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent).with_context(|| format!("create {}", parent.display()))?;
    }
    let text = serde_yaml::to_string(value)?;
    fs::write(path, text).with_context(|| format!("write {}", path.display()))?;
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

fn yaml_optional_string(value: &Value, key: &str) -> Option<String> {
    value
        .get(key)
        .and_then(Value::as_str)
        .map(ToString::to_string)
}

fn require_ref(engagement: &Map<String, Value>, key: &str) -> Result<()> {
    let exists = engagement
        .get("refs")
        .and_then(Value::as_object)
        .and_then(|refs| refs.get(key))
        .and_then(Value::as_str)
        .map(|value| !value.trim().is_empty())
        .unwrap_or(false);
    if exists {
        Ok(())
    } else {
        bail!("engagement is missing required ref `{key}`; run the previous compiler command first")
    }
}

fn set_status_and_ref(
    value: &mut Map<String, Value>,
    status: &str,
    refs: &[(&str, &str)],
    updated_at: &str,
) {
    upsert(value, "status", json!(status));
    upsert(value, "stage", json!(status));
    upsert(value, "updated_at", json!(updated_at));
    for (key, reference) in refs {
        value.insert((*key).to_string(), json!(reference));
    }
    let refs_value = value
        .entry("refs".to_string())
        .or_insert_with(|| Value::Object(Map::new()));
    if let Some(refs_object) = refs_value.as_object_mut() {
        for (key, reference) in refs {
            refs_object.insert((*key).to_string(), json!(reference));
        }
    }
}

fn upsert(object: &mut Map<String, Value>, key: &str, value: Value) {
    object.insert(key.to_string(), value);
}

fn source_digests(octon_dir: &Path) -> Result<Value> {
    let repo_root = repo_root(octon_dir);
    let refs = [
        WORKSPACE_CHARTER_REF,
        WORKSPACE_CHARTER_MACHINE_REF,
        ".octon/framework/engine/runtime/crates/Cargo.toml",
        ".octon/framework/engine/runtime/crates/kernel/src/main.rs",
    ];
    let mut out = Map::new();
    for reference in refs {
        let path = repo_root.join(reference);
        if path.is_file() {
            out.insert(reference.to_string(), json!(sha256_file(&path)?));
        }
    }
    Ok(Value::Object(out))
}

fn sha256_file(path: &Path) -> Result<String> {
    let bytes = fs::read(path).with_context(|| format!("read {}", path.display()))?;
    Ok(hex::encode(Sha256::digest(bytes)))
}

fn detected_toolchains(octon_dir: &Path) -> Vec<String> {
    let repo_root = repo_root(octon_dir);
    let mut toolchains = Vec::new();
    if repo_root
        .join(".octon/framework/engine/runtime/crates/Cargo.toml")
        .is_file()
        || repo_root.join("Cargo.toml").is_file()
    {
        toolchains.push("rust".to_string());
    }
    if repo_root.join("package.json").is_file() {
        toolchains.push("node".to_string());
    }
    if repo_root.join("pyproject.toml").is_file() {
        toolchains.push("python".to_string());
    }
    if toolchains.is_empty() {
        toolchains.push("unknown".to_string());
    }
    toolchains
}

fn ensure_machine_policy(octon_dir: &Path, reference: &str) -> Result<()> {
    let path = repo_root(octon_dir).join(reference);
    if !path.is_file() {
        bail!("required machine-readable policy is missing: {reference}");
    }
    let value = read_yaml_value(&path)?;
    if value
        .get("schema_version")
        .and_then(Value::as_str)
        .is_none()
    {
        bail!("required policy lacks schema_version: {reference}");
    }
    Ok(())
}

fn validate_workflow_known(octon_dir: &Path, workflow_id: &str) -> Result<()> {
    let manifest_path =
        repo_root(octon_dir).join(".octon/framework/orchestration/runtime/workflows/manifest.yml");
    let manifest = read_yaml_value(&manifest_path)?;
    let workflows = manifest
        .get("workflows")
        .and_then(Value::as_array)
        .ok_or_else(|| anyhow!("workflow manifest does not contain workflows"))?;
    let found = workflows.iter().any(|entry| {
        entry
            .get("id")
            .and_then(Value::as_str)
            .map(|id| id == workflow_id)
            .unwrap_or(false)
    });
    if found {
        Ok(())
    } else {
        bail!("unknown workflow id for run candidate: {workflow_id}")
    }
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

fn new_id(prefix: &str) -> String {
    let millis = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|duration| duration.as_millis())
        .unwrap_or(0);
    format!("{prefix}-{millis}-{}", std::process::id())
}

fn write_projection(
    path: &Path,
    engagement_id: &str,
    status: &str,
    refs: &BTreeMap<String, String>,
) -> Result<()> {
    write_yaml(
        path,
        &json!({
            "schema_version": "engagement-operator-read-model-v1",
            "non_authority_notice": "Generated operator projection only; control truth lives under state/control/engagements.",
            "engagement_id": engagement_id,
            "status": status,
            "refs": refs,
            "updated_at": now_rfc3339()?,
        }),
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    struct TempRepo {
        root: PathBuf,
        octon: PathBuf,
    }

    impl TempRepo {
        fn new(name: &str) -> Self {
            let unique = SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .expect("clock should be valid")
                .as_nanos();
            let root = std::env::temp_dir().join(format!(
                "octon-engagement-{name}-{}-{unique}",
                std::process::id()
            ));
            let octon = root.join(".octon");
            fs::create_dir_all(&octon).expect("octon dir");
            seed_repo(&root).expect("seed repo");
            Self { root, octon }
        }
    }

    impl Drop for TempRepo {
        fn drop(&mut self) {
            let _ = fs::remove_dir_all(&self.root);
        }
    }

    #[test]
    fn engagement_compiler_prepares_candidate_under_engagement_control() {
        let repo = TempRepo::new("candidate");
        let start = start_engagement(
            &repo.octon,
            None,
            Some("Ship a small change".to_string()),
            true,
        )
        .expect("start");
        let engagement_id = start.engagement_id;

        profile_engagement(&repo.octon, &engagement_id).expect("profile");
        plan_engagement(&repo.octon, &engagement_id).expect("plan");
        let armed = arm_engagement(&repo.octon, &engagement_id, DEFAULT_WORKFLOW_ID).expect("arm");

        let candidate_ref = armed
            .refs
            .get("run_contract_candidate_ref")
            .expect("candidate ref");
        assert!(
            candidate_ref.starts_with(".octon/state/control/engagements/"),
            "candidate should stay under engagement control state: {candidate_ref}"
        );
        assert!(
            candidate_ref.ends_with("/run-contract.candidate.yml"),
            "candidate should use candidate filename: {candidate_ref}"
        );
        assert!(
            !repo
                .root
                .join(".octon/state/control/execution/runs")
                .exists(),
            "arm must not materialize canonical run roots"
        );
        assert!(
            repo.root
                .join(".octon/instance/locality/project-profile.yml")
                .is_file(),
            "profile should write machine-readable project profile"
        );
        assert!(
            repo.root
                .join(".octon/state/control/engagements")
                .join(&engagement_id)
                .join("connectors/posture.yml")
                .is_file(),
            "arm should write machine-readable connector posture selection"
        );
    }

    #[test]
    fn run_start_candidate_materializes_only_on_start_path() {
        let repo = TempRepo::new("materialize");
        let engagement_id =
            start_engagement(&repo.octon, None, Some("Prepare run".to_string()), true)
                .expect("start")
                .engagement_id;
        profile_engagement(&repo.octon, &engagement_id).expect("profile");
        plan_engagement(&repo.octon, &engagement_id).expect("plan");
        let armed = arm_engagement(&repo.octon, &engagement_id, DEFAULT_WORKFLOW_ID).expect("arm");
        let candidate = repo
            .root
            .join(armed.refs.get("run_contract_candidate_ref").unwrap());

        let blocked = materialize_run_candidate_for_start(&repo.octon, &candidate)
            .expect_err("unresolved Decision Request should block candidate materialization");
        assert!(
            blocked.to_string().contains("unresolved Decision Requests"),
            "candidate must fail closed until the Decision Request is resolved: {blocked}"
        );
        decide_engagement(
            &repo.octon,
            &engagement_id,
            &format!("{engagement_id}-authorize-run"),
            "approval",
        )
        .expect("decision approval");
        let descriptor =
            materialize_run_candidate_for_start(&repo.octon, &candidate).expect("materialize");

        assert_eq!(descriptor.workflow_id, DEFAULT_WORKFLOW_ID);
        assert!(
            repo.root
                .join(".octon/state/control/execution/runs")
                .join(&descriptor.run_id)
                .join("run-contract.yml")
                .is_file(),
            "run start candidate path should create the canonical run contract"
        );
    }

    fn seed_repo(root: &Path) -> Result<()> {
        write_yaml(
            &root.join(".octon/instance/charter/workspace.yml"),
            &json!({
                "schema_version": "workspace-charter-v1",
                "workspace_charter_id": "workspace-charter://test",
                "version": "1.0.0"
            }),
        )?;
        fs::write(
            root.join(".octon/instance/charter/workspace.md"),
            "# Test Workspace\n",
        )?;
        write_yaml(
            &root.join(COMPILER_POLICY_REF),
            &json!({"schema_version": "engagement-work-package-compiler-governance-v1"}),
        )?;
        write_yaml(
            &root.join(EVIDENCE_PROFILES_POLICY_REF),
            &json!({"schema_version": "engagement-evidence-profiles-policy-v1"}),
        )?;
        write_yaml(
            &root.join(PREFLIGHT_EVIDENCE_LANE_POLICY_REF),
            &json!({"schema_version": "preflight-evidence-lane-policy-v1"}),
        )?;
        write_yaml(
            &root.join(CONNECTOR_POSTURE_REF),
            &json!({
                "schema_version": "engagement-connector-posture-v1",
                "policy_id": "engagement-connector-posture",
                "connector_classes": []
            }),
        )?;
        write_yaml(
            &root.join(".octon/framework/orchestration/runtime/workflows/manifest.yml"),
            &json!({
                "workflows": [
                    {
                        "id": DEFAULT_WORKFLOW_ID,
                        "path": "tasks/agent-led-happy-path/"
                    }
                ]
            }),
        )?;
        write_yaml(
            &root.join(".octon/framework/engine/runtime/crates/Cargo.toml"),
            &json!({"package": {"name": "fixture"}}),
        )?;
        Ok(())
    }
}
