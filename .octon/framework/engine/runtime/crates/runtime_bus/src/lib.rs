use serde::{Deserialize, Serialize};
use serde_json::Value;
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;
use std::fs::{self, OpenOptions};
use std::io::Write;
use std::path::{Path, PathBuf};
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
            causality.causal_parent_event_ids.push(parent.event_id.clone());
        }
    }

    let event = seal_event(
        &request,
        sequence,
        previous_event_hash,
        causality,
    )?;
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

    Ok(RunJournalDocument {
        ledger_path,
        manifest_path,
        events,
        manifest,
    })
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

    Ok(())
}

fn empty_manifest(
    request: &RunJournalAppendRequest,
) -> Result<RunJournalLedgerManifest, RuntimeBusError> {
    let manifest_ref = join_control_ref(&request.control_root_ref, "events.manifest.yml", &request.run_id)?;
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
    let first = events.first().expect("append_event always provides an event");
    let last = events.last().expect("append_event always provides an event");
    let mut governing_event_refs = previous_manifest.governing_event_refs.clone();
    for role in &request.governing_manifest_roles {
        governing_event_refs.insert(role.clone(), last.event_id.clone());
    }

    let snapshot_refs = request
        .snapshot_refs
        .clone()
        .unwrap_or_else(|| previous_manifest.snapshot_refs.clone());
    let last_materialization = request.materialization.clone().unwrap_or_else(|| {
        RunJournalMaterialization {
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
        }
    });

    let ledger_ref =
        join_control_ref(&request.control_root_ref, "events.ndjson", &request.run_id)?;
    let manifest_ref =
        join_control_ref(&request.control_root_ref, "events.manifest.yml", &request.run_id)?;
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

fn write_manifest(
    path: &Path,
    manifest: &RunJournalLedgerManifest,
) -> Result<(), RuntimeBusError> {
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
    use std::time::{SystemTime, UNIX_EPOCH};

    fn unique_temp_dir() -> PathBuf {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("system time before unix epoch")
            .as_nanos();
        let path = std::env::temp_dir().join(format!("runtime-bus-{nanos}"));
        fs::create_dir_all(&path).expect("temp dir should be creatable");
        path
    }

    fn sample_request(run_id: &str, control_root_ref: &str, event_id: &str) -> RunJournalAppendRequest {
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
                state_before: Some("created".to_string()),
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
        let receipt =
            append_event(&root, sample_request(run_id, control_root_ref, "evt-001"))
                .expect("first append should succeed");

        assert_eq!(receipt.event.sequence, 1);
        assert!(receipt.event.causality.causal_parent_event_ids.is_empty());
        assert_eq!(receipt.manifest.event_count, 1);
        assert_eq!(receipt.manifest.first_event_ref.event_id, "evt-001");
        assert_eq!(receipt.manifest.last_event_ref.event_id, "evt-001");
    }

    #[test]
    fn append_event_chains_hashes_and_updates_manifest_roles() {
        let root = unique_temp_dir();
        let run_id = "run-456";
        let control_root_ref = ".octon/state/control/execution/runs/run-456";
        let first = append_event(&root, sample_request(run_id, control_root_ref, "evt-001"))
            .expect("first append should succeed");
        let mut second_request = sample_request(run_id, control_root_ref, "evt-002");
        second_request.event_type = "authority-requested".to_string();
        second_request.classification.event_plane = "requested-action".to_string();
        second_request.lifecycle.state_before = Some("bound".to_string());
        second_request.lifecycle.state_after = Some("authorizing".to_string());
        second_request.governing_manifest_roles = vec!["runtime_state_ref".to_string()];

        let second =
            append_event(&root, second_request).expect("second append should succeed");
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
            second.manifest.governing_event_refs.get("runtime_state_ref"),
            Some(&"evt-002".to_string())
        );
        assert_eq!(second.manifest.event_count, 2);
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
            "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
                .to_string();
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
