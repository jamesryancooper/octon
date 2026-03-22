use crate::errors::{ErrorCode, KernelError, Result};
use serde::Serialize;
use serde_json::Value;
use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::path::{Path, PathBuf};
use time::format_description::well_known::Rfc3339;
use time::OffsetDateTime;

#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
pub enum SummarySurface {
    Watchers,
    Queue,
    Automations,
    Runs,
    Missions,
    Incidents,
    All,
}

impl SummarySurface {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Watchers => "watchers",
            Self::Queue => "queue",
            Self::Automations => "automations",
            Self::Runs => "runs",
            Self::Missions => "missions",
            Self::Incidents => "incidents",
            Self::All => "all",
        }
    }
}

#[derive(Debug, Clone)]
pub enum LookupQuery {
    DecisionId(String),
    RunId(String),
    IncidentId(String),
    QueueItemId(String),
    EventId(String),
    AutomationId(String),
    WatcherId(String),
    MissionId(String),
}

impl LookupQuery {
    pub fn kind(&self) -> &'static str {
        match self {
            Self::DecisionId(_) => "decision_id",
            Self::RunId(_) => "run_id",
            Self::IncidentId(_) => "incident_id",
            Self::QueueItemId(_) => "queue_item_id",
            Self::EventId(_) => "event_id",
            Self::AutomationId(_) => "automation_id",
            Self::WatcherId(_) => "watcher_id",
            Self::MissionId(_) => "mission_id",
        }
    }

    pub fn id(&self) -> &str {
        match self {
            Self::DecisionId(id)
            | Self::RunId(id)
            | Self::IncidentId(id)
            | Self::QueueItemId(id)
            | Self::EventId(id)
            | Self::AutomationId(id)
            | Self::WatcherId(id)
            | Self::MissionId(id) => id,
        }
    }
}

#[derive(Debug, Clone, Serialize, Default)]
pub struct OverviewCounts {
    pub watcher_count: usize,
    pub watcher_unhealthy_count: usize,
    pub automation_count: usize,
    pub automation_attention_count: usize,
    pub mission_count: usize,
    pub run_count: usize,
    pub running_run_count: usize,
    pub incident_count: usize,
    pub open_incident_count: usize,
    pub incident_closure_blocked_count: usize,
    pub queue_pending_count: usize,
    pub queue_claimed_count: usize,
    pub queue_retry_count: usize,
    pub queue_dead_letter_count: usize,
    pub queue_expired_claim_count: usize,
}

#[derive(Debug, Clone, Serialize)]
pub struct QueueSummary {
    pub pending_count: usize,
    pub claimed_count: usize,
    pub retry_count: usize,
    pub dead_letter_count: usize,
    pub expired_claim_count: usize,
    pub oldest_pending_queue_item_id: Option<String>,
    pub oldest_pending_age_seconds: Option<i64>,
    pub last_receipt_at: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
pub struct WatcherStatusSummary {
    pub watcher_id: String,
    pub title: String,
    pub status: String,
    pub health_status: String,
    pub owner: String,
    pub last_evaluated_at: Option<String>,
    pub last_emitted_event_id: Option<String>,
    pub last_emitted_at: Option<String>,
    pub suppressed_count: usize,
    pub health_reason: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
pub struct AutomationStatusSummary {
    pub automation_id: String,
    pub title: String,
    pub status: String,
    pub workflow_ref: Option<String>,
    pub owner: String,
    pub last_launch_attempt_at: Option<String>,
    pub last_successful_run_id: Option<String>,
    pub failure_count: usize,
    pub suppression_count: usize,
    pub pause_or_error_reason: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
pub struct RunStatusSummary {
    pub run_id: String,
    pub status: String,
    pub started_at: Option<String>,
    pub completed_at: Option<String>,
    pub recovery_status: Option<String>,
    pub recovery_reason: Option<String>,
    pub decision_link_health: String,
    pub evidence_link_health: String,
    pub workflow_ref: Option<String>,
    pub mission_id: Option<String>,
    pub automation_id: Option<String>,
    pub incident_id: Option<String>,
    pub queue_item_id: Option<String>,
    pub event_id: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
pub struct MissionStatusSummary {
    pub mission_id: String,
    pub title: String,
    pub status: String,
    pub owner: String,
    pub active_run_ids: Vec<String>,
    pub blocked_task_count: usize,
    pub outstanding_task_count: usize,
}

#[derive(Debug, Clone, Serialize)]
pub struct IncidentStatusSummary {
    pub incident_id: String,
    pub title: String,
    pub severity: String,
    pub status: String,
    pub owner: String,
    pub last_timeline_update_at: Option<String>,
    pub linked_run_ids: Vec<String>,
    pub closure_ready: bool,
    pub closure_blockers: Vec<String>,
}

#[derive(Debug, Clone, Serialize)]
pub struct OpsSnapshot {
    pub generated_at: String,
    pub overview: OverviewCounts,
    pub watchers: Vec<WatcherStatusSummary>,
    pub queue: QueueSummary,
    pub automations: Vec<AutomationStatusSummary>,
    pub runs: Vec<RunStatusSummary>,
    pub missions: Vec<MissionStatusSummary>,
    pub incidents: Vec<IncidentStatusSummary>,
}

#[derive(Debug, Clone, Serialize)]
pub struct SurfaceSummary {
    pub generated_at: String,
    pub surface: String,
    pub payload: Value,
}

#[derive(Debug, Clone, Serialize)]
pub struct ClosureReadiness {
    pub incident_id: String,
    pub title: String,
    pub severity: String,
    pub status: String,
    pub owner: String,
    pub linked_run_ids: Vec<String>,
    pub ready: bool,
    pub blockers: Vec<String>,
}

#[derive(Debug, Clone, Serialize)]
pub struct LookupArtifact {
    pub kind: String,
    pub id: String,
    pub path: String,
    pub status: Option<String>,
    pub summary: Option<String>,
    pub details: BTreeMap<String, String>,
}

#[derive(Debug, Clone, Serialize)]
pub struct LookupRelation {
    pub from: String,
    pub to: String,
    pub relation: String,
}

#[derive(Debug, Clone, Serialize)]
pub struct LookupResult {
    pub query_kind: String,
    pub query_id: String,
    pub artifacts: Vec<LookupArtifact>,
    pub relations: Vec<LookupRelation>,
    pub notes: Vec<String>,
}

#[derive(Debug, Clone)]
pub struct OrchestrationInspector {
    repo_root: PathBuf,
    runtime_dir: PathBuf,
    runs: Vec<RunRecord>,
    decisions: Vec<DecisionRecord>,
    queue_items: Vec<QueueItemRecord>,
    queue_receipts: Vec<QueueReceiptRecord>,
    watchers: Vec<WatcherRecord>,
    automations: Vec<AutomationRecord>,
    missions: Vec<MissionRecord>,
    incidents: Vec<IncidentRecord>,
}

#[derive(Debug, Clone)]
struct RunRecord {
    run_id: String,
    path: String,
    status: String,
    summary: Option<String>,
    started_at: Option<String>,
    completed_at: Option<String>,
    decision_id: Option<String>,
    continuity_run_path: Option<String>,
    recovery_status: Option<String>,
    recovery_reason: Option<String>,
    workflow_ref: Option<String>,
    mission_id: Option<String>,
    automation_id: Option<String>,
    incident_id: Option<String>,
    queue_item_id: Option<String>,
    event_id: Option<String>,
}

#[derive(Debug, Clone)]
struct DecisionRecord {
    decision_id: String,
    path: String,
    outcome: String,
    summary: Option<String>,
    run_id: Option<String>,
    mission_id: Option<String>,
    automation_id: Option<String>,
    incident_id: Option<String>,
    event_id: Option<String>,
    queue_item_id: Option<String>,
    workflow_ref: Option<String>,
}

#[derive(Debug, Clone)]
struct QueueItemRecord {
    queue_item_id: String,
    path: String,
    lane: String,
    status: String,
    summary: Option<String>,
    target_automation_id: Option<String>,
    event_id: Option<String>,
    watcher_id: Option<String>,
    payload_ref: Option<String>,
    enqueued_at: Option<String>,
    claim_deadline: Option<String>,
}

#[derive(Debug, Clone)]
struct QueueReceiptRecord {
    handled_at: Option<String>,
}

#[derive(Debug, Clone)]
struct WatcherRecord {
    watcher_id: String,
    path: String,
    title: String,
    owner: String,
    status: String,
    health_status: String,
    health_reason: Option<String>,
    last_evaluated_at: Option<String>,
    suppressed_count: usize,
}

#[derive(Debug, Clone)]
struct AutomationRecord {
    automation_id: String,
    path: String,
    title: String,
    owner: String,
    status: String,
    workflow_ref: Option<String>,
    state_status: Option<String>,
    state_reason: Option<String>,
    counters_blocked: usize,
}

#[derive(Debug, Clone)]
struct MissionRecord {
    mission_id: String,
    path: String,
    title: String,
    status: String,
    owner: String,
    active_run_ids: Vec<String>,
    blocked_task_count: usize,
    outstanding_task_count: usize,
}

#[derive(Debug, Clone)]
struct IncidentRecord {
    incident_id: String,
    path: String,
    title: String,
    severity: String,
    status: String,
    owner: String,
    summary: Option<String>,
    linked_run_ids: Vec<String>,
    last_timeline_update_at: Option<String>,
}

impl OrchestrationInspector {
    pub fn from_octon_dir(octon_dir: &Path) -> Result<Self> {
        let octon_dir = octon_dir.canonicalize().map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to canonicalize octon dir {}: {e}", octon_dir.display()),
            )
        })?;
        let repo_root = octon_dir
            .parent()
            .ok_or_else(|| KernelError::new(ErrorCode::Internal, ".octon has no repository root"))?
            .to_path_buf();
        let runtime_dir = octon_dir.join("framework").join("orchestration").join("runtime");
        let decisions_dir = octon_dir
            .join("state")
            .join("evidence")
            .join("decisions")
            .join("repo");
        let missions_dir = octon_dir
            .join("instance")
            .join("orchestration")
            .join("missions");

        Ok(Self {
            runs: load_runs(&repo_root, &runtime_dir)?,
            decisions: load_decisions(&repo_root, &decisions_dir)?,
            queue_items: load_queue_items(&repo_root, &runtime_dir)?,
            queue_receipts: load_queue_receipts(&repo_root, &runtime_dir)?,
            watchers: load_watchers(&repo_root, &runtime_dir)?,
            automations: load_automations(&repo_root, &runtime_dir)?,
            missions: load_missions(&repo_root, &missions_dir)?,
            incidents: load_incidents(&repo_root, &runtime_dir)?,
            repo_root,
            runtime_dir,
        })
    }

    pub fn from_repo_root(repo_root: &Path) -> Result<Self> {
        Self::from_octon_dir(&repo_root.join(".octon"))
    }

    pub fn snapshot(&self) -> Result<OpsSnapshot> {
        let generated_at = now_utc()?;
        let watcher_summaries = self.watcher_summaries();
        let queue_summary = self.queue_summary();
        let automation_summaries = self.automation_summaries();
        let run_summaries = self.run_summaries();
        let mission_summaries = self.mission_summaries();
        let incident_summaries = self.incident_summaries()?;

        let overview = OverviewCounts {
            watcher_count: watcher_summaries.len(),
            watcher_unhealthy_count: watcher_summaries
                .iter()
                .filter(|item| item.health_status != "healthy")
                .count(),
            automation_count: automation_summaries.len(),
            automation_attention_count: automation_summaries
                .iter()
                .filter(|item| {
                    matches!(item.status.as_str(), "paused" | "error")
                        || item.pause_or_error_reason.is_some()
                        || item.failure_count > 0
                })
                .count(),
            mission_count: mission_summaries.len(),
            run_count: run_summaries.len(),
            running_run_count: run_summaries
                .iter()
                .filter(|item| item.status == "running")
                .count(),
            incident_count: incident_summaries.len(),
            open_incident_count: incident_summaries
                .iter()
                .filter(|item| item.status != "closed" && item.status != "cancelled")
                .count(),
            incident_closure_blocked_count: incident_summaries
                .iter()
                .filter(|item| !item.closure_ready)
                .count(),
            queue_pending_count: queue_summary.pending_count,
            queue_claimed_count: queue_summary.claimed_count,
            queue_retry_count: queue_summary.retry_count,
            queue_dead_letter_count: queue_summary.dead_letter_count,
            queue_expired_claim_count: queue_summary.expired_claim_count,
        };

        Ok(OpsSnapshot {
            generated_at,
            overview,
            watchers: watcher_summaries,
            queue: queue_summary,
            automations: automation_summaries,
            runs: run_summaries,
            missions: mission_summaries,
            incidents: incident_summaries,
        })
    }

    pub fn summary(&self, surface: SummarySurface) -> Result<SurfaceSummary> {
        let snapshot = self.snapshot()?;
        let payload = match surface {
            SummarySurface::Watchers => to_json_value(&snapshot.watchers)?,
            SummarySurface::Queue => to_json_value(&snapshot.queue)?,
            SummarySurface::Automations => to_json_value(&snapshot.automations)?,
            SummarySurface::Runs => to_json_value(&snapshot.runs)?,
            SummarySurface::Missions => to_json_value(&snapshot.missions)?,
            SummarySurface::Incidents => to_json_value(&snapshot.incidents)?,
            SummarySurface::All => to_json_value(&snapshot)?,
        };

        Ok(SurfaceSummary {
            generated_at: snapshot.generated_at,
            surface: surface.as_str().to_string(),
            payload,
        })
    }

    pub fn incident_closure_readiness(&self, incident_id: &str) -> Result<ClosureReadiness> {
        let incident = self
            .incidents
            .iter()
            .find(|item| item.incident_id == incident_id)
            .ok_or_else(|| {
                KernelError::new(
                    ErrorCode::UnknownOperation,
                    format!("unknown incident_id '{}'", incident_id),
                )
            })?;
        compute_incident_closure_readiness(&self.repo_root, incident)
    }

    pub fn lookup(&self, query: LookupQuery) -> Result<LookupResult> {
        let mut artifacts = Vec::new();
        let mut relations = Vec::new();
        let mut notes = Vec::new();
        let mut seen = BTreeSet::new();

        let mut push_artifact = |artifact: LookupArtifact| {
            let key = format!("{}:{}", artifact.kind, artifact.id);
            if seen.insert(key) {
                artifacts.push(artifact);
            }
        };

        match query.clone() {
            LookupQuery::DecisionId(decision_id) => {
                let decision = self
                    .decisions
                    .iter()
                    .find(|item| item.decision_id == decision_id)
                    .ok_or_else(|| {
                        KernelError::new(
                            ErrorCode::UnknownOperation,
                            format!("unknown decision_id '{}'", query.id()),
                        )
                    })?;
                push_artifact(self.decision_artifact(decision));
                self.expand_from_decision(decision, &mut push_artifact, &mut relations, &mut notes);
            }
            LookupQuery::RunId(run_id) => {
                let run = self.runs.iter().find(|item| item.run_id == run_id).ok_or_else(|| {
                    KernelError::new(
                        ErrorCode::UnknownOperation,
                        format!("unknown run_id '{}'", query.id()),
                    )
                })?;
                push_artifact(self.run_artifact(run));
                self.expand_from_run(run, &mut push_artifact, &mut relations, &mut notes);
            }
            LookupQuery::IncidentId(incident_id) => {
                let incident = self
                    .incidents
                    .iter()
                    .find(|item| item.incident_id == incident_id)
                    .ok_or_else(|| {
                        KernelError::new(
                            ErrorCode::UnknownOperation,
                            format!("unknown incident_id '{}'", query.id()),
                        )
                    })?;
                push_artifact(self.incident_artifact(incident)?);
                self.expand_from_incident(incident, &mut push_artifact, &mut relations, &mut notes)?;
            }
            LookupQuery::QueueItemId(queue_item_id) => {
                let queue_item = self
                    .queue_items
                    .iter()
                    .find(|item| item.queue_item_id == queue_item_id)
                    .ok_or_else(|| {
                        KernelError::new(
                            ErrorCode::UnknownOperation,
                            format!("unknown queue_item_id '{}'", query.id()),
                        )
                    })?;
                push_artifact(self.queue_artifact(queue_item));
                self.expand_from_queue_item(queue_item, &mut push_artifact, &mut relations, &mut notes);
            }
            LookupQuery::EventId(event_id) => {
                let mut found = false;
                for queue_item in self.queue_items.iter().filter(|item| item.event_id.as_deref() == Some(event_id.as_str())) {
                    found = true;
                    push_artifact(self.queue_artifact(queue_item));
                    self.expand_from_queue_item(queue_item, &mut push_artifact, &mut relations, &mut notes);
                }
                for run in self.runs.iter().filter(|item| item.event_id.as_deref() == Some(event_id.as_str())) {
                    found = true;
                    push_artifact(self.run_artifact(run));
                    self.expand_from_run(run, &mut push_artifact, &mut relations, &mut notes);
                }
                for decision in self
                    .decisions
                    .iter()
                    .filter(|item| item.event_id.as_deref() == Some(event_id.as_str()))
                {
                    found = true;
                    push_artifact(self.decision_artifact(decision));
                    self.expand_from_decision(decision, &mut push_artifact, &mut relations, &mut notes);
                }
                for incident in self
                    .incidents
                    .iter()
                    .filter(|item| incident_contains_event(item, event_id.as_str(), &self.repo_root))
                {
                    found = true;
                    push_artifact(self.incident_artifact(incident)?);
                    self.expand_from_incident(incident, &mut push_artifact, &mut relations, &mut notes)?;
                }
                if !found {
                    return Err(KernelError::new(
                        ErrorCode::UnknownOperation,
                        format!("unknown event_id '{}'", query.id()),
                    ));
                }
            }
            LookupQuery::AutomationId(automation_id) => {
                let automation = self
                    .automations
                    .iter()
                    .find(|item| item.automation_id == automation_id)
                    .ok_or_else(|| {
                        KernelError::new(
                            ErrorCode::UnknownOperation,
                            format!("unknown automation_id '{}'", query.id()),
                        )
                    })?;
                push_artifact(self.automation_artifact(automation));
                for queue_item in self
                    .queue_items
                    .iter()
                    .filter(|item| item.target_automation_id.as_deref() == Some(automation_id.as_str()))
                {
                    push_artifact(self.queue_artifact(queue_item));
                    relations.push(LookupRelation {
                        from: format!("queue_item:{}", queue_item.queue_item_id),
                        to: format!("automation:{}", automation_id),
                        relation: "targets".to_string(),
                    });
                }
                for run in self.runs.iter().filter(|item| item.automation_id.as_deref() == Some(automation_id.as_str())) {
                    push_artifact(self.run_artifact(run));
                    self.expand_from_run(run, &mut push_artifact, &mut relations, &mut notes);
                }
                if let Some(workflow_ref) = &automation.workflow_ref {
                    push_artifact(self.workflow_artifact(workflow_ref));
                    relations.push(LookupRelation {
                        from: format!("automation:{}", automation_id),
                        to: format!("workflow:{}", workflow_ref),
                        relation: "targets_workflow".to_string(),
                    });
                }
            }
            LookupQuery::WatcherId(watcher_id) => {
                let watcher = self
                    .watchers
                    .iter()
                    .find(|item| item.watcher_id == watcher_id)
                    .ok_or_else(|| {
                        KernelError::new(
                            ErrorCode::UnknownOperation,
                            format!("unknown watcher_id '{}'", query.id()),
                        )
                    })?;
                push_artifact(self.watcher_artifact(watcher));
                for queue_item in self.queue_items.iter().filter(|item| item.watcher_id.as_deref() == Some(watcher_id.as_str())) {
                    push_artifact(self.queue_artifact(queue_item));
                    self.expand_from_queue_item(queue_item, &mut push_artifact, &mut relations, &mut notes);
                }
            }
            LookupQuery::MissionId(mission_id) => {
                let mission = self
                    .missions
                    .iter()
                    .find(|item| item.mission_id == mission_id)
                    .ok_or_else(|| {
                        KernelError::new(
                            ErrorCode::UnknownOperation,
                            format!("unknown mission_id '{}'", query.id()),
                        )
                    })?;
                push_artifact(self.mission_artifact(mission));
                for run in self.runs.iter().filter(|item| item.mission_id.as_deref() == Some(mission_id.as_str())) {
                    push_artifact(self.run_artifact(run));
                    self.expand_from_run(run, &mut push_artifact, &mut relations, &mut notes);
                }
                for incident in self.incidents.iter().filter(|item| incident_contains_mission(item, mission_id.as_str(), &self.repo_root)) {
                    push_artifact(self.incident_artifact(incident)?);
                    self.expand_from_incident(incident, &mut push_artifact, &mut relations, &mut notes)?;
                }
            }
        }

        artifacts.sort_by(|a, b| a.kind.cmp(&b.kind).then(a.id.cmp(&b.id)));
        relations.sort_by(|a, b| a.from.cmp(&b.from).then(a.to.cmp(&b.to)).then(a.relation.cmp(&b.relation)));
        notes.sort();
        notes.dedup();

        Ok(LookupResult {
            query_kind: query.kind().to_string(),
            query_id: query.id().to_string(),
            artifacts,
            relations,
            notes,
        })
    }

    fn watcher_summaries(&self) -> Vec<WatcherStatusSummary> {
        let mut items = self
            .watchers
            .iter()
            .map(|watcher| {
                let latest_event = self.latest_event_for_watcher(&watcher.watcher_id);
                WatcherStatusSummary {
                    watcher_id: watcher.watcher_id.clone(),
                    title: watcher.title.clone(),
                    status: watcher.status.clone(),
                    health_status: watcher.health_status.clone(),
                    owner: watcher.owner.clone(),
                    last_evaluated_at: watcher.last_evaluated_at.clone(),
                    last_emitted_event_id: latest_event.as_ref().map(|(event_id, _, _)| event_id.clone()),
                    last_emitted_at: latest_event.as_ref().and_then(|(_, emitted_at, _)| emitted_at.clone()),
                    suppressed_count: watcher.suppressed_count,
                    health_reason: watcher.health_reason.clone(),
                }
            })
            .collect::<Vec<_>>();
        items.sort_by(|a, b| a.watcher_id.cmp(&b.watcher_id));
        items
    }

    fn queue_summary(&self) -> QueueSummary {
        let mut pending_count = 0;
        let mut claimed_count = 0;
        let mut retry_count = 0;
        let mut dead_letter_count = 0;
        let mut expired_claim_count = 0;
        let mut oldest_pending: Option<(&QueueItemRecord, Option<OffsetDateTime>)> = None;
        let now = OffsetDateTime::now_utc();

        for item in &self.queue_items {
            match item.lane.as_str() {
                "pending" => {
                    pending_count += 1;
                    let parsed = item.enqueued_at.as_deref().and_then(parse_timestamp);
                    match (&oldest_pending, parsed) {
                        (None, _) => oldest_pending = Some((item, parsed)),
                        (Some((current, current_ts)), Some(candidate_ts)) => {
                            if current_ts.map(|ts| candidate_ts < ts).unwrap_or(true) {
                                oldest_pending = Some((item, Some(candidate_ts)));
                            } else {
                                oldest_pending = Some((current, *current_ts));
                            }
                        }
                        _ => {}
                    }
                }
                "claimed" => {
                    claimed_count += 1;
                    if item
                        .claim_deadline
                        .as_deref()
                        .and_then(parse_timestamp)
                        .map(|deadline| deadline < now)
                        .unwrap_or(false)
                    {
                        expired_claim_count += 1;
                    }
                }
                "retry" => retry_count += 1,
                "dead-letter" => dead_letter_count += 1,
                _ => {}
            }
        }

        let oldest_pending_queue_item_id = oldest_pending.map(|(item, _)| item.queue_item_id.clone());
        let oldest_pending_age_seconds = oldest_pending
            .and_then(|(_, ts)| ts)
            .map(|ts| (now - ts).whole_seconds());
        let last_receipt_at = self
            .queue_receipts
            .iter()
            .filter_map(|item| item.handled_at.clone())
            .max();

        QueueSummary {
            pending_count,
            claimed_count,
            retry_count,
            dead_letter_count,
            expired_claim_count,
            oldest_pending_queue_item_id,
            oldest_pending_age_seconds,
            last_receipt_at,
        }
    }

    fn automation_summaries(&self) -> Vec<AutomationStatusSummary> {
        let mut items = self
            .automations
            .iter()
            .map(|automation| {
                let related_runs = self
                    .runs
                    .iter()
                    .filter(|run| run.automation_id.as_deref() == Some(automation.automation_id.as_str()))
                    .collect::<Vec<_>>();
                let last_launch_attempt_at = related_runs
                    .iter()
                    .filter_map(|run| run.started_at.clone())
                    .max();
                let last_successful_run_id = related_runs
                    .iter()
                    .filter(|run| run.status == "succeeded")
                    .max_by_key(|run| run.completed_at.clone().unwrap_or_default())
                    .map(|run| run.run_id.clone());
                let failure_count = related_runs.iter().filter(|run| run.status == "failed").count();
                let pause_or_error_reason = automation.state_reason.clone().or_else(|| {
                    if matches!(automation.status.as_str(), "paused" | "error") {
                        Some("status requires operator attention".to_string())
                    } else {
                        None
                    }
                });
                AutomationStatusSummary {
                    automation_id: automation.automation_id.clone(),
                    title: automation.title.clone(),
                    status: automation
                        .state_status
                        .clone()
                        .unwrap_or_else(|| automation.status.clone()),
                    workflow_ref: automation.workflow_ref.clone(),
                    owner: automation.owner.clone(),
                    last_launch_attempt_at,
                    last_successful_run_id,
                    failure_count,
                    suppression_count: automation.counters_blocked,
                    pause_or_error_reason,
                }
            })
            .collect::<Vec<_>>();
        items.sort_by(|a, b| a.automation_id.cmp(&b.automation_id));
        items
    }

    fn run_summaries(&self) -> Vec<RunStatusSummary> {
        let mut items = self
            .runs
            .iter()
            .map(|run| {
                let decision_link_health = match &run.decision_id {
                    Some(decision_id) if self.decisions.iter().any(|item| item.decision_id == *decision_id) => "healthy".to_string(),
                    Some(_) => "missing-decision".to_string(),
                    None => "missing-decision".to_string(),
                };
                let evidence_link_health = match &run.continuity_run_path {
                    Some(path) if self.repo_root.join(path).exists() => "healthy".to_string(),
                    Some(_) => "missing-continuity-evidence".to_string(),
                    None => "missing-continuity-evidence".to_string(),
                };
                RunStatusSummary {
                    run_id: run.run_id.clone(),
                    status: run.status.clone(),
                    started_at: run.started_at.clone(),
                    completed_at: run.completed_at.clone(),
                    recovery_status: run.recovery_status.clone(),
                    recovery_reason: run.recovery_reason.clone(),
                    decision_link_health,
                    evidence_link_health,
                    workflow_ref: run.workflow_ref.clone(),
                    mission_id: run.mission_id.clone(),
                    automation_id: run.automation_id.clone(),
                    incident_id: run.incident_id.clone(),
                    queue_item_id: run.queue_item_id.clone(),
                    event_id: run.event_id.clone(),
                }
            })
            .collect::<Vec<_>>();
        items.sort_by(|a, b| a.run_id.cmp(&b.run_id));
        items
    }

    fn mission_summaries(&self) -> Vec<MissionStatusSummary> {
        let mut items = self
            .missions
            .iter()
            .map(|mission| MissionStatusSummary {
                mission_id: mission.mission_id.clone(),
                title: mission.title.clone(),
                status: mission.status.clone(),
                owner: mission.owner.clone(),
                active_run_ids: mission.active_run_ids.clone(),
                blocked_task_count: mission.blocked_task_count,
                outstanding_task_count: mission.outstanding_task_count,
            })
            .collect::<Vec<_>>();
        items.sort_by(|a, b| a.mission_id.cmp(&b.mission_id));
        items
    }

    fn incident_summaries(&self) -> Result<Vec<IncidentStatusSummary>> {
        let mut items = Vec::new();
        for incident in &self.incidents {
            let readiness = compute_incident_closure_readiness(&self.repo_root, incident)?;
            items.push(IncidentStatusSummary {
                incident_id: incident.incident_id.clone(),
                title: incident.title.clone(),
                severity: incident.severity.clone(),
                status: incident.status.clone(),
                owner: incident.owner.clone(),
                last_timeline_update_at: incident.last_timeline_update_at.clone(),
                linked_run_ids: incident.linked_run_ids.clone(),
                closure_ready: readiness.ready,
                closure_blockers: readiness.blockers,
            });
        }
        items.sort_by(|a, b| a.incident_id.cmp(&b.incident_id));
        Ok(items)
    }

    fn latest_event_for_watcher(&self, watcher_id: &str) -> Option<(String, Option<String>, String)> {
        self.queue_items
            .iter()
            .filter(|item| item.watcher_id.as_deref() == Some(watcher_id))
            .filter_map(|item| {
                let emitted_at = item
                    .payload_ref
                    .as_deref()
                    .and_then(|path| read_event_timestamp(&self.repo_root, path).ok().flatten());
                Some((
                    item.event_id.clone().unwrap_or_else(|| item.queue_item_id.clone()),
                    emitted_at,
                    item.path.clone(),
                ))
            })
            .max_by_key(|(event_id, emitted_at, path)| {
                (
                    emitted_at.clone().unwrap_or_default(),
                    event_id.clone(),
                    path.clone(),
                )
            })
    }

    fn decision_artifact(&self, item: &DecisionRecord) -> LookupArtifact {
        let mut details = BTreeMap::new();
        details.insert("outcome".to_string(), item.outcome.clone());
        if let Some(workflow_ref) = &item.workflow_ref {
            details.insert("workflow_ref".to_string(), workflow_ref.clone());
        }
        LookupArtifact {
            kind: "decision".to_string(),
            id: item.decision_id.clone(),
            path: item.path.clone(),
            status: Some(item.outcome.clone()),
            summary: item.summary.clone(),
            details,
        }
    }

    fn run_artifact(&self, item: &RunRecord) -> LookupArtifact {
        let mut details = BTreeMap::new();
        if let Some(workflow_ref) = &item.workflow_ref {
            details.insert("workflow_ref".to_string(), workflow_ref.clone());
        }
        if let Some(recovery_status) = &item.recovery_status {
            details.insert("recovery_status".to_string(), recovery_status.clone());
        }
        details.insert(
            "decision_link_health".to_string(),
            if item
                .decision_id
                .as_ref()
                .is_some_and(|decision_id| self.decisions.iter().any(|entry| entry.decision_id == *decision_id))
            {
                "healthy".to_string()
            } else {
                "missing-decision".to_string()
            },
        );
        details.insert(
            "evidence_link_health".to_string(),
            if item
                .continuity_run_path
                .as_ref()
                .is_some_and(|path| self.repo_root.join(path).exists())
            {
                "healthy".to_string()
            } else {
                "missing-continuity-evidence".to_string()
            },
        );
        LookupArtifact {
            kind: "run".to_string(),
            id: item.run_id.clone(),
            path: item.path.clone(),
            status: Some(item.status.clone()),
            summary: item.summary.clone(),
            details,
        }
    }

    fn queue_artifact(&self, item: &QueueItemRecord) -> LookupArtifact {
        let mut details = BTreeMap::new();
        details.insert("lane".to_string(), item.lane.clone());
        if let Some(target) = &item.target_automation_id {
            details.insert("target_automation_id".to_string(), target.clone());
        }
        LookupArtifact {
            kind: "queue_item".to_string(),
            id: item.queue_item_id.clone(),
            path: item.path.clone(),
            status: Some(item.status.clone()),
            summary: item.summary.clone(),
            details,
        }
    }

    fn watcher_artifact(&self, item: &WatcherRecord) -> LookupArtifact {
        let mut details = BTreeMap::new();
        details.insert("health_status".to_string(), item.health_status.clone());
        if let Some(reason) = &item.health_reason {
            details.insert("health_reason".to_string(), reason.clone());
        }
        LookupArtifact {
            kind: "watcher".to_string(),
            id: item.watcher_id.clone(),
            path: item.path.clone(),
            status: Some(item.status.clone()),
            summary: Some(item.title.clone()),
            details,
        }
    }

    fn automation_artifact(&self, item: &AutomationRecord) -> LookupArtifact {
        let mut details = BTreeMap::new();
        if let Some(workflow_ref) = &item.workflow_ref {
            details.insert("workflow_ref".to_string(), workflow_ref.clone());
        }
        LookupArtifact {
            kind: "automation".to_string(),
            id: item.automation_id.clone(),
            path: item.path.clone(),
            status: Some(item.status.clone()),
            summary: Some(item.title.clone()),
            details,
        }
    }

    fn mission_artifact(&self, item: &MissionRecord) -> LookupArtifact {
        let mut details = BTreeMap::new();
        details.insert(
            "outstanding_task_count".to_string(),
            item.outstanding_task_count.to_string(),
        );
        details.insert("blocked_task_count".to_string(), item.blocked_task_count.to_string());
        LookupArtifact {
            kind: "mission".to_string(),
            id: item.mission_id.clone(),
            path: item.path.clone(),
            status: Some(item.status.clone()),
            summary: Some(item.title.clone()),
            details,
        }
    }

    fn incident_artifact(&self, item: &IncidentRecord) -> Result<LookupArtifact> {
        let readiness = compute_incident_closure_readiness(&self.repo_root, item)?;
        let mut details = BTreeMap::new();
        details.insert("severity".to_string(), item.severity.clone());
        details.insert("closure_ready".to_string(), readiness.ready.to_string());
        if !readiness.blockers.is_empty() {
            details.insert("closure_blockers".to_string(), readiness.blockers.join("; "));
        }
        Ok(LookupArtifact {
            kind: "incident".to_string(),
            id: item.incident_id.clone(),
            path: item.path.clone(),
            status: Some(item.status.clone()),
            summary: item.summary.clone().or_else(|| Some(item.title.clone())),
            details,
        })
    }

    fn workflow_artifact(&self, workflow_ref: &str) -> LookupArtifact {
        let parts = workflow_ref.split('/').collect::<Vec<_>>();
        let path = if parts.len() == 2 {
            self.runtime_dir
                .join("workflows")
                .join(parts[0])
                .join(parts[1])
                .join("workflow.yml")
        } else {
            self.runtime_dir.join("workflows")
        };
        LookupArtifact {
            kind: "workflow".to_string(),
            id: workflow_ref.to_string(),
            path: rel_path(&self.repo_root, &path),
            status: None,
            summary: None,
            details: BTreeMap::new(),
        }
    }

    fn continuity_run_artifact(&self, path: &str, run_id: &str) -> LookupArtifact {
        let abs = self.repo_root.join(path);
        LookupArtifact {
            kind: "continuity_run".to_string(),
            id: run_id.to_string(),
            path: rel_path(&self.repo_root, &abs),
            status: Some(if abs.exists() { "present" } else { "missing" }.to_string()),
            summary: None,
            details: BTreeMap::new(),
        }
    }

    fn expand_from_decision(
        &self,
        decision: &DecisionRecord,
        push_artifact: &mut dyn FnMut(LookupArtifact),
        relations: &mut Vec<LookupRelation>,
        notes: &mut Vec<String>,
    ) {
        if let Some(run_id) = &decision.run_id {
            if let Some(run) = self.runs.iter().find(|item| item.run_id == *run_id) {
                push_artifact(self.run_artifact(run));
                relations.push(LookupRelation {
                    from: format!("decision:{}", decision.decision_id),
                    to: format!("run:{}", run.run_id),
                    relation: "permits".to_string(),
                });
                self.expand_from_run(run, push_artifact, relations, notes);
            }
        }
        if let Some(queue_item_id) = &decision.queue_item_id {
            if let Some(queue_item) = self
                .queue_items
                .iter()
                .find(|item| item.queue_item_id == *queue_item_id)
            {
                push_artifact(self.queue_artifact(queue_item));
                relations.push(LookupRelation {
                    from: format!("decision:{}", decision.decision_id),
                    to: format!("queue_item:{}", queue_item.queue_item_id),
                    relation: "references_queue_item".to_string(),
                });
            }
        }
        if let Some(automation_id) = &decision.automation_id {
            if let Some(automation) = self
                .automations
                .iter()
                .find(|item| item.automation_id == *automation_id)
            {
                push_artifact(self.automation_artifact(automation));
                relations.push(LookupRelation {
                    from: format!("decision:{}", decision.decision_id),
                    to: format!("automation:{}", automation.automation_id),
                    relation: "for_automation".to_string(),
                });
            }
        }
        if let Some(mission_id) = &decision.mission_id {
            if let Some(mission) = self.missions.iter().find(|item| item.mission_id == *mission_id) {
                push_artifact(self.mission_artifact(mission));
            }
        }
        if let Some(incident_id) = &decision.incident_id {
            if let Some(incident) = self
                .incidents
                .iter()
                .find(|item| item.incident_id == *incident_id)
            {
                if let Ok(artifact) = self.incident_artifact(incident) {
                    push_artifact(artifact);
                }
            }
        }
        if let Some(workflow_ref) = &decision.workflow_ref {
            push_artifact(self.workflow_artifact(workflow_ref));
        }
        if let Some(event_id) = &decision.event_id {
            notes.push(format!("decision references event_id `{event_id}`"));
        }
    }

    fn expand_from_run(
        &self,
        run: &RunRecord,
        push_artifact: &mut dyn FnMut(LookupArtifact),
        relations: &mut Vec<LookupRelation>,
        notes: &mut Vec<String>,
    ) {
        if let Some(decision_id) = &run.decision_id {
            if let Some(decision) = self
                .decisions
                .iter()
                .find(|item| item.decision_id == *decision_id)
            {
                push_artifact(self.decision_artifact(decision));
                relations.push(LookupRelation {
                    from: format!("run:{}", run.run_id),
                    to: format!("decision:{}", decision.decision_id),
                    relation: "authorized_by".to_string(),
                });
            } else {
                notes.push(format!("run `{}` references missing decision `{}`", run.run_id, decision_id));
            }
        }
        if let Some(queue_item_id) = &run.queue_item_id {
            if let Some(queue_item) = self
                .queue_items
                .iter()
                .find(|item| item.queue_item_id == *queue_item_id)
            {
                push_artifact(self.queue_artifact(queue_item));
                relations.push(LookupRelation {
                    from: format!("run:{}", run.run_id),
                    to: format!("queue_item:{}", queue_item.queue_item_id),
                    relation: "originated_from".to_string(),
                });
            }
        }
        if let Some(automation_id) = &run.automation_id {
            if let Some(automation) = self
                .automations
                .iter()
                .find(|item| item.automation_id == *automation_id)
            {
                push_artifact(self.automation_artifact(automation));
                relations.push(LookupRelation {
                    from: format!("run:{}", run.run_id),
                    to: format!("automation:{}", automation.automation_id),
                    relation: "launched_by".to_string(),
                });
                if let Some(workflow_ref) = &automation.workflow_ref {
                    push_artifact(self.workflow_artifact(workflow_ref));
                }
            }
        }
        if let Some(workflow_ref) = &run.workflow_ref {
            push_artifact(self.workflow_artifact(workflow_ref));
        }
        if let Some(mission_id) = &run.mission_id {
            if let Some(mission) = self.missions.iter().find(|item| item.mission_id == *mission_id) {
                push_artifact(self.mission_artifact(mission));
                relations.push(LookupRelation {
                    from: format!("run:{}", run.run_id),
                    to: format!("mission:{}", mission.mission_id),
                    relation: "linked_to".to_string(),
                });
            }
        }
        if let Some(incident_id) = &run.incident_id {
            if let Some(incident) = self
                .incidents
                .iter()
                .find(|item| item.incident_id == *incident_id)
            {
                if let Ok(artifact) = self.incident_artifact(incident) {
                    push_artifact(artifact);
                }
                relations.push(LookupRelation {
                    from: format!("run:{}", run.run_id),
                    to: format!("incident:{}", incident.incident_id),
                    relation: "linked_to".to_string(),
                });
            }
        }
        if let Some(path) = &run.continuity_run_path {
            push_artifact(self.continuity_run_artifact(path, &run.run_id));
        }
        if let Some(event_id) = &run.event_id {
            notes.push(format!("run references event_id `{event_id}`"));
        }
    }

    fn expand_from_queue_item(
        &self,
        queue_item: &QueueItemRecord,
        push_artifact: &mut dyn FnMut(LookupArtifact),
        relations: &mut Vec<LookupRelation>,
        notes: &mut Vec<String>,
    ) {
        if let Some(automation_id) = &queue_item.target_automation_id {
            if let Some(automation) = self
                .automations
                .iter()
                .find(|item| item.automation_id == *automation_id)
            {
                push_artifact(self.automation_artifact(automation));
                relations.push(LookupRelation {
                    from: format!("queue_item:{}", queue_item.queue_item_id),
                    to: format!("automation:{}", automation.automation_id),
                    relation: "targets".to_string(),
                });
                if let Some(workflow_ref) = &automation.workflow_ref {
                    push_artifact(self.workflow_artifact(workflow_ref));
                }
            }
        }
        if let Some(watcher_id) = &queue_item.watcher_id {
            if let Some(watcher) = self.watchers.iter().find(|item| item.watcher_id == *watcher_id) {
                push_artifact(self.watcher_artifact(watcher));
                relations.push(LookupRelation {
                    from: format!("queue_item:{}", queue_item.queue_item_id),
                    to: format!("watcher:{}", watcher.watcher_id),
                    relation: "emitted_by".to_string(),
                });
            }
        }
        if let Some(event_id) = &queue_item.event_id {
            for run in self.runs.iter().filter(|item| item.event_id.as_deref() == Some(event_id.as_str())) {
                push_artifact(self.run_artifact(run));
                relations.push(LookupRelation {
                    from: format!("queue_item:{}", queue_item.queue_item_id),
                    to: format!("run:{}", run.run_id),
                    relation: "launches".to_string(),
                });
            }
            notes.push(format!("queue item references event_id `{event_id}`"));
        }
    }

    fn expand_from_incident(
        &self,
        incident: &IncidentRecord,
        push_artifact: &mut dyn FnMut(LookupArtifact),
        relations: &mut Vec<LookupRelation>,
        notes: &mut Vec<String>,
    ) -> Result<()> {
            let readiness = compute_incident_closure_readiness(&self.repo_root, incident)?;
        if !readiness.blockers.is_empty() {
            notes.push(format!(
                "incident `{}` closure blockers: {}",
                incident.incident_id,
                readiness.blockers.join("; ")
            ));
        }
        for run_id in &incident.linked_run_ids {
            if let Some(run) = self.runs.iter().find(|item| item.run_id == *run_id) {
                push_artifact(self.run_artifact(run));
                relations.push(LookupRelation {
                    from: format!("incident:{}", incident.incident_id),
                    to: format!("run:{}", run.run_id),
                    relation: "tracks".to_string(),
                });
            }
        }
        Ok(())
    }
}

fn load_runs(repo_root: &Path, runtime_dir: &Path) -> Result<Vec<RunRecord>> {
    let runs_dir = runtime_dir.join("runs");
    if !runs_dir.is_dir() {
        return Ok(Vec::new());
    }
    let mut runs = Vec::new();
    for entry in fs::read_dir(&runs_dir).map_err(|e| io_error("read orchestration runs dir", &runs_dir, e))? {
        let entry = entry.map_err(|e| io_error("read orchestration runs dir entry", &runs_dir, e))?;
        let path = entry.path();
        if !path.is_file() || path.file_name().and_then(|v| v.to_str()) == Some("README.md") || path.file_name().and_then(|v| v.to_str()) == Some("index.yml") {
            continue;
        }
        if path.extension().and_then(|v| v.to_str()) != Some("yml") {
            continue;
        }
        let value = read_yaml_value(&path)?;
        runs.push(RunRecord {
            run_id: required_string(&value, "run_id", &path)?,
            path: rel_path(repo_root, &path),
            status: string_field(&value, "status").unwrap_or_else(|| "unknown".to_string()),
            summary: string_field(&value, "summary"),
            started_at: string_field(&value, "started_at"),
            completed_at: string_field(&value, "completed_at"),
            decision_id: string_field(&value, "decision_id"),
            continuity_run_path: string_field(&value, "continuity_run_path"),
            recovery_status: string_field(&value, "recovery_status"),
            recovery_reason: string_field(&value, "recovery_reason"),
            workflow_ref: workflow_ref_string(&value),
            mission_id: string_field(&value, "mission_id"),
            automation_id: string_field(&value, "automation_id"),
            incident_id: string_field(&value, "incident_id"),
            queue_item_id: string_field(&value, "queue_item_id"),
            event_id: string_field(&value, "event_id"),
        });
    }
    Ok(runs)
}

fn load_decisions(repo_root: &Path, decisions_dir: &Path) -> Result<Vec<DecisionRecord>> {
    if !decisions_dir.is_dir() {
        return Ok(Vec::new());
    }
    let mut decisions = Vec::new();
    for entry in fs::read_dir(&decisions_dir).map_err(|e| io_error("read decisions dir", &decisions_dir, e))? {
        let entry = entry.map_err(|e| io_error("read decisions dir entry", &decisions_dir, e))?;
        let path = entry.path();
        if !path.is_dir() {
            continue;
        }
        let decision_path = path.join("decision.json");
        if !decision_path.is_file() {
            continue;
        }
        let value = read_json_value(&decision_path)?;
        decisions.push(DecisionRecord {
            decision_id: required_string(&value, "decision_id", &decision_path)?,
            path: rel_path(repo_root, &decision_path),
            outcome: string_field(&value, "outcome").unwrap_or_else(|| "unknown".to_string()),
            summary: string_field(&value, "summary"),
            run_id: string_field(&value, "run_id"),
            mission_id: string_field(&value, "mission_id"),
            automation_id: string_field(&value, "automation_id"),
            incident_id: string_field(&value, "incident_id"),
            event_id: string_field(&value, "event_id"),
            queue_item_id: string_field(&value, "queue_item_id"),
            workflow_ref: workflow_ref_string(&value),
        });
    }
    Ok(decisions)
}

fn load_queue_items(repo_root: &Path, runtime_dir: &Path) -> Result<Vec<QueueItemRecord>> {
    let queue_dir = runtime_dir.join("queue");
    if !queue_dir.is_dir() {
        return Ok(Vec::new());
    }
    let mut items = Vec::new();
    for lane in ["pending", "claimed", "retry", "dead-letter"] {
        let lane_dir = queue_dir.join(lane);
        if !lane_dir.is_dir() {
            continue;
        }
        for entry in fs::read_dir(&lane_dir).map_err(|e| io_error("read queue lane dir", &lane_dir, e))? {
            let entry = entry.map_err(|e| io_error("read queue lane entry", &lane_dir, e))?;
            let path = entry.path();
            if !path.is_file() || path.extension().and_then(|v| v.to_str()) != Some("json") {
                continue;
            }
            let value = read_json_value(&path)?;
            items.push(QueueItemRecord {
                queue_item_id: required_string(&value, "queue_item_id", &path)?,
                path: rel_path(repo_root, &path),
                lane: lane.to_string(),
                status: string_field(&value, "status").unwrap_or_else(|| lane.to_string()),
                summary: string_field(&value, "summary"),
                target_automation_id: string_field(&value, "target_automation_id"),
                event_id: string_field(&value, "event_id"),
                watcher_id: string_field(&value, "watcher_id"),
                payload_ref: string_field(&value, "payload_ref"),
                enqueued_at: string_field(&value, "enqueued_at"),
                claim_deadline: string_field(&value, "claim_deadline"),
            });
        }
    }
    Ok(items)
}

fn load_queue_receipts(_repo_root: &Path, runtime_dir: &Path) -> Result<Vec<QueueReceiptRecord>> {
    let receipts_dir = runtime_dir.join("queue").join("receipts");
    if !receipts_dir.is_dir() {
        return Ok(Vec::new());
    }
    let mut items = Vec::new();
    for entry in fs::read_dir(&receipts_dir).map_err(|e| io_error("read queue receipts dir", &receipts_dir, e))? {
        let entry = entry.map_err(|e| io_error("read queue receipt entry", &receipts_dir, e))?;
        let path = entry.path();
        if !path.is_file() || path.extension().and_then(|v| v.to_str()) != Some("json") {
            continue;
        }
        let value = read_json_value(&path)?;
        items.push(QueueReceiptRecord {
            handled_at: string_field(&value, "handled_at"),
        });
    }
    Ok(items)
}

fn load_watchers(repo_root: &Path, runtime_dir: &Path) -> Result<Vec<WatcherRecord>> {
    let watchers_dir = runtime_dir.join("watchers");
    if !watchers_dir.is_dir() {
        return Ok(Vec::new());
    }
    let mut items = Vec::new();
    for entry in fs::read_dir(&watchers_dir).map_err(|e| io_error("read watchers dir", &watchers_dir, e))? {
        let entry = entry.map_err(|e| io_error("read watchers dir entry", &watchers_dir, e))?;
        let path = entry.path();
        let rel_name = path.file_name().and_then(|v| v.to_str()).unwrap_or_default();
        if !path.is_dir() || rel_name.starts_with('_') {
            continue;
        }
        let watcher_yml = path.join("watcher.yml");
        if !watcher_yml.is_file() {
            continue;
        }
        let watcher = read_yaml_value(&watcher_yml)?;
        let health = read_optional_json_value(&path.join("state/health.json"))?;
        let suppressions = read_optional_json_value(&path.join("state/suppressions.json"))?;
        items.push(WatcherRecord {
            watcher_id: required_string(&watcher, "watcher_id", &watcher_yml)?,
            path: rel_path(repo_root, &watcher_yml),
            title: string_field(&watcher, "title").unwrap_or_else(|| rel_name.to_string()),
            owner: string_field(&watcher, "owner").unwrap_or_else(|| "unknown".to_string()),
            status: string_field(&watcher, "status").unwrap_or_else(|| "unknown".to_string()),
            health_status: health
                .as_ref()
                .and_then(|value| string_field(value, "status"))
                .unwrap_or_else(|| "unknown".to_string()),
            health_reason: health
                .as_ref()
                .and_then(|value| string_field(value, "reason").or_else(|| string_field(value, "error_reason"))),
            last_evaluated_at: health.as_ref().and_then(|value| string_field(value, "checked_at")),
            suppressed_count: suppressions
                .as_ref()
                .and_then(|value| value.get("suppressed").and_then(|v| v.as_array()).map(|v| v.len()))
                .unwrap_or(0),
        });
    }
    Ok(items)
}

fn load_automations(repo_root: &Path, runtime_dir: &Path) -> Result<Vec<AutomationRecord>> {
    let automations_dir = runtime_dir.join("automations");
    if !automations_dir.is_dir() {
        return Ok(Vec::new());
    }
    let mut items = Vec::new();
    for entry in fs::read_dir(&automations_dir).map_err(|e| io_error("read automations dir", &automations_dir, e))? {
        let entry = entry.map_err(|e| io_error("read automations dir entry", &automations_dir, e))?;
        let path = entry.path();
        let rel_name = path.file_name().and_then(|v| v.to_str()).unwrap_or_default();
        if !path.is_dir() || rel_name.starts_with('_') {
            continue;
        }
        let automation_yml = path.join("automation.yml");
        if !automation_yml.is_file() {
            continue;
        }
        let automation = read_yaml_value(&automation_yml)?;
        let counters = read_optional_json_value(&path.join("state/counters.json"))?;
        let state_status = read_optional_json_value(&path.join("state/status.json"))?;
        items.push(AutomationRecord {
            automation_id: required_string(&automation, "automation_id", &automation_yml)?,
            path: rel_path(repo_root, &automation_yml),
            title: string_field(&automation, "title").unwrap_or_else(|| rel_name.to_string()),
            owner: string_field(&automation, "owner").unwrap_or_else(|| "unknown".to_string()),
            status: string_field(&automation, "status").unwrap_or_else(|| "unknown".to_string()),
            workflow_ref: workflow_ref_string(&automation),
            state_status: state_status.as_ref().and_then(|value| string_field(value, "status")),
            state_reason: state_status
                .as_ref()
                .and_then(|value| string_field(value, "reason").or_else(|| string_field(value, "error_reason"))),
            counters_blocked: counters
                .as_ref()
                .and_then(|value| usize_field(value, "blocked"))
                .unwrap_or(0),
        });
    }
    Ok(items)
}

fn load_missions(repo_root: &Path, missions_dir: &Path) -> Result<Vec<MissionRecord>> {
    if !missions_dir.is_dir() {
        return Ok(Vec::new());
    }
    let mut items = Vec::new();
    for entry in fs::read_dir(&missions_dir).map_err(|e| io_error("read missions dir", &missions_dir, e))? {
        let entry = entry.map_err(|e| io_error("read missions dir entry", &missions_dir, e))?;
        let path = entry.path();
        let rel_name = path.file_name().and_then(|v| v.to_str()).unwrap_or_default();
        if !path.is_dir() || rel_name.starts_with('_') || rel_name == ".archive" {
            continue;
        }
        let mission_yml = path.join("mission.yml");
        if !mission_yml.is_file() {
            continue;
        }
        let mission = read_yaml_value(&mission_yml)?;
        let tasks = read_optional_json_value(&path.join("tasks.json"))?;
        let (blocked_task_count, outstanding_task_count) = count_tasks(tasks.as_ref());
        items.push(MissionRecord {
            mission_id: required_string(&mission, "mission_id", &mission_yml)?,
            path: rel_path(repo_root, &mission_yml),
            title: string_field(&mission, "title").unwrap_or_else(|| rel_name.to_string()),
            status: string_field(&mission, "status").unwrap_or_else(|| "unknown".to_string()),
            owner: string_field(&mission, "owner").unwrap_or_else(|| "unknown".to_string()),
            active_run_ids: string_array_field(&mission, "active_run_ids"),
            blocked_task_count,
            outstanding_task_count,
        });
    }
    Ok(items)
}

fn load_incidents(repo_root: &Path, runtime_dir: &Path) -> Result<Vec<IncidentRecord>> {
    let incidents_dir = runtime_dir.join("incidents");
    if !incidents_dir.is_dir() {
        return Ok(Vec::new());
    }
    let mut items = Vec::new();
    for entry in fs::read_dir(&incidents_dir).map_err(|e| io_error("read incidents dir", &incidents_dir, e))? {
        let entry = entry.map_err(|e| io_error("read incidents dir entry", &incidents_dir, e))?;
        let path = entry.path();
        let rel_name = path.file_name().and_then(|v| v.to_str()).unwrap_or_default();
        if !path.is_dir() || rel_name.starts_with('_') {
            continue;
        }
        let incident_yml = path.join("incident.yml");
        if !incident_yml.is_file() {
            continue;
        }
        let incident = read_yaml_value(&incident_yml)?;
        let timeline_path = path.join("timeline.md");
        items.push(IncidentRecord {
            incident_id: required_string(&incident, "incident_id", &incident_yml)?,
            path: rel_path(repo_root, &incident_yml),
            title: string_field(&incident, "title").unwrap_or_else(|| rel_name.to_string()),
            severity: string_field(&incident, "severity").unwrap_or_else(|| "unknown".to_string()),
            status: string_field(&incident, "status").unwrap_or_else(|| "unknown".to_string()),
            owner: string_field(&incident, "owner").unwrap_or_else(|| "unknown".to_string()),
            summary: string_field(&incident, "summary"),
            linked_run_ids: string_array_field(&incident, "run_ids"),
            last_timeline_update_at: parse_last_timeline_timestamp(&timeline_path).ok().flatten(),
        });
    }
    Ok(items)
}

fn compute_incident_closure_readiness(repo_root: &Path, incident: &IncidentRecord) -> Result<ClosureReadiness> {
    let incident_path = repo_root.join(&incident.path);
    let incident_dir = incident_path.parent().unwrap_or_else(|| Path::new("."));
    let closure_path = incident_dir.join("closure.md");
    let closure_text = if closure_path.is_file() {
        Some(
            fs::read_to_string(&closure_path)
                .map_err(|e| io_error("read incident closure file", &closure_path, e))?,
        )
    } else {
        None
    };

    let mut blockers = Vec::new();
    if incident.linked_run_ids.is_empty() {
        blockers.push("missing linked runs".to_string());
    }
    let Some(closure_text) = closure_text else {
        blockers.push("missing closure.md".to_string());
        return Ok(ClosureReadiness {
            incident_id: incident.incident_id.clone(),
            title: incident.title.clone(),
            severity: incident.severity.clone(),
            status: incident.status.clone(),
            owner: incident.owner.clone(),
            linked_run_ids: incident.linked_run_ids.clone(),
            ready: false,
            blockers,
        });
    };

    if !closure_text.contains("Approval:") {
        blockers.push("missing approval reference".to_string());
    }
    if !closure_text.contains("Remediation Ref:") && !closure_text.contains("Waiver Ref:") {
        blockers.push("missing remediation evidence or waiver".to_string());
    }
    if extract_closure_summary(&closure_text).is_none() {
        blockers.push("missing closure summary".to_string());
    }
    if incident.status == "closed" {
        if !closure_text.contains("Closed By:") {
            blockers.push("missing closed_by evidence".to_string());
        }
        if !closure_text.contains("Closed At:") {
            blockers.push("missing closed_at evidence".to_string());
        }
    } else {
        blockers.push(format!("incident status is `{}`", incident.status));
    }

    Ok(ClosureReadiness {
        incident_id: incident.incident_id.clone(),
        title: incident.title.clone(),
        severity: incident.severity.clone(),
        status: incident.status.clone(),
        owner: incident.owner.clone(),
        linked_run_ids: incident.linked_run_ids.clone(),
        ready: blockers.is_empty(),
        blockers,
    })
}

fn extract_closure_summary(text: &str) -> Option<String> {
    let mut lines = Vec::new();
    let mut in_summary = false;
    for line in text.lines() {
        let trimmed = line.trim();
        if trimmed.starts_with("# Incident Closure") {
            in_summary = true;
            continue;
        }
        if trimmed.starts_with("## Remediation Evidence") {
            break;
        }
        if !in_summary || trimmed.is_empty() || trimmed.starts_with("- Closed") || trimmed.starts_with("- Approval") {
            continue;
        }
        lines.push(trimmed.to_string());
    }
    if lines.is_empty() {
        None
    } else {
        Some(lines.join(" "))
    }
}

fn incident_contains_event(item: &IncidentRecord, event_id: &str, repo_root: &Path) -> bool {
    let incident_file = repo_root.join(&item.path);
    match read_yaml_value(&incident_file) {
        Ok(value) => string_array_field(&value, "event_ids")
            .iter()
            .any(|value| value == event_id),
        Err(_) => false,
    }
}

fn incident_contains_mission(item: &IncidentRecord, mission_id: &str, repo_root: &Path) -> bool {
    let incident_file = repo_root.join(&item.path);
    match read_yaml_value(&incident_file) {
        Ok(value) => string_array_field(&value, "mission_ids")
            .iter()
            .any(|value| value == mission_id),
        Err(_) => false,
    }
}

fn read_event_timestamp(repo_root: &Path, payload_ref: &str) -> Result<Option<String>> {
    let path = resolve_repo_relative(repo_root, payload_ref);
    if !path.is_file() {
        return Ok(None);
    }
    let value = read_json_value(&path)?;
    Ok(string_field(&value, "emitted_at"))
}

fn count_tasks(tasks: Option<&Value>) -> (usize, usize) {
    let mut blocked = 0;
    let mut outstanding = 0;
    let Some(tasks) = tasks else {
        return (0, 0);
    };
    let Some(entries) = tasks.get("tasks").and_then(|value| value.as_array()) else {
        return (0, 0);
    };
    for item in entries {
        let status = item
            .get("status")
            .and_then(|value| value.as_str())
            .unwrap_or("open");
        if status.eq_ignore_ascii_case("blocked") {
            blocked += 1;
            outstanding += 1;
            continue;
        }
        if !matches!(status.to_ascii_lowercase().as_str(), "done" | "completed" | "cancelled") {
            outstanding += 1;
        }
    }
    (blocked, outstanding)
}

fn to_json_value<T: Serialize>(value: &T) -> Result<Value> {
    serde_json::to_value(value).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to serialize orchestration inspection value: {e}"),
        )
    })
}

fn rel_path(repo_root: &Path, path: &Path) -> String {
    path.strip_prefix(repo_root)
        .unwrap_or(path)
        .display()
        .to_string()
}

fn resolve_repo_relative(repo_root: &Path, raw: &str) -> PathBuf {
    let path = PathBuf::from(raw);
    if path.is_absolute() {
        path
    } else {
        repo_root.join(path)
    }
}

fn read_yaml_value(path: &Path) -> Result<Value> {
    let text = fs::read_to_string(path).map_err(|e| io_error("read YAML file", path, e))?;
    let yaml: serde_yaml::Value = serde_yaml::from_str(&text).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to parse YAML {}: {e}", path.display()),
        )
    })?;
    serde_json::to_value(yaml).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to convert YAML {} to JSON value: {e}", path.display()),
        )
    })
}

fn read_optional_json_value(path: &Path) -> Result<Option<Value>> {
    if !path.is_file() {
        return Ok(None);
    }
    read_json_value(path).map(Some)
}

fn read_json_value(path: &Path) -> Result<Value> {
    let text = fs::read_to_string(path).map_err(|e| io_error("read JSON file", path, e))?;
    serde_json::from_str(&text).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to parse JSON {}: {e}", path.display()),
        )
    })
}

fn required_string(value: &Value, key: &str, path: &Path) -> Result<String> {
    string_field(value, key).ok_or_else(|| {
        KernelError::new(
            ErrorCode::Internal,
            format!("{} missing required string field '{}'", path.display(), key),
        )
    })
}

fn string_field(value: &Value, key: &str) -> Option<String> {
    value.get(key).and_then(|item| item.as_str()).map(ToString::to_string)
}

fn workflow_ref_string(value: &Value) -> Option<String> {
    let workflow_group = value
        .get("workflow_ref")
        .and_then(|item| item.get("workflow_group"))
        .and_then(|item| item.as_str())?;
    let workflow_id = value
        .get("workflow_ref")
        .and_then(|item| item.get("workflow_id"))
        .and_then(|item| item.as_str())?;
    Some(format!("{workflow_group}/{workflow_id}"))
}

fn usize_field(value: &Value, key: &str) -> Option<usize> {
    value.get(key).and_then(|item| item.as_u64()).map(|item| item as usize)
}

fn string_array_field(value: &Value, key: &str) -> Vec<String> {
    value.get(key)
        .and_then(|item| item.as_array())
        .map(|items| {
            items.iter()
                .filter_map(|item| item.as_str().map(ToString::to_string))
                .collect::<Vec<_>>()
        })
        .unwrap_or_default()
}

fn parse_last_timeline_timestamp(path: &Path) -> Result<Option<String>> {
    if !path.is_file() {
        return Ok(None);
    }
    let text = fs::read_to_string(path).map_err(|e| io_error("read timeline file", path, e))?;
    for line in text.lines().rev() {
        let trimmed = line.trim();
        if let Some(rest) = trimmed.strip_prefix("- ") {
            if let Some((timestamp, _)) = rest.split_once(": ") {
                if timestamp.contains('T') {
                    return Ok(Some(timestamp.to_string()));
                }
            }
        }
    }
    Ok(None)
}

fn parse_timestamp(raw: &str) -> Option<OffsetDateTime> {
    OffsetDateTime::parse(raw, &Rfc3339).ok()
}

fn now_utc() -> Result<String> {
    OffsetDateTime::now_utc()
        .format(&Rfc3339)
        .map_err(|e| KernelError::new(ErrorCode::Internal, format!("failed to format current timestamp: {e}")))
}

fn io_error(action: &str, path: &Path, error: std::io::Error) -> KernelError {
    KernelError::new(
        ErrorCode::Internal,
        format!("{action} {}: {error}", path.display()),
    )
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    fn temp_root(label: &str) -> PathBuf {
        let root = std::env::temp_dir().join(format!("octon-orch-core-{label}-{}", std::process::id()));
        let _ = fs::remove_dir_all(&root);
        fs::create_dir_all(&root).expect("create temp root");
        root
    }

    fn seed_base(root: &Path) {
        for rel in [
            ".octon/framework/orchestration/runtime/runs/by-surface/workflows",
            ".octon/framework/orchestration/runtime/runs/by-surface/missions",
            ".octon/framework/orchestration/runtime/runs/by-surface/automations",
            ".octon/framework/orchestration/runtime/runs/by-surface/incidents",
            ".octon/framework/orchestration/runtime/queue/pending",
            ".octon/framework/orchestration/runtime/queue/claimed",
            ".octon/framework/orchestration/runtime/queue/retry",
            ".octon/framework/orchestration/runtime/queue/dead-letter",
            ".octon/framework/orchestration/runtime/queue/receipts",
            ".octon/framework/orchestration/runtime/watchers/example/state",
            ".octon/framework/orchestration/runtime/automations/example/state",
            ".octon/instance/orchestration/missions/example/context",
            ".octon/framework/orchestration/runtime/incidents/inc-001",
            ".octon/framework/orchestration/runtime/workflows/example/sample",
            ".octon/state/evidence/decisions/repo/dec-001",
            ".octon/state/evidence/runs/run-001",
            ".octon/framework/orchestration/governance",
        ] {
            fs::create_dir_all(root.join(rel)).expect("create fixture dirs");
        }
        fs::write(
            root.join(".octon/framework/orchestration/runtime/queue/registry.yml"),
            "schema_version: orchestration-queue-registry-v1\n",
        )
        .expect("write queue registry");
        fs::write(
            root.join(".octon/framework/orchestration/runtime/runs/index.yml"),
            "schema_version: orchestration-runs-index-v1\nruns: []\n",
        )
        .expect("write run index");
        fs::write(
            root.join(".octon/framework/orchestration/runtime/incidents/index.yml"),
            "schema_version: orchestration-incidents-index-v1\nincidents: []\n",
        )
        .expect("write incident index");
        fs::write(
            root.join(".octon/instance/orchestration/missions/registry.yml"),
            "schema_version: '1.0'\nactive: []\narchived: []\n",
        )
        .expect("write mission registry");
        fs::write(
            root.join(".octon/framework/orchestration/runtime/watchers/example/watcher.yml"),
            "watcher_id: example\ntitle: Example Watcher\nowner: '@architect'\nstatus: active\n",
        )
        .expect("write watcher");
        fs::write(
            root.join(".octon/framework/orchestration/runtime/watchers/example/state/health.json"),
            "{\n  \"status\": \"healthy\",\n  \"checked_at\": \"2026-03-11T10:00:00Z\"\n}\n",
        )
        .expect("write health");
        fs::write(
            root.join(".octon/framework/orchestration/runtime/watchers/example/state/suppressions.json"),
            "{\n  \"suppressed\": [\"evt-old\"]\n}\n",
        )
        .expect("write suppressions");
        fs::write(
            root.join(".octon/framework/orchestration/runtime/automations/example/automation.yml"),
            "automation_id: example\ntitle: Example Automation\nowner: '@architect'\nstatus: active\nworkflow_ref:\n  workflow_group: example\n  workflow_id: sample\n",
        )
        .expect("write automation");
        fs::write(
            root.join(".octon/framework/orchestration/runtime/automations/example/state/counters.json"),
            "{\n  \"blocked\": 2\n}\n",
        )
        .expect("write counters");
        fs::write(
            root.join(".octon/framework/orchestration/runtime/automations/example/state/status.json"),
            "{\n  \"status\": \"active\"\n}\n",
        )
        .expect("write automation status");
        fs::write(
            root.join(".octon/instance/orchestration/missions/example/mission.yml"),
            "schema_version: mission-object-v1\nmission_id: example\ntitle: Example Mission\nsummary: Example mission.\nstatus: active\nowner: '@architect'\ncreated_at: '2026-03-10T00:00:00Z'\nactive_run_ids:\n  - run-001\n",
        )
        .expect("write mission");
        fs::write(
            root.join(".octon/instance/orchestration/missions/example/tasks.json"),
            "{\n  \"tasks\": [\n    {\"id\": \"t1\", \"status\": \"blocked\"},\n    {\"id\": \"t2\", \"status\": \"open\"},\n    {\"id\": \"t3\", \"status\": \"done\"}\n  ]\n}\n",
        )
        .expect("write tasks");
        fs::write(
            root.join(".octon/state/evidence/decisions/repo/dec-001/decision.json"),
            "{\n  \"decision_id\": \"dec-001\",\n  \"outcome\": \"allow\",\n  \"surface\": \"automations\",\n  \"action\": \"launch\",\n  \"actor\": \"example\",\n  \"summary\": \"Allowed.\",\n  \"run_id\": \"run-001\",\n  \"automation_id\": \"example\",\n  \"event_id\": \"evt-001\",\n  \"queue_item_id\": \"q-001\",\n  \"workflow_ref\": {\"workflow_group\": \"example\", \"workflow_id\": \"sample\"}\n}\n",
        )
        .expect("write decision");
        fs::write(
            root.join(".octon/framework/orchestration/runtime/runs/run-001.yml"),
            "run_id: run-001\nstatus: running\nstarted_at: '2026-03-11T10:10:00Z'\ndecision_id: dec-001\ncontinuity_run_path: '.octon/state/evidence/runs/run-001/'\nsummary: Example run\nexecutor_id: exec-1\nexecutor_acknowledged_at: '2026-03-11T10:10:01Z'\nlast_heartbeat_at: '2026-03-11T10:15:00Z'\nlease_expires_at: '2099-03-11T10:20:00Z'\nrecovery_status: healthy\nworkflow_ref:\n  workflow_group: example\n  workflow_id: sample\nautomation_id: example\nmission_id: example\nincident_id: inc-001\nqueue_item_id: q-001\nevent_id: evt-001\n",
        )
        .expect("write run");
        fs::write(
            root.join(".octon/framework/orchestration/runtime/queue/pending/q-001.json"),
            "{\n  \"queue_item_id\": \"q-001\",\n  \"target_automation_id\": \"example\",\n  \"status\": \"pending\",\n  \"summary\": \"Queued.\",\n  \"event_id\": \"evt-001\",\n  \"watcher_id\": \"example\",\n  \"payload_ref\": \"/tmp/octon-orch-event.json\",\n  \"enqueued_at\": \"2026-03-11T10:05:00Z\",\n  \"available_at\": \"2026-03-11T10:05:00Z\"\n}\n",
        )
        .expect("write queue item");
        fs::write(
            Path::new("/tmp/octon-orch-event.json"),
            "{\n  \"event_id\": \"evt-001\",\n  \"emitted_at\": \"2026-03-11T10:04:00Z\"\n}\n",
        )
        .expect("write event");
        fs::write(
            root.join(".octon/framework/orchestration/runtime/queue/receipts/q-001-ack-20260311T101600Z.json"),
            "{\n  \"queue_item_id\": \"q-001\",\n  \"handled_at\": \"2026-03-11T10:16:00Z\"\n}\n",
        )
        .expect("write receipt");
        fs::write(
            root.join(".octon/framework/orchestration/runtime/incidents/inc-001/incident.yml"),
            "incident_id: inc-001\ntitle: Example Incident\nseverity: sev2\nstatus: closed\nowner: '@architect'\nsummary: Incident summary\nrun_ids:\n  - run-001\n",
        )
        .expect("write incident");
        fs::write(
            root.join(".octon/framework/orchestration/runtime/incidents/inc-001/timeline.md"),
            "# Incident Timeline: inc-001\n\n- 2026-03-11T10:20:00Z: incident updated\n",
        )
        .expect("write timeline");
        fs::write(
            root.join(".octon/framework/orchestration/runtime/incidents/inc-001/closure.md"),
            "# Incident Closure: inc-001\n\n- Closed At: `2026-03-11T10:30:00Z`\n- Closed By: `@architect`\n- Approval: `appr-001`\n\nClosed with evidence.\n\n## Remediation Evidence\n\n- Remediation Ref: `run:run-001`\n",
        )
        .expect("write closure");
        fs::write(
            root.join(".octon/framework/orchestration/runtime/workflows/example/sample/workflow.yml"),
            "schema_version: workflow-contract-v2\nname: sample\ndescription: Example workflow.\nversion: 1.0.0\nentry_mode: human\nexecution_profile: core\nstages: []\ndone_gate:\n  checks: []\n",
        )
        .expect("write workflow");
    }

    #[test]
    fn lookup_resolves_run_and_event_lineage() {
        let root = temp_root("lookup");
        seed_base(&root);
        let inspector = OrchestrationInspector::from_repo_root(&root).expect("load inspector");

        let run_lookup = inspector
            .lookup(LookupQuery::RunId("run-001".to_string()))
            .expect("run lookup should succeed");
        assert!(run_lookup.artifacts.iter().any(|item| item.kind == "decision" && item.id == "dec-001"));
        assert!(run_lookup.artifacts.iter().any(|item| item.kind == "queue_item" && item.id == "q-001"));
        assert!(run_lookup.artifacts.iter().any(|item| item.kind == "continuity_run" && item.id == "run-001"));

        let event_lookup = inspector
            .lookup(LookupQuery::EventId("evt-001".to_string()))
            .expect("event lookup should succeed");
        assert!(event_lookup.artifacts.iter().any(|item| item.kind == "run" && item.id == "run-001"));
        assert!(event_lookup.artifacts.iter().any(|item| item.kind == "queue_item" && item.id == "q-001"));

        let _ = fs::remove_file("/tmp/octon-orch-event.json");
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn snapshot_reports_surface_health() {
        let root = temp_root("snapshot");
        seed_base(&root);
        let inspector = OrchestrationInspector::from_repo_root(&root).expect("load inspector");
        let snapshot = inspector.snapshot().expect("snapshot should succeed");

        assert_eq!(snapshot.overview.queue_pending_count, 1);
        assert_eq!(snapshot.overview.running_run_count, 1);
        assert_eq!(snapshot.watchers[0].suppressed_count, 1);
        assert_eq!(snapshot.automations[0].suppression_count, 2);
        assert_eq!(snapshot.missions[0].blocked_task_count, 1);
        assert_eq!(snapshot.incidents[0].closure_ready, true);
        assert_eq!(
            snapshot.incidents[0].last_timeline_update_at.as_deref(),
            Some("2026-03-11T10:20:00Z")
        );

        let _ = fs::remove_file("/tmp/octon-orch-event.json");
        fs::remove_dir_all(root).ok();
    }

    #[test]
    fn incident_closure_readiness_reports_missing_evidence() {
        let root = temp_root("closure");
        seed_base(&root);
        fs::write(
            root.join(".octon/framework/orchestration/runtime/incidents/inc-001/incident.yml"),
            "incident_id: inc-001\ntitle: Example Incident\nseverity: sev2\nstatus: open\nowner: '@architect'\nsummary: Incident summary\n",
        )
        .expect("rewrite incident");
        fs::remove_file(root.join(".octon/framework/orchestration/runtime/incidents/inc-001/closure.md"))
            .expect("remove closure");
        let inspector = OrchestrationInspector::from_repo_root(&root).expect("load inspector");
        let readiness = inspector
            .incident_closure_readiness("inc-001")
            .expect("closure readiness should succeed");

        assert!(!readiness.ready);
        assert!(readiness.blockers.iter().any(|item| item == "missing linked runs"));
        assert!(readiness.blockers.iter().any(|item| item == "missing closure.md"));

        let _ = fs::remove_file("/tmp/octon-orch-event.json");
        fs::remove_dir_all(root).ok();
    }
}
