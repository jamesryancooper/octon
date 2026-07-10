# Preserved Source — Child Charter And Obligations

Verbatim extract of the parent program's child-registry entry and child-packet
contract that scope this child. Lineage only — not authority. The parent
coordinates; it does not own, and its evidence never satisfies this child's
receipts.

## Child Registry Entry (`resources/child-packet-index.yml`)

```yaml
  - child_id: "companion-architecture-review-methods"
    path: ".octon/inputs/exploratory/proposals/architecture/companion-architecture-review-methods"
    required: true
    deferred: false
    dependencies:
      - "architecture-review-method-taxonomy-and-routing"
    dependency_gate: "verification"
    phase_id: "phase-2"
    group_id: "method-docs"
    rollback_posture: "manual"
    write_scopes:
      - ".octon/framework/cognition/practices/methodology/architectural-review/"
```

## Per-Child Charter (`architecture/child-packet-contract.md`)

> `companion-architecture-review-methods`: author the four companion method
> docs per `architecture/method-taxonomy.md` §§3–6 with one shared contract
> shape (question, use cases, non-goals, required inputs, outputs, lens
> profile reference, escalation rules). Must include the explicit boundary
> statements: Failure-Mode Review vs the readiness audit's failure-mode
> assessment; Boundary/Authority Review vs the surface-architecture audit's
> single-unit classification. Boundary/Authority ships Octon-only.

## Obligations Every Child Must Meet (contract summary)

1. **Independent validity** — passes `validate-proposal-standard.sh` and its
   subtype validator at its own path with its own manifests, README, navigation,
   and working docs.
2. **Own receipts** — creation/review/implementation/verification/closeout
   receipts are child-local; parent evidence, the contract, and the registry never
   satisfy a child receipt, promotion target, verdict, or archive metadata.
3. **Source grounding** — cite the intake unit and program design docs as lineage
   only; re-ground every claim; where a design doc disagrees with the live repo,
   the repository wins and the child triggers a program revision instead of
   implementing a stale claim.
4. **Validation floor** — before implementation planning, define acceptance
   criteria, required evidence, required validator depth, and rollback posture. A
   methodology-docs-only child (greenfield-method, companion-methods) must define a
   **doc-consistency check against `naming.yml` and `lens-bank.yml`**.
5. **Authority boundaries** — no new lifecycle gate, review mechanism, routed
   workflow mode, closeout authority, or review-output authority; no widened
   support claims; no generated publication outside canonical scripts; evidence,
   projections, and the intake unit are never authority. Durable changes land only
   under `framework/**` through governed acceptance.
6. **Suite design rules** — methods own the question/scope/routing/output
   contract; lenses come from the shared bank only; no private lens catalogs;
   Balanced stays default; companion methods remain distinct and callable;
   readiness and surface-audit doctrine are cited, never modified or duplicated.
7. **Write-scope discipline** — stay inside the registry-declared write scope;
   touching another child's scope requires a parent registry revision.
8. **Terminal outcomes** — closed (implemented and verified), superseded, or
   rejected.

## How This Packet Satisfies The Charter

- Obligation 1 → full architecture packet at the canonical sibling path (this
  packet).
- Obligation 2 → child-owned evidence root declared at
  `.octon/state/evidence/validation/proposals/companion-architecture-review-methods/`.
- Obligation 3 → `../architecture/current-state-gap-map.md` records live grounding
  and the settled source⇄repo reconciliations.
- Obligation 4 → `../architecture/validation-plan.md` defines the doc-consistency
  check plus regression validators.
- Obligations 5–6 → `../architecture/target-architecture.md` invariants and the
  fail-closed output boundary in every planned doc.
- Obligation 7 → all changes confined to
  `.octon/framework/cognition/practices/methodology/architectural-review/`.
- Obligation 8 → closeout gate in `../architecture/acceptance-criteria.md`.
