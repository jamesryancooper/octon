# Control, Authority, and Governance Model

## Human / harness / model boundaries
### Humans own
- constitutional amendments
- support-target changes
- policy changes
- ownership rules
- one-way-door approvals
- exception leases
- revocations
- external/public commitments
- HarnessCard release sign-off

### Harness owns
- route evaluation
- fail-closed enforcement
- grant/receipt validation
- run-state integrity
- replay integrity
- intervention logging
- disclosure assembly

### Model owns
- bounded planning
- run-contract drafts
- execution strategy within grant
- local deterministic self-checks
- low-risk retries

### Model may not own
- approvals
- exception/lease issuance
- revocations
- support-tier widening
- irreversible authorization
- final consequential acceptance

## Route semantics
- `ALLOW`
- `STAGE_ONLY`
- `ESCALATE`
- `DENY`

## Approval rules
- every material approval uses `ApprovalRequest` + `ApprovalGrant`
- host labels/comments/checks are projections only
- approvals must be scope- and time-bounded
- approval artifacts carry quorum, conditions, and revocation policy

## Exception lease rules
- temporary
- scoped
- owner-bound
- revocable
- expiry is hard fail-closed

## Revocation rules
- immediate and authoritative
- may target grants, leases, adapters, capability packs, or live runs
- triggers safing and continuity updates

## Fail-closed conditions
At minimum fail closed or stage only on:
- missing run contract
- missing or invalid intent binding
- missing mission context when mission is required
- unresolved ownership
- unsupported support-tier tuple
- missing required evidence or freshness receipts
- policy ambiguity with no explicit precedence resolution
