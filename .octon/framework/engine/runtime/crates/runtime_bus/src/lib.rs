use serde::{Deserialize, Serialize};
use serde_json::Value;
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;
use std::fs::{self, OpenOptions};
use std::io::Write;
use std::path::{Component, Path, PathBuf};
use thiserror::Error;

const RUN_EVENT_SCHEMA_REF: &str =
    ".octon/framework/constitution/contracts/runtime/run-event-v2.schema.json";
const RUNTIME_STATE_SCHEMA_REF: &str =
    ".octon/framework/constitution/contracts/runtime/runtime-state-v2.schema.json";
const STATE_RECONSTRUCTION_REF: &str =
    ".octon/framework/constitution/contracts/runtime/state-reconstruction-v2.md";

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct JournalActor {
    pub actor_class: String,
    pub actor_ref: String,
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct JournalCausality {
    #[serde(default)]
    pub causal_parent_event_ids: Vec<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub command_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub correlation_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub idempotency_key: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct JournalClassification {
    pub event_plane: String,
    pub replay_disposition: String,
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct JournalLifecycle {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub state_before: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub state_after: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct JournalGoverningRefs {
    pub run_contract_ref: String,
    pub run_manifest_ref: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub execution_request_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub authority_route_receipt_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub grant_bundle_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub policy_receipt_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub approval_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub lease_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub revocation_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub support_target_tuple_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub rollback_plan_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub rollback_posture_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub context_pack_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub stage_attempt_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub checkpoint_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub validator_result_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub evidence_snapshot_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub disclosure_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub drift_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub continuity_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub additional_refs: Vec<String>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct JournalPayload {
    pub payload_kind: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub schema_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub typed_body: Option<Value>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub artifact_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub artifact_hash: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub content_type: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub summary: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct JournalEffect {
    pub effect_class: String,
    pub reversibility_class: String,
    pub evidence_class: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct JournalRedaction {
    pub redacted: bool,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub justification: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub lineage_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub omitted_fields: Vec<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct JournalIntegrity {
    pub hash_algorithm: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub previous_event_hash: Option<String>,
    pub event_hash: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct RunJournalEvent {
    pub schema_version: String,
    pub event_id: String,
    pub run_id: String,
    pub sequence: u64,
    pub event_type: String,
    pub recorded_at: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub subject_ref: Option<String>,
    pub actor: JournalActor,
    pub causality: JournalCausality,
    pub classification: JournalClassification,
    pub lifecycle: JournalLifecycle,
    pub governing_refs: JournalGoverningRefs,
    pub payload: JournalPayload,
    pub effect: JournalEffect,
    pub redaction: JournalRedaction,
    pub integrity: JournalIntegrity,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct JournalEventRef {
    pub event_id: String,
    pub sequence: u64,
    pub event_hash: String,
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct RunJournalSnapshotRefs {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub control_snapshot_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub evidence_snapshot_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub evidence_manifest_snapshot_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub redaction_record_ref: Option<String>,
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct RunJournalMaterialization {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub runtime_state_ref: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub last_applied_event_id: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub last_applied_sequence: Option<u64>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub last_applied_event_hash: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub materialized_at: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub materialized_by_ref: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct JournalHashChain {
    pub hash_algorithm: String,
    pub chain_status: String,
    pub head_event_hash: String,
    pub tail_event_hash: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct RunJournalLedgerManifest {
    pub schema_version: String,
    pub run_id: String,
    pub ledger_ref: String,
    pub manifest_ref: String,
    pub event_schema_ref: String,
    pub runtime_state_schema_ref: String,
    pub state_reconstruction_ref: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub ledger_digest: Option<String>,
    pub event_count: u64,
    pub first_event_ref: JournalEventRef,
    pub last_event_ref: JournalEventRef,
    pub hash_chain: JournalHashChain,
    #[serde(default, skip_serializing_if = "BTreeMap::is_empty")]
    pub governing_event_refs: BTreeMap<String, String>,
    pub snapshot_refs: RunJournalSnapshotRefs,
    pub last_materialization: RunJournalMaterialization,
    pub drift_status: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub drift_ref: Option<String>,
    pub updated_at: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct RunJournalAppendRequest {
    pub run_id: String,
    pub control_root_ref: String,
    pub event_id: String,
    pub event_type: String,
    pub recorded_at: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub subject_ref: Option<String>,
    pub actor: JournalActor,
    pub classification: JournalClassification,
    pub lifecycle: JournalLifecycle,
    pub governing_refs: JournalGoverningRefs,
    pub payload: JournalPayload,
    pub effect: JournalEffect,
    pub redaction: JournalRedaction,
    #[serde(default)]
    pub causality: JournalCausality,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub governing_manifest_roles: Vec<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub materialization: Option<RunJournalMaterialization>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub snapshot_refs: Option<RunJournalSnapshotRefs>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub drift_status: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub drift_ref: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct RunJournalAppendReceipt {
    pub ledger_path: PathBuf,
    pub manifest_path: PathBuf,
    pub event: RunJournalEvent,
    pub manifest: RunJournalLedgerManifest,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct RunJournalDocument {
    pub ledger_path: PathBuf,
    pub manifest_path: PathBuf,
    pub events: Vec<RunJournalEvent>,
    pub manifest: RunJournalLedgerManifest,
}

#[derive(Debug, Error)]
pub enum RuntimeBusError {
    #[error("run journal is missing for {run_id}")]
    MissingJournal { run_id: String },
    #[error("failed to read {path}: {source}")]
    Read {
        path: PathBuf,
        #[source]
        source: std::io::Error,
    },
    #[error("failed to write {path}: {source}")]
    Write {
        path: PathBuf,
        #[source]
        source: std::io::Error,
    },
    #[error("failed to parse JSON event line in {path}: {source}")]
    ParseEvent {
        path: PathBuf,
        #[source]
        source: serde_json::Error,
    },
    #[error("failed to parse YAML manifest in {path}: {source}")]
    ParseManifest {
        path: PathBuf,
        #[source]
        source: serde_yaml::Error,
    },
    #[error("failed to serialize event {event_id}: {source}")]
    SerializeEvent {
        event_id: String,
        #[source]
        source: serde_json::Error,
    },
    #[error("failed to serialize manifest for {run_id}: {source}")]
    SerializeManifest {
        run_id: String,
        #[source]
        source: serde_yaml::Error,
    },
    #[error("journal sequence drift for {run_id}: expected {expected}, found {found}")]
    SequenceDrift {
        run_id: String,
        expected: u64,
        found: u64,
    },
    #[error("journal hash drift for event {event_id}: expected {expected}, found {found:?}")]
    HashDrift {
        event_id: String,
        expected: String,
        found: Option<String>,
    },
    #[error("journal event hash mismatch for {event_id}: expected {expected}, found {found}")]
    EventHashMismatch {
        event_id: String,
        expected: String,
        found: String,
    },
    #[error("append request for {run_id} has an invalid control root ref: {control_root_ref}")]
    InvalidControlRootRef {
        run_id: String,
        control_root_ref: String,
    },
    #[error("run lifecycle state is invalid for {run_id} event {event_id}: {state}")]
    InvalidLifecycleState {
        run_id: String,
        event_id: String,
        state: String,
    },
    #[error("run lifecycle state_before mismatch for {run_id} event {event_id}: expected {expected}, found {found}")]
    LifecycleStateMismatch {
        run_id: String,
        event_id: String,
        expected: String,
        found: String,
    },
    #[error("illegal run lifecycle transition for {run_id} event {event_id}: {before} -> {after}")]
    IllegalLifecycleTransition {
        run_id: String,
        event_id: String,
        before: String,
        after: String,
    },
    #[error("run lifecycle transition for {run_id} event {event_id} is missing required refs: {missing}")]
    MissingLifecycleRefs {
        run_id: String,
        event_id: String,
        missing: String,
    },
    #[error("run lifecycle governing ref for {run_id} event {event_id} uses non-authority root {role}: {reference}")]
    NonAuthoritativeLifecycleRef {
        run_id: String,
        event_id: String,
        role: String,
        reference: String,
    },
    #[error(
        "run lifecycle artifact for {run_id} event {event_id} is invalid: {artifact} ({reason})"
    )]
    InvalidLifecycleArtifact {
        run_id: String,
        event_id: String,
        artifact: String,
        reason: String,
    },
    #[error("failed to serialize {subject} for hashing: {source}")]
    HashSerialization {
        subject: &'static str,
        #[source]
        source: serde_json::Error,
    },
}

pub fn append_event(
    control_root: &Path,
    request: RunJournalAppendRequest,
) -> Result<RunJournalAppendReceipt, RuntimeBusError> {
    let ledger_path = control_root.join("events.ndjson");
    let manifest_path = control_root.join("events.manifest.yml");
    let mut existing = if ledger_path.is_file() {
        load_journal(control_root)?
    } else {
        RunJournalDocument {
            ledger_path: ledger_path.clone(),
            manifest_path: manifest_path.clone(),
            events: Vec::new(),
            manifest: empty_manifest(&request)?,
        }
    };

    validate_existing_document(&existing)?;
    validate_lifecycle_append(control_root, &existing.events, &request)?;

    let sequence = existing
        .events
        .last()
        .map(|event| event.sequence + 1)
        .unwrap_or(1);
    let previous_event_hash = existing
        .events
        .last()
        .map(|event| event.integrity.event_hash.clone());
    let mut causality = request.causality.clone();
    if causality.causal_parent_event_ids.is_empty() {
        if let Some(parent) = existing.events.last() {
            causality
                .causal_parent_event_ids
                .push(parent.event_id.clone());
        }
    }

    let event = seal_event(&request, sequence, previous_event_hash, causality)?;
    existing.events.push(event.clone());
    existing.manifest = rebuild_manifest(&request, &existing.events, &existing.manifest)?;

    write_event(&ledger_path, &event)?;
    write_manifest(&manifest_path, &existing.manifest)?;

    Ok(RunJournalAppendReceipt {
        ledger_path,
        manifest_path,
        event,
        manifest: existing.manifest,
    })
}

pub fn load_journal(control_root: &Path) -> Result<RunJournalDocument, RuntimeBusError> {
    let ledger_path = control_root.join("events.ndjson");
    let manifest_path = control_root.join("events.manifest.yml");

    if !ledger_path.is_file() || !manifest_path.is_file() {
        return Err(RuntimeBusError::MissingJournal {
            run_id: control_root
                .file_name()
                .and_then(|value| value.to_str())
                .unwrap_or_default()
                .to_string(),
        });
    }

    let raw_events = fs::read_to_string(&ledger_path).map_err(|source| RuntimeBusError::Read {
        path: ledger_path.clone(),
        source,
    })?;
    let mut events = Vec::new();
    for line in raw_events.lines().filter(|line| !line.trim().is_empty()) {
        events.push(
            serde_json::from_str::<RunJournalEvent>(line).map_err(|source| {
                RuntimeBusError::ParseEvent {
                    path: ledger_path.clone(),
                    source,
                }
            })?,
        );
    }

    let raw_manifest =
        fs::read_to_string(&manifest_path).map_err(|source| RuntimeBusError::Read {
            path: manifest_path.clone(),
            source,
        })?;
    let manifest =
        serde_yaml::from_str::<RunJournalLedgerManifest>(&raw_manifest).map_err(|source| {
            RuntimeBusError::ParseManifest {
                path: manifest_path.clone(),
                source,
            }
        })?;

    let document = RunJournalDocument {
        ledger_path,
        manifest_path,
        events,
        manifest,
    };
    validate_existing_document(&document)?;
    Ok(document)
}

pub fn update_snapshot_refs(
    control_root: &Path,
    snapshot_refs: RunJournalSnapshotRefs,
    updated_at: impl Into<String>,
) -> Result<RunJournalLedgerManifest, RuntimeBusError> {
    let document = load_journal(control_root)?;
    validate_existing_document(&document)?;

    let mut manifest = document.manifest;
    manifest.snapshot_refs = snapshot_refs;
    manifest.updated_at = updated_at.into();
    write_manifest(&document.manifest_path, &manifest)?;
    Ok(manifest)
}

fn validate_existing_document(document: &RunJournalDocument) -> Result<(), RuntimeBusError> {
    let mut expected_sequence = 1_u64;
    let mut previous_event_hash: Option<String> = None;

    for event in &document.events {
        if event.sequence != expected_sequence {
            return Err(RuntimeBusError::SequenceDrift {
                run_id: event.run_id.clone(),
                expected: expected_sequence,
                found: event.sequence,
            });
        }

        let expected_previous = previous_event_hash.clone();
        if event.integrity.previous_event_hash != expected_previous {
            return Err(RuntimeBusError::HashDrift {
                event_id: event.event_id.clone(),
                expected: expected_previous.unwrap_or_else(|| "<genesis>".to_string()),
                found: event.integrity.previous_event_hash.clone(),
            });
        }

        let expected_hash = digest_event(event)?;
        if event.integrity.event_hash != expected_hash {
            return Err(RuntimeBusError::EventHashMismatch {
                event_id: event.event_id.clone(),
                expected: expected_hash,
                found: event.integrity.event_hash.clone(),
            });
        }

        previous_event_hash = Some(event.integrity.event_hash.clone());
        expected_sequence += 1;
    }

    validate_lifecycle_event_sequence(&document.events, document.ledger_path.parent(), false)?;

    Ok(())
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum RunLifecycleState {
    Draft,
    Bound,
    Authorized,
    Running,
    Paused,
    Staged,
    Revoked,
    Failed,
    RolledBack,
    Succeeded,
    Denied,
    Closed,
}

impl RunLifecycleState {
    fn as_str(self) -> &'static str {
        match self {
            Self::Draft => "draft",
            Self::Bound => "bound",
            Self::Authorized => "authorized",
            Self::Running => "running",
            Self::Paused => "paused",
            Self::Staged => "staged",
            Self::Revoked => "revoked",
            Self::Failed => "failed",
            Self::RolledBack => "rolled_back",
            Self::Succeeded => "succeeded",
            Self::Denied => "denied",
            Self::Closed => "closed",
        }
    }

    fn parse(value: &str) -> Option<Self> {
        match value {
            "draft" => Some(Self::Draft),
            "bound" => Some(Self::Bound),
            "authorized" => Some(Self::Authorized),
            "running" => Some(Self::Running),
            "paused" => Some(Self::Paused),
            "staged" => Some(Self::Staged),
            "revoked" => Some(Self::Revoked),
            "failed" => Some(Self::Failed),
            "rolled_back" => Some(Self::RolledBack),
            "succeeded" => Some(Self::Succeeded),
            "denied" => Some(Self::Denied),
            "closed" => Some(Self::Closed),
            _ => None,
        }
    }
}

fn validate_lifecycle_append(
    control_root: &Path,
    existing_events: &[RunJournalEvent],
    request: &RunJournalAppendRequest,
) -> Result<(), RuntimeBusError> {
    let current = validate_lifecycle_event_sequence(existing_events, Some(control_root), false)?;
    validate_lifecycle_transition_for_fields(
        Some(control_root),
        &request.run_id,
        &request.event_id,
        &request.event_type,
        request.lifecycle.state_before.as_deref(),
        request.lifecycle.state_after.as_deref(),
        &request.governing_refs,
        request.subject_ref.as_deref(),
        current,
        true,
    )?;
    Ok(())
}

fn validate_lifecycle_event_sequence(
    events: &[RunJournalEvent],
    control_root: Option<&Path>,
    strict_artifacts: bool,
) -> Result<RunLifecycleState, RuntimeBusError> {
    let mut current = RunLifecycleState::Draft;
    for event in events {
        current = validate_lifecycle_transition_for_fields(
            control_root,
            &event.run_id,
            &event.event_id,
            &event.event_type,
            event.lifecycle.state_before.as_deref(),
            event.lifecycle.state_after.as_deref(),
            &event.governing_refs,
            event.subject_ref.as_deref(),
            current,
            strict_artifacts,
        )?;
    }
    Ok(current)
}

fn validate_lifecycle_transition_for_fields(
    control_root: Option<&Path>,
    run_id: &str,
    event_id: &str,
    event_type: &str,
    state_before: Option<&str>,
    state_after: Option<&str>,
    refs: &JournalGoverningRefs,
    subject_ref: Option<&str>,
    current_state: RunLifecycleState,
    strict_artifacts: bool,
) -> Result<RunLifecycleState, RuntimeBusError> {
    let before = match state_before {
        Some(value) => parse_lifecycle_state(run_id, event_id, value)?,
        None => current_state,
    };
    let after = match state_after {
        Some(value) => parse_lifecycle_state(run_id, event_id, value)?,
        None => before,
    };

    if before != current_state {
        return Err(RuntimeBusError::LifecycleStateMismatch {
            run_id: run_id.to_string(),
            event_id: event_id.to_string(),
            expected: current_state.as_str().to_string(),
            found: before.as_str().to_string(),
        });
    }
    if !is_allowed_lifecycle_transition(before, after) {
        return Err(RuntimeBusError::IllegalLifecycleTransition {
            run_id: run_id.to_string(),
            event_id: event_id.to_string(),
            before: before.as_str().to_string(),
            after: after.as_str().to_string(),
        });
    }

    validate_lifecycle_ref_boundaries(control_root, run_id, event_id, refs)?;
    validate_lifecycle_required_refs(
        control_root,
        run_id,
        event_id,
        event_type,
        refs,
        subject_ref,
        before,
        after,
        strict_artifacts,
    )?;
    Ok(after)
}

fn parse_lifecycle_state(
    run_id: &str,
    event_id: &str,
    value: &str,
) -> Result<RunLifecycleState, RuntimeBusError> {
    RunLifecycleState::parse(value).ok_or_else(|| RuntimeBusError::InvalidLifecycleState {
        run_id: run_id.to_string(),
        event_id: event_id.to_string(),
        state: value.to_string(),
    })
}

fn is_allowed_lifecycle_transition(before: RunLifecycleState, after: RunLifecycleState) -> bool {
    if before == after && before != RunLifecycleState::Closed {
        return true;
    }
    match before {
        RunLifecycleState::Draft => {
            matches!(after, RunLifecycleState::Bound | RunLifecycleState::Denied)
        }
        RunLifecycleState::Bound => matches!(
            after,
            RunLifecycleState::Authorized | RunLifecycleState::Staged | RunLifecycleState::Denied
        ),
        RunLifecycleState::Authorized => matches!(
            after,
            RunLifecycleState::Running
                | RunLifecycleState::Staged
                | RunLifecycleState::Revoked
                | RunLifecycleState::Denied
        ),
        RunLifecycleState::Running => matches!(
            after,
            RunLifecycleState::Paused
                | RunLifecycleState::Failed
                | RunLifecycleState::Revoked
                | RunLifecycleState::Succeeded
                | RunLifecycleState::Staged
        ),
        RunLifecycleState::Paused => matches!(
            after,
            RunLifecycleState::Running | RunLifecycleState::Revoked | RunLifecycleState::Failed
        ),
        RunLifecycleState::Staged => matches!(
            after,
            RunLifecycleState::Authorized | RunLifecycleState::Revoked | RunLifecycleState::Closed
        ),
        RunLifecycleState::Revoked => {
            matches!(
                after,
                RunLifecycleState::RolledBack | RunLifecycleState::Closed
            )
        }
        RunLifecycleState::Failed => {
            matches!(
                after,
                RunLifecycleState::RolledBack | RunLifecycleState::Closed
            )
        }
        RunLifecycleState::RolledBack => matches!(after, RunLifecycleState::Closed),
        RunLifecycleState::Succeeded => matches!(after, RunLifecycleState::Closed),
        RunLifecycleState::Denied => matches!(after, RunLifecycleState::Closed),
        RunLifecycleState::Closed => false,
    }
}

fn validate_lifecycle_ref_boundaries(
    control_root: Option<&Path>,
    run_id: &str,
    event_id: &str,
    refs: &JournalGoverningRefs,
) -> Result<(), RuntimeBusError> {
    let repo_root = control_root.and_then(discover_repo_root);
    for (role, reference) in lifecycle_ref_values(refs) {
        let Some(normalized) =
            normalize_lifecycle_ref(repo_root.as_deref(), reference).map_err(|reference| {
                RuntimeBusError::NonAuthoritativeLifecycleRef {
                    run_id: run_id.to_string(),
                    event_id: event_id.to_string(),
                    role: role.to_string(),
                    reference,
                }
            })?
        else {
            continue;
        };
        if normalized.starts_with(".octon/generated/") || normalized.starts_with(".octon/inputs/") {
            return Err(RuntimeBusError::NonAuthoritativeLifecycleRef {
                run_id: run_id.to_string(),
                event_id: event_id.to_string(),
                role: role.to_string(),
                reference: reference.to_string(),
            });
        }
    }
    Ok(())
}

fn validate_lifecycle_required_refs(
    control_root: Option<&Path>,
    run_id: &str,
    event_id: &str,
    event_type: &str,
    refs: &JournalGoverningRefs,
    subject_ref: Option<&str>,
    before: RunLifecycleState,
    after: RunLifecycleState,
    strict_artifacts: bool,
) -> Result<(), RuntimeBusError> {
    let mut missing = Vec::new();

    require_nonempty(&refs.run_contract_ref, "run_contract_ref", &mut missing);
    require_nonempty(&refs.run_manifest_ref, "run_manifest_ref", &mut missing);

    if before == after {
        match event_type {
            "checkpoint-created" => {
                require_optional(&refs.checkpoint_ref, "checkpoint_ref", &mut missing);
            }
            "context-pack-requested" | "context-pack-built" | "context-pack-bound" => {
                require_optional(&refs.context_pack_ref, "context_pack_ref", &mut missing);
                require_optional(
                    &refs.evidence_snapshot_ref,
                    "context_pack_receipt_ref",
                    &mut missing,
                );
            }
            "capability-authorized" | "capability-invoked" => {
                require_optional(&refs.grant_bundle_ref, "grant_bundle_ref", &mut missing);
                require_optional(&refs.stage_attempt_ref, "stage_attempt_ref", &mut missing);
            }
            event if event.starts_with("effect-token-") => {
                require_optional(&refs.grant_bundle_ref, "grant_bundle_ref", &mut missing);
                require_optional(&refs.context_pack_ref, "context_pack_ref", &mut missing);
            }
            "run-card-published" => {
                require_optional(&refs.disclosure_ref, "disclosure_ref", &mut missing);
            }
            "evidence-snapshot-created" => {
                require_optional(
                    &refs.evidence_snapshot_ref,
                    "evidence_snapshot_ref",
                    &mut missing,
                );
            }
            _ => {}
        }
    } else {
        match after {
            RunLifecycleState::Bound => {
                require_optional(
                    &refs.rollback_posture_ref,
                    "rollback_posture_ref",
                    &mut missing,
                );
            }
            RunLifecycleState::Authorized => {
                require_optional(
                    &refs.authority_route_receipt_ref,
                    "authority_route_receipt_ref",
                    &mut missing,
                );
                require_optional(&refs.grant_bundle_ref, "grant_bundle_ref", &mut missing);
                require_optional(&refs.context_pack_ref, "context_pack_ref", &mut missing);
                require_optional(
                    &refs.support_target_tuple_ref,
                    "support_target_tuple_ref",
                    &mut missing,
                );
            }
            RunLifecycleState::Running => {
                require_optional(&refs.grant_bundle_ref, "grant_bundle_ref", &mut missing);
                require_optional(&refs.stage_attempt_ref, "stage_attempt_ref", &mut missing);
            }
            RunLifecycleState::Paused => {
                require_optional(&refs.checkpoint_ref, "checkpoint_ref", &mut missing);
            }
            RunLifecycleState::Staged => {
                require_optional(
                    &refs.authority_route_receipt_ref,
                    "authority_route_receipt_ref",
                    &mut missing,
                );
            }
            RunLifecycleState::Revoked => {
                require_optional(&refs.revocation_ref, "revocation_ref", &mut missing);
                require_optional(
                    &refs.rollback_posture_ref,
                    "rollback_posture_ref",
                    &mut missing,
                );
            }
            RunLifecycleState::Failed => {
                require_subject(subject_ref, "subject_ref", &mut missing);
                require_optional(
                    &refs.rollback_posture_ref,
                    "rollback_posture_ref",
                    &mut missing,
                );
            }
            RunLifecycleState::RolledBack => {
                require_optional(
                    &refs.rollback_posture_ref,
                    "rollback_posture_ref",
                    &mut missing,
                );
                require_optional(&refs.checkpoint_ref, "checkpoint_ref", &mut missing);
            }
            RunLifecycleState::Succeeded => {
                require_subject(subject_ref, "subject_ref", &mut missing);
            }
            RunLifecycleState::Denied => {
                require_optional(
                    &refs.authority_route_receipt_ref,
                    "authority_route_receipt_ref",
                    &mut missing,
                );
            }
            RunLifecycleState::Closed => {
                require_optional(
                    &refs.rollback_posture_ref,
                    "rollback_posture_ref",
                    &mut missing,
                );
                require_optional(
                    &refs.evidence_snapshot_ref,
                    "evidence_snapshot_ref",
                    &mut missing,
                );
                require_optional(&refs.disclosure_ref, "disclosure_ref", &mut missing);
                require_additional_ref(
                    refs,
                    "authority/review-dispositions.yml",
                    "review_dispositions_ref",
                    &mut missing,
                );
                require_additional_ref(
                    refs,
                    "/closeout/evidence-store-completeness.yml",
                    "evidence_store_completeness_ref",
                    &mut missing,
                );
            }
            RunLifecycleState::Draft => {}
        }
    }

    if !missing.is_empty() {
        missing.sort();
        missing.dedup();
        return Err(RuntimeBusError::MissingLifecycleRefs {
            run_id: run_id.to_string(),
            event_id: event_id.to_string(),
            missing: missing.join(", "),
        });
    }

    if strict_artifacts && before != after {
        match after {
            RunLifecycleState::Staged => {
                validate_stage_only_route(control_root, run_id, event_id, refs)?;
            }
            RunLifecycleState::Closed => {
                validate_closeout_completeness(control_root, run_id, event_id, refs)?;
            }
            _ => {}
        }
    }

    Ok(())
}

fn discover_repo_root(path: &Path) -> Option<PathBuf> {
    let mut current = if path.is_dir() {
        path.to_path_buf()
    } else {
        path.parent()?.to_path_buf()
    };
    loop {
        if current.file_name().and_then(|value| value.to_str()) == Some(".octon") {
            let mut root = current.clone();
            while root.file_name().and_then(|value| value.to_str()) == Some(".octon") {
                root = root.parent()?.to_path_buf();
            }
            return Some(root);
        }
        if current.join(".octon").is_dir() {
            return Some(current);
        }
        if !current.pop() {
            return None;
        }
    }
}

fn normalize_lifecycle_ref(
    repo_root: Option<&Path>,
    reference: &str,
) -> Result<Option<String>, String> {
    let path_part = reference.split('#').next().unwrap_or(reference).trim();
    if path_part.is_empty() || path_part.contains("://") {
        return Ok(None);
    }
    let path = Path::new(path_part);
    if path.is_absolute() {
        let normalized = lexical_normalize(path);
        let Some(repo_root) = repo_root else {
            return Err(reference.to_string());
        };
        let repo_root = lexical_normalize(repo_root);
        let relative = normalized
            .strip_prefix(&repo_root)
            .map_err(|_| reference.to_string())?;
        return Ok(Some(path_to_slash(relative)));
    }
    Ok(Some(path_to_slash(&lexical_normalize(path))))
}

fn lexical_normalize(path: &Path) -> PathBuf {
    let mut normalized = PathBuf::new();
    for component in path.components() {
        match component {
            Component::CurDir => {}
            Component::ParentDir => {
                normalized.pop();
            }
            Component::Normal(value) => normalized.push(value),
            Component::RootDir | Component::Prefix(_) => normalized.push(component.as_os_str()),
        }
    }
    normalized
}

fn path_to_slash(path: &Path) -> String {
    path.components()
        .map(|component| component.as_os_str().to_string_lossy())
        .collect::<Vec<_>>()
        .join("/")
}

fn require_repo_root(
    control_root: Option<&Path>,
    run_id: &str,
    event_id: &str,
    key: &str,
) -> Result<PathBuf, RuntimeBusError> {
    control_root
        .and_then(discover_repo_root)
        .ok_or_else(|| RuntimeBusError::MissingLifecycleRefs {
            run_id: run_id.to_string(),
            event_id: event_id.to_string(),
            missing: format!("{key}_repo_root"),
        })
}

fn resolve_required_ref(
    repo_root: &Path,
    run_id: &str,
    event_id: &str,
    reference: &str,
    key: &str,
) -> Result<PathBuf, RuntimeBusError> {
    let path_part = reference.split('#').next().unwrap_or(reference).trim();
    if path_part.is_empty() || path_part.contains("://") {
        return Err(RuntimeBusError::MissingLifecycleRefs {
            run_id: run_id.to_string(),
            event_id: event_id.to_string(),
            missing: key.to_string(),
        });
    }

    let candidate = if Path::new(path_part).is_absolute() {
        let normalized = lexical_normalize(Path::new(path_part));
        let repo_root = lexical_normalize(repo_root);
        normalized.strip_prefix(&repo_root).map_err(|_| {
            RuntimeBusError::NonAuthoritativeLifecycleRef {
                run_id: run_id.to_string(),
                event_id: event_id.to_string(),
                role: key.to_string(),
                reference: reference.to_string(),
            }
        })?;
        normalized
    } else {
        repo_root.join(lexical_normalize(Path::new(path_part)))
    };

    if !candidate.is_file() {
        return Err(RuntimeBusError::MissingLifecycleRefs {
            run_id: run_id.to_string(),
            event_id: event_id.to_string(),
            missing: format!("{key} ({reference})"),
        });
    }
    Ok(candidate)
}

fn read_yaml_artifact(
    run_id: &str,
    event_id: &str,
    artifact: &str,
    path: &Path,
) -> Result<serde_yaml::Value, RuntimeBusError> {
    let raw =
        fs::read_to_string(path).map_err(|error| RuntimeBusError::InvalidLifecycleArtifact {
            run_id: run_id.to_string(),
            event_id: event_id.to_string(),
            artifact: artifact.to_string(),
            reason: format!("failed to read {}: {error}", path.display()),
        })?;
    serde_yaml::from_str(&raw).map_err(|error| RuntimeBusError::InvalidLifecycleArtifact {
        run_id: run_id.to_string(),
        event_id: event_id.to_string(),
        artifact: artifact.to_string(),
        reason: format!("failed to parse {}: {error}", path.display()),
    })
}

fn validate_stage_only_route(
    control_root: Option<&Path>,
    run_id: &str,
    event_id: &str,
    refs: &JournalGoverningRefs,
) -> Result<(), RuntimeBusError> {
    let repo_root = require_repo_root(control_root, run_id, event_id, "stage_only_decision")?;
    let mut inspected_candidate = false;
    for reference in &refs.additional_refs {
        let Some(normalized) =
            normalize_lifecycle_ref(Some(&repo_root), reference).map_err(|reference| {
                RuntimeBusError::NonAuthoritativeLifecycleRef {
                    run_id: run_id.to_string(),
                    event_id: event_id.to_string(),
                    role: "stage_only_decision_ref".to_string(),
                    reference,
                }
            })?
        else {
            continue;
        };
        if !is_stage_only_candidate_ref(&normalized) {
            continue;
        }
        inspected_candidate = true;
        let path = resolve_required_ref(
            &repo_root,
            run_id,
            event_id,
            reference,
            "stage_only_decision_ref",
        )?;
        let artifact = read_yaml_artifact(run_id, event_id, "stage_only_decision_ref", &path)?;
        if yaml_has_stage_only_or_escalation(&artifact) {
            return Ok(());
        }
    }

    Err(RuntimeBusError::MissingLifecycleRefs {
        run_id: run_id.to_string(),
        event_id: event_id.to_string(),
        missing: if inspected_candidate {
            "stage_only_decision_ref(stage_only_or_escalation)".to_string()
        } else {
            "stage_only_decision_ref".to_string()
        },
    })
}

fn is_stage_only_candidate_ref(reference: &str) -> bool {
    reference.contains("stage-only")
        || reference.contains("stage_only")
        || reference.contains("authority-decision")
        || reference.contains("authority/decision")
}

fn yaml_has_stage_only_or_escalation(value: &serde_yaml::Value) -> bool {
    for key in [
        "decision",
        "decision_state",
        "route",
        "posture",
        "routing_posture",
        "status",
    ] {
        if value
            .get(key)
            .and_then(|value| value.as_str())
            .is_some_and(is_stage_only_or_escalation)
        {
            return true;
        }
    }
    false
}

fn is_stage_only_or_escalation(value: &str) -> bool {
    let normalized = value.trim().to_ascii_lowercase().replace(['-', ' '], "_");
    matches!(
        normalized.as_str(),
        "stage_only" | "stageonly" | "escalate" | "escalation" | "stage_only_escalation"
    )
}

fn validate_closeout_completeness(
    control_root: Option<&Path>,
    run_id: &str,
    event_id: &str,
    refs: &JournalGoverningRefs,
) -> Result<(), RuntimeBusError> {
    let control_root = control_root.ok_or_else(|| RuntimeBusError::MissingLifecycleRefs {
        run_id: run_id.to_string(),
        event_id: event_id.to_string(),
        missing: "closeout_control_root".to_string(),
    })?;
    let repo_root = require_repo_root(Some(control_root), run_id, event_id, "closeout")?;

    let rollback_ref = refs.rollback_posture_ref.as_deref().unwrap_or_default();
    resolve_required_ref(
        &repo_root,
        run_id,
        event_id,
        rollback_ref,
        "rollback_posture_ref",
    )?;

    let disclosure_ref = refs.disclosure_ref.as_deref().unwrap_or_default();
    resolve_required_ref(
        &repo_root,
        run_id,
        event_id,
        disclosure_ref,
        "disclosure_ref",
    )?;

    let evidence_snapshot_ref = refs.evidence_snapshot_ref.as_deref().unwrap_or_default();
    let evidence_snapshot_path = resolve_required_ref(
        &repo_root,
        run_id,
        event_id,
        evidence_snapshot_ref,
        "evidence_snapshot_ref",
    )?;

    let review_ref =
        find_additional_ref(refs, "authority/review-dispositions.yml").ok_or_else(|| {
            RuntimeBusError::MissingLifecycleRefs {
                run_id: run_id.to_string(),
                event_id: event_id.to_string(),
                missing: "review_dispositions_ref".to_string(),
            }
        })?;
    let review_path = resolve_required_ref(
        &repo_root,
        run_id,
        event_id,
        review_ref,
        "review_dispositions_ref",
    )?;

    let completeness_ref = find_additional_ref(refs, "evidence-store-completeness.yml")
        .ok_or_else(|| RuntimeBusError::MissingLifecycleRefs {
            run_id: run_id.to_string(),
            event_id: event_id.to_string(),
            missing: "evidence_store_completeness_ref".to_string(),
        })?;
    let completeness_path = resolve_required_ref(
        &repo_root,
        run_id,
        event_id,
        completeness_ref,
        "evidence_store_completeness_ref",
    )?;

    validate_review_dispositions(&repo_root, run_id, event_id, &review_path)?;
    validate_evidence_store_completeness(
        control_root,
        &repo_root,
        run_id,
        event_id,
        &completeness_path,
        evidence_snapshot_ref,
        &evidence_snapshot_path,
    )?;
    Ok(())
}

fn find_additional_ref<'a>(refs: &'a JournalGoverningRefs, needle: &str) -> Option<&'a str> {
    refs.additional_refs
        .iter()
        .find(|reference| reference.contains(needle))
        .map(String::as_str)
}

fn validate_review_dispositions(
    repo_root: &Path,
    run_id: &str,
    event_id: &str,
    review_path: &Path,
) -> Result<(), RuntimeBusError> {
    let value = read_yaml_artifact(run_id, event_id, "review_dispositions_ref", review_path)?;
    let unresolved_review = value
        .get("dispositions")
        .and_then(|value| value.as_sequence())
        .into_iter()
        .flatten()
        .any(|entry| {
            entry
                .get("blocking")
                .and_then(|value| value.as_bool())
                .unwrap_or(false)
                && entry
                    .get("status")
                    .and_then(|value| value.as_str())
                    .is_some_and(|status| status != "resolved")
        });
    if unresolved_review {
        return Err(RuntimeBusError::InvalidLifecycleArtifact {
            run_id: run_id.to_string(),
            event_id: event_id.to_string(),
            artifact: "review_dispositions_ref".to_string(),
            reason: "unresolved blocking review disposition".to_string(),
        });
    }

    let Some(risk) = value.get("risk_disposition") else {
        return Err(RuntimeBusError::InvalidLifecycleArtifact {
            run_id: run_id.to_string(),
            event_id: event_id.to_string(),
            artifact: "risk_disposition".to_string(),
            reason: "missing risk disposition".to_string(),
        });
    };
    let unresolved_risk_count = risk
        .get("unresolved_risk_count")
        .and_then(|value| value.as_i64())
        .unwrap_or(0);
    let risk_status = risk
        .get("status")
        .and_then(|value| value.as_str())
        .unwrap_or_default();
    if unresolved_risk_count > 0 && !matches!(risk_status, "accepted" | "resolved") {
        return Err(RuntimeBusError::InvalidLifecycleArtifact {
            run_id: run_id.to_string(),
            event_id: event_id.to_string(),
            artifact: "risk_disposition".to_string(),
            reason: "unresolved risk disposition".to_string(),
        });
    }

    let retained_ref = format!(".octon/state/evidence/runs/{run_id}/retained-run-evidence.yml");
    resolve_required_ref(
        repo_root,
        run_id,
        event_id,
        &retained_ref,
        "retained_evidence_ref",
    )?;
    Ok(())
}

fn validate_evidence_store_completeness(
    control_root: &Path,
    repo_root: &Path,
    run_id: &str,
    event_id: &str,
    completeness_path: &Path,
    event_evidence_snapshot_ref: &str,
    event_evidence_snapshot_path: &Path,
) -> Result<(), RuntimeBusError> {
    let value = read_yaml_artifact(
        run_id,
        event_id,
        "evidence_store_completeness_ref",
        completeness_path,
    )?;
    if value
        .get("completeness_status")
        .and_then(|value| value.as_str())
        != Some("complete")
    {
        return Err(RuntimeBusError::InvalidLifecycleArtifact {
            run_id: run_id.to_string(),
            event_id: event_id.to_string(),
            artifact: "evidence_store_completeness_ref".to_string(),
            reason: "completeness_status is not complete".to_string(),
        });
    }
    if value
        .get("replay_disclosure_ready")
        .and_then(|value| value.as_bool())
        != Some(true)
    {
        return Err(RuntimeBusError::InvalidLifecycleArtifact {
            run_id: run_id.to_string(),
            event_id: event_id.to_string(),
            artifact: "evidence_store_completeness_ref".to_string(),
            reason: "replay_disclosure_ready is not true".to_string(),
        });
    }

    let journal_snapshot_ref = value
        .get("journal_snapshot_ref")
        .and_then(|value| value.as_str())
        .unwrap_or(event_evidence_snapshot_ref);
    let normalized_event_snapshot =
        normalize_lifecycle_ref(Some(repo_root), event_evidence_snapshot_ref).map_err(
            |reference| RuntimeBusError::NonAuthoritativeLifecycleRef {
                run_id: run_id.to_string(),
                event_id: event_id.to_string(),
                role: "evidence_snapshot_ref".to_string(),
                reference,
            },
        )?;
    let normalized_journal_snapshot =
        normalize_lifecycle_ref(Some(repo_root), journal_snapshot_ref).map_err(|reference| {
            RuntimeBusError::NonAuthoritativeLifecycleRef {
                run_id: run_id.to_string(),
                event_id: event_id.to_string(),
                role: "journal_snapshot_ref".to_string(),
                reference,
            }
        })?;
    if normalized_event_snapshot != normalized_journal_snapshot {
        return Err(RuntimeBusError::InvalidLifecycleArtifact {
            run_id: run_id.to_string(),
            event_id: event_id.to_string(),
            artifact: "journal_snapshot_ref".to_string(),
            reason: "journal snapshot does not match run-closed evidence snapshot ref".to_string(),
        });
    }
    let journal_snapshot_path = resolve_required_ref(
        repo_root,
        run_id,
        event_id,
        journal_snapshot_ref,
        "journal_snapshot_ref",
    )?;
    if journal_snapshot_path != event_evidence_snapshot_path {
        return Err(RuntimeBusError::InvalidLifecycleArtifact {
            run_id: run_id.to_string(),
            event_id: event_id.to_string(),
            artifact: "journal_snapshot_ref".to_string(),
            reason: "journal snapshot path does not match evidence snapshot path".to_string(),
        });
    }

    let evidence_manifest_ref = value
        .get("evidence_manifest_snapshot_ref")
        .and_then(|value| value.as_str())
        .map(str::to_string)
        .unwrap_or_else(|| {
            format!(".octon/state/evidence/runs/{run_id}/run-journal/events.manifest.snapshot.yml")
        });

    for (key, default_ref) in [
        (
            "evidence_manifest_snapshot_ref",
            evidence_manifest_ref.clone(),
        ),
        (
            "rollback_posture_ref",
            format!(".octon/state/control/execution/runs/{run_id}/rollback-posture.yml"),
        ),
        (
            "run_card_ref",
            format!(".octon/state/evidence/disclosure/runs/{run_id}/run-card.yml"),
        ),
        (
            "review_dispositions_ref",
            format!(
                ".octon/state/control/execution/runs/{run_id}/authority/review-dispositions.yml"
            ),
        ),
        (
            "retained_evidence_ref",
            format!(".octon/state/evidence/runs/{run_id}/retained-run-evidence.yml"),
        ),
    ] {
        let reference = value
            .get(key)
            .and_then(|value| value.as_str())
            .unwrap_or(default_ref.as_str());
        resolve_required_ref(repo_root, run_id, event_id, reference, key)?;
    }

    let evidence_manifest_path = resolve_required_ref(
        repo_root,
        run_id,
        event_id,
        &evidence_manifest_ref,
        "evidence_manifest_snapshot_ref",
    )?;
    compare_file_hashes(
        control_root.join("events.ndjson"),
        journal_snapshot_path,
        run_id,
        event_id,
        "journal_snapshot_ref",
    )?;
    compare_file_hashes(
        control_root.join("events.manifest.yml"),
        evidence_manifest_path,
        run_id,
        event_id,
        "evidence_manifest_snapshot_ref",
    )?;
    Ok(())
}

fn compare_file_hashes(
    left: PathBuf,
    right: PathBuf,
    run_id: &str,
    event_id: &str,
    artifact: &str,
) -> Result<(), RuntimeBusError> {
    if sha256_file(&left)? != sha256_file(&right)? {
        return Err(RuntimeBusError::InvalidLifecycleArtifact {
            run_id: run_id.to_string(),
            event_id: event_id.to_string(),
            artifact: artifact.to_string(),
            reason: format!("{} does not hash-match {}", right.display(), left.display()),
        });
    }
    Ok(())
}

fn sha256_file(path: &Path) -> Result<String, RuntimeBusError> {
    let bytes = fs::read(path).map_err(|source| RuntimeBusError::Read {
        path: path.to_path_buf(),
        source,
    })?;
    let mut hasher = Sha256::new();
    hasher.update(&bytes);
    Ok(format!("sha256:{:x}", hasher.finalize()))
}

fn lifecycle_ref_values(refs: &JournalGoverningRefs) -> Vec<(&'static str, &str)> {
    let mut values = vec![
        ("run_contract_ref", refs.run_contract_ref.as_str()),
        ("run_manifest_ref", refs.run_manifest_ref.as_str()),
    ];
    let option_values = [
        (
            "execution_request_ref",
            refs.execution_request_ref.as_deref(),
        ),
        (
            "authority_route_receipt_ref",
            refs.authority_route_receipt_ref.as_deref(),
        ),
        ("grant_bundle_ref", refs.grant_bundle_ref.as_deref()),
        ("policy_receipt_ref", refs.policy_receipt_ref.as_deref()),
        ("approval_ref", refs.approval_ref.as_deref()),
        ("lease_ref", refs.lease_ref.as_deref()),
        ("revocation_ref", refs.revocation_ref.as_deref()),
        (
            "support_target_tuple_ref",
            refs.support_target_tuple_ref.as_deref(),
        ),
        ("rollback_plan_ref", refs.rollback_plan_ref.as_deref()),
        ("rollback_posture_ref", refs.rollback_posture_ref.as_deref()),
        ("context_pack_ref", refs.context_pack_ref.as_deref()),
        ("stage_attempt_ref", refs.stage_attempt_ref.as_deref()),
        ("checkpoint_ref", refs.checkpoint_ref.as_deref()),
        ("validator_result_ref", refs.validator_result_ref.as_deref()),
        (
            "evidence_snapshot_ref",
            refs.evidence_snapshot_ref.as_deref(),
        ),
        ("disclosure_ref", refs.disclosure_ref.as_deref()),
        ("drift_ref", refs.drift_ref.as_deref()),
        ("continuity_ref", refs.continuity_ref.as_deref()),
    ];
    for (role, value) in option_values {
        if let Some(value) = value {
            values.push((role, value));
        }
    }
    for value in &refs.additional_refs {
        values.push(("additional_refs", value.as_str()));
    }
    values
}

fn require_nonempty<'a>(value: &'a str, key: &'a str, missing: &mut Vec<&'a str>) {
    if value.trim().is_empty() {
        missing.push(key);
    }
}

fn require_optional<'a>(value: &'a Option<String>, key: &'a str, missing: &mut Vec<&'a str>) {
    if value.as_deref().unwrap_or_default().trim().is_empty() {
        missing.push(key);
    }
}

fn require_subject<'a>(value: Option<&str>, key: &'a str, missing: &mut Vec<&'a str>) {
    if value.unwrap_or_default().trim().is_empty() {
        missing.push(key);
    }
}

fn require_additional_ref<'a>(
    refs: &JournalGoverningRefs,
    needle: &str,
    key: &'a str,
    missing: &mut Vec<&'a str>,
) {
    if !refs
        .additional_refs
        .iter()
        .any(|reference| reference.contains(needle))
    {
        missing.push(key);
    }
}

fn empty_manifest(
    request: &RunJournalAppendRequest,
) -> Result<RunJournalLedgerManifest, RuntimeBusError> {
    let manifest_ref = join_control_ref(
        &request.control_root_ref,
        "events.manifest.yml",
        &request.run_id,
    )?;
    let ledger_ref = join_control_ref(&request.control_root_ref, "events.ndjson", &request.run_id)?;
    let zero_ref = JournalEventRef {
        event_id: request.event_id.clone(),
        sequence: 1,
        event_hash: "sha256:0000000000000000000000000000000000000000000000000000000000000000"
            .to_string(),
    };
    Ok(RunJournalLedgerManifest {
        schema_version: "run-event-ledger-v2".to_string(),
        run_id: request.run_id.clone(),
        ledger_ref,
        manifest_ref,
        event_schema_ref: RUN_EVENT_SCHEMA_REF.to_string(),
        runtime_state_schema_ref: RUNTIME_STATE_SCHEMA_REF.to_string(),
        state_reconstruction_ref: STATE_RECONSTRUCTION_REF.to_string(),
        ledger_digest: None,
        event_count: 0,
        first_event_ref: zero_ref.clone(),
        last_event_ref: zero_ref,
        hash_chain: JournalHashChain {
            hash_algorithm: "sha256".to_string(),
            chain_status: "verified".to_string(),
            head_event_hash:
                "sha256:0000000000000000000000000000000000000000000000000000000000000000"
                    .to_string(),
            tail_event_hash:
                "sha256:0000000000000000000000000000000000000000000000000000000000000000"
                    .to_string(),
        },
        governing_event_refs: BTreeMap::new(),
        snapshot_refs: RunJournalSnapshotRefs::default(),
        last_materialization: RunJournalMaterialization::default(),
        drift_status: "in-sync".to_string(),
        drift_ref: None,
        updated_at: request.recorded_at.clone(),
    })
}

fn seal_event(
    request: &RunJournalAppendRequest,
    sequence: u64,
    previous_event_hash: Option<String>,
    causality: JournalCausality,
) -> Result<RunJournalEvent, RuntimeBusError> {
    let mut event = RunJournalEvent {
        schema_version: "run-event-v2".to_string(),
        event_id: request.event_id.clone(),
        run_id: request.run_id.clone(),
        sequence,
        event_type: request.event_type.clone(),
        recorded_at: request.recorded_at.clone(),
        subject_ref: request.subject_ref.clone(),
        actor: request.actor.clone(),
        causality,
        classification: request.classification.clone(),
        lifecycle: request.lifecycle.clone(),
        governing_refs: request.governing_refs.clone(),
        payload: request.payload.clone(),
        effect: request.effect.clone(),
        redaction: request.redaction.clone(),
        integrity: JournalIntegrity {
            hash_algorithm: "sha256".to_string(),
            previous_event_hash,
            event_hash: String::new(),
        },
    };
    event.integrity.event_hash = digest_event(&event)?;
    Ok(event)
}

fn rebuild_manifest(
    request: &RunJournalAppendRequest,
    events: &[RunJournalEvent],
    previous_manifest: &RunJournalLedgerManifest,
) -> Result<RunJournalLedgerManifest, RuntimeBusError> {
    let first = events
        .first()
        .expect("append_event always provides an event");
    let last = events
        .last()
        .expect("append_event always provides an event");
    let mut governing_event_refs = previous_manifest.governing_event_refs.clone();
    for role in &request.governing_manifest_roles {
        governing_event_refs.insert(role.clone(), last.event_id.clone());
    }

    let snapshot_refs = request
        .snapshot_refs
        .clone()
        .unwrap_or_else(|| previous_manifest.snapshot_refs.clone());
    let last_materialization =
        request
            .materialization
            .clone()
            .unwrap_or_else(|| RunJournalMaterialization {
                runtime_state_ref: Some(format!(
                    "{}/runtime-state.yml",
                    request.control_root_ref.trim_end_matches('/')
                )),
                last_applied_event_id: Some(last.event_id.clone()),
                last_applied_sequence: Some(last.sequence),
                last_applied_event_hash: Some(last.integrity.event_hash.clone()),
                materialized_at: Some(last.recorded_at.clone()),
                materialized_by_ref: Some(
                    ".octon/framework/engine/runtime/crates/runtime_bus".to_string(),
                ),
            });

    let ledger_ref = join_control_ref(&request.control_root_ref, "events.ndjson", &request.run_id)?;
    let manifest_ref = join_control_ref(
        &request.control_root_ref,
        "events.manifest.yml",
        &request.run_id,
    )?;
    let ledger_digest = Some(digest_events(events)?);

    Ok(RunJournalLedgerManifest {
        schema_version: "run-event-ledger-v2".to_string(),
        run_id: request.run_id.clone(),
        ledger_ref,
        manifest_ref,
        event_schema_ref: RUN_EVENT_SCHEMA_REF.to_string(),
        runtime_state_schema_ref: RUNTIME_STATE_SCHEMA_REF.to_string(),
        state_reconstruction_ref: STATE_RECONSTRUCTION_REF.to_string(),
        ledger_digest,
        event_count: events.len() as u64,
        first_event_ref: JournalEventRef {
            event_id: first.event_id.clone(),
            sequence: first.sequence,
            event_hash: first.integrity.event_hash.clone(),
        },
        last_event_ref: JournalEventRef {
            event_id: last.event_id.clone(),
            sequence: last.sequence,
            event_hash: last.integrity.event_hash.clone(),
        },
        hash_chain: JournalHashChain {
            hash_algorithm: "sha256".to_string(),
            chain_status: "verified".to_string(),
            head_event_hash: first.integrity.event_hash.clone(),
            tail_event_hash: last.integrity.event_hash.clone(),
        },
        governing_event_refs,
        snapshot_refs,
        last_materialization,
        drift_status: request
            .drift_status
            .clone()
            .or_else(|| Some(previous_manifest.drift_status.clone()))
            .unwrap_or_else(|| "in-sync".to_string()),
        drift_ref: request
            .drift_ref
            .clone()
            .or_else(|| previous_manifest.drift_ref.clone()),
        updated_at: last.recorded_at.clone(),
    })
}

fn write_event(path: &Path, event: &RunJournalEvent) -> Result<(), RuntimeBusError> {
    let parent = path.parent().expect("events path always has a parent");
    fs::create_dir_all(parent).map_err(|source| RuntimeBusError::Write {
        path: parent.to_path_buf(),
        source,
    })?;
    let mut file = OpenOptions::new()
        .create(true)
        .append(true)
        .open(path)
        .map_err(|source| RuntimeBusError::Write {
            path: path.to_path_buf(),
            source,
        })?;
    let json = serde_json::to_string(event).map_err(|source| RuntimeBusError::SerializeEvent {
        event_id: event.event_id.clone(),
        source,
    })?;
    file.write_all(json.as_bytes())
        .map_err(|source| RuntimeBusError::Write {
            path: path.to_path_buf(),
            source,
        })?;
    file.write_all(b"\n")
        .map_err(|source| RuntimeBusError::Write {
            path: path.to_path_buf(),
            source,
        })?;
    Ok(())
}

fn write_manifest(path: &Path, manifest: &RunJournalLedgerManifest) -> Result<(), RuntimeBusError> {
    let parent = path.parent().expect("manifest path always has a parent");
    fs::create_dir_all(parent).map_err(|source| RuntimeBusError::Write {
        path: parent.to_path_buf(),
        source,
    })?;
    let yaml =
        serde_yaml::to_string(manifest).map_err(|source| RuntimeBusError::SerializeManifest {
            run_id: manifest.run_id.clone(),
            source,
        })?;
    fs::write(path, yaml).map_err(|source| RuntimeBusError::Write {
        path: path.to_path_buf(),
        source,
    })
}

fn join_control_ref(
    control_root_ref: &str,
    filename: &str,
    run_id: &str,
) -> Result<String, RuntimeBusError> {
    if control_root_ref.trim().is_empty() || !control_root_ref.contains(run_id) {
        return Err(RuntimeBusError::InvalidControlRootRef {
            run_id: run_id.to_string(),
            control_root_ref: control_root_ref.to_string(),
        });
    }
    Ok(format!(
        "{}/{}",
        control_root_ref.trim_end_matches('/'),
        filename
    ))
}

fn digest_event(event: &RunJournalEvent) -> Result<String, RuntimeBusError> {
    #[derive(Serialize)]
    struct EventHashInput<'a> {
        schema_version: &'a str,
        event_id: &'a str,
        run_id: &'a str,
        sequence: u64,
        event_type: &'a str,
        recorded_at: &'a str,
        subject_ref: &'a Option<String>,
        actor: &'a JournalActor,
        causality: &'a JournalCausality,
        classification: &'a JournalClassification,
        lifecycle: &'a JournalLifecycle,
        governing_refs: &'a JournalGoverningRefs,
        payload: &'a JournalPayload,
        effect: &'a JournalEffect,
        redaction: &'a JournalRedaction,
        previous_event_hash: &'a Option<String>,
    }

    let json = serde_json::to_vec(&EventHashInput {
        schema_version: &event.schema_version,
        event_id: &event.event_id,
        run_id: &event.run_id,
        sequence: event.sequence,
        event_type: &event.event_type,
        recorded_at: &event.recorded_at,
        subject_ref: &event.subject_ref,
        actor: &event.actor,
        causality: &event.causality,
        classification: &event.classification,
        lifecycle: &event.lifecycle,
        governing_refs: &event.governing_refs,
        payload: &event.payload,
        effect: &event.effect,
        redaction: &event.redaction,
        previous_event_hash: &event.integrity.previous_event_hash,
    })
    .map_err(|source| RuntimeBusError::HashSerialization {
        subject: "run-event-v2",
        source,
    })?;
    Ok(format!("sha256:{}", hex::encode(Sha256::digest(json))))
}

fn digest_events(events: &[RunJournalEvent]) -> Result<String, RuntimeBusError> {
    let json = serde_json::to_vec(events).map_err(|source| RuntimeBusError::HashSerialization {
        subject: "run-event-stream",
        source,
    })?;
    Ok(format!("sha256:{}", hex::encode(Sha256::digest(json))))
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::atomic::{AtomicU64, Ordering};
    use std::time::{SystemTime, UNIX_EPOCH};

    static TEMP_DIR_COUNTER: AtomicU64 = AtomicU64::new(0);

    fn unique_temp_dir() -> PathBuf {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("system time before unix epoch")
            .as_nanos();
        let serial = TEMP_DIR_COUNTER.fetch_add(1, Ordering::Relaxed);
        let path = std::env::temp_dir().join(format!(
            "runtime-bus-{}-{nanos}-{serial}",
            std::process::id()
        ));
        fs::create_dir_all(&path).expect("temp dir should be creatable");
        path
    }

    fn unique_repo_run_control_root(run_id: &str) -> (PathBuf, PathBuf, String) {
        let repo_root = unique_temp_dir();
        let control_root = repo_root
            .join(".octon/state/control/execution/runs")
            .join(run_id);
        fs::create_dir_all(&control_root).expect("run control root should be creatable");
        (
            repo_root,
            control_root,
            format!(".octon/state/control/execution/runs/{run_id}"),
        )
    }

    fn write_repo_file(repo_root: &Path, reference: &str, contents: &str) {
        let path = if Path::new(reference).is_absolute() {
            PathBuf::from(reference)
        } else {
            repo_root.join(reference)
        };
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).expect("fixture parent should be creatable");
        }
        fs::write(path, contents).expect("fixture file should be writable");
    }

    fn write_stage_only_decision(repo_root: &Path, control_root_ref: &str) -> String {
        let reference = format!("{control_root_ref}/authority/stage-only-decision.yml");
        write_repo_file(
            repo_root,
            &reference,
            "schema_version: stage-only-decision-v1\ndecision: STAGE_ONLY\nroute: stage_only\n",
        );
        reference
    }

    fn write_allow_decision(repo_root: &Path, control_root_ref: &str) -> String {
        let reference = format!("{control_root_ref}/authority/decision.yml");
        write_repo_file(
            repo_root,
            &reference,
            "schema_version: authority-decision-artifact-v1\ndecision: ALLOW\nroute: allow\n",
        );
        reference
    }

    fn refresh_journal_snapshot(repo_root: &Path, run_id: &str, control_root: &Path) {
        let snapshot_root = repo_root
            .join(".octon/state/evidence/runs")
            .join(run_id)
            .join("run-journal");
        fs::create_dir_all(&snapshot_root).expect("snapshot root should be creatable");
        fs::copy(
            control_root.join("events.ndjson"),
            snapshot_root.join("events.snapshot.ndjson"),
        )
        .expect("events snapshot should copy");
        fs::copy(
            control_root.join("events.manifest.yml"),
            snapshot_root.join("events.manifest.snapshot.yml"),
        )
        .expect("manifest snapshot should copy");
    }

    fn prepare_closeout_artifacts(
        repo_root: &Path,
        run_id: &str,
        control_root: &Path,
        control_root_ref: &str,
        unresolved_risk_count: u64,
        risk_status: &str,
    ) -> (String, String, String, String) {
        refresh_journal_snapshot(repo_root, run_id, control_root);
        let rollback_ref = format!("{control_root_ref}/rollback-posture.yml");
        let review_ref = format!("{control_root_ref}/authority/review-dispositions.yml");
        let disclosure_ref = format!(".octon/state/evidence/disclosure/runs/{run_id}/run-card.yml");
        let retained_ref = format!(".octon/state/evidence/runs/{run_id}/retained-run-evidence.yml");
        let evidence_snapshot_ref =
            format!(".octon/state/evidence/runs/{run_id}/run-journal/events.snapshot.ndjson");
        let evidence_manifest_snapshot_ref =
            format!(".octon/state/evidence/runs/{run_id}/run-journal/events.manifest.snapshot.yml");
        let completeness_ref =
            format!(".octon/state/evidence/runs/{run_id}/closeout/evidence-store-completeness.yml");
        write_repo_file(repo_root, &rollback_ref, "status: ready\n");
        write_repo_file(repo_root, &disclosure_ref, "schema_version: run-card-v1\n");
        write_repo_file(
            repo_root,
            &retained_ref,
            "schema_version: retained-run-evidence-v1\n",
        );
        write_repo_file(
            repo_root,
            &review_ref,
            &format!(
                "schema_version: review-dispositions-v1\ndispositions: []\nrisk_disposition:\n  status: {risk_status}\n  unresolved_risk_count: {unresolved_risk_count}\n"
            ),
        );
        write_repo_file(
            repo_root,
            &completeness_ref,
            &format!(
                "schema_version: run-closeout-evidence-store-completeness-v1\ncompleteness_status: complete\njournal_snapshot_ref: {evidence_snapshot_ref}\nevidence_manifest_snapshot_ref: {evidence_manifest_snapshot_ref}\nrollback_posture_ref: {rollback_ref}\nrun_card_ref: {disclosure_ref}\nreview_dispositions_ref: {review_ref}\nretained_evidence_ref: {retained_ref}\nreplay_disclosure_ready: true\n"
            ),
        );
        (
            review_ref,
            completeness_ref,
            evidence_snapshot_ref,
            disclosure_ref,
        )
    }

    fn sample_request(
        run_id: &str,
        control_root_ref: &str,
        event_id: &str,
    ) -> RunJournalAppendRequest {
        RunJournalAppendRequest {
            run_id: run_id.to_string(),
            control_root_ref: control_root_ref.to_string(),
            event_id: event_id.to_string(),
            event_type: "run-created".to_string(),
            recorded_at: "2026-04-22T12:00:00Z".to_string(),
            subject_ref: Some(format!("{control_root_ref}/run-contract.yml")),
            actor: JournalActor {
                actor_class: "authority-engine".to_string(),
                actor_ref: ".octon/framework/engine/runtime/crates/authority_engine".to_string(),
            },
            classification: JournalClassification {
                event_plane: "committed-effect".to_string(),
                replay_disposition: "dry-run-only".to_string(),
            },
            lifecycle: JournalLifecycle {
                state_before: Some("draft".to_string()),
                state_after: Some("bound".to_string()),
            },
            governing_refs: JournalGoverningRefs {
                run_contract_ref: format!("{control_root_ref}/run-contract.yml"),
                run_manifest_ref: format!("{control_root_ref}/run-manifest.yml"),
                execution_request_ref: Some(format!("{control_root_ref}/request.yml")),
                authority_route_receipt_ref: None,
                grant_bundle_ref: None,
                policy_receipt_ref: None,
                approval_ref: None,
                lease_ref: None,
                revocation_ref: None,
                support_target_tuple_ref: Some(
                    "tuple://repo-local-governed/observe-and-read/reference-owned/english-primary/repo-shell"
                        .to_string(),
                ),
                rollback_plan_ref: None,
                rollback_posture_ref: Some(format!("{control_root_ref}/rollback-posture.yml")),
                context_pack_ref: None,
                stage_attempt_ref: None,
                checkpoint_ref: None,
                validator_result_ref: None,
                evidence_snapshot_ref: None,
                disclosure_ref: None,
                drift_ref: None,
                continuity_ref: None,
                additional_refs: Vec::new(),
            },
            payload: JournalPayload {
                payload_kind: "inline-typed".to_string(),
                schema_ref: None,
                typed_body: Some(serde_json::json!({"status":"bound"})),
                artifact_ref: None,
                artifact_hash: None,
                content_type: None,
                summary: Some("Canonical run root bound.".to_string()),
            },
            effect: JournalEffect {
                effect_class: "write".to_string(),
                reversibility_class: "reversible".to_string(),
                evidence_class: "required".to_string(),
            },
            redaction: JournalRedaction {
                redacted: false,
                justification: None,
                lineage_ref: None,
                omitted_fields: Vec::new(),
            },
            causality: JournalCausality::default(),
            governing_manifest_roles: vec!["run_contract_ref".to_string()],
            materialization: None,
            snapshot_refs: None,
            drift_status: None,
            drift_ref: None,
        }
    }

    #[test]
    fn append_event_initializes_sequence_and_manifest() {
        let root = unique_temp_dir();
        let run_id = "run-123";
        let control_root_ref = ".octon/state/control/execution/runs/run-123";
        let receipt = append_event(&root, sample_request(run_id, control_root_ref, "evt-001"))
            .expect("first append should succeed");

        assert_eq!(receipt.event.sequence, 1);
        assert!(receipt.event.causality.causal_parent_event_ids.is_empty());
        assert_eq!(receipt.manifest.event_count, 1);
        assert_eq!(receipt.manifest.first_event_ref.event_id, "evt-001");
        assert_eq!(receipt.manifest.last_event_ref.event_id, "evt-001");
    }

    #[test]
    fn append_event_chains_hashes_and_updates_manifest_roles() {
        let run_id = "run-456";
        let (repo_root, root, control_root_ref) = unique_repo_run_control_root(run_id);
        let first = append_event(&root, sample_request(run_id, &control_root_ref, "evt-001"))
            .expect("first append should succeed");
        let mut second_request = sample_request(run_id, &control_root_ref, "evt-002");
        second_request.event_type = "authority-resolved".to_string();
        second_request.classification.event_plane = "authorized-action".to_string();
        second_request.lifecycle.state_before = Some("bound".to_string());
        second_request.lifecycle.state_after = Some("staged".to_string());
        second_request.governing_refs.authority_route_receipt_ref =
            Some(format!("{control_root_ref}/authority/decision.yml"));
        second_request
            .governing_refs
            .additional_refs
            .push(write_stage_only_decision(&repo_root, &control_root_ref));
        second_request.governing_manifest_roles = vec!["runtime_state_ref".to_string()];

        let second = append_event(&root, second_request).expect("second append should succeed");
        assert_eq!(second.event.sequence, 2);
        assert_eq!(
            second.event.integrity.previous_event_hash.as_deref(),
            Some(first.event.integrity.event_hash.as_str())
        );
        assert_eq!(
            second.event.causality.causal_parent_event_ids,
            vec!["evt-001".to_string()]
        );
        assert_eq!(
            second
                .manifest
                .governing_event_refs
                .get("runtime_state_ref"),
            Some(&"evt-002".to_string())
        );
        assert_eq!(second.manifest.event_count, 2);
    }

    #[test]
    fn append_event_rejects_unknown_lifecycle_states() {
        let root = unique_temp_dir();
        let run_id = "run-created-state";
        let control_root_ref = ".octon/state/control/execution/runs/run-created-state";
        let mut request = sample_request(run_id, control_root_ref, "evt-001");
        request.lifecycle.state_before = Some("created".to_string());

        let err = append_event(&root, request).expect_err("created is not a lifecycle-v1 state");
        assert!(matches!(err, RuntimeBusError::InvalidLifecycleState { .. }));
    }

    #[test]
    fn append_event_rejects_authorizing_transition() {
        let root = unique_temp_dir();
        let run_id = "run-authorizing-state";
        let control_root_ref = ".octon/state/control/execution/runs/run-authorizing-state";
        append_event(&root, sample_request(run_id, control_root_ref, "evt-001"))
            .expect("first append should succeed");

        let mut request = sample_request(run_id, control_root_ref, "evt-002");
        request.lifecycle.state_before = Some("bound".to_string());
        request.lifecycle.state_after = Some("authorizing".to_string());

        let err =
            append_event(&root, request).expect_err("authorizing is not a lifecycle-v1 state");
        assert!(matches!(err, RuntimeBusError::InvalidLifecycleState { .. }));
    }

    #[test]
    fn append_event_rejects_illegal_raw_running_transition() {
        let root = unique_temp_dir();
        let run_id = "run-bound-running";
        let control_root_ref = ".octon/state/control/execution/runs/run-bound-running";
        append_event(&root, sample_request(run_id, control_root_ref, "evt-001"))
            .expect("first append should succeed");

        let mut request = sample_request(run_id, control_root_ref, "evt-002");
        request.event_type = "stage-started".to_string();
        request.lifecycle.state_before = Some("bound".to_string());
        request.lifecycle.state_after = Some("running".to_string());
        request.governing_refs.stage_attempt_ref =
            Some(format!("{control_root_ref}/stage-attempts/initial.yml"));

        let err = append_event(&root, request).expect_err("bound -> running must fail closed");
        assert!(matches!(
            err,
            RuntimeBusError::IllegalLifecycleTransition { .. }
        ));
    }

    #[test]
    fn append_event_rejects_bound_staged_without_stage_only_evidence() {
        let run_id = "run-bound-staged-no-stage-only";
        let (_repo_root, root, control_root_ref) = unique_repo_run_control_root(run_id);
        append_event(&root, sample_request(run_id, &control_root_ref, "evt-001"))
            .expect("first append should succeed");

        let mut staged = sample_request(run_id, &control_root_ref, "evt-002");
        staged.event_type = "authority-resolved".to_string();
        staged.lifecycle.state_before = Some("bound".to_string());
        staged.lifecycle.state_after = Some("staged".to_string());
        staged.governing_refs.authority_route_receipt_ref =
            Some(format!("{control_root_ref}/authority/decision.yml"));

        let err = append_event(&root, staged)
            .expect_err("bound -> staged requires stage-only routing evidence");
        assert!(matches!(err, RuntimeBusError::MissingLifecycleRefs { .. }));
    }

    #[test]
    fn append_event_rejects_bound_staged_with_allow_decision() {
        let run_id = "run-bound-staged-allow";
        let (repo_root, root, control_root_ref) = unique_repo_run_control_root(run_id);
        append_event(&root, sample_request(run_id, &control_root_ref, "evt-001"))
            .expect("first append should succeed");

        let mut staged = sample_request(run_id, &control_root_ref, "evt-002");
        staged.event_type = "authority-resolved".to_string();
        staged.lifecycle.state_before = Some("bound".to_string());
        staged.lifecycle.state_after = Some("staged".to_string());
        staged.governing_refs.authority_route_receipt_ref =
            Some(format!("{control_root_ref}/authority/decision.yml"));
        staged
            .governing_refs
            .additional_refs
            .push(write_allow_decision(&repo_root, &control_root_ref));

        let err = append_event(&root, staged)
            .expect_err("bound -> staged rejects non-stage-only routing evidence");
        assert!(matches!(err, RuntimeBusError::MissingLifecycleRefs { .. }));
    }

    #[test]
    fn append_event_rejects_events_after_closed() {
        let run_id = "run-closed-terminal";
        let (repo_root, root, control_root_ref) = unique_repo_run_control_root(run_id);
        append_event(&root, sample_request(run_id, &control_root_ref, "evt-001"))
            .expect("bound append should succeed");

        let mut staged = sample_request(run_id, &control_root_ref, "evt-002");
        staged.event_type = "authority-resolved".to_string();
        staged.lifecycle.state_before = Some("bound".to_string());
        staged.lifecycle.state_after = Some("staged".to_string());
        staged.governing_refs.authority_route_receipt_ref =
            Some(format!("{control_root_ref}/authority/decision.yml"));
        staged
            .governing_refs
            .additional_refs
            .push(write_stage_only_decision(&repo_root, &control_root_ref));
        append_event(&root, staged).expect("staged append should succeed");

        let (review_ref, completeness_ref, evidence_snapshot_ref, disclosure_ref) =
            prepare_closeout_artifacts(&repo_root, run_id, &root, &control_root_ref, 0, "resolved");
        let mut close = sample_request(run_id, &control_root_ref, "evt-003");
        close.event_type = "run-closed".to_string();
        close.lifecycle.state_before = Some("staged".to_string());
        close.lifecycle.state_after = Some("closed".to_string());
        close.governing_refs.authority_route_receipt_ref =
            Some(format!("{control_root_ref}/authority/decision.yml"));
        close.governing_refs.evidence_snapshot_ref = Some(evidence_snapshot_ref);
        close.governing_refs.disclosure_ref = Some(disclosure_ref);
        close.governing_refs.additional_refs = vec![review_ref, completeness_ref];
        append_event(&root, close).expect("close append should succeed");
        refresh_journal_snapshot(&repo_root, run_id, &root);

        let mut after_close = sample_request(run_id, &control_root_ref, "evt-004");
        after_close.lifecycle.state_before = Some("closed".to_string());
        after_close.lifecycle.state_after = Some("closed".to_string());
        let err = append_event(&root, after_close).expect_err("closed is terminal");
        assert!(matches!(
            err,
            RuntimeBusError::IllegalLifecycleTransition { .. }
        ));
    }

    #[test]
    fn append_event_allows_succeeded_run_closed_with_closeout_refs() {
        let run_id = "run-closed-from-succeeded";
        let (repo_root, root, control_root_ref) = unique_repo_run_control_root(run_id);
        fs::create_dir_all(repo_root.join(".octon/.octon/generated"))
            .expect("nested .octon marker fixture should be creatable");
        assert_eq!(
            discover_repo_root(&root).as_deref(),
            Some(repo_root.as_path())
        );
        append_event(&root, sample_request(run_id, &control_root_ref, "evt-001"))
            .expect("bound append should succeed");

        let mut authorized = sample_request(run_id, &control_root_ref, "evt-002");
        authorized.event_type = "authority-resolved".to_string();
        authorized.lifecycle.state_before = Some("bound".to_string());
        authorized.lifecycle.state_after = Some("authorized".to_string());
        authorized.governing_refs.authority_route_receipt_ref =
            Some(format!("{control_root_ref}/authority/decision.yml"));
        authorized.governing_refs.grant_bundle_ref =
            Some(format!("{control_root_ref}/authority/grant-bundle.yml"));
        authorized.governing_refs.context_pack_ref = Some(format!(
            ".octon/state/evidence/runs/{run_id}/context/context-pack.json"
        ));
        append_event(&root, authorized).expect("authorized append should succeed");

        let mut running = sample_request(run_id, &control_root_ref, "evt-003");
        running.event_type = "capability-invoked".to_string();
        running.lifecycle.state_before = Some("authorized".to_string());
        running.lifecycle.state_after = Some("running".to_string());
        running.governing_refs.grant_bundle_ref =
            Some(format!("{control_root_ref}/authority/grant-bundle.yml"));
        running.governing_refs.stage_attempt_ref =
            Some(format!("{control_root_ref}/stage-attempts/initial.yml"));
        append_event(&root, running).expect("running append should succeed");

        let mut succeeded = sample_request(run_id, &control_root_ref, "evt-004");
        succeeded.event_type = "capability-completed".to_string();
        succeeded.lifecycle.state_before = Some("running".to_string());
        succeeded.lifecycle.state_after = Some("succeeded".to_string());
        succeeded.subject_ref = Some(format!(
            ".octon/state/evidence/runs/{run_id}/receipts/execution-receipt.json"
        ));
        append_event(&root, succeeded).expect("succeeded append should succeed");

        let mut checkpoint = sample_request(run_id, &control_root_ref, "evt-005");
        checkpoint.event_type = "checkpoint-created".to_string();
        checkpoint.lifecycle.state_before = Some("succeeded".to_string());
        checkpoint.lifecycle.state_after = Some("succeeded".to_string());
        checkpoint.governing_refs.checkpoint_ref =
            Some(format!("{control_root_ref}/checkpoints/execution-complete.yml"));
        append_event(&root, checkpoint).expect("checkpoint append should succeed");

        let (review_ref, completeness_ref, evidence_snapshot_ref, disclosure_ref) =
            prepare_closeout_artifacts(&repo_root, run_id, &root, &control_root_ref, 0, "resolved");

        let mut disclosure = sample_request(run_id, &control_root_ref, "evt-006");
        disclosure.event_type = "run-card-published".to_string();
        disclosure.lifecycle.state_before = Some("succeeded".to_string());
        disclosure.lifecycle.state_after = Some("succeeded".to_string());
        disclosure.subject_ref = Some(disclosure_ref.clone());
        disclosure.governing_refs.disclosure_ref = Some(disclosure_ref.clone());
        append_event(&root, disclosure).expect("run-card append should succeed");

        refresh_journal_snapshot(&repo_root, run_id, &root);

        let mut snapshot = sample_request(run_id, &control_root_ref, "evt-007");
        snapshot.event_type = "evidence-snapshot-created".to_string();
        snapshot.lifecycle.state_before = Some("succeeded".to_string());
        snapshot.lifecycle.state_after = Some("succeeded".to_string());
        snapshot.subject_ref = Some(evidence_snapshot_ref.clone());
        snapshot.governing_refs.evidence_snapshot_ref = Some(evidence_snapshot_ref.clone());
        snapshot.governing_refs.disclosure_ref = Some(disclosure_ref.clone());
        append_event(&root, snapshot).expect("snapshot append should succeed");

        refresh_journal_snapshot(&repo_root, run_id, &root);

        let mut close = sample_request(run_id, &control_root_ref, "evt-008");
        close.event_type = "run-closed".to_string();
        close.lifecycle.state_before = Some("succeeded".to_string());
        close.lifecycle.state_after = Some("closed".to_string());
        close.subject_ref = Some(format!("{control_root_ref}/runtime-state.yml"));
        close.governing_refs.evidence_snapshot_ref = Some(evidence_snapshot_ref);
        close.governing_refs.disclosure_ref = Some(disclosure_ref);
        close.governing_refs.additional_refs = vec![review_ref, completeness_ref];
        append_event(&root, close).expect("run-closed append should succeed");
    }

    #[test]
    fn append_event_rejects_run_closed_without_closeout_refs() {
        let run_id = "run-closeout-missing";
        let (repo_root, root, control_root_ref) = unique_repo_run_control_root(run_id);
        append_event(&root, sample_request(run_id, &control_root_ref, "evt-001"))
            .expect("bound append should succeed");

        let mut staged = sample_request(run_id, &control_root_ref, "evt-002");
        staged.event_type = "authority-resolved".to_string();
        staged.lifecycle.state_before = Some("bound".to_string());
        staged.lifecycle.state_after = Some("staged".to_string());
        staged.governing_refs.authority_route_receipt_ref =
            Some(format!("{control_root_ref}/authority/decision.yml"));
        staged
            .governing_refs
            .additional_refs
            .push(write_stage_only_decision(&repo_root, &control_root_ref));
        append_event(&root, staged).expect("staged append should succeed");

        let mut close = sample_request(run_id, &control_root_ref, "evt-003");
        close.event_type = "run-closed".to_string();
        close.lifecycle.state_before = Some("staged".to_string());
        close.lifecycle.state_after = Some("closed".to_string());
        close.governing_refs.authority_route_receipt_ref =
            Some(format!("{control_root_ref}/authority/decision.yml"));
        close.governing_refs.evidence_snapshot_ref = Some(format!(
            ".octon/state/evidence/runs/{run_id}/run-journal/events.snapshot.ndjson"
        ));
        close.governing_refs.disclosure_ref = Some(format!(
            ".octon/state/evidence/disclosure/runs/{run_id}/run-card.yml"
        ));

        let err = append_event(&root, close).expect_err("closeout refs are mandatory");
        assert!(matches!(err, RuntimeBusError::MissingLifecycleRefs { .. }));
    }

    #[test]
    fn append_event_rejects_run_closed_with_fake_closeout_refs() {
        let run_id = "run-closeout-fake";
        let (repo_root, root, control_root_ref) = unique_repo_run_control_root(run_id);
        append_event(&root, sample_request(run_id, &control_root_ref, "evt-001"))
            .expect("bound append should succeed");

        let mut staged = sample_request(run_id, &control_root_ref, "evt-002");
        staged.event_type = "authority-resolved".to_string();
        staged.lifecycle.state_before = Some("bound".to_string());
        staged.lifecycle.state_after = Some("staged".to_string());
        staged.governing_refs.authority_route_receipt_ref =
            Some(format!("{control_root_ref}/authority/decision.yml"));
        staged
            .governing_refs
            .additional_refs
            .push(write_stage_only_decision(&repo_root, &control_root_ref));
        append_event(&root, staged).expect("staged append should succeed");

        let mut close = sample_request(run_id, &control_root_ref, "evt-003");
        close.event_type = "run-closed".to_string();
        close.lifecycle.state_before = Some("staged".to_string());
        close.lifecycle.state_after = Some("closed".to_string());
        close.governing_refs.evidence_snapshot_ref = Some(format!(
            ".octon/state/evidence/runs/{run_id}/run-journal/events.snapshot.ndjson"
        ));
        close.governing_refs.disclosure_ref = Some(format!(
            ".octon/state/evidence/disclosure/runs/{run_id}/run-card.yml"
        ));
        close.governing_refs.additional_refs = vec![
            format!("{control_root_ref}/authority/review-dispositions.yml"),
            format!(".octon/state/evidence/runs/{run_id}/closeout/evidence-store-completeness.yml"),
        ];

        let err = append_event(&root, close)
            .expect_err("closeout refs must resolve to complete artifacts");
        assert!(matches!(err, RuntimeBusError::MissingLifecycleRefs { .. }));
    }

    #[test]
    fn append_event_rejects_run_closed_with_unresolved_risk() {
        let run_id = "run-closeout-unresolved-risk";
        let (repo_root, root, control_root_ref) = unique_repo_run_control_root(run_id);
        append_event(&root, sample_request(run_id, &control_root_ref, "evt-001"))
            .expect("bound append should succeed");

        let mut staged = sample_request(run_id, &control_root_ref, "evt-002");
        staged.event_type = "authority-resolved".to_string();
        staged.lifecycle.state_before = Some("bound".to_string());
        staged.lifecycle.state_after = Some("staged".to_string());
        staged.governing_refs.authority_route_receipt_ref =
            Some(format!("{control_root_ref}/authority/decision.yml"));
        staged
            .governing_refs
            .additional_refs
            .push(write_stage_only_decision(&repo_root, &control_root_ref));
        append_event(&root, staged).expect("staged append should succeed");

        let (review_ref, completeness_ref, evidence_snapshot_ref, disclosure_ref) =
            prepare_closeout_artifacts(&repo_root, run_id, &root, &control_root_ref, 1, "open");
        let mut close = sample_request(run_id, &control_root_ref, "evt-003");
        close.event_type = "run-closed".to_string();
        close.lifecycle.state_before = Some("staged".to_string());
        close.lifecycle.state_after = Some("closed".to_string());
        close.governing_refs.evidence_snapshot_ref = Some(evidence_snapshot_ref);
        close.governing_refs.disclosure_ref = Some(disclosure_ref);
        close.governing_refs.additional_refs = vec![review_ref, completeness_ref];

        let err =
            append_event(&root, close).expect_err("unresolved blocking risks prevent closure");
        assert!(matches!(
            err,
            RuntimeBusError::InvalidLifecycleArtifact { .. }
        ));
    }

    #[test]
    fn append_event_rejects_generated_lifecycle_authority() {
        let root = unique_temp_dir();
        let run_id = "run-generated-authority";
        let control_root_ref = ".octon/state/control/execution/runs/run-generated-authority";
        let mut request = sample_request(run_id, control_root_ref, "evt-001");
        request.governing_refs.run_manifest_ref = ".octon/generated/runs/run.yml".to_string();

        let err = append_event(&root, request).expect_err("generated refs cannot govern lifecycle");
        assert!(matches!(
            err,
            RuntimeBusError::NonAuthoritativeLifecycleRef { .. }
        ));
    }

    #[test]
    fn append_event_rejects_absolute_generated_lifecycle_authority() {
        let run_id = "run-absolute-generated-authority";
        let (repo_root, root, control_root_ref) = unique_repo_run_control_root(run_id);
        let mut request = sample_request(run_id, &control_root_ref, "evt-001");
        request.governing_refs.run_manifest_ref = repo_root
            .join(".octon/generated/runs/run.yml")
            .to_string_lossy()
            .to_string();

        let err = append_event(&root, request)
            .expect_err("absolute generated refs cannot govern lifecycle");
        assert!(matches!(
            err,
            RuntimeBusError::NonAuthoritativeLifecycleRef { .. }
        ));
    }

    #[test]
    fn append_event_rejects_absolute_input_lifecycle_authority() {
        let run_id = "run-absolute-input-authority";
        let (repo_root, root, control_root_ref) = unique_repo_run_control_root(run_id);
        let mut request = sample_request(run_id, &control_root_ref, "evt-001");
        request.governing_refs.run_manifest_ref = repo_root
            .join(".octon/inputs/exploratory/proposals/example.yml")
            .to_string_lossy()
            .to_string();

        let err =
            append_event(&root, request).expect_err("absolute input refs cannot govern lifecycle");
        assert!(matches!(
            err,
            RuntimeBusError::NonAuthoritativeLifecycleRef { .. }
        ));
    }

    #[test]
    fn append_event_rejects_generated_additional_ref_authority() {
        let run_id = "run-generated-additional-authority";
        let (repo_root, root, control_root_ref) = unique_repo_run_control_root(run_id);
        let mut request = sample_request(run_id, &control_root_ref, "evt-001");
        request.governing_refs.additional_refs.push(
            repo_root
                .join(".octon/generated/runs/run.yml")
                .to_string_lossy()
                .to_string(),
        );

        let err = append_event(&root, request)
            .expect_err("generated additional refs cannot govern lifecycle");
        assert!(matches!(
            err,
            RuntimeBusError::NonAuthoritativeLifecycleRef { .. }
        ));
    }

    #[test]
    fn load_journal_rejects_tampered_event_hashes() {
        let root = unique_temp_dir();
        let run_id = "run-789";
        let control_root_ref = ".octon/state/control/execution/runs/run-789";
        append_event(&root, sample_request(run_id, control_root_ref, "evt-001"))
            .expect("append should succeed");

        let ledger_path = root.join("events.ndjson");
        let raw = fs::read_to_string(&ledger_path).expect("event file should be readable");
        let mut tampered: RunJournalEvent =
            serde_json::from_str(raw.lines().next().expect("one event"))
                .expect("event line should parse");
        tampered.integrity.event_hash =
            "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa".to_string();
        fs::write(
            &ledger_path,
            format!(
                "{}\n",
                serde_json::to_string(&tampered).expect("tampered event should serialize")
            ),
        )
        .expect("tampered event should write");

        let err = load_journal(&root)
            .and_then(|journal| validate_existing_document(&journal))
            .expect_err("tampered journal should fail");
        assert!(matches!(err, RuntimeBusError::EventHashMismatch { .. }));
    }
}
