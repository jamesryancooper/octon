# File Change Map

- proposal: `octon-proposal-packet-lifecycle-automation`

## Authored Extension Pack

| Target | Change |
| --- | --- |
| `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/pack.yml` | Add first-party pack metadata and content entrypoints. |
| `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/README.md` | Document lifecycle scope, entry points, boundaries, and publication readiness. |
| `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/context/**` | Add lifecycle model, scenario taxonomy, routing guide, output boundaries, bundle matrix, routing contract, reusable patterns, and the Proposal Program pattern. |
| `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/context/patterns/proposal-program.md` | Preferred durable home for the full parent/child Proposal Program pattern. |
| `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/prompts/shared/**` | Add shared contracts for repository grounding, proposal contracts, authority boundaries, lifecycle artifact placement, validation/evidence, and GitHub closeout boundaries. |
| `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/prompts/**` | Add shared contracts and route-specific prompt bundles. |
| `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/prompts/create-proposal-program/**` | Add parent program packet creation route. |
| `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/prompts/generate-program-implementation-prompt/**` | Add aggregate implementation prompt generation route for child packet sequences. |
| `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/prompts/generate-program-verification-prompt/**` | Add aggregate verification prompt generation route. |
| `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/prompts/run-program-verification-and-correction-loop/**` | Add program-level and child-level convergence route. |
| `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/prompts/generate-program-closeout-prompt/**` | Add aggregate closeout prompt generation route. |
| `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/prompts/closeout-proposal-program/**` | Add gated parent and child closeout route. |
| `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/commands/**` | Add composite and leaf command wrappers. |
| `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/skills/**` | Add composite and leaf skills. |
| `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/validation/**` | Add compatibility profile, local tests, scenarios, and bundle matrix. |

## Activation And Generated Outputs

| Target | Change |
| --- | --- |
| `.octon/instance/extensions.yml` | Add the pack to enabled or explicitly selected first-party extension state. |
| `.octon/state/control/extensions/active.yml` | Regenerate active extension state after publication. |
| `.octon/generated/effective/extensions/**` | Publish effective extension catalog, artifact map, and generation lock. |
| `.octon/generated/effective/capabilities/**` | Publish command and skill routing outputs. |

## Host Projections

| Target | Change |
| --- | --- |
| `.claude/commands/**` | Publish command wrappers for Claude host projection. |
| `.claude/skills/**` | Publish skill projections for Claude host projection. |
| `.codex/skills/**` | Publish skill projections for Codex host projection. |
| `.cursor/rules/**` | Publish Cursor-compatible projections if the current host projection system emits them. |

Host projections are expected implementation outputs but not `proposal.yml`
promotion targets, because this active proposal uses `promotion_scope:
octon-internal` and must keep promotion targets under `.octon/**`.

## Out Of Scope

- Direct edits to proposal packet authority rules unless validators require a narrow bug fix.
- New proposal workspace roots.
- Nested child proposal packet directories under parent proposal packets.
- Runtime or policy reads from raw extension pack paths.
- Direct mutation of generated proposal registry outside the canonical generator.
