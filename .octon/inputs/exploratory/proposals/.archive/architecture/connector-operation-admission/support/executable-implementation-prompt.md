# Executable Implementation Prompt

Implement the accepted `connector-operation-admission` child packet as a
child-owned proposal packet in the Governed Workflow Runtime Transition Program.

## Scope

- Promote connector admission posture only through the declared promotion
  targets:
  - `.octon/instance/governance/connector-admissions/`
  - `.octon/instance/governance/connectors/`
  - `.octon/framework/constitution/contracts/adapters/`
  - `.octon/framework/assurance/runtime/_ops/scripts/`
- Refresh connector drift state only as validation evidence for the existing
  MCP `observe-context` connector posture.
- Preserve the exclusions for MCP integration approval, Durable Object adapter
  implementation, external workflow-engine adapter implementation, and
  support-target widening from connector availability.

## Required Commands

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/connector-operation-admission --skip-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/connector-operation-admission`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/connector-operation-admission`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/connector-operation-admission --require-implementation-authorization`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-connector-admission-runtime-v4.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/connector-operation-admission`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/connector-operation-admission`
- `cd .octon/inputs/exploratory/proposals/architecture/connector-operation-admission && shasum -a 256 -c SHA256SUMS.txt`

## Retained Evidence

Retain child-owned validation evidence outside proposal-local inputs under
`.octon/state/evidence/validation/proposals/connector-operation-admission/`.
The parent program may summarize this evidence only after this child owns its
implementation, validation, conformance, drift/churn, closeout, and archive
receipts.

The implementation must replace and pass the child-owned conformance receipt at
`support/implementation-conformance-review.md` and the child-owned drift/churn
receipt at `support/post-implementation-drift-churn-review.md`.

## Rollback

Rollback is to restore the previous MCP `observe-context` drift digest record
and revert packet status and closeout receipts before archive. Rollback may not
remove the durable connector-admission contracts that are already validated by
`validate-connector-admission-runtime-v4.sh` unless a separate accepted child
authorizes that removal.

## Closeout Refusal Criteria

Refuse archive if connector availability can authorize execution, if MCP is
treating itself as a capability pack, if drift/quarantine state can bypass run
authorization, if support-target proof can widen support, if retained evidence
is proposal-local only, or if implementation conformance, post-implementation
drift/churn, checksum, registry, or worktree hygiene checks fail.
