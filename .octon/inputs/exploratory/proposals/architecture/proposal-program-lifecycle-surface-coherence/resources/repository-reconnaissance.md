# Repository Reconnaissance

## Searches Run

- Checked for existing proposal ids before creating new packets.
- Read the proposal program pattern and the program structure validator.
- Read existing proposal program and child packet examples.
- Checked runtime capability and workflow surfaces for `proposal-program-delivery`.
- Checked `.codex/skills` for existing proposal delivery host projections.

## Existing Surfaces Found

- Canonical program delivery runtime skill exists at `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md`.
- Program delivery workflow exists at `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml`.
- Program review/revision is already represented in the program lifecycle contract and documented as parent-local coordination in the program pattern.
- The archived parent proposal exists at `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-to-clean-delivery/`.
- No `.codex/skills` projection for `proposal-program-delivery` was present at creation time.

## Reused Surfaces

- Existing proposal program packet shape.
- Existing child registry schema.
- Existing proposal standard, architecture proposal, program structure, and implementation-readiness validators.
- Existing program review/revision lifecycle semantics.

## Rejected Surfaces

- A standalone program review-and-revise wrapper is not created by this parent because the lifecycle contract already has parent-local program review/revision semantics.
- Nested child directories are rejected because child packets must remain sibling proposal packets.
- Generated projections are not treated as authority.

## New Surfaces Proposed

The new parent and child proposal packets are needed because the audit identified several related but separately owned durable changes. A program is the smallest route that preserves child authority while coordinating sequencing, aggregate closeout, archive handoff, cleanup, and terminal proof.
