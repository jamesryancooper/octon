# Approval Control Roots

`state/control/execution/approvals/**` is the canonical live control family
for normalized approval requests and approval grants.

- `requests/**` stores canonical `ApprovalRequest` artifacts
- `grants/**` stores canonical `ApprovalGrant` artifacts
- quorum-governed requests cite the canonical quorum policy binding before a
  grant can remain valid
- host labels, comments, checks, and env flags may reference this family for
  visibility, but they never mint authority and cannot replace these artifacts
- GitHub control-plane workflows may project or request against this family,
  but runtime remains the canonical authority consumer.
