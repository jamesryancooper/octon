# Source Context

This proposal program is derived from two thread-local planning artifacts:

1. A deep architecture evaluation of Octon's cross-surface mechanisms.
2. A documentation architecture plan for governed cross-surface mechanisms.

Those artifacts established these conclusions:

- Use `product features` only for product documentation and product catalog
  entries.
- Use `governed cross-surface mechanisms` as the architecture and governance
  term.
- Use runtime/operator terms such as `lifecycles`, `workflows`, `routes`,
  `state machines`, `receipts`, command names, and skill names in runtime
  surfaces.
- Keep the product feature catalog navigation-only.
- Create a separate architecture mechanism index under
  `.octon/framework/cognition/_meta/architecture/`.
- Require every mechanism description to name authority-bearing surfaces,
  derived surfaces, raw/input surfaces, validators, ownership boundaries, and
  explicit non-authority boundaries.

## Required Mechanisms

The mechanism index must cover at least:

- Change Closeout Lifecycle
- Governed Lifecycle Orchestration
- Governed Incoming Intake Routing
- Extension Packs
- Run Lifecycle v1
- Workflow system
- Execution authorization / effect-token system
- Evidence store / proof plane
- Lifecycle interaction receipts
- Repo hygiene cleanup
- Mission autonomy / Mission Runner
- Mission Plan compiler
- Generated effective/runtime resolution
- Operator read models

## Key Risks To Resolve

- Product feature entries could be mistaken for authority.
- `state/control/**` could be mislabeled as retained evidence.
- Generated-effective surfaces could be mistaken for authored authority.
- Operator read models could be mistaken for runtime or support truth.
- Raw intake or exploratory proposals could be mistaken for policy or runtime
  input.
- Proposal lifecycle, Change closeout, worktree closeout, and repo hygiene
  could be collapsed into one authority system.
- Lifecycle interaction receipts could be treated as authorization.
- Parent proposal-program evidence could be allowed to satisfy child packet
  receipts.
- Retired `Lifecycle Autopilot` terminology could reappear outside explicit
  compatibility notes.
