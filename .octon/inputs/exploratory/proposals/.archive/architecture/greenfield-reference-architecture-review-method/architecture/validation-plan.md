# Validation Plan

## Packet-Time Validation (this lifecycle stage)

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/greenfield-reference-architecture-review-method --skip-registry-check`
  — base proposal-standard checks. Registry check is skipped because unrelated
  in-flight proposal packets (the parent program and sibling children) are
  visible and the discovery registry projection is refreshed by canonical
  program-level coordination, not by this child's creation. Reason recorded in
  `support/proposal-creation.md`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/greenfield-reference-architecture-review-method`
  — architecture subtype floor (manifest fields, required artifacts, and the
  chained implementation-readiness gate, which for a `draft` packet warns rather
  than errors).

## Implementation-Time Validation (later lifecycle stage)

This child touches only methodology docs, so its mandatory floor is a
**doc-consistency check** against `naming.yml` and `lens-bank.yml`
(child-packet-contract obligation 4), plus a no-regression sweep. It ships no
enforcement surface and therefore no negative-control fixture.

| Check | Command / method | Expectation |
| --- | --- | --- |
| Doc-consistency: slug match | doc declared slug vs `naming.yml` `methods.catalog` slug vs `lens-bank.yml` `suite_methods` slug | all three equal `greenfield-reference-architecture-review-method` |
| Doc-consistency: lens profile match | lens ids cited in the doc vs `lens-bank.yml` `method_profiles.greenfield-reference-architecture-review-method` (required + optional) | exact match — no extra id, no missing id, no private catalog |
| Structural: five required sections | doc contains domain/job model; reference architecture; quality/security/ops model; authority/evidence model; evolution plan | all five present |
| Structural: build discipline | doc contains initial-build sequencing, minimum viable architecture, what-not-to-build-yet | all three present |
| Fail-closed output boundary present | doc states reference-architecture-only boundary (evidence/proposal input, never implementation authority/gate/verdict) | present and stated fail-closed |
| Naming validator no-regression | `validate-architectural-review-naming.sh` against `naming.yml` with the additive `doc:` reference | passes (errors=0) |
| Routing validator no-regression | `validate-architectural-review-routing.sh` against `review-routing.yml` | passes (errors=0) |
| Lens-reference no-regression | phase-0 `validate-architectural-review-lens-references.sh` against live `lens-bank.yml` | still passes; profile unchanged |
| Balanced / companion doctrine unchanged | `git diff` on `balanced-architecture-review-method.md` and any companion doc | no change |
| Additive-only diff | `git diff` on `naming.yml` (only `doc:` field added) and `README.md` (only a References link added) | no slug/route/schema-version/table-row change |
| Full suite no-regression | remaining `validate-architectural-review-*.sh` (receipts, workflows, lifecycle-gates, extension-split, skills-commands) | still pass |

## Evidence Retention

The doc-consistency check run, the structural and fail-closed-boundary presence
checks, the no-regression validator sweep, and the `git diff` additive-only /
doctrine-unchanged proofs are retained under this child's promotion evidence root
`.octon/state/evidence/validation/proposals/greenfield-reference-architecture-review-method/`
and referenced from the child's implementation and verification receipts. Parent
program evidence never substitutes for these child receipts.

## Why No Negative Control

Per child-packet-contract obligation 4, only children touching **enforcement
surfaces** (lens-bank foundation, taxonomy-and-routing, schema-extensions,
suite-integration) must define a negative control. This child touches **only
methodology docs**, so its required floor is the doc-consistency check above
against `naming.yml` and `lens-bank.yml`. No fail-closed rule, validator, or
fixture is authored by this child.
