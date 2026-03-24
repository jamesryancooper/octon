use crate::graph::layout::{layered_layout, Edge, Node, PositionedNode};
use crate::staging::{list_recent_apply_audits, ApplyAuditSummary, StagedEditBuffer};
use crate::workflows::{
    load_workflow_index, validate_snapshot, ValidationIssue, WorkflowIndexSnapshot, WorkflowSummary,
};
use anyhow::{anyhow, Result};
use octon_core::orchestration::{LookupQuery, OpsSnapshot, OrchestrationInspector};
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

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum OpsSection {
    Overview,
    Lookup,
    Runs,
    Incidents,
    Queue,
    Watchers,
    Automations,
    Missions,
    Playbooks,
}

impl OpsSection {
    fn from_mode(mode: i32) -> Self {
        match mode {
            1 => Self::Lookup,
            2 => Self::Runs,
            3 => Self::Incidents,
            4 => Self::Queue,
            5 => Self::Watchers,
            6 => Self::Automations,
            7 => Self::Missions,
            8 => Self::Playbooks,
            _ => Self::Overview,
        }
    }

    fn mode(self) -> i32 {
        match self {
            Self::Overview => 0,
            Self::Lookup => 1,
            Self::Runs => 2,
            Self::Incidents => 3,
            Self::Queue => 4,
            Self::Watchers => 5,
            Self::Automations => 6,
            Self::Missions => 7,
            Self::Playbooks => 8,
        }
    }

    fn title(self) -> &'static str {
        match self {
            Self::Overview => "Overview",
            Self::Lookup => "Lookup",
            Self::Runs => "Runs",
            Self::Incidents => "Incidents",
            Self::Queue => "Queue",
            Self::Watchers => "Watchers",
            Self::Automations => "Automations",
            Self::Missions => "Missions",
            Self::Playbooks => "Playbooks",
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum OpsLookupMode {
    DecisionId,
    RunId,
    IncidentId,
    QueueItemId,
    EventId,
    AutomationId,
    WatcherId,
    MissionId,
}

impl OpsLookupMode {
    fn from_mode(mode: i32) -> Self {
        match mode {
            1 => Self::RunId,
            2 => Self::IncidentId,
            3 => Self::QueueItemId,
            4 => Self::EventId,
            5 => Self::AutomationId,
            6 => Self::WatcherId,
            7 => Self::MissionId,
            _ => Self::DecisionId,
        }
    }

    fn mode(self) -> i32 {
        match self {
            Self::DecisionId => 0,
            Self::RunId => 1,
            Self::IncidentId => 2,
            Self::QueueItemId => 3,
            Self::EventId => 4,
            Self::AutomationId => 5,
            Self::WatcherId => 6,
            Self::MissionId => 7,
        }
    }

    fn label(self) -> &'static str {
        match self {
            Self::DecisionId => "Decision",
            Self::RunId => "Run",
            Self::IncidentId => "Incident",
            Self::QueueItemId => "Queue",
            Self::EventId => "Event",
            Self::AutomationId => "Automation",
            Self::WatcherId => "Watcher",
            Self::MissionId => "Mission",
        }
    }

    fn into_query(self, query: &str) -> LookupQuery {
        match self {
            Self::DecisionId => LookupQuery::DecisionId(query.to_string()),
            Self::RunId => LookupQuery::RunId(query.to_string()),
            Self::IncidentId => LookupQuery::IncidentId(query.to_string()),
            Self::QueueItemId => LookupQuery::QueueItemId(query.to_string()),
            Self::EventId => LookupQuery::EventId(query.to_string()),
            Self::AutomationId => LookupQuery::AutomationId(query.to_string()),
            Self::WatcherId => LookupQuery::WatcherId(query.to_string()),
            Self::MissionId => LookupQuery::MissionId(query.to_string()),
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
    ops_snapshot: OpsSnapshot,
    ops_status: String,
    ops_section: OpsSection,
    ops_lookup_mode: OpsLookupMode,
    ops_lookup_query: String,
    ops_lookup_result: String,
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
        let (ops_snapshot, ops_status) = match load_ops_snapshot(&root) {
            Ok(snapshot) => {
                let status = format!(
                    "Loaded ops snapshot: watchers={} queue_pending={} runs={} incidents={}.",
                    snapshot.watchers.len(),
                    snapshot.queue.pending_count,
                    snapshot.runs.len(),
                    snapshot.incidents.len()
                );
                (snapshot, status)
            }
            Err(error) => (empty_ops_snapshot(), format!("Operations snapshot unavailable: {error}")),
        };

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
            ops_snapshot,
            ops_status,
            ops_section: OpsSection::Overview,
            ops_lookup_mode: OpsLookupMode::DecisionId,
            ops_lookup_query: String::new(),
            ops_lookup_result: "# Enter a canonical id and run a lookup.\n".to_string(),
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

    pub fn ops_status_text(&self) -> String {
        self.ops_status.clone()
    }

    pub fn ops_section_mode(&self) -> i32 {
        self.ops_section.mode()
    }

    pub fn ops_section_title_text(&self) -> String {
        self.ops_section.title().to_string()
    }

    pub fn ops_lookup_mode(&self) -> i32 {
        self.ops_lookup_mode.mode()
    }

    pub fn ops_lookup_query_text(&self) -> String {
        self.ops_lookup_query.clone()
    }

    pub fn ops_lookup_result_text(&self) -> String {
        self.ops_lookup_result.clone()
    }

    pub fn ops_section_body_text(&self) -> String {
        match self.ops_section {
            OpsSection::Overview => render_ops_overview(&self.ops_snapshot),
            OpsSection::Lookup => format!(
                "# Lookup\n\n- mode: {}\n- query: {}\n\n{}",
                self.ops_lookup_mode.label(),
                if self.ops_lookup_query.is_empty() {
                    "<empty>"
                } else {
                    self.ops_lookup_query.as_str()
                },
                self.ops_lookup_result
            ),
            OpsSection::Runs => render_ops_runs(&self.ops_snapshot),
            OpsSection::Incidents => render_ops_incidents(&self.ops_snapshot),
            OpsSection::Queue => render_ops_queue(&self.ops_snapshot),
            OpsSection::Watchers => render_ops_watchers(&self.ops_snapshot),
            OpsSection::Automations => render_ops_automations(&self.ops_snapshot),
            OpsSection::Missions => render_ops_missions(&self.ops_snapshot),
            OpsSection::Playbooks => render_ops_playbooks(&self.root),
        }
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
                        if name != &workflow.id {
                            return format!("{name} ({})", workflow.id);
                        }
                        return workflow.id.clone();
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
            return "Workflow contract did not provide a description.".to_string();
        }
        "Select a workflow from the left list or graph canvas.".to_string()
    }

    pub fn selected_path(&self) -> String {
        if let Some(workflow) = self.selected_workflow() {
            let mut segments = vec![
                format!("workflow contract: {}", workflow.contract_file.display()),
                format!("generated README: {}", workflow.workflow_file.display()),
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
        let mut readme_status_note: Option<String> = None;

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
                "Normalize README.md frontmatter defaults".to_string(),
            );
            touched_targets += 1;
        } else {
            readme_status_note = Some(format!(
                "README.md is missing for '{}'; regenerate it from workflow.yml with generate-workflow-guides.sh.",
                workflow.id
            ));
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
            self.export_status = format!(
                "No staged edits were needed for '{}'.{}",
                workflow.id,
                readme_status_note
                    .as_deref()
                    .map(|note| format!(" {note}"))
                    .unwrap_or_default()
            );
        } else {
            self.export_status = format!(
                "Staged {} new edits ({} total) across {} targets for '{}'.{}",
                newly_staged,
                total_staged,
                touched_targets,
                workflow.id,
                readme_status_note
                    .as_deref()
                    .map(|note| format!(" {note}"))
                    .unwrap_or_default()
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

    pub fn refresh_ops(&mut self) {
        match load_ops_snapshot(&self.root) {
            Ok(snapshot) => {
                self.ops_snapshot = snapshot;
                self.ops_status = format!(
                    "Reloaded ops snapshot: watchers={} queue_pending={} runs={} incidents={}.",
                    self.ops_snapshot.watchers.len(),
                    self.ops_snapshot.queue.pending_count,
                    self.ops_snapshot.runs.len(),
                    self.ops_snapshot.incidents.len()
                );
            }
            Err(error) => {
                self.ops_status = format!("Failed to reload ops snapshot: {error}");
            }
        }
    }

    pub fn set_ops_section(&mut self, mode: i32) {
        self.ops_section = OpsSection::from_mode(mode);
        self.ops_status = format!("Operations section: {}", self.ops_section.title());
    }

    pub fn set_ops_lookup_mode(&mut self, mode: i32) {
        self.ops_lookup_mode = OpsLookupMode::from_mode(mode);
        self.ops_status = format!("Lookup mode: {}", self.ops_lookup_mode.label());
    }

    pub fn set_ops_lookup_query(&mut self, query: &str) {
        self.ops_lookup_query = query.to_string();
    }

    pub fn run_ops_lookup(&mut self) {
        let query = self.ops_lookup_query.trim();
        if query.is_empty() {
            self.ops_lookup_result = "# Lookup\n\n- missing query\n".to_string();
            self.ops_status = "Lookup query is empty.".to_string();
            return;
        }

        let inspector = match OrchestrationInspector::from_repo_root(&self.root) {
            Ok(inspector) => inspector,
            Err(error) => {
                self.ops_lookup_result =
                    format!("# Lookup Failed\n\nerror: {error}");
                self.ops_status = format!("Lookup failed: {error}");
                return;
            }
        };

        match inspector.lookup(self.ops_lookup_mode.into_query(query)) {
            Ok(result) => {
                self.ops_lookup_result = render_lookup_result(&result);
                self.ops_status = format!(
                    "Lookup completed for {} `{}`.",
                    self.ops_lookup_mode.label(),
                    query
                );
            }
            Err(error) => {
                self.ops_lookup_result = format!("# Lookup Failed\n\nerror: {error}");
                self.ops_status = format!("Lookup failed: {error}");
            }
        }
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
        if let Ok(snapshot) = load_ops_snapshot(&self.root) {
            self.ops_snapshot = snapshot;
        }
        Ok(())
    }
}

fn load_ops_snapshot(root: &Path) -> Result<OpsSnapshot> {
    Ok(OrchestrationInspector::from_repo_root(root)?.snapshot()?)
}

fn empty_ops_snapshot() -> OpsSnapshot {
    OpsSnapshot {
        generated_at: "unavailable".to_string(),
        overview: Default::default(),
        watchers: Vec::new(),
        queue: octon_core::orchestration::QueueSummary {
            pending_count: 0,
            claimed_count: 0,
            retry_count: 0,
            dead_letter_count: 0,
            expired_claim_count: 0,
            oldest_pending_queue_item_id: None,
            oldest_pending_age_seconds: None,
            last_receipt_at: None,
        },
        automations: Vec::new(),
        runs: Vec::new(),
        missions: Vec::new(),
        incidents: Vec::new(),
    }
}

fn render_ops_overview(snapshot: &OpsSnapshot) -> String {
    format!(
        "# Overview\n\n- generated_at: `{}`\n- watchers: {} ({} unhealthy)\n- automations: {} ({} attention)\n- runs: {} ({} running)\n- incidents: {} ({} open, {} closure blocked)\n- queue: pending={} claimed={} retry={} dead_letter={} expired_claims={}\n",
        snapshot.generated_at,
        snapshot.overview.watcher_count,
        snapshot.overview.watcher_unhealthy_count,
        snapshot.overview.automation_count,
        snapshot.overview.automation_attention_count,
        snapshot.overview.run_count,
        snapshot.overview.running_run_count,
        snapshot.overview.incident_count,
        snapshot.overview.open_incident_count,
        snapshot.overview.incident_closure_blocked_count,
        snapshot.overview.queue_pending_count,
        snapshot.overview.queue_claimed_count,
        snapshot.overview.queue_retry_count,
        snapshot.overview.queue_dead_letter_count,
        snapshot.overview.queue_expired_claim_count,
    )
}

fn render_ops_runs(snapshot: &OpsSnapshot) -> String {
    if snapshot.runs.is_empty() {
        return "# Runs\n\n- none\n".to_string();
    }
    let mut body = String::from("# Runs\n\n");
    for run in &snapshot.runs {
        body.push_str(&format!(
            "- `{}` status=`{}` recovery=`{}` decision=`{}` evidence=`{}`\n",
            run.run_id,
            run.status,
            run.recovery_status.clone().unwrap_or_else(|| "-".to_string()),
            run.decision_link_health,
            run.evidence_link_health
        ));
    }
    body
}

fn render_ops_incidents(snapshot: &OpsSnapshot) -> String {
    if snapshot.incidents.is_empty() {
        return "# Incidents\n\n- none\n".to_string();
    }
    let mut body = String::from("# Incidents\n\n");
    for incident in &snapshot.incidents {
        body.push_str(&format!(
            "- `{}` severity=`{}` status=`{}` owner=`{}` closure_ready=`{}` linked_runs={}\n",
            incident.incident_id,
            incident.severity,
            incident.status,
            incident.owner,
            incident.closure_ready,
            if incident.linked_run_ids.is_empty() {
                "none".to_string()
            } else {
                incident.linked_run_ids.join(", ")
            }
        ));
        if !incident.closure_blockers.is_empty() {
            body.push_str(&format!(
                "  blockers: {}\n",
                incident.closure_blockers.join("; ")
            ));
        }
    }
    body
}

fn render_ops_queue(snapshot: &OpsSnapshot) -> String {
    format!(
        "# Queue\n\n- pending: {}\n- claimed: {}\n- retry: {}\n- dead_letter: {}\n- expired_claims: {}\n- oldest_pending_queue_item_id: {}\n- oldest_pending_age_seconds: {}\n- last_receipt_at: {}\n",
        snapshot.queue.pending_count,
        snapshot.queue.claimed_count,
        snapshot.queue.retry_count,
        snapshot.queue.dead_letter_count,
        snapshot.queue.expired_claim_count,
        snapshot
            .queue
            .oldest_pending_queue_item_id
            .clone()
            .unwrap_or_else(|| "none".to_string()),
        snapshot
            .queue
            .oldest_pending_age_seconds
            .map(|value| value.to_string())
            .unwrap_or_else(|| "none".to_string()),
        snapshot
            .queue
            .last_receipt_at
            .clone()
            .unwrap_or_else(|| "none".to_string()),
    )
}

fn render_ops_watchers(snapshot: &OpsSnapshot) -> String {
    if snapshot.watchers.is_empty() {
        return "# Watchers\n\n- none\n".to_string();
    }
    let mut body = String::from("# Watchers\n\n");
    for watcher in &snapshot.watchers {
        body.push_str(&format!(
            "- `{}` status=`{}` health=`{}` last_eval=`{}` last_event=`{}` suppressed={}\n",
            watcher.watcher_id,
            watcher.status,
            watcher.health_status,
            watcher
                .last_evaluated_at
                .clone()
                .unwrap_or_else(|| "none".to_string()),
            watcher
                .last_emitted_event_id
                .clone()
                .unwrap_or_else(|| "none".to_string()),
            watcher.suppressed_count
        ));
    }
    body
}

fn render_ops_automations(snapshot: &OpsSnapshot) -> String {
    if snapshot.automations.is_empty() {
        return "# Automations\n\n- none\n".to_string();
    }
    let mut body = String::from("# Automations\n\n");
    for automation in &snapshot.automations {
        body.push_str(&format!(
            "- `{}` status=`{}` workflow=`{}` last_attempt=`{}` last_success=`{}` failures={} suppressed={}\n",
            automation.automation_id,
            automation.status,
            automation
                .workflow_ref
                .clone()
                .unwrap_or_else(|| "none".to_string()),
            automation
                .last_launch_attempt_at
                .clone()
                .unwrap_or_else(|| "none".to_string()),
            automation
                .last_successful_run_id
                .clone()
                .unwrap_or_else(|| "none".to_string()),
            automation.failure_count,
            automation.suppression_count
        ));
        if let Some(reason) = &automation.pause_or_error_reason {
            body.push_str(&format!("  attention: {}\n", reason));
        }
    }
    body
}

fn render_ops_missions(snapshot: &OpsSnapshot) -> String {
    if snapshot.missions.is_empty() {
        return "# Missions\n\n- none\n".to_string();
    }
    let mut body = String::from("# Missions\n\n");
    for mission in &snapshot.missions {
        body.push_str(&format!(
            "- `{}` status=`{}` owner=`{}` active_runs={} blocked_tasks={} outstanding_tasks={}\n",
            mission.mission_id,
            mission.status,
            mission.owner,
            if mission.active_run_ids.is_empty() {
                "none".to_string()
            } else {
                mission.active_run_ids.join(", ")
            },
            mission.blocked_task_count,
            mission.outstanding_task_count
        ));
    }
    body
}

fn render_ops_playbooks(root: &Path) -> String {
    let path = root.join(".octon/framework/orchestration/practices/orchestration-failure-playbooks.md");
    fs::read_to_string(&path).unwrap_or_else(|_| {
        "# Playbooks\n\nNo orchestration failure playbooks are available yet.\n".to_string()
    })
}

fn render_lookup_result(result: &octon_core::orchestration::LookupResult) -> String {
    let mut body = String::new();
    body.push_str("# Lookup Result\n\n");
    body.push_str(&format!(
        "- query_kind: `{}`\n- query_id: `{}`\n\n",
        result.query_kind, result.query_id
    ));
    body.push_str("## Artifacts\n\n");
    if result.artifacts.is_empty() {
        body.push_str("- none\n");
    } else {
        for artifact in &result.artifacts {
            body.push_str(&format!(
                "- `{}` `{}` -> `{}`\n",
                artifact.kind, artifact.id, artifact.path
            ));
            if !artifact.details.is_empty() {
                let details = artifact
                    .details
                    .iter()
                    .map(|(key, value)| format!("{key}={value}"))
                    .collect::<Vec<_>>()
                    .join(", ");
                body.push_str(&format!("  details: {}\n", details));
            }
        }
    }
    body.push_str("\n## Relations\n\n");
    if result.relations.is_empty() {
        body.push_str("- none\n");
    } else {
        for relation in &result.relations {
            body.push_str(&format!(
                "- `{}` -> `{}` ({})\n",
                relation.from, relation.to, relation.relation
            ));
        }
    }
    if !result.notes.is_empty() {
        body.push_str("\n## Notes\n\n");
        for note in &result.notes {
            body.push_str(&format!("- {}\n", note));
        }
    }
    body
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
            let root = std::env::temp_dir().join(format!("octon-studio-{label}-{pid}-{stamp}"));
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
        assert_eq!(state.selected_title(), "alpha");
        assert_eq!(state.selected_issue_count(), 0);
        assert_eq!(state.selected_steps().len(), 1);
        assert_eq!(state.selected_steps()[0].status, "ok");

        state.select_workflow("beta");
        assert_eq!(state.selected_title(), "beta");
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

    #[test]
    fn operations_section_switching_and_lookup_render() {
        let harness = TempHarness::new("ops-sections");
        let mut state = AppState::load(harness.root_path()).expect("app state should load");

        assert!(state.ops_section_body_text().contains("# Overview"));
        assert!(state.ops_status_text().contains("ops snapshot"));

        state.set_ops_section(2);
        assert_eq!(state.ops_section_title_text(), "Runs");
        assert!(state.ops_section_body_text().contains("run-001"));

        state.set_ops_lookup_mode(1);
        state.set_ops_lookup_query("run-001");
        state.run_ops_lookup();
        assert!(state.ops_lookup_result_text().contains("dec-001"));
        assert!(state.ops_lookup_result_text().contains("q-001"));
    }

    #[test]
    fn operations_incident_blockers_and_playbooks_render() {
        let harness = TempHarness::new("ops-blockers");
        write_file(
            &harness
                .root
                .join(".octon/framework/orchestration/runtime/incidents/inc-001/incident.yml"),
            "incident_id: \"inc-001\"\ntitle: \"Example Incident\"\nseverity: \"sev2\"\nstatus: \"open\"\nowner: \"@architect\"\nsummary: \"Incident summary\"\n",
        );
        let _ = fs::remove_file(
            harness
                .root
                .join(".octon/framework/orchestration/runtime/incidents/inc-001/closure.md"),
        );
        let mut state = AppState::load(harness.root_path()).expect("app state should load");

        state.set_ops_section(3);
        assert!(state.ops_section_body_text().contains("missing linked runs"));
        assert!(state.ops_section_body_text().contains("missing closure.md"));

        state.set_ops_section(8);
        assert!(state.ops_section_body_text().contains("watcher source unreadable"));
    }

    fn write_fixture_harness(root: &Path) {
        write_file(
            &root.join(".octon/framework/orchestration/runtime/workflows/manifest.yml"),
            "workflows:\n  - id: alpha\n    path: alpha\n  - id: beta\n    path: beta\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/workflows/registry.yml"),
            "workflows:\n  alpha:\n    path: alpha\n  beta:\n    path: beta\n    depends_on:\n      - workflow: alpha\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/workflows/alpha/README.md"),
            "---\nname: Alpha Flow\ndescription: Alpha workflow for fixture tests.\nsteps:\n  - id: alpha-step\n    file: 01-alpha.md\n    description: Alpha step.\n---\n\n# Alpha\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/workflows/alpha/workflow.yml"),
            "schema_version: workflow-contract-v2\nname: alpha\ndescription: Alpha workflow for fixture tests.\nversion: 1.0.0\nentry_mode: human\nexecution_profile: core\nstages:\n  - id: alpha-step\n    asset: stages/01-alpha.md\n    kind: analysis\n    mutation_scope: []\n    authorization:\n      action_type: execute_stage\n      requested_capabilities:\n        - workflow.stage.execute\n        - evidence.write\n      side_effects:\n        write_repo: false\n        write_evidence: true\n        shell: true\n        network: false\n        model_invoke: true\n        state_mutation: false\n        publication: false\n        branch_mutation: false\n      risk_tier: low\n      scope:\n        read:\n          - workflow-scope\n        write:\n          - workflow-evidence\n      review_requirements:\n        human_approval: false\n        quorum: false\n        rollback_metadata: false\n      allowed_executor_profiles:\n        - read_only_analysis\nartifacts: []\ndone_gate:\n  checks:\n    - Alpha complete\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/workflows/alpha/stages/01-alpha.md"),
            "---\nname: alpha-step\ndescription: Alpha step.\n---\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/workflows/beta/README.md"),
            "---\nname: Beta Flow\ndescription: Beta workflow with a missing step file.\nsteps:\n  - id: beta-step\n    file: 01-beta.md\n    description: Beta missing step.\n---\n\n# Beta\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/workflows/beta/workflow.yml"),
            "schema_version: workflow-contract-v2\nname: beta\ndescription: Beta workflow with a missing step file.\nversion: 1.0.0\nentry_mode: human\nexecution_profile: core\nstages:\n  - id: beta-step\n    asset: stages/01-beta.md\n    kind: analysis\n    mutation_scope: []\n    authorization:\n      action_type: execute_stage\n      requested_capabilities:\n        - workflow.stage.execute\n        - evidence.write\n      side_effects:\n        write_repo: false\n        write_evidence: true\n        shell: true\n        network: false\n        model_invoke: true\n        state_mutation: false\n        publication: false\n        branch_mutation: false\n      risk_tier: low\n      scope:\n        read:\n          - workflow-scope\n        write:\n          - workflow-evidence\n      review_requirements:\n        human_approval: false\n        quorum: false\n        rollback_metadata: false\n      allowed_executor_profiles:\n        - read_only_analysis\nartifacts: []\ndone_gate:\n  checks:\n    - Beta complete\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/runs/run-001.yml"),
            "run_id: \"run-001\"\nstatus: \"running\"\nstarted_at: \"2026-03-11T10:10:00Z\"\ndecision_id: \"dec-001\"\ncontinuity_run_path: \".octon/state/evidence/runs/run-001/\"\nsummary: \"Example run\"\nexecutor_id: \"exec-1\"\nexecutor_acknowledged_at: \"2026-03-11T10:10:01Z\"\nlast_heartbeat_at: \"2026-03-11T10:15:00Z\"\nlease_expires_at: \"2099-03-11T10:20:00Z\"\nrecovery_status: \"healthy\"\nworkflow_ref:\n  workflow_group: \"alpha\"\n  workflow_id: \"alpha\"\nautomation_id: \"example\"\nmission_id: \"example\"\nincident_id: \"inc-001\"\nqueue_item_id: \"q-001\"\nevent_id: \"evt-001\"\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/runs/index.yml"),
            "schema_version: \"orchestration-runs-index-v1\"\nruns: []\n",
        );
        write_file(
            &root.join(".octon/state/evidence/decisions/repo/dec-001/decision.json"),
            "{\n  \"decision_id\": \"dec-001\",\n  \"outcome\": \"allow\",\n  \"surface\": \"automations\",\n  \"action\": \"launch\",\n  \"actor\": \"example\",\n  \"summary\": \"Allowed.\",\n  \"run_id\": \"run-001\",\n  \"automation_id\": \"example\",\n  \"event_id\": \"evt-001\",\n  \"queue_item_id\": \"q-001\"\n}\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/queue/pending/q-001.json"),
            "{\n  \"queue_item_id\": \"q-001\",\n  \"target_automation_id\": \"example\",\n  \"status\": \"pending\",\n  \"summary\": \"Queued.\",\n  \"event_id\": \"evt-001\",\n  \"watcher_id\": \"example\",\n  \"payload_ref\": \"/tmp/octon-studio-ops-event.json\",\n  \"enqueued_at\": \"2026-03-11T10:05:00Z\",\n  \"available_at\": \"2026-03-11T10:05:00Z\"\n}\n",
        );
        write_file(
            &PathBuf::from("/tmp/octon-studio-ops-event.json"),
            "{\n  \"event_id\": \"evt-001\",\n  \"emitted_at\": \"2026-03-11T10:04:00Z\"\n}\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/queue/receipts/q-001-ack-20260311T101600Z.json"),
            "{\n  \"queue_item_id\": \"q-001\",\n  \"handled_at\": \"2026-03-11T10:16:00Z\"\n}\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/automations/example/automation.yml"),
            "automation_id: \"example\"\ntitle: \"Example Automation\"\nworkflow_ref:\n  workflow_group: \"alpha\"\n  workflow_id: \"alpha\"\nowner: \"@architect\"\nstatus: \"active\"\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/automations/example/state/counters.json"),
            "{\n  \"blocked\": 2\n}\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/automations/example/state/status.json"),
            "{\n  \"status\": \"active\"\n}\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/watchers/example/watcher.yml"),
            "watcher_id: \"example\"\ntitle: \"Example Watcher\"\nowner: \"@architect\"\nstatus: \"active\"\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/watchers/example/state/health.json"),
            "{\n  \"status\": \"healthy\",\n  \"checked_at\": \"2026-03-11T10:00:00Z\"\n}\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/watchers/example/state/suppressions.json"),
            "{\n  \"suppressed\": [\"evt-old\"]\n}\n",
        );
        write_file(
            &root.join(".octon/instance/orchestration/missions/example/mission.yml"),
            "schema_version: \"octon-mission-v2\"\nmission_id: \"example\"\ntitle: \"Example Mission\"\nsummary: \"Example mission.\"\nstatus: \"active\"\nmission_class: \"maintenance\"\nowner_ref: \"operator://architect\"\ncreated_at: \"2026-03-10T00:00:00Z\"\nrisk_ceiling: \"ACP-1\"\nallowed_action_classes:\n  - \"repo-maintenance\"\ndefault_safing_subset:\n  - \"observe_only\"\n  - \"stage_only\"\ndefault_schedule_hint: \"interruptible_scheduled\"\ndefault_overlap_policy: \"skip\"\nscope_ids: []\nsuccess_criteria:\n  - \"Example complete\"\nfailure_conditions: []\nactive_run_ids:\n  - \"run-001\"\n",
        );
        write_file(
            &root.join(".octon/instance/orchestration/missions/example/tasks.json"),
            "{\n  \"tasks\": [\n    {\"id\": \"t1\", \"status\": \"blocked\"},\n    {\"id\": \"t2\", \"status\": \"open\"}\n  ]\n}\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/incidents/inc-001/incident.yml"),
            "incident_id: \"inc-001\"\ntitle: \"Example Incident\"\nseverity: \"sev2\"\nstatus: \"closed\"\nowner: \"@architect\"\nsummary: \"Incident summary\"\nrun_ids:\n  - \"run-001\"\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/incidents/inc-001/timeline.md"),
            "# Incident Timeline: inc-001\n\n- 2026-03-11T10:20:00Z: incident updated\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/runtime/incidents/inc-001/closure.md"),
            "# Incident Closure: inc-001\n\n- Closed At: `2026-03-11T10:30:00Z`\n- Closed By: `@architect`\n- Approval: `appr-001`\n\nClosed with evidence.\n\n## Remediation Evidence\n\n- Remediation Ref: `run:run-001`\n",
        );
        write_file(
            &root.join(".octon/framework/orchestration/practices/orchestration-failure-playbooks.md"),
            "# Orchestration Failure Playbooks\n\n## watcher source unreadable\n\n- Inspect watcher health.\n",
        );
    }

    fn write_fixture_audits(root: &Path) {
        write_file(
            &root.join(".octon/state/evidence/runs/operations/1001-1-studio-apply-audit.md"),
            "# Octon Studio Apply Audit\n\n- timestamp_unix_ms: 1001\n- status: applied\n- attempted_files: 1\n- applied_files: 1\n- rolled_back_files: 0\n- summary: Applied 1 staged edits.\n\n## Staged Edits\n- update | .octon/framework/orchestration/runtime/workflows/alpha/README.md | Normalize README.md frontmatter defaults\n",
        );
        write_file(
            &root.join(".octon/state/evidence/runs/operations/1002-1-studio-apply-audit.md"),
            "# Octon Studio Apply Audit\n\n- timestamp_unix_ms: 1002\n- status: failed-rolled-back\n- attempted_files: 2\n- applied_files: 1\n- rolled_back_files: 1\n- summary: Apply failed and rolled back 1 file(s): synthetic write error\n\n## Staged Edits\n- create | .octon/framework/orchestration/runtime/workflows/beta/stages/01-beta.md | Create missing step file\n",
        );
    }

    fn write_file(path: &Path, contents: &str) {
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).expect("parent directory should be created");
        }
        fs::write(path, contents).expect("fixture file should be written");
    }
}
