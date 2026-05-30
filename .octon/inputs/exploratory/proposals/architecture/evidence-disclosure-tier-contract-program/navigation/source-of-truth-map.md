# Source Of Truth Map

_Status: In-review parent-program navigation_

## Parent Program Authority

- `proposal.yml` is the parent proposal manifest.
- `architecture-proposal.yml` is the architecture subtype manifest.
- `resources/child-packet-index.yml` is the structured child registry.
- `architecture/packet-sequence.md` defines the parent coordination sequence.
- `architecture/child-packet-contract.md` defines parent/child authority
  separation.
- `architecture/program-closeout-plan.md` defines parent aggregate closeout.

## Supporting Navigation

- `README.md` explains program purpose and scope.
- `resources/source-context.md` summarizes operator-supplied source context.
- `resources/child-packet-index.md` is the human child index.
- `RISK-REGISTER.md` tracks aggregate risks.
- `validation-plan.md` tracks aggregate validation.
- `support/program-creation.md` records parent-local creation evidence.
- `support/implementation-grade-completeness-review.md` records readiness
  status and must pass before implementation readiness can be claimed.
- `support/proposal-review.md` records parent review receipts. Implementation
  authorization exists only when the current receipt is accepted, has zero open
  blockers, authorizes implementation prompt generation, and carries a fresh
  digest.
- `support/revisions/` records parent-local revision receipts.
- `support/program-implementation-orchestration-prompt.md` is an operational
  support aid retained for lineage; it must re-check the current strict parent
  review gate and child-readiness gate before use and does not itself authorize
  or route lifecycle execution.

## Non-Authority Source Lineage

The parent uses the operator-supplied source material captured in
`resources/source-context.md` as proposal-local input only.

This source context does not prove the target architecture and does not become
runtime, policy, support, evidence, or closeout authority.
