# Source Context

## Conversation Lineage

The source material for this proposal came from a product-policy discussion about Octon's solo-developer orientation and whether Pull Requests should remain central.

The stance resolved through that discussion was:

- Octon should not focus on PRs as the default work unit.
- Octon's default work unit should be a Change.
- PRs should remain optional publishing and review outputs.
- Branches should be isolation tools, not mandatory ceremony.
- Direct-to-main should be allowed in solo mode under explicit safety criteria.
- Validation, review, closeout, and durable history should attach to the Change.

## Prior Audit Inputs

The audit request named `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml` as a required review target and asked for all contracts, standards, workflows, adapters, manifests, or practice documents that would need alignment.

The resulting implementation direction was to create a canonical policy location, then update downstream Git, closeout, workflow, skill, and documentation surfaces to reference that policy rather than owning the product stance.

## Open Questions Resolved Into This Proposal

The proposal takes these positions:

- Change is the product concept.
- Existing Work Package terminology should be fully cut over to Change Package before 1.0.
- Minimum durable history for a completed no-PR Change is commit or preserved patch/checkpoint, Change receipt, validation evidence, and rollback handle.
- Direct-to-main is allowed for low-risk solo Changes that satisfy safety and evidence criteria.
- AI and code review gates are Change-scoped and must run locally or be waived for no-PR Changes.
- Routing should be automated from Change risk, repo state, collaboration need, protected surfaces, validation requirements, and user intent.

The later refinement rejected aliases and shims for Work Package. The target state is a complete cutover: Change remains the product work unit, Change Package becomes the internal runtime bundle, and active authoritative surfaces should not preserve Work Package as a live term.
