# Acceptance Criteria

- Hosted/shared closeout receipts cannot cite local/private landing or cleanup
  refs.
- Local terminal evidence remains digest-backed retained evidence only.
- Metadata refreshes use canonical generators and record source/output digests.
- Generated metadata is never treated as authority.
- Validators identify the next owning route when evidence placement is wrong.
- Every manifest promotion target has current assumptions, required changes,
  owner, priority, rationale, retained evidence expectations, and rollback or
  closeout expectations recorded in `support/affected-artifact-map.md`.
- `support/pre-integration-architecture-review.yml` validates as a strict
  passing pre-integration architecture review receipt for the current reviewed
  packet digest.
- The next `review-packet` pass records a fresh packet digest, keeps
  implementation prompt authorization at `no` unless all review gates pass, and
  explicitly re-evaluates BF-001 through BF-003.
- Future implementation evidence includes negative controls for local/private
  evidence leakage into hosted/shared landing, cleanup, delivery, archive, or
  Change receipt claims.
