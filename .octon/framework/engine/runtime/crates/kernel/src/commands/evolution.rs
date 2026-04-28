use crate::{AmendCmd, EvolveCmd, PromoteCmd, RecertifyCmd};
use anyhow::{anyhow, bail, Context, Result};
use serde::Serialize;
use serde_json::{json, Value};
use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};

const DEFAULT_CANDIDATE_ID: &str = "evolution-candidate-v5-validation";
const DEFAULT_PROMOTION_ID: &str = "evolution-promotion-v5-validation";
const DEFAULT_RECERTIFICATION_ID: &str = "evolution-recertification-v5-validation";

#[derive(Debug, Clone, Serialize)]
struct EvolutionReport {
    command: &'static str,
    status: String,
    program_id: Option<String>,
    subject_id: Option<String>,
    refs: BTreeMap<String, String>,
    outcome: String,
    next_command: String,
    blockers: Vec<String>,
}

pub(super) fn cmd_evolve(cmd: EvolveCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let report = match cmd {
        EvolveCmd::Observe(args) => observe(&octon_dir, &args.program_id)?,
        EvolveCmd::Candidates(args) => list_candidates(&octon_dir, &args.program_id)?,
        EvolveCmd::Inspect(args) => {
            inspect_candidate(&octon_dir, &args.program_id, &args.candidate)?
        }
        EvolveCmd::Classify(args) => {
            classify_candidate(&octon_dir, &args.program_id, &args.candidate)?
        }
        EvolveCmd::Simulate(args) => linked_record(
            &octon_dir,
            &args.program_id,
            &args.candidate,
            "simulate",
            "simulation_ref",
        )?,
        EvolveCmd::Lab(args) => linked_record(
            &octon_dir,
            &args.program_id,
            &args.candidate,
            "lab",
            "lab_gate_ref",
        )?,
        EvolveCmd::Propose(args) => {
            propose_candidate(&octon_dir, &args.program_id, &args.candidate)?
        }
        EvolveCmd::Decide(args) => {
            inspect_decision(&octon_dir, &args.program_id, &args.proposal_or_request)?
        }
        EvolveCmd::Promote(args) => {
            inspect_promotion_by_proposal(&octon_dir, &args.program_id, &args.proposal)?
        }
        EvolveCmd::Recertify(args) => recertification_status(&octon_dir, &args.program_id)?,
        EvolveCmd::Rollback(args) => print_named_state(
            &octon_dir,
            &args.program_id,
            "rollback",
            control_root(&octon_dir).join("rollbacks/evolution-rollback-v5-validation.yml"),
        )?,
        EvolveCmd::Retire(args) => print_named_state(
            &octon_dir,
            &args.program_id,
            "retire",
            control_root(&octon_dir).join("retirements/evolution-retirement-v5-validation.yml"),
        )?,
        EvolveCmd::Ledger(args) => print_named_state(
            &octon_dir,
            &args.program_id,
            "ledger",
            control_root(&octon_dir).join("ledger.yml"),
        )?,
    };
    print_report(&report)
}

pub(super) fn cmd_amend(cmd: AmendCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let report = match cmd {
        AmendCmd::Request(args) => linked_record(
            &octon_dir,
            &args.program_id,
            &args.candidate,
            "amend-request",
            "constitutional_amendment_request_ref",
        )
        .and_then(|report| enforce_amendment_gate(&octon_dir, &args.program_id, report))?,
        AmendCmd::Inspect(args) => print_named_state(
            &octon_dir,
            &args.program_id,
            "amend-inspect",
            control_root(&octon_dir)
                .join("amendment-requests")
                .join(format!("{}.yml", args.request_id)),
        )?,
    };
    print_report(&report)
}

pub(super) fn cmd_promote(cmd: PromoteCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let report = match cmd {
        PromoteCmd::Inspect(args) => {
            inspect_promotion(&octon_dir, &args.program_id, &args.promotion_id)?
        }
        PromoteCmd::Apply(args) => {
            apply_promotion(&octon_dir, &args.program_id, &args.promotion_id)?
        }
        PromoteCmd::Receipt(args) => print_named_state(
            &octon_dir,
            &args.program_id,
            "promote-receipt",
            evidence_root(&octon_dir)
                .join("promotions")
                .join(&args.promotion_id)
                .join("receipt.yml"),
        )?,
    };
    print_report(&report)
}

pub(super) fn cmd_recertify(cmd: RecertifyCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let report = match cmd {
        RecertifyCmd::Status(args) => recertification_status(&octon_dir, &args.program_id)?,
        RecertifyCmd::Run(args) => recertification_dry_run(&octon_dir, &args.program_id)?,
    };
    print_report(&report)
}

fn observe(octon_dir: &Path, program_id: &str) -> Result<EvolutionReport> {
    ensure_program(octon_dir, program_id)?;
    let refs = standard_refs(program_id);
    Ok(report(
        "evolve-observe",
        "candidate_available",
        Some(program_id.to_string()),
        Some(DEFAULT_CANDIDATE_ID.to_string()),
        refs,
        "ready_for_candidate_review",
        format!("octon evolve inspect {DEFAULT_CANDIDATE_ID}"),
        vec![],
    ))
}

fn list_candidates(octon_dir: &Path, program_id: &str) -> Result<EvolutionReport> {
    ensure_program(octon_dir, program_id)?;
    let mut refs = standard_refs(program_id);
    let candidates = collect_yaml_files(&control_root(octon_dir).join("candidates"))?;
    refs.insert("candidate_count".to_string(), candidates.len().to_string());
    println!(
        "{}",
        serde_json::to_string_pretty(&json!({
            "schema_version": "evolution-candidate-list-v1",
            "authority_notice": "Candidates are control records; generated views, proposal packets, evidence distillation, chat, simulations, and labs are not authority.",
            "program_id": program_id,
            "candidates": candidates
        }))?
    );
    Ok(report(
        "evolve-candidates",
        "listed",
        Some(program_id.to_string()),
        None,
        refs,
        "ready",
        format!("octon evolve inspect {DEFAULT_CANDIDATE_ID}"),
        vec![],
    ))
}

fn inspect_candidate(
    octon_dir: &Path,
    program_id: &str,
    candidate_id: &str,
) -> Result<EvolutionReport> {
    ensure_program(octon_dir, program_id)?;
    validate_id(candidate_id, "candidate_id")?;
    let path = candidate_path(octon_dir, candidate_id);
    let candidate = read_yaml_value(&path)?;
    println!("{}", serde_json::to_string_pretty(&candidate)?);
    let mut blockers = Vec::new();
    if candidate
        .get("source_evidence_refs")
        .and_then(Value::as_array)
        .map(|refs| refs.is_empty())
        .unwrap_or(true)
    {
        blockers.push("EVOLUTION_SOURCE_EVIDENCE_REQUIRED".to_string());
    }
    if candidate
        .get("candidate_authorizes_change")
        .and_then(Value::as_bool)
        .unwrap_or(true)
    {
        blockers.push("EVOLUTION_SELF_AUTHORIZATION_DENIED".to_string());
    }
    Ok(report(
        "evolve-inspect",
        if blockers.is_empty() {
            "valid"
        } else {
            "blocked"
        },
        Some(program_id.to_string()),
        Some(candidate_id.to_string()),
        standard_refs(program_id),
        if blockers.is_empty() {
            "ready"
        } else {
            "blocked"
        },
        format!("octon evolve simulate {candidate_id}"),
        blockers,
    ))
}

fn classify_candidate(
    octon_dir: &Path,
    program_id: &str,
    candidate_id: &str,
) -> Result<EvolutionReport> {
    ensure_program(octon_dir, program_id)?;
    let candidate = read_yaml_value(&candidate_path(octon_dir, candidate_id))?;
    println!(
        "{}",
        serde_json::to_string_pretty(&json!({
            "schema_version": "evolution-candidate-classification-v1",
            "candidate_id": candidate_id,
            "risk_materiality": candidate.get("risk_materiality"),
            "authority_impact": candidate.get("authority_impact"),
            "constitutional_impact": candidate.get("constitutional_impact"),
            "runtime_impact": candidate.get("runtime_impact"),
            "support_target_impact": candidate.get("support_target_impact"),
            "generated_effective_impact": candidate.get("generated_effective_impact"),
            "evidence_obligation_impact": candidate.get("evidence_obligation_impact"),
            "required_proof_classes": candidate.get("required_proof_classes"),
            "classification_authorizes_change": false
        }))?
    );
    Ok(report(
        "evolve-classify",
        "classified",
        Some(program_id.to_string()),
        Some(candidate_id.to_string()),
        standard_refs(program_id),
        "requires_decision_before_promotion",
        format!("octon evolve propose {candidate_id}"),
        vec![],
    ))
}

fn linked_record(
    octon_dir: &Path,
    program_id: &str,
    candidate_id: &str,
    command: &'static str,
    link_field: &str,
) -> Result<EvolutionReport> {
    ensure_program(octon_dir, program_id)?;
    let candidate = read_yaml_value(&candidate_path(octon_dir, candidate_id))?;
    let link = candidate
        .get(link_field)
        .and_then(Value::as_str)
        .ok_or_else(|| anyhow!("EVOLUTION_LINKED_RECORD_MISSING: {link_field}"))?;
    let path = repo_path(octon_dir, link);
    let value = read_yaml_value(&path)?;
    println!("{}", serde_json::to_string_pretty(&value)?);
    let mut blockers = Vec::new();
    if value
        .get("simulation_success_approves_change")
        .and_then(Value::as_bool)
        .unwrap_or(false)
    {
        blockers.push("EVOLUTION_SIMULATION_APPROVAL_DENIED".to_string());
    }
    if value
        .get("lab_success_approves_change")
        .and_then(Value::as_bool)
        .unwrap_or(false)
    {
        blockers.push("EVOLUTION_LAB_APPROVAL_DENIED".to_string());
    }
    Ok(report(
        command,
        if blockers.is_empty() {
            "valid"
        } else {
            "blocked"
        },
        Some(program_id.to_string()),
        Some(candidate_id.to_string()),
        BTreeMap::from([(link_field.to_string(), link.to_string())]),
        if blockers.is_empty() {
            "ready"
        } else {
            "blocked"
        },
        format!("octon evolve propose {candidate_id}"),
        blockers,
    ))
}

fn propose_candidate(
    octon_dir: &Path,
    program_id: &str,
    candidate_id: &str,
) -> Result<EvolutionReport> {
    ensure_program(octon_dir, program_id)?;
    let candidate = read_yaml_value(&candidate_path(octon_dir, candidate_id))?;
    let proposal_ref = yaml_string(&candidate, "proposal_ref")?;
    let mut blockers = Vec::new();
    if candidate
        .get("source_evidence_refs")
        .and_then(Value::as_array)
        .map(|refs| refs.is_empty())
        .unwrap_or(true)
    {
        blockers.push("EVOLUTION_SOURCE_EVIDENCE_REQUIRED".to_string());
    }
    println!(
        "{}",
        serde_json::to_string_pretty(&json!({
            "schema_version": "evolution-proposal-compiler-report-v1",
            "candidate_id": candidate_id,
            "proposal_ref": proposal_ref,
            "compiled_packet_is_authority": false,
            "compiled_packet_promotes_change": false,
            "blockers": blockers
        }))?
    );
    Ok(report(
        "evolve-propose",
        if blockers.is_empty() {
            "compiled_non_authoritative"
        } else {
            "blocked"
        },
        Some(program_id.to_string()),
        Some(candidate_id.to_string()),
        BTreeMap::from([("proposal_ref".to_string(), proposal_ref.to_string())]),
        if blockers.is_empty() {
            "requires_decision"
        } else {
            "blocked"
        },
        "octon promote inspect --promotion-id evolution-promotion-v5-validation".to_string(),
        blockers,
    ))
}

fn inspect_decision(octon_dir: &Path, program_id: &str, subject: &str) -> Result<EvolutionReport> {
    ensure_program(octon_dir, program_id)?;
    let candidates = [
        control_root(octon_dir)
            .join("decisions")
            .join(format!("{subject}.yml")),
        control_root(octon_dir)
            .join("amendment-requests")
            .join(format!("{subject}.yml")),
        control_root(octon_dir)
            .join("promotions")
            .join(format!("{subject}.yml")),
    ];
    let path = candidates
        .iter()
        .find(|path| path.is_file())
        .cloned()
        .ok_or_else(|| anyhow!("EVOLUTION_DECISION_REQUIRED: {subject}"))?;
    print_named_state(octon_dir, program_id, "evolve-decide", path)
}

fn inspect_promotion_by_proposal(
    octon_dir: &Path,
    program_id: &str,
    proposal: &str,
) -> Result<EvolutionReport> {
    ensure_program(octon_dir, program_id)?;
    let request = read_yaml_value(&promotion_path(octon_dir, DEFAULT_PROMOTION_ID))?;
    let proposal_ref = request
        .get("proposal_ref")
        .and_then(Value::as_str)
        .unwrap_or_default();
    if !proposal_ref.ends_with(proposal) && !proposal.contains(proposal_ref) {
        bail!("EVOLUTION_PROMOTION_FOR_PROPOSAL_MISSING: {proposal}");
    }
    inspect_promotion(octon_dir, program_id, DEFAULT_PROMOTION_ID)
}

fn inspect_promotion(
    octon_dir: &Path,
    program_id: &str,
    promotion_id: &str,
) -> Result<EvolutionReport> {
    ensure_program(octon_dir, program_id)?;
    validate_id(promotion_id, "promotion_id")?;
    let promotion = read_yaml_value(&promotion_path(octon_dir, promotion_id))?;
    println!("{}", serde_json::to_string_pretty(&promotion)?);
    let blockers = promotion_blockers(octon_dir, &promotion)?;
    Ok(report(
        "promote-inspect",
        if blockers.is_empty() {
            "ready"
        } else {
            "requires_decision"
        },
        Some(program_id.to_string()),
        Some(promotion_id.to_string()),
        standard_refs(program_id),
        if blockers.is_empty() {
            "ready"
        } else {
            "blocked"
        },
        format!("octon promote apply --promotion-id {promotion_id}"),
        blockers,
    ))
}

fn apply_promotion(
    octon_dir: &Path,
    program_id: &str,
    promotion_id: &str,
) -> Result<EvolutionReport> {
    ensure_program(octon_dir, program_id)?;
    let promotion = read_yaml_value(&promotion_path(octon_dir, promotion_id))?;
    let mut blockers = promotion_blockers(octon_dir, &promotion)?;
    let proposal_status = proposal_status(octon_dir, &promotion)?;
    if proposal_status == "implemented" && blockers.is_empty() {
        return Ok(report(
            "promote-apply",
            "already_applied",
            Some(program_id.to_string()),
            Some(promotion_id.to_string()),
            standard_refs(program_id),
            "recertification_required",
            "octon recertify run".to_string(),
            vec![],
        ));
    }
    if proposal_status != "accepted" {
        blockers.push(format!(
            "EVOLUTION_PROPOSAL_STATUS_NOT_ACCEPTED:{proposal_status}"
        ));
    }
    Ok(report(
        "promote-apply",
        if blockers.is_empty() {
            "ready_to_apply"
        } else {
            "blocked"
        },
        Some(program_id.to_string()),
        Some(promotion_id.to_string()),
        standard_refs(program_id),
        if blockers.is_empty() {
            "requires_authorized_run_for_material_change"
        } else {
            "blocked"
        },
        "octon recertify run".to_string(),
        blockers,
    ))
}

fn recertification_status(octon_dir: &Path, program_id: &str) -> Result<EvolutionReport> {
    print_named_state(
        octon_dir,
        program_id,
        "recertify-status",
        control_root(octon_dir)
            .join("recertifications")
            .join(format!("{DEFAULT_RECERTIFICATION_ID}.yml")),
    )
}

fn recertification_dry_run(octon_dir: &Path, program_id: &str) -> Result<EvolutionReport> {
    ensure_program(octon_dir, program_id)?;
    let required = [
        "framework/engine/runtime/spec/evolution-program-v1.schema.json",
        "framework/engine/runtime/spec/evolution-candidate-v1.schema.json",
        "framework/engine/runtime/spec/promotion-runtime-v1.md",
        "framework/engine/runtime/spec/recertification-runtime-v1.md",
        "framework/engine/runtime/spec/evolution-ledger-v1.schema.json",
        "instance/governance/evolution/programs/octon-self-evolution/program.yml",
        "state/control/evolution/ledger.yml",
        "state/evidence/evolution/promotions/evolution-promotion-v5-validation/receipt.yml",
    ];
    let mut blockers: Vec<String> = required
        .iter()
        .filter(|rel| !octon_dir.join(rel).is_file())
        .map(|rel| format!("EVOLUTION_RECERTIFICATION_REQUIRED_MISSING:{rel}"))
        .collect();
    if blockers.is_empty() {
        let request = read_yaml_value(
            &control_root(octon_dir)
                .join("recertification-requests")
                .join(format!("{DEFAULT_RECERTIFICATION_ID}.yml")),
        )?;
        if request
            .get("blocks_closure_until_terminal")
            .and_then(Value::as_bool)
            != Some(true)
        {
            blockers.push("EVOLUTION_RECERTIFICATION_REQUEST_MUST_BLOCK".to_string());
        }
        let recertification = read_yaml_value(
            &control_root(octon_dir)
                .join("recertifications")
                .join(format!("{DEFAULT_RECERTIFICATION_ID}.yml")),
        )?;
        if let Err(err) = validate_recertification_result(octon_dir, &recertification) {
            blockers.push(format!("EVOLUTION_RECERTIFICATION_INVALID:{err}"));
        }
    }
    Ok(report(
        "recertify-run",
        if blockers.is_empty() {
            "passed"
        } else {
            "blocked"
        },
        Some(program_id.to_string()),
        Some(DEFAULT_RECERTIFICATION_ID.to_string()),
        standard_refs(program_id),
        if blockers.is_empty() {
            "ready_for_closeout"
        } else {
            "blocked"
        },
        "octon evolve ledger".to_string(),
        blockers,
    ))
}

fn promotion_blockers(octon_dir: &Path, promotion: &Value) -> Result<Vec<String>> {
    let mut blockers = Vec::new();
    let proposal_status = proposal_status(octon_dir, promotion)?;
    if !matches!(proposal_status.as_str(), "accepted" | "implemented") {
        blockers.push(format!(
            "EVOLUTION_PROPOSAL_STATUS_NOT_PROMOTABLE:{proposal_status}"
        ));
    }
    if promotion
        .get("target_root_legality")
        .and_then(Value::as_str)
        != Some("valid")
    {
        blockers.push("EVOLUTION_PROMOTION_TARGET_ROOT_LEGALITY_INVALID".to_string());
    }
    if promotion
        .get("promotion_runtime_self_approves")
        .and_then(Value::as_bool)
        != Some(false)
    {
        blockers.push("EVOLUTION_PROMOTION_SELF_APPROVAL_DENIED".to_string());
    }
    let promotion_targets = promotion
        .get("declared_promotion_targets")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default();
    if promotion_targets.is_empty() {
        blockers.push("EVOLUTION_PROMOTION_TARGET_UNDECLARED".to_string());
    }
    for target in promotion_targets.iter().filter_map(Value::as_str) {
        if !legal_target_root(target) || target.contains("..") || target.starts_with('/') {
            blockers.push(format!("EVOLUTION_PROMOTION_TARGET_ILLEGAL:{target}"));
        }
        let target_path = repo_path(octon_dir, target);
        if target.ends_with('/') {
            if !target_path.is_dir() {
                blockers.push(format!("EVOLUTION_PROMOTION_TARGET_DIR_MISSING:{target}"));
            }
        } else if !target_path.is_file() {
            blockers.push(format!("EVOLUTION_PROMOTION_TARGET_FILE_MISSING:{target}"));
        }
    }
    let decision_refs = promotion
        .get("accepted_decision_refs")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default();
    if decision_refs.is_empty() {
        blockers.push("EVOLUTION_APPROVAL_GRANT_MISSING".to_string());
    }
    for decision in decision_refs.iter().filter_map(Value::as_str) {
        let path = repo_path(octon_dir, decision);
        if decision.starts_with(".octon/") && !path.exists() {
            blockers.push(format!("EVOLUTION_APPROVAL_REF_MISSING:{decision}"));
            continue;
        }
        if let Err(err) = validate_approval_or_decision_ref(&path) {
            blockers.push(format!("EVOLUTION_APPROVAL_REF_INVALID:{decision}:{err}"));
        }
    }
    if promotion
        .get("proposal_path_dependency_scan")
        .and_then(Value::as_str)
        != Some("pass")
    {
        blockers.push("EVOLUTION_PROPOSAL_PATH_DEPENDENCY".to_string());
    }
    if promotion
        .get("recertification_required")
        .and_then(Value::as_bool)
        != Some(true)
    {
        blockers.push("EVOLUTION_RECERTIFICATION_REQUIRED".to_string());
    }
    let evidence_root_ref = promotion
        .get("promotion_evidence_root")
        .and_then(Value::as_str)
        .unwrap_or_default();
    if evidence_root_ref.is_empty() || !repo_path(octon_dir, evidence_root_ref).is_dir() {
        blockers.push("EVOLUTION_PROMOTION_EVIDENCE_ROOT_MISSING".to_string());
    }
    let receipt_ref = format!("{evidence_root_ref}/receipt.yml");
    if evidence_root_ref.is_empty() || !repo_path(octon_dir, &receipt_ref).is_file() {
        blockers.push("EVOLUTION_PROMOTION_RECEIPT_MISSING".to_string());
    } else {
        let receipt = read_yaml_value(&repo_path(octon_dir, &receipt_ref))?;
        if receipt
            .get("receipt_authorizes_future_change")
            .and_then(Value::as_bool)
            != Some(false)
        {
            blockers.push("EVOLUTION_PROMOTION_RECEIPT_AUTHORITY_DENIED".to_string());
        }
        if receipt
            .get("non_authority_attestation")
            .and_then(|v| v.get("self_authorization_denied"))
            .and_then(Value::as_bool)
            != Some(true)
        {
            blockers.push("EVOLUTION_PROMOTION_RECEIPT_ATTESTATION_MISSING".to_string());
        }
    }
    if promotion.get("support_no_widening").and_then(Value::as_str) != Some("pass") {
        blockers.push("EVOLUTION_SUPPORT_NO_WIDENING_PROOF_MISSING".to_string());
    }
    if promotion
        .get("support_no_widening_evidence_refs")
        .and_then(Value::as_array)
        .map(|refs| refs.is_empty())
        .unwrap_or(true)
    {
        blockers.push("EVOLUTION_SUPPORT_NO_WIDENING_EVIDENCE_MISSING".to_string());
    }
    for proof in promotion
        .get("support_no_widening_evidence_refs")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter_map(Value::as_str)
    {
        if !repo_path(octon_dir, proof).exists() {
            blockers.push(format!(
                "EVOLUTION_SUPPORT_NO_WIDENING_EVIDENCE_MISSING:{proof}"
            ));
        }
    }
    let rollback_ref = promotion
        .get("rollback_or_retirement_posture_ref")
        .and_then(Value::as_str)
        .unwrap_or_default();
    if rollback_ref.is_empty() || !repo_path(octon_dir, rollback_ref).is_file() {
        blockers.push("EVOLUTION_ROLLBACK_OR_RETIREMENT_POSTURE_MISSING".to_string());
    }
    if let Err(err) = validate_lab_gate_for_candidate(octon_dir) {
        blockers.push(format!("EVOLUTION_LAB_GATE_INVALID:{err}"));
    }
    if promotion
        .get("durable_decision_refs")
        .and_then(Value::as_array)
        .map(|refs| refs.is_empty())
        .unwrap_or(true)
    {
        blockers.push("EVOLUTION_DURABLE_DECISION_REF_MISSING".to_string());
    }
    for durable_decision in promotion
        .get("durable_decision_refs")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter_map(Value::as_str)
    {
        if !repo_path(octon_dir, durable_decision).is_file() {
            blockers.push(format!(
                "EVOLUTION_DURABLE_DECISION_REF_MISSING:{durable_decision}"
            ));
        }
    }
    let recertification_request_ref = promotion
        .get("recertification_request_ref")
        .and_then(Value::as_str)
        .unwrap_or_default();
    if recertification_request_ref.is_empty()
        || !repo_path(octon_dir, recertification_request_ref).is_file()
    {
        blockers.push("EVOLUTION_RECERTIFICATION_REQUEST_MISSING".to_string());
    } else {
        let request = read_yaml_value(&repo_path(octon_dir, recertification_request_ref))?;
        if request
            .get("blocks_closure_until_terminal")
            .and_then(Value::as_bool)
            != Some(true)
        {
            blockers.push("EVOLUTION_RECERTIFICATION_REQUEST_MUST_BLOCK".to_string());
        }
    }
    let recertification_ref = promotion
        .get("recertification_ref")
        .and_then(Value::as_str)
        .unwrap_or_default();
    if recertification_ref.is_empty() || !repo_path(octon_dir, recertification_ref).is_file() {
        blockers.push("EVOLUTION_RECERTIFICATION_RESULT_MISSING".to_string());
    } else {
        let recertification = read_yaml_value(&repo_path(octon_dir, recertification_ref))?;
        if let Err(err) = validate_recertification_result(octon_dir, &recertification) {
            blockers.push(format!("EVOLUTION_RECERTIFICATION_INVALID:{err}"));
        }
    }
    if promotion
        .get("generated_projection_refresh_refs")
        .and_then(Value::as_array)
        .map(|refs| refs.is_empty())
        .unwrap_or(true)
    {
        blockers.push("EVOLUTION_GENERATED_REFRESH_REF_MISSING".to_string());
    }
    for generated_ref in promotion
        .get("generated_projection_refresh_refs")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter_map(Value::as_str)
    {
        if !repo_path(octon_dir, generated_ref).is_file() {
            blockers.push(format!(
                "EVOLUTION_GENERATED_REFRESH_REF_MISSING:{generated_ref}"
            ));
        }
    }
    let amendment = read_yaml_value(
        &control_root(octon_dir).join("amendment-requests/evolution-amendment-v5-validation.yml"),
    )?;
    if amendment
        .get("human_or_quorum_approval_required")
        .and_then(Value::as_bool)
        == Some(true)
        && amendment
            .get("approval_refs")
            .and_then(Value::as_array)
            .map(|refs| refs.is_empty())
            .unwrap_or(true)
    {
        blockers.push("EVOLUTION_AMENDMENT_APPROVAL_REQUIRED".to_string());
    }
    if amendment
        .get("post_promotion_recertification_required")
        .and_then(Value::as_bool)
        != Some(true)
    {
        blockers.push("EVOLUTION_AMENDMENT_RECERTIFICATION_REQUIRED".to_string());
    }
    for approval in amendment
        .get("approval_refs")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter_map(Value::as_str)
    {
        let path = repo_path(octon_dir, approval);
        if let Err(err) = validate_approval_or_decision_ref(&path) {
            blockers.push(format!(
                "EVOLUTION_AMENDMENT_APPROVAL_INVALID:{approval}:{err}"
            ));
        }
    }
    Ok(blockers)
}

fn enforce_amendment_gate(
    octon_dir: &Path,
    program_id: &str,
    mut report: EvolutionReport,
) -> Result<EvolutionReport> {
    ensure_program(octon_dir, program_id)?;
    let amendment_path =
        control_root(octon_dir).join("amendment-requests/evolution-amendment-v5-validation.yml");
    let amendment = read_yaml_value(&amendment_path)?;
    if amendment
        .get("human_or_quorum_approval_required")
        .and_then(Value::as_bool)
        == Some(true)
        && amendment
            .get("approval_refs")
            .and_then(Value::as_array)
            .map(|refs| refs.is_empty())
            .unwrap_or(true)
    {
        report
            .blockers
            .push("EVOLUTION_AMENDMENT_APPROVAL_REQUIRED".to_string());
    }
    if amendment
        .get("post_promotion_recertification_required")
        .and_then(Value::as_bool)
        != Some(true)
    {
        report
            .blockers
            .push("EVOLUTION_AMENDMENT_RECERTIFICATION_REQUIRED".to_string());
    }
    for approval in amendment
        .get("approval_refs")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter_map(Value::as_str)
    {
        let path = repo_path(octon_dir, approval);
        if let Err(err) = validate_approval_or_decision_ref(&path) {
            report.blockers.push(format!(
                "EVOLUTION_AMENDMENT_APPROVAL_INVALID:{approval}:{err}"
            ));
        }
    }
    report.status = if report.blockers.is_empty() {
        "valid".to_string()
    } else {
        "blocked".to_string()
    };
    report.outcome = if report.blockers.is_empty() {
        "requires_promotion_gate".to_string()
    } else {
        "blocked".to_string()
    };
    report.refs.insert(
        "amendment_request_ref".to_string(),
        repo_ref(octon_dir, &amendment_path),
    );
    Ok(report)
}

fn validate_approval_or_decision_ref(path: &Path) -> Result<()> {
    let value = read_yaml_value(path)?;
    match value.get("schema_version").and_then(Value::as_str) {
        Some("authority-approval-request-v1") => {
            if value.get("status").and_then(Value::as_str) != Some("granted") {
                bail!("approval_request_not_granted");
            }
            if value.get("workflow_mode").and_then(Value::as_str) != Some("role-mediated")
                && value.get("workflow_mode").and_then(Value::as_str) != Some("human-only")
            {
                bail!("approval_request_workflow_mode_invalid");
            }
            validate_quorum_policy_ref(path, &value)?;
        }
        Some("authority-approval-grant-v1") => {
            if value.get("state").and_then(Value::as_str) != Some("active") {
                bail!("grant_not_active");
            }
            if value.get("issued_by").and_then(Value::as_str).is_none() {
                bail!("grant_issuer_missing");
            }
            validate_quorum_policy_ref(path, &value)?;
        }
        Some("self-evolution-decision-request-v1") => {
            let status = value.get("status").and_then(Value::as_str).unwrap_or("");
            let resolution = value
                .get("resolution")
                .and_then(Value::as_str)
                .unwrap_or("");
            if !matches!(status, "resolved_approved" | "accepted") || resolution != "approval" {
                bail!("decision_not_resolved");
            }
            if value
                .get("decision_request_authorizes_promotion")
                .and_then(Value::as_bool)
                != Some(false)
            {
                bail!("decision_claims_promotion_authority");
            }
            if value
                .get("decision_request_authorizes_material_execution")
                .and_then(Value::as_bool)
                != Some(false)
            {
                bail!("decision_claims_material_execution_authority");
            }
        }
        Some(other) => bail!("unsupported_schema:{other}"),
        None => bail!("schema_missing"),
    }
    Ok(())
}

fn validate_quorum_policy_ref(ref_path: &Path, value: &Value) -> Result<()> {
    let Some(policy_ref) = value.get("quorum_policy_ref").and_then(Value::as_str) else {
        return Ok(());
    };
    let repo_root = ref_path
        .ancestors()
        .find(|path| path.join(".octon").is_dir())
        .ok_or_else(|| anyhow!("repo_root_missing"))?;
    let policy = read_yaml_value(&repo_root.join(policy_ref))?;
    if policy.get("schema_version").and_then(Value::as_str) != Some("authority-quorum-policy-v1")
        || policy.get("policy_id").and_then(Value::as_str).is_none()
        || policy.get("policy_ref").and_then(Value::as_str).is_none()
        || policy
            .get("quorum_levels")
            .and_then(Value::as_object)
            .map(|levels| levels.is_empty())
            .unwrap_or(true)
    {
        bail!("quorum_policy_invalid");
    }
    Ok(())
}

fn validate_lab_gate_for_candidate(octon_dir: &Path) -> Result<()> {
    let candidate = read_yaml_value(&candidate_path(octon_dir, DEFAULT_CANDIDATE_ID))?;
    let lab = read_yaml_value(
        &control_root(octon_dir).join("lab-gates/evolution-lab-gate-v5-validation.yml"),
    )?;
    if lab.get("result").and_then(Value::as_str) != Some("passed") {
        bail!("lab_gate_not_passed");
    }
    if lab
        .get("lab_success_approves_change")
        .and_then(Value::as_bool)
        != Some(false)
    {
        bail!("lab_success_claims_approval");
    }
    if candidate.get("risk_materiality").and_then(Value::as_str) == Some("constitutional") {
        if lab
            .get("replay_refs")
            .and_then(Value::as_array)
            .map(|refs| refs.is_empty())
            .unwrap_or(true)
        {
            bail!("constitutional_candidate_replay_required");
        }
        if lab
            .get("shadow_run_refs")
            .and_then(Value::as_array)
            .map(|refs| refs.is_empty())
            .unwrap_or(true)
        {
            bail!("constitutional_candidate_shadow_run_required");
        }
    }
    for field in [
        "replay_refs",
        "shadow_run_refs",
        "rollback_simulation_refs",
        "generated_effective_freshness_refs",
        "evidence_completeness_refs",
        "evidence_refs",
    ] {
        for path_ref in lab
            .get(field)
            .and_then(Value::as_array)
            .into_iter()
            .flatten()
            .filter_map(Value::as_str)
        {
            if !repo_path(octon_dir, path_ref).exists() {
                bail!("lab_ref_missing:{path_ref}");
            }
        }
    }
    Ok(())
}

fn validate_recertification_result(octon_dir: &Path, recertification: &Value) -> Result<()> {
    if recertification.get("status").and_then(Value::as_str) != Some("passed") {
        bail!("not_passed");
    }
    if recertification
        .get("failure_blocks_closure")
        .and_then(Value::as_bool)
        != Some(true)
    {
        bail!("failure_does_not_block");
    }
    if recertification
        .get("evidence_refs")
        .and_then(Value::as_array)
        .map(|refs| refs.is_empty())
        .unwrap_or(true)
    {
        bail!("evidence_refs_missing");
    }
    let required = [
        "authority_placement",
        "root_boundaries",
        "runtime_authorization_coverage",
        "support_target_claims",
        "capability_pack_routes",
        "connector_admissions",
        "generated_effective_handles",
        "context_pack_behavior",
        "run_lifecycle",
        "evidence_completeness",
        "rollback_posture",
        "operator_read_model_non_authority",
        "documentation_runtime_consistency",
        "validator_health",
        "proof_plane_completeness",
    ];
    for field in required {
        let value = recertification.get(field).and_then(Value::as_str);
        let passed = if field == "validator_health" {
            matches!(value, Some("passed") | Some("passed-by-cli-dry-run"))
        } else {
            value == Some("passed")
        };
        if !passed {
            bail!("dimension_not_passed:{field}");
        }
    }
    for evidence_ref in recertification
        .get("evidence_refs")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter_map(Value::as_str)
    {
        if !repo_path(octon_dir, evidence_ref).exists() {
            bail!("recertification_evidence_missing:{evidence_ref}");
        }
    }
    Ok(())
}

fn legal_target_root(target: &str) -> bool {
    matches!(
        target,
        t if t.starts_with(".octon/framework/")
            || t.starts_with(".octon/instance/")
            || t.starts_with(".octon/state/control/")
            || t.starts_with(".octon/state/evidence/")
            || t.starts_with(".octon/state/continuity/")
            || t.starts_with(".octon/generated/")
    )
}

fn proposal_status(octon_dir: &Path, promotion: &Value) -> Result<String> {
    let _ = octon_dir;
    Ok(promotion
        .get("proposal_status")
        .and_then(Value::as_str)
        .unwrap_or("unknown")
        .to_string())
}

fn print_named_state(
    octon_dir: &Path,
    program_id: &str,
    command: &'static str,
    path: PathBuf,
) -> Result<EvolutionReport> {
    ensure_program(octon_dir, program_id)?;
    let value = read_yaml_value(&path)?;
    println!("{}", serde_json::to_string_pretty(&value)?);
    Ok(report(
        command,
        "read",
        Some(program_id.to_string()),
        path.file_stem()
            .and_then(|stem| stem.to_str())
            .map(ToString::to_string),
        BTreeMap::from([("state_ref".to_string(), repo_ref(octon_dir, &path))]),
        "non_authoritative_inspection",
        "octon evolve ledger".to_string(),
        vec![],
    ))
}

fn ensure_program(octon_dir: &Path, program_id: &str) -> Result<()> {
    validate_id(program_id, "program_id")?;
    let program = repo_root(octon_dir)
        .join(".octon/instance/governance/evolution/programs")
        .join(program_id)
        .join("program.yml");
    if !program.is_file() {
        bail!("EVOLUTION_PROGRAM_MISSING: {}", program.display());
    }
    Ok(())
}

fn candidate_path(octon_dir: &Path, candidate_id: &str) -> PathBuf {
    control_root(octon_dir)
        .join("candidates")
        .join(format!("{candidate_id}.yml"))
}

fn promotion_path(octon_dir: &Path, promotion_id: &str) -> PathBuf {
    control_root(octon_dir)
        .join("promotions")
        .join(format!("{promotion_id}.yml"))
}

fn control_root(octon_dir: &Path) -> PathBuf {
    repo_root(octon_dir).join(".octon/state/control/evolution")
}

fn evidence_root(octon_dir: &Path) -> PathBuf {
    repo_root(octon_dir).join(".octon/state/evidence/evolution")
}

fn repo_root(octon_dir: &Path) -> &Path {
    octon_dir.parent().unwrap_or(octon_dir)
}

fn repo_path(octon_dir: &Path, rel: &str) -> PathBuf {
    let root = repo_root(octon_dir);
    if let Some(stripped) = rel.strip_prefix('/') {
        root.join(stripped)
    } else {
        root.join(rel)
    }
}

fn repo_ref(octon_dir: &Path, path: &Path) -> String {
    path.strip_prefix(repo_root(octon_dir))
        .unwrap_or(path)
        .display()
        .to_string()
}

fn standard_refs(program_id: &str) -> BTreeMap<String, String> {
    BTreeMap::from([
        (
            "program_ref".to_string(),
            format!(".octon/instance/governance/evolution/programs/{program_id}/program.yml"),
        ),
        (
            "ledger_ref".to_string(),
            ".octon/state/control/evolution/ledger.yml".to_string(),
        ),
        (
            "evidence_root".to_string(),
            ".octon/state/evidence/evolution".to_string(),
        ),
    ])
}

fn collect_yaml_files(root: &Path) -> Result<Vec<String>> {
    if !root.is_dir() {
        return Ok(Vec::new());
    }
    let mut out = Vec::new();
    for entry in fs::read_dir(root).with_context(|| format!("read {}", root.display()))? {
        let entry = entry?;
        let path = entry.path();
        if path.extension().and_then(|ext| ext.to_str()) == Some("yml") {
            out.push(path.display().to_string());
        }
    }
    out.sort();
    Ok(out)
}

fn read_yaml_value(path: &Path) -> Result<Value> {
    let text = fs::read_to_string(path).with_context(|| format!("read {}", path.display()))?;
    Ok(serde_yaml::from_str(&text).with_context(|| format!("parse {}", path.display()))?)
}

fn yaml_string<'a>(value: &'a Value, field: &str) -> Result<&'a str> {
    value
        .get(field)
        .and_then(Value::as_str)
        .ok_or_else(|| anyhow!("missing string field `{field}`"))
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

fn report(
    command: &'static str,
    status: &str,
    program_id: Option<String>,
    subject_id: Option<String>,
    refs: BTreeMap<String, String>,
    outcome: &str,
    next_command: String,
    blockers: Vec<String>,
) -> EvolutionReport {
    EvolutionReport {
        command,
        status: status.to_string(),
        program_id,
        subject_id,
        refs,
        outcome: outcome.to_string(),
        next_command,
        blockers,
    }
}

fn print_report(report: &EvolutionReport) -> Result<()> {
    println!("{}", serde_json::to_string_pretty(report)?);
    Ok(())
}
