use crate::errors::{ErrorCode, KernelError, Result};
use serde::Deserialize;
use std::collections::{BTreeMap, BTreeSet};
use std::path::{Path, PathBuf};

/// In-memory runtime configuration produced by `ConfigLoader`.
#[derive(Debug, Clone)]
pub struct RuntimeConfig {
    pub octon_dir: PathBuf,
    pub repo_root: PathBuf,
    pub state_dir: PathBuf,

    pub policy: PolicyConfig,

    /// NDJSON stdio max line length (bytes). Default: 1 MiB.
    pub ndjson_max_line_bytes: usize,

    /// Optional Wasmtime cache config TOML path.
    pub wasmtime_cache_config: Option<PathBuf>,
}

#[derive(Debug, Clone, Default)]
pub struct PolicyConfig {
    pub default_allow: BTreeSet<String>,
    pub category_allow: BTreeMap<String, BTreeSet<String>>,
    pub service_allow: BTreeMap<String, BTreeSet<String>>,
}

pub struct ConfigLoader;

impl ConfigLoader {
    pub fn load(octon_dir: &Path) -> Result<RuntimeConfig> {
        let octon_dir = octon_dir
            .canonicalize()
            .map_err(|e| KernelError::new(ErrorCode::Internal, format!("failed to canonicalize octon_dir: {e}")))?;

        let repo_root = octon_dir
            .parent()
            .ok_or_else(|| KernelError::new(ErrorCode::Internal, ".octon has no parent directory"))?
            .to_path_buf();

        let state_dir = octon_dir.join("engine").join("_ops").join("state");

        let policy_path = Self::resolve_policy_path(&octon_dir)?;
        let policy = if let Some(path) = policy_path {
            Self::load_policy_file(&octon_dir, &path)?
        } else {
            PolicyConfig::default()
        };

        let cache_config_path = octon_dir
            .join("engine")
            .join("runtime")
            .join("config")
            .join("wasmtime-cache.toml");
        let wasmtime_cache_config = if cache_config_path.is_file() {
            Some(cache_config_path)
        } else {
            None
        };

        Ok(RuntimeConfig {
            octon_dir,
            repo_root,
            state_dir,
            policy,
            ndjson_max_line_bytes: 1024 * 1024,
            wasmtime_cache_config,
        })
    }

    /// Resolve the policy file path.
    ///
    /// Behavior (v1 pragmatic):
    /// - If `.octon/octon.yml` contains `engine.runtime.policy_file`, use that (relative to `.octon/`).
    /// - Else, if `.octon/engine/runtime/config/policy.yml` exists, use that.
    /// - Else, no policy file (deny-by-default).
    fn resolve_policy_path(octon_dir: &Path) -> Result<Option<PathBuf>> {
        let octon_yml = octon_dir.join("octon.yml");
        if octon_yml.is_file() {
            if let Ok(bytes) = std::fs::read(&octon_yml) {
                if let Ok(doc) = serde_yaml::from_slice::<serde_yaml::Value>(&bytes) {
                    if let Some(path) = doc
                        .get("engine")
                        .and_then(|v| v.get("runtime"))
                        .and_then(|v| v.get("policy_file"))
                        .and_then(|v| v.as_str())
                    {
                        return Ok(Some(PathBuf::from(path)));
                    }
                }
            }
        }

        let default = octon_dir
            .join("engine")
            .join("runtime")
            .join("config")
            .join("policy.yml");
        if default.is_file() {
            // Return relative path to keep later joins consistent.
            let rel = PathBuf::from("engine/runtime/config/policy.yml");
            return Ok(Some(rel));
        }

        Ok(None)
    }

    fn load_policy_file(octon_dir: &Path, rel_or_abs: &Path) -> Result<PolicyConfig> {
        let path = if rel_or_abs.is_absolute() {
            rel_or_abs.to_path_buf()
        } else {
            octon_dir.join(rel_or_abs)
        };

        let bytes = std::fs::read(&path).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to read policy file {}: {e}", path.display()),
            )
        })?;

        let file: PolicyFile = serde_yaml::from_slice(&bytes).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("policy file is not valid YAML at {}: {e}", path.display()),
            )
        })?;

        // Optional format_version check.
        if let Some(v) = file.format_version.as_deref() {
            if v != "policy-v1" {
                return Err(KernelError::new(
                    ErrorCode::Internal,
                    format!("unsupported policy format_version '{v}'"),
                ));
            }
        }

        let mut cfg = PolicyConfig::default();

        if let Some(def) = file.default {
            cfg.default_allow.extend(def.allow);
        }

        for (cat, block) in file.categories {
            cfg.category_allow.insert(cat, block.allow.into_iter().collect());
        }

        for (id, block) in file.services {
            cfg.service_allow.insert(id, block.allow.into_iter().collect());
        }

        Ok(cfg)
    }
}

#[derive(Debug, Deserialize)]
struct PolicyFile {
    #[serde(default)]
    format_version: Option<String>,

    #[serde(default)]
    default: Option<AllowBlock>,

    #[serde(default)]
    categories: BTreeMap<String, AllowBlock>,

    #[serde(default)]
    services: BTreeMap<String, AllowBlock>,
}

#[derive(Debug, Deserialize, Default)]
struct AllowBlock {
    #[serde(default)]
    allow: Vec<String>,
}
