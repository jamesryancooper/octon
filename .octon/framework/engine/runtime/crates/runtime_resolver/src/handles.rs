use anyhow::{anyhow, Context, Result};
use serde::Deserialize;
use serde_yaml::Value;
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};
use time::format_description::well_known::Rfc3339;
use time::OffsetDateTime;

#[derive(Debug, Clone, Deserialize, Default)]
struct RuntimeHandleConfig {
    #[serde(default)]
    output_ref: String,
    #[serde(default)]
    lock_ref: String,
    #[serde(default)]
    freshness_mode: String,
}

#[derive(Debug, Clone, Deserialize, Default)]
struct RuntimeResolutionRecord {
    #[serde(default)]
    schema_version: String,
    #[serde(default)]
    runtime_effective_route_bundle_ref: String,
    #[serde(default)]
    runtime_effective_route_bundle_lock_ref: String,
    #[serde(default)]
    pack_routes_effective_ref: String,
    #[serde(default)]
    pack_routes_lock_ref: String,
    #[serde(default)]
    support_target_matrix_ref: String,
    #[serde(default)]
    extensions_catalog_ref: String,
    #[serde(default)]
    extensions_generation_lock_ref: String,
    #[serde(default)]
    runtime_effective_handle_kinds: BTreeMap<String, RuntimeHandleConfig>,
}

#[derive(Debug, Clone)]
pub struct VerifiedRuntimeHandle {
    pub kind: String,
    pub output_path: PathBuf,
    pub lock_path: Option<PathBuf>,
    pub generation_id: String,
    pub output_sha256: String,
    pub lock_sha256: Option<String>,
    pub publication_status: String,
    pub publication_receipt_path: String,
    pub publication_receipt_sha256: Option<String>,
    pub freshness_mode: String,
    pub invalidation_conditions: Vec<String>,
    pub allowed_consumers: Vec<String>,
    pub forbidden_consumers: Vec<String>,
    pub non_authority_classification: String,
}

impl VerifiedRuntimeHandle {
    pub fn allows_consumer(&self, consumer: &str) -> Result<()> {
        if !self.allowed_consumers.iter().any(|value| value == consumer) {
            return Err(anyhow!(
                "CAPABILITY_DENIED: runtime-effective handle consumer '{}' is not allowed for '{}'",
                consumer,
                self.kind
            ));
        }
        if self.forbidden_consumers.iter().any(|value| value == consumer) {
            return Err(anyhow!(
                "CAPABILITY_DENIED: runtime-effective handle consumer '{}' is forbidden for '{}'",
                consumer,
                self.kind
            ));
        }
        Ok(())
    }
}

pub fn verify_runtime_effective_handle(
    octon_dir: &Path,
    kind: &str,
    expected_consumer: &str,
) -> Result<VerifiedRuntimeHandle> {
    let root_dir = octon_dir
        .parent()
        .ok_or_else(|| anyhow!("INTERNAL: .octon has no parent directory"))?;
    let selector = load_runtime_resolution(octon_dir)?;
    let config = resolve_handle_config(&selector, kind)?;
    let output_path = resolve_repo_path(root_dir, &config.output_ref);

    match kind {
        "pack_routes" => verify_pack_routes_handle(root_dir, &output_path, &config, expected_consumer),
        "support_matrix" => verify_support_matrix_handle(root_dir, &output_path, expected_consumer),
        "extension_catalog" => verify_extension_catalog_handle(root_dir, &output_path, &config, expected_consumer),
        "extension_generation_lock" => {
            verify_extension_generation_lock_handle(root_dir, &output_path, expected_consumer)
        }
        "capability_routing" => verify_capability_routing_handle(root_dir, &output_path, &config, expected_consumer),
        "runtime_route_bundle" => Err(anyhow!(
            "INTERNAL: runtime_route_bundle is verified by verify_runtime_route_bundle"
        )),
        _ => Err(anyhow!(
            "CAPABILITY_DENIED: unsupported runtime-effective handle kind '{}'",
            kind
        )),
    }
}

pub fn runtime_effective_handle_present(octon_dir: &Path, kind: &str) -> Result<bool> {
    let root_dir = octon_dir
        .parent()
        .ok_or_else(|| anyhow!("INTERNAL: .octon has no parent directory"))?;
    let selector = load_runtime_resolution(octon_dir)?;
    let config = resolve_handle_config(&selector, kind)?;
    let output_path = resolve_repo_path(root_dir, &config.output_ref);
    if !output_path.exists() {
        return Ok(false);
    }
    if !config.lock_ref.trim().is_empty() {
        let lock_path = resolve_repo_path(root_dir, &config.lock_ref);
        if !lock_path.exists() {
            return Ok(false);
        }
    }
    Ok(true)
}

fn verify_pack_routes_handle(
    root_dir: &Path,
    output_path: &Path,
    config: &RuntimeHandleConfig,
    expected_consumer: &str,
) -> Result<VerifiedRuntimeHandle> {
    let lock_path = resolve_repo_path(root_dir, &config.lock_ref);
    let output_value = read_yaml(output_path)?;
    let lock_value = read_yaml(&lock_path)?;
    let output_bytes = fs::read(output_path)
        .with_context(|| format!("failed to read {}", output_path.display()))?;
    let lock_bytes =
        fs::read(&lock_path).with_context(|| format!("failed to read {}", lock_path.display()))?;
    let output_sha = sha256_hex(&output_bytes);
    let lock_sha = sha256_hex(&lock_bytes);
    let generation_id = required_str(&output_value, &["generation_id"], "pack routes generation_id")?;
    let lock_generation_id =
        required_str(&lock_value, &["generation_id"], "pack routes lock generation_id")?;
    if generation_id != lock_generation_id {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime-effective handle generation mismatch for 'pack_routes'"
        ));
    }
    let publication_status =
        required_str(&output_value, &["publication_status"], "pack routes publication_status")?;
    let lock_status =
        required_str(&lock_value, &["publication_status"], "pack routes lock publication_status")?;
    if publication_status != lock_status {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime-effective handle publication status mismatch for 'pack_routes'"
        ));
    }
    let receipt_path = required_str(
        &lock_value,
        &["publication_receipt_path"],
        "pack routes publication_receipt_path",
    )?;
    let receipt_sha = required_str(
        &lock_value,
        &["publication_receipt_sha256"],
        "pack routes publication_receipt_sha256",
    )?;
    let expected_output_sha =
        required_str(&lock_value, &["pack_routes_sha256"], "pack routes output digest")?;
    if output_sha != expected_output_sha {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime-effective handle output digest drift detected for 'pack_routes'"
        ));
    }
    verify_publication_receipt(
        root_dir,
        &receipt_path,
        &receipt_sha,
        &generation_id,
        &publication_status,
        &config.output_ref,
    )?;
    verify_digest_field(
        root_dir,
        ".octon/octon.yml",
        &required_str(&lock_value, &["root_manifest_sha256"], "pack routes root manifest digest")?,
        "pack routes root manifest",
    )?;
    verify_digest_field(
        root_dir,
        ".octon/instance/governance/support-targets.yml",
        &required_str(&lock_value, &["support_targets_sha256"], "pack routes support-targets digest")?,
        "pack routes support targets",
    )?;
    verify_digest_field(
        root_dir,
        ".octon/instance/governance/capability-packs/registry.yml",
        &required_str(&lock_value, &["governance_registry_sha256"], "pack routes governance registry digest")?,
        "pack routes governance registry",
    )?;
    verify_digest_field(
        root_dir,
        ".octon/instance/capabilities/runtime/packs/registry.yml",
        &required_str(&lock_value, &["runtime_registry_sha256"], "pack routes runtime registry digest")?,
        "pack routes runtime registry",
    )?;
    verify_digest_field(
        root_dir,
        ".octon/generated/effective/governance/support-target-matrix.yml",
        &required_str(&lock_value, &["support_target_matrix_sha256"], "pack routes support matrix digest")?,
        "pack routes support matrix",
    )?;

    let freshness_mode = required_str(&lock_value, &["freshness", "mode"], "pack routes freshness.mode")?;
    let invalidation_conditions = required_seq(
        &lock_value,
        &["freshness", "invalidation_conditions"],
        "pack routes invalidation conditions",
    )?;
    enforce_freshness_mode(&freshness_mode, &lock_value, "pack routes")?;
    let allowed_consumers =
        optional_seq(&lock_value, &["allowed_consumers"]).unwrap_or_else(|| default_allowed(kind_to_runtime("pack_routes")));
    let forbidden_consumers =
        optional_seq(&lock_value, &["forbidden_consumers"]).unwrap_or_else(|| default_forbidden(kind_to_runtime("pack_routes")));
    let non_authority = required_str(
        &lock_value,
        &["non_authority_classification"],
        "pack routes non_authority_classification",
    )?;
    ensure_non_authority("pack_routes", &non_authority)?;
    let handle = VerifiedRuntimeHandle {
        kind: "pack_routes".to_string(),
        output_path: output_path.to_path_buf(),
        lock_path: Some(lock_path),
        generation_id: generation_id.to_string(),
        output_sha256: output_sha,
        lock_sha256: Some(lock_sha),
        publication_status: publication_status.to_string(),
        publication_receipt_path: receipt_path.to_string(),
        publication_receipt_sha256: Some(receipt_sha.to_string()),
        freshness_mode: freshness_mode.to_string(),
        invalidation_conditions,
        allowed_consumers,
        forbidden_consumers,
        non_authority_classification: non_authority.to_string(),
    };
    handle.allows_consumer(expected_consumer)?;
    Ok(handle)
}

fn verify_support_matrix_handle(
    root_dir: &Path,
    output_path: &Path,
    expected_consumer: &str,
) -> Result<VerifiedRuntimeHandle> {
    let output_value = read_yaml(output_path)?;
    let output_bytes = fs::read(output_path)
        .with_context(|| format!("failed to read {}", output_path.display()))?;
    let output_sha = sha256_hex(&output_bytes);
    let source_ref = required_str(&output_value, &["source_ref"], "support matrix source_ref")?;
    if source_ref != ".octon/instance/governance/support-targets.yml" {
        return Err(anyhow!(
            "CAPABILITY_DENIED: support matrix source_ref is not canonical"
        ));
    }
    if expected_consumer == "runtime_resolver" {
        return Err(anyhow!(
            "CAPABILITY_DENIED: support matrix is not a direct runtime authority handle"
        ));
    }
    let handle = VerifiedRuntimeHandle {
        kind: "support_matrix".to_string(),
        output_path: output_path.to_path_buf(),
        lock_path: None,
        generation_id: required_str(&output_value, &["generated_at"], "support matrix generated_at")?
            .to_string(),
        output_sha256: output_sha,
        lock_sha256: None,
        publication_status: "compiled".to_string(),
        publication_receipt_path:
            ".octon/state/evidence/validation/architecture/10of10-target-transition/support-targets/proof-refresh.yml"
                .to_string(),
        publication_receipt_sha256: None,
        freshness_mode: "digest_bound".to_string(),
        invalidation_conditions: vec!["support-targets-sha-changed".to_string()],
        allowed_consumers: vec!["route_bundle_compiler".to_string(), "validators".to_string()],
        forbidden_consumers: vec![
            "runtime_resolver".to_string(),
            "direct_runtime_raw_path_read".to_string(),
        ],
        non_authority_classification: "derived-non-authority".to_string(),
    };
    handle.allows_consumer(expected_consumer)?;
    verify_digest_field(
        root_dir,
        ".octon/instance/governance/support-targets.yml",
        &sha256_hex(&fs::read(resolve_repo_path(root_dir, &source_ref))?),
        "support matrix source",
    )?;
    Ok(handle)
}

fn verify_extension_catalog_handle(
    root_dir: &Path,
    output_path: &Path,
    config: &RuntimeHandleConfig,
    expected_consumer: &str,
) -> Result<VerifiedRuntimeHandle> {
    let lock_path = resolve_repo_path(root_dir, &config.lock_ref);
    let output_value = read_yaml(output_path)?;
    let lock_value = read_yaml(&lock_path)?;
    let output_bytes = fs::read(output_path)
        .with_context(|| format!("failed to read {}", output_path.display()))?;
    let lock_bytes =
        fs::read(&lock_path).with_context(|| format!("failed to read {}", lock_path.display()))?;
    let output_sha = sha256_hex(&output_bytes);
    let lock_sha = sha256_hex(&lock_bytes);
    let generation_id =
        required_str(&output_value, &["generation_id"], "extension catalog generation_id")?;
    let lock_generation_id =
        required_str(&lock_value, &["generation_id"], "extension generation lock generation_id")?;
    if generation_id != lock_generation_id {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime-effective handle generation mismatch for 'extension_catalog'"
        ));
    }
    let publication_status = required_str(
        &output_value,
        &["publication_status"],
        "extension catalog publication_status",
    )?;
    let lock_status = required_str(
        &lock_value,
        &["publication_status"],
        "extension generation lock publication_status",
    )?;
    if publication_status != lock_status {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime-effective handle publication status mismatch for 'extension_catalog'"
        ));
    }
    let receipt_path = required_str(
        &lock_value,
        &["publication_receipt_path"],
        "extension generation lock publication_receipt_path",
    )?;
    let receipt_sha = required_str(
        &lock_value,
        &["publication_receipt_sha256"],
        "extension generation lock publication_receipt_sha256",
    )?;
    verify_publication_receipt(
        root_dir,
        &receipt_path,
        &receipt_sha,
        &generation_id,
        &publication_status,
        &config.output_ref,
    )?;
    verify_digest_field(
        root_dir,
        ".octon/octon.yml",
        &required_str(
            &lock_value,
            &["root_manifest_sha256"],
            "extension generation lock root_manifest_sha256",
        )?,
        "extension catalog root manifest",
    )?;
    verify_extension_desired_config(
        root_dir,
        &required_str(
            &lock_value,
            &["desired_config_sha256"],
            "extension generation lock desired_config_sha256",
        )?,
        "extension catalog desired config",
    )?;
    verify_extension_active_state(root_dir, &generation_id, &receipt_path, &receipt_sha, &publication_status)?;
    let freshness_mode = if config.freshness_mode.trim().is_empty() {
        "receipt_bound".to_string()
    } else {
        config.freshness_mode.clone()
    };
    let invalidation_conditions = optional_seq(&output_value, &["invalidation_conditions"])
        .or_else(|| optional_seq(&lock_value, &["invalidation_conditions"]))
        .unwrap_or_else(|| vec!["publication-receipt-changed".to_string()]);
    let handle = VerifiedRuntimeHandle {
        kind: "extension_catalog".to_string(),
        output_path: output_path.to_path_buf(),
        lock_path: Some(lock_path),
        generation_id: generation_id.to_string(),
        output_sha256: output_sha,
        lock_sha256: Some(lock_sha),
        publication_status: publication_status.to_string(),
        publication_receipt_path: receipt_path.to_string(),
        publication_receipt_sha256: Some(receipt_sha.to_string()),
        freshness_mode,
        invalidation_conditions,
        allowed_consumers: default_allowed(kind_to_runtime("extension_catalog")),
        forbidden_consumers: default_forbidden(kind_to_runtime("extension_catalog")),
        non_authority_classification: "derived-runtime-handle".to_string(),
    };
    handle.allows_consumer(expected_consumer)?;
    Ok(handle)
}

fn verify_extension_generation_lock_handle(
    root_dir: &Path,
    output_path: &Path,
    expected_consumer: &str,
) -> Result<VerifiedRuntimeHandle> {
    let lock_value = read_yaml(output_path)?;
    let lock_bytes =
        fs::read(output_path).with_context(|| format!("failed to read {}", output_path.display()))?;
    let generation_id = required_str(
        &lock_value,
        &["generation_id"],
        "extension generation lock generation_id",
    )?;
    let publication_status = required_str(
        &lock_value,
        &["publication_status"],
        "extension generation lock publication_status",
    )?;
    let receipt_path = required_str(
        &lock_value,
        &["publication_receipt_path"],
        "extension generation lock publication_receipt_path",
    )?;
    let receipt_sha = required_str(
        &lock_value,
        &["publication_receipt_sha256"],
        "extension generation lock publication_receipt_sha256",
    )?;
    verify_publication_receipt(
        root_dir,
        &receipt_path,
        &receipt_sha,
        &generation_id,
        &publication_status,
        ".octon/generated/effective/extensions/generation.lock.yml",
    )?;
    verify_digest_field(
        root_dir,
        ".octon/octon.yml",
        &required_str(
            &lock_value,
            &["root_manifest_sha256"],
            "extension generation lock root_manifest_sha256",
        )?,
        "extension generation lock root manifest",
    )?;
    verify_extension_desired_config(
        root_dir,
        &required_str(
            &lock_value,
            &["desired_config_sha256"],
            "extension generation lock desired_config_sha256",
        )?,
        "extension generation lock desired config",
    )?;
    verify_extension_active_state(root_dir, &generation_id, &receipt_path, &receipt_sha, &publication_status)?;
    let handle = VerifiedRuntimeHandle {
        kind: "extension_generation_lock".to_string(),
        output_path: output_path.to_path_buf(),
        lock_path: None,
        generation_id: generation_id.to_string(),
        output_sha256: sha256_hex(&lock_bytes),
        lock_sha256: None,
        publication_status: publication_status.to_string(),
        publication_receipt_path: receipt_path.to_string(),
        publication_receipt_sha256: Some(receipt_sha.to_string()),
        freshness_mode: "receipt_bound".to_string(),
        invalidation_conditions: optional_seq(&lock_value, &["invalidation_conditions"])
            .unwrap_or_else(|| vec!["publication-receipt-changed".to_string()]),
        allowed_consumers: default_allowed(kind_to_runtime("extension_generation_lock")),
        forbidden_consumers: default_forbidden(kind_to_runtime("extension_generation_lock")),
        non_authority_classification: "derived-runtime-handle".to_string(),
    };
    handle.allows_consumer(expected_consumer)?;
    Ok(handle)
}

fn verify_capability_routing_handle(
    root_dir: &Path,
    output_path: &Path,
    config: &RuntimeHandleConfig,
    expected_consumer: &str,
) -> Result<VerifiedRuntimeHandle> {
    let lock_path = resolve_repo_path(root_dir, &config.lock_ref);
    let output_value = read_yaml(output_path)?;
    let lock_value = read_yaml(&lock_path)?;
    let output_bytes = fs::read(output_path)
        .with_context(|| format!("failed to read {}", output_path.display()))?;
    let lock_bytes =
        fs::read(&lock_path).with_context(|| format!("failed to read {}", lock_path.display()))?;
    let output_sha = sha256_hex(&output_bytes);
    let lock_sha = sha256_hex(&lock_bytes);
    let generation_id =
        required_str(&output_value, &["generation_id"], "capability routing generation_id")?;
    let lock_generation_id = required_str(
        &lock_value,
        &["generation_id"],
        "capability routing generation lock generation_id",
    )?;
    if generation_id != lock_generation_id {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime-effective handle generation mismatch for 'capability_routing'"
        ));
    }
    let publication_status = required_str(
        &output_value,
        &["publication_status"],
        "capability routing publication_status",
    )?;
    let lock_status = required_str(
        &lock_value,
        &["publication_status"],
        "capability routing generation lock publication_status",
    )?;
    if publication_status != lock_status {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime-effective handle publication status mismatch for 'capability_routing'"
        ));
    }
    let receipt_path = required_str(
        &lock_value,
        &["publication_receipt_path"],
        "capability routing generation lock publication_receipt_path",
    )?;
    let receipt_sha = required_str(
        &lock_value,
        &["publication_receipt_sha256"],
        "capability routing generation lock publication_receipt_sha256",
    )?;
    verify_publication_receipt(
        root_dir,
        &receipt_path,
        &receipt_sha,
        &generation_id,
        &publication_status,
        &config.output_ref,
    )?;
    verify_digest_field(
        root_dir,
        ".octon/octon.yml",
        &required_str(
            &lock_value,
            &["root_manifest_sha256"],
            "capability routing root_manifest_sha256",
        )?,
        "capability routing root manifest",
    )?;
    verify_digest_field(
        root_dir,
        ".octon/generated/effective/locality/scopes.effective.yml",
        &required_str(
            &lock_value,
            &["locality_scopes_sha256"],
            "capability routing locality_scopes_sha256",
        )?,
        "capability routing locality scopes",
    )?;
    verify_digest_field(
        root_dir,
        ".octon/generated/effective/locality/generation.lock.yml",
        &required_str(
            &lock_value,
            &["locality_generation_lock_sha256"],
            "capability routing locality_generation_lock_sha256",
        )?,
        "capability routing locality generation lock",
    )?;
    verify_digest_field(
        root_dir,
        ".octon/generated/effective/extensions/catalog.effective.yml",
        &required_str(
            &lock_value,
            &["extensions_catalog_sha256"],
            "capability routing extensions_catalog_sha256",
        )?,
        "capability routing extensions catalog",
    )?;
    verify_digest_field(
        root_dir,
        ".octon/generated/effective/extensions/generation.lock.yml",
        &required_str(
            &lock_value,
            &["extensions_generation_lock_sha256"],
            "capability routing extensions_generation_lock_sha256",
        )?,
        "capability routing extensions generation lock",
    )?;
    let freshness_mode = if config.freshness_mode.trim().is_empty() {
        "receipt_bound".to_string()
    } else {
        config.freshness_mode.clone()
    };
    let invalidation_conditions = optional_seq(&output_value, &["invalidation_conditions"])
        .or_else(|| optional_seq(&lock_value, &["invalidation_conditions"]))
        .unwrap_or_else(|| vec!["publication-receipt-changed".to_string()]);
    let handle = VerifiedRuntimeHandle {
        kind: "capability_routing".to_string(),
        output_path: output_path.to_path_buf(),
        lock_path: Some(lock_path),
        generation_id: generation_id.to_string(),
        output_sha256: output_sha,
        lock_sha256: Some(lock_sha),
        publication_status: publication_status.to_string(),
        publication_receipt_path: receipt_path.to_string(),
        publication_receipt_sha256: Some(receipt_sha.to_string()),
        freshness_mode,
        invalidation_conditions,
        allowed_consumers: default_allowed(kind_to_runtime("capability_routing")),
        forbidden_consumers: default_forbidden(kind_to_runtime("capability_routing")),
        non_authority_classification: "derived-runtime-handle".to_string(),
    };
    handle.allows_consumer(expected_consumer)?;
    Ok(handle)
}

fn verify_extension_active_state(
    root_dir: &Path,
    generation_id: &str,
    receipt_path: &str,
    receipt_sha: &str,
    publication_status: &str,
) -> Result<()> {
    let active_path = resolve_repo_path(root_dir, ".octon/state/control/extensions/active.yml");
    let active_value = read_yaml(&active_path)?;
    let active_generation_id =
        required_str(&active_value, &["generation_id"], "extension active state generation_id")?;
    if active_generation_id != generation_id {
        return Err(anyhow!(
            "CAPABILITY_DENIED: extension active state generation mismatch"
        ));
    }
    let active_status =
        required_str(&active_value, &["status"], "extension active state status")?;
    if active_status != publication_status {
        return Err(anyhow!(
            "CAPABILITY_DENIED: extension active state publication status mismatch"
        ));
    }
    let active_receipt_path = required_str(
        &active_value,
        &["publication_receipt_path"],
        "extension active state publication_receipt_path",
    )?;
    if active_receipt_path != receipt_path {
        return Err(anyhow!(
            "CAPABILITY_DENIED: extension active state publication receipt path mismatch"
        ));
    }
    let active_receipt_sha = required_str(
        &active_value,
        &["publication_receipt_sha256"],
        "extension active state publication_receipt_sha256",
    )?;
    if active_receipt_sha != receipt_sha {
        return Err(anyhow!(
            "CAPABILITY_DENIED: extension active state publication receipt digest drift detected"
        ));
    }
    Ok(())
}

fn verify_extension_desired_config(root_dir: &Path, expected_sha: &str, label: &str) -> Result<()> {
    let desired_config_path = resolve_repo_path(root_dir, ".octon/instance/extensions.yml");
    if desired_config_path.is_file() {
        return verify_digest_field(root_dir, ".octon/instance/extensions.yml", expected_sha, label);
    }
    let active_path = resolve_repo_path(root_dir, ".octon/state/control/extensions/active.yml");
    let active_value = read_yaml(&active_path)?;
    let active_desired_sha = required_str(
        &active_value,
        &["desired_config_revision", "sha256"],
        "extension active state desired_config_revision.sha256",
    )?;
    if active_desired_sha != expected_sha {
        return Err(anyhow!(
            "CAPABILITY_DENIED: {label} digest drift detected"
        ));
    }
    Ok(())
}

fn load_runtime_resolution(octon_dir: &Path) -> Result<RuntimeResolutionRecord> {
    let selector_path = octon_dir.join("instance/governance/runtime-resolution.yml");
    let selector_bytes = fs::read(&selector_path)
        .with_context(|| format!("failed to read {}", selector_path.display()))?;
    let selector: RuntimeResolutionRecord = serde_yaml::from_slice(&selector_bytes)
        .context("runtime-resolution selector is not valid YAML")?;
    if selector.schema_version != "octon-runtime-resolution-v1" {
        return Err(anyhow!(
            "INVALID_INPUT: unsupported runtime-resolution schema '{}'",
            selector.schema_version
        ));
    }
    Ok(selector)
}

fn resolve_handle_config(selector: &RuntimeResolutionRecord, kind: &str) -> Result<RuntimeHandleConfig> {
    if let Some(config) = selector.runtime_effective_handle_kinds.get(kind) {
        return Ok(config.clone());
    }
    let config = match kind {
        "runtime_route_bundle" => RuntimeHandleConfig {
            output_ref: selector.runtime_effective_route_bundle_ref.clone(),
            lock_ref: selector.runtime_effective_route_bundle_lock_ref.clone(),
            freshness_mode: "digest_bound".to_string(),
        },
        "pack_routes" => RuntimeHandleConfig {
            output_ref: selector.pack_routes_effective_ref.clone(),
            lock_ref: selector.pack_routes_lock_ref.clone(),
            freshness_mode: "digest_bound".to_string(),
        },
        "support_matrix" => RuntimeHandleConfig {
            output_ref: selector.support_target_matrix_ref.clone(),
            lock_ref: String::new(),
            freshness_mode: "digest_bound".to_string(),
        },
        "extension_catalog" => RuntimeHandleConfig {
            output_ref: selector.extensions_catalog_ref.clone(),
            lock_ref: selector.extensions_generation_lock_ref.clone(),
            freshness_mode: "receipt_bound".to_string(),
        },
        "extension_generation_lock" => RuntimeHandleConfig {
            output_ref: selector.extensions_generation_lock_ref.clone(),
            lock_ref: String::new(),
            freshness_mode: "receipt_bound".to_string(),
        },
        "capability_routing" => RuntimeHandleConfig {
            output_ref: ".octon/generated/effective/capabilities/routing.effective.yml".to_string(),
            lock_ref: ".octon/generated/effective/capabilities/generation.lock.yml".to_string(),
            freshness_mode: "receipt_bound".to_string(),
        },
        _ => RuntimeHandleConfig::default(),
    };
    if config.output_ref.trim().is_empty() {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime-resolution selector is missing handle config for '{}'",
            kind
        ));
    }
    Ok(config)
}

fn verify_publication_receipt(
    root_dir: &Path,
    receipt_path_raw: &str,
    expected_sha: &str,
    expected_generation_id: &str,
    expected_status: &str,
    expected_output_ref: &str,
) -> Result<()> {
    let receipt_path = resolve_repo_path(root_dir, receipt_path_raw);
    let receipt_bytes = fs::read(&receipt_path)
        .with_context(|| format!("failed to read {}", receipt_path.display()))?;
    let receipt_sha = sha256_hex(&receipt_bytes);
    if receipt_sha != expected_sha {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime-effective handle publication receipt digest drift detected"
        ));
    }
    let receipt_value = read_yaml(&receipt_path)?;
    let schema_version =
        required_str(&receipt_value, &["schema_version"], "publication receipt schema_version")?;
    if schema_version != "octon-validation-publication-receipt-v1" {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime-effective handle publication receipt schema is not current"
        ));
    }
    let generation_id = required_str(
        &receipt_value,
        &["generation_id"],
        "publication receipt generation_id",
    )?;
    if generation_id != expected_generation_id {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime-effective handle publication receipt generation mismatch"
        ));
    }
    let result = required_str(&receipt_value, &["result"], "publication receipt result")?;
    if result != expected_status {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime-effective handle publication receipt status mismatch"
        ));
    }
    let published_paths =
        required_seq(&receipt_value, &["published_paths"], "publication receipt published_paths")?;
    if !published_paths.iter().any(|value| value == expected_output_ref) {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime-effective handle publication receipt does not publish the expected output"
        ));
    }
    Ok(())
}

fn verify_digest_field(root_dir: &Path, raw_path: &str, expected_sha: &str, label: &str) -> Result<()> {
    let path = resolve_repo_path(root_dir, raw_path);
    let bytes = fs::read(&path).with_context(|| format!("failed to read {}", path.display()))?;
    let actual_sha = sha256_hex(&bytes);
    if actual_sha != expected_sha {
        return Err(anyhow!(
            "CAPABILITY_DENIED: {label} digest drift detected"
        ));
    }
    Ok(())
}

fn enforce_freshness_mode(mode: &str, value: &Value, label: &str) -> Result<()> {
    match mode {
        "digest_bound" | "receipt_bound" => Ok(()),
        "ttl_bound" => {
            let ttl_seconds = required_i64(value, &["freshness", "ttl_seconds"], label)?;
            if ttl_seconds <= 0 {
                return Err(anyhow!(
                    "CAPABILITY_DENIED: runtime-effective handle ttl_bound freshness requires a positive ttl_seconds"
                ));
            }
            let published_at = required_str(value, &["published_at"], "published_at")?;
            let published_at = OffsetDateTime::parse(published_at.trim(), &Rfc3339)
                .with_context(|| format!("{label} published_at is not valid RFC3339"))?;
            if published_at + time::Duration::seconds(ttl_seconds) <= OffsetDateTime::now_utc() {
                return Err(anyhow!(
                    "CAPABILITY_DENIED: runtime-effective handle ttl-bound freshness window expired"
                ));
            }
            Ok(())
        }
        _ => Err(anyhow!(
            "CAPABILITY_DENIED: runtime-effective handle freshness mode is invalid"
        )),
    }
}

fn ensure_non_authority(kind: &str, classification: &str) -> Result<()> {
    let expected = match kind {
        "support_matrix" => "derived-non-authority",
        _ => "derived-runtime-handle",
    };
    if classification != expected {
        return Err(anyhow!(
            "CAPABILITY_DENIED: runtime-effective handle non-authority classification is invalid for '{}'",
            kind
        ));
    }
    Ok(())
}

fn default_allowed(kind: &str) -> Vec<String> {
    match kind {
        "support_matrix" => vec!["route_bundle_compiler".to_string(), "validators".to_string()],
        _ => vec!["runtime_resolver".to_string(), "validators".to_string()],
    }
}

fn default_forbidden(kind: &str) -> Vec<String> {
    match kind {
        "support_matrix" => vec!["runtime_resolver".to_string(), "direct_runtime_raw_path_read".to_string()],
        _ => vec!["direct_runtime_raw_path_read".to_string(), "generated_cognition_as_authority".to_string()],
    }
}

fn kind_to_runtime(kind: &str) -> &str {
    kind
}

fn read_yaml(path: &Path) -> Result<Value> {
    let bytes = fs::read(path).with_context(|| format!("failed to read {}", path.display()))?;
    serde_yaml::from_slice(&bytes).with_context(|| format!("invalid YAML: {}", path.display()))
}

fn required_str<'a>(value: &'a Value, keys: &[&str], label: &str) -> Result<&'a str> {
    descend(value, keys)
        .and_then(Value::as_str)
        .filter(|value| !value.trim().is_empty())
        .ok_or_else(|| anyhow!("CAPABILITY_DENIED: missing required field '{}'", label))
}

fn required_i64(value: &Value, keys: &[&str], label: &str) -> Result<i64> {
    descend(value, keys)
        .and_then(Value::as_i64)
        .ok_or_else(|| anyhow!("CAPABILITY_DENIED: missing required field '{}'", label))
}

fn optional_seq(value: &Value, keys: &[&str]) -> Option<Vec<String>> {
    descend(value, keys).and_then(Value::as_sequence).map(|seq| {
        seq.iter()
            .filter_map(Value::as_str)
            .map(ToString::to_string)
            .collect::<Vec<_>>()
    })
}

fn required_seq(value: &Value, keys: &[&str], label: &str) -> Result<Vec<String>> {
    let seq = optional_seq(value, keys)
        .filter(|seq| !seq.is_empty())
        .ok_or_else(|| anyhow!("CAPABILITY_DENIED: missing required field '{}'", label))?;
    Ok(seq)
}

fn descend<'a>(value: &'a Value, keys: &[&str]) -> Option<&'a Value> {
    let mut current = value;
    for key in keys {
        let mapping = current.as_mapping()?;
        current = mapping.get(Value::String((*key).to_string()))?;
    }
    Some(current)
}

fn resolve_repo_path(root_dir: &Path, raw: &str) -> PathBuf {
    match raw {
        "" => root_dir.to_path_buf(),
        _ if raw.starts_with('/') => root_dir.join(raw.trim_start_matches('/')),
        _ if raw.starts_with(".octon/") || raw.starts_with(".github/") => root_dir.join(raw),
        _ => root_dir.join(raw),
    }
}

fn sha256_hex(bytes: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(bytes);
    hex::encode(hasher.finalize())
}
