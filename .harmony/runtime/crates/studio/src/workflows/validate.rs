use crate::workflows::WorkflowIndexSnapshot;
use std::collections::BTreeSet;
use std::path::PathBuf;

#[derive(Debug, Clone)]
pub struct ValidationIssue {
    pub code: &'static str,
    pub workflow_id: Option<String>,
    pub message: String,
    pub path: Option<PathBuf>,
}

pub fn validate_snapshot(snapshot: &WorkflowIndexSnapshot) -> Vec<ValidationIssue> {
    let mut issues = Vec::new();

    for workflow in &snapshot.workflows {
        if !workflow.has_workflow_file {
            issues.push(ValidationIssue {
                code: "missing-workflow-file",
                workflow_id: Some(workflow.id.clone()),
                message: format!("Workflow '{}' is missing WORKFLOW.md", workflow.id),
                path: Some(workflow.workflow_file.clone()),
            });
        }

        if let Some(parse_error) = &workflow.parse_error {
            issues.push(ValidationIssue {
                code: "invalid-workflow-frontmatter",
                workflow_id: Some(workflow.id.clone()),
                message: format!(
                    "Workflow '{}' frontmatter error: {parse_error}",
                    workflow.id
                ),
                path: Some(workflow.workflow_file.clone()),
            });
        }

        if let Some(document) = &workflow.document {
            if document.steps.is_empty() {
                issues.push(ValidationIssue {
                    code: "missing-workflow-steps",
                    workflow_id: Some(workflow.id.clone()),
                    message: format!(
                        "Workflow '{}' does not declare any step entries in frontmatter",
                        workflow.id
                    ),
                    path: Some(workflow.workflow_file.clone()),
                });
            }

            for step in &document.steps {
                if !step.exists {
                    issues.push(ValidationIssue {
                        code: "missing-step-file",
                        workflow_id: Some(workflow.id.clone()),
                        message: format!(
                            "Workflow '{}' step '{}' points to missing file '{}'",
                            workflow.id, step.id, step.file
                        ),
                        path: Some(step.path.clone()),
                    });
                }
            }
        }
    }

    let manifest_ids: BTreeSet<String> = snapshot
        .workflows
        .iter()
        .map(|workflow| workflow.id.clone())
        .collect();

    for workflow in &snapshot.workflows {
        if !snapshot.registry_ids.contains(&workflow.id) {
            issues.push(ValidationIssue {
                code: "missing-registry-entry",
                workflow_id: Some(workflow.id.clone()),
                message: format!(
                    "Workflow '{}' exists in manifest but not in registry",
                    workflow.id
                ),
                path: Some(snapshot.registry_path.clone()),
            });
        }

        for dependency in &workflow.dependencies {
            if !manifest_ids.contains(dependency) {
                issues.push(ValidationIssue {
                    code: "unknown-workflow-dependency",
                    workflow_id: Some(workflow.id.clone()),
                    message: format!(
                        "Workflow '{}' depends on missing workflow '{}'",
                        workflow.id, dependency
                    ),
                    path: Some(snapshot.registry_path.clone()),
                });
            }
        }
    }

    for registry_id in &snapshot.registry_ids {
        if !manifest_ids.contains(registry_id) {
            issues.push(ValidationIssue {
                code: "missing-manifest-entry",
                workflow_id: Some(registry_id.clone()),
                message: format!(
                    "Workflow '{}' exists in registry but not in manifest",
                    registry_id
                ),
                path: Some(snapshot.manifest_path.clone()),
            });
        }
    }

    issues
}
