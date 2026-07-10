# Target Architecture

## End State

The Architectural Review Mechanism method layer is doctrine-complete for its four
companion methods. Under
`.octon/framework/cognition/practices/methodology/architectural-review/` four new
method docs exist beside the delivered `balanced-architecture-review-method.md`
and `greenfield-reference-architecture-review-method.md`:

| Slug | Doc file | Method question |
| --- | --- | --- |
| `tradeoff-review-method` | `tradeoff-review-method.md` | Given the candidate designs, which tradeoffs are we accepting, and which option should we recommend? |
| `failure-mode-review-method` | `failure-mode-review-method.md` | How does this architecture fail, drift, get bypassed, partially execute, lose evidence, confuse operators, or fail to recover? |
| `evolution-fitness-review-method` | `evolution-fitness-review-method.md` | Will this architecture remain healthy as the system changes, and how will we know? |
| `boundary-authority-review-method` | `boundary-authority-review-method.md` | Where does authority actually live for this surface, and what must never become authority? |

## One Shared Contract Shape

Each of the four docs follows the same section contract, matching the shape the
delivered Greenfield doc established:

1. **Method question** (title banner).
2. **Use Cases And Non-Goals** — when to select the method and what it explicitly
   does not do (naming the sibling method or audit that owns the excluded job).
3. **Required Inputs** — what a review of this method cannot start without.
4. **Lens Profile** — a pointer to `lens-bank.yml`
   `method_profiles.<slug>`, citing lens ids only, listing the exact required and
   optional lens sets, and stating "no private lens catalog". The listed sets
   must match `lens-bank.yml` exactly.
5. **Required Output Sections** — the method's output contract, each output driven
   by named lenses from the profile.
6. **Escalation Rules** — cite `review-routing.yml` `method_selection`
   (`escalation_map`, `constitutional_conflict_routes_to`); do not restate routing
   as new authority.
7. **Output Boundary (Fail-Closed)** — output is retained evidence or proposal
   input, never lifecycle-gate or implementation authority; the pre-integration
   support receipt remains the only lifecycle-gating review artifact.
8. **Related / Navigation** — navigation-only links to `naming.yml`,
   `lens-bank.yml`/`architecture-lens-bank.md`, `review-routing.yml`, and the
   Balanced default.

## Per-Method Output Contracts (from method-taxonomy §§3–6, repo-grounded)

- **Tradeoff (`tradeoff-review-method`)** — option matrix; quality-attribute
  assessment; per-option tradeoff/risk/reversibility analysis; recommendation with
  rejected alternatives; ADR-ready decision-record input with revisit triggers.
  Required lenses: `quality-attribute-scenarios`, `tradeoff-adr`.
- **Failure-Mode (`failure-mode-review-method`)** — failure-mode catalog
  (authority inflation, stale evidence, generated-output misuse, bypass paths,
  partial execution, zombie runs, rollback gaps, operator confusion); detection
  and containment expectations per mode; recovery posture; required validators or
  negative controls; unresolved-failure blocker list. Required lenses:
  `current-reality-map`, `failure-and-recovery`, `authority-boundary`,
  `validation-strategy`, `security-threat-model`,
  `operability-observability-evidence`.
- **Evolution/Fitness (`evolution-fitness-review-method`)** — architectural
  fitness functions; drift triggers; retirement triggers; compatibility posture;
  validator needs; revisit cadence with owner. Required lenses:
  `current-reality-map`, `validation-strategy`, `contracts-compatibility`,
  `operability-observability-evidence`, `evolution-fitness`.
- **Boundary/Authority (`boundary-authority-review-method`)** — actual-vs-claimed
  authority map; accidental-control-surface findings; containment plan (what must
  move into `framework/**` or `instance/**`, what must be demoted to evidence or
  projection); fail-closed and support-claim implications; blocker list. Required
  lenses: `current-reality-map`, `authority-boundary`. Ships **Octon-only** in v1.

## Mandated Boundary Statements

- **Failure-Mode vs readiness audit.** The doc states that scoring implementation
  readiness — including the Architecture Readiness Audit's mandatory failure-mode
  assessment — is owned by the readiness audit, not this method. Failure-Mode
  Review cites that failure-mode vocabulary where it overlaps and issues no
  readiness verdict.
- **Boundary/Authority vs surface-architecture audit.** The doc states that
  classifying a single unit's smallest-robust authority model with the
  `contract-first`/`mixed`/`markdown-first`/`human-led` vocabulary is owned by the
  Surface Architecture Audit (canonical mode `surface-architecture-audit`). This
  method reviews authority *placement and containment across a design* and
  escalates single-unit follow-ups to that audit.

## Additive Discoverability Wiring

- `naming.yml`: add `doc: <slug>.md` to each of the four companion
  `methods.catalog` entries, mirroring the existing Greenfield entry. No slug,
  role, default, or `lens_profile_ref` change.
- `README.md`: add the four doc links to the References section. The
  canonical-names table and Methods-And-Selection prose already name all six
  methods and are unchanged.

## Invariants Preserved

- Balanced Architecture Review remains the declared default method.
- Method output remains retained evidence or proposal input; the pre-integration
  support receipt remains the only lifecycle-gating review artifact.
- No new mechanism, routed workflow mode, lifecycle gate, evidence root, schema,
  validator, or command facade is created.
- Every lens comes from the shared bank; no method owns a private lens catalog.
- Architecture-readiness and surface-architecture audit doctrine are composed
  with, never modified or duplicated.
- The change stays inside the child's registry-declared write scope
  `.octon/framework/cognition/practices/methodology/architectural-review/`.
