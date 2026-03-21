# ADR 058: Validation, Fail-Closed, Quarantine, And Staleness Atomic Cutover

- Date: 2026-03-20
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/inputs/exploratory/proposals/.archive/architecture/validation-fail-closed-quarantine-staleness/`
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-20-validation-fail-closed-quarantine-staleness-cutover/plan.md`
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh`

## Context

Packets 1 through 13 established the five-class super-root, the desired versus
actual extension split, the locality registry, generated effective families,
capability routing, and the fail-closed portability/trust contract.

What remained unresolved was the operational safety contract tying those
surfaces together:

1. runtime and policy consumers still depended on a distributed set of
   validators without one explicit runtime-effective trust gate,
2. locality publication still blocked on any quarantine instead of isolating
   scope-local failures,
3. runtime-facing publication families did not carry a common receipt model,
4. extension effective publication still exposed obsolete `content_roots`
   fields even though routing had moved to compiled exports, and
5. the Packet 14 proposal package was still active rather than archived with
   implementation evidence.

## Decision

Promote Packet 14 as one atomic clear-break cutover.

Rules:

1. `validate-runtime-effective-state.sh` is the canonical Packet 14
   runtime-effective trust gate.
2. `octon.yml` fail-closed policies remain unchanged and are enforced
   end-to-end rather than being treated as informational.
3. Runtime-facing publication receipts live under
   `state/evidence/validation/publication/**` and use
   `octon-validation-publication-receipt-v1`.
4. Extension control/publication schemas move to `active/quarantine v3` and
   `catalog/artifact-map/generation-lock v4`.
5. Locality control/publication schemas move to `quarantine/effective/
   artifact-map/generation-lock v2`.
6. Capability routing publication schemas move to `effective/artifact-map/
   generation-lock v3`.
7. Scope-local locality failures republish a reduced coherent locality set
   with `publication_status: published_with_quarantine`.
8. Repo-level locality contract failures remain global fail-closed and block
   locality publication.
9. Extension publication keeps the desired/actual/quarantine/compiled split,
   records receipt linkage, and fails closed on native-versus-extension
   capability collisions.
10. `repo_snapshot` remains clean-only and fails when extension quarantine is
    non-empty.
11. The Packet 14 proposal package moves to `.archive/**` with an
    `implemented` disposition in the same change set as the durable cutover.

## Consequences

### Benefits

- Runtime and policy trust now terminates at one explicit Packet 14 gate.
- Scope-local failures can quarantine without forcing unnecessary repo-wide
  locality outages.
- Every runtime-facing effective family now records receipt linkage and
  invalidation metadata consistently.
- Publication evidence lives in retained state rather than in generated
  convenience outputs.

### Costs

- Publication scripts, validators, schema contracts, templates, tests, and
  docs all changed together.
- Locality publication semantics changed materially from full-blocking to
  reduced coherent publication.
- Packet 14 closeout required retiring the active proposal package and
  refreshing generated effective outputs in the same promotion window.
- Harness verification in this environment required an escalated rerun of the
  host-projection refresh step during `alignment-check`.

### Follow-on Work

1. Packet 15 can treat Packet 14 as the settled runtime failure model for the
   final migration-and-rollout closeout.
2. Future runtime consumers may rely on the new publication receipt family
   without inventing parallel evidence surfaces.
