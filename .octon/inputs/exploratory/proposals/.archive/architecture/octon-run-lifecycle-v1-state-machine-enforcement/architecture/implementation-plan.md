# Implementation Plan

## Phase 0 — Preflight and inventory

1. Confirm the implemented Run Journal, Authorized Effect Token, and Context Pack Builder contracts are present.
2. Inventory every runtime operation that can bind, authorize, execute, pause, resume, checkpoint, stage, revoke, fail, rollback, succeed, deny, close, replay, or disclose a Run.
3. Assign each operation a stable lifecycle operation ID.
4. Confirm every operation currently writes through `runtime_bus` or identify violations.

## Phase 1 — Add machine-readable lifecycle contracts

1. Add `run-lifecycle-transition-v1.schema.json` with:
   - `run_id`
   - `actor_ref`
   - `operation_id`
   - `current_state_ref`
   - `requested_transition`
   - `required_refs`
   - `journal_head_before`
   - `outcome`
   - `journal_event_ref`
   - `fail_closed_reason_codes`
2. Add `run-lifecycle-reconstruction-v1.schema.json` with:
   - `run_id`
   - `journal_ref`
   - `manifest_ref`
   - `latest_sequence`
   - `latest_hash`
   - `reconstructed_state`
   - `runtime_state_ref`
   - `runtime_state_match`
   - `drift_findings`
   - `missing_side_artifact_refs`

## Phase 2 — Implement runtime transition gate

1. Implement lifecycle reconstruction from `events.ndjson` and `events.manifest.yml`.
2. Materialize `runtime-state.yml` only from accepted events and bounded side artifacts.
3. Reject direct mutation of `runtime-state.yml` or mismatch with journal as drift.
4. Validate all transitions against the state table in `run-lifecycle-v1.md`.
5. Validate state-specific required facts.
6. Append transition acceptance/rejection through `runtime_bus`.
7. Ensure transition failures are journaled as denied/rejected where safe and do not advance state.

## Phase 3 — Wire CLI and runtime operations

1. Route `octon run start` through draft/bound/authorized/running/staged/denied transitions.
2. Route `octon run resume` through paused/staged resumability checks.
3. Route `octon run checkpoint` through checkpoint event validation.
4. Route `octon run close` through closeout completeness gate.
5. Route `octon run replay` through dry-run/sandbox replay defaults.
6. Route `octon run disclose` through retained-evidence-only disclosure generation.

## Phase 4 — Enforce closeout

1. Verify terminal lifecycle event.
2. Verify retained evidence bundle exists.
3. Verify journal snapshot mirror hash-matches the control journal at closeout.
4. Verify rollback posture is current.
5. Verify RunCard/disclosure is generated from retained evidence only.
6. Verify blocking review and risk dispositions are resolved.
7. Refuse `closed` when any required fact is missing.

## Phase 5 — Assurance and fixtures

1. Add positive fixtures for legal paths:
   - denied request
   - successful run
   - paused/resumed successful run
   - failed then rolled back then closed
   - stage-only then closed
2. Add negative fixtures for illegal paths:
   - running before authorized
   - authorized without grant
   - effect token consumed outside running
   - closeout without evidence snapshot
   - runtime-state mismatch with journal
   - generated read model used as lifecycle source
   - replay attempts live side effects without fresh authorization
3. Add validator script and test script.
4. Retain validation evidence under `state/evidence/validation/assurance/run-lifecycle-v1/**`.

## Phase 6 — Cutover and cleanup

1. Enable lifecycle validator in local and CI assurance gates.
2. Update operator docs only where they describe live command behavior.
3. Regenerate derived read models from canonical state after implementation.
4. Archive this packet after promotion evidence exists outside the proposal tree.
