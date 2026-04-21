# ADR 098: Evidence Store And Proof Plane Closeout

- Date: 2026-04-20
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/framework/constitution/contracts/retention/evidence-store-v1.schema.json`
  - `/.octon/framework/engine/runtime/spec/evidence-store-v1.md`
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-completeness.sh`
  - `/.octon/framework/constitution/contracts/assurance/support-target-proof-bundle-v1.schema.json`
  - `/.octon/state/evidence/validation/architecture/10of10-remediation/`

## Context

The live repo already retained run, control, lab, disclosure, and publication
evidence, but the architecture still lacked one explicit evidence-store
contract and one generalized completeness rule that distinguished retained
evidence from transport-only CI artifacts and read-model mirrors.

## Decision

Close the gap by making evidence-store semantics and support-proof bundles
explicit architectural contracts.

Rules:

1. Closure-grade evidence must be retained under canonical evidence roots, not
   inferred from CI transport artifacts.
2. Support claims require tuple-level proof bundles that connect admissions,
   dossiers, retained runs, denied scenarios, and disclosure.
3. Run and closure completeness are validator-enforced, not left to narrative.

## Consequences

- Evidence and disclosure claims become easier to audit.
- Support-target proofing becomes a general architectural rule rather than a
  packet-local expectation.
- Closure can certify durable evidence completeness instead of just artifact
  presence.
