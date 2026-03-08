# Failure Modes And Safety Analysis

## Purpose

Make the major orchestration failure modes explicit and tie them to containment,
escalation, validation, and design boundaries.

This document exists to reduce promotion risk before live `.harmony`
canonicalization.

## Why Failure Analysis Is Needed

The orchestration model is intentionally autonomous within policy boundaries.
That autonomy is only safe if common failure modes are named, contained, and
validated before promotion.

## Analysis Scope

Highest-risk areas:

- `watchers`
- `queue`
- `automations`
- `runs` / evidence linkage
- `incidents`
- cross-surface references
- routing / authority controls

## Failure Mode Matrix

### FM-01 Duplicate Event Or Duplicate Launch

- Description: same semantic condition produces repeated events or repeated
  launches
- Likely Cause: unstable `dedupe_key`, weak idempotency strategy, replayed queue
  items
- Also Likely Cause: ambiguous overlap handling between `drop`, `parallel`, and
  `replace`
- Affected Surfaces: `watchers`, `queue`, `automations`, `runs`
- Effect: repeated work, retry storms, operator confusion
- Detection: duplicate `event_id` patterns, repeated idempotency keys, multiple
  runs for one semantic trigger
- Containment: suppress duplicate emission, drop or serialize duplicate launch
  per automation policy
- Escalation: required if repeated duplication crosses policy thresholds
- Evidence: event envelope, queue receipts, decision records, run lineage,
  automation counters
- Related Validation: routing determinism, queue correctness, evidence
  traceability
- Prevention: stable `dedupe_key`, strict idempotency policy, explicit
  concurrency mode

### FM-02 Stuck Lease Or Unacknowledged Queue Item

- Description: claimed queue item never completes and never returns to a
  claimable lane
- Likely Cause: lost claimant, bad lease expiry logic, stale or reused
  `claim_token`, missing ack receipt path
- Affected Surfaces: `queue`, `automations`
- Effect: hidden work loss or backlog stall
- Detection: expired `claim_deadline`, claimed items older than threshold,
  acknowledgement attempts with mismatched `claim_token`
- Containment: deterministic move to `retry`, operator-visible expired-lease
  count
- Escalation: required if stale queue accumulation crosses operational
  threshold
- Evidence: queue item state, `claimed_at`, `claim_token`, receipt absence, lease
  timestamps
- Related Validation: queue lease and retry checks
- Prevention: strict lease expiry rules, mandatory receipts, validation of claim
  transitions

### FM-03 Lost Or Partial Evidence Linkage

- Description: run exists without complete continuity evidence linkage, or
  evidence bundle exists without a valid run projection
- Likely Cause: partial write, projection drift, failed continuity write
- Affected Surfaces: `runs`, `continuity`, `incidents`, `missions`
- Effect: audit gaps, broken lineage, unverifiable completion
- Detection: unresolved `continuity_run_path`, orphaned evidence bundle,
  missing reverse links
- Containment: fail validation, block completion/closure, mark run incomplete
- Escalation: required for material runs lacking evidence linkage
- Evidence: run record, continuity path check, validation failure output
- Related Validation: evidence traceability, promotion gates `G3` and `G6`
- Prevention: two-phase write discipline, linkage validation, no duplication of
  durable evidence in runtime state

### FM-04 Incident State Drifting Into Policy Space

- Description: incident runtime state begins acting as policy authority instead
  of using governance policy
- Likely Cause: incident workflow shortcuts, undocumented closure rules,
  ad hoc operator fields
- Affected Surfaces: `incidents`, `governance`, `runs`
- Effect: silent authority expansion, inconsistent escalation/closure behavior
- Detection: incident fields used to override policy without governance source,
  missing closure authority evidence
- Containment: block closure or escalated action until governance prerequisites
  resolve
- Escalation: always required
- Evidence: incident timeline, closure actor, linked policy authority
- Related Validation: authority-boundary checks, incident closure checks
- Prevention: explicit governance/runtime separation, closure authority rules,
  ADR review for authority changes

### FM-05 Unauthorized Or Under-Authorized Execution

- Description: material work launches without sufficient authority or clear
  routing basis
- Likely Cause: missing prerequisite checks, ambiguous objective scope, stale
  approvals
- Affected Surfaces: `automations`, `workflows`, `incidents`, `runs`
- Effect: unsafe side effects, policy violation, unverifiable execution
- Detection: missing allow decision basis, absent approvals, unresolved scope
- Containment: `block` or `escalate`; do not launch
- Escalation: required
- Evidence: blocked or escalated decision record, related references
- Related Validation: fail-closed checks, authority-boundary checks
- Prevention: route before act, materiality checks, explicit operator-visible
  block reasons

### FM-06 Stale References Or Broken Lineage

- Description: cross-surface references resolve to missing or wrong targets
- Likely Cause: renamed artifacts, incomplete updates, contract drift
- Affected Surfaces: all, especially `missions`, `runs`, `incidents`,
  `automations`
- Effect: broken routing, missing traceability, false completion signals
- Detection: unresolved canonical IDs, validation failure, reverse lookup gaps
- Containment: block execution or completion; do not guess replacements
- Escalation: required if material action cannot route safely
- Evidence: reference resolution errors, failed validation results
- Related Validation: contract conformance, routing determinism, evidence
  traceability
- Prevention: canonical identifiers, update discipline, compatibility policy

### FM-07 Retry Storm Or Replay Hazard

- Description: retries amplify failures or replay old work unsafely
- Likely Cause: weak retry policy, missing backoff, absent idempotency
- Affected Surfaces: `automations`, `queue`, `runs`
- Effect: thundering herd, duplicate runs, operational instability
- Detection: rapidly increasing retry counts, repeated failed runs with same
  lineage
- Containment: pause automation, cap retries, move items to `dead_letter`
- Escalation: required when containment does not stabilize retries
- Evidence: automation counters, queue retry counts, run lineage
- Related Validation: queue correctness, automation policy checks
- Prevention: bounded retry policy, strong idempotency, pause-on-error behavior

### FM-08 Watcher Emission Ambiguity

- Description: watcher emits events that cannot be routed deterministically
- Likely Cause: incomplete event envelope, ambiguous event type, missing target
  hint, weak source semantics
- Affected Surfaces: `watchers`, `queue`, `automations`
- Effect: ambiguous routing, dropped or misrouted work
- Detection: queue items without resolvable automation target, event validation
  failures
- Containment: block queue creation or route to dead-letter/diagnostic handling
- Escalation: required when ambiguity affects material automation launch
- Evidence: raw event, validation error, operator-visible blocked status
- Related Validation: watcher event contract, routing determinism checks
- Prevention: strict event envelope contract, explicit trigger selection in
  `trigger.yml`

### FM-09 Contract Drift Across Promoted Surfaces

- Description: promoted surface implementations evolve incompatibly with the
  package contracts
- Likely Cause: unversioned changes, undocumented field evolution, missing ADRs
- Affected Surfaces: all promoted surfaces
- Effect: schema mismatch, routing failures, broken evidence tooling
- Detection: version mismatch, validation failures, incompatible readers
- Containment: block rollout, fail validation, require explicit compatibility
  handling
- Escalation: required for breaking discovery, evidence, or authority changes
- Evidence: version metadata, validation failures, ADR references
- Related Validation: contract compatibility checks, promotion gates
- Prevention: contract versioning policy, ADR trigger rules, staged rollout

### FM-10 Unsafe Replace Preemption

- Description: automation `replace` preempts work that cannot be cancelled
  safely
- Likely Cause: missing or incorrect `execution_controls.cancel_safe`
- Affected Surfaces: `automations`, `workflows`, `runs`
- Effect: partial side effects, duplicated follow-up work, unverifiable state
- Detection: replace requested on workflow without explicit cancel-safe
  declaration, repeated cancellation failures
- Containment: block replacement, preserve active run, emit decision record
- Escalation: required when operator override is requested
- Evidence: decision record, run cancellation state, automation counters
- Related Validation: authority-boundary checks, automation policy checks
- Prevention: require `execution_controls.cancel_safe=true` before allowing
  replace

## Explicit Prohibited Behaviors

- watcher launching workflows directly
- queue targeting missions directly
- runtime projections becoming the durable evidence source
- incidents self-authorizing policy exceptions
- unknown lifecycle states being treated as safe
- stale references being guessed or auto-corrected without authority

## Open Design Decisions

These remain intentionally open and should not be papered over:

- concrete storage backend choices
- default lease timeout values
- default retry backoff values
- operator UI implementation details

## Safety Position

The orchestration model is safe to promote only when:

- high-risk failure modes are covered by validation
- blocked and escalated outcomes are visible and evidenced
- containment paths are deterministic
- no surface exceeds its bounded authority
