use crate::errors::{LifecycleErrorClass, LifecycleExecutionError};
use anyhow::{Context, Result};
use octon_runtime_resolver::{
    generated_effective_extension_catalog_path, runtime_effective_route_bundle_path,
};
use serde_yaml::Value;
use std::fs;
use std::path::{Component, Path, PathBuf};

const PUBLISHED_EXTENSION_PREFIX: &str = ".octon/generated/effective/extensions/published/";
const WORKFLOW_RUNTIME_ROOT_REL: &str = ".octon/framework/orchestration/runtime/workflows/";

#[derive(Clone, Debug)]
pub struct PromptBundleAsset {
    pub role: String,
    pub path: PathBuf,
    pub content: String,
}

#[derive(Clone, Debug)]
pub struct PromptBundle {
    pub prompt_set_id: String,
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
            let mut assets = Vec::new();
            collect_assets(repo_root, bundle, "prompt_assets", "prompt", &mut assets)?;
            collect_assets(
                repo_root,
                bundle,
                "reference_assets",
                "reference",
                &mut assets,
            )?;
            collect_assets(
                repo_root,
                bundle,
                "shared_reference_assets",
                "shared-reference",
                &mut assets,
            )?;
            return Ok(PromptBundle {
                prompt_set_id: prompt_set_id.to_string(),
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
        let content = fs::read_to_string(&path)
            .with_context(|| format!("read prompt asset {}", path.display()))
            .map_err(LifecycleExecutionError::from)?;
        assets.push(PromptBundleAsset {
            role: role.to_string(),
            path,
            content,
        });
    }
    Ok(())
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

fn value_sequence_contains(value: Option<&Value>, expected: &str) -> bool {
    value
        .and_then(Value::as_sequence)
        .map(|items| items.iter().any(|item| item.as_str() == Some(expected)))
        .unwrap_or(false)
}
