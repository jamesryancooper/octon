# Bound Source Context

This packet was created by the proposal-lifecycle `create-packet` route as the
phase-2 child of the **Architecture Review Method Suite Program**.

- Run: `20260709-arms-program-clean-delivery-04-architectural-review-schema-extensions`
- Program run: `20260709-arms-program-clean-delivery-04`
- Child id: `architectural-review-schema-extensions`
- Bound `source`:
  `.octon/inputs/exploratory/proposals/architecture/architecture-review-method-suite-program/`
- Bound `target`:
  `.octon/inputs/exploratory/proposals/architecture/architectural-review-schema-extensions`

All bound source material is **non-authoritative lineage only**. Every claim is
re-grounded against the live repository at HEAD. Where a program design doc
disagrees with the live mechanism, the live mechanism wins and this child triggers
a parent registry/design revision rather than implementing a stale claim
(child-packet-contract obligation 3).

## Source Lineage Chain

1. Non-authoritative intake unit (raw conversation-derived direction):
   `.octon/inputs/additive/.incoming/architecture-review-method-suite/`
2. Parent program design (direction for this child, not authority):
   - `architecture/method-taxonomy.md` — "every method report records the method
     slug and the lens profile actually applied (schema extension child)"
   - `architecture/child-packet-contract.md` — per-child charter and obligations
   - `architecture/target-architecture.md` — suite-level intent
   - `resources/child-packet-index.yml` — registry: phase, dependencies, write scopes
3. Live mechanism (epistemic precedence over all of the above):
   - `.octon/framework/constitution/contracts/assurance/architectural-review-report-v1.schema.json`
   - `.octon/framework/constitution/contracts/assurance/architectural-review-routing-decision-v1.schema.json`
   - `.octon/framework/constitution/contracts/assurance/architectural-review-support-receipt-v1.schema.json`
   - `.octon/framework/constitution/contracts/assurance/README.md`
   - `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh`
   - `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml` (phase-1 `methods` catalog)
   - `.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml` (phase-1 `missing_method_record`)
   - `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml` (phase-0 lens ids)

## Per-Child Charter (verbatim from parent `child-packet-contract.md`)

> `architectural-review-schema-extensions`: add
> `architectural-review-report-v2.schema.json` and
> `architectural-review-routing-decision-v2.schema.json` with additive
> `method` and `lenses_applied` fields; leave
> `architectural-review-support-receipt-v1.schema.json` untouched; extend
> `validate-architectural-review-receipts.sh` with v2 awareness and negative
> controls; declare the v1→v2 coexistence posture explicitly.

## Registry Facts (verbatim from parent `resources/child-packet-index.yml`)

- `child_id: architectural-review-schema-extensions`
- `path: .octon/inputs/exploratory/proposals/architecture/architectural-review-schema-extensions`
- `required: true`, `deferred: false`
- `dependencies: [architecture-review-method-taxonomy-and-routing]`
- `dependency_gate: verification`
- `phase_id: phase-2`, `group_id: contracts-and-assurance`
- `rollback_posture: manual`
- `write_scopes:`
  - `.octon/framework/constitution/contracts/assurance/`
  - `.octon/framework/assurance/runtime/_ops/scripts/`

The declared upstream is `architecture-review-method-taxonomy-and-routing`
(phase-1, `naming.yml` `methods` catalog + `missing_method_record`). Phase-1 in
turn depends on `architecture-lens-bank-foundation` (phase-0, lens ids), so both
are transitively verified before this child implements. The downstream consumer is
`architectural-review-suite-integration` (phase-3), which records the selected
method id in review workflow run evidence conforming to these v2 schemas.

## Method-Report Direction (verbatim from parent `architecture/method-taxonomy.md`)

Preserved verbatim as the primary source direction this child implements as schema
fields. It is retained here so the packet is archive-ready without the parent
packet on disk.

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

Verified against `.octon/framework/constitution/contracts/assurance/` and the
receipts validator:

- `architectural-review-report-v1.schema.json` and
  `architectural-review-routing-decision-v1.schema.json` exist with
  `additionalProperties: false`, no `method`/`lenses_applied` field. This child
  adds v2 supersets carrying those two required fields and **retains** the v1
  schemas.
- `architectural-review-support-receipt-v1.schema.json` exists and is **left
  untouched**; the receipts validator asserts receipts stay at v1
  (`receipt_schema_drift`).
- `validate-architectural-review-receipts.sh` today validates **only** the support
  receipt and hard-asserts its v1 schema_version. "Extend with v2 awareness" is an
  additive capability (validate v2 report/routing-decision fields; guard receipt
  drift), not a rewrite of the existing support-receipt checks. Recorded in
  `architecture/current-state-gap-map.md`.
- The six canonical method slugs are live in `naming.yml` `methods` (fixed by
  phase-1): `balanced-architecture-review-method` (default),
  `greenfield-reference-architecture-review-method`, `tradeoff-review-method`,
  `failure-mode-review-method`, `evolution-fitness-review-method`,
  `boundary-authority-review-method`. The v2 `method` enum copies them verbatim —
  no slug divergence remains for this child to resolve.
- The 18 lens ids used by `lenses_applied` are live in `lens-bank.yml` (phase-0):
  12 core + 6 extended. No undefined lens id is referenced by this packet.
- Phase-1's `review-routing.yml` declares the `missing_method_record` fail-closed
  condition; this child completes the schema-level `method` record that condition
  anticipated. Consistent with the phase-1 packet's own handoff note. Not a
  blocker.
