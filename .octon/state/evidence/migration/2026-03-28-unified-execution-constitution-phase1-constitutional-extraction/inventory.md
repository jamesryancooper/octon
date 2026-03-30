# Phase 1 Change Inventory

## Summary

- Reduced live ingress to a constitution-first minimal read set and made the
  projected ingress adapters truly adapter-only.
- Converted the remaining legacy charter- or constitution-shaped governance
  surfaces into explicit non-conflicting shims or subordinate overlays.
- Recorded shim surfaces in the constitutional contract registry and aligned
  scaffolding plus validators to the same singular-kernel model.

## Constitutional Kernel And Ingress

- Updated `/.octon/instance/ingress/AGENTS.md` to read the constitutional
  kernel first, include the current workspace objective pair only after the
  kernel, and move `START.md` plus other bootstrap/state documents into
  optional orientation.
- Updated `/.octon/AGENTS.md`, `/AGENTS.md`, and `/CLAUDE.md` so the projected
  ingress surfaces no longer widen the read path beyond the canonical internal
  ingress source.
- Updated `/.octon/framework/constitution/CHARTER.md` to explicitly allow
  legacy charter- or constitution-shaped files only as non-conflicting shims.
- Updated `/.octon/framework/constitution/contracts/registry.yml` to register
  ingress adapters, the agency constitution shim, cognition/assurance charter
  shims, and the protected principles charter as subordinate shim surfaces.

## Shim Strategy

- `/.octon/framework/agency/governance/CONSTITUTION.md` now declares itself an
  agency constitutional application shim. It keeps agency-specific execution
  and profile-governance rules while making the constitutional kernel and
  `instance/ingress/AGENTS.md` authoritative above it.
- `/.octon/framework/cognition/governance/CHARTER.md` now declares itself a
  historical cognition-governance shim. It preserves lineage and framing, but
  no longer claims repo-local constitutional authority.
- `/.octon/framework/assurance/governance/CHARTER.md` now declares itself a
  subordinate assurance-governance shim used by assurance weighting and
  scoring tooling.
- `/.octon/framework/cognition/governance/principles/principles.md` remains a
  protected human-override-only principles charter, but it now explicitly
  states that it is subordinate to `framework/constitution/**`.
- Updated supporting READMEs and agency agent-contract docs to reflect the new
  application order instead of the old `AGENTS.md -> CONSTITUTION.md -> ...`
  chain.

## Scaffolding And Validators

- Updated all scaffolded `AGENTS.md` bootstrap sources under
  `framework/scaffolding/runtime/**` so `/init` and template materialization
  preserve the new adapter-only projected ingress behavior.
- Updated `validate-agency.sh` to fail if `instance/ingress/AGENTS.md` pulls
  cognition architecture, cognition principles, or `START.md` back into the
  minimal constitutional read set and to require that
  `CONSTITUTION.md` identifies itself as a constitutional application shim.
- Updated `validate-bootstrap-ingress.sh` to fail if `/.octon/AGENTS.md`
  widens the ingress path to `OBJECTIVE.md`, `intent.contract.yml`, or
  `START.md`.

## Phase 1 Exit Status

- One constitutional kernel exists: `framework/constitution/**` remains the
  singular repo-local constitutional kernel.
- Old constitutional surfaces are shims, not conflicting authorities: satisfied
  by the explicit shim markers and subordinate framing added to agency,
  cognition, assurance, and principles surfaces.
- Ingress reads the constitutional kernel first: satisfied by the updated
  `instance/ingress/AGENTS.md` read order and the adapter-only projected
  ingress surfaces.

## Residual Later-Phase Blockers

- `instance/charter/**` still does not exist, so the workspace objective layer
  remains at the current bootstrap/cognition pair until Phase 2.
- Authored disclosure under `instance/governance/disclosure/**` is still
  absent.
- Live approval/grant roots remain sparsely populated and external replay index
  usage remains largely structural only.
