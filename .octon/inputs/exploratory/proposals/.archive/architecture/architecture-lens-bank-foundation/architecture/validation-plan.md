# Validation Plan

## Packet-Time Validation (this lifecycle stage)

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/architecture-lens-bank-foundation --skip-registry-check`
  — base proposal-standard checks. Registry check is skipped because unrelated
  in-flight proposal packets (the parent program and sibling children) are
  visible and the discovery registry projection is refreshed by canonical
  program-level coordination, not by this child's creation. Reason recorded in
  `support/proposal-creation.md`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/architecture-lens-bank-foundation`
  — architecture subtype floor (manifest fields, required artifacts, and the
  chained implementation-readiness gate, which for a `draft` packet warns rather
  than errors).

## Implementation-Time Validation (later lifecycle stage)

| Check | Command / method | Fail-closed expectation |
| --- | --- | --- |
| Lens-reference positive control | `validate-architectural-review-lens-references.sh` against shipped `lens-bank.yml` | passes (errors=0) |
| Negative control 1 — undefined lens id | validator against the `fail-undefined-lens` fixture | fails (errors>0, non-zero exit) |
| Negative control 2 — missing method profile | validator against the `fail-missing-profile` fixture | fails (errors>0, non-zero exit) |
| Doc/registry consistency | compare `architecture-lens-bank.md` profile table vs `lens-bank.yml` `method_profiles` and the 18 lens ids | identical id + tier + profile sets |
| Balanced unchanged | `git diff` on `balanced-architecture-review-method.md` | no change |
| No regression | existing `validate-architectural-review-naming.sh` and `validate-architectural-review-routing.sh` | still pass |

## Evidence Retention

Validator runs, the doc/registry consistency check, and the Balanced-unchanged
proof are retained under this child's promotion evidence root
`.octon/state/evidence/validation/proposals/architecture-lens-bank-foundation/`
and referenced from the child's implementation and verification receipts. Parent
program evidence never substitutes for these child receipts.

## Negative Controls Are Mandatory

Because this child ships an enforcement surface (the lens-reference validator),
the two negative controls above are required, not optional, per
child-packet-contract obligation 4.
