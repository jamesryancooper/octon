# Acceptance Criteria

- `architecture-proposal.yml#architecture_scope` uses an allowed architecture
  proposal enum.
- Architecture-floor artifacts exist for current state, file-change map,
  cutover, rollback, operator disclosure, validation, evidence, risk, and
  assumptions/blockers.
- Every parent postmortem requirement is mapped to live evidence, current
  classification, downstream owner, required change or no-op rationale, and
  validation expectation.
- Promotion targets are explained by file or subdirectory, with clear read,
  no-op, and downstream mutation boundaries.
- The source-of-truth map names durable authorities, proposal-local lifecycle
  sources, generated projections, retained evidence roots, run-control
  surfaces, parent/child boundaries, and forbidden authority transfers.
- `support/implementation-grade-completeness-review.md` accurately reflects
  packet-local readiness without authorizing implementation.
- `proposal.yml#status` remains `in-review`.
- The packet passes structural, architecture subtype, implementation-readiness,
  and baseline review-gate validators, or records any external validator
  blocker without claiming acceptance.
- The next lifecycle route remains `review-packet`.
