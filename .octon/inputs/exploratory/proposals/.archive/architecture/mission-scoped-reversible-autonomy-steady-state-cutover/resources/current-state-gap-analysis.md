# Current State Gap Analysis

This analysis assumes the repo is already on the **substantially landed**
`0.6.0` MSRAOM baseline.

It now also incorporates `resources/implementation-audit.md`, whose verdict is
that the repo is **partially complete with moderate gaps**: the operating
model spine is real, but the closeout conditions for a clean steady-state
cutover are not yet satisfied.

## What Is Already Real

The following are already present in the repo and are *not* being redesigned:

- canonical MSRAOM naming and governance principle
- mission-autonomy policy
- ownership registry
- mission-aware execution request/receipt/policy receipt contracts
- mission-control schemas for lease, mode state, intent register, directives,
  schedule, autonomy budget, circuit breakers, and subscriptions
- generated scenario-resolution for the seeded validation mission
- generated `Now / Next / Recent / Recover`
- at least one generated operator digest
- evaluator logic that consumes mission control and route state
- retained control-evidence root
- seeded live-validation mission

Those are significant gains. This packet exists because the remaining gaps are
the ones that still keep MSRAOM from a true steady state.

## Remaining Gaps To Close

### 1. Version-parity gap
`version.txt` and `.octon/octon.yml` still do not agree on the live release
version.

**Why it matters:** a steady-state cutover cannot claim ratified completion if
the root version surfaces already drift on the baseline.

### 2. Mission scaffold gap
The mission scaffold still creates only the authored charter and a small set of
notes/tasks files. It does not create the full mission-control family and it
does not guarantee route/summaries/projections exist immediately after mission
creation.

**Why it matters:** active mission creation is still not atomic.

### 3. Interaction grammar gap
`Inspect / Signal / Authorize-Update` is described conceptually, but the
control-file family only partially reflects it. Directives exist; a dedicated
authorize-update queue does not.

**Why it matters:** synchronous authority mutations are not yet first-class
mission control truth.

### 4. Route linkage gap
A generated scenario-resolution artifact exists, but route linkage is still
weaker than it should be. The live mode state is not yet a hard proof that the
mission is bound to a fresh current route.

**Why it matters:** runtime, summaries, and schedulers can drift if route
freshness and linkage are not invariants.

### 5. Empty-intent and generic-route gap
Forward intent publication exists as a file, but the committed validation
mission still demonstrates an empty register. Route recovery currently proves
plumbing more than it proves slice-derived behavior.

**Why it matters:** material autonomous work must not depend on empty-intent or
generic action-class fallback semantics.

### 6. Safe-boundary taxonomy gap
The policy’s scenario/boundary vocabulary and the live effective route are not
fully normalized.

**Why it matters:** safe interruption should not degrade to generic or weaker
pause behavior because of taxonomy mismatch.

### 7. Breaker/budget normalization gap
Burn and breaker surfaces exist, but the update path, vocabulary alignment,
and evidence coverage are not yet strong enough to count as steady-state
trust-tightening.

**Why it matters:** trust tightening must be automatic, not implied by files
that never change.

### 8. Evidence coverage gap
Control evidence exists, but broad mutation coverage is not yet demonstrated
or enforced across directives, authorize-updates, schedule mutations, safing,
break-glass, breaker transitions, and closeout/finalize controls.

**Why it matters:** the operator cannot trust control history if only some
mutations are receipted.

### 9. Generalization gap in read models
Mission summaries and one operator digest exist. The manifest also names a
mission-projection root. But the full operator- and machine-view lifecycle is
not yet clearly generalized across all active missions.

**Why it matters:** seeded proof is not the same thing as steady-state
behavior.

### 10. CI enforcement gap
The contract registry names mission-runtime and scenario blocking checks, but
the visible main architecture-conformance workflow still does not clearly run
the full set.

**Why it matters:** without blocking CI, regressions are easy and invisible.

### 11. No-defer rule
Earlier proposals closed many gaps, but left a few still open. This packet is
explicitly the *last* corrective pass. It must leave no known issue behind.

## Summary

The repo is no longer “missing MSRAOM.” The audit confirms the hard parts are
present, but also confirms that the remaining unresolved issues are exactly the
ones that matter most for trust, correctness, operator legibility, and release
ratification.

That is exactly why they should be closed in one final clean break.
