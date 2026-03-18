use crate::errors::{ErrorCode, KernelError, Result};
use crate::registry::{ServiceDescriptor, ServiceKey, ServiceManifestV1, ServiceRegistry};
use crate::schema::SchemaStore;
use semver::Version;
use sha2::{Digest, Sha256};
use std::collections::HashMap;
use std::path::Path;
use walkdir::WalkDir;

pub struct ServiceDiscovery;

impl ServiceDiscovery {
    pub fn discover(octon_dir: &Path, schemas: &SchemaStore) -> Result<ServiceRegistry> {
        let services_root = octon_dir
            .join("capabilities")
            .join("runtime")
            .join("services");
        if !services_root.is_dir() {
            return Ok(ServiceRegistry::default());
        }

        let mut by_key: HashMap<ServiceKey, ServiceDescriptor> = HashMap::new();

        for entry in WalkDir::new(&services_root)
            .follow_links(false)
            .into_iter()
            .filter_map(|e| e.ok())
        {
            if !entry.file_type().is_file() {
                continue;
            }
            if entry.file_name() != "service.json" {
                continue;
            }

            let service_json_path = entry.path().to_path_buf();
            let service_dir = service_json_path
                .parent()
                .map(Path::to_path_buf)
                .ok_or_else(|| KernelError::new(ErrorCode::Internal, "service.json has no parent dir"))?;

            let bytes = std::fs::read(&service_json_path).map_err(|e| {
                KernelError::new(
                    ErrorCode::Internal,
                    format!("failed to read {}: {e}", service_json_path.display()),
                )
            })?;

            let manifest_json: serde_json::Value = serde_json::from_slice(&bytes).map_err(|e| {
                KernelError::new(
                    ErrorCode::Internal,
                    format!("service.json is not valid JSON at {}: {e}", service_json_path.display()),
                )
            })?;

            schemas.validate_service_manifest(&manifest_json)?;

            let manifest: ServiceManifestV1 = serde_json::from_value(manifest_json).map_err(|e| {
                KernelError::new(
                    ErrorCode::Internal,
                    format!("service.json could not be decoded into ServiceManifestV1: {e}"),
                )
            })?;

            // Required behavior: format_version must match exactly.
            if manifest.format_version != "service-manifest-v1" {
                return Err(KernelError::new(
                    ErrorCode::Internal,
                    format!(
                        "service.json format_version must be 'service-manifest-v1' (got '{}')",
                        manifest.format_version
                    ),
                ));
            }

            let version = Version::parse(&manifest.version).map_err(|e| {
                KernelError::new(
                    ErrorCode::Internal,
                    format!("invalid semver '{}' in service.json: {e}", manifest.version),
                )
            })?;

            // Required behavior: entry must exist and be inside the same service folder.
            let wasm_path = service_dir.join(&manifest.entry);
            if !wasm_path.exists() {
                return Err(KernelError::new(
                    ErrorCode::Internal,
                    format!(
                        "service entry '{}' does not exist for {}",
                        wasm_path.display(),
                        service_json_path.display()
                    ),
                ));
            }
            if !wasm_path.is_file() {
                return Err(KernelError::new(
                    ErrorCode::Internal,
                    format!("service entry is not a file: {}", wasm_path.display()),
                ));
            }

            // Integrity verification (required if wasm_sha256 exists).
            if let Some(expected) = manifest
                .integrity
                .as_ref()
                .and_then(|i| i.wasm_sha256.as_ref())
            {
                let wasm_bytes = std::fs::read(&wasm_path).map_err(|e| {
                    KernelError::new(
                        ErrorCode::Internal,
                        format!("failed to read wasm entry for integrity check: {e}"),
                    )
                })?;
                let actual = hex::encode(Sha256::digest(&wasm_bytes));
                if actual.to_lowercase() != expected.to_lowercase() {
                    return Err(KernelError::new(
                        ErrorCode::Internal,
                        format!(
                            "integrity.wasm_sha256 mismatch for {} (expected {}, got {})",
                            wasm_path.display(),
                            expected,
                            actual
                        ),
                    ));
                }
            }

            let key = ServiceKey {
                category: manifest.category.clone(),
                name: manifest.name.clone(),
            };

            if by_key.contains_key(&key) {
                return Err(KernelError::new(
                    ErrorCode::Internal,
                    format!("duplicate service key discovered: {}", key.id()),
                ));
            }

            by_key.insert(
                key.clone(),
                ServiceDescriptor {
                    key,
                    version,
                    dir: service_dir,
                    wasm_path,
                    manifest,
                },
            );
        }

        Ok(ServiceRegistry::new(by_key))
    }
}
