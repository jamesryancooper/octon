# Acceptance Criteria

- `--confirm` is not a mandatory human gate when a valid current hosted no-PR
  authorization receipt exists.
- The execution flag validates the receipt and immediate live facts before
  mutation.
- Landing evidence records receipt path, source/target refs, exact SHA,
  checks or empty-check rationale, provider-control status, rollback handle,
  execution result, and final sync proof.
- Autonomous hosted mutation requires pre-approved command prefixes or
  equivalent execution-environment authority in addition to the Octon receipt.
- Negative controls block stale, missing, denied, externally blocked,
  policy-incomplete, force-push, and failed-check cases.
