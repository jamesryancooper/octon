# Target Architecture

## Decision

Align the native Architectural Review Mechanism as a single discoverable,
validator-backed mechanism across durable docs, invocation surfaces, generated
projections, and operator navigation.

The implementation should preserve the existing authority model:

- `pre-integration-architecture-review` is the lifecycle-gated review for
  architecture proposal acceptance and implementation authorization.
- `post-integration-architecture-review` remains evidence-only unless a future
  explicit lifecycle policy changes that.
- `current-state-mechanism-architecture-review` remains evidence-only unless a
  future explicit lifecycle policy changes that.
- `architecture-readiness-audit`, `domain-architecture-audit`, and
  `surface-architecture-audit` remain audit/evidence modes unless a future
  explicit lifecycle policy changes them.
- Implementation conformance and post-implementation drift/churn stay separate
  hard closeout gates.

## Required Alignment

### Product Navigation

Decide whether the Architectural Review Mechanism needs a product feature
entry. If it does, add an `architectural-review-mechanism` feature file and
catalog entry that is explicitly navigation-only. If it does not, document the
durable exclusion rule in both the governed mechanism index and product
feature guidance.

### Mode Naming

Resolve the domain and surface mode naming mismatch. The durable methodology
currently uses `domain-architecture-audit` and `surface-architecture-audit`,
while invocation surfaces use `audit-domain-architecture` and
`audit-surface-architecture`.

The implementation must choose one of these routes:

1. rename invocation surfaces to the canonical methodology slugs; or
2. retain the existing invocation names as documented aliases and teach
   validators to require an explicit canonical-mode-to-invocation mapping.

Do not change the established `architecture-readiness-audit` slug.

### Governed Mechanism Coverage

Update the governed cross-surface mechanism entry so its runtime
implementation refs, generated refs, retained evidence refs, and
not-applicable rationales cover all declared review modes. If domain and
surface audits are intentionally outside the native mechanism, record that
boundary explicitly.

### Invocation Surfaces

Clarify whether `architecture-readiness-audit`, domain audit, and surface audit
need command facades in addition to skills and workflow registry command
metadata. Any intentional omission must be documented and validator-covered.

### Validators

Extend validators so they fail closed on:

- undeclared canonical mode aliases;
- missing mechanism-index refs for declared modes;
- missing or intentionally omitted product feature documentation without a
  rationale;
- command facade ambiguity for modes that are declared operator-facing;
- stale generated effective capability projections;
- stale generated proposal projections after active packet changes;
- stale `audit-architecture-readiness` use outside retired-name documentation,
  validators, or historical evidence.

### Publication

Generated projections must be regenerated only through canonical scripts. The
implementation must not hand-edit `.octon/generated/**`, `.codex/commands/**`,
or `.codex/skills/**`.

## Authority Boundary

Workflows are canonical execution contracts. Skills and commands are thin
invocation surfaces. Product feature entries are navigation-only. Generated
projections are derived-only. Raw inputs, proposal packets, extension
packetization, chat, model memory, host state, dashboards, and lifecycle
postmortems cannot authorize review outcomes, lifecycle gates, generated
publication, or closeout.
