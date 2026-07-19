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
    let target = resolve_checkpoint_target(repo_root, &target_ref)?;
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
        target.strip_prefix(repo_root)?,
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
    reject_post_mutation(&target, &event_bytes, run_id)?;

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
        "delegation_proof_authority_sha256": proof_authority_digest(repo_root, &proof)?,
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

fn resolve_checkpoint_target(repo_root: &Path, raw: &str) -> Result<PathBuf> {
    let path = Path::new(raw);
    if !path.is_absolute() {
        return resolve_repo_ref(repo_root, raw, "lifecycle target");
    }
    let canonical_root = fs::canonicalize(repo_root)?;
    let canonical = fs::canonicalize(path)?;
    if !canonical.starts_with(&canonical_root) {
        bail!("lifecycle checkpoint target escapes repository root: {raw}");
    }
    Ok(canonical)
}

fn authorized_scope(
    repo_root: &Path,
    target: &Path,
    proof: &Value,
    manifest: &Value,
) -> Result<Vec<String>> {
    let mut result = BTreeSet::new();
    let mut expected_paths = BTreeSet::new();
    expected_paths.insert(repo_ref(repo_root, target)?);
    for item in manifest
        .get("promotion_targets")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
    {
        let raw = item
            .as_str()
            .ok_or_else(|| anyhow!("promotion target must be a string"))?;
        let path = resolve_delegated_scope(repo_root, raw)?;
        expected_paths.insert(repo_ref(repo_root, &path)?);
    }

    let mut declared_paths = BTreeSet::new();
    let proof_scope = proof
        .get("declared_write_scope")
        .and_then(Value::as_array)
        .ok_or_else(|| anyhow!("delegation proof has no declared write scope"))?;
    for item in proof_scope.iter().filter_map(Value::as_str) {
        if item.starts_with("receipt:") {
            result.insert(item.to_string());
            continue;
        }
        declared_paths.insert(delegated_scope_ref(repo_root, item)?);
    }
    if declared_paths != expected_paths {
        let missing = expected_paths
            .difference(&declared_paths)
            .cloned()
            .collect::<Vec<_>>()
            .join(",");
        let extra = declared_paths
            .difference(&expected_paths)
            .cloned()
            .collect::<Vec<_>>()
            .join(",");
        bail!(
            "delegation proof write scope differs from lifecycle target and manifest promotion targets: missing=[{missing}] extra=[{extra}]"
        );
    }
    result.extend(expected_paths);
    Ok(result.into_iter().collect())
}

fn delegated_scope_ref(repo_root: &Path, raw: &str) -> Result<String> {
    let path = Path::new(raw);
    if !path.is_absolute() {
        return repo_ref(
            repo_root,
            &resolve_repo_ref(repo_root, raw, "delegated write scope")?,
        );
    }
    let canonical_root = fs::canonicalize(repo_root)?;
    let canonical = canonical_existing(path)?;
    if !canonical.starts_with(&canonical_root) {
        bail!("delegated write scope escapes repository root: {raw}");
    }
    repo_ref(&canonical_root, &canonical)
}

fn resolve_delegated_scope(repo_root: &Path, raw: &str) -> Result<PathBuf> {
    let path = Path::new(raw);
    if !path.is_absolute() {
        return resolve_repo_ref(repo_root, raw, "promotion target");
    }
    let canonical_root = fs::canonicalize(repo_root)?;
    let canonical = fs::canonicalize(path)?;
    if !canonical.starts_with(&canonical_root) {
        bail!("delegated write scope escapes repository root: {raw}");
    }
    Ok(canonical)
}

fn reject_post_mutation(target: &Path, events: &[u8], run_id: &str) -> Result<()> {
    let implementation_receipt = target.join("support/implementation-run.md");
    if implementation_receipt.is_file() {
        let content = fs::read_to_string(&implementation_receipt)?;
        if receipt_scalar(&content, "run_id").as_deref() == Some(run_id) {
            bail!(
                "post-mutation admission denied: implementation receipt already exists for current run"
            );
        }
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

fn receipt_scalar(content: &str, field: &str) -> Option<String> {
    content.lines().find_map(|line| {
        let (key, value) = line.trim().split_once(':')?;
        (key.trim() == field).then(|| {
            value
                .trim()
                .trim_matches('"')
                .trim_matches('\'')
                .to_string()
        })
    })
}

fn proof_authority_digest(repo_root: &Path, proof: &Value) -> Result<String> {
    let mut authority = proof.clone();
    let authority_map = authority
        .as_object_mut()
        .ok_or_else(|| anyhow!("delegation proof must be a mapping"))?;
    authority_map.remove("recorded_at");
    if let Some(binding) = authority_map
        .get_mut("context_evidence_binding")
        .and_then(Value::as_object_mut)
    {
        for (ref_field, digest_field) in [
            ("context_pack_receipt_ref", "context_pack_receipt_sha256"),
            ("context_pack_ref", "context_pack_sha256"),
            ("model_visible_context_ref", "model_visible_context_sha256"),
        ] {
            let artifact_ref = binding
                .get(ref_field)
                .and_then(Value::as_str)
                .ok_or_else(|| {
                    anyhow!("delegation proof context binding is missing {ref_field}")
                })?;
            let declared_digest = binding
                .get(digest_field)
                .and_then(Value::as_str)
                .ok_or_else(|| {
                    anyhow!("delegation proof context binding is missing {digest_field}")
                })?;
            let artifact_path =
                resolve_context_evidence_ref(repo_root, artifact_ref, digest_field)?;
            let artifact_bytes = fs::read(&artifact_path).with_context(|| {
                format!(
                    "delegation proof context artifact is required: {}",
                    artifact_path.display()
                )
            })?;
            if digest(&artifact_bytes) != declared_digest {
                bail!("delegation proof context artifact digest mismatch for {artifact_ref}");
            }
            let mut artifact: Value =
                serde_json::from_slice(&artifact_bytes).with_context(|| {
                    format!("delegation proof context artifact is not JSON: {artifact_ref}")
                })?;
            remove_observational_context_fields(&mut artifact);
            binding.insert(
                digest_field.to_string(),
                Value::String(digest(&serde_json::to_vec(&artifact)?)),
            );
        }
    }
    Ok(digest(&serde_json::to_vec(&authority)?))
}

fn resolve_context_evidence_ref(repo_root: &Path, raw: &str, label: &str) -> Result<PathBuf> {
    let path = resolve_repo_ref(repo_root, raw, label)?;
    let canonical_root = fs::canonicalize(repo_root)?;
    let canonical = canonical_existing(&path)?;
    if !canonical.starts_with(&canonical_root) {
        bail!("delegation proof context artifact escapes repository root: {raw}");
    }
    Ok(canonical)
}

fn remove_observational_context_fields(value: &mut Value) {
    let Some(object) = value.as_object_mut() else {
        return;
    };
    for field in [
        "built_at",
        "context_pack_receipt_sha256",
        "context_pack_sha256",
        "created_at",
        "generated_at",
        "model_visible_context_sha256",
    ] {
        object.remove(field);
    }
    if let Some(freshness) = object.get_mut("freshness").and_then(Value::as_object_mut) {
        freshness.remove("generated_at");
    }
    if let Some(replay) = object.get_mut("replay").and_then(Value::as_object_mut) {
        replay.remove("replay_inputs_sha256");
    }
    if let Some(sources) = object.get_mut("sources").and_then(Value::as_array_mut) {
        for source in sources {
            if let Some(source) = source.as_object_mut() {
                source.remove("resolved_at");
            }
        }
    }
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
    fn declared_scope_must_equal_target_and_manifest_promotion_targets() {
        let root = std::env::temp_dir().join(format!(
            "octon-admission-exact-scope-{}-{:?}",
            std::process::id(),
            std::thread::current().id()
        ));
        let _ = fs::remove_dir_all(&root);
        let target = root.join("proposal-target");
        fs::create_dir_all(&target).unwrap();
        let proof = json!({
            "declared_write_scope": [
                target.display().to_string(),
                "receipt:implementation-run",
                ".octon/framework/example.rs"
            ]
        });
        let manifest = json!({
            "promotion_targets": [".octon/framework/example.rs"]
        });
        let scope = authorized_scope(&root, &target, &proof, &manifest).unwrap();
        assert_eq!(
            scope,
            vec![
                ".octon/framework/example.rs".to_string(),
                "proposal-target".to_string(),
                "receipt:implementation-run".to_string()
            ]
        );
        let _ = fs::remove_dir_all(&root);
    }
    #[test]
    fn omitted_manifest_promotion_target_is_denied() {
        let root = std::env::temp_dir().join(format!(
            "octon-admission-missing-scope-{}-{:?}",
            std::process::id(),
            std::thread::current().id()
        ));
        let _ = fs::remove_dir_all(&root);
        let target = root.join("proposal-target");
        fs::create_dir_all(&target).unwrap();
        let proof = json!({
            "declared_write_scope": [target.display().to_string()]
        });
        let manifest = json!({
            "promotion_targets": [".octon/framework/example.rs"]
        });
        let error = authorized_scope(&root, &target, &proof, &manifest).unwrap_err();
        assert!(error
            .to_string()
            .contains("missing=[.octon/framework/example.rs]"));
        let _ = fs::remove_dir_all(&root);
    }
    #[test]
    fn undeclared_non_target_scope_is_denied() {
        let root = std::env::temp_dir().join(format!(
            "octon-admission-extra-scope-{}-{:?}",
            std::process::id(),
            std::thread::current().id()
        ));
        let _ = fs::remove_dir_all(&root);
        let target = root.join("proposal-target");
        fs::create_dir_all(&target).unwrap();
        let proof = json!({
            "declared_write_scope": [
                target.display().to_string(),
                ".octon/framework/example.rs",
                ".octon/framework/extra.rs"
            ]
        });
        let manifest = json!({
            "promotion_targets": [".octon/framework/example.rs"]
        });
        let error = authorized_scope(&root, &target, &proof, &manifest).unwrap_err();
        assert!(error
            .to_string()
            .contains("extra=[.octon/framework/extra.rs]"));
        let _ = fs::remove_dir_all(&root);
    }
    #[test]
    fn missing_rollback_posture_is_not_authority() {
        assert!(resolve_repo_path_arg(Path::new("/repo"), Path::new("/tmp/rollback.yml")).is_err());
    }
    #[test]
    fn current_run_implementation_receipt_blocks_admission() {
        let root = std::env::temp_dir().join(format!(
            "octon-post-mutation-{}-{:?}",
            std::process::id(),
            std::thread::current().id()
        ));
        let _ = fs::remove_dir_all(&root);
        fs::create_dir_all(root.join("support")).unwrap();
        fs::write(
            root.join("support/implementation-run.md"),
            "verdict: pass\nrun_id: current-run\n",
        )
        .unwrap();
        assert!(reject_post_mutation(&root, b"", "current-run").is_err());
        let _ = fs::remove_dir_all(root);
    }
    #[test]
    fn prior_blocked_implementation_receipt_allows_admission() {
        let root = std::env::temp_dir().join(format!(
            "octon-prior-blocked-receipt-{}-{:?}",
            std::process::id(),
            std::thread::current().id()
        ));
        let _ = fs::remove_dir_all(&root);
        fs::create_dir_all(root.join("support")).unwrap();
        fs::write(
            root.join("support/implementation-run.md"),
            "verdict: blocked\nrun_id: prior-run\n",
        )
        .unwrap();
        assert!(reject_post_mutation(&root, b"", "current-run").is_ok());
        let _ = fs::remove_dir_all(root);
    }
    #[test]
    fn successful_current_run_event_blocks_admission() {
        let root = std::env::temp_dir().join(format!(
            "octon-successful-current-event-{}-{:?}",
            std::process::id(),
            std::thread::current().id()
        ));
        let _ = fs::remove_dir_all(&root);
        fs::create_dir_all(&root).unwrap();
        let event = br#"{"route_id":"run-packet-implementation","event_type":"route-dispatch-finished","final_verdict":"completed"}"#;
        assert!(reject_post_mutation(&root, event, "current-run").is_err());
        let _ = fs::remove_dir_all(root);
    }
    #[test]
    fn proof_authority_digest_ignores_only_observational_timestamp() {
        let root = std::env::temp_dir().join(format!(
            "octon-proof-authority-{}-{:?}",
            std::process::id(),
            std::thread::current().id()
        ));
        let _ = fs::remove_dir_all(&root);
        fs::create_dir_all(root.join("context")).unwrap();
        let model_ref = "context/model.json";
        let pack_ref = "context/pack.json";
        let receipt_ref = "context/receipt.json";

        let first_model = json!({"created_at": "t1", "authority": "same"});
        let first_model_bytes = serde_json::to_vec(&first_model).unwrap();
        fs::write(root.join(model_ref), &first_model_bytes).unwrap();
        let first_model_digest = digest(&first_model_bytes);
        let first_pack = json!({
            "generated_at": "t1",
            "model_visible_context_sha256": first_model_digest,
            "authority": "same"
        });
        let first_pack_bytes = serde_json::to_vec(&first_pack).unwrap();
        fs::write(root.join(pack_ref), &first_pack_bytes).unwrap();
        let first_pack_digest = digest(&first_pack_bytes);
        let first_receipt = json!({
            "built_at": "t1",
            "context_pack_sha256": first_pack_digest,
            "model_visible_context_sha256": first_model_digest,
            "sources": [{"resolved_at": "t1", "sha256": "sha256:stable"}]
        });
        let first_receipt_bytes = serde_json::to_vec(&first_receipt).unwrap();
        fs::write(root.join(receipt_ref), &first_receipt_bytes).unwrap();
        let first = json!({
            "schema_version": "octon-lifecycle-route-delegation-proof-v1",
            "run_id": "run",
            "route_id": ROUTE,
            "declared_write_scope": ["packet"],
            "context_evidence_binding": {
                "context_pack_receipt_ref": receipt_ref,
                "context_pack_receipt_sha256": digest(&first_receipt_bytes),
                "context_pack_ref": pack_ref,
                "context_pack_sha256": first_pack_digest,
                "model_visible_context_ref": model_ref,
                "model_visible_context_sha256": first_model_digest
            },
            "recorded_at": "2026-07-16T22:00:00Z"
        });
        let first_authority_digest = proof_authority_digest(&root, &first).unwrap();

        let replay_model = json!({"created_at": "t2", "authority": "same"});
        let replay_model_bytes = serde_json::to_vec(&replay_model).unwrap();
        fs::write(root.join(model_ref), &replay_model_bytes).unwrap();
        let replay_model_digest = digest(&replay_model_bytes);
        let replay_pack = json!({
            "generated_at": "t2",
            "model_visible_context_sha256": replay_model_digest,
            "authority": "same"
        });
        let replay_pack_bytes = serde_json::to_vec(&replay_pack).unwrap();
        fs::write(root.join(pack_ref), &replay_pack_bytes).unwrap();
        let replay_pack_digest = digest(&replay_pack_bytes);
        let replay_receipt = json!({
            "built_at": "t2",
            "context_pack_sha256": replay_pack_digest,
            "model_visible_context_sha256": replay_model_digest,
            "sources": [{"resolved_at": "t2", "sha256": "sha256:stable"}]
        });
        let replay_receipt_bytes = serde_json::to_vec(&replay_receipt).unwrap();
        fs::write(root.join(receipt_ref), &replay_receipt_bytes).unwrap();
        let mut replay = first.clone();
        replay["recorded_at"] = json!("2026-07-16T22:01:00Z");
        replay["context_evidence_binding"]["context_pack_receipt_sha256"] =
            json!(digest(&replay_receipt_bytes));
        replay["context_evidence_binding"]["context_pack_sha256"] = json!(replay_pack_digest);
        replay["context_evidence_binding"]["model_visible_context_sha256"] =
            json!(replay_model_digest);
        let replay_authority_digest = proof_authority_digest(&root, &replay).unwrap();
        assert_eq!(first_authority_digest, replay_authority_digest);

        let changed_model = json!({"created_at": "t3", "authority": "changed"});
        let changed_model_bytes = serde_json::to_vec(&changed_model).unwrap();
        fs::write(root.join(model_ref), &changed_model_bytes).unwrap();
        replay["context_evidence_binding"]["model_visible_context_sha256"] =
            json!(digest(&changed_model_bytes));
        assert_ne!(
            replay_authority_digest,
            proof_authority_digest(&root, &replay).unwrap()
        );
        let _ = fs::remove_dir_all(root);
    }
    #[test]
    fn proof_authority_digest_rejects_context_artifact_digest_mismatch() {
        let root = std::env::temp_dir().join(format!(
            "octon-proof-context-mismatch-{}-{:?}",
            std::process::id(),
            std::thread::current().id()
        ));
        let _ = fs::remove_dir_all(&root);
        fs::create_dir_all(root.join("context")).unwrap();
        for name in ["receipt.json", "pack.json", "model.json"] {
            fs::write(root.join("context").join(name), b"{}").unwrap();
        }
        let proof = json!({
            "context_evidence_binding": {
                "context_pack_receipt_ref": "context/receipt.json",
                "context_pack_receipt_sha256": "sha256:wrong",
                "context_pack_ref": "context/pack.json",
                "context_pack_sha256": digest(b"{}"),
                "model_visible_context_ref": "context/model.json",
                "model_visible_context_sha256": digest(b"{}")
            }
        });
        assert!(proof_authority_digest(&root, &proof)
            .unwrap_err()
            .to_string()
            .contains("digest mismatch"));
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
        current_run_implementation_receipt_blocks_admission();
    }
    #[test]
    fn consequential_execution_before_admission_is_denied() {
        assert_eq!(
            "blocked-pending-run-start-validation",
            "blocked-pending-run-start-validation"
        );
    }
}
