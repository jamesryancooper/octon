use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::collections::BTreeSet;
use thiserror::Error;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ReplayBundleRef {
    pub run_id: String,
    pub manifest_ref: String,
    pub external_index_ref: String,
}

pub fn canonical_bundle_ref(run_id: &str) -> ReplayBundleRef {
    ReplayBundleRef {
        run_id: run_id.to_string(),
        manifest_ref: format!(".octon/state/evidence/runs/{run_id}/replay/manifest.yml"),
        external_index_ref: format!(".octon/state/evidence/external-index/runs/{run_id}.yml"),
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct RunJournalPaths {
    pub control_manifest_ref: String,
    pub control_events_ref: String,
    pub evidence_manifest_snapshot_ref: String,
    pub evidence_events_snapshot_ref: String,
}

pub fn canonical_journal_paths(run_id: &str) -> RunJournalPaths {
    RunJournalPaths {
        control_manifest_ref: format!(
            ".octon/state/control/execution/runs/{run_id}/events.manifest.yml"
        ),
        control_events_ref: format!(".octon/state/control/execution/runs/{run_id}/events.ndjson"),
        evidence_manifest_snapshot_ref: format!(
            ".octon/state/evidence/runs/{run_id}/run-journal/events.manifest.snapshot.yml"
        ),
        evidence_events_snapshot_ref: format!(
            ".octon/state/evidence/runs/{run_id}/run-journal/events.snapshot.ndjson"
        ),
    }
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct RunJournal {
    pub manifest_ref: String,
    pub manifest: RunJournalLedger,
    #[serde(default)]
    pub events: Vec<RunJournalEvent>,
}

impl RunJournal {
    pub fn from_events(
        run_id: &str,
        manifest_ref: &str,
        events_ref: &str,
        events: Vec<RunJournalEvent>,
    ) -> Result<Self, ReplayError> {
        Ok(Self {
            manifest_ref: manifest_ref.to_string(),
            manifest: RunJournalLedger::from_events(run_id, events_ref, &events)?,
            events,
        })
    }

    pub fn mirror_to(&self, manifest_ref: &str, events_ref: &str) -> Self {
        let mut manifest = self.manifest.clone();
        manifest.events_ref = events_ref.to_string();
        Self {
            manifest_ref: manifest_ref.to_string(),
            manifest,
            events: self.events.clone(),
        }
    }
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct RunJournalLedger {
    pub schema_version: String,
    pub run_id: String,
    pub events_ref: String,
    #[serde(default)]
    pub runtime_state_ref: Option<String>,
    #[serde(default)]
    pub event_schema_ref: Option<String>,
    #[serde(default)]
    pub runtime_state_schema_ref: Option<String>,
    #[serde(default)]
    pub first_event_id: Option<String>,
    #[serde(default)]
    pub last_event_id: Option<String>,
    #[serde(default)]
    pub first_sequence: Option<u64>,
    #[serde(default)]
    pub last_sequence: Option<u64>,
    pub event_count: u64,
    #[serde(default)]
    pub first_event_hash: Option<String>,
    #[serde(default)]
    pub last_event_hash: Option<String>,
    #[serde(default)]
    pub redaction_refs: Vec<String>,
    #[serde(default)]
    pub closeout_snapshot_refs: Vec<String>,
    #[serde(default)]
    pub validator_refs: Vec<String>,
    #[serde(default)]
    pub hash_chain_status: String,
    #[serde(default)]
    pub drift_status: String,
}

impl RunJournalLedger {
    pub fn from_events(
        run_id: &str,
        events_ref: &str,
        events: &[RunJournalEvent],
    ) -> Result<Self, ReplayError> {
        let first = events.first();
        let last = events.last();
        Ok(Self {
            schema_version: "run-event-ledger-v2".to_string(),
            run_id: run_id.to_string(),
            events_ref: events_ref.to_string(),
            runtime_state_ref: None,
            event_schema_ref: Some(
                ".octon/framework/constitution/contracts/runtime/run-event-v2.schema.json"
                    .to_string(),
            ),
            runtime_state_schema_ref: Some(
                ".octon/framework/constitution/contracts/runtime/runtime-state-v2.schema.json"
                    .to_string(),
            ),
            first_event_id: first.map(|event| event.event_id.clone()),
            last_event_id: last.map(|event| event.event_id.clone()),
            first_sequence: first.map(|event| event.sequence),
            last_sequence: last.map(|event| event.sequence),
            event_count: events.len() as u64,
            first_event_hash: first.map(|event| event.event_hash.clone()),
            last_event_hash: last.map(|event| event.event_hash.clone()),
            redaction_refs: unique_strings(
                events
                    .iter()
                    .filter_map(|event| event.redaction.lineage_ref.clone())
                    .collect(),
            ),
            closeout_snapshot_refs: Vec::new(),
            validator_refs: Vec::new(),
            hash_chain_status: if events.is_empty() {
                "missing".to_string()
            } else {
                "verified".to_string()
            },
            drift_status: "clean".to_string(),
        })
    }
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct RunJournalEvent {
    pub schema_version: String,
    pub run_id: String,
    pub event_id: String,
    pub sequence: u64,
    pub event_type: String,
    pub recorded_at: String,
    pub actor: JournalActor,
    #[serde(default)]
    pub causal_parent_event_ids: Vec<String>,
    #[serde(default)]
    pub idempotency_key: Option<String>,
    pub lifecycle: JournalLifecycle,
    pub governing_refs: GoverningRefs,
    pub effect: JournalEffect,
    #[serde(default)]
    pub payload_ref: Option<String>,
    #[serde(default)]
    pub payload_hash: Option<String>,
    pub redaction: JournalRedaction,
    #[serde(default)]
    pub previous_event_hash: Option<String>,
    #[serde(default)]
    pub event_hash: String,
}

impl RunJournalEvent {
    pub fn seal(mut self) -> Result<Self, ReplayError> {
        self.event_hash = canonical_event_hash(&self)?;
        Ok(self)
    }

    pub fn is_side_effecting(&self) -> bool {
        matches!(
            self.effect.effect_class.as_str(),
            "write"
                | "mutate"
                | "external-side-effect"
                | "rollback"
                | "recovery"
                | "disclosure"
        )
    }
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct JournalActor {
    pub actor_class: String,
    pub actor_ref: String,
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct JournalLifecycle {
    #[serde(default)]
    pub state_before: String,
    #[serde(default)]
    pub state_after: String,
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct GoverningRefs {
    #[serde(default)]
    pub execution_request_ref: Option<String>,
    #[serde(default)]
    pub grant_ref: Option<String>,
    #[serde(default)]
    pub policy_receipt_ref: Option<String>,
    #[serde(default)]
    pub support_target_tuple_ref: Option<String>,
    #[serde(default)]
    pub rollback_plan_ref: Option<String>,
    #[serde(default)]
    pub context_pack_ref: Option<String>,
    #[serde(default)]
    pub capability_lease_ref: Option<String>,
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct JournalEffect {
    pub effect_class: String,
    pub reversibility_class: String,
    pub evidence_class: String,
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct JournalRedaction {
    pub redacted: bool,
    #[serde(default)]
    pub lineage_ref: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum ReplayGapKind {
    MissingPayloadArtifact,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ReplayGap {
    pub kind: ReplayGapKind,
    pub run_id: String,
    pub event_id: String,
    pub sequence: u64,
    pub missing_ref: String,
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct ReconstructedRuntimeState {
    pub schema_version: String,
    pub run_id: String,
    pub state: String,
    pub source_ledger_ref: String,
    pub last_applied_event_id: String,
    pub last_applied_sequence: u64,
    pub last_applied_event_hash: String,
    pub materialized_at: String,
    pub materialized_by: String,
    pub drift_status: String,
    #[serde(default)]
    pub drift_ref: Option<String>,
    #[serde(default)]
    pub replay_gap_refs: Vec<String>,
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct JournalIntegritySummary {
    pub manifest_ref: String,
    pub events_ref: String,
    pub event_count: u64,
    #[serde(default)]
    pub first_event_id: Option<String>,
    #[serde(default)]
    pub last_event_id: Option<String>,
    #[serde(default)]
    pub final_event_hash: Option<String>,
    pub manifest_digest: String,
    pub manifest_integrity_digest: String,
    pub event_stream_digest: String,
    pub hash_chain_status: String,
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct ReconstructionReport {
    pub integrity: JournalIntegritySummary,
    pub runtime_state: ReconstructedRuntimeState,
    #[serde(default)]
    pub replay_gaps: Vec<ReplayGap>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum ReplayMode {
    DryRun,
    Sandbox,
    Live,
}

impl Default for ReplayMode {
    fn default() -> Self {
        Self::DryRun
    }
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct FreshReplayAuthorization {
    pub execution_request_ref: String,
    pub grant_ref: String,
    #[serde(default)]
    pub authorized_event_ids: Vec<String>,
    #[serde(default)]
    pub authorized_effect_classes: Vec<String>,
}

impl FreshReplayAuthorization {
    pub fn permits(&self, event: &RunJournalEvent) -> bool {
        if self.execution_request_ref.trim().is_empty() || self.grant_ref.trim().is_empty() {
            return false;
        }
        if self.authorized_event_ids.is_empty() && self.authorized_effect_classes.is_empty() {
            return false;
        }
        if !self.authorized_event_ids.is_empty()
            && !self.authorized_event_ids.contains(&event.event_id)
        {
            return false;
        }
        if !self.authorized_effect_classes.is_empty()
            && !self
                .authorized_effect_classes
                .contains(&event.effect.effect_class)
        {
            return false;
        }
        true
    }
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct ReplayRequest {
    #[serde(default)]
    pub mode: ReplayMode,
    #[serde(default)]
    pub fresh_authorization: Option<FreshReplayAuthorization>,
}

impl ReplayRequest {
    pub fn sandbox() -> Self {
        Self {
            mode: ReplayMode::Sandbox,
            fresh_authorization: None,
        }
    }

    pub fn live(fresh_authorization: FreshReplayAuthorization) -> Self {
        Self {
            mode: ReplayMode::Live,
            fresh_authorization: Some(fresh_authorization),
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum ReplayDisposition {
    ReconstructOnly,
    Simulate,
    Sandbox,
    ReplayLive,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ReplayAction {
    pub event_id: String,
    pub sequence: u64,
    pub event_type: String,
    pub disposition: ReplayDisposition,
    #[serde(default)]
    pub payload_ref: Option<String>,
    #[serde(default)]
    pub note: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ReplayPlan {
    pub run_id: String,
    pub mode: ReplayMode,
    pub reconstruction: ReconstructionReport,
    pub actions: Vec<ReplayAction>,
}

#[derive(Debug, Error)]
pub enum ReplayError {
    #[error("run journal for {run_id} has no events to replay")]
    EmptyJournal { run_id: String },
    #[error(
        "event {event_id} belongs to run {event_run_id}, but manifest expects {manifest_run_id}"
    )]
    RunIdMismatch {
        event_id: String,
        event_run_id: String,
        manifest_run_id: String,
    },
    #[error("event {event_id} expected sequence {expected} but found {actual}")]
    SequenceGap {
        event_id: String,
        expected: u64,
        actual: u64,
    },
    #[error("event {event_id} previous hash {actual:?} does not match {expected}")]
    PreviousHashMismatch {
        event_id: String,
        expected: String,
        actual: Option<String>,
    },
    #[error("event {event_id} hash mismatch: expected {expected}, found {actual}")]
    EventHashMismatch {
        event_id: String,
        expected: String,
        actual: String,
    },
    #[error("journal manifest field {field} mismatch: expected {expected}, found {actual}")]
    ManifestMismatch {
        field: &'static str,
        expected: String,
        actual: String,
    },
    #[error("live replay of side-effecting event {event_id} is denied without fresh authorization")]
    MissingFreshAuthorization { event_id: String },
    #[error("live replay of event {event_id} requires payload artifact {missing_ref}")]
    MissingPayloadArtifact {
        event_id: String,
        missing_ref: String,
    },
    #[error("failed to serialize {subject} for hashing: {source}")]
    CanonicalSerialization {
        subject: &'static str,
        #[source]
        source: serde_json::Error,
    },
}

pub fn canonical_event_hash(event: &RunJournalEvent) -> Result<String, ReplayError> {
    #[derive(Serialize)]
    struct EventHashInput<'a> {
        schema_version: &'a str,
        run_id: &'a str,
        event_id: &'a str,
        sequence: u64,
        event_type: &'a str,
        recorded_at: &'a str,
        actor: &'a JournalActor,
        causal_parent_event_ids: &'a [String],
        idempotency_key: &'a Option<String>,
        lifecycle: &'a JournalLifecycle,
        governing_refs: &'a GoverningRefs,
        effect: &'a JournalEffect,
        payload_ref: &'a Option<String>,
        payload_hash: &'a Option<String>,
        redaction: &'a JournalRedaction,
        previous_event_hash: &'a Option<String>,
    }

    digest_value(
        "run-event-v2 envelope",
        &EventHashInput {
            schema_version: &event.schema_version,
            run_id: &event.run_id,
            event_id: &event.event_id,
            sequence: event.sequence,
            event_type: &event.event_type,
            recorded_at: &event.recorded_at,
            actor: &event.actor,
            causal_parent_event_ids: &event.causal_parent_event_ids,
            idempotency_key: &event.idempotency_key,
            lifecycle: &event.lifecycle,
            governing_refs: &event.governing_refs,
            effect: &event.effect,
            payload_ref: &event.payload_ref,
            payload_hash: &event.payload_hash,
            redaction: &event.redaction,
            previous_event_hash: &event.previous_event_hash,
        },
    )
}

pub fn canonical_manifest_digest(ledger: &RunJournalLedger) -> Result<String, ReplayError> {
    digest_value("run-event-ledger-v2", ledger)
}

pub fn canonical_manifest_integrity_digest(
    ledger: &RunJournalLedger,
) -> Result<String, ReplayError> {
    #[derive(Serialize)]
    struct ManifestIntegrityHashInput<'a> {
        schema_version: &'a str,
        run_id: &'a str,
        event_schema_ref: &'a Option<String>,
        runtime_state_schema_ref: &'a Option<String>,
        first_event_id: &'a Option<String>,
        last_event_id: &'a Option<String>,
        first_sequence: &'a Option<u64>,
        last_sequence: &'a Option<u64>,
        event_count: u64,
        first_event_hash: &'a Option<String>,
        last_event_hash: &'a Option<String>,
        redaction_refs: &'a [String],
        validator_refs: &'a [String],
        hash_chain_status: &'a str,
        drift_status: &'a str,
    }

    digest_value(
        "run-event-ledger-v2 integrity subset",
        &ManifestIntegrityHashInput {
            schema_version: &ledger.schema_version,
            run_id: &ledger.run_id,
            event_schema_ref: &ledger.event_schema_ref,
            runtime_state_schema_ref: &ledger.runtime_state_schema_ref,
            first_event_id: &ledger.first_event_id,
            last_event_id: &ledger.last_event_id,
            first_sequence: &ledger.first_sequence,
            last_sequence: &ledger.last_sequence,
            event_count: ledger.event_count,
            first_event_hash: &ledger.first_event_hash,
            last_event_hash: &ledger.last_event_hash,
            redaction_refs: &ledger.redaction_refs,
            validator_refs: &ledger.validator_refs,
            hash_chain_status: &ledger.hash_chain_status,
            drift_status: &ledger.drift_status,
        },
    )
}

pub fn canonical_event_stream_digest(events: &[RunJournalEvent]) -> Result<String, ReplayError> {
    digest_value("run-event-v2 stream", events)
}

pub fn validate_journal(journal: &RunJournal) -> Result<JournalIntegritySummary, ReplayError> {
    if journal.events.is_empty() {
        return Err(ReplayError::EmptyJournal {
            run_id: journal.manifest.run_id.clone(),
        });
    }

    let mut expected_sequence = journal.events[0].sequence;
    let mut previous_hash: Option<&str> = None;

    for event in &journal.events {
        if event.run_id != journal.manifest.run_id {
            return Err(ReplayError::RunIdMismatch {
                event_id: event.event_id.clone(),
                event_run_id: event.run_id.clone(),
                manifest_run_id: journal.manifest.run_id.clone(),
            });
        }

        if event.sequence != expected_sequence {
            return Err(ReplayError::SequenceGap {
                event_id: event.event_id.clone(),
                expected: expected_sequence,
                actual: event.sequence,
            });
        }

        match previous_hash {
            Some(expected) => {
                if event.previous_event_hash.as_deref() != Some(expected) {
                    return Err(ReplayError::PreviousHashMismatch {
                        event_id: event.event_id.clone(),
                        expected: expected.to_string(),
                        actual: event.previous_event_hash.clone(),
                    });
                }
            }
            None => {
                if event.previous_event_hash.as_deref().is_some_and(|hash| !hash.trim().is_empty())
                {
                    return Err(ReplayError::PreviousHashMismatch {
                        event_id: event.event_id.clone(),
                        expected: "<genesis>".to_string(),
                        actual: event.previous_event_hash.clone(),
                    });
                }
            }
        }

        let expected_hash = canonical_event_hash(event)?;
        if event.event_hash != expected_hash {
            return Err(ReplayError::EventHashMismatch {
                event_id: event.event_id.clone(),
                expected: expected_hash,
                actual: event.event_hash.clone(),
            });
        }

        previous_hash = Some(event.event_hash.as_str());
        expected_sequence += 1;
    }

    let first = journal.events.first().expect("checked above");
    let last = journal.events.last().expect("checked above");

    ensure_manifest_field(
        "first_event_id",
        journal.manifest.first_event_id.clone(),
        Some(first.event_id.clone()),
    )?;
    ensure_manifest_field(
        "last_event_id",
        journal.manifest.last_event_id.clone(),
        Some(last.event_id.clone()),
    )?;
    ensure_manifest_field(
        "first_sequence",
        journal.manifest.first_sequence.map(|value| value.to_string()),
        Some(first.sequence.to_string()),
    )?;
    ensure_manifest_field(
        "last_sequence",
        journal.manifest.last_sequence.map(|value| value.to_string()),
        Some(last.sequence.to_string()),
    )?;
    ensure_manifest_field(
        "event_count",
        Some(journal.manifest.event_count.to_string()),
        Some(journal.events.len().to_string()),
    )?;
    ensure_manifest_field(
        "first_event_hash",
        journal.manifest.first_event_hash.clone(),
        Some(first.event_hash.clone()),
    )?;
    ensure_manifest_field(
        "last_event_hash",
        journal.manifest.last_event_hash.clone(),
        Some(last.event_hash.clone()),
    )?;

    Ok(JournalIntegritySummary {
        manifest_ref: journal.manifest_ref.clone(),
        events_ref: journal.manifest.events_ref.clone(),
        event_count: journal.events.len() as u64,
        first_event_id: Some(first.event_id.clone()),
        last_event_id: Some(last.event_id.clone()),
        final_event_hash: Some(last.event_hash.clone()),
        manifest_digest: canonical_manifest_digest(&journal.manifest)?,
        manifest_integrity_digest: canonical_manifest_integrity_digest(&journal.manifest)?,
        event_stream_digest: canonical_event_stream_digest(&journal.events)?,
        hash_chain_status: if journal.manifest.hash_chain_status.trim().is_empty() {
            "verified".to_string()
        } else {
            journal.manifest.hash_chain_status.clone()
        },
    })
}

pub fn reconstruct_runtime_state(
    journal: &RunJournal,
    available_artifact_refs: &BTreeSet<String>,
) -> Result<ReconstructionReport, ReplayError> {
    let integrity = validate_journal(journal)?;
    let mut replay_gaps = Vec::new();
    let mut current_state = journal.events[0].lifecycle.state_before.clone();

    for event in &journal.events {
        if let Some(state_after) = non_empty(&event.lifecycle.state_after) {
            current_state = state_after.to_string();
        }

        if let Some(payload_ref) = &event.payload_ref {
            if !available_artifact_refs.contains(payload_ref) {
                replay_gaps.push(ReplayGap {
                    kind: ReplayGapKind::MissingPayloadArtifact,
                    run_id: event.run_id.clone(),
                    event_id: event.event_id.clone(),
                    sequence: event.sequence,
                    missing_ref: payload_ref.clone(),
                });
            }
        }
    }

    let last = journal.events.last().expect("validated journal is non-empty");
    let drift_status = if journal.manifest.drift_status.trim().is_empty()
        || journal.manifest.drift_status == "clean"
    {
        if replay_gaps.is_empty() {
            "clean".to_string()
        } else {
            "replay-gaps-detected".to_string()
        }
    } else {
        journal.manifest.drift_status.clone()
    };

    Ok(ReconstructionReport {
        integrity,
        runtime_state: ReconstructedRuntimeState {
            schema_version: "runtime-state-v2".to_string(),
            run_id: journal.manifest.run_id.clone(),
            state: current_state,
            source_ledger_ref: journal.manifest_ref.clone(),
            last_applied_event_id: last.event_id.clone(),
            last_applied_sequence: last.sequence,
            last_applied_event_hash: last.event_hash.clone(),
            materialized_at: last.recorded_at.clone(),
            materialized_by: "replay-store".to_string(),
            drift_status,
            drift_ref: None,
            replay_gap_refs: replay_gaps
                .iter()
                .map(|gap| gap.missing_ref.clone())
                .collect(),
        },
        replay_gaps,
    })
}

pub fn plan_replay(
    journal: &RunJournal,
    available_artifact_refs: &BTreeSet<String>,
    request: &ReplayRequest,
) -> Result<ReplayPlan, ReplayError> {
    let reconstruction = reconstruct_runtime_state(journal, available_artifact_refs)?;
    let replay_gaps = &reconstruction.replay_gaps;
    let mut actions = Vec::with_capacity(journal.events.len());

    for event in &journal.events {
        let missing_payload = replay_gaps
            .iter()
            .find(|gap| gap.event_id == event.event_id)
            .map(|gap| gap.missing_ref.clone());

        let (disposition, note) = if event.is_side_effecting() {
            match request.mode {
                ReplayMode::DryRun => (
                    ReplayDisposition::Simulate,
                    Some("defaulted to dry-run for side-effecting replay".to_string()),
                ),
                ReplayMode::Sandbox => (
                    ReplayDisposition::Sandbox,
                    if missing_payload.is_some() {
                        Some("sandbox replay is missing side-artifact input".to_string())
                    } else {
                        Some("sandbox replay keeps side effects isolated".to_string())
                    },
                ),
                ReplayMode::Live => {
                    if let Some(missing_ref) = missing_payload.clone() {
                        return Err(ReplayError::MissingPayloadArtifact {
                            event_id: event.event_id.clone(),
                            missing_ref,
                        });
                    }
                    let authorization = request
                        .fresh_authorization
                        .as_ref()
                        .ok_or_else(|| ReplayError::MissingFreshAuthorization {
                            event_id: event.event_id.clone(),
                        })?;
                    if !authorization.permits(event) {
                        return Err(ReplayError::MissingFreshAuthorization {
                            event_id: event.event_id.clone(),
                        });
                    }
                    (
                        ReplayDisposition::ReplayLive,
                        Some("fresh authorization permits live side-effect replay".to_string()),
                    )
                }
            }
        } else {
            (
                ReplayDisposition::ReconstructOnly,
                if missing_payload.is_some() {
                    Some("journal-first reconstruction detected a replay gap".to_string())
                } else {
                    Some("state derived directly from canonical journal".to_string())
                },
            )
        };

        actions.push(ReplayAction {
            event_id: event.event_id.clone(),
            sequence: event.sequence,
            event_type: event.event_type.clone(),
            disposition,
            payload_ref: event.payload_ref.clone(),
            note,
        });
    }

    Ok(ReplayPlan {
        run_id: journal.manifest.run_id.clone(),
        mode: request.mode,
        reconstruction,
        actions,
    })
}

fn digest_value<T: Serialize + ?Sized>(
    subject: &'static str,
    value: &T,
) -> Result<String, ReplayError> {
    let encoded = serde_json::to_vec(value)
        .map_err(|source| ReplayError::CanonicalSerialization { subject, source })?;
    let digest = Sha256::digest(encoded);
    Ok(format!("sha256:{}", hex::encode(digest)))
}

fn ensure_manifest_field(
    field: &'static str,
    actual: Option<String>,
    expected: Option<String>,
) -> Result<(), ReplayError> {
    if actual != expected {
        return Err(ReplayError::ManifestMismatch {
            field,
            expected: format_option(expected),
            actual: format_option(actual),
        });
    }
    Ok(())
}

fn format_option(value: Option<String>) -> String {
    value.unwrap_or_else(|| "<none>".to_string())
}

fn non_empty(value: &str) -> Option<&str> {
    if value.trim().is_empty() {
        None
    } else {
        Some(value)
    }
}

fn unique_strings(values: Vec<String>) -> Vec<String> {
    values
        .into_iter()
        .filter(|value| !value.trim().is_empty())
        .collect::<BTreeSet<_>>()
        .into_iter()
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample_event(
        sequence: u64,
        event_id: &str,
        event_type: &str,
        state_before: &str,
        state_after: &str,
        effect_class: &str,
        payload_ref: Option<&str>,
        previous_event_hash: Option<String>,
    ) -> RunJournalEvent {
        RunJournalEvent {
            schema_version: "run-event-v2".to_string(),
            run_id: "run-123".to_string(),
            event_id: event_id.to_string(),
            sequence,
            event_type: event_type.to_string(),
            recorded_at: format!("2026-04-22T00:00:0{sequence}Z"),
            actor: JournalActor {
                actor_class: "runtime".to_string(),
                actor_ref: "runtime-bus".to_string(),
            },
            causal_parent_event_ids: Vec::new(),
            idempotency_key: Some(format!("idem-{sequence}")),
            lifecycle: JournalLifecycle {
                state_before: state_before.to_string(),
                state_after: state_after.to_string(),
            },
            governing_refs: GoverningRefs {
                execution_request_ref: Some(".octon/state/control/execution/runs/run-123/request.yml".to_string()),
                grant_ref: Some(".octon/state/control/execution/runs/run-123/grant.yml".to_string()),
                policy_receipt_ref: Some(".octon/state/control/execution/runs/run-123/policy.yml".to_string()),
                support_target_tuple_ref: None,
                rollback_plan_ref: None,
                context_pack_ref: None,
                capability_lease_ref: None,
            },
            effect: JournalEffect {
                effect_class: effect_class.to_string(),
                reversibility_class: "compensable".to_string(),
                evidence_class: "required".to_string(),
            },
            payload_ref: payload_ref.map(ToString::to_string),
            payload_hash: payload_ref.map(|value| format!("sha256:{value}")),
            redaction: JournalRedaction {
                redacted: false,
                lineage_ref: None,
            },
            previous_event_hash,
            event_hash: String::new(),
        }
        .seal()
        .expect("sample event should hash")
    }

    fn sample_journal() -> RunJournal {
        let first = sample_event(
            1,
            "evt-1",
            "authority-granted",
            "authorized",
            "running",
            "observe",
            None,
            None,
        );
        let second = sample_event(
            2,
            "evt-2",
            "capability-invoked",
            "running",
            "running",
            "external-side-effect",
            Some(".octon/state/evidence/runs/run-123/receipts/capability.json"),
            Some(first.event_hash.clone()),
        );
        let third = sample_event(
            3,
            "evt-3",
            "run-closed",
            "running",
            "closed",
            "observe",
            None,
            Some(second.event_hash.clone()),
        );
        RunJournal::from_events(
            "run-123",
            ".octon/state/control/execution/runs/run-123/events.manifest.yml",
            ".octon/state/control/execution/runs/run-123/events.ndjson",
            vec![first, second, third],
        )
        .expect("sample journal should build")
    }

    #[test]
    fn canonical_bundle_ref_uses_runtime_roots() {
        let bundle = canonical_bundle_ref("run-123");
        assert_eq!(
            bundle.manifest_ref,
            ".octon/state/evidence/runs/run-123/replay/manifest.yml"
        );
        assert_eq!(
            bundle.external_index_ref,
            ".octon/state/evidence/external-index/runs/run-123.yml"
        );
    }

    #[test]
    fn reconstruct_runtime_state_prefers_journal_and_marks_missing_artifacts() {
        let journal = sample_journal();
        let report = reconstruct_runtime_state(&journal, &BTreeSet::new())
            .expect("journal reconstruction should succeed");

        assert_eq!(report.runtime_state.state, "closed");
        assert_eq!(report.runtime_state.last_applied_event_id, "evt-3");
        assert_eq!(report.runtime_state.source_ledger_ref, journal.manifest_ref);
        assert_eq!(report.replay_gaps.len(), 1);
        assert_eq!(
            report.replay_gaps[0].missing_ref,
            ".octon/state/evidence/runs/run-123/receipts/capability.json"
        );
        assert_eq!(report.runtime_state.drift_status, "replay-gaps-detected");
    }

    #[test]
    fn plan_replay_defaults_to_dry_run_for_side_effecting_events() {
        let journal = sample_journal();
        let plan = plan_replay(&journal, &BTreeSet::new(), &ReplayRequest::default())
            .expect("dry-run plan should succeed");

        assert_eq!(plan.mode, ReplayMode::DryRun);
        assert_eq!(plan.actions[0].disposition, ReplayDisposition::ReconstructOnly);
        assert_eq!(plan.actions[1].disposition, ReplayDisposition::Simulate);
        assert_eq!(plan.actions[2].disposition, ReplayDisposition::ReconstructOnly);
    }

    #[test]
    fn live_side_effect_replay_requires_fresh_authorization() {
        let journal = sample_journal();
        let err = plan_replay(
            &journal,
            &BTreeSet::from([String::from(
                ".octon/state/evidence/runs/run-123/receipts/capability.json",
            )]),
            &ReplayRequest {
                mode: ReplayMode::Live,
                fresh_authorization: None,
            },
        )
        .expect_err("live replay without authorization must fail");

        assert!(matches!(
            err,
            ReplayError::MissingFreshAuthorization { event_id } if event_id == "evt-2"
        ));
    }

    #[test]
    fn live_side_effect_replay_accepts_fresh_authorization() {
        let journal = sample_journal();
        let plan = plan_replay(
            &journal,
            &BTreeSet::from([String::from(
                ".octon/state/evidence/runs/run-123/receipts/capability.json",
            )]),
            &ReplayRequest::live(FreshReplayAuthorization {
                execution_request_ref:
                    ".octon/state/control/execution/runs/run-123/replay-request.yml".to_string(),
                grant_ref: ".octon/state/control/execution/runs/run-123/replay-grant.yml"
                    .to_string(),
                authorized_event_ids: vec!["evt-2".to_string()],
                authorized_effect_classes: vec!["external-side-effect".to_string()],
            }),
        )
        .expect("fresh authorization should permit live replay");

        assert_eq!(plan.actions[1].disposition, ReplayDisposition::ReplayLive);
    }

    #[test]
    fn validate_journal_rejects_hash_drift() {
        let mut journal = sample_journal();
        journal.events[1].event_hash = "sha256:tampered".to_string();

        let err = validate_journal(&journal).expect_err("tampered hash must fail");
        assert!(matches!(
            err,
            ReplayError::EventHashMismatch { event_id, .. } if event_id == "evt-2"
        ));
    }
}
