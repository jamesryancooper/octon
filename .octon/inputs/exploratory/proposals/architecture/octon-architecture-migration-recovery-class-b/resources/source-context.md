# Source Context

## Coordination And Proof Baseline

This packet derives from:

`.octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/`

The intake controls accepted operator intent while remaining non-authoritative
pending formal promotion. The following reconciliation sources control RP-08
packet coordination, current findings, engineering refinement, and proof planning
only where they preserve that intent:

- `reconciliation/reconciled-proposal-packet-map.yml` — RP-08 scope,
  dependencies, steps, proof, and exclusions;
- `reconciliation/reconciled-workgroup-roadmap.yml` — RWG-08 wave, entry,
  exit, rollback, and concurrency constraints;
- `reconciliation/reconciled-decision-register.yml` — FD-002/012/016;
- `reconciliation/reconciled-finding-register.yml` — RF-011/018/026/028;
- `reconciliation/proof-obligations.yml` — PO-FD-002/012/016 and
  PG-08-CLASS-ROUTES/EFFECT-RECOVERY/DEGRADED-MODE;
- `reconciliation/unresolved-evidence.yml` — UE-004/007 and RP-14-owned UE-014;
- `reconciliation/remaining-operator-decisions.yml` — ROD-002 and ED-003; and
- `reconciliation/safe-intermediate-states.md` — SI-06.

## Current Repository Facts

Static starting facts include existing mission autonomy/continuation/runner and
closeout contracts, run-lifecycle and run-health read models, effect-token
records, provider publication paths, and some post-effect state observation.
They do not prove a complete T1/send/T2 crash-safe path, unknown-before-retry,
causal attribution, immutable A/B/C route behavior, or narrow degraded SI-06.

## Fixed Boundaries

- one immutable RP-06 predicate classifies A/B/C and Class B no-PR/PR;
- RP-03 owns the only T1/external/T2 transition/store model;
- every unknown reconciles before retry;
- `state_satisfied` is not `attempt_performed`;
- invalid/stale/revoked/raced authority denies rather than PR laundering;
- failure blocks only the affected consequence, preserves work, and exposes no
  ambient credential fallback;
- SI-06 uses scratch targets and prohibits trust-root automation; and
- SQLite/provider atomicity and universal exactly-once are not claimed.

## Open Judgment And Engineering Disposition

ROD-002 is settled/retired lineage, not an open operator choice. RP-08 must
encode the intake-accepted deterministic Class A/B/C behavior, eligible Class B
no-PR publication, deterministic PR escalation, protected Class C/trust-root
handling, no autonomous direct-main route, and notification only for
irreducible ambiguity. Zero routine A/B escalation and one concise action only
for irreducible ambiguity are accepted rules to prove, not tunable thresholds.

ED-003 defaults to a single-repository GitHub App, atomic expected-old
fast-forward operation, authenticated receipt when available, and explicit
`state_satisfied` versus `attempt_performed`. Targeted scratch-provider evidence,
not a routine operator preference, determines attainable attribution strength.

## Named Predecessor Use

Revision 2 is consulted only for compatible lineage/detail and is not modified,
accepted, rejected, superseded, archived, or made a program child here.

## Evidence Classification

- current repository claims: `STATICALLY_INSPECTED`;
- target: architecture constrained by accepted intake decisions and reconciled
  coordination, findings, engineering refinement, and proof planning;
- route/recovery/degraded claims: unproven until `ADVERSARIALLY_TESTED`;
- UE-014: remains RP-14-owned integrated product evidence.

Unrelated reviews, chat, generated summaries, provider dashboards, and unscoped
ideation are excluded semantic inputs.

## Bounded Git Lifecycle Input

Read-only references to runs `29249394310`, `29249511200`, `29249511103`,
`29249511080`, ruleset `12881449`, and the observed two-commit range support the
current race/validation/cleanup gaps only. No raw logs were imported. Provider
observations remain evidence, not authority or future recovery proof.
