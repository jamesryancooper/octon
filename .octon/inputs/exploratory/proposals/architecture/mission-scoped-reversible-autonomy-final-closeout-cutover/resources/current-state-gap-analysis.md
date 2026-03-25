# Current-State Gap Analysis

This packet closes the exact gaps identified in the [implementation audit](./implementation-audit.md).
Each gap below is a normalized proposal-facing restatement of that artifact.

## Gap 1 — Lifecycle is still not obviously atomic

### Current state
The repo has a full seeded validation mission and a seed script, but the generic mission scaffold still looks authority-only and does not itself prove the default activation path.

### Risk
MSRAOM may be “implemented” for seeded missions while still ambiguous for new missions.

### Correction
Make seed-before-active the canonical lifecycle rule, validate it, and document it explicitly.

---

## Gap 2 — Forward intent is real but not yet universal

### Current state
A seeded mission has non-empty intent publication, but the repo does not yet prove the same invariant for every active material autonomous mission.

### Risk
Material autonomy could degrade into generic route behavior instead of slice-driven behavior.

### Correction
Require fresh, current, slice-linked intent for material autonomous work, with observe-only as the only empty-intent carveout.

---

## Gap 3 — Control-plane evidence is not yet broad enough

### Current state
Control receipts exist, but the full mutation set is not yet guaranteed and visibly enforced.

### Risk
Control mutations can happen without fully reconstructible evidence.

### Correction
Emit and validate receipts for every meaningful control mutation and state transition.

---

## Gap 4 — Burn/breaker automation is under-proven

### Current state
Policy, files, and evaluator state exist, but the retained-evidence-driven recomputation loop is not yet the explicit invariant.

### Risk
Autonomy tightening could drift toward static or partially manual semantics.

### Correction
Add a canonical reducer that recomputes burn and breaker state from evidence and control truth, emit receipts, and validate the loop.

---

## Gap 5 — Scenario-family precedence is mostly right but still partly implicit

### Current state
Generated route exists and is linked, but family/boundary/recovery precedence is not yet maximally transparent.

### Risk
Route behavior may remain correct but harder to trust or validate.

### Correction
Add explicit route provenance fields and validation for family/boundary/recovery precedence.

---

## Gap 6 — Generated awareness is real but not yet proven universal

### Current state
Summaries, digests, and mission views exist, but the repo still proves them mainly through a seeded mission and the current validator suite.

### Risk
Operator legibility could remain exemplar-heavy rather than lifecycle-guaranteed.

### Correction
Require those outputs for every active autonomous mission and validate them in blocking CI.

---

## Gap 7 — The last closure rule is still missing

### Current state
The repo is close enough that the remaining issue is not concept design, but proof that there is no lingering gap.

### Risk
MSRAOM remains “mostly done” rather than “done.”

### Correction
Adopt this final closeout packet, merge it atomically, archive the prior packet, and treat any remaining gap as a bug rather than as an unfinished architectural area.
