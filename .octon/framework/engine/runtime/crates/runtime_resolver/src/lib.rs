use anyhow::{anyhow, Context, Result};
use serde::Deserialize;
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};
use time::format_description::well_known::Rfc3339;
use time::OffsetDateTime;

mod handles;

pub use handles::{
    runtime_effective_handle_present, verify_runtime_effective_handle, VerifiedRuntimeHandle,
};

#[derive(Debug, Clone, Deserialize)]
pub struct RuntimeResolutionRecord {
    pub schema_version: String,
    pub runtime_effective_route_bundle_ref: String,
    pub runtime_effective_route_bundle_lock_ref: String,
    #[serde(default)]
    pub pack_routes_effective_ref: String,
    #[serde(default)]
    pub pack_routes_lock_ref: String,
    #[serde(default)]
    pub support_target_matrix_ref: String,
    #[serde(default)]
    pub extensions_catalog_ref: String,
    #[serde(default)]
    pub extensions_generation_lock_ref: String,
}

#[derive(Debug, Clone, Deserialize, Default)]
pub struct RuntimeSupportTupleRecord {
    #[serde(default)]
    pub model_tier: String,
    #[serde(default)]
    pub workload_tier: String,
    #[serde(default)]
    pub language_resource_tier: String,
    #[serde(default)]
    pub locale_tier: String,
    #[serde(default)]
    pub host_adapter: String,
    #[serde(default)]
    pub model_adapter: String,
}

#[derive(Debug, Clone)]
pub struct RuntimeSupportTupleRef {
    pub model_tier: String,
    pub workload_tier: String,
    pub language_resource_tier: String,
    pub locale_tier: String,
    pub host_adapter: String,
    pub model_adapter: String,
}

#[derive(Debug, Clone, Deserialize, Default)]
pub struct RuntimePackRoute {
    #[serde(default)]
    pub tuple_id: String,
    #[serde(default)]
    pub tuple: RuntimeSupportTupleRecord,
    #[serde(default)]
    pub claim_effect: String,
    #[serde(default)]
    pub route: String,
    #[serde(default)]
    pub requires_mission: bool,
    #[serde(default)]
    pub allowed_capability_packs: Vec<String>,
}

#[derive(Debug, Clone, Deserialize, Default)]
pub struct RuntimeExtensionState {
    #[serde(default)]
    pub generation_id: String,
    #[serde(default)]
    pub status: String,
    #[serde(default)]
    pub quarantine_count: u64,
}

#[derive(Debug, Clone, Deserialize, Default)]
pub struct RuntimeEffectiveRouteBundle {
    pub schema_version: String,
    pub generation_id: String,
    #[serde(default)]
    pub publication_status: String,
    #[serde(default)]
    pub publication_receipt_path: String,
    #[serde(default)]
    pub routes: Vec<RuntimePackRoute>,
    #[serde(default)]
    pub extensions: RuntimeExtensionState,
}

#[derive(Debug, Clone, Deserialize, Default)]
pub struct RuntimeHandleFreshness {
    #[serde(default)]
    pub mode: String,
    #[serde(default)]
    pub ttl_seconds: Option<i64>,
    #[serde(default)]
    pub invalidation_conditions: Vec<String>,
}

#[derive(Debug, Clone, Deserialize, Default)]
pub struct RuntimeEffectiveRouteBundleLock {
    pub schema_version: String,
    pub generation_id: String,
    #[serde(default)]
    pub published_at: String,
    #[serde(default)]
    pub publication_status: String,
    #[serde(default)]
    pub publication_receipt_path: String,
    #[serde(default)]
    pub publication_receipt_sha256: String,
    #[serde(default)]
    pub route_bundle_ref: String,
    #[serde(default)]
    pub route_bundle_sha256: String,
    #[serde(default)]
    pub runtime_resolution_sha256: String,
    #[serde(default)]
    pub root_manifest_sha256: String,
    #[serde(default)]
    pub support_target_matrix_sha256: String,
    #[serde(default)]
    pub pack_routes_effective_sha256: String,
    #[serde(default)]
    pub pack_routes_lock_sha256: String,
    #[serde(default)]
    pub extensions_catalog_sha256: String,
    #[serde(default)]
    pub extensions_generation_lock_sha256: String,
    #[serde(default)]
    pub capability_routing_sha256: String,
    #[serde(default)]
    pub capability_routing_lock_sha256: String,
    #[serde(default)]
    pub fresh_until: String,
    #[serde(default)]
    pub source_digests: BTreeMap<String, String>,
    #[serde(default)]
    pub freshness: RuntimeHandleFreshness,
    #[serde(default)]
    pub legacy_fresh_until: String,
    #[serde(default)]
    pub allowed_consumers: Vec<String>,
    #[serde(default)]
    pub forbidden_consumers: Vec<String>,
    #[serde(default)]
    pub non_authority_classification: String,
    #[serde(default)]
    pub dependency_handles: Vec<RuntimeDependencyHandle>,
    #[serde(default)]
    pub dependency_handle_refs: Vec<RuntimeDependencyHandle>,
}

#[derive(Debug, Clone, Deserialize, Default)]
pub struct RuntimeDependencyHandle {
    #[serde(default)]
    pub artifact_kind: String,
    #[serde(default)]
    pub output_ref: String,
    #[serde(default)]
    pub lock_ref: Option<String>,
    #[serde(default)]
    pub requirement: String,
    #[serde(default)]
    pub purpose: String,
}

#[derive(Debug, Clone, Deserialize, Default)]
struct PublicationReceipt {
    #[serde(default)]
    schema_version: String,
    #[serde(default)]
    generation_id: String,
    #[serde(default)]
    result: String,
    #[serde(default)]
    published_paths: Vec<String>,
}

#[derive(Debug, Clone)]
pub struct VerifiedRuntimeRouteBundle {
    pub resolution_path: PathBuf,
    pub bundle_path: PathBuf,
    pub lock_path: PathBuf,
    pub pack_routes_effective_path: PathBuf,
    pub pack_routes_lock_path: PathBuf,
    pub bundle_sha256: String,
    pub bundle: RuntimeEffectiveRouteBundle,
    pub lock: RuntimeEffectiveRouteBundleLock,
}

impl VerifiedRuntimeRouteBundle {
    pub fn generation_id(&self) -> &str {
        &self.bundle.generation_id
    }

    pub fn freshness_mode(&self) -> &str {
        self.lock.freshness.mode.as_str()
    }

    pub fn ensure_live_tuple_and_packs(
        &self,
        tuple: &RuntimeSupportTupleRef,
        requested_capability_packs: &[String],
    ) -> Result<RuntimePackRoute> {
        let route = self
            .bundle
            .routes
            .iter()
            .find(|candidate| candidate.matches(tuple))
            .cloned()
            .ok_or_else(|| anyhow!("CAPABILITY_DENIED: runtime route bundle does not cover the requested support tuple"))?;
        if route.claim_effect != "admitted-live-claim" {
            return Err(anyhow!(
                "CAPABILITY_DENIED: runtime route bundle resolved a non-live support tuple"
            ));
        }
        for pack_id in requested_capability_packs {
            if !route.allowed_capability_packs.iter().any(|allowed| allowed == pack_id) {
                return Err(anyhow!(
                    "CAPABILITY_DENIED: runtime route bundle denied requested capability pack '{}'",
                    pack_id
                ));
            }
        }
        Ok(route)
    }

    pub fn ensure_extensions_available(&self) -> Result<()> {
        if self.bundle.extensions.status != "published" {
            return Err(anyhow!(
                "CAPABILITY_DENIED: runtime route bundle reports unpublished or degraded extension state"
            ));
        }
        if self.bundle.extensions.quarantine_count > 0 {
            return Err(anyhow!(
                "CAPABILITY_DENIED: runtime route bundle reports quarantined extensions"
            ));
        }
        Ok(())
    }
}

impl RuntimePackRoute {
    fn matches(&self, tuple: &RuntimeSupportTupleRef) -> bool {
        self.tuple.model_tier == tuple.model_tier
            && self.tuple.workload_tier == tuple.workload_tier
            && self.tuple.language_resource_tier == tuple.language_resource_tier
            && self.tuple.locale_tier == tuple.locale_tier
            && self.tuple.host_adapter == tuple.host_adapter
            && self.tuple.model_adapter == tuple.model_adapter
    }
}

pub fn verify_runtime_route_bundle(octon_dir: &Path) -> Result<VerifiedRuntimeRouteBundle> {
    let root_dir = octon_dir
        .parent()
        .ok_or_else(|| anyhow!("INTERNAL: .octon has no parent directory"))?;
    let resolution_path = octon_dir.join("instance/governance/runtime-resolution.yml");
    let resolution_bytes = fs::read(&resolution_path)
        .with_context(|| format!("failed to read {}", resolution_path.display()))?;
    let resolution_digest = sha256_hex(&resolution_bytes);
    let resolution: RuntimeResolutionRecord =
        serde_yaml::from_slice(&resolution_bytes).context("runtime-resolution selector is not valid YAML")?;
    if resolution.schema_version != "octon-runtime-resolution-v1" {
        return Err(anyhow!(
            "INVALID_INPUT: unsupported runtime-resolution schema '{}'",
            resolution.schema_version
        ));
    }

    let bundle_path = resolve_repo_path(root_dir, &resolution.runtime_effective_route_bundle_ref);
    let lock_path = resolve_repo_path(root_dir, &resolution.runtime_effective_route_bundle_lock_ref);
    let pack_routes_effective_path = resolve_repo_path(root_dir, &resolution.pack_routes_effective_ref);
    let pack_routes_lock_path = resolve_repo_path(root_dir, &resolution.pack_routes_lock_ref);

    let bundle_bytes =
        fs::read(&bundle_path).with_context(|| format!("failed to read {}", bundle_path.display()))?;
    let bundle_sha256 = sha256_hex(&bundle_bytes);
    let bundle: RuntimeEffectiveRouteBundle =
        serde_yaml::from_slice(&bundle_bytes).context("runtime route bundle is not valid YAML")?;
    if bundle.schema_version != "octon-runtime-effective-route-bundle-v1" {
        return Err(anyhow!(
            "INVALID_INPUT: unsupported runtime route bundle schema '{}'",
            bundle.schema_version
        ));
    }

    let lock_bytes =
        fs::read(&lock_path).with_context(|| format!("failed to read {}", lock_path.display()))?;
    let lock: RuntimeEffectiveRouteBundleLock =
        serde_yaml::from_slice(&lock_bytes).context("runtime route bundle lock is not valid YAML")?;
    if lock.schema_version != "octon-runtime-effective-route-bundle-lock-v1"
        && lock.schema_version != "octon-runtime-effective-route-bundle-lock-v2"
        && lock.schema_version != "octon-runtime-effective-route-bundle-lock-v3"
    {
        return Err(anyhow!(
            "INVALID_INPUT: unsupported runtime route bundle lock schema '{}'",
            lock.schema_version
        ));
    }
    if bundle.generation_id != lock.generation_id {
        return Err(anyhow!("CAPABILITY_DENIED: runtime route bundle generation_id mismatch"));
    }
    require_non_empty(&lock.publication_receipt_sha256, "publication_receipt_sha256")?;
    require_non_empty(&lock.route_bundle_sha256, "route_bundle_sha256")?;
    require_non_empty(
        source_digest(&lock, "runtime_resolution_sha256"),
        "runtime_resolution_sha256",
    )?;
    require_non_empty(source_digest(&lock, "root_manifest_sha256"), "root_manifest_sha256")?;
    require_non_empty(
        source_digest(&lock, "support_target_matrix_sha256"),
        "support_target_matrix_sha256",
    )?;
    require_non_empty(
        source_digest(&lock, "pack_routes_effective_sha256"),
        "pack_routes_effective_sha256",
    )?;
    require_non_empty(
        source_digest(&lock, "pack_routes_lock_sha256"),
        "pack_routes_lock_sha256",
    )?;
    require_non_empty(
        source_digest(&lock, "extensions_catalog_sha256"),
        "extensions_catalog_sha256",
    )?;
    require_non_empty(
        source_digest(&lock, "extensions_generation_lock_sha256"),
        "extensions_generation_lock_sha256",
    )?;

    if lock.route_bundle_sha256 != bundle_sha256 {
        return Err(anyhow!("CAPABILITY_DENIED: runtime route bundle digest drift detected"));
    }
    if source_digest(&lock, "runtime_resolution_sha256") != resolution_digest {
        return Err(anyhow!("CAPABILITY_DENIED: runtime-resolution selector digest drift detected"));
    }

    if lock.schema_version == "octon-runtime-effective-route-bundle-lock-v2"
        || lock.schema_version == "octon-runtime-effective-route-bundle-lock-v3"
    {
        require_handle_metadata(&lock)?;
        enforce_handle_freshness(&lock)?;
        if lock.schema_version == "octon-runtime-effective-route-bundle-lock-v3" {
            if lock.route_bundle_ref != resolution.runtime_effective_route_bundle_ref {
                return Err(anyhow!(
                    "CAPABILITY_DENIED: runtime route bundle lock route_bundle_ref drift detected"
                ));
            }
            let dependency_handles = if lock.dependency_handles.is_empty() {
                &lock.dependency_handle_refs
            } else {
                &lock.dependency_handles
            };
            if dependency_handles.is_empty() {
                return Err(anyhow!(
                    "CAPABILITY_DENIED: runtime route bundle lock must declare dependency handles"
                ));
            }
        }
    } else if !lock.fresh_until.trim().is_empty() {
        let fresh_until = OffsetDateTime::parse(lock.fresh_until.trim(), &Rfc3339)
            .context("runtime route bundle lock fresh_until is not valid RFC3339")?;
        if fresh_until <= OffsetDateTime::now_utc() {
            return Err(anyhow!("CAPABILITY_DENIED: runtime route bundle freshness window expired"));
        }
    }

    let receipt_path = resolve_repo_path(root_dir, &lock.publication_receipt_path);
    let receipt_bytes =
        fs::read(&receipt_path).with_context(|| format!("failed to read {}", receipt_path.display()))?;
    let receipt_sha256 = sha256_hex(&receipt_bytes);
    let receipt: PublicationReceipt =
        serde_yaml::from_slice(&receipt_bytes).context("runtime route bundle receipt is not valid YAML")?;
    if lock.publication_receipt_sha256 != receipt_sha256 {
        return Err(anyhow!("CAPABILITY_DENIED: runtime route bundle publication receipt digest drift detected"));
    }
    if receipt.schema_version != "octon-validation-publication-receipt-v1" {
        return Err(anyhow!("CAPABILITY_DENIED: runtime route bundle receipt schema is not current"));
    }
    if receipt.generation_id != bundle.generation_id {
        return Err(anyhow!("CAPABILITY_DENIED: runtime route bundle receipt generation mismatch"));
    }
    if receipt.result != bundle.publication_status {
        return Err(anyhow!("CAPABILITY_DENIED: runtime route bundle receipt status mismatch"));
    }
    if !receipt
        .published_paths
        .iter()
        .any(|path| path == &resolution.runtime_effective_route_bundle_ref)
    {
        return Err(anyhow!("CAPABILITY_DENIED: runtime route bundle receipt does not publish the bundle path"));
    }

    verify_optional_digest(
        &resolve_repo_path(root_dir, ".octon/octon.yml"),
        source_digest(&lock, "root_manifest_sha256"),
        "root manifest",
    )?;
    verify_optional_digest(
        &resolve_repo_path(root_dir, &resolution.support_target_matrix_ref),
        source_digest(&lock, "support_target_matrix_sha256"),
        "support target matrix",
    )?;
    verify_optional_digest(
        &pack_routes_effective_path,
        source_digest(&lock, "pack_routes_effective_sha256"),
        "pack routes effective",
    )?;
    verify_optional_digest(
        &pack_routes_lock_path,
        source_digest(&lock, "pack_routes_lock_sha256"),
        "pack routes lock",
    )?;
    verify_optional_digest(
        &resolve_repo_path(root_dir, &resolution.extensions_catalog_ref),
        source_digest(&lock, "extensions_catalog_sha256"),
        "extensions catalog",
    )?;
    verify_optional_digest(
        &resolve_repo_path(root_dir, &resolution.extensions_generation_lock_ref),
        source_digest(&lock, "extensions_generation_lock_sha256"),
        "extensions generation lock",
    )?;

    let _support_matrix = handles::verify_runtime_effective_handle(
        octon_dir,
        "support_matrix",
        "route_bundle_compiler",
    )?;
    let _pack_routes = handles::verify_runtime_effective_handle(
        octon_dir,
        "pack_routes",
        "runtime_resolver",
    )?;
    let extension_catalog = handles::verify_runtime_effective_handle(
        octon_dir,
        "extension_catalog",
        "runtime_resolver",
    )?;
    let extension_generation_lock = handles::verify_runtime_effective_handle(
        octon_dir,
        "extension_generation_lock",
        "runtime_resolver",
    )?;
    if handles::runtime_effective_handle_present(octon_dir, "capability_routing")? {
        let _capability_routing = handles::verify_runtime_effective_handle(
            octon_dir,
            "capability_routing",
            "runtime_resolver",
        )?;
    }
    if bundle.extensions.generation_id != extension_catalog.generation_id {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime route bundle extension generation does not match the verified extension catalog"
        ));
    }
    if bundle.extensions.generation_id != extension_generation_lock.generation_id {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime route bundle extension generation does not match the verified extension generation lock"
        ));
    }
    if bundle.extensions.status != extension_catalog.publication_status {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime route bundle extension status does not match the verified extension catalog"
        ));
    }

    Ok(VerifiedRuntimeRouteBundle {
        resolution_path,
        bundle_path,
        lock_path,
        pack_routes_effective_path,
        pack_routes_lock_path,
        bundle_sha256,
        bundle,
        lock,
    })
}

fn source_digest<'a>(lock: &'a RuntimeEffectiveRouteBundleLock, key: &str) -> &'a str {
    if let Some(value) = lock.source_digests.get(key) {
        return value.as_str();
    }
    match key {
        "runtime_resolution_sha256" => lock.runtime_resolution_sha256.as_str(),
        "root_manifest_sha256" => lock.root_manifest_sha256.as_str(),
        "support_target_matrix_sha256" => lock.support_target_matrix_sha256.as_str(),
        "pack_routes_effective_sha256" => lock.pack_routes_effective_sha256.as_str(),
        "pack_routes_lock_sha256" => lock.pack_routes_lock_sha256.as_str(),
        "extensions_catalog_sha256" => lock.extensions_catalog_sha256.as_str(),
        "extensions_generation_lock_sha256" => lock.extensions_generation_lock_sha256.as_str(),
        _ => "",
    }
}

fn require_handle_metadata(lock: &RuntimeEffectiveRouteBundleLock) -> Result<()> {
    require_non_empty(&lock.freshness.mode, "freshness.mode")?;
    if lock.freshness.invalidation_conditions.is_empty() {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime route bundle lock must declare freshness invalidation conditions"
        ));
    }
    if !lock
        .allowed_consumers
        .iter()
        .any(|value| value == "runtime_resolver")
    {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime route bundle lock must allow runtime_resolver as a consumer"
        ));
    }
    if lock
        .forbidden_consumers
        .iter()
        .any(|value| value == "runtime_resolver")
    {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime route bundle lock forbids runtime_resolver"
        ));
    }
    if lock.non_authority_classification != "derived-runtime-handle" {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime route bundle lock non-authority classification is invalid"
        ));
    }
    Ok(())
}

fn enforce_handle_freshness(lock: &RuntimeEffectiveRouteBundleLock) -> Result<()> {
    match lock.freshness.mode.as_str() {
        "digest_bound" | "receipt_bound" => Ok(()),
        "ttl_bound" => {
            let ttl_seconds = lock.freshness.ttl_seconds.ok_or_else(|| {
                anyhow!("CAPABILITY_DENIED: runtime route bundle lock ttl_bound freshness requires ttl_seconds")
            })?;
            if ttl_seconds <= 0 {
                return Err(anyhow!(
                    "CAPABILITY_DENIED: runtime route bundle lock ttl_bound freshness requires a positive ttl_seconds"
                ));
            }
            let published_at = OffsetDateTime::parse(lock.published_at.trim(), &Rfc3339)
                .context("runtime route bundle lock published_at is not valid RFC3339")?;
            if published_at + time::Duration::seconds(ttl_seconds) <= OffsetDateTime::now_utc() {
                return Err(anyhow!(
                    "CAPABILITY_DENIED: runtime route bundle lock ttl-bound freshness window expired"
                ));
            }
            Ok(())
        }
        _ => Err(anyhow!(
            "CAPABILITY_DENIED: runtime route bundle lock freshness mode is invalid"
        )),
    }
}

fn require_non_empty(value: &str, field: &str) -> Result<()> {
    if value.trim().is_empty() {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime route bundle lock field '{}' must be non-empty",
            field
        ));
    }
    Ok(())
}

fn resolve_repo_path(root_dir: &Path, raw: &str) -> PathBuf {
    match raw {
        "" => root_dir.to_path_buf(),
        _ if raw.starts_with('/') => root_dir.join(raw.trim_start_matches('/')),
        _ if raw.starts_with(".octon/") || raw.starts_with(".github/") => root_dir.join(raw),
        _ => root_dir.join(raw),
    }
}

fn verify_optional_digest(path: &Path, expected_sha256: &str, label: &str) -> Result<()> {
    if expected_sha256.is_empty() {
        return Ok(());
    }
    let bytes = fs::read(path).with_context(|| format!("failed to read {}", path.display()))?;
    let actual = sha256_hex(&bytes);
    if actual != expected_sha256 {
        return Err(anyhow!("CAPABILITY_DENIED: {label} digest drift detected"));
    }
    Ok(())
}

fn sha256_hex(bytes: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(bytes);
    hex::encode(hasher.finalize())
}
