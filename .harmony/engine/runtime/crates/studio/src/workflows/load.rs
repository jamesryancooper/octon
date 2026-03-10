use anyhow::{Context, Result};
use serde::Deserialize;
use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::path::{Path, PathBuf};

#[derive(Debug, Clone)]
pub struct WorkflowSummary {
    pub id: String,
    pub manifest_path_hint: Option<String>,
    pub registry_path_hint: Option<String>,
    pub workflow_dir: PathBuf,
    pub contract_file: PathBuf,
    pub has_contract_file: bool,
    pub workflow_file: PathBuf,
    pub has_workflow_file: bool,
    pub dependencies: Vec<String>,
    pub document: Option<WorkflowDocument>,
    pub parse_error: Option<String>,
}

#[derive(Debug, Clone)]
pub struct WorkflowDocument {
    pub name: Option<String>,
    pub description: Option<String>,
    pub steps: Vec<WorkflowStepSummary>,
}

#[derive(Debug, Clone)]
pub struct WorkflowStepSummary {
    pub id: String,
    pub file: String,
    pub description: Option<String>,
    pub path: PathBuf,
    pub exists: bool,
}

#[derive(Debug, Clone)]
pub struct WorkflowIndexSnapshot {
    pub manifest_path: PathBuf,
    pub registry_path: PathBuf,
    pub workflows: Vec<WorkflowSummary>,
    pub registry_ids: BTreeSet<String>,
}

#[derive(Debug, Deserialize)]
struct ManifestFile {
    #[serde(default)]
    workflows: Vec<ManifestWorkflow>,
}

#[derive(Debug, Deserialize)]
struct ManifestWorkflow {
    id: String,
    path: Option<String>,
}

#[derive(Debug, Deserialize)]
struct RegistryFile {
    #[serde(default)]
    workflows: BTreeMap<String, RegistryWorkflow>,
}

#[derive(Debug, Deserialize, Default)]
struct RegistryWorkflow {
    path: Option<String>,
    #[serde(default)]
    depends_on: Vec<RegistryDependency>,
}

#[derive(Debug, Deserialize, Default)]
struct RegistryDependency {
    workflow: Option<String>,
}

#[derive(Debug, Deserialize, Default)]
struct WorkflowContract {
    name: Option<String>,
    description: Option<String>,
    #[serde(default)]
    stages: Vec<WorkflowStageContract>,
}

#[derive(Debug, Deserialize)]
struct WorkflowStageContract {
    id: String,
    asset: String,
    description: Option<String>,
}

pub fn load_workflow_index(root: &Path) -> Result<WorkflowIndexSnapshot> {
    let workflows_root = root.join(".harmony/orchestration/runtime/workflows");
    let manifest_path = workflows_root.join("manifest.yml");
    let registry_path = workflows_root.join("registry.yml");

    let manifest_raw = fs::read_to_string(&manifest_path).with_context(|| {
        format!(
            "failed to read workflow manifest at {}",
            manifest_path.display()
        )
    })?;
    let registry_raw = fs::read_to_string(&registry_path).with_context(|| {
        format!(
            "failed to read workflow registry at {}",
            registry_path.display()
        )
    })?;

    let manifest: ManifestFile = serde_yaml::from_str(&manifest_raw)
        .with_context(|| format!("failed to parse {}", manifest_path.display()))?;
    let registry: RegistryFile = serde_yaml::from_str(&registry_raw)
        .with_context(|| format!("failed to parse {}", registry_path.display()))?;

    let registry_ids = registry.workflows.keys().cloned().collect();
    let mut workflows: Vec<WorkflowSummary> = manifest
        .workflows
        .into_iter()
        .map(|workflow| {
            let registry_entry = registry.workflows.get(&workflow.id);
            let registry_path_hint = registry_entry.and_then(|entry| entry.path.clone());
            let workflow_dir = resolve_workflow_dir(
                &workflows_root,
                &workflow.id,
                workflow.path.as_deref(),
                registry_path_hint.as_deref(),
            );
            let contract_file = workflow_dir.join("workflow.yml");
            let workflow_file = workflow_dir.join("README.md");
            let dependencies = registry_entry
                .map(|entry| {
                    entry
                        .depends_on
                        .iter()
                        .filter_map(|dependency| dependency.workflow.as_deref())
                        .map(normalize_workflow_reference)
                        .filter(|reference| !reference.is_empty())
                        .collect::<Vec<_>>()
                })
                .unwrap_or_default();
            let (document, parse_error) = parse_workflow_contract(&workflow_dir, &contract_file);
            WorkflowSummary {
                id: workflow.id,
                manifest_path_hint: workflow.path,
                registry_path_hint,
                has_contract_file: contract_file.exists(),
                contract_file,
                has_workflow_file: workflow_file.exists(),
                workflow_file,
                workflow_dir,
                dependencies,
                document,
                parse_error,
            }
        })
        .collect();
    workflows.sort_by(|left, right| left.id.cmp(&right.id));

    Ok(WorkflowIndexSnapshot {
        manifest_path,
        registry_path,
        workflows,
        registry_ids,
    })
}

fn resolve_workflow_dir(
    workflows_root: &Path,
    id: &str,
    manifest_path: Option<&str>,
    registry_path: Option<&str>,
) -> PathBuf {
    if let Some(path_hint) = manifest_path {
        let normalized = path_hint.trim().trim_end_matches('/');
        if !normalized.is_empty() {
            return workflows_root.join(normalized);
        }
    }

    if let Some(path_hint) = registry_path {
        let normalized = path_hint.trim().trim_end_matches('/');
        if !normalized.is_empty() {
            return workflows_root.join(normalized);
        }
    }

    workflows_root.join(id)
}

fn normalize_workflow_reference(raw: &str) -> String {
    raw.trim()
        .trim_matches('"')
        .split('/')
        .next_back()
        .unwrap_or(raw.trim())
        .to_string()
}

fn parse_workflow_contract(
    workflow_dir: &Path,
    contract_file: &Path,
) -> (Option<WorkflowDocument>, Option<String>) {
    if !contract_file.exists() {
        return (None, None);
    }

    let workflow_yaml = match fs::read_to_string(contract_file) {
        Ok(value) => value,
        Err(error) => {
            return (
                None,
                Some(format!(
                    "failed to read {}: {error}",
                    contract_file.display()
                )),
            );
        }
    };

    let contract: WorkflowContract = match serde_yaml::from_str(&workflow_yaml) {
        Ok(value) => value,
        Err(error) => {
            return (
                None,
                Some(format!(
                    "invalid workflow contract in {}: {error}",
                    contract_file.display()
                )),
            );
        }
    };

    let steps = contract
        .stages
        .into_iter()
        .map(|step| {
            let path = workflow_dir.join(&step.asset);
            WorkflowStepSummary {
                id: step.id,
                file: step.asset,
                description: step.description,
                exists: path.exists(),
                path,
            }
        })
        .collect();

    (
        Some(WorkflowDocument {
            name: contract.name,
            description: contract.description,
            steps,
        }),
        None,
    )
}
