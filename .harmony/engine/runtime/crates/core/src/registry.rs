use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, HashMap};
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServiceManifestV1 {
    pub format_version: String,
    pub name: String,
    pub version: String,
    pub category: String,
    pub abi: String,
    pub entry: String,
    pub capabilities_required: Vec<String>,
    pub ops: BTreeMap<String, OpDeclV1>,
    pub limits: LimitsV1,
    pub integrity: Option<IntegrityV1>,
    pub docs: Option<DocsV1>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OpDeclV1 {
    pub input_schema: serde_json::Value,
    pub output_schema: serde_json::Value,
    pub idempotent: Option<bool>,
    pub streaming: Option<bool>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LimitsV1 {
    pub max_request_bytes: u64,
    pub max_response_bytes: u64,
    pub timeout_ms: u64,
    pub max_concurrency: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IntegrityV1 {
    pub wasm_sha256: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DocsV1 {
    pub summary: Option<String>,
    pub help: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct ServiceKey {
    pub category: String,
    pub name: String,
}

impl ServiceKey {
    pub fn id(&self) -> String {
        format!("{}/{}", self.category, self.name)
    }
}

#[derive(Debug, Clone)]
pub struct ServiceDescriptor {
    pub key: ServiceKey,
    pub version: semver::Version,
    pub dir: PathBuf,
    pub wasm_path: PathBuf,
    pub manifest: ServiceManifestV1,
}

#[derive(Debug, Default, Clone)]
pub struct ServiceRegistry {
    by_key: HashMap<ServiceKey, ServiceDescriptor>,
}

impl ServiceRegistry {
    pub fn new(by_key: HashMap<ServiceKey, ServiceDescriptor>) -> Self {
        Self { by_key }
    }

    pub fn get(&self, key: &ServiceKey) -> Option<&ServiceDescriptor> {
        self.by_key.get(key)
    }

    pub fn list(&self) -> Vec<&ServiceDescriptor> {
        let mut out: Vec<&ServiceDescriptor> = self.by_key.values().collect();
        out.sort_by(|a, b| a.key.id().cmp(&b.key.id()));
        out
    }

    /// Resolve a service by "name" alone.
    ///
    /// If multiple categories provide the same name, this returns None.
    pub fn get_by_name_unique(&self, name: &str) -> Option<&ServiceDescriptor> {
        let mut found: Option<&ServiceDescriptor> = None;
        for d in self.by_key.values() {
            if d.key.name == name {
                if found.is_some() {
                    return None;
                }
                found = Some(d);
            }
        }
        found
    }

    /// Resolve a service by either "category/name" or "name" (if unique).
    pub fn resolve_id(&self, id_or_name: &str) -> Option<&ServiceDescriptor> {
        if let Some((cat, name)) = id_or_name.split_once('/') {
            let key = ServiceKey {
                category: cat.to_string(),
                name: name.to_string(),
            };
            return self.by_key.get(&key);
        }
        self.get_by_name_unique(id_or_name)
    }
}
