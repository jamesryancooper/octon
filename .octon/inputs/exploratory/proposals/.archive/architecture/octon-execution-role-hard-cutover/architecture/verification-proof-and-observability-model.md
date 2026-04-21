# Verification, Proof, and Observability Model

## Proof stack

The final proof stack is:

1. schema validators
2. support-target tuple validators
3. capability-pack admission validators
4. context-pack validators
5. runtime conformance tests
6. browser/API replay tests
7. rollback and recovery drills
8. intervention and lease drills
9. scenario suites
10. shadow runs
11. raw frontier-model baselines
12. RunCards and HarnessCards generated only from retained evidence

## Deterministic validators

Validators must check:

- no active `framework/agency/**`;
- no durable `agents`, `assistants`, `teams`, or `subagents` registries;
- execution-role registry shape;
- exactly one orchestrator per consequential run;
- specialists are stateless and bounded;
- verifiers have activation criteria;
- context-pack presence for consequential runs;
- support-target tuple admission;
- capability-pack admission;
- rollback posture;
- browser/API service and proof prerequisites;
- generated non-authority.

## Runtime conformance

Runtime conformance tests must prove:

- all material actions pass `authorize_execution`;
- denials emit reason codes;
- receipts emit for material attempts;
- checkpoints emit at required boundaries;
- replay pointers exist;
- rollback and intervention events are retained.

## Browser/API proof

Browser/API support requires:

- runtime service entry in `manifest.runtime.yml`;
- egress lease;
- action record;
- event ledger;
- redaction metadata;
- replay manifest;
- support dossier;
- scenario and shadow evidence.

## Verifier role

Verifier is optional and activated only for high materiality, separation of
duties, support proof, weak deterministic coverage, or subjective quality. It is
not a default multi-agent pattern.

## RunCards and HarnessCards

RunCards and HarnessCards must be generated from retained evidence only. They may
summarize but never replace:

- run receipts;
- replay pointers;
- evidence classification;
- context-pack receipts;
- support dossier;
- validation results.

## Baseline benchmarks

Every claimed agency-runtime improvement must compare:

1. raw frontier model with equivalent context;
2. same model with thin tool wrapper;
3. Octon-governed run;
4. Octon-governed run with verifier when applicable.

Metrics:

- success rate;
- unauthorized action prevention;
- false block rate;
- evidence completeness;
- replayability;
- rollback success;
- intervention latency;
- cost;
- wall-clock time;
- support-claim conformance.
