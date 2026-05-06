# Policy Decision

## Status

Proposed.

## Context

Octon targets solo developers. For that audience, treating Pull Requests as the default work unit imports a team-review workflow into a product that should optimize for local momentum, durable evidence, and reversible change.

PRs remain useful when a Change needs hosted review, remote CI, branch protection, collaboration, preview environments, or publication. They should not be the conceptual center of Octon execution.

## Decision

Octon's default work unit is a Change.

A Change is the durable unit of intent, execution, evidence, validation, and closeout. Its compiled internal execution bundle is a Change Package. Run Contracts, receipts, commits, patches, checkpoints, proposal packets, branches, and PRs are artifacts around the Change rather than replacements for the product concept.

Work Package is deprecated terminology. Because Octon is unreleased and still converging toward 1.0, this proposal requires a complete cutover from Work Package to Change Package in active authoritative surfaces. No compatibility aliases or shims are part of the target state.

Pull Requests are optional publishing and review outputs. A PR is selected when the Change requires hosted review, remote checks, collaborative inspection, external publication, protected-branch compliance, or an explicit user request. Otherwise, Octon may complete the Change without a PR.

Branches are isolation tools. They are required when the Change needs isolation from `main`, spans multiple sessions, carries elevated risk, touches protected surfaces, has incomplete validation, or may need review before landing. Branches are not required merely because a Change exists.

Direct-to-main is allowed in solo mode when all of these are true:

- the repository is on a clean, current `main`;
- the Change is low risk and locally understandable;
- validation can run locally at the required floor;
- rollback is straightforward from the resulting commit;
- no protected surface, collaboration requirement, or user instruction requires a branch or PR.

Branch-without-PR is the default isolation path for Changes that need a branch but do not need hosted review or publication.

Branch-with-PR is the review and publication path for Changes that need GitHub-native review, remote CI, preview links, protected-branch compliance, external signoff, or user-requested publication.

No-PR Changes still require durable history. A completed code Change must leave at least:

- a landed commit or an explicitly preserved patch/checkpoint if the Change is not landed;
- a Change receipt or equivalent closeout record tying intent, diff, validation, and outcome together;
- run evidence for the selected validation floor;
- a rollback handle, such as a commit hash, patch reversal note, or restoration instruction.

AI review and code review gates attach to the Change, not the PR. PR-backed Changes may satisfy gates through GitHub review and checks. No-PR Changes must satisfy the same policy intent through local review, local validation, recorded evidence, or explicit waiver.

## Consequences

Octon becomes product-aligned for solo developers: work starts from intent and evidence, not from a collaboration artifact.

PRs remain supported and first-class when they are useful, but Octon stops treating them as mandatory ceremony.

Existing Work Package machinery should be renamed to Change Package during this promotion. The product contract should not preserve Work Package as an active implementation term, because doing so would create a permanent translation burden for agents, validators, maintainers, and future policy.

Git, closeout, validation, and skill surfaces must be updated so they route by Change risk and publication need instead of assuming a branch or PR by default.
