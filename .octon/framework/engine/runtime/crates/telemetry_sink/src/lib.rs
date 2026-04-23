use octon_replay_store::{ReplayDisposition, ReplayPlan};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Default, PartialEq, Serialize, Deserialize)]
pub struct TelemetryTotals {
    pub latency_ms: u64,
    pub retry_count: u32,
    pub intervention_count: u32,
    pub token_usage: u64,
    pub cost_microusd: u64,
}

impl TelemetryTotals {
    pub fn absorb(&mut self, other: &TelemetryTotals) {
        self.latency_ms += other.latency_ms;
        self.retry_count += other.retry_count;
        self.intervention_count += other.intervention_count;
        self.token_usage += other.token_usage;
        self.cost_microusd += other.cost_microusd;
    }
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct EventTelemetry {
    pub event_id: String,
    pub event_type: String,
    pub disposition: String,
}

#[derive(Debug, Clone, Default, PartialEq, Serialize, Deserialize)]
pub struct TelemetryEnvelope {
    pub source_manifest_ref: String,
    pub source_events_ref: String,
    pub replay_mode: String,
    pub non_authority_classification: String,
    pub actions_recorded: usize,
    pub simulated_side_effects: usize,
    pub live_side_effects: usize,
    pub totals: TelemetryTotals,
    #[serde(default)]
    pub events: Vec<EventTelemetry>,
}

impl TelemetryEnvelope {
    pub fn from_replay_plan(plan: &ReplayPlan) -> Self {
        let mut simulated_side_effects = 0_usize;
        let mut live_side_effects = 0_usize;
        let events = plan
            .actions
            .iter()
            .map(|action| {
                match action.disposition {
                    ReplayDisposition::Simulate | ReplayDisposition::Sandbox => {
                        simulated_side_effects += 1;
                    }
                    ReplayDisposition::ReplayLive => {
                        live_side_effects += 1;
                    }
                    ReplayDisposition::ReconstructOnly => {}
                }
                EventTelemetry {
                    event_id: action.event_id.clone(),
                    event_type: action.event_type.clone(),
                    disposition: format!("{:?}", action.disposition).to_lowercase(),
                }
            })
            .collect::<Vec<_>>();

        Self {
            source_manifest_ref: plan.reconstruction.integrity.manifest_ref.clone(),
            source_events_ref: plan.reconstruction.integrity.events_ref.clone(),
            replay_mode: format!("{:?}", plan.mode).to_lowercase(),
            non_authority_classification: "derived-telemetry".to_string(),
            actions_recorded: plan.actions.len(),
            simulated_side_effects,
            live_side_effects,
            totals: TelemetryTotals::default(),
            events,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use octon_replay_store::{
        FreshReplayAuthorization, GoverningRefs, JournalActor, JournalEffect, JournalLifecycle,
        JournalRedaction, ReplayMode, ReplayRequest, RunJournal, RunJournalEvent,
        RunJournalLedger, plan_replay,
    };
    use std::collections::BTreeSet;

    fn sample_event(
        sequence: u64,
        event_id: &str,
        event_type: &str,
        effect_class: &str,
        previous_event_hash: Option<String>,
    ) -> RunJournalEvent {
        let mut event = RunJournalEvent {
            schema_version: "run-event-v2".to_string(),
            run_id: "run-123".to_string(),
            event_id: event_id.to_string(),
            sequence,
            event_type: event_type.to_string(),
            recorded_at: format!("2026-04-22T12:00:0{sequence}Z"),
            actor: JournalActor {
                actor_class: "runtime".to_string(),
                actor_ref: "runtime-bus".to_string(),
            },
            causal_parent_event_ids: Vec::new(),
            idempotency_key: Some(format!("id-{sequence}")),
            lifecycle: JournalLifecycle {
                state_before: "running".to_string(),
                state_after: "running".to_string(),
            },
            governing_refs: GoverningRefs {
                execution_request_ref: Some("request".to_string()),
                grant_ref: Some("grant".to_string()),
                policy_receipt_ref: None,
                support_target_tuple_ref: None,
                rollback_plan_ref: None,
                context_pack_ref: None,
                capability_lease_ref: None,
            },
            effect: JournalEffect {
                effect_class: effect_class.to_string(),
                reversibility_class: "reversible".to_string(),
                evidence_class: "required".to_string(),
            },
            payload_ref: None,
            payload_hash: None,
            redaction: JournalRedaction {
                redacted: false,
                lineage_ref: None,
            },
            previous_event_hash,
            event_hash: String::new(),
        };
        event = event.seal().expect("event should hash");
        event
    }

    fn sample_plan() -> ReplayPlan {
        let first = sample_event(1, "evt-1", "run-created", "observe", None);
        let second = sample_event(
            2,
            "evt-2",
            "capability-invoked",
            "external-side-effect",
            Some(first.event_hash.clone()),
        );
        let journal = RunJournal {
            manifest_ref: ".octon/state/control/execution/runs/run-123/events.manifest.yml"
                .to_string(),
            manifest: RunJournalLedger::from_events(
                "run-123",
                ".octon/state/control/execution/runs/run-123/events.ndjson",
                &[first.clone(), second.clone()],
            )
            .expect("ledger should build"),
            events: vec![first, second],
        };

        plan_replay(
            &journal,
            &BTreeSet::new(),
            &ReplayRequest::live(FreshReplayAuthorization {
                execution_request_ref: "request".to_string(),
                grant_ref: "grant".to_string(),
                authorized_event_ids: vec!["evt-2".to_string()],
                authorized_effect_classes: vec!["external-side-effect".to_string()],
            }),
        )
        .expect("replay plan should build")
    }

    #[test]
    fn absorb_accumulates_runtime_measurements() {
        let mut base = TelemetryTotals {
            latency_ms: 10,
            retry_count: 1,
            intervention_count: 0,
            token_usage: 120,
            cost_microusd: 400,
        };
        base.absorb(&TelemetryTotals {
            latency_ms: 5,
            retry_count: 2,
            intervention_count: 1,
            token_usage: 80,
            cost_microusd: 600,
        });

        assert_eq!(base.latency_ms, 15);
        assert_eq!(base.retry_count, 3);
        assert_eq!(base.intervention_count, 1);
        assert_eq!(base.token_usage, 200);
        assert_eq!(base.cost_microusd, 1000);
    }

    #[test]
    fn telemetry_envelope_tracks_replay_lineage_without_minting_authority() {
        let envelope = TelemetryEnvelope::from_replay_plan(&sample_plan());

        assert_eq!(
            envelope.source_manifest_ref,
            ".octon/state/control/execution/runs/run-123/events.manifest.yml"
        );
        assert_eq!(envelope.non_authority_classification, "derived-telemetry");
        assert_eq!(envelope.actions_recorded, 2);
        assert_eq!(envelope.live_side_effects, 1);
        assert_eq!(envelope.simulated_side_effects, 0);
    }

    #[test]
    fn telemetry_envelope_counts_simulated_side_effects() {
        let first = sample_event(1, "evt-1", "run-created", "observe", None);
        let second = sample_event(
            2,
            "evt-2",
            "capability-invoked",
            "external-side-effect",
            Some(first.event_hash.clone()),
        );
        let journal = RunJournal {
            manifest_ref: ".octon/state/control/execution/runs/run-123/events.manifest.yml"
                .to_string(),
            manifest: RunJournalLedger::from_events(
                "run-123",
                ".octon/state/control/execution/runs/run-123/events.ndjson",
                &[first.clone(), second.clone()],
            )
            .expect("ledger should build"),
            events: vec![first, second],
        };
        let plan = plan_replay(&journal, &BTreeSet::new(), &ReplayRequest::default())
            .expect("default replay plan should build");
        let envelope = TelemetryEnvelope::from_replay_plan(&plan);

        assert_eq!(envelope.replay_mode, format!("{:?}", ReplayMode::DryRun).to_lowercase());
        assert_eq!(envelope.simulated_side_effects, 1);
        assert_eq!(envelope.live_side_effects, 0);
    }
}
