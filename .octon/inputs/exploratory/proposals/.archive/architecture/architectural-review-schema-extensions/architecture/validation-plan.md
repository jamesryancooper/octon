# Validation Plan

## Packet-Time Validation (this lifecycle stage)

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/architectural-review-schema-extensions --skip-registry-check`
  — base proposal-standard checks. Registry check is skipped because unrelated
  in-flight proposal packets (the parent program and sibling children) are
  visible and the discovery registry projection is refreshed by canonical
  program-level coordination, not by this child's creation. Reason recorded in
  `support/proposal-creation.md`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/architectural-review-schema-extensions`
  — architecture subtype floor (manifest fields, required artifacts, and the
  chained implementation-readiness gate, which for a `draft` packet warns rather
  than errors).

## Implementation-Time Validation (later lifecycle stage)

| Check | Command / method | Fail-closed expectation |
| --- | --- | --- |
| v2 report schema well-formed | JSON-Schema parse of `architectural-review-report-v2.schema.json` | valid schema |
| v2 routing-decision schema well-formed | JSON-Schema parse of `architectural-review-routing-decision-v2.schema.json` | valid schema |
| Additive-superset (report) | `diff` v2 against v1: only `$id`, `title`, `schema_version` const, and the added `method`/`lenses_applied` fields differ | no v1 field removed / renamed / re-typed |
| Additive-superset (routing-decision) | same `diff` method against the routing-decision v1 | no v1 field removed / renamed / re-typed |
| Method enum binding | every v2 `method` enum value ∈ `naming.yml` `methods` catalog slugs | all six present, no extras |
| Receipts validator positive control | `validate-architectural-review-receipts.sh` against the `pass` fixture (valid v2 report + routing-decision) | passes (errors=0) |
| NC-1 — unknown method | receipts validator against `fail-unknown-method` fixture | fails (errors>0, non-zero exit) |
| NC-2 — undefined lens | receipts validator against `fail-undefined-lens` fixture | fails (errors>0, non-zero exit) |
| NC-3 — receipt schema drift | receipts validator against `fail-receipt-schema-drift` fixture | fails (errors>0, non-zero exit) |
| v1 coexistence | v1 report + routing-decision artifacts validate against the retained v1 schemas | still valid (no method/lens required) |
| Support receipt unchanged | `git diff` on `architectural-review-support-receipt-v1.schema.json` | empty diff (byte-for-byte unchanged) |
| README extended, not rewritten | `git diff` on contracts/assurance `README.md` | only the two v2 entries added |
| Lens binding no-regression | phase-0 `validate-architectural-review-lens-references.sh` against live `lens-bank.yml` | still passes |
| Naming binding no-regression | phase-1 `validate-architectural-review-naming.sh` against live `naming.yml` | still passes |
| Full suite no-regression | remaining `validate-architectural-review-*.sh` (naming, routing, workflows, lifecycle-gates, extension-split, skills-commands, lens-references) | still pass |

## Evidence Retention

Schema well-formedness runs, the additive-superset diffs, the receipts-validator
positive and three negative-control runs, the method-enum and lens-id binding
proofs, the v1 coexistence proof, the support-receipt-unchanged `git diff`, and
the remaining-suite no-regression runs are retained under this child's promotion
evidence root
`.octon/state/evidence/validation/proposals/architectural-review-schema-extensions/`
and referenced from the child's implementation and verification receipts. Parent
program evidence never substitutes for these child receipts.

## Negative Controls Are Mandatory

Because this child ships an enforcement surface (the receipts validator with new
fail-closed rules), the three negative controls above are required, not optional,
per child-packet-contract obligation 4 — at least one per new fail-closed rule
(`unknown_method`, `undefined_lens`, and `receipt_schema_drift`).
