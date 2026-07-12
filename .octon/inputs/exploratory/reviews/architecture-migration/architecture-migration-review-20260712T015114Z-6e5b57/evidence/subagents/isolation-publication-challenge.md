# Subagent Report — Isolation, Publication, Challenger

Agent: /root/isolation_publication_challenge

Assignments: B, C, J. Read-only repository and provider inspection. Sibling
review tree was not listed, searched, read, or cited.

## Accepted findings

- B-ISO-001: candidates are neither credentialless nor disposable.
- B-GITSTATE-001: worktrees share canonical Git common state.
- B-BROKER-001: separate deterministic broker/store absent.
- C-ROUTE-001: direct-main and direct Git remain normal routes.
- C-AUTH-001: hosted no-PR authorization is self-minted, unsigned, and
  non-consuming.
- C-VERIFY-001: required exact-SHA checks are candidate-controlled.
- C-CI-001: candidate code executes with provider-write credentials.
- C-GIT-001: privileged Git is not sanitized.
- J-SECONDPLANE-001: current GitHub workflow behavior is a second effect plane.
- J-TRUST-001: trust activation is unverified and not ready.
- J-CLAIM-001: current consequential support claims require downgrade.

## Accepted strengths

Canonical path containment, Codex ephemeral/workspace posture, lifecycle
cancellation, no-PR exact-ref/check/post-land logic, no-bypass provider
ruleset, base-workflow/fork/main constraints, and work-unit cleanup/rollback
vocabulary.

## Provider observations

Active ruleset 12881449, strict four checks, no PR rule, no bypass actors;
Actions broadly allowed; AUTONOMY_AUTO_MERGE_ENABLED true; AUTONOMY_PAT secret
metadata present; no secret values read.

## Rejected or narrowed

No central finding was rejected. The primary reviewer did not call the
target-race/duplicate-context scenarios dynamically proven; both remain
architectural/provider inferences pending fixtures. The remote worker is
excluded from the minimum proof rather than mandated.

## Disagreements

None.

