# ADR 079: Unified Execution Constitution Phase 3 Runtime And Evidence Normalization

- Date: 2026-03-29
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-29-unified-execution-constitution-phase3-runtime-evidence-normalization/plan.md`
  - `/.octon/state/evidence/migration/2026-03-29-unified-execution-constitution-phase3-runtime-evidence-normalization/`
  - `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/`

## Context

After Phase 2, Octon had most of the runtime/evidence vocabulary the packet
required, but one key ambiguity remained unresolved:

- `runtime-state.yml` was still acting as a partial stand-in for a dedicated
  run manifest
- replay pointers treated the in-repo replay manifest as if it were an
  external replay reference
- the packet’s Class A/B/C evidence model existed in prose but not as an
  enforced per-run artifact
- the external immutable replay index root existed structurally but was not
  exercised by a supported run class

That left Phase 3 incomplete against the packet and made resumability and
replay retention weaker than claimed.

## Decision

Execute Phase 3 as an atomic runtime-and-evidence normalization cutover.

Rules:

1. `run-manifest.yml` becomes the canonical bound run-manifest model.
2. `runtime-state.yml` remains mutable lifecycle status only.
3. `evidence-classification.yml` becomes the canonical per-run encoding of the
   packet’s Class A/B/C model.
4. `replay-pointers.yml` must distinguish Git-retained replay manifests from
   external immutable replay index entries.
5. The supported `release-and-boundary-sensitive` run class must retain
   immutable replay payloads through a content-addressed index under
   `state/evidence/external-index/**`.

## Consequences

### Benefits

- Run state is resumable from artifacts without relying on
  `runtime-state.yml` as an overloaded topology manifest.
- Evidence retention classes are explicit, machine-readable, and validator
  enforced.
- Replay indexing is exercised in a real supported run class rather than left
  nominal.

### Costs

- Runtime writers, validators, and sample run bundles must all carry the new
  manifest/classification artifacts together.
- Boundary-sensitive replay evidence now has a stronger retention burden
  because immutable external payloads require indexed pointers.

## Completion

This decision is complete once:

- seeded runs carry `run-manifest.yml`, `evidence-classification.yml`, and
  updated replay pointers
- supported boundary-sensitive runs retain a canonical external replay index
- validators confirm Phase 3 exit criteria directly
