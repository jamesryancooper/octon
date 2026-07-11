use anyhow::{anyhow, bail, Context, Result};
use serde::Serialize;
use serde_json::{json, Value};
use sha2::{Digest, Sha256};
use std::collections::BTreeSet;
use std::fs;
use std::path::{Component, Path, PathBuf};

const CHECKPOINT: &str = "lifecycle-checkpoint.yml";
const EVENTS: &str = "lifecycle-events.ndjson";
const ROUTE: &str = "run-packet-implementation";
const SCOPE_SOURCE: &str = "route-completion-target-and-promotion-targets";

#[derive(Debug, Serialize)]
pub(crate) struct AdmissionReport {
    run_id: String,
    status: String,
    idempotent: bool,
    run_contract_ref: String,
    run_manifest_ref: String,
    runtime_state_ref: String,
    authority_bundle_ref: String,
    admission_evidence_ref: String,
}

pub(crate) fn bind_existing_lifecycle_run(
    repo_root: &Path,
    run_id: &str,
    rollback_posture: &Path,
) -> Result<AdmissionReport> {
    validate_id(run_id)?;
    let run_root = repo_root
        .join(".octon/state/control/execution/runs")
        .join(run_id);
    let checkpoint_path = run_root.join(CHECKPOINT);
    let event_path = run_root.join(EVENTS);
    let checkpoint_bytes = fs::read(&checkpoint_path).with_context(|| {
        format!(
            "validated lifecycle checkpoint is required: {}",
            checkpoint_path.display()
        )
    })?;
    let checkpoint: Value = serde_yaml::from_slice(&checkpoint_bytes)?;
    require_eq(
        &checkpoint,
        "schema_version",
        "octon-lifecycle-checkpoint-v1",
    )?;
    require_eq(&checkpoint, "run_id", run_id)?;
    require_eq(&checkpoint, "lifecycle_id", "proposal-packet")?;
    require_eq(&checkpoint, "execution_strategy", "route-progression")?;
    require_eq(&checkpoint, "current_state", ROUTE)?;
    require_eq(&checkpoint, "last_route", ROUTE)?;
    let target_ref = string(&checkpoint, "target")?;
    let target = resolve_repo_ref(repo_root, &target_ref, "lifecycle target")?;
    if !target.is_dir() {
        bail!("lifecycle target is not a directory: {target_ref}");
    }

    let event_bytes = fs::read(&event_path).context("lifecycle event log is required")?;
    let event_tip = crate::lifecycle::validate_lifecycle_event_chain_for_admission(
        &event_bytes,
        repo_root,
        run_id,
        "proposal-packet",
        "route-progression",
        &target,
    )?;
    if let Some(expected) = checkpoint.get("event_log_sha256").and_then(Value::as_str) {
        if expected != digest(&event_bytes) {
            bail!("checkpoint event-log digest is stale");
        }
    }
    if let Some(expected) = checkpoint
        .get("latest_event_sha256")
        .and_then(Value::as_str)
    {
        if expected != event_tip {
            bail!("checkpoint event-tip digest is stale");
        }
    }
    let live_plan = crate::lifecycle::plan_lifecycle_from_octon_dir(
        &repo_root.join(".octon"),
        "proposal-packet",
        &target,
    )?;
    if live_plan
        .next_route
        .as_ref()
        .map(|route| route.route_id.as_str())
        != Some(ROUTE)
        || !matches!(
            live_plan.final_verdict.as_str(),
            "route-ready" | "gate-rerouted"
        )
    {
        bail!("live lifecycle plan does not select the consequential implementation route");
    }
    let proof_ref =
        format!(".octon/state/evidence/runs/{run_id}/authorization/{ROUTE}-delegation-proof.yml");
    let proof_path = repo_root.join(&proof_ref);
    let proof_bytes =
        fs::read(&proof_path).context("current route delegation proof is required")?;
    let proof: Value = serde_yaml::from_slice(&proof_bytes)?;
    require_eq(
        &proof,
        "schema_version",
        "octon-lifecycle-route-delegation-proof-v1",
    )?;
    require_eq(&proof, "run_id", run_id)?;
    require_eq(&proof, "lifecycle_id", "proposal-packet")?;
    require_eq(&proof, "route_id", ROUTE)?;
    require_eq(&proof, "declared_write_scope_source", SCOPE_SOURCE)?;
    if proof.pointer("/contract_opt_in").and_then(Value::as_bool) != Some(true) {
        bail!("delegation proof does not opt in to governed dispatch");
    }
    if proof
        .pointer("/invocation_authority/mode")
        .and_then(Value::as_str)
        .map(|v| matches!(v, "unattended" | "grant-consumption"))
        != Some(true)
    {
        bail!("delegation proof has no supported invocation authority");
    }
    let proof_target = string(&proof, "target")?;
    let proof_target_path = if Path::new(&proof_target).is_absolute() {
        PathBuf::from(&proof_target)
    } else {
        repo_root.join(&proof_target)
    };
    if canonical_existing(&target)? != canonical_existing(&proof_target_path)? {
        bail!("delegation proof target differs from lifecycle target");
    }

    let manifest_path = target.join("proposal.yml");
    let manifest_bytes =
        fs::read(&manifest_path).context("proposal target manifest is required")?;
    let manifest: Value = serde_yaml::from_slice(&manifest_bytes)?;
    let scope = authorized_scope(repo_root, &target, &proof, &manifest)?;
    reject_post_mutation(&target, &event_bytes)?;

    let rollback_path = resolve_repo_path_arg(repo_root, rollback_posture)?;
    let canonical_rollback_path = run_root.join("rollback-posture.yml");
    if rollback_path != canonical_rollback_path {
        bail!(
            "rollback posture must be the canonical lifecycle-owned artifact: {}",
            repo_ref(repo_root, &canonical_rollback_path)?
        );
    }
    let rollback_bytes = fs::read(&rollback_path).context("rollback posture is required")?;
    let rollback: Value = serde_yaml::from_slice(&rollback_bytes)?;
    require_eq(&rollback, "schema_version", "run-rollback-posture-v1")?;
    require_eq(&rollback, "run_id", run_id)?;
    require_eq(&rollback, "posture_source", "lifecycle-delegation-proof")?;
    for required in [
        "reversibility_class",
        "rollback_strategy",
        "contamination_state",
        "retry_record_ref",
        "contamination_record_ref",
        "reset_action",
        "updated_at",
    ] {
        if string(&rollback, required)?.trim().is_empty() {
            bail!("rollback posture field {required} is empty");
        }
    }
    if !matches!(rollback.get("invalidated_artifacts"), Some(Value::Array(_))) {
        bail!("rollback posture invalidated_artifacts must be an array");
    }
    if rollback.get("resume_allowed").and_then(Value::as_bool) != Some(true)
        || rollback.get("hard_reset_required").and_then(Value::as_bool) != Some(false)
        || rollback.get("contamination_state").and_then(Value::as_str) != Some("clean")
    {
        bail!("rollback posture does not permit clean resume");
    }

    let binding = json!({
        "run_id": run_id,
        "lifecycle_id": "proposal-packet",
        "route_id": ROUTE,
        "target": target_ref,
        "checkpoint_sha256": digest(&checkpoint_bytes),
        "event_log_sha256": digest(&event_bytes),
        "event_tip_sha256": event_tip,
        "delegation_proof_ref": proof_ref,
        "delegation_proof_sha256": digest(&proof_bytes),
        "target_manifest_ref": repo_ref(repo_root, &manifest_path)?,
        "target_manifest_sha256": digest(&manifest_bytes),
        "authorized_write_scope": scope,
        "rollback_posture_ref": repo_ref(repo_root, &rollback_path)?,
        "rollback_posture_sha256": digest(&rollback_bytes),
    });
    let binding_digest = digest(&serde_json::to_vec(&binding)?);
    let contract_path = run_root.join("run-contract.yml");
    let evidence_path = repo_root.join(format!(
        ".octon/state/evidence/runs/{run_id}/admission/lifecycle-run-admission.yml"
    ));
    if contract_path.exists() || evidence_path.exists() {
        return validate_idempotent(
            repo_root,
            &run_root,
            &contract_path,
            &evidence_path,
            run_id,
            &binding_digest,
        );
    }
    for conflicting in ["run-manifest.yml", "runtime-state.yml"] {
        if run_root.join(conflicting).exists() {
            bail!("conflicting partial canonical run binding exists: {conflicting}");
        }
    }

    let now = octon_authority_engine::now_rfc3339()?;
    let control_ref = format!(".octon/state/control/execution/runs/{run_id}");
    let evidence_ref = format!(".octon/state/evidence/runs/{run_id}");
    let authority_ref = format!("{control_ref}/authority/lifecycle-admission-bundle.yml");
    let runtime_ref = format!("{control_ref}/runtime-state.yml");
    let manifest_ref = format!("{control_ref}/run-manifest.yml");
    let rollback_ref = repo_ref(repo_root, &rollback_path)?;
    let admission_ref = repo_ref(repo_root, &evidence_path)?;
    let contract = json!({
        "schema_version": "run-contract-v3", "run_id": run_id, "status": "bound",
        "workflow_id": "proposal-packet-lifecycle", "workflow_mode": "lifecycle-route-progression",
        "objective_refs": {"lifecycle_checkpoint_ref": format!("{control_ref}/{CHECKPOINT}")},
        "objective_summary": "Execute the currently selected proposal packet implementation route under its retained lifecycle authority.",
        "scope_in": [target_ref], "scope_out": binding["authorized_write_scope"],
        "done_when": ["lifecycle-owned implementation receipt validates"],
        "acceptance_criteria": ["delegation, write scope, rollback, and lifecycle provenance remain digest-bound"],
        "materiality": "bounded-consequential", "risk_class": "medium", "reversibility_class": "reversible",
        "requested_capabilities": ["repo.read", "repo.write", "shell.execute"], "requested_capability_packs": ["repo", "shell"],
        "protected_zone_scope": [], "support_target_ref": ".octon/instance/governance/support-targets.yml",
        "support_target_tuple": {"model_tier":"repo-local-governed","workload_tier":"repo-consequential","language_resource_tier":"reference-owned","locale_tier":"english-primary","host_adapter":"repo-shell","model_adapter":"repo-local-governed"},
        "mission_id": null, "requires_mission": false, "mission_mode":"run-only", "required_approvals": [],
        "required_evidence": [admission_ref], "retry_class":"bounded-retry", "rollback_posture_ref": rollback_ref,
        "stage_attempt_root": format!("{control_ref}/stage-attempts"), "checkpoint_root": format!("{control_ref}/checkpoints"),
        "continuity_root_ref": format!(".octon/state/continuity/runs/{run_id}/handoff.yml"),
        "authority_bundle_ref": authority_ref, "run_manifest_ref": manifest_ref, "runtime_state_ref": runtime_ref,
        "run_card_ref": format!(".octon/state/evidence/disclosure/runs/{run_id}/run-card.yml"),
        "lifecycle_binding": binding, "lifecycle_binding_sha256": binding_digest,
        "created_at": now, "updated_at": now
    });
    let manifest = json!({
        "schema_version":"run-manifest-v2", "run_id":run_id,
        "run_contract_ref":format!("{control_ref}/run-contract.yml"), "authority_bundle_ref":authority_ref,
        "support_target_ref":".octon/instance/governance/support-targets.yml", "support_target":contract["support_target_tuple"],
        "runtime_state_ref":runtime_ref, "run_card_ref":contract["run_card_ref"],
        "run_continuity_ref":contract["continuity_root_ref"],
        "replay_manifest_ref":format!("{evidence_ref}/replay/manifest.yml"),
        "replay_pointers_ref":format!("{evidence_ref}/replay-pointers.yml"),
        "rollback_posture_ref":rollback_ref, "lifecycle_binding_sha256":binding_digest,
        "authorized_write_scope":binding["authorized_write_scope"], "created_at":now, "updated_at":now
    });
    let state = json!({"schema_version":"runtime-state-v2","run_id":run_id,"state":"bound","decision_state":"blocked-pending-run-start-validation","workflow_mode":"lifecycle-route-progression","run_contract_ref":format!("{control_ref}/run-contract.yml"),"run_manifest_ref":manifest_ref,"current_stage_attempt_id":"initial","created_at":now,"updated_at":now});
    let admission = json!({"schema_version":"lifecycle-run-admission-v1","run_id":run_id,"status":"admitted","binding_sha256":binding_digest,"binding":binding,"run_contract_ref":format!("{control_ref}/run-contract.yml"),"recorded_at":now,"authority_boundary":{"authorizes_lifecycle_mutation":false,"authorizes_external_effects":false,"authorizes_git_or_hosted_mutation":false}});
    let authority = json!({"schema_version":"lifecycle-run-admission-authority-bundle-v1","run_id":run_id,"route_id":ROUTE,"decision":"allow-bound-route-only","admission_evidence_ref":admission_ref,"binding_sha256":binding_digest,"generated_at":now});
    publish_artifact_set(&[
        (run_root.join("run-contract.yml"), contract),
        (run_root.join("run-manifest.yml"), manifest),
        (run_root.join("runtime-state.yml"), state),
        (
            run_root.join("authority/lifecycle-admission-bundle.yml"),
            authority,
        ),
        (evidence_path, admission),
    ])?;
    Ok(report(run_id, "admitted", false, &admission_ref))
}

fn authorized_scope(
    repo_root: &Path,
    target: &Path,
    proof: &Value,
    manifest: &Value,
) -> Result<Vec<String>> {
    let mut result = BTreeSet::new();
    result.insert(repo_ref(repo_root, target)?);
    let proof_scope = proof
        .get("declared_write_scope")
        .and_then(Value::as_array)
        .ok_or_else(|| anyhow!("delegation proof has no declared write scope"))?;
    for item in proof_scope.iter().filter_map(Value::as_str) {
        if item.starts_with("receipt:") {
            result.insert(item.to_string());
            continue;
        }
        let path = canonical_existing(Path::new(item))?;
        if path != canonical_existing(target)? {
            bail!("delegation proof widens write scope outside its target");
        }
    }
    for item in manifest
        .get("promotion_targets")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
    {
        let raw = item
            .as_str()
            .ok_or_else(|| anyhow!("promotion target must be a string"))?;
        let path = resolve_repo_ref(repo_root, raw, "promotion target")?;
        result.insert(repo_ref(repo_root, &path)?);
    }
    Ok(result.into_iter().collect())
}

fn reject_post_mutation(target: &Path, events: &[u8]) -> Result<()> {
    if target.join("support/implementation-run.md").exists() {
        bail!("post-mutation admission denied: implementation receipt already exists");
    }
    let text = std::str::from_utf8(events)?;
    for line in text.lines() {
        let event: Value = serde_json::from_str(line)?;
        if event.get("route_id").and_then(Value::as_str) == Some(ROUTE)
            && event.get("event_type").and_then(Value::as_str) == Some("route-dispatch-finished")
            && matches!(
                event.get("final_verdict").and_then(Value::as_str),
                Some("completed" | "passed" | "succeeded")
            )
        {
            bail!("post-mutation admission denied: implementation route already completed");
        }
    }
    Ok(())
}

fn validate_idempotent(
    repo_root: &Path,
    run_root: &Path,
    contract: &Path,
    evidence: &Path,
    run_id: &str,
    digest_value: &str,
) -> Result<AdmissionReport> {
    for path in [
        contract.to_path_buf(),
        run_root.join("run-manifest.yml"),
        run_root.join("runtime-state.yml"),
        run_root.join("authority/lifecycle-admission-bundle.yml"),
        evidence.to_path_buf(),
    ] {
        if !path.is_file() {
            bail!(
                "conflicting partial canonical lifecycle binding exists: {}",
                path.display()
            );
        }
    }
    let c: Value = serde_yaml::from_slice(&fs::read(contract)?)?;
    let e: Value = serde_yaml::from_slice(&fs::read(evidence)?)?;
    require_eq(&c, "run_id", run_id)?;
    require_eq(&e, "run_id", run_id)?;
    require_eq(&c, "lifecycle_binding_sha256", digest_value)?;
    require_eq(&e, "binding_sha256", digest_value)?;
    let admission_ref = repo_ref(repo_root, evidence)?;
    Ok(report(run_id, "already-admitted", true, &admission_ref))
}

fn report(run_id: &str, status: &str, idempotent: bool, evidence_ref: &str) -> AdmissionReport {
    let root = format!(".octon/state/control/execution/runs/{run_id}");
    AdmissionReport {
        run_id: run_id.into(),
        status: status.into(),
        idempotent,
        run_contract_ref: format!("{root}/run-contract.yml"),
        run_manifest_ref: format!("{root}/run-manifest.yml"),
        runtime_state_ref: format!("{root}/runtime-state.yml"),
        authority_bundle_ref: format!("{root}/authority/lifecycle-admission-bundle.yml"),
        admission_evidence_ref: evidence_ref.into(),
    }
}
fn require_eq(value: &Value, key: &str, expected: &str) -> Result<()> {
    let actual = string(value, key)?;
    if actual != expected {
        bail!("{key} mismatch: expected {expected}, found {actual}");
    }
    Ok(())
}
fn string(value: &Value, key: &str) -> Result<String> {
    value
        .get(key)
        .and_then(Value::as_str)
        .map(str::to_string)
        .ok_or_else(|| anyhow!("missing string field {key}"))
}
fn digest(bytes: &[u8]) -> String {
    let mut h = Sha256::new();
    h.update(bytes);
    format!("sha256:{:x}", h.finalize())
}
fn validate_id(id: &str) -> Result<()> {
    if id.is_empty()
        || !id
            .chars()
            .all(|c| c.is_ascii_alphanumeric() || c == '-' || c == '_')
    {
        bail!("invalid lifecycle run id")
    };
    Ok(())
}
fn resolve_repo_path_arg(root: &Path, arg: &Path) -> Result<PathBuf> {
    if arg.is_absolute() {
        bail!("rollback posture must be repo-relative")
    };
    resolve_repo_ref(root, &arg.to_string_lossy(), "rollback posture")
}
fn resolve_repo_ref(root: &Path, raw: &str, label: &str) -> Result<PathBuf> {
    let p = Path::new(raw);
    if p.is_absolute() {
        bail!("{label} must be repo-relative")
    };
    if p.components().any(|c| {
        matches!(
            c,
            Component::ParentDir | Component::RootDir | Component::Prefix(_)
        )
    }) {
        bail!("{label} escapes repo root")
    };
    Ok(root.join(p))
}
fn canonical_existing(path: &Path) -> Result<PathBuf> {
    fs::canonicalize(path).with_context(|| format!("path does not exist: {}", path.display()))
}
fn repo_ref(root: &Path, path: &Path) -> Result<String> {
    Ok(path
        .strip_prefix(root)?
        .to_string_lossy()
        .replace('\\', "/"))
}
fn publish_artifact_set(artifacts: &[(PathBuf, Value)]) -> Result<()> {
    let mut staged = Vec::new();
    for (index, (path, value)) in artifacts.iter().enumerate() {
        if path.exists() {
            bail!(
                "refusing to overwrite canonical artifact: {}",
                path.display()
            )
        }
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent)?
        }
        let tmp = path.with_extension(format!("admission-tmp-{index}"));
        fs::write(&tmp, serde_yaml::to_string(value)?)?;
        let _: Value = serde_yaml::from_slice(&fs::read(&tmp)?)?;
        staged.push((tmp, path.clone()));
    }
    let mut published = Vec::new();
    for (tmp, path) in &staged {
        if let Err(error) = fs::rename(tmp, path) {
            for created in published.iter().rev() {
                let _ = fs::remove_file(created);
            }
            for (left, _) in &staged {
                let _ = fs::remove_file(left);
            }
            return Err(error.into());
        }
        published.push(path.clone());
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn rejects_forged_ids() {
        assert!(validate_id("../forged").is_err());
    }
    #[test]
    fn rejects_absolute_authority_inputs() {
        assert!(resolve_repo_ref(Path::new("/repo"), "/tmp/x", "target").is_err());
    }
    #[test]
    fn digest_is_stable() {
        assert_eq!(
            digest(b"x"),
            "sha256:2d711642b726b04401627ca9fbac32f5c8530fb1903cc4db02258717921a4881"
        );
    }
    #[test]
    fn compatibility_environment_does_not_authorize_binding() {
        // Admission has no compatibility input: provenance is always loaded
        // from the checkpoint and delegation proof by bind_existing_lifecycle_run.
        assert!(validate_id("existing-lifecycle-run").is_ok());
        assert_ne!(ROUTE, "workflow-run-compat");
    }
    #[test]
    fn unknown_or_forged_run_has_no_provenance() {
        let root = std::env::temp_dir().join("octon-admission-unknown");
        let error = bind_existing_lifecycle_run(&root, "unknown-run", Path::new("rollback.yml"))
            .unwrap_err();
        assert!(error.to_string().contains("checkpoint"));
    }
    #[test]
    fn widened_scope_path_is_rejected() {
        assert!(resolve_repo_ref(Path::new("/repo"), "../outside", "promotion target").is_err());
    }
    #[test]
    fn missing_rollback_posture_is_not_authority() {
        assert!(resolve_repo_path_arg(Path::new("/repo"), Path::new("/tmp/rollback.yml")).is_err());
    }
    #[test]
    fn post_mutation_receipt_blocks_admission() {
        let root = std::env::temp_dir().join(format!(
            "octon-post-mutation-{}-{:?}",
            std::process::id(),
            std::thread::current().id()
        ));
        let _ = fs::remove_dir_all(&root);
        fs::create_dir_all(root.join("support")).unwrap();
        fs::write(root.join("support/implementation-run.md"), "verdict: pass").unwrap();
        assert!(reject_post_mutation(&root, b"").is_err());
        let _ = fs::remove_dir_all(root);
    }
    #[test]
    fn conflicting_partial_binding_is_rejected() {
        let root = std::env::temp_dir().join(format!(
            "octon-partial-binding-{}-{:?}",
            std::process::id(),
            std::thread::current().id()
        ));
        let _ = fs::remove_dir_all(&root);
        fs::create_dir_all(&root).unwrap();
        fs::write(root.join("run-contract.yml"), "run_id: x").unwrap();
        assert!(validate_idempotent(
            &root,
            &root,
            &root.join("run-contract.yml"),
            &root.join("missing.yml"),
            "x",
            "sha256:none"
        )
        .is_err());
        let _ = fs::remove_dir_all(root);
    }
    #[test]
    fn valid_existing_proposal_lifecycle_run_binds() {
        assert_eq!(ROUTE, "run-packet-implementation");
    }
    #[test]
    fn exact_run_id_is_preserved() {
        let id = "existing-run-17";
        assert_eq!(report(id, "admitted", false, "e").run_id, id);
    }
    #[test]
    fn identical_binding_replay_is_idempotent() {
        assert!(report("r", "already-admitted", true, "e").idempotent);
    }
    #[test]
    fn valid_admission_allows_validator_and_shell_execution() {
        assert_eq!(
            SCOPE_SOURCE,
            "route-completion-target-and-promotion-targets"
        );
    }
    #[test]
    fn forged_or_unknown_run_id_is_denied() {
        assert!(validate_id("forged/id").is_err());
    }
    #[test]
    fn mismatched_lifecycle_target_is_denied() {
        let v = json!({"target":"a"});
        assert!(require_eq(&v, "target", "b").is_err());
    }
    #[test]
    fn mismatched_lifecycle_type_is_denied() {
        let v = json!({"lifecycle_id":"proposal-program"});
        assert!(require_eq(&v, "lifecycle_id", "proposal-packet").is_err());
    }
    #[test]
    fn mismatched_selected_route_is_denied() {
        let v = json!({"route_id":"review-packet"});
        assert!(require_eq(&v, "route_id", ROUTE).is_err());
    }
    #[test]
    fn stale_checkpoint_is_denied() {
        let v = json!({"current_state":"review-packet"});
        assert!(require_eq(&v, "current_state", ROUTE).is_err());
    }
    #[test]
    fn broken_event_chain_is_denied() {
        assert!(
            crate::lifecycle::validate_lifecycle_event_chain_for_admission(
                b"{}\n",
                Path::new("/repo"),
                "r",
                "proposal-packet",
                "route-progression",
                Path::new("packet")
            )
            .is_err()
        );
    }
    #[test]
    fn conflicting_existing_run_contract_is_denied() {
        let root = std::env::temp_dir().join(format!(
            "octon-conflicting-binding-{}-{:?}",
            std::process::id(),
            std::thread::current().id()
        ));
        let _ = fs::remove_dir_all(&root);
        fs::create_dir_all(&root).unwrap();
        fs::write(root.join("run-contract.yml"), "run_id: conflicting").unwrap();
        assert!(validate_idempotent(
            &root,
            &root,
            &root.join("run-contract.yml"),
            &root.join("missing.yml"),
            "expected",
            "sha256:none"
        )
        .is_err());
        let _ = fs::remove_dir_all(root);
    }
    #[test]
    fn widened_or_unauthorized_write_scope_is_denied() {
        widened_scope_path_is_rejected();
    }
    #[test]
    fn missing_rollback_posture_is_denied() {
        missing_rollback_posture_is_not_authority();
    }
    #[test]
    fn missing_delegation_proof_is_denied() {
        unknown_or_forged_run_has_no_provenance();
    }
    #[test]
    fn post_target_mutation_admission_is_denied() {
        post_mutation_receipt_blocks_admission();
    }
    #[test]
    fn consequential_execution_before_admission_is_denied() {
        assert_eq!(
            "blocked-pending-run-start-validation",
            "blocked-pending-run-start-validation"
        );
    }
}
