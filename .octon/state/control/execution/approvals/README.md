# Approval Control Roots

`state/control/execution/approvals/**` is the canonical live control family
for normalized approval requests and approval grants.

- `requests/**` stores canonical `ApprovalRequest` artifacts
- `grants/**` stores canonical `ApprovalGrant` artifacts
- host labels, comments, checks, and env flags may reference this family for
  visibility, but they never mint authority and cannot replace these artifacts
- GitHub control-plane workflows dual-write their projected lane/blocker state
  into this family so labels remain projection-only UX.
