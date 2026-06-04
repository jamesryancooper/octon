use crate::errors::{LifecycleErrorClass, LifecycleExecutionError};
use crate::generated::resolve_prompt_bundle;
use crate::request::LifecycleRouteExecutionRequest;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use sha2::{Digest, Sha256};
use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::path::{Component, Path, PathBuf};

const CONTEXT_BUILDER_SPEC_REF: &str =
    ".octon/framework/engine/runtime/spec/context-pack-builder-v1.md";
const CONTEXT_BUILDER_VERSION: &str = "context-pack-builder-v1";
const CONTEXT_POLICY_REF: &str = ".octon/instance/governance/policies/context-packing.yml";
const CONTEXT_MODEL_VISIBLE_FORMAT: &str = "context-pack-builder-v1/model-visible-context-json";
const CONTEXT_RECEIPT_VALID_UNTIL: &str = "9999-12-31T23:59:59Z";

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct LifecycleContextPackBinding {
    pub context_pack_ref: String,
    pub context_pack_receipt_ref: String,
    pub context_pack_sha256: String,
    pub context_pack_receipt_sha256: String,
    pub model_visible_context_ref: String,
    pub model_visible_context_sha256: String,
    pub source_manifest_ref: String,
    pub omissions_ref: String,
    pub redactions_ref: String,
    pub invalidation_events_ref: String,
    pub context_policy_ref: String,
    pub builder_spec_ref: String,
    pub builder_version: String,
    pub verification_status: String,
    #[serde(skip)]
    pub evidence_paths: Vec<PathBuf>,
}

impl LifecycleContextPackBinding {
    pub fn proof_fields(&self) -> BTreeMap<String, String> {
        let mut fields = BTreeMap::new();
        fields.insert(
            "context_pack_ref".to_string(),
            self.context_pack_ref.clone(),
        );
        fields.insert(
            "context_pack_receipt_ref".to_string(),
            self.context_pack_receipt_ref.clone(),
        );
        fields.insert(
            "context_pack_sha256".to_string(),
            self.context_pack_sha256.clone(),
        );
        fields.insert(
            "context_pack_receipt_sha256".to_string(),
            self.context_pack_receipt_sha256.clone(),
        );
        fields.insert(
            "model_visible_context_ref".to_string(),
            self.model_visible_context_ref.clone(),
        );
        fields.insert(
            "model_visible_context_sha256".to_string(),
            self.model_visible_context_sha256.clone(),
        );
        fields.insert(
            "context_policy_ref".to_string(),
            self.context_policy_ref.clone(),
        );
        fields.insert(
            "builder_spec_ref".to_string(),
            self.builder_spec_ref.clone(),
        );
        fields.insert("builder_version".to_string(), self.builder_version.clone());
        fields.insert(
            "verification_status".to_string(),
            self.verification_status.clone(),
        );
        fields
    }
}

#[derive(Clone, Debug)]
struct SourceCandidate {
    path: String,
    bucket: SourceBucket,
    source_class: &'static str,
    surface_class: &'static str,
    authority_label: &'static str,
    trust_class: &'static str,
    source_role: &'static str,
    receipt_kind: &'static str,
    inclusion_mode: &'static str,
    policy_reason: &'static str,
    required: bool,
}

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
enum SourceBucket {
    Authority,
    Derived,
    NonAuthoritative,
}

pub fn build_route_context_pack(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
) -> Result<LifecycleContextPackBinding, LifecycleExecutionError> {
    let context_policy_path = repo_root.join(CONTEXT_POLICY_REF);
    let context_policy_raw = fs::read_to_string(&context_policy_path).map_err(|error| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            format!("context packing policy is missing: {error}"),
        )
    })?;
    serde_yaml::from_str::<serde_yaml::Value>(&context_policy_raw).map_err(|error| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            format!("context packing policy is unparsable: {error}"),
        )
    })?;

    let now = crate::authorization::now_rfc3339();
    let context_pack_id = format!("context-pack-{}", request.run_id);
    let context_root = request.evidence_root.join("context");
    let control_context_root = request
        .checkpoint_path
        .parent()
        .unwrap_or_else(|| request.evidence_root.as_path())
        .join("context");
    fs::create_dir_all(&context_root)?;
    fs::create_dir_all(&control_context_root)?;

    let mut candidates = lifecycle_context_candidates(repo_root, request)?;
    candidates.sort_by(|left, right| {
        bucket_order(left.bucket)
            .cmp(&bucket_order(right.bucket))
            .then(left.path.cmp(&right.path))
    });
    candidates.dedup_by(|left, right| left.path == right.path && left.bucket == right.bucket);

    let mut authority_sources = Vec::new();
    let mut derived_sources = Vec::new();
    let mut non_authoritative_inputs = Vec::new();
    let mut receipt_sources = Vec::new();
    let mut source_manifest = Vec::new();
    let mut omissions = Vec::new();
    let mut seen_paths = BTreeSet::new();

    for candidate in candidates {
        let abs = resolve_repo_ref(repo_root, &candidate.path);
        if !abs.is_file() {
            let omission = json!({
                "source_ref": candidate.path,
                "omission_code": if candidate.required { "stale" } else { "explicit_policy_exclusion" },
                "reason": if candidate.required {
                    "required lifecycle context source is missing"
                } else {
                    "optional lifecycle context source is unavailable"
                },
                "route": if candidate.required { "deny" } else { "allow" },
                "policy_ref": CONTEXT_POLICY_REF,
            });
            omissions.push(omission);
            if candidate.required {
                write_context_json(&context_root.join("omissions.json"), &omissions)?;
                return Err(LifecycleExecutionError::new(
                    LifecycleErrorClass::AuthorizationProofFailed,
                    format!("required context source is missing: {}", candidate.path),
                ));
            }
            continue;
        }
        if !seen_paths.insert((candidate.bucket, candidate.path.clone())) {
            continue;
        }
        let sha256 = sha256_file_prefixed(&abs)?;
        let byte_count = fs::metadata(&abs).map(|meta| meta.len()).unwrap_or(0);
        let source_entry = json!({
            "path": candidate.path,
            "sha256": sha256,
            "source_class": candidate.source_class,
            "surface_class": candidate.surface_class,
            "authority_label": candidate.authority_label,
            "trust_class": candidate.trust_class,
            "source_role": candidate.source_role,
            "inclusion_mode": candidate.inclusion_mode,
            "model_visible": true,
            "byte_count": byte_count,
            "bytes_included": 0,
            "estimated_token_count": estimate_tokens(byte_count),
            "estimated_tokens": 0,
            "handle_ref": candidate.path,
            "policy_ref": CONTEXT_POLICY_REF,
            "policy_reason": candidate.policy_reason,
        });
        match candidate.bucket {
            SourceBucket::Authority => authority_sources.push(source_entry),
            SourceBucket::Derived => derived_sources.push(source_entry),
            SourceBucket::NonAuthoritative => non_authoritative_inputs.push(source_entry),
        }
        receipt_sources.push(json!({
            "source_ref": candidate.path,
            "source_kind": candidate.receipt_kind,
            "authority_label": candidate.authority_label,
            "required": candidate.required,
            "sha256": sha256,
            "verification_status": "valid",
            "freshness_status": "valid",
            "resolved_at": now,
            "evidence_ref": candidate.path,
            "inclusion_mode": candidate.inclusion_mode,
        }));
        source_manifest.push(format!("{} {}", candidate.path, sha256));
    }

    if authority_sources.is_empty() {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::AuthorizationProofFailed,
            "context builder found no lifecycle authority sources",
        ));
    }

    source_manifest.sort();
    let source_manifest_path = context_root.join("source-manifest.json");
    let omissions_path = context_root.join("omissions.json");
    let redactions_path = context_root.join("redactions.json");
    let invalidation_path = context_root.join("invalidation-events.json");
    let model_visible_context_path = context_root.join("model-visible-context.json");
    let model_visible_hash_path = context_root.join("model-visible-context.sha256");
    let context_pack_path = context_root.join("context-pack.json");
    let context_receipt_path = context_root.join("context-pack-receipt.json");
    let context_pack_ref = repo_rel(repo_root, &context_pack_path);
    let context_receipt_ref = repo_rel(repo_root, &context_receipt_path);
    let model_visible_context_ref = repo_rel(repo_root, &model_visible_context_path);

    write_context_json(&source_manifest_path, &source_manifest)?;
    write_context_json(&omissions_path, &omissions)?;
    write_context_json(&redactions_path, &json!([]))?;
    write_context_json(&invalidation_path, &json!([]))?;

    let source_summary = source_summary(
        receipt_sources.len(),
        authority_sources.len(),
        derived_sources.len(),
        non_authoritative_inputs.len(),
    );
    let model_visible_context = json!({
        "schema_version": "model-visible-context-v1",
        "serialization_format": CONTEXT_MODEL_VISIBLE_FORMAT,
        "run_id": request.run_id,
        "route_id": request.route.route_id,
        "lifecycle_id": request.lifecycle_id,
        "context_pack_id": context_pack_id,
        "context_policy_ref": CONTEXT_POLICY_REF,
        "builder_version": CONTEXT_BUILDER_VERSION,
        "created_at": now,
        "assembler_id": "octon_lifecycle_executor::context_pack",
        "request_scope": {
            "target_ref": repo_rel(repo_root, &request.target),
            "route_type": request.route.route_type,
            "executor": request.executor,
            "phase_id": request.phase_id,
        },
        "support_target_tuple_ref": "lifecycle-route-context-pack",
        "source_manifest": source_manifest,
        "authority_sources": authority_sources,
        "derived_sources": derived_sources,
        "non_authoritative_inputs": non_authoritative_inputs,
        "omissions": omissions,
        "redactions": [],
        "freshness": {
            "generated_at": now,
            "valid_until": CONTEXT_RECEIPT_VALID_UNTIL,
            "freshness_status": "valid",
        },
        "replay": {
            "replayable": true,
            "reconstruction_refs": [
                model_visible_context_ref,
                repo_rel(repo_root, &model_visible_hash_path)
            ],
        },
    });
    let model_visible_bytes =
        write_context_json_bytes(&model_visible_context_path, &model_visible_context)?;
    let model_visible_context_sha256 = format!("sha256:{}", sha256_bytes(&model_visible_bytes));
    fs::write(
        &model_visible_hash_path,
        format!("{model_visible_context_sha256}\n"),
    )?;

    let pack = json!({
        "schema_version": "context-pack-v1",
        "context_pack_id": context_pack_id,
        "pack_id": context_pack_id,
        "run_id": request.run_id,
        "builder_id": "octon-lifecycle-executor",
        "builder_version": CONTEXT_BUILDER_VERSION,
        "context_policy_ref": CONTEXT_POLICY_REF,
        "model_visible_context_sha256": model_visible_context_sha256,
        "model_visible_context_ref": model_visible_context_ref,
        "model_visible_serialization_format": CONTEXT_MODEL_VISIBLE_FORMAT,
        "created_at": now,
        "validity_state": "valid",
        "authority_sources": authority_sources,
        "control_sources": [],
        "evidence_sources": [],
        "continuity_sources": [],
        "generated_runtime_effective_handles": [],
        "capability_schema_sources": [],
        "derived_sources": derived_sources,
        "non_authoritative_inputs": non_authoritative_inputs,
        "omissions": omissions,
        "redactions": [],
        "source_manifest": source_manifest,
        "source_manifest_ref": repo_rel(repo_root, &source_manifest_path),
        "budget": {
            "max_prompt_bytes": 400000,
            "max_estimated_input_tokens": 100000,
            "model_context_limit": null,
            "included_bytes": 0,
            "model_visible_bytes": model_visible_bytes.len(),
            "estimated_input_tokens": estimate_tokens(model_visible_bytes.len() as u64),
            "model_visible_estimated_tokens": estimate_tokens(model_visible_bytes.len() as u64),
        },
        "freshness": {
            "generated_at": now,
            "fresh_until": CONTEXT_RECEIPT_VALID_UNTIL,
            "freshness_mode": "receipt-verified",
        },
        "invalidation": {
            "mode": "source-digest",
            "watch_refs": source_manifest,
            "invalidated_at": null,
            "reason": null,
        },
        "rebuild": {
            "rebuild_required": false,
            "rebuild_refs": [],
        },
        "replay": {
            "replayable": true,
            "replay_inputs_sha256": model_visible_context_sha256,
            "model_visible_context_ref": model_visible_context_ref,
        },
        "receipt_ref": context_receipt_ref,
        "generated_at": now,
    });
    write_context_json(&context_pack_path, &pack)?;
    let context_pack_sha256 = sha256_file_prefixed(&context_pack_path)?;

    let receipt = json!({
        "schema_version": "context-pack-receipt-v1",
        "receipt_id": format!("context-pack-receipt-{}", request.run_id),
        "context_pack_id": context_pack_id,
        "context_pack_ref": context_pack_ref,
        "context_pack_sha256": context_pack_sha256,
        "run_id": request.run_id,
        "request_id": request.run_id,
        "builder_spec_ref": CONTEXT_BUILDER_SPEC_REF,
        "builder_version": CONTEXT_BUILDER_VERSION,
        "context_policy_ref": CONTEXT_POLICY_REF,
        "model_visible_context_sha256": model_visible_context_sha256,
        "model_visible_context_ref": model_visible_context_ref,
        "source_manifest_ref": repo_rel(repo_root, &source_manifest_path),
        "omissions_ref": repo_rel(repo_root, &omissions_path),
        "redactions_ref": repo_rel(repo_root, &redactions_path),
        "invalidation_events_ref": repo_rel(repo_root, &invalidation_path),
        "built_at": now,
        "freshness": {
            "generated_at": now,
            "valid_until": CONTEXT_RECEIPT_VALID_UNTIL,
            "freshness_status": "valid",
        },
        "validity_state": "valid",
        "invalidation_state": "not_invalidated",
        "rebuild_refs": [],
        "compaction_refs": [],
        "replay_reconstruction_refs": [
            model_visible_context_ref,
            repo_rel(repo_root, &model_visible_hash_path)
        ],
        "authorization_binding_refs": [
            format!(
                ".octon/state/evidence/runs/{}/authorization/{}-delegation-proof.yml",
                request.run_id,
                request.route.route_id
            )
        ],
        "verification_status": "valid",
        "authority_boundary": {
            "authorize_execution_ref": ".octon/framework/engine/runtime/spec/context-pack-builder-v1.md#authorization-validation",
            "subordinate_to_lifecycle_route_authorization": true,
            "proposal_inputs_are_authority": false,
            "generated_outputs_are_authority": false
        },
        "request_binding": {
            "request_id": request.run_id,
            "target_id": repo_rel(repo_root, &request.target),
            "action_type": request.route.route_id,
            "workflow_mode": request.route.route_type,
            "risk_tier": "lifecycle-route",
            "support_target_tuple_ref": "lifecycle-route-context-pack",
            "requires_context_evidence": true,
            "boundary_sensitive": true,
            "consequential": true,
        },
        "source_summary": source_summary,
        "sources": receipt_sources,
        "omissions": omissions,
        "failure_policy": {
            "missing_required_context_route": "DENY",
            "stale_required_context_route": "DENY",
            "invalid_required_context_route": "DENY",
            "unverifiable_required_context_route": "DENY",
            "reason_codes": ["CONTEXT_EVIDENCE_REQUIRED", "FCR-007", "FCR-013"],
        },
        "builder_notes": [
            "Lifecycle route context packs are evidence for route authorization.",
            "Generated route state is handle-only and proposal-local inputs are non-authoritative.",
        ],
    });
    write_context_json(&context_receipt_path, &receipt)?;
    let context_pack_receipt_sha256 = sha256_file_prefixed(&context_receipt_path)?;

    write_context_yaml(
        &control_context_root.join("active-context-pack.yml"),
        &json!({
            "schema_version": "active-context-pack-v1",
            "run_id": request.run_id,
            "route_id": request.route.route_id,
            "context_pack_ref": context_pack_ref,
            "context_pack_receipt_ref": context_receipt_ref,
            "context_pack_sha256": context_pack_sha256,
            "receipt_sha256": context_pack_receipt_sha256,
            "model_visible_context_sha256": model_visible_context_sha256,
            "context_policy_ref": CONTEXT_POLICY_REF,
            "validity_state": "valid",
            "updated_at": now,
            "model_visible_context_ref": model_visible_context_ref,
        }),
    )?;
    write_context_yaml(
        &control_context_root.join("status.yml"),
        &json!({
            "schema_version": "context-pack-status-v1",
            "run_id": request.run_id,
            "route_id": request.route.route_id,
            "status": "bound",
            "validity_state": "valid",
            "context_pack_ref": context_pack_ref,
            "context_pack_receipt_ref": context_receipt_ref,
            "updated_at": now,
        }),
    )?;

    Ok(LifecycleContextPackBinding {
        context_pack_ref,
        context_pack_receipt_ref: context_receipt_ref,
        context_pack_sha256,
        context_pack_receipt_sha256,
        model_visible_context_ref,
        model_visible_context_sha256,
        source_manifest_ref: repo_rel(repo_root, &source_manifest_path),
        omissions_ref: repo_rel(repo_root, &omissions_path),
        redactions_ref: repo_rel(repo_root, &redactions_path),
        invalidation_events_ref: repo_rel(repo_root, &invalidation_path),
        context_policy_ref: CONTEXT_POLICY_REF.to_string(),
        builder_spec_ref: CONTEXT_BUILDER_SPEC_REF.to_string(),
        builder_version: CONTEXT_BUILDER_VERSION.to_string(),
        verification_status: "valid".to_string(),
        evidence_paths: vec![
            context_pack_path,
            context_receipt_path,
            model_visible_context_path,
            model_visible_hash_path,
            source_manifest_path,
            omissions_path,
            redactions_path,
            invalidation_path,
        ],
    })
}

fn lifecycle_context_candidates(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
) -> Result<Vec<SourceCandidate>, LifecycleExecutionError> {
    let mut candidates = vec![
        authority_candidate(CONTEXT_BUILDER_SPEC_REF, "context-pack-builder-spec", true),
        authority_candidate(CONTEXT_POLICY_REF, "context-packing-policy", true),
        authority_candidate(
            ".octon/instance/ingress/AGENTS.md",
            "bootstrap-ingress",
            false,
        ),
    ];
    push_existing_path_candidate(
        repo_root,
        &mut candidates,
        &request.runtime_route_bundle,
        SourceBucket::Derived,
        "generated_derived",
        "generated-runtime-effective",
        "derived",
        "freshness-checked-generated-handle",
        "runtime-route-bundle",
        "generated-handle",
        "handle-only",
        "handle_visible_by_lifecycle_context_policy",
        false,
    );
    push_existing_path_candidate(
        repo_root,
        &mut candidates,
        &request.effective_extension_catalog,
        SourceBucket::Derived,
        "generated_derived",
        "generated-extension-effective",
        "derived",
        "freshness-checked-generated-handle",
        "effective-extension-catalog",
        "generated-handle",
        "handle-only",
        "handle_visible_by_lifecycle_context_policy",
        false,
    );

    if let Some(prompt_set_id) = request.route.prompt_set_id.as_deref() {
        let bundle = resolve_prompt_bundle(
            repo_root,
            &request.effective_extension_catalog,
            &request.owner_extension,
            prompt_set_id,
        )?;
        candidates.push(derived_candidate(
            &bundle.manifest_path,
            "prompt-bundle-manifest",
            true,
        ));
        for anchor in bundle.required_repo_anchors {
            candidates.push(authority_candidate(
                &anchor.path,
                "required-repo-anchor",
                true,
            ));
        }
        for asset in bundle.assets {
            candidates.push(derived_candidate(
                &repo_rel(repo_root, &asset.path),
                "prompt-asset-projection",
                true,
            ));
            candidates.push(non_authoritative_candidate(
                &repo_rel(repo_root, &asset.source_path),
                "prompt-source-asset",
                true,
            ));
        }
    }

    let manifest_path = request.target.join(&request.manifest_path);
    push_existing_path_candidate(
        repo_root,
        &mut candidates,
        &manifest_path,
        SourceBucket::NonAuthoritative,
        "raw_input",
        "proposal-or-target-manifest",
        "non_authoritative",
        "untrusted-current-request-input",
        "target-manifest",
        "target-input",
        "digest-only",
        "digest_visible_for_current_request_binding",
        false,
    );
    for receipt in &request.receipts {
        push_existing_path_candidate(
            repo_root,
            &mut candidates,
            &request.target.join(&receipt.path),
            SourceBucket::NonAuthoritative,
            "raw_input",
            "proposal-local-receipt",
            "non_authoritative",
            "untrusted-current-request-input",
            "route-receipt-observation",
            "target-input",
            "digest-only",
            "digest_visible_for_current_request_binding",
            false,
        );
    }

    Ok(candidates)
}

fn authority_candidate(path: &str, source_role: &'static str, required: bool) -> SourceCandidate {
    SourceCandidate {
        path: path.to_string(),
        bucket: SourceBucket::Authority,
        source_class: "authored_authority",
        surface_class: "authored-authority",
        authority_label: "authoritative",
        trust_class: "repo-local-authority",
        source_role,
        receipt_kind: "authority",
        inclusion_mode: "digest-only",
        policy_reason: "digest_visible_by_lifecycle_context_policy",
        required,
    }
}

fn derived_candidate(path: &str, source_role: &'static str, required: bool) -> SourceCandidate {
    SourceCandidate {
        path: path.to_string(),
        bucket: SourceBucket::Derived,
        source_class: "generated_derived",
        surface_class: "generated-derived",
        authority_label: "derived",
        trust_class: "freshness-checked-generated-handle",
        source_role,
        receipt_kind: "generated-handle",
        inclusion_mode: "handle-only",
        policy_reason: "handle_visible_by_lifecycle_context_policy",
        required,
    }
}

fn non_authoritative_candidate(
    path: &str,
    source_role: &'static str,
    required: bool,
) -> SourceCandidate {
    SourceCandidate {
        path: path.to_string(),
        bucket: SourceBucket::NonAuthoritative,
        source_class: "raw_input",
        surface_class: "non-authoritative-input",
        authority_label: "non_authoritative",
        trust_class: "untrusted-current-request-input",
        source_role,
        receipt_kind: "target-input",
        inclusion_mode: "digest-only",
        policy_reason: "digest_visible_for_current_request_binding",
        required,
    }
}

#[allow(clippy::too_many_arguments)]
fn push_existing_path_candidate(
    repo_root: &Path,
    candidates: &mut Vec<SourceCandidate>,
    path: &Path,
    bucket: SourceBucket,
    source_class: &'static str,
    surface_class: &'static str,
    authority_label: &'static str,
    trust_class: &'static str,
    source_role: &'static str,
    receipt_kind: &'static str,
    inclusion_mode: &'static str,
    policy_reason: &'static str,
    required: bool,
) {
    let rel = repo_rel(repo_root, path);
    if rel.is_empty() {
        return;
    }
    candidates.push(SourceCandidate {
        path: rel,
        bucket,
        source_class,
        surface_class,
        authority_label,
        trust_class,
        source_role,
        receipt_kind,
        inclusion_mode,
        policy_reason,
        required,
    });
}

fn source_summary(
    source_count: usize,
    authority_source_count: usize,
    derived_source_count: usize,
    non_authoritative_source_count: usize,
) -> Value {
    json!({
        "authority_source_count": authority_source_count,
        "evidence_source_count": 0,
        "derived_source_count": derived_source_count,
        "non_authoritative_source_count": non_authoritative_source_count,
        "required_source_count": source_count,
        "failed_required_source_count": 0,
    })
}

fn bucket_order(bucket: SourceBucket) -> u8 {
    match bucket {
        SourceBucket::Authority => 0,
        SourceBucket::Derived => 1,
        SourceBucket::NonAuthoritative => 2,
    }
}

fn resolve_repo_ref(repo_root: &Path, path: &str) -> PathBuf {
    let path = Path::new(path);
    if path.is_absolute() {
        path.to_path_buf()
    } else {
        repo_root.join(path)
    }
}

fn repo_rel(repo_root: &Path, path: &Path) -> String {
    let path = normalize_path(path);
    let repo_root = normalize_path(repo_root);
    path.strip_prefix(&repo_root)
        .ok()
        .unwrap_or(&path)
        .to_string_lossy()
        .trim_start_matches('/')
        .to_string()
}

fn normalize_path(path: &Path) -> PathBuf {
    let mut normalized = PathBuf::new();
    for component in path.components() {
        match component {
            Component::CurDir => {}
            Component::ParentDir => {
                normalized.pop();
            }
            other => normalized.push(other.as_os_str()),
        }
    }
    normalized
}

fn estimate_tokens(bytes: u64) -> u64 {
    bytes.saturating_add(3) / 4
}

fn write_context_json<T: Serialize>(path: &Path, value: &T) -> Result<(), LifecycleExecutionError> {
    let bytes = json_bytes(value)?;
    fs::write(path, bytes)?;
    Ok(())
}

fn write_context_json_bytes<T: Serialize>(
    path: &Path,
    value: &T,
) -> Result<Vec<u8>, LifecycleExecutionError> {
    let bytes = json_bytes(value)?;
    fs::write(path, &bytes)?;
    Ok(bytes)
}

fn json_bytes<T: Serialize>(value: &T) -> Result<Vec<u8>, LifecycleExecutionError> {
    let mut bytes = serde_json::to_vec_pretty(value).map_err(|error| {
        LifecycleExecutionError::new(LifecycleErrorClass::Io, error.to_string())
    })?;
    bytes.push(b'\n');
    Ok(bytes)
}

fn write_context_yaml(path: &Path, value: &Value) -> Result<(), LifecycleExecutionError> {
    fs::write(path, serde_yaml::to_string(value)?)?;
    Ok(())
}

fn sha256_file_prefixed(path: &Path) -> Result<String, LifecycleExecutionError> {
    let bytes = fs::read(path)?;
    Ok(format!("sha256:{}", sha256_bytes(&bytes)))
}

fn sha256_bytes(bytes: &[u8]) -> String {
    hex::encode(Sha256::digest(bytes))
}
