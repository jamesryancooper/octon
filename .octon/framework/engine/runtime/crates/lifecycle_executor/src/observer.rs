use crate::request::{LifecycleReceiptSpec, LifecycleRouteExecutionRequest};
use crate::result::{LifecycleRouteCompletionObservation, ReceiptObservation};
use crate::{LifecycleErrorClass, LifecycleExecutionError};
use anyhow::{bail, Context, Result};
use serde_yaml::Value;
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;
use std::fs;
use std::path::{Component, Path, PathBuf};
use walkdir::WalkDir;

pub fn validate_request_paths(
    request: &LifecycleRouteExecutionRequest,
) -> std::result::Result<(), LifecycleExecutionError> {
    validate_request_path(&request.target, &request.manifest_path, "manifest path")?;
    for receipt in &request.receipts {
        validate_request_path(
            &request.target,
            &receipt.path,
            &format!("receipt path {}", receipt.receipt_id),
        )?;
    }
    for path in &request.expected_paths {
        validate_request_path(&request.target, path, "completion expected path")?;
    }
    Ok(())
}

fn validate_request_path(
    target: &Path,
    raw: &str,
    label: &str,
) -> std::result::Result<(), LifecycleExecutionError> {
    target_local_path(target, raw, label)
        .map(|_| ())
        .map_err(|error| {
            LifecycleExecutionError::new(LifecycleErrorClass::ReceiptInvalid, error.to_string())
        })
}

pub fn manifest_status(
    target: &Path,
    manifest_path: &str,
    status_field: &str,
) -> Result<Option<String>> {
    let path = target_local_path(target, manifest_path, "manifest path")?;
    if !path.is_file() {
        return Ok(None);
    }
    let value: Value = serde_yaml::from_slice(&fs::read(path)?)?;
    Ok(lookup_dotted_field(&value, status_field).and_then(scalar_string))
}

pub fn observe_completion(
    request: &LifecycleRouteExecutionRequest,
    before_status: Option<String>,
    before_target_digest: Option<String>,
) -> Result<LifecycleRouteCompletionObservation> {
    let after_status = manifest_status(
        &request.target,
        &request.manifest_path,
        &request.status_field,
    )?;
    let receipts = observe_receipts(&request.target, &request.receipts)?;
    let mut missing_expected_paths = Vec::new();
    for expected in &request.expected_paths {
        let path = target_local_path(&request.target, expected, "completion expected path")?;
        if !path.exists() {
            missing_expected_paths.push(path);
        }
    }
    let after_target_digest = if request.expected_target_change {
        Some(target_digest(&request.target)?)
    } else {
        None
    };
    let receipts_satisfied = request.expected_receipts.iter().all(|expected| {
        receipts
            .iter()
            .any(|receipt| &receipt.receipt_id == expected && receipt.exists && receipt.complete)
    });
    let paths_satisfied = missing_expected_paths.is_empty();
    let manifest_satisfied = request
        .expected_manifest_status
        .as_ref()
        .map(|expected| after_status.as_deref() == Some(expected.as_str()))
        .unwrap_or(true);
    let target_change_satisfied = if request.expected_target_change {
        before_target_digest.is_some()
            && after_target_digest.is_some()
            && before_target_digest != after_target_digest
    } else {
        true
    };
    let explicit_completion = !request.expected_receipts.is_empty()
        || !request.expected_paths.is_empty()
        || request.expected_manifest_status.is_some()
        || request.expected_target_change;
    let completion_observed = if explicit_completion {
        receipts_satisfied && paths_satisfied && manifest_satisfied && target_change_satisfied
    } else {
        before_status != after_status
    };
    let completion_message = if completion_observed {
        "route completion observed".to_string()
    } else if explicit_completion {
        "route completion not observed from route-specific expectations".to_string()
    } else {
        "route completion not observed from manifest status change".to_string()
    };
    Ok(LifecycleRouteCompletionObservation {
        schema_version: "octon-lifecycle-route-completion-observation-v1".to_string(),
        route_id: request.route.route_id.clone(),
        manifest_status_before: before_status,
        manifest_status_after: after_status,
        expected_manifest_status: request.expected_manifest_status.clone(),
        receipts_observed: receipts,
        expected_receipts: request.expected_receipts.clone(),
        expected_paths: request.expected_paths.clone(),
        missing_expected_paths,
        expected_target_change: request.expected_target_change,
        target_digest_before: before_target_digest,
        target_digest_after: after_target_digest,
        completion_observed,
        completion_message,
    })
}

pub fn target_digest(target: &Path) -> Result<String> {
    if !target.exists() {
        return Ok(
            "sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855".to_string(),
        );
    }
    let mut rels = Vec::new();
    for entry in WalkDir::new(target)
        .into_iter()
        .filter_map(std::result::Result::ok)
    {
        if entry.file_type().is_file() {
            rels.push(
                entry
                    .path()
                    .strip_prefix(target)?
                    .to_string_lossy()
                    .replace('\\', "/"),
            );
        }
    }
    rels.sort();
    let mut hashes = String::new();
    for rel in rels {
        let hash = hex::encode(Sha256::digest(fs::read(target.join(&rel))?));
        hashes.push_str(&format!("{hash}  {rel}\n"));
    }
    Ok(format!(
        "sha256:{}",
        hex::encode(Sha256::digest(hashes.as_bytes()))
    ))
}

pub fn observe_receipts(
    target: &Path,
    specs: &[LifecycleReceiptSpec],
) -> Result<Vec<ReceiptObservation>> {
    let mut observations = Vec::new();
    for spec in specs {
        let path = target_local_path(
            target,
            &spec.path,
            &format!("receipt path {}", spec.receipt_id),
        )?;
        let exists = path.is_file();
        let fields = if path.is_file() {
            parse_receipt_fields(&path)?
        } else {
            BTreeMap::new()
        };
        let missing_required_fields = spec
            .required_fields
            .iter()
            .filter(|field| {
                fields
                    .get(field.as_str())
                    .map(|value| value.trim().is_empty())
                    .unwrap_or(true)
            })
            .cloned()
            .collect::<Vec<_>>();
        let verdict_field = spec.verdict_field.as_deref().unwrap_or("verdict");
        observations.push(ReceiptObservation {
            receipt_id: spec.receipt_id.clone(),
            path,
            exists,
            complete: missing_required_fields.is_empty() && exists,
            verdict: fields.get(verdict_field).cloned(),
            missing_required_fields,
            fields,
        });
    }
    Ok(observations)
}

fn target_local_path(target: &Path, raw: &str, label: &str) -> Result<PathBuf> {
    let path = Path::new(raw);
    if path.as_os_str().is_empty() {
        bail!("{label} must not be empty");
    }
    if path.is_absolute()
        || !path
            .components()
            .all(|component| matches!(component, Component::Normal(_)))
    {
        bail!(
            "{label} must be target-relative and must not contain . or .. traversal: {}",
            path.display()
        );
    }
    let candidate = target.join(path);
    if target.exists() {
        let canonical_target = target.canonicalize().with_context(|| {
            format!(
                "failed to canonicalize lifecycle target {}",
                target.display()
            )
        })?;
        ensure_existing_components_stay_in_target(target, &canonical_target, path, label)?;
        let anchor = nearest_existing_ancestor(&candidate).with_context(|| {
            format!(
                "failed to resolve nearest existing ancestor for {label}: {}",
                path.display()
            )
        })?;
        let canonical_anchor = anchor.canonicalize().with_context(|| {
            format!(
                "failed to canonicalize existing ancestor for {label}: {}",
                anchor.display()
            )
        })?;
        if !canonical_anchor.starts_with(&canonical_target) {
            bail!(
                "{label} existing ancestor escapes target root: {} -> {}",
                anchor.display(),
                canonical_anchor.display()
            );
        }
    }
    Ok(candidate)
}

fn ensure_existing_components_stay_in_target(
    target: &Path,
    canonical_target: &Path,
    path: &Path,
    label: &str,
) -> Result<()> {
    let mut current = target.to_path_buf();
    for component in path.components() {
        let Component::Normal(part) = component else {
            bail!(
                "{label} must be target-relative and must not contain . or .. traversal: {}",
                path.display()
            );
        };
        current.push(part);
        match fs::symlink_metadata(&current) {
            Ok(metadata) => {
                if metadata.file_type().is_symlink() {
                    let canonical = current.canonicalize().with_context(|| {
                        format!(
                            "{label} contains unresolved symlink component: {}",
                            current.display()
                        )
                    })?;
                    if !canonical.starts_with(canonical_target) {
                        bail!(
                            "{label} symlink component escapes target root: {} -> {}",
                            current.display(),
                            canonical.display()
                        );
                    }
                }
            }
            Err(error) if error.kind() == std::io::ErrorKind::NotFound => break,
            Err(error) => {
                return Err(error).with_context(|| {
                    format!(
                        "failed to inspect existing component for {label}: {}",
                        current.display()
                    )
                });
            }
        }
    }
    Ok(())
}

fn nearest_existing_ancestor(path: &Path) -> Option<PathBuf> {
    let mut current = path.to_path_buf();
    loop {
        if current.exists() {
            return Some(current);
        }
        if !current.pop() {
            return None;
        }
    }
}

fn parse_receipt_fields(path: &PathBuf) -> Result<BTreeMap<String, String>> {
    let content = fs::read_to_string(path)?;
    let mut fields = BTreeMap::new();
    for line in content.lines() {
        let trimmed = line.trim();
        if trimmed.is_empty() || trimmed.starts_with('#') {
            continue;
        }
        if let Some((key, value)) = trimmed.split_once(':') {
            let key = key.trim();
            if is_receipt_key(key) {
                fields.insert(key.to_string(), clean_scalar(value.trim()));
            }
        } else if trimmed.starts_with('|') && trimmed.ends_with('|') {
            let cells = trimmed
                .trim_matches('|')
                .split('|')
                .map(str::trim)
                .collect::<Vec<_>>();
            if cells.len() >= 2 && is_receipt_key(cells[0]) {
                fields.insert(cells[0].to_string(), clean_scalar(cells[1]));
            }
        }
    }
    Ok(fields)
}

fn is_receipt_key(value: &str) -> bool {
    !value.is_empty()
        && value
            .chars()
            .all(|ch| ch.is_ascii_alphanumeric() || ch == '_' || ch == '-')
}

fn clean_scalar(value: &str) -> String {
    let mut cleaned = value
        .trim()
        .trim_matches('"')
        .trim_matches('\'')
        .to_string();
    if cleaned.starts_with('`') && cleaned.ends_with('`') && cleaned.len() >= 2 {
        cleaned = cleaned.trim_matches('`').to_string();
    }
    cleaned
}

fn lookup_dotted_field<'a>(value: &'a Value, field: &str) -> Option<&'a Value> {
    let mut current = value;
    for part in field.split('.') {
        current = current.get(part)?;
    }
    Some(current)
}

fn scalar_string(value: &Value) -> Option<String> {
    match value {
        Value::String(raw) => Some(raw.clone()),
        _ => None,
    }
}
