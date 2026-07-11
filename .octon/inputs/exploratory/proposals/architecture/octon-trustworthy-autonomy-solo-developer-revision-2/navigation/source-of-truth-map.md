# Proposal Reading and Precedence Map

## Boundary

This packet is non-authoritative exploratory input. It may inform a decision
and later implementation, but it cannot authorize execution or satisfy a
runtime, provider, evidence, approval, merge, activation, or closeout gate.

## Precedence

| Rank | Surface | Role |
| --- | --- | --- |
| 1 | Constitutional kernel, live revocations, and external obligations | Governing authority |
| 2 | Durable framework and instance contracts named by this packet | Current architecture and policy |
| 3 | Live control state and validated retained evidence | Current operational fact |
| 4 | `proposal.yml` and `architecture-proposal.yml` | Proposal identity, scope, and lifecycle only |
| 5 | `architecture/target-architecture.md` and the detailed architecture documents | Proposed target design |
| 6 | `resources/evidence-appendix.yml` | Bounded evidence and limitations |
| 7 | Navigation, support notes, and this README | Explanatory support |
| 8 | Generated proposal registry | Discovery projection only |

## Durable Sources

| Concern | Current source |
| --- | --- |
| Constitutional posture | `.octon/framework/constitution/**` |
| Execution authorization and typed effects | `.octon/framework/engine/runtime/spec/execution-authorization-v1.md` and `authorized-effect-token-v1.md` |
| Runtime implementation | `.octon/framework/engine/runtime/crates/**` |
| Project Profile and task harness | `.octon/framework/engine/runtime/spec/project-profile-v1.schema.json` and `task-specific-execution-harness-v1.md` |
| Provider projection contract | `.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json` |
| Live provider configuration | GitHub API observation recorded in `resources/evidence-appendix.yml` |
| Proposal lifecycle | `.octon/framework/scaffolding/governance/patterns/proposal-standard.md` and `architecture-proposal-standard.md` |

## Evidence Classes

Repository declarations, static implementation inspection, focused dynamic
tests, live provider observations, deployment-local configuration, and
architectural inference remain separately labeled. A hash chain without an
independent anchor is not treated as adversarial tamper evidence. A declared
test or schema is not treated as runtime proof.

## Conflict Rule

Live repository and provider facts outrank packet assumptions. If acceptance
would require changing the constitutional kernel, precedence, fail-closed
obligations, or the rule that only canonical authority may authorize effects,
stop and route the conflict to a constitutional-challenge packet.
