use crate::graph::layout::{layered_layout, Edge, Node, PositionedNode};
use crate::staging::{list_recent_apply_audits, ApplyAuditSummary, StagedEditBuffer};
use crate::workflows::{
    load_workflow_index, validate_snapshot, ValidationIssue, WorkflowIndexSnapshot, WorkflowSummary,
};
use anyhow::{anyhow, Result};
use serde_yaml::{Mapping, Value};
use std::collections::HashMap;
use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command as ProcessCommand, Stdio};

const MIN_ZOOM: f32 = 0.55;
const MAX_ZOOM: f32 = 2.4;
const PATCH_PREVIEW_LIMIT: usize = 18_000;
const AUDIT_LIST_LIMIT: usize = 6;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum AuditStatusFilter {
    All,
    AppliedOnly,
    FailedOnly,
}

impl AuditStatusFilter {
    fn from_mode(mode: i32) -> Self {
        match mode {
            1 => Self::AppliedOnly,
            2 => Self::FailedOnly,
            _ => Self::All,
        }
    }

    fn mode(self) -> i32 {
        match self {
            Self::All => 0,
            Self::AppliedOnly => 1,
            Self::FailedOnly => 2,
        }
    }
}

#[derive(Debug, Clone)]
pub struct WorkflowListItemState {
    pub id: String,
    pub label: String,
    pub selected: bool,
    pub issue_count: i32,
    pub step_count: i32,
}

#[derive(Debug, Clone)]
pub struct GraphNodeState {
    pub id: String,
    pub label: String,
    pub x: f32,
    pub y: f32,
    pub selected: bool,
}

#[derive(Debug, Clone)]
pub struct InspectorStepState {
    pub id: String,
    pub file: String,
    pub status: String,
    pub description: String,
}

#[derive(Debug, Clone)]
pub struct InspectorIssueState {
    pub code: String,
    pub message: String,
}

#[derive(Debug, Clone)]
pub struct ApplyAuditItemState {
    pub path: String,
    pub status: String,
    pub summary: String,
    pub selected: bool,
}

pub struct AppState {
    root: PathBuf,
    snapshot: WorkflowIndexSnapshot,
    issues: Vec<ValidationIssue>,
    base_layout: Vec<PositionedNode>,
    edges: Vec<Edge>,
    selected_workflow_id: Option<String>,
    pan_x: f32,
    pan_y: f32,
    zoom: f32,
    staged_edits: StagedEditBuffer,
    apply_armed: bool,
    recent_audits: Vec<ApplyAuditSummary>,
    audit_filter_query: String,
    audit_status_filter: AuditStatusFilter,
    selected_audit_index: Option<usize>,
    selected_audit_path: String,
    selected_audit_preview: String,
    patch_preview: String,
    export_status: String,
}

impl AppState {
    pub fn load(root: PathBuf) -> Result<Self> {
        let snapshot = load_workflow_index(&root)?;
        let issues = validate_snapshot(&snapshot);
        let (base_layout, edges) = build_graph_layout(&snapshot);
        let selected_workflow_id = snapshot
            .workflows
            .first()
            .map(|workflow| workflow.id.clone());
        let recent_audits = list_recent_apply_audits(&root, 10).unwrap_or_default();

        let mut state = Self {
            root,
            snapshot,
            issues,
            base_layout,
            edges,
            selected_workflow_id,
            pan_x: 0.0,
            pan_y: 0.0,
            zoom: 1.0,
            staged_edits: StagedEditBuffer::default(),
            apply_armed: false,
            recent_audits,
            audit_filter_query: String::new(),
            audit_status_filter: AuditStatusFilter::All,
            selected_audit_index: None,
            selected_audit_path: "No audit selected".to_string(),
            selected_audit_preview: "# Select an audit entry to preview markdown.\n".to_string(),
            patch_preview: "# No staged edits.\n".to_string(),
            export_status: "No staged edits yet.".to_string(),
        };
        state.sync_selected_audit_after_reload(None);
        Ok(state)
    }

    pub fn root_display(&self) -> String {
        self.root.display().to_string()
    }

    pub fn workflow_count(&self) -> usize {
        self.snapshot.workflows.len()
    }

    pub fn issue_count(&self) -> usize {
        self.issues.len()
    }

    pub fn edge_count(&self) -> usize {
        self.edges.len()
    }

    pub fn staged_edit_count(&self) -> usize {
        self.staged_edits.len()
    }

    pub fn apply_armed(&self) -> bool {
        self.apply_armed
    }

    pub fn patch_preview_text(&self) -> String {
        if self.patch_preview.len() <= PATCH_PREVIEW_LIMIT {
            return self.patch_preview.clone();
        }
        let mut preview = self.patch_preview[..PATCH_PREVIEW_LIMIT].to_string();
        preview.push_str("\n# ... preview truncated ...\n");
        preview
    }

    pub fn export_status_text(&self) -> String {
        self.export_status.clone()
    }

    pub fn audit_count(&self) -> usize {
        self.filtered_audit_indices().len()
    }

    pub fn audit_filter_query_text(&self) -> String {
        self.audit_filter_query.clone()
    }

    pub fn audit_status_filter_mode(&self) -> i32 {
        self.audit_status_filter.mode()
    }

    pub fn audit_items(&self) -> Vec<ApplyAuditItemState> {
        self.filtered_audit_indices()
            .into_iter()
            .take(AUDIT_LIST_LIMIT)
            .filter_map(|audit_index| {
                self.recent_audits
                    .get(audit_index)
                    .map(|audit| (audit_index, audit))
            })
            .map(|(audit_index, audit)| ApplyAuditItemState {
                path: audit.path.display().to_string(),
                status: audit.status.clone(),
                summary: if let Some(timestamp) = audit.timestamp_unix_ms {
                    format!("[{timestamp}] {}", audit.summary)
                } else {
                    audit.summary.clone()
                },
                selected: self.selected_audit_index == Some(audit_index),
            })
            .collect()
    }

    pub fn selected_audit_path_text(&self) -> String {
        self.selected_audit_path.clone()
    }

    pub fn selected_audit_preview_text(&self) -> String {
        self.selected_audit_preview.clone()
    }

    pub fn workflow_list_items(&self) -> Vec<WorkflowListItemState> {
        self.snapshot
            .workflows
            .iter()
            .map(|workflow| {
                let step_count = workflow
                    .document
                    .as_ref()
                    .map_or(0, |document| document.steps.len())
                    as i32;
                WorkflowListItemState {
                    id: workflow.id.clone(),
                    label: workflow.id.clone(),
                    selected: self.selected_workflow_id.as_deref() == Some(workflow.id.as_str()),
                    issue_count: self.issue_count_for_workflow(&workflow.id) as i32,
                    step_count,
                }
            })
            .collect()
    }

    pub fn graph_node_items(&self) -> Vec<GraphNodeState> {
        let mut workflow_by_id = HashMap::new();
        for workflow in &self.snapshot.workflows {
            workflow_by_id.insert(workflow.id.as_str(), workflow);
        }

        self.base_layout
            .iter()
            .map(|position| {
                let label = workflow_by_id
                    .get(position.id.as_str())
                    .map(|workflow| workflow.id.clone())
                    .unwrap_or_else(|| position.id.clone());
                GraphNodeState {
                    id: position.id.clone(),
                    label,
                    x: position.x * self.zoom + self.pan_x,
                    y: position.y * self.zoom + self.pan_y,
                    selected: self.selected_workflow_id.as_deref() == Some(position.id.as_str()),
                }
            })
            .collect()
    }

    pub fn selected_title(&self) -> String {
        if let Some(workflow) = self.selected_workflow() {
            if let Some(document) = &workflow.document {
                if let Some(name) = &document.name {
                    if !name.trim().is_empty() {
                        return format!("{name} ({})", workflow.id);
                    }
                }
            }
            return workflow.id.clone();
        }
        "No workflow selected".to_string()
    }

    pub fn selected_description(&self) -> String {
        if let Some(workflow) = self.selected_workflow() {
            if let Some(document) = &workflow.document {
                if let Some(description) = &document.description {
                    if !description.trim().is_empty() {
                        return description.clone();
                    }
                }
            }
            return "Workflow frontmatter did not provide a description.".to_string();
        }
        "Select a workflow from the left list or graph canvas.".to_string()
    }

    pub fn selected_path(&self) -> String {
        if let Some(workflow) = self.selected_workflow() {
            let mut segments = vec![
                format!("workflow file: {}", workflow.workflow_file.display()),
                format!("workflow dir: {}", workflow.workflow_dir.display()),
            ];
            if let Some(path_hint) = &workflow.manifest_path_hint {
                segments.push(format!("manifest path hint: {path_hint}"));
            }
            if let Some(path_hint) = &workflow.registry_path_hint {
                segments.push(format!("registry path hint: {path_hint}"));
            }
            return segments.join(" | ");
        }
        "-".to_string()
    }

    pub fn selected_dependency_summary(&self) -> String {
        if let Some(workflow) = self.selected_workflow() {
            if workflow.dependencies.is_empty() {
                return "Dependencies: none".to_string();
            }
            return format!("Dependencies: {}", workflow.dependencies.join(", "));
        }
        "Dependencies: -".to_string()
    }

    pub fn selected_steps(&self) -> Vec<InspectorStepState> {
        let Some(workflow) = self.selected_workflow() else {
            return Vec::new();
        };
        let Some(document) = &workflow.document else {
            return Vec::new();
        };

        document
            .steps
            .iter()
            .map(|step| InspectorStepState {
                id: step.id.clone(),
                file: step.file.clone(),
                status: if step.exists {
                    "ok".to_string()
                } else {
                    "missing".to_string()
                },
                description: step.description.clone().unwrap_or_default(),
            })
            .collect()
    }

    pub fn selected_issues(&self) -> Vec<InspectorIssueState> {
        let selected_id = self.selected_workflow_id.as_deref();
        self.issues
            .iter()
            .filter(|issue| issue.workflow_id.as_deref() == selected_id)
            .map(|issue| InspectorIssueState {
                code: issue.code.to_string(),
                message: if let Some(path) = &issue.path {
                    format!("{} [{}]", issue.message, path.display())
                } else {
                    issue.message.clone()
                },
            })
            .collect()
    }

    pub fn selected_issue_count(&self) -> usize {
        self.selected_issues().len()
    }

    pub fn zoom_percent(&self) -> i32 {
        (self.zoom * 100.0).round() as i32
    }

    pub fn select_workflow(&mut self, workflow_id: &str) {
        self.selected_workflow_id = Some(workflow_id.to_string());
    }

    pub fn pan_by(&mut self, delta_x: f32, delta_y: f32) {
        self.pan_x = (self.pan_x + delta_x).clamp(-1800.0, 1800.0);
        self.pan_y = (self.pan_y + delta_y).clamp(-1400.0, 1400.0);
    }

    pub fn zoom_by(&mut self, factor: f32) {
        self.zoom = (self.zoom * factor).clamp(MIN_ZOOM, MAX_ZOOM);
    }

    pub fn reset_view(&mut self) {
        self.pan_x = 0.0;
        self.pan_y = 0.0;
        self.zoom = 1.0;
    }

    pub fn stage_selected_safe_edits(&mut self) -> Result<()> {
        let Some(workflow) = self.selected_workflow().cloned() else {
            self.apply_armed = false;
            self.export_status = "Select a workflow before staging edits.".to_string();
            return Ok(());
        };

        let existing_edit_count = self.staged_edits.len();
        let mut touched_targets = 0usize;

        if workflow.has_workflow_file {
            let original = match fs::read_to_string(&workflow.workflow_file) {
                Ok(contents) => contents,
                Err(error) => {
                    self.export_status = format!(
                        "Failed to read {}: {error}",
                        workflow.workflow_file.display()
                    );
                    return Err(error.into());
                }
            };
            let normalized = normalize_workflow_markdown(&workflow.id, &original);
            self.staged_edits.stage_update(
                workflow.workflow_file.clone(),
                original,
                normalized,
                "Normalize WORKFLOW.md frontmatter defaults".to_string(),
            );
            touched_targets += 1;
        } else {
            self.staged_edits.stage_create(
                workflow.workflow_file.clone(),
                workflow_file_template(&workflow.id),
                "Create missing WORKFLOW.md from safe template".to_string(),
            );
            touched_targets += 1;
        }

        if let Some(document) = workflow.document {
            for step in document.steps {
                if !step.exists {
                    self.staged_edits.stage_create(
                        step.path.clone(),
                        step_file_template(&step.id, step.description.as_deref()),
                        format!("Create missing step file '{}'", step.file),
                    );
                    touched_targets += 1;
                }
            }
        }

        self.refresh_patch_preview();
        let total_staged = self.staged_edits.len();
        let newly_staged = total_staged.saturating_sub(existing_edit_count);
        self.apply_armed = false;
        if total_staged == 0 {
            self.export_status = format!("No staged edits were needed for '{}'.", workflow.id);
        } else {
            self.export_status = format!(
                "Staged {} new edits ({} total) across {} targets for '{}'.",
                newly_staged, total_staged, touched_targets, workflow.id
            );
        }

        Ok(())
    }

    pub fn clear_staged_edits(&mut self) {
        self.staged_edits.clear();
        self.apply_armed = false;
        self.refresh_patch_preview();
        self.export_status = "Cleared staged edit buffer.".to_string();
    }

    pub fn export_patch_preview(&mut self) -> Result<()> {
        if self.staged_edits.is_empty() {
            self.export_status = "No staged edits to export.".to_string();
            return Ok(());
        }

        let path = match self.staged_edits.export_patch_preview(&self.root) {
            Ok(path) => path,
            Err(error) => {
                self.export_status = format!("Failed to export patch preview: {error}");
                return Err(error);
            }
        };
        self.export_status = format!("Patch preview exported to {}.", path.display());
        Ok(())
    }

    pub fn refresh_audit_index(&mut self) {
        let preferred = self.current_selected_audit_path();
        match list_recent_apply_audits(&self.root, 10) {
            Ok(audits) => {
                self.recent_audits = audits;
                self.sync_selected_audit_after_reload(preferred.as_deref());
                self.export_status =
                    format!("Reloaded {} apply audit records.", self.recent_audits.len());
            }
            Err(error) => {
                self.export_status = format!("Failed to reload apply audits: {error}");
            }
        }
    }

    pub fn set_audit_filter_query(&mut self, query: &str) {
        self.audit_filter_query = query.to_string();
        let preferred = self.current_selected_audit_path();
        self.sync_selected_audit_after_reload(preferred.as_deref());
        self.export_status = format!(
            "Audit search query updated ({} matches).",
            self.audit_count()
        );
    }

    pub fn set_audit_status_filter(&mut self, mode: i32) {
        self.audit_status_filter = AuditStatusFilter::from_mode(mode);
        let preferred = self.current_selected_audit_path();
        self.sync_selected_audit_after_reload(preferred.as_deref());
        self.export_status = format!(
            "Audit status filter updated ({} matches).",
            self.audit_count()
        );
    }

    pub fn select_audit(&mut self, index: i32) {
        if index < 0 {
            self.export_status = format!("Invalid audit selection index: {index}");
            return;
        }
        let index = index as usize;
        let visible = self
            .filtered_audit_indices()
            .into_iter()
            .take(AUDIT_LIST_LIMIT)
            .collect::<Vec<_>>();
        if index >= visible.len() {
            self.export_status = format!("Invalid audit selection index: {index}");
            return;
        }

        self.selected_audit_index = Some(visible[index]);
        self.refresh_selected_audit_preview();
        self.export_status = format!("Selected audit: {}", self.selected_audit_path);
    }

    pub fn open_selected_audit_location(&mut self) -> Result<()> {
        let Some(path) = self.current_selected_audit_path() else {
            self.export_status = "No audit selected to open.".to_string();
            return Ok(());
        };

        if let Err(error) = reveal_path_in_system(&path) {
            self.export_status = format!("Failed to open audit location: {error}");
            return Err(error);
        }

        self.export_status = format!("Opened audit location for {}.", path.display());
        Ok(())
    }

    pub fn copy_selected_audit_path(&mut self) -> Result<()> {
        let Some(path) = self.current_selected_audit_path() else {
            self.export_status = "No audit selected to copy.".to_string();
            return Ok(());
        };

        let path_text = path.display().to_string();
        if let Err(error) = copy_text_to_clipboard(&path_text) {
            self.export_status = format!("Failed to copy audit path: {error}");
            return Err(error);
        }

        self.export_status = format!("Copied audit path to clipboard: {}", path.display());
        Ok(())
    }

    pub fn toggle_apply_arm(&mut self) {
        if self.staged_edits.is_empty() {
            self.apply_armed = false;
            self.export_status = "No staged edits to arm.".to_string();
            return;
        }

        self.apply_armed = !self.apply_armed;
        self.export_status = if self.apply_armed {
            "Apply is armed. Click 'Apply to Files' to write staged edits.".to_string()
        } else {
            "Apply disarmed.".to_string()
        };
    }

    pub fn apply_staged_edits(&mut self) -> Result<()> {
        if self.staged_edits.is_empty() {
            self.apply_armed = false;
            self.export_status = "No staged edits to apply.".to_string();
            return Ok(());
        }

        if !self.apply_armed {
            self.export_status = "Apply is disarmed. Arm apply before writing files.".to_string();
            return Ok(());
        }

        let report = match self.staged_edits.apply_to_disk(&self.root) {
            Ok(report) => report,
            Err(error) => {
                self.apply_armed = false;
                self.refresh_recent_audits_silent();
                self.export_status = format!("Apply failed: {error}");
                return Err(error);
            }
        };

        self.staged_edits.clear();
        self.apply_armed = false;
        self.refresh_patch_preview();
        self.refresh_recent_audits_silent();

        if let Err(error) = self.reload_snapshot_from_disk() {
            self.export_status = format!(
                "Applied {} staged edits (audit: {}), but failed to reload workflow state: {error}",
                report.applied_files,
                report.audit_path.display()
            );
            return Err(error);
        }

        self.export_status = format!(
            "Applied {} staged edits ({} attempted, rollback {}). Audit: {}",
            report.applied_files,
            report.attempted_files,
            report.rolled_back_files,
            report.audit_path.display()
        );
        Ok(())
    }

    pub fn status_line(&self) -> String {
        let selected = self
            .selected_workflow_id
            .as_deref()
            .map_or("none", |value| value);
        format!(
            "Loaded {} workflows; {} edges; {} validation issues; staged={}; apply_armed={}; selected={}; zoom={}%.",
            self.snapshot.workflows.len(),
            self.edges.len(),
            self.issues.len(),
            self.staged_edits.len(),
            self.apply_armed,
            selected,
            self.zoom_percent(),
        )
    }

    fn selected_workflow(&self) -> Option<&WorkflowSummary> {
        let selected = self.selected_workflow_id.as_deref()?;
        self.snapshot
            .workflows
            .iter()
            .find(|workflow| workflow.id == selected)
    }

    fn issue_count_for_workflow(&self, workflow_id: &str) -> usize {
        self.issues
            .iter()
            .filter(|issue| issue.workflow_id.as_deref() == Some(workflow_id))
            .count()
    }

    fn refresh_patch_preview(&mut self) {
        self.patch_preview = self.staged_edits.render_unified_patch(&self.root);
    }

    fn refresh_recent_audits_silent(&mut self) {
        let preferred = self.current_selected_audit_path();
        if let Ok(audits) = list_recent_apply_audits(&self.root, 10) {
            self.recent_audits = audits;
            self.sync_selected_audit_after_reload(preferred.as_deref());
        }
    }

    fn current_selected_audit_path(&self) -> Option<PathBuf> {
        self.selected_audit_index
            .and_then(|index| self.recent_audits.get(index))
            .map(|audit| audit.path.clone())
    }

    fn filtered_audit_indices(&self) -> Vec<usize> {
        let query = self.audit_filter_query.trim().to_lowercase();
        self.recent_audits
            .iter()
            .enumerate()
            .filter(|(_, audit)| {
                let status_ok = match self.audit_status_filter {
                    AuditStatusFilter::All => true,
                    AuditStatusFilter::AppliedOnly => audit.status == "applied",
                    AuditStatusFilter::FailedOnly => audit.status != "applied",
                };
                if !status_ok {
                    return false;
                }

                if query.is_empty() {
                    return true;
                }

                let haystack = format!(
                    "{} {} {}",
                    audit.path.display(),
                    audit.status,
                    audit.summary
                )
                .to_lowercase();
                haystack.contains(&query)
            })
            .map(|(index, _)| index)
            .collect()
    }

    fn sync_selected_audit_after_reload(&mut self, preferred_path: Option<&Path>) {
        let filtered = self.filtered_audit_indices();
        if filtered.is_empty() {
            self.selected_audit_index = None;
            self.selected_audit_path = "No audit selected".to_string();
            self.selected_audit_preview = "# No apply audits match current filters.\n".to_string();
            return;
        }

        let selected = preferred_path
            .and_then(|path| {
                filtered.iter().copied().find(|index| {
                    self.recent_audits
                        .get(*index)
                        .is_some_and(|audit| audit.path == path)
                })
            })
            .or_else(|| {
                self.selected_audit_index
                    .filter(|index| filtered.contains(index))
            })
            .unwrap_or(filtered[0]);

        self.selected_audit_index = Some(selected);
        self.refresh_selected_audit_preview();
    }

    fn refresh_selected_audit_preview(&mut self) {
        let Some(index) = self.selected_audit_index else {
            self.selected_audit_path = "No audit selected".to_string();
            self.selected_audit_preview = "# No apply audit selected.\n".to_string();
            return;
        };
        let Some(audit) = self.recent_audits.get(index) else {
            self.selected_audit_index = None;
            self.selected_audit_path = "No audit selected".to_string();
            self.selected_audit_preview = "# No apply audit selected.\n".to_string();
            return;
        };

        self.selected_audit_path = audit.path.display().to_string();
        self.selected_audit_preview = match fs::read_to_string(&audit.path) {
            Ok(markdown) => markdown,
            Err(error) => format!(
                "# Failed to read audit\n\npath: {}\nerror: {error}",
                audit.path.display()
            ),
        };
    }

    fn reload_snapshot_from_disk(&mut self) -> Result<()> {
        let snapshot = load_workflow_index(&self.root)?;
        let issues = validate_snapshot(&snapshot);
        let (base_layout, edges) = build_graph_layout(&snapshot);

        let selected = self.selected_workflow_id.clone();
        let selected_workflow_id = selected
            .filter(|workflow_id| snapshot.workflows.iter().any(|w| &w.id == workflow_id))
            .or_else(|| {
                snapshot
                    .workflows
                    .first()
                    .map(|workflow| workflow.id.clone())
            });

        self.snapshot = snapshot;
        self.issues = issues;
        self.base_layout = base_layout;
        self.edges = edges;
        self.selected_workflow_id = selected_workflow_id;
        Ok(())
    }
}

fn build_graph_layout(snapshot: &WorkflowIndexSnapshot) -> (Vec<PositionedNode>, Vec<Edge>) {
    let nodes: Vec<Node> = snapshot
        .workflows
        .iter()
        .map(|workflow| Node {
            id: workflow.id.clone(),
        })
        .collect();

    let mut edges = Vec::new();
    for workflow in &snapshot.workflows {
        for dependency in &workflow.dependencies {
            edges.push(Edge {
                from: dependency.clone(),
                to: workflow.id.clone(),
            });
        }
    }

    let base_layout = layered_layout(&nodes, &edges);
    (base_layout, edges)
}

fn workflow_file_template(workflow_id: &str) -> String {
    format!(
        "---\nname: {workflow_id}\ndescription: TODO: describe what this workflow does and when to use it.\nsteps: []\n---\n\n# {workflow_id}\n\nAdd workflow overview and numbered step files.\n"
    )
}

fn step_file_template(step_id: &str, description: Option<&str>) -> String {
    let desc = description
        .map(str::trim)
        .filter(|value| !value.is_empty())
        .map(ToOwned::to_owned)
        .unwrap_or_else(|| format!("TODO: describe {step_id} step behavior."));

    format!(
        "---\nname: {step_id}\ndescription: {desc}\n---\n\n# Step: {step_id}\n\n## Purpose\n- {desc}\n\n## Actions\n1. TODO: implement this step.\n\n## Idempotency\n- Check: verify whether outputs already exist.\n- If Already Complete: skip execution and continue.\n- Marker: checkpoints/<workflow-id>/{step_id}.complete\n"
    )
}

fn normalize_workflow_markdown(workflow_id: &str, markdown: &str) -> String {
    let Some((frontmatter_yaml, body)) = split_frontmatter(markdown) else {
        return format!(
            "---\nname: {workflow_id}\ndescription: TODO: describe what this workflow does and when to use it.\nsteps: []\n---\n\n{}",
            markdown.trim_start_matches('\n')
        );
    };

    let Ok(mut parsed) = serde_yaml::from_str::<Value>(&frontmatter_yaml) else {
        return markdown.to_string();
    };
    let Some(mapping) = parsed.as_mapping_mut() else {
        return markdown.to_string();
    };

    ensure_frontmatter_description(mapping, workflow_id);
    ensure_step_descriptions(mapping);

    let Ok(mut serialized) = serde_yaml::to_string(&parsed) else {
        return markdown.to_string();
    };
    if let Some(stripped) = serialized.strip_prefix("---\n") {
        serialized = stripped.to_string();
    }
    let serialized = serialized.trim_end_matches('\n');
    let body = body.trim_start_matches('\n');

    if body.is_empty() {
        format!("---\n{serialized}\n---\n")
    } else {
        format!("---\n{serialized}\n---\n\n{body}")
    }
}

fn split_frontmatter(markdown: &str) -> Option<(String, String)> {
    let mut lines = markdown.lines();
    if lines.next()?.trim() != "---" {
        return None;
    }

    let mut yaml_lines = Vec::new();
    let mut body_start = None;
    let source_lines: Vec<&str> = markdown.lines().collect();
    for (index, line) in source_lines.iter().enumerate().skip(1) {
        if line.trim() == "---" {
            body_start = Some(index + 1);
            break;
        }
        yaml_lines.push(*line);
    }

    let body_start = body_start?;
    let body = source_lines[body_start..].join("\n");
    Some((yaml_lines.join("\n"), body))
}

fn ensure_frontmatter_description(mapping: &mut Mapping, workflow_id: &str) {
    let key = Value::String("description".to_string());
    let current = mapping.get(&key).and_then(Value::as_str).map(str::trim);
    if current.is_none_or(|value| value.is_empty()) {
        mapping.insert(
            key,
            Value::String(format!(
                "TODO: describe workflow '{workflow_id}' and when to use it."
            )),
        );
    }
}

fn ensure_step_descriptions(mapping: &mut Mapping) {
    let steps_key = Value::String("steps".to_string());
    let Some(steps) = mapping.get_mut(&steps_key).and_then(Value::as_sequence_mut) else {
        return;
    };

    let id_key = Value::String("id".to_string());
    let desc_key = Value::String("description".to_string());

    for step in steps {
        let Some(step_mapping) = step.as_mapping_mut() else {
            continue;
        };

        let step_id = step_mapping
            .get(&id_key)
            .and_then(Value::as_str)
            .unwrap_or("step");
        let current = step_mapping
            .get(&desc_key)
            .and_then(Value::as_str)
            .map(str::trim);
        if current.is_none_or(|value| value.is_empty()) {
            step_mapping.insert(
                desc_key.clone(),
                Value::String(format!("TODO: describe {step_id} step behavior.")),
            );
        }
    }
}

fn copy_text_to_clipboard(text: &str) -> Result<()> {
    #[cfg(target_os = "macos")]
    {
        return copy_text_with_stdin(ProcessCommand::new("pbcopy"), text);
    }

    #[cfg(target_os = "linux")]
    {
        let wl_copy = copy_text_with_stdin(ProcessCommand::new("wl-copy"), text);
        if wl_copy.is_ok() {
            return Ok(());
        }

        let xclip = copy_text_with_stdin(
            {
                let mut cmd = ProcessCommand::new("xclip");
                cmd.arg("-selection").arg("clipboard");
                cmd
            },
            text,
        );
        if xclip.is_ok() {
            return Ok(());
        }

        let xsel = copy_text_with_stdin(
            {
                let mut cmd = ProcessCommand::new("xsel");
                cmd.arg("--clipboard").arg("--input");
                cmd
            },
            text,
        );
        if xsel.is_ok() {
            return Ok(());
        }

        return Err(anyhow!(
            "failed to copy via wl-copy/xclip/xsel; install one clipboard utility"
        ));
    }

    #[cfg(target_os = "windows")]
    {
        return copy_text_with_stdin(
            {
                let mut cmd = ProcessCommand::new("powershell");
                cmd.arg("-NoProfile").arg("-Command").arg("Set-Clipboard");
                cmd
            },
            text,
        );
    }

    #[cfg(not(any(target_os = "macos", target_os = "linux", target_os = "windows")))]
    {
        let _ = text;
        Err(anyhow!("clipboard copy is unsupported on this OS"))
    }
}

fn copy_text_with_stdin(mut command: ProcessCommand, text: &str) -> Result<()> {
    let mut child = command.stdin(Stdio::piped()).spawn()?;
    if let Some(mut stdin) = child.stdin.take() {
        stdin.write_all(text.as_bytes())?;
    }
    let status = child.wait()?;
    if status.success() {
        Ok(())
    } else {
        Err(anyhow!("clipboard command exited with status {}", status))
    }
}

fn reveal_path_in_system(path: &Path) -> Result<()> {
    #[cfg(target_os = "macos")]
    {
        let status = ProcessCommand::new("open").arg("-R").arg(path).status()?;
        if status.success() {
            return Ok(());
        }
        return Err(anyhow!("'open -R' exited with status {}", status));
    }

    #[cfg(target_os = "linux")]
    {
        let target = path.parent().unwrap_or(path);
        let status = ProcessCommand::new("xdg-open").arg(target).status()?;
        if status.success() {
            return Ok(());
        }
        return Err(anyhow!("'xdg-open' exited with status {}", status));
    }

    #[cfg(target_os = "windows")]
    {
        let arg = format!("/select,{}", path.display());
        let status = ProcessCommand::new("explorer").arg(arg).status()?;
        if status.success() {
            return Ok(());
        }
        return Err(anyhow!("'explorer /select' exited with status {}", status));
    }

    #[cfg(not(any(target_os = "macos", target_os = "linux", target_os = "windows")))]
    {
        let _ = path;
        Err(anyhow!("opening file locations is unsupported on this OS"))
    }
}

#[cfg(test)]
mod tests {
    use super::AppState;
    use std::fs;
    use std::path::{Path, PathBuf};
    use std::time::{SystemTime, UNIX_EPOCH};

    struct TempHarness {
        root: PathBuf,
    }

    impl TempHarness {
        fn new(label: &str) -> Self {
            let stamp = SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .expect("system clock should be valid")
                .as_nanos();
            let pid = std::process::id();
            let root = std::env::temp_dir().join(format!("harmony-studio-{label}-{pid}-{stamp}"));
            fs::create_dir_all(&root).expect("temp root should be created");
            write_fixture_harness(&root);
            Self { root }
        }

        fn root_path(&self) -> PathBuf {
            self.root.clone()
        }
    }

    impl Drop for TempHarness {
        fn drop(&mut self) {
            let _ = fs::remove_dir_all(&self.root);
        }
    }

    #[test]
    fn app_state_loads_workflow_inspector_and_graph_models() {
        let harness = TempHarness::new("inspector-graph");
        let mut state = AppState::load(harness.root_path()).expect("app state should load");

        assert_eq!(
            state.workflow_count(),
            2,
            "fixture should define two workflows"
        );
        assert_eq!(
            state.edge_count(),
            1,
            "registry dependency should create one edge"
        );
        assert_eq!(state.selected_title(), "Alpha Flow (alpha)");
        assert_eq!(state.selected_issue_count(), 0);
        assert_eq!(state.selected_steps().len(), 1);
        assert_eq!(state.selected_steps()[0].status, "ok");

        state.select_workflow("beta");
        assert_eq!(state.selected_title(), "Beta Flow (beta)");
        assert_eq!(
            state.selected_dependency_summary(),
            "Dependencies: alpha",
            "beta should show alpha dependency"
        );
        assert_eq!(
            state.selected_issue_count(),
            1,
            "beta should surface missing-step-file validation"
        );
        assert_eq!(state.selected_steps().len(), 1);
        assert_eq!(state.selected_steps()[0].status, "missing");

        let graph_nodes = state.graph_node_items();
        assert_eq!(graph_nodes.len(), 2);
        assert!(
            graph_nodes
                .iter()
                .any(|node| node.id == "beta" && node.selected),
            "selected workflow should be reflected in graph model"
        );
    }

    #[test]
    fn graph_pan_zoom_reset_updates_positions() {
        let harness = TempHarness::new("graph-pan-zoom");
        let mut state = AppState::load(harness.root_path()).expect("app state should load");

        let baseline_nodes = state.graph_node_items();
        let baseline_alpha = baseline_nodes
            .iter()
            .find(|node| node.id == "alpha")
            .expect("alpha node should exist");

        state.pan_by(120.0, -80.0);
        state.zoom_by(1.5);

        let moved_alpha = state
            .graph_node_items()
            .into_iter()
            .find(|node| node.id == "alpha")
            .expect("alpha node should exist after pan/zoom");
        assert!(
            (moved_alpha.x - baseline_alpha.x).abs() > 0.01
                || (moved_alpha.y - baseline_alpha.y).abs() > 0.01,
            "pan/zoom should move rendered graph coordinates"
        );

        state.zoom_by(100.0);
        assert_eq!(state.zoom_percent(), 240, "zoom should clamp to max");
        state.zoom_by(0.0001);
        assert_eq!(state.zoom_percent(), 55, "zoom should clamp to min");

        state.reset_view();
        assert_eq!(state.zoom_percent(), 100);
        let reset_alpha = state
            .graph_node_items()
            .into_iter()
            .find(|node| node.id == "alpha")
            .expect("alpha node should exist after reset");
        assert!((reset_alpha.x - baseline_alpha.x).abs() < 0.01);
        assert!((reset_alpha.y - baseline_alpha.y).abs() < 0.01);
    }

    #[test]
    fn audit_filter_and_selection_updates_preview() {
        let harness = TempHarness::new("audit-filters");
        write_fixture_audits(harness.root.as_path());

        let mut state = AppState::load(harness.root_path()).expect("app state should load");
        assert_eq!(state.audit_count(), 2);
        assert!(
            state.selected_audit_path_text().contains("1002-"),
            "newest audit should be selected by default"
        );

        state.set_audit_status_filter(1);
        assert_eq!(state.audit_count(), 1);
        assert!(
            state.selected_audit_path_text().contains("1001-"),
            "applied filter should keep only applied audit"
        );

        state.set_audit_status_filter(2);
        assert_eq!(state.audit_count(), 1);
        assert!(
            state.selected_audit_path_text().contains("1002-"),
            "failed filter should keep only failed audit"
        );

        state.set_audit_status_filter(0);
        state.set_audit_filter_query("rolled back");
        assert_eq!(state.audit_count(), 1);
        assert!(
            state
                .selected_audit_preview_text()
                .contains("failed-rolled-back"),
            "preview should show selected failed audit markdown"
        );
        state.select_audit(0);
        assert_eq!(state.audit_items().len(), 1);
        assert!(state.audit_items()[0].selected);
    }

    #[test]
    fn staged_buffer_flow_requires_arm_and_supports_clear() {
        let harness = TempHarness::new("staged-flow");
        let mut state = AppState::load(harness.root_path()).expect("app state should load");

        state.select_workflow("beta");
        state
            .stage_selected_safe_edits()
            .expect("staging should succeed");
        assert!(
            state.staged_edit_count() >= 1,
            "staging should buffer at least one safe edit"
        );
        assert!(
            state.patch_preview_text().contains("diff --git"),
            "patch preview should include staged diff output"
        );
        assert!(!state.apply_armed(), "staging should disarm apply");

        state.toggle_apply_arm();
        assert!(state.apply_armed(), "toggle should arm apply");

        state.clear_staged_edits();
        assert_eq!(state.staged_edit_count(), 0);
        assert!(!state.apply_armed());
        assert_eq!(state.patch_preview_text(), "# No staged edits.\n");
    }

    fn write_fixture_harness(root: &Path) {
        write_file(
            &root.join(".harmony/orchestration/runtime/workflows/manifest.yml"),
            "workflows:\n  - id: alpha\n    path: alpha\n  - id: beta\n    path: beta\n",
        );
        write_file(
            &root.join(".harmony/orchestration/runtime/workflows/registry.yml"),
            "workflows:\n  alpha:\n    path: alpha\n  beta:\n    path: beta\n    depends_on:\n      - workflow: alpha\n",
        );
        write_file(
            &root.join(".harmony/orchestration/runtime/workflows/alpha/WORKFLOW.md"),
            "---\nname: Alpha Flow\ndescription: Alpha workflow for fixture tests.\nsteps:\n  - id: alpha-step\n    file: 01-alpha.md\n    description: Alpha step.\n---\n\n# Alpha\n",
        );
        write_file(
            &root.join(".harmony/orchestration/runtime/workflows/alpha/01-alpha.md"),
            "---\nname: alpha-step\ndescription: Alpha step.\n---\n",
        );
        write_file(
            &root.join(".harmony/orchestration/runtime/workflows/beta/WORKFLOW.md"),
            "---\nname: Beta Flow\ndescription: Beta workflow with a missing step file.\nsteps:\n  - id: beta-step\n    file: 01-beta.md\n    description: Beta missing step.\n---\n\n# Beta\n",
        );
    }

    fn write_fixture_audits(root: &Path) {
        write_file(
            &root.join(".harmony/output/reports/1001-1-studio-apply-audit.md"),
            "# Harmony Studio Apply Audit\n\n- timestamp_unix_ms: 1001\n- status: applied\n- attempted_files: 1\n- applied_files: 1\n- rolled_back_files: 0\n- summary: Applied 1 staged edits.\n\n## Staged Edits\n- update | .harmony/orchestration/runtime/workflows/alpha/WORKFLOW.md | Normalize WORKFLOW.md frontmatter defaults\n",
        );
        write_file(
            &root.join(".harmony/output/reports/1002-1-studio-apply-audit.md"),
            "# Harmony Studio Apply Audit\n\n- timestamp_unix_ms: 1002\n- status: failed-rolled-back\n- attempted_files: 2\n- applied_files: 1\n- rolled_back_files: 1\n- summary: Apply failed and rolled back 1 file(s): synthetic write error\n\n## Staged Edits\n- create | .harmony/orchestration/runtime/workflows/beta/01-beta.md | Create missing step file\n",
        );
    }

    fn write_file(path: &Path, contents: &str) {
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).expect("parent directory should be created");
        }
        fs::write(path, contents).expect("fixture file should be written");
    }
}
