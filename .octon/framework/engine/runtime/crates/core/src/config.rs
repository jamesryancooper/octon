use crate::errors::{ErrorCode, KernelError, Result};
use octon_runtime_resolver::{
    runtime_route_bundle_publication_bypass, verify_runtime_route_bundle,
};
use serde::Deserialize;
use serde_json::json;
use std::collections::{BTreeMap, BTreeSet};
use std::path::{Path, PathBuf};

fn allow_stale_runtime_route_bundle() -> bool {
    std::env::var("OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE")
        .map(|value| value == "1" || value.eq_ignore_ascii_case("true"))
        .unwrap_or(false)
}

/// In-memory runtime configuration produced by `ConfigLoader`.
#[derive(Debug, Clone)]
pub struct RuntimeConfig {
    pub octon_dir: PathBuf,
    pub repo_root: PathBuf,
    pub run_evidence_root: PathBuf,
    pub run_continuity_root: PathBuf,
    pub execution_control_root: PathBuf,
    pub execution_tmp_root: PathBuf,
    pub runtime_resolution_path: PathBuf,
    pub runtime_route_bundle_path: PathBuf,
    pub runtime_route_bundle_lock_path: PathBuf,
    pub runtime_pack_routes_effective_path: PathBuf,
    pub runtime_pack_routes_lock_path: PathBuf,
    pub runtime_route_bundle_generation_id: String,
    pub runtime_route_bundle_sha256: String,

    pub policy: PolicyConfig,
    pub policy_path: Option<PathBuf>,
    pub execution_governance: ExecutionGovernanceConfig,

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

#[derive(Debug, Clone)]
pub struct ExecutionGovernanceConfig {
    pub default_policy_mode: String,
    pub protected_policy_mode: String,
    pub allowed_development_modes: BTreeSet<String>,
    pub protected_refs: BTreeSet<String>,
    pub protected_workflows: BTreeSet<String>,
    pub critical_action_types: BTreeSet<String>,
    pub receipt_roots: ReceiptRootsConfig,
    pub executor_profiles: BTreeMap<String, ExecutorProfileConfig>,
}

impl Default for ExecutionGovernanceConfig {
    fn default() -> Self {
        let mut allowed_development_modes = BTreeSet::new();
        allowed_development_modes.insert("shadow".to_string());
        allowed_development_modes.insert("soft-enforce".to_string());
        allowed_development_modes.insert("hard-enforce".to_string());

        let mut protected_refs = BTreeSet::new();
        protected_refs.insert("main".to_string());

        let mut protected_workflows = BTreeSet::new();
        protected_workflows.insert("ai-review-gate".to_string());
        protected_workflows.insert("pr-autonomy-policy".to_string());
        protected_workflows.insert("deny-by-default-gates".to_string());
        protected_workflows.insert("release-please".to_string());

        let mut critical_action_types = BTreeSet::new();
        critical_action_types.insert("mutate_repo".to_string());
        critical_action_types.insert("launch_executor_elevated".to_string());
        critical_action_types.insert("publish_artifact".to_string());
        critical_action_types.insert("protected_branch_mutation".to_string());
        critical_action_types.insert("release_publication".to_string());

        let mut executor_profiles = BTreeMap::new();
        executor_profiles.insert(
            "read_only_analysis".to_string(),
            ExecutorProfileConfig {
                name: "read_only_analysis".to_string(),
                dangerous_flags_allowed: false,
                allow_repo_write: false,
                require_hard_enforce: false,
                require_human_review: false,
                require_rollback_metadata: false,
            },
        );
        executor_profiles.insert(
            "patch_generation_only".to_string(),
            ExecutorProfileConfig {
                name: "patch_generation_only".to_string(),
                dangerous_flags_allowed: false,
                allow_repo_write: true,
                require_hard_enforce: false,
                require_human_review: false,
                require_rollback_metadata: false,
            },
        );
        executor_profiles.insert(
            "scoped_repo_mutation".to_string(),
            ExecutorProfileConfig {
                name: "scoped_repo_mutation".to_string(),
                dangerous_flags_allowed: false,
                allow_repo_write: true,
                require_hard_enforce: false,
                require_human_review: false,
                require_rollback_metadata: false,
            },
        );
        executor_profiles.insert(
            "release_candidate_preparation".to_string(),
            ExecutorProfileConfig {
                name: "release_candidate_preparation".to_string(),
                dangerous_flags_allowed: true,
                allow_repo_write: true,
                require_hard_enforce: true,
                require_human_review: true,
                require_rollback_metadata: true,
            },
        );
        executor_profiles.insert(
            "human_review_required".to_string(),
            ExecutorProfileConfig {
                name: "human_review_required".to_string(),
                dangerous_flags_allowed: false,
                allow_repo_write: false,
                require_hard_enforce: true,
                require_human_review: true,
                require_rollback_metadata: true,
            },
        );

        Self {
            default_policy_mode: "hard-enforce".to_string(),
            protected_policy_mode: "hard-enforce".to_string(),
            allowed_development_modes,
            protected_refs,
            protected_workflows,
            critical_action_types,
            receipt_roots: ReceiptRootsConfig::default(),
            executor_profiles,
        }
    }
}

#[derive(Debug, Clone)]
pub struct ReceiptRootsConfig {
    pub kernel: String,
    pub services: String,
    pub workflows: String,
    pub executors: String,
    pub ci: String,
}

impl Default for ReceiptRootsConfig {
    fn default() -> Self {
        Self {
            kernel: ".octon/state/evidence/runs/kernel".to_string(),
            services: ".octon/state/evidence/runs/services".to_string(),
            workflows: ".octon/state/evidence/runs/workflows".to_string(),
            executors: ".octon/state/evidence/runs/executors".to_string(),
            ci: ".octon/state/evidence/runs/ci".to_string(),
        }
    }
}

#[derive(Debug, Clone)]
pub struct ExecutorProfileConfig {
    pub name: String,
    pub dangerous_flags_allowed: bool,
    pub allow_repo_write: bool,
    pub require_hard_enforce: bool,
    pub require_human_review: bool,
    pub require_rollback_metadata: bool,
}

pub struct ConfigLoader;

impl ConfigLoader {
    pub fn load(octon_dir: &Path) -> Result<RuntimeConfig> {
        let octon_dir = octon_dir.canonicalize().map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to canonicalize octon_dir: {e}"),
            )
        })?;

        let repo_root = octon_dir
            .parent()
            .ok_or_else(|| KernelError::new(ErrorCode::Internal, ".octon has no parent directory"))?
            .to_path_buf();

        let run_evidence_root = octon_dir.join("state").join("evidence").join("runs");
        let run_continuity_root = octon_dir.join("state").join("continuity").join("runs");
        let execution_control_root = octon_dir.join("state").join("control").join("execution");
        let execution_tmp_root = octon_dir.join("generated").join(".tmp").join("execution");
        let (
            runtime_resolution_path,
            runtime_route_bundle_path,
            runtime_route_bundle_lock_path,
            runtime_pack_routes_effective_path,
            runtime_pack_routes_lock_path,
            runtime_route_bundle_generation_id,
            runtime_route_bundle_sha256,
        ) = if allow_stale_runtime_route_bundle() {
            let runtime_bundle =
                runtime_route_bundle_publication_bypass(&octon_dir).map_err(|e| {
                    KernelError::new(
                        ErrorCode::CapabilityDenied,
                        format!("runtime-effective route bundle publication bypass failed: {e}"),
                    )
                    .with_details(json!({"reason_codes":["FCR-025"]}))
                })?;
            (
                runtime_bundle.resolution_path.clone(),
                runtime_bundle.bundle_path.clone(),
                runtime_bundle.lock_path.clone(),
                runtime_bundle.pack_routes_effective_path.clone(),
                runtime_bundle.pack_routes_lock_path.clone(),
                runtime_bundle.bundle.generation_id.clone(),
                runtime_bundle.bundle_sha256.clone(),
            )
        } else {
            let runtime_bundle = verify_runtime_route_bundle(&octon_dir).map_err(|e| {
                KernelError::new(
                    ErrorCode::CapabilityDenied,
                    format!("runtime-effective route bundle validation failed: {e}"),
                )
                .with_details(json!({"reason_codes":["FCR-025"]}))
            })?;
            (
                runtime_bundle.resolution_path.clone(),
                runtime_bundle.bundle_path.clone(),
                runtime_bundle.lock_path.clone(),
                runtime_bundle.pack_routes_effective_path.clone(),
                runtime_bundle.pack_routes_lock_path.clone(),
                runtime_bundle.bundle.generation_id.clone(),
                runtime_bundle.bundle_sha256.clone(),
            )
        };

        let root_manifest = Self::load_root_manifest(&octon_dir)?;

        let policy_path = Self::resolve_policy_path(&octon_dir, root_manifest.as_ref())?;
        let policy = if let Some(ref path) = policy_path {
            Self::load_policy_file(&octon_dir, path)?
        } else {
            PolicyConfig::default()
        };
        let execution_governance = Self::load_execution_governance(root_manifest.as_ref());

        let cache_config_path = octon_dir
            .join("framework")
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
            run_evidence_root,
            run_continuity_root,
            execution_control_root,
            execution_tmp_root,
            runtime_resolution_path,
            runtime_route_bundle_path,
            runtime_route_bundle_lock_path,
            runtime_pack_routes_effective_path,
            runtime_pack_routes_lock_path,
            runtime_route_bundle_generation_id,
            runtime_route_bundle_sha256,
            policy,
            policy_path,
            execution_governance,
            ndjson_max_line_bytes: 1024 * 1024,
            wasmtime_cache_config,
        })
    }

    /// Resolve the policy file path.
    ///
    /// Behavior (v1 pragmatic):
    /// - If `.octon/octon.yml` contains `engine.runtime.policy_file`, use that (relative to `.octon/`).
    /// - Else, if `.octon/framework/engine/runtime/config/policy.yml` exists, use that.
    /// - Else, no policy file (deny-by-default).
    fn load_root_manifest(octon_dir: &Path) -> Result<Option<serde_yaml::Value>> {
        let octon_yml = octon_dir.join("octon.yml");
        if !octon_yml.is_file() {
            return Ok(None);
        }

        let bytes = std::fs::read(&octon_yml).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to read root manifest {}: {e}", octon_yml.display()),
            )
        })?;

        let doc = serde_yaml::from_slice::<serde_yaml::Value>(&bytes).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!(
                    "root manifest is not valid YAML at {}: {e}",
                    octon_yml.display()
                ),
            )
        })?;

        Ok(Some(doc))
    }

    fn resolve_policy_path(
        octon_dir: &Path,
        root_manifest: Option<&serde_yaml::Value>,
    ) -> Result<Option<PathBuf>> {
        if let Some(path) = root_manifest
            .and_then(|doc| doc.get("engine"))
            .and_then(|v| v.get("runtime"))
            .and_then(|v| v.get("policy_file"))
            .and_then(|v| v.as_str())
        {
            return Ok(Some(PathBuf::from(path)));
        }

        let default = octon_dir
            .join("framework")
            .join("engine")
            .join("runtime")
            .join("config")
            .join("policy.yml");
        if default.is_file() {
            // Return relative path to keep later joins consistent.
            let rel = PathBuf::from("framework/engine/runtime/config/policy.yml");
            return Ok(Some(rel));
        }

        Ok(None)
    }

    fn load_execution_governance(
        root_manifest: Option<&serde_yaml::Value>,
    ) -> ExecutionGovernanceConfig {
        let mut cfg = ExecutionGovernanceConfig::default();
        let Some(exec) = root_manifest.and_then(|doc| doc.get("execution_governance")) else {
            return cfg;
        };

        if let Some(value) = exec
            .get("policy_mode")
            .and_then(|v| v.get("default"))
            .and_then(|v| v.as_str())
        {
            cfg.default_policy_mode = value.to_string();
        }
        if let Some(value) = exec
            .get("policy_mode")
            .and_then(|v| v.get("protected"))
            .and_then(|v| v.as_str())
        {
            cfg.protected_policy_mode = value.to_string();
        }
        if let Some(values) = exec
            .get("policy_mode")
            .and_then(|v| v.get("allowed_development_modes"))
            .and_then(|v| v.as_sequence())
        {
            cfg.allowed_development_modes = values
                .iter()
                .filter_map(|value| value.as_str().map(ToOwned::to_owned))
                .collect();
        }
        if let Some(values) = exec.get("protected_refs").and_then(|v| v.as_sequence()) {
            cfg.protected_refs = values
                .iter()
                .filter_map(|value| value.as_str().map(ToOwned::to_owned))
                .collect();
        }
        if let Some(values) = exec
            .get("protected_workflows")
            .and_then(|v| v.as_sequence())
        {
            cfg.protected_workflows = values
                .iter()
                .filter_map(|value| value.as_str().map(ToOwned::to_owned))
                .collect();
        }
        if let Some(values) = exec
            .get("critical_action_types")
            .and_then(|v| v.as_sequence())
        {
            cfg.critical_action_types = values
                .iter()
                .filter_map(|value| value.as_str().map(ToOwned::to_owned))
                .collect();
        }

        if let Some(receipt_roots) = exec.get("receipt_roots") {
            if let Some(value) = receipt_roots.get("kernel").and_then(|v| v.as_str()) {
                cfg.receipt_roots.kernel = value.to_string();
            }
            if let Some(value) = receipt_roots.get("services").and_then(|v| v.as_str()) {
                cfg.receipt_roots.services = value.to_string();
            }
            if let Some(value) = receipt_roots.get("workflows").and_then(|v| v.as_str()) {
                cfg.receipt_roots.workflows = value.to_string();
            }
            if let Some(value) = receipt_roots.get("executors").and_then(|v| v.as_str()) {
                cfg.receipt_roots.executors = value.to_string();
            }
            if let Some(value) = receipt_roots.get("ci").and_then(|v| v.as_str()) {
                cfg.receipt_roots.ci = value.to_string();
            }
        }

        if let Some(profiles) = exec.get("executor_profiles").and_then(|v| v.as_mapping()) {
            cfg.executor_profiles.clear();
            for (key, value) in profiles {
                let Some(name) = key.as_str() else {
                    continue;
                };
                let profile = ExecutorProfileConfig {
                    name: name.to_string(),
                    dangerous_flags_allowed: value
                        .get(serde_yaml::Value::from("dangerous_flags_allowed"))
                        .and_then(|v| v.as_bool())
                        .unwrap_or(false),
                    allow_repo_write: value
                        .get(serde_yaml::Value::from("allow_repo_write"))
                        .and_then(|v| v.as_bool())
                        .unwrap_or(false),
                    require_hard_enforce: value
                        .get(serde_yaml::Value::from("require_hard_enforce"))
                        .and_then(|v| v.as_bool())
                        .unwrap_or(false),
                    require_human_review: value
                        .get(serde_yaml::Value::from("require_human_review"))
                        .and_then(|v| v.as_bool())
                        .unwrap_or(false),
                    require_rollback_metadata: value
                        .get(serde_yaml::Value::from("require_rollback_metadata"))
                        .and_then(|v| v.as_bool())
                        .unwrap_or(false),
                };
                cfg.executor_profiles.insert(name.to_string(), profile);
            }
        }

        cfg
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
            cfg.category_allow
                .insert(cat, block.allow.into_iter().collect());
        }

        for (id, block) in file.services {
            cfg.service_allow
                .insert(id, block.allow.into_iter().collect());
        }

        Ok(cfg)
    }
}

impl RuntimeConfig {
    pub fn run_root(&self, request_id: &str) -> PathBuf {
        self.run_evidence_root.join(request_id)
    }

    pub fn run_continuity_path(&self, request_id: &str) -> PathBuf {
        self.run_continuity_root.join(request_id)
    }

    pub fn run_control_root(&self, request_id: &str) -> PathBuf {
        self.execution_control_root.join("runs").join(request_id)
    }

    pub fn ensure_execution_write_path(&self, path: &Path) -> Result<()> {
        if path.starts_with(self.octon_dir.join("framework")) {
            return Err(KernelError::new(
                ErrorCode::CapabilityDenied,
                format!(
                    "execution write target must not resolve under framework/**: {}",
                    path.display()
                ),
            ));
        }

        if path.starts_with(&self.run_evidence_root)
            || path.starts_with(&self.run_continuity_root)
            || path.starts_with(&self.execution_control_root)
            || path.starts_with(&self.execution_tmp_root)
        {
            return Ok(());
        }

        Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            format!(
                "execution write target falls outside declared execution roots: {}",
                path.display()
            ),
        ))
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
