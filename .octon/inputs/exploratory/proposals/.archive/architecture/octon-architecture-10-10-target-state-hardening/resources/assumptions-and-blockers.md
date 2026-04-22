# Assumptions and Blockers

## Assumptions

- Octon should preserve its current constitutional and class-root model.
- The target 10/10 architecture is judged by mechanical enforcement and proof,
  not by more elaborate documentation.
- Proposal packets remain non-canonical and excluded from runtime/policy
  resolution.
- Generated/effective outputs may be runtime-facing only under freshness and
  publication receipts.
- Support widening is out of scope unless proof/admission/disclosure is promoted
  through durable surfaces.

## Current blockers to implementation certainty

- This packet did not execute the Rust runtime or validators.
- Full runtime path coverage must be verified against code, not assumed from
  specs.
- Current support admission/dossier contents should be inspected during cutover
  to avoid accidental claim-state changes.
- Existing CI workflow behavior must be checked before making new validators
  blocking.
- Generated/effective publication tooling must be located and verified.

## Blocker resolution plan

- Phase 0 locates runtime emitters, validators, generators, and proof bundle
  emitters.
- Validators start report-only, then become blocking.
- Closure requires retained proof from executed validation, not proposal claims.
