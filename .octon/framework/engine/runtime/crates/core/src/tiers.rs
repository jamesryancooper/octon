use crate::errors::{ErrorCode, KernelError, Result};
use crate::registry::{ServiceKey, ServiceRegistry};
use serde::Deserialize;
use serde_json::json;
use std::collections::{BTreeMap, BTreeSet};
use std::path::{Component, Path, PathBuf};

const MANIFEST_FILE: &str = "manifest.runtime.yml";
const REGISTRY_FILE: &str = "registry.runtime.yml";

#[derive(Debug, Clone)]
pub struct RuntimeTierValidation {
    pub manifest_path: PathBuf,
    pub registry_path: PathBuf,
    pub service_count: usize,
}

#[derive(Debug, Deserialize)]
struct ServicesManifestV1 {
    format_version: String,
    services: Vec<ManifestServiceEntry>,
}

#[derive(Debug, Deserialize)]
struct ManifestServiceEntry {
    id: String,
    name: String,
    category: String,
    summary: String,
    #[serde(default)]
    triggers: Vec<String>,
    runtime: ManifestRuntime,
}

#[derive(Debug, Deserialize)]
struct ManifestRuntime {
    #[serde(rename = "type")]
    runtime_type: String,
    path: String,
}

#[derive(Debug, Deserialize)]
struct ServicesRegistryV1 {
    format_version: String,
    #[serde(default)]
    services: BTreeMap<String, serde_yaml::Value>,
}

pub fn validate_runtime_discovery_tiers(
    octon_dir: &Path,
    discovered: &ServiceRegistry,
) -> Result<Option<RuntimeTierValidation>> {
    let services_dir = octon_dir
        .join("capabilities")
        .join("runtime")
        .join("services");
    let manifest_path = services_dir.join(MANIFEST_FILE);
    if !manifest_path.is_file() {
        return Ok(None);
    }

    let registry_path = services_dir.join(REGISTRY_FILE);
    if !registry_path.is_file() {
        return Err(KernelError::new(
            ErrorCode::Internal,
            format!(
                "runtime tier manifest exists but {} is missing",
                registry_path.display()
            ),
        ));
    }

    let manifest: ServicesManifestV1 = parse_yaml(&manifest_path)?;
    if manifest.format_version != "services-manifest-v1" {
        return Err(KernelError::new(
            ErrorCode::Internal,
            format!(
                "invalid runtime services manifest format_version '{}' (expected services-manifest-v1)",
                manifest.format_version
            ),
        ));
    }

    let mut seen_ids = BTreeSet::new();
    for svc in &manifest.services {
        if !seen_ids.insert(svc.id.clone()) {
            return Err(KernelError::new(
                ErrorCode::Internal,
                format!("duplicate runtime service id '{}'", svc.id),
            ));
        }

        let expected_id = format!("{}/{}", svc.category, svc.name);
        if svc.id != expected_id {
            return Err(KernelError::new(
                ErrorCode::Internal,
                format!(
                    "runtime service id '{}' must equal '{}/{}'",
                    svc.id, svc.category, svc.name
                ),
            ));
        }

        if svc.summary.trim().is_empty() {
            return Err(KernelError::new(
                ErrorCode::Internal,
                format!("runtime service '{}' has an empty summary", svc.id),
            ));
        }

        // Keep routing triggers compact and non-empty for Tier 1.
        if svc.triggers.iter().any(|t| t.trim().is_empty()) {
            return Err(KernelError::new(
                ErrorCode::Internal,
                format!("runtime service '{}' contains an empty trigger", svc.id),
            ));
        }

        let rel_path = sanitize_relative_path(&svc.runtime.path)?;
        let abs_path = services_dir.join(&rel_path);
        if !abs_path.is_file() {
            return Err(KernelError::new(
                ErrorCode::Internal,
                format!(
                    "runtime.path '{}' for '{}' does not exist",
                    svc.runtime.path, svc.id
                ),
            ));
        }

        match svc.runtime.runtime_type.as_str() {
            "wasm" => {
                if rel_path.file_name().and_then(|x| x.to_str()) != Some("service.json") {
                    return Err(KernelError::new(
                        ErrorCode::Internal,
                        format!(
                            "runtime.path '{}' for '{}' must point to service.json",
                            svc.runtime.path, svc.id
                        ),
                    ));
                }

                let key = ServiceKey {
                    category: svc.category.clone(),
                    name: svc.name.clone(),
                };
                let desc = discovered.get(&key).ok_or_else(|| {
                    KernelError::new(
                        ErrorCode::Internal,
                        format!(
                            "runtime tier entry '{}' not found in discovered service registry",
                            svc.id
                        ),
                    )
                })?;
                let discovered_path = desc.dir.join("service.json");
                let discovered_rel = discovered_path.strip_prefix(&services_dir).map_err(|_| {
                    KernelError::new(
                        ErrorCode::Internal,
                        "discovered service path escaped services directory",
                    )
                })?;
                if discovered_rel != rel_path {
                    return Err(KernelError::new(
                        ErrorCode::Internal,
                        format!(
                            "runtime.path mismatch for '{}': expected '{}', discovered '{}'",
                            svc.id,
                            rel_path.display(),
                            discovered_rel.display()
                        ),
                    ));
                }
            }
            other => {
                return Err(KernelError::new(
                    ErrorCode::Internal,
                    format!(
                        "unsupported runtime.type '{}' for '{}' (expected wasm)",
                        other, svc.id
                    ),
                ));
            }
        }
    }

    let registry: ServicesRegistryV1 = parse_yaml(&registry_path)?;
    if registry.format_version != "services-registry-v1" {
        return Err(KernelError::new(
            ErrorCode::Internal,
            format!(
                "invalid runtime services registry format_version '{}' (expected services-registry-v1)",
                registry.format_version
            ),
        ));
    }

    // Registry keys must match Tier 1 IDs.
    let registry_ids: BTreeSet<String> = registry.services.keys().cloned().collect();
    if registry_ids != seen_ids {
        let missing_in_registry: Vec<String> = seen_ids
            .difference(&registry_ids)
            .cloned()
            .collect();
        let missing_in_manifest: Vec<String> = registry_ids
            .difference(&seen_ids)
            .cloned()
            .collect();

        return Err(KernelError::new(
            ErrorCode::Internal,
            "runtime tier manifest/registry id mismatch",
        )
        .with_details(json!({
            "missing_in_registry": missing_in_registry,
            "missing_in_manifest": missing_in_manifest,
        })));
    }

    Ok(Some(RuntimeTierValidation {
        manifest_path,
        registry_path,
        service_count: seen_ids.len(),
    }))
}

fn parse_yaml<T: for<'de> Deserialize<'de>>(path: &Path) -> Result<T> {
    let bytes = std::fs::read(path).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to read {}: {e}", path.display()),
        )
    })?;

    serde_yaml::from_slice::<T>(&bytes).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("invalid YAML at {}: {e}", path.display()),
        )
    })
}

fn sanitize_relative_path(path: &str) -> Result<PathBuf> {
    if path.trim().is_empty() {
        return Err(KernelError::new(
            ErrorCode::Internal,
            "runtime.path cannot be empty",
        ));
    }

    let p = Path::new(path);
    let mut out = PathBuf::new();
    for c in p.components() {
        match c {
            Component::Normal(seg) => out.push(seg),
            Component::CurDir => {}
            Component::ParentDir => {
                return Err(KernelError::new(
                    ErrorCode::Internal,
                    format!("runtime.path '{}' cannot contain '..'", path),
                ))
            }
            Component::RootDir | Component::Prefix(_) => {
                return Err(KernelError::new(
                    ErrorCode::Internal,
                    format!("runtime.path '{}' must be relative", path),
                ))
            }
        }
    }

    if out.as_os_str().is_empty() {
        return Err(KernelError::new(
            ErrorCode::Internal,
            "runtime.path resolves to empty",
        ));
    }

    Ok(out)
}
