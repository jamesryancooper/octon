use crate::errors::{LifecycleErrorClass, LifecycleExecutionError};
use anyhow::{Context, Result};
use octon_runtime_resolver::{
    generated_effective_extension_catalog_path, runtime_effective_route_bundle_path,
};
use serde_yaml::Value;
use sha2::{Digest, Sha256};
use std::fs;
use std::path::{Component, Path, PathBuf};

const PUBLISHED_EXTENSION_PREFIX: &str = ".octon/generated/effective/extensions/published/";
const WORKFLOW_RUNTIME_ROOT_REL: &str = ".octon/framework/orchestration/runtime/workflows/";

#[derive(Clone, Debug)]
pub struct PromptBundleAsset {
    pub id: String,
    pub role: String,
    pub role_class: Option<String>,
    pub bundle_path: String,
    pub path: PathBuf,
    pub source_path: PathBuf,
    pub sha256: String,
    pub content: String,
}

#[derive(Clone, Debug)]
pub struct PromptBundleRepoAnchor {
    pub path: String,
    pub sha256: String,
}

#[derive(Clone, Debug)]
pub struct PromptBundle {
    pub prompt_set_id: String,
    pub manifest_path: String,
    pub manifest_sha256: String,
    pub bundle_sha256: String,
    pub publication_status: String,
    pub alignment_status: Option<String>,
    pub alignment_receipt_path: Option<String>,
    pub required_repo_anchors: Vec<PromptBundleRepoAnchor>,
    pub assets: Vec<PromptBundleAsset>,
}

pub fn resolve_prompt_bundle(
    repo_root: &Path,
    catalog_path: &Path,
    owner_extension: &str,
    prompt_set_id: &str,
) -> Result<PromptBundle, LifecycleExecutionError> {
    let octon_dir = repo_root.join(".octon");
    ensure_exact_generated_file(
        repo_root,
        catalog_path,
        &generated_effective_extension_catalog_path(&octon_dir).map_err(|error| {
            LifecycleExecutionError::new(LifecycleErrorClass::Discovery, error.to_string())
        })?,
        "effective extension catalog",
    )?;
    let catalog: Value = serde_yaml::from_slice(&fs::read(catalog_path).map_err(|error| {
        LifecycleExecutionError::new(LifecycleErrorClass::Discovery, error.to_string())
    })?)
    .map_err(|error| {
        LifecycleExecutionError::new(LifecycleErrorClass::Discovery, error.to_string())
    })?;
    let packs = catalog
        .get("packs")
        .and_then(Value::as_sequence)
        .ok_or_else(|| {
            LifecycleExecutionError::new(
                LifecycleErrorClass::Discovery,
                "effective extension catalog has no packs",
            )
        })?;
    for pack in packs {
        if scalar(pack.get("pack_id")) != Some(owner_extension) {
            continue;
        }
        if !value_sequence_contains(pack.get("capability_profiles"), "prompt-bundle") {
            return Err(LifecycleExecutionError::new(
                LifecycleErrorClass::Discovery,
                format!(
                    "owner extension {owner_extension} is missing prompt-bundle capability profile"
                ),
            ));
        }
        let Some(bundles) = pack.get("prompt_bundles").and_then(Value::as_sequence) else {
            continue;
        };
        for bundle in bundles {
            if scalar(bundle.get("prompt_set_id")) != Some(prompt_set_id) {
                continue;
            }
            let publication_status =
                required_scalar(bundle, "publication_status", "prompt bundle")?.to_string();
            if !matches!(
                publication_status.as_str(),
                "published" | "published_with_quarantine"
            ) {
                return Err(LifecycleExecutionError::new(
                    LifecycleErrorClass::Discovery,
                    format!("prompt bundle {prompt_set_id} is not published: {publication_status}"),
                ));
            }
            let alignment_status = scalar(bundle.get("alignment_status")).map(str::to_string);
            if let Some(status) = alignment_status.as_deref() {
                if status != "fresh" {
                    return Err(LifecycleExecutionError::new(
                        LifecycleErrorClass::Discovery,
                        format!("prompt bundle {prompt_set_id} alignment is not fresh: {status}"),
                    ));
                }
            }
            let manifest_path =
                required_scalar(bundle, "manifest_path", "prompt bundle")?.to_string();
            let manifest_sha256 = normalized_required_sha256(
                required_scalar(bundle, "manifest_sha256", "prompt bundle")?,
                "manifest_sha256",
            )?;
            let bundle_sha256 = normalized_required_sha256(
                required_scalar(bundle, "bundle_sha256", "prompt bundle")?,
                "bundle_sha256",
            )?;
            let manifest_abs = resolve_existing_repo_path_under(
                repo_root,
                &manifest_path,
                ".octon/inputs/additive/extensions/",
                "prompt bundle manifest",
            )?;
            verify_file_sha256(&manifest_abs, &manifest_sha256, "prompt bundle manifest")?;
            let manifest_dir = manifest_abs.parent().ok_or_else(|| {
                LifecycleExecutionError::new(
                    LifecycleErrorClass::Discovery,
                    format!(
                        "prompt bundle manifest has no parent: {}",
                        manifest_abs.display()
                    ),
                )
            })?;
            let prompt_root = manifest_dir.parent().ok_or_else(|| {
                LifecycleExecutionError::new(
                    LifecycleErrorClass::Discovery,
                    format!(
                        "prompt bundle manifest has no prompt root: {}",
                        manifest_abs.display()
                    ),
                )
            })?;
            let required_repo_anchors = collect_repo_anchors(repo_root, bundle)?;
            let mut assets = Vec::new();
            collect_assets(
                repo_root,
                bundle,
                "prompt_assets",
                "prompt",
                manifest_dir,
                &mut assets,
            )?;
            collect_assets(
                repo_root,
                bundle,
                "reference_assets",
                "reference",
                manifest_dir,
                &mut assets,
            )?;
            collect_assets(
                repo_root,
                bundle,
                "shared_reference_assets",
                "shared-reference",
                prompt_root,
                &mut assets,
            )?;
            return Ok(PromptBundle {
                prompt_set_id: prompt_set_id.to_string(),
                manifest_path,
                manifest_sha256,
                bundle_sha256,
                publication_status,
                alignment_status,
                alignment_receipt_path: scalar(bundle.get("alignment_receipt_path"))
                    .map(str::to_string),
                required_repo_anchors,
                assets,
            });
        }
    }
    Err(LifecycleExecutionError::new(
        LifecycleErrorClass::Discovery,
        format!("prompt bundle not found in owner extension {owner_extension}: {prompt_set_id}"),
    ))
}

pub fn resolve_workflow_manifest(
    repo_root: &Path,
    runtime_route_bundle: &Path,
    route_id: &str,
) -> Result<PathBuf, LifecycleExecutionError> {
    let octon_dir = repo_root.join(".octon");
    ensure_exact_generated_file(
        repo_root,
        runtime_route_bundle,
        &runtime_effective_route_bundle_path(&octon_dir).map_err(|error| {
            LifecycleExecutionError::new(LifecycleErrorClass::Discovery, error.to_string())
        })?,
        "runtime route bundle",
    )?;
    if !runtime_route_bundle.is_file() {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!(
                "runtime route bundle missing: {}",
                runtime_route_bundle.display()
            ),
        ));
    }
    let route_bundle: Value =
        serde_yaml::from_slice(&fs::read(runtime_route_bundle).map_err(|error| {
            LifecycleExecutionError::new(LifecycleErrorClass::Discovery, error.to_string())
        })?)
        .map_err(|error| {
            LifecycleExecutionError::new(LifecycleErrorClass::Discovery, error.to_string())
        })?;
    let manifest_ref = scalar(
        route_bundle
            .get("source_refs")
            .and_then(|source_refs| source_refs.get("workflow_manifest_ref")),
    )
    .ok_or_else(|| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            "runtime route bundle has no source_refs.workflow_manifest_ref",
        )
    })?;
    let workflow_manifest = resolve_existing_repo_path_under(
        repo_root,
        manifest_ref,
        WORKFLOW_RUNTIME_ROOT_REL,
        "workflow manifest ref",
    )?;
    let manifest: Value =
        serde_yaml::from_slice(&fs::read(&workflow_manifest).map_err(|error| {
            LifecycleExecutionError::new(LifecycleErrorClass::Discovery, error.to_string())
        })?)
        .map_err(|error| {
            LifecycleExecutionError::new(LifecycleErrorClass::Discovery, error.to_string())
        })?;
    let workflows = manifest
        .get("workflows")
        .and_then(Value::as_sequence)
        .ok_or_else(|| {
            LifecycleExecutionError::new(
                LifecycleErrorClass::Discovery,
                "workflow manifest has no workflows",
            )
        })?;
    for workflow in workflows {
        if scalar(workflow.get("id")) == Some(route_id) {
            let path = scalar(workflow.get("path")).ok_or_else(|| {
                LifecycleExecutionError::new(
                    LifecycleErrorClass::Discovery,
                    format!("workflow route {route_id} has no path"),
                )
            })?;
            let workflow_root = repo_root.join(WORKFLOW_RUNTIME_ROOT_REL);
            let full = resolve_existing_child_file_under(
                &workflow_root,
                path,
                "workflow.yml",
                "workflow route path",
            )?;
            if full.is_file() {
                return Ok(full);
            }
            return Err(LifecycleExecutionError::new(
                LifecycleErrorClass::Discovery,
                format!(
                    "workflow contract missing for {route_id}: {}",
                    full.display()
                ),
            ));
        }
    }
    Err(LifecycleExecutionError::new(
        LifecycleErrorClass::Discovery,
        format!("workflow route not found: {route_id}"),
    ))
}

fn collect_assets(
    repo_root: &Path,
    bundle: &Value,
    key: &str,
    role: &str,
    source_root: &Path,
    assets: &mut Vec<PromptBundleAsset>,
) -> Result<(), LifecycleExecutionError> {
    let Some(items) = bundle.get(key).and_then(Value::as_sequence) else {
        return Ok(());
    };
    for item in items {
        let Some(raw) = scalar(item.get("projection_source_path")) else {
            return Err(LifecycleExecutionError::new(
                LifecycleErrorClass::Discovery,
                format!("{key} asset is missing projection_source_path"),
            ));
        };
        let path = resolve_existing_repo_path_under(
            repo_root,
            raw,
            PUBLISHED_EXTENSION_PREFIX,
            "prompt asset projection",
        )?;
        let id = scalar(item.get("prompt_id"))
            .or_else(|| scalar(item.get("ref_id")))
            .unwrap_or(role)
            .to_string();
        let Some(bundle_path) = scalar(item.get("path")) else {
            return Err(LifecycleExecutionError::new(
                LifecycleErrorClass::Discovery,
                format!("{key} asset is missing path"),
            ));
        };
        let expected_sha256 = normalized_required_sha256(
            required_scalar(item, "sha256", key)?,
            &format!("{key} sha256"),
        )?;
        let source_path =
            resolve_existing_child_path_under(source_root, bundle_path, "prompt source asset")?;
        verify_file_sha256(&source_path, &expected_sha256, "prompt source asset")?;
        verify_file_sha256(&path, &expected_sha256, "prompt asset projection")?;
        let content = fs::read_to_string(&path)
            .with_context(|| format!("read prompt asset {}", path.display()))
            .map_err(LifecycleExecutionError::from)?;
        assets.push(PromptBundleAsset {
            id,
            role: role.to_string(),
            role_class: scalar(item.get("role_class")).map(str::to_string),
            bundle_path: bundle_path.to_string(),
            path,
            source_path,
            sha256: expected_sha256,
            content,
        });
    }
    Ok(())
}

fn collect_repo_anchors(
    repo_root: &Path,
    bundle: &Value,
) -> Result<Vec<PromptBundleRepoAnchor>, LifecycleExecutionError> {
    let mut anchors = Vec::new();
    let Some(items) = bundle
        .get("required_repo_anchors")
        .and_then(Value::as_sequence)
    else {
        return Ok(anchors);
    };
    for item in items {
        let path = required_scalar(item, "path", "required repo anchor")?.to_string();
        let sha256 = normalized_required_sha256(
            required_scalar(item, "sha256", "required repo anchor")?,
            "required repo anchor sha256",
        )?;
        let anchor_path = resolve_existing_repo_path(repo_root, &path, "required repo anchor")?;
        verify_file_sha256(&anchor_path, &sha256, "required repo anchor")?;
        anchors.push(PromptBundleRepoAnchor { path, sha256 });
    }
    Ok(anchors)
}

fn ensure_exact_generated_file(
    _repo_root: &Path,
    path: &Path,
    expected_path: &Path,
    label: &str,
) -> Result<(), LifecycleExecutionError> {
    let expected = expected_path.canonicalize().map_err(|error| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!(
                "{label} missing at generated effective projection {}: {error}",
                expected_path.display()
            ),
        )
    })?;
    let actual = path.canonicalize().map_err(|error| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!(
                "{label} path is not a generated effective file: {}: {error}",
                path.display()
            ),
        )
    })?;
    if actual != expected {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!(
                "{label} must be resolved from generated effective projection {}: {}",
                expected_path.display(),
                path.display()
            ),
        ));
    }
    Ok(())
}

fn resolve_existing_repo_path_under(
    repo_root: &Path,
    raw: &str,
    required_prefix: &str,
    label: &str,
) -> Result<PathBuf, LifecycleExecutionError> {
    if !is_safe_repo_relative(raw) || !raw.starts_with(required_prefix) {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!("{label} is outside required generated/runtime root {required_prefix}: {raw}"),
        ));
    }
    let path = repo_root.join(raw);
    let root = repo_root
        .join(required_prefix)
        .canonicalize()
        .map_err(|error| {
            LifecycleExecutionError::new(
                LifecycleErrorClass::Discovery,
                format!("{label} root is missing {required_prefix}: {error}"),
            )
        })?;
    let canonical = path.canonicalize().map_err(|error| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!(
                "{label} projection missing or unreadable: {}: {error}",
                path.display()
            ),
        )
    })?;
    if !canonical.starts_with(&root) {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!("{label} escapes required generated/runtime root {required_prefix}: {raw}"),
        ));
    }
    Ok(path)
}

fn resolve_existing_repo_path(
    repo_root: &Path,
    raw: &str,
    label: &str,
) -> Result<PathBuf, LifecycleExecutionError> {
    if !is_safe_repo_relative(raw) {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!("{label} must be repo-relative without traversal: {raw}"),
        ));
    }
    let root = repo_root.canonicalize().map_err(|error| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!(
                "{label} repo root is missing: {}: {error}",
                repo_root.display()
            ),
        )
    })?;
    let path = repo_root.join(raw);
    let canonical = path.canonicalize().map_err(|error| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!("{label} missing or unreadable: {}: {error}", path.display()),
        )
    })?;
    if !canonical.starts_with(&root) {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!("{label} escapes repo root: {raw}"),
        ));
    }
    Ok(path)
}

fn resolve_existing_child_path_under(
    root: &Path,
    raw: &str,
    label: &str,
) -> Result<PathBuf, LifecycleExecutionError> {
    if !is_safe_repo_relative(raw) {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!("{label} must be repo-relative without traversal: {raw}"),
        ));
    }
    let root_canonical = root.canonicalize().map_err(|error| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!("{label} root is missing: {}: {error}", root.display()),
        )
    })?;
    let path = root.join(raw);
    let canonical = path.canonicalize().map_err(|error| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!("{label} missing or unreadable: {}: {error}", path.display()),
        )
    })?;
    if !canonical.starts_with(&root_canonical) {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!("{label} escapes source root: {raw}"),
        ));
    }
    Ok(path)
}

fn resolve_existing_child_file_under(
    root: &Path,
    raw: &str,
    leaf: &str,
    label: &str,
) -> Result<PathBuf, LifecycleExecutionError> {
    if !is_safe_repo_relative(raw) {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!("{label} must be repo-relative without traversal: {raw}"),
        ));
    }
    let root_canonical = root.canonicalize().map_err(|error| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!("{label} root is missing: {}: {error}", root.display()),
        )
    })?;
    let path = root.join(raw).join(leaf);
    let canonical = path.canonicalize().map_err(|error| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!("{label} missing or unreadable: {}: {error}", path.display()),
        )
    })?;
    if !canonical.starts_with(&root_canonical) {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!("{label} escapes workflow runtime root: {raw}"),
        ));
    }
    Ok(path)
}

fn is_safe_repo_relative(raw: &str) -> bool {
    !raw.is_empty()
        && !Path::new(raw).is_absolute()
        && Path::new(raw)
            .components()
            .all(|component| matches!(component, Component::Normal(_)))
}

fn scalar(value: Option<&Value>) -> Option<&str> {
    value.and_then(|value| match value {
        Value::String(raw) => Some(raw.as_str()),
        _ => None,
    })
}

fn required_scalar<'a>(
    value: &'a Value,
    key: &str,
    label: &str,
) -> Result<&'a str, LifecycleExecutionError> {
    scalar(value.get(key)).ok_or_else(|| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!("{label} is missing {key}"),
        )
    })
}

fn normalized_required_sha256(raw: &str, label: &str) -> Result<String, LifecycleExecutionError> {
    let value = raw.strip_prefix("sha256:").unwrap_or(raw);
    if value.len() != 64 || !value.chars().all(|char| char.is_ascii_hexdigit()) {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!("{label} must be a sha256 digest"),
        ));
    }
    Ok(value.to_ascii_lowercase())
}

fn verify_file_sha256(
    path: &Path,
    expected_sha256: &str,
    label: &str,
) -> Result<(), LifecycleExecutionError> {
    let bytes = fs::read(path).map_err(|error| {
        LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!("{label} unreadable: {}: {error}", path.display()),
        )
    })?;
    let actual = hex::encode(Sha256::digest(&bytes));
    if actual != expected_sha256 {
        return Err(LifecycleExecutionError::new(
            LifecycleErrorClass::Discovery,
            format!(
                "{label} digest mismatch for {}: expected sha256:{expected_sha256} actual sha256:{actual}",
                path.display()
            ),
        ));
    }
    Ok(())
}

fn value_sequence_contains(value: Option<&Value>, expected: &str) -> bool {
    value
        .and_then(Value::as_sequence)
        .map(|items| items.iter().any(|item| item.as_str() == Some(expected)))
        .unwrap_or(false)
}
