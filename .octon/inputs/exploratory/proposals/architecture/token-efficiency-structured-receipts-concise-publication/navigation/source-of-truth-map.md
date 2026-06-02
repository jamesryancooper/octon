# Source Of Truth Map

## Proposal-local lifecycle sources

1. `proposal.yml`
2. `architecture-proposal.yml`

## Durable authority targets

- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Derived / non-authoritative artifacts

- `closeout-projection.yml`
- `publication-summary.yml`
- `structured-receipt.yml`
- `expanded-report-request.yml`

These artifacts are compact evidence, generated/read-model projections, or templates. They do not replace durable authorities or raw evidence.

## Parent Program

Parent proposal: `token-efficient-proposal-program-controller`

The parent may coordinate and summarize. It cannot satisfy this child's receipts.

## Boundary Rules

- This child cannot use parent summaries as child-owned evidence.
- Raw proposal inputs are non-authoritative.
- Generated/read-model outputs are advisory only.
- Material execution requires engine-owned authorization.
