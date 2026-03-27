# Approval Control Roots

`state/control/execution/approvals/**` is the canonical live control family
for normalized approval requests and approval grants.

- `requests/**` stores canonical `ApprovalRequest` artifacts
- `grants/**` stores canonical `ApprovalGrant` artifacts
- host labels, comments, checks, and env flags may project into this family,
  but they are never authority until runtime materializes these artifacts
