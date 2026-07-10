# Validation Plan

## Packet-Time Validation (this lifecycle stage)

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/architecture-review-method-taxonomy-and-routing --skip-registry-check`
  — base proposal-standard checks. Registry check is skipped because unrelated
  in-flight proposal packets (the parent program and sibling children) are
  visible and the discovery registry projection is refreshed by canonical
  program-level coordination, not by this child's creation. Reason recorded in
  `support/proposal-creation.md`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/architecture-review-method-taxonomy-and-routing`
  — architecture subtype floor (manifest fields, required artifacts, and the
  chained implementation-readiness gate, which for a `draft` packet warns rather
  than errors).

## Implementation-Time Validation (later lifecycle stage)

| Check | Command / method | Fail-closed expectation |
| --- | --- | --- |
| Naming v2 positive control | `validate-architectural-review-naming.sh` against shipped `naming.yml` | passes (errors=0) |
| Routing v2 positive control | `validate-architectural-review-routing.sh` against shipped `review-routing.yml` | passes (errors=0) |
| NC-A — method without lens profile | naming validator against `fail-method-without-profile` fixture | fails (errors>0, non-zero exit) |
| NC-B — unknown method in routing | routing validator against `fail-unknown-method` fixture | fails (errors>0, non-zero exit) |
| NC-C — missing method record | routing validator against `fail-missing-method-record` fixture | fails (errors>0, non-zero exit) |
| Lens-bank dependency binding | every `naming.yml` method slug ∈ `lens-bank.yml` `suite_methods` | all six present |
| Lens-reference no-regression | phase-0 `validate-architectural-review-lens-references.sh` against live `lens-bank.yml` | still passes |
| Balanced doctrine unchanged | `git diff` on `balanced-architecture-review-method.md` | only navigation cross-references added; no doctrine text change |
| No slug renames / alias retirements | `git diff` on `naming.yml` restricted to additive `methods` block + schema bump | no existing slug/alias removed or renamed |
| Existing routes / gate unchanged | `git diff` on `review-routing.yml` restricted to additive `method_selection` + two new conditions | existing routes/default/conditions intact |
| Full suite no-regression | remaining `validate-architectural-review-*.sh` (workflows, receipts, lifecycle-gates, extension-split) | still pass |

## Evidence Retention

Validator runs, the negative-control runs, the lens-bank binding proof, and the
`git diff` no-regression / Balanced-unchanged proofs are retained under this
child's promotion evidence root
`.octon/state/evidence/validation/proposals/architecture-review-method-taxonomy-and-routing/`
and referenced from the child's implementation and verification receipts. Parent
program evidence never substitutes for these child receipts.

## Negative Controls Are Mandatory

Because this child ships an enforcement surface (the naming and routing
validators with new fail-closed rules), the three negative controls above are
required, not optional, per child-packet-contract obligation 4 — at least one per
new fail-closed rule (`unknown_method`, `missing_method_record`, and the
method-without-profile dependency binding).
