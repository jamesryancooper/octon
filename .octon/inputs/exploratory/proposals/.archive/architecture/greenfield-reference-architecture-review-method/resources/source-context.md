# Bound Source Context

This packet was created by the proposal-lifecycle `create-packet` route as the
phase-2 child of the **Architecture Review Method Suite Program**.

- Run: `20260709-arms-program-clean-delivery-04-greenfield-reference-architecture-review-method`
- Program run: `20260709-arms-program-clean-delivery-04`
- Child id: `greenfield-reference-architecture-review-method`
- Bound `source`:
  `.octon/inputs/exploratory/proposals/architecture/architecture-review-method-suite-program/`
- Bound `target`:
  `.octon/inputs/exploratory/proposals/architecture/greenfield-reference-architecture-review-method`

All bound source material is **non-authoritative lineage only**. Every claim is
re-grounded against the live repository at HEAD. Where a program design doc
disagrees with the live mechanism, the live mechanism wins and this child triggers
a parent registry/design revision rather than implementing a stale claim
(child-packet-contract obligation 3). No blocking divergence was found at HEAD —
the greenfield slug, routing entry, and lens profile all exist and agree (see
`architecture/current-state-gap-map.md`).

## Source Lineage Chain

1. Non-authoritative intake unit (raw conversation-derived direction):
   `.octon/inputs/additive/.incoming/architecture-review-method-suite/`
2. Parent program design (direction for this child, not authority):
   - `architecture/method-taxonomy.md` §2 — the Greenfield method contract this
     child authors as a doc
   - `architecture/child-packet-contract.md` — per-child charter and obligations
   - `architecture/target-architecture.md` — suite-level intent and invariants
   - `resources/child-packet-index.yml` — registry: phase, dependencies, write scope
3. Live mechanism (epistemic precedence over all of the above):
   `.octon/framework/cognition/practices/methodology/architectural-review/`
   (naming.yml, review-routing.yml, README.md,
   balanced-architecture-review-method.md, lens-bank.yml, architecture-lens-bank.md)

## Per-Child Charter (verbatim from parent `child-packet-contract.md`)

> `greenfield-reference-architecture-review-method`: author the method doc
> per `architecture/method-taxonomy.md` §2 — five required output sections,
> initial-build sequencing, minimum viable architecture, what-not-to-build,
> clean-sheet complementarity, escalation rules, and the
> reference-architecture-only output boundary stated fail-closed.

## Registry Facts (verbatim from parent `resources/child-packet-index.yml`)

- `child_id: greenfield-reference-architecture-review-method`
- `path: .octon/inputs/exploratory/proposals/architecture/greenfield-reference-architecture-review-method`
- `required: true`, `deferred: false`
- `dependencies: [architecture-review-method-taxonomy-and-routing]`
- `dependency_gate: verification`
- `phase_id: phase-2`, `group_id: method-docs`
- `rollback_posture: manual` (program default; no per-child override)
- `write_scopes:`
  - `.octon/framework/cognition/practices/methodology/architectural-review/`

The immediate upstream is `architecture-review-method-taxonomy-and-routing`
(phase-1), which named the greenfield method in `naming.yml` `methods.catalog` and
routed it in `review-routing.yml` `method_selection`. Transitively,
`architecture-lens-bank-foundation` (phase-0) seeded the greenfield lens profile.
The immediate downstream consumer is `architectural-review-suite-integration`
(phase-3), which records the selected method id in run evidence and refreshes
generated projections.

## Method Contract (verbatim from parent `architecture/method-taxonomy.md` §2)

The following is preserved verbatim as the primary source direction this child
authors as a method doc. It is retained here so the packet is archive-ready
without the parent packet on disk.

```markdown
## 2. Greenfield Reference Architecture Review

- **Slug:** `greenfield-reference-architecture-review`.
- **Question:** If this system or subsystem did not exist, what should we
  build first?
- **Use cases:** new systems, new subsystems, major replacement candidates
  before implementation proposals exist.
- **Non-goals:** deciding what to change in an existing system (Balanced);
  fantasy architecture — output must respect Octon governance, support
  claims, validation, and operability from day one; absorbing companion
  methods' output contracts.
- **Required inputs:** the system job / mission statement; known hard
  constraints (governance posture, evidence obligations, support-claim
  boundaries); explicit statement of what is being replaced, if anything.
- **Outputs (five required sections):** domain/job model; reference
  architecture; quality/security/ops model; authority/evidence model;
  evolution plan — plus initial-build sequencing, minimum viable
  architecture, and an explicit what-not-to-build-yet list. Output is
  reference architecture: evidence or proposal input, never implementation
  authority.
- **Escalation:** option choice inside the reference design → Tradeoff
  Review; runtime-critical subsystem in the design → Failure-Mode Review;
  before any implementation proposal → Balanced Review or proposal drafting
  against current reality (when replacing an existing system).
```

## Common Method Rules (verbatim from parent `architecture/method-taxonomy.md`)

```markdown
Common rules for every method:

- Output is retained evidence or proposal input. No method output gains
  lifecycle gate authority; the pre-integration support receipt remains the
  only gating review artifact.
- Every method report records the method slug and the lens profile actually
  applied (schema extension child).
- Constitutional conflicts route to Constitutional Challenge regardless of
  method (existing kernel gate).
- Unknown method selection is fail-closed (`unknown_method`).
```

## Live Re-Grounding Notes (verified at HEAD)

Verified against
`.octon/framework/cognition/practices/methodology/architectural-review/`:

- **Slug resolved to the live canonical form.** The parent prose slug is
  `greenfield-reference-architecture-review` (non-suffixed), but the phase-1
  taxonomy-and-routing child already fixed the canonical slug to
  `greenfield-reference-architecture-review-method` in the live `naming.yml`
  `methods.catalog`, matching the phase-0 `lens-bank.yml` `suite_methods` slug and
  the program registry `child_id`. This child adopts the live canonical slug; the
  prose divergence was already reconciled upstream, so no new program design
  revision is triggered here.
- **The method is already named and routable.** `naming.yml` `methods.catalog`
  carries the greenfield entry (with `lens_profile_ref` but no `doc:` yet), and
  `review-routing.yml` `method_selection` lists it in
  `allowed_methods_by_route.pre-integration-architecture-review` and as the target
  of the Balanced escalation trigger `target-does-not-exist-yet`. This child adds
  the missing output contract (the doc) and the additive `doc:` reference.
- **The lens profile is verified.** `lens-bank.yml`
  `method_profiles.greenfield-reference-architecture-review-method` declares 14
  required + 3 optional lens ids; the doc cites them exactly and defines no
  private catalog.
- **Balanced doctrine is intact and unchanged.** `balanced-architecture-review-method.md`
  uses the `clean-sheet-reference` lens as a comparison tool; the greenfield doc
  contrasts with this (clean-sheet as deliverable) without changing Balanced text.

Program-level invariants that constrain this child: Balanced remains the default
method; review outputs remain evidence or proposal input; the pre-integration
support receipt remains the only lifecycle-gating review artifact; no new
mechanism, routed workflow mode, or gate; readiness and surface-audit doctrine
untouched; generated outputs derived-only; children stay in declared write scopes;
parent evidence never substitutes for child evidence.
