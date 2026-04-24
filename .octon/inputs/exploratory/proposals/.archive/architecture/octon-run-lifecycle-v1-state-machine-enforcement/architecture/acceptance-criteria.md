# Acceptance Criteria

The implementation is accepted only when all criteria below are met. Status was
reviewed on 2026-04-24 against the current shared worktree and retained
validation report. This checklist is proposal-local closure evidence only and
does not promote the proposal to authority.

## Functional criteria

- [x] Every runtime entrypoint that can change Run lifecycle state calls the lifecycle transition gate.
- [x] The transition gate reconstructs current lifecycle state from `events.ndjson` and `events.manifest.yml` before accepting a state change.
- [x] `runtime-state.yml` is rebuilt from journal-derived state and bounded side artifacts.
- [x] Journal/runtime-state mismatch is detected and blocks consequential transitions.
- [x] All `run-lifecycle-v1.md` states and allowed exits are represented in code/tests.
- [x] Invalid transitions fail closed with reason codes and retained evidence.
- [x] Raw `runtime_bus::append_event` cannot bypass the transition matrix.
- [x] Raw `runtime_bus::append_event` rejects fake closeout refs, unresolved
  blocking risks, non-stage-only staged routing, and relative or absolute
  generated/input governing refs.
- [x] Active durable scripts are guarded from direct writes to canonical
  `.octon/state/control/execution/runs/<run-id>/events.ndjson` and
  `events.manifest.yml` outside the runtime-owned journal path.

## Authority criteria

- [x] `authorized` cannot be entered without decision artifact and grant bundle refs.
- [x] `running` cannot invoke material effects without valid `AuthorizedEffect<T>` -> `VerifiedEffect` verification.
- [x] Expired, revoked, already-consumed, out-of-scope, or wrong-state effect tokens reject.
- [x] Generated/operator read models never serve as lifecycle authority.
- [x] Absolute refs into `generated/**` or `inputs/**` are normalized and
  rejected at the canonical append boundary.

## Context criteria

- [x] Authorization requires a valid Context Pack Builder v1 receipt.
- [x] Resume validates context freshness or rebuilds/denies according to policy.
- [x] Context compaction/invalidation events are journaled and state-aware.

## Evidence and closeout criteria

- [x] `closed` requires evidence-store completeness.
- [x] `closed` requires journal closeout snapshot linkage and hash match.
- [x] `closed` requires current rollback posture.
- [x] `closed` requires canonical disclosure/RunCard from retained evidence only.
- [x] `closed` requires review and risk disposition facts.
- [x] Unresolved blocking risks prevent closure.
- [x] Missing required evidence blocks closure.

## Assurance criteria

- [x] Lifecycle validator exists and passes on positive fixtures.
- [x] Lifecycle validator fails on negative fixtures.
- [x] Static append-boundary guard passes and is included in retained lifecycle
  validation coverage.
- [x] Retained validation evidence lands under `.octon/state/evidence/validation/assurance/run-lifecycle-v1/**`.
- [x] Support-target proof can cite deterministic lifecycle reconstruction for admitted repo-consequential tuples.

## Governance criteria

- [x] No new top-level root is introduced.
- [x] No support target is widened.
- [x] No proposal-local file is promoted as runtime authority.
- [x] No rival control plane is introduced.

## Validation references

- `.octon/state/evidence/validation/assurance/run-lifecycle-v1/validation-report.yml`
  records `status: pass` and covers positive transitions, invalid-transition
  fail-closed behavior, journal-derived runtime state, closeout completeness,
  boundary composition, authority preconditions, context refresh, generated
  non-authority, effect-token preconditions, pause/resume, rollback, denial,
  stage-only cases, journal append-boundary protection, and unknown lifecycle
  state negative controls.
- Local closure validation passed `git diff --check`, `jq empty` for both
  lifecycle schema files, the lifecycle validator, the lifecycle shell
  regression harness, run-journal contract validation, lifecycle transition
  coverage validation, run-journal append-boundary validation, UEC packet
  certification validation, full runtime crate tests with `--test-threads=1`,
  and the packet-local `SHA256SUMS.txt` verification.
- Promotion cleanliness is part of acceptance: rerunning the required validation
  stack after staging must leave `git diff --name-only` empty.
