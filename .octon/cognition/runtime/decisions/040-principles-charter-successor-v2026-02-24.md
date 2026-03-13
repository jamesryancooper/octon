# ADR 040: Principles Charter Successor v2026-02-24

- Date: 2026-02-24
- Status: Superseded by ADR 042
- Deciders: Octon maintainers
- Supersedes: `020-principles-charter-successor-v2026-02-20`
- Superseded-by:
  - `042-principles-charter-human-override-direct-edit-policy`
- Related:
  - `/.octon/cognition/governance/principles/principles.md`
  - `/.octon/cognition/governance/principles/README.md`
  - `/.octon/cognition/governance/principles/index.yml`

## Context

At the time of this ADR, `/.octon/cognition/governance/principles/principles.md`
was treated as immutable by policy and not directly editable. Octon needed
active framing alignment for three canonical requirements:

1. agent-first purpose for cross-project standardization,
2. managed complexity through complexity calibration and complexity fitness,
3. system-governed operation with default policy/workflow/check execution.

ADR 020 established the successor pattern but references a prior successor file
that is not present in the current repository path structure. Active framing
therefore requires a new discoverable successor artifact plus explicit
supersession.

## Decision

Adopt a new versioned successor charter at (now retired by ADR 042):

- Retired successor artifact for this ADR (removed after ADR 042).

This successor defines active canonical framing while preserving immutable
charter policy:

1. Octon standardizes agent operation through shared contracts, workflows,
   capabilities, safety controls, and auditability.
2. Governance is system-governed by default through encoded contracts, policy,
   workflow, and enforcement checks.
3. Humans retain governance authorship, exceptions, and escalation authority.
4. Complexity language is normalized to `minimal sufficient complexity`,
   `Complexity Calibration`, and `Complexity Fitness`.
5. Canonical assurance/governance attribute id is locked to
   `complexity_calibration`.

Also update principles discovery surfaces (`README.md` and `index.yml`) to
reference both immutable charter and the successor path (historical).

## Consequences

### Benefits

- Preserved then-current immutable-charter guarantees while enabling active framing updates.
- Restores discoverable, path-correct successor governance for current work.
- Provides a deterministic baseline for downstream migration waves.

### Costs

- Introduces another successor version requiring explicit supersession tracking.
- Requires downstream docs/contracts to migrate legacy terminology.

### Follow-on Work

1. Replace active principle surface references from legacy simplicity wording to
   complexity calibration terminology.
2. Migrate contract, methodology, assurance, capabilities, and scaffolding
   surfaces to canonical framing.
3. Add regression checks to prevent deprecated framing reintroduction.

## Status Update (2026-02-24)

- ADR 042 supersedes this ADR's active policy posture.
- The successor artifact path is retained in this record as historical context
  and is no longer an active governance discovery target.
