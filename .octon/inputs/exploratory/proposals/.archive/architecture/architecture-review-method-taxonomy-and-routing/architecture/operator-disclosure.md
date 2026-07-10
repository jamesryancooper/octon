# Operator Disclosure

## What Changes For Operators

Very little changes operationally when this child lands. No new command, skill,
gate, routed workflow mode, or evidence root is created. Balanced Architecture
Review remains the **default** method: any existing review that makes no method
selection behaves exactly as before. What is new is that a reviewer may now name
one of six methods for a review run, and routing knows which methods each review
occasion permits.

## What Becomes Available

- A canonical **method taxonomy** in `naming.yml` v2: Balanced plus five
  companion methods, each with a stable canonical slug.
- **Method-selection routing** in `review-routing.yml` v2: a default method,
  per-route allowed methods, and a Balanced escalation map (to Tradeoff,
  Failure-Mode, Evolution/Fitness, Boundary/Authority, or Greenfield).
- **Fail-closed method routing**: selecting an undefined method
  (`unknown_method`) or emitting a routing decision without the required method
  record (`missing_method_record`) fails closed, enforced by the naming and
  routing validators with negative controls.

## What Operators Must Not Assume

- Method selection grants **no** review-output authority. Review outputs remain
  evidence or proposal input; the pre-integration support receipt remains the
  only lifecycle-gating review artifact.
- The five companion methods are **named and routable** by this child, but their
  full **method docs** (output contracts) arrive in phase-2
  (`greenfield-reference-architecture-review-method`,
  `companion-architecture-review-methods`). Until then, selecting a companion
  method routes correctly but the method's detailed output contract is authored
  separately.
- The **schema field** that records the selected method in a review report /
  routing decision is authored by the phase-2 schema-extensions child. This
  child declares the `missing_method_record` fail-closed intent; the schema-level
  enforcement completes in phase-2.
- No existing route, alias, evidence root, or the pre-integration gate changed.

## Support And Evidence

Validator runs, negative-control runs, the lens-bank binding proof, and the
no-regression / Balanced-unchanged `git diff` proofs are retained under
`.octon/state/evidence/validation/proposals/architecture-review-method-taxonomy-and-routing/`.
This packet is non-authoritative proposal lineage; the durable authority after
promotion is the framework artifacts listed in `architecture/file-change-map.md`.
