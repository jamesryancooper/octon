# Source of Truth Map

This file defines the proposal-local precedence model, authority boundaries,
and evidence posture for `octon-bounded-uec-packet`. It does not make the
packet a canonical repository authority.

## Durable external authorities

| Concern | Durable source of truth | Why it outranks the packet |
| --- | --- | --- |
| Ingress read order, constitutional kernel, and profile defaults | `AGENTS.md`, `/.octon/instance/ingress/AGENTS.md`, `/.octon/framework/constitution/**`, `/.octon/instance/charter/workspace.{md,yml}`, `/.octon/framework/agency/runtime/agents/orchestrator/AGENT.md` | These define the live constitutional read set, execution boundaries, and profile-selection rules that the packet must preserve. |
| Current claim state and governance posture | `/.octon/instance/governance/**`, `/.octon/generated/effective/**` | These define the live release, disclosure, and support-target claims that the packet is trying to harden and recertify. |
| Runtime control and retained evidence | `/.octon/state/control/execution/**`, `/.octon/state/evidence/**` | These are the factual control and evidence surfaces for authority, run state, and disclosure proof. |
| Proposal-system contract | `/.octon/inputs/exploratory/proposals/README.md`, `/.octon/framework/scaffolding/governance/patterns/proposal-standard.md`, `/.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | These define the packet path, manifest contract, lifecycle rules, and minimum file obligations. |
| Proposal validation floor | `/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh`, `/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh` | These provide the validator-backed minimum for proposal correctness. |

## Proposal-local authorities

| Artifact | Role | Authority level within the packet |
| --- | --- | --- |
| `proposal.yml` | packet identity, scope, lifecycle, and promotion targets | highest proposal-local authority |
| `architecture-proposal.yml` | architecture subtype scope and decision classification | secondary proposal-local authority |
| `navigation/source-of-truth-map.md` | explicit proposal-local precedence and boundary map | tertiary proposal-local authority |
| `00-master-proposal-packet.md` | primary closure-hardening narrative and decision record | primary narrative design surface |
| `architecture/target-architecture.md` | condensed target-state definition | binding target-state summary within the packet |
| `architecture/acceptance-criteria.md` | proof contract for re-attaining the bounded complete claim | binding acceptance surface |
| `architecture/implementation-plan.md` | staged execution workstreams and receipts | operational planning within the packet |
| `specs/*.md` | detailed target-state, remediation, validation, disclosure, and cutover program | supporting design authority |
| `traceability/*.md` | blocker register, crosswalk, and file change register | supporting traceability authority |
| `resources/*.md` | retained audit, evidence, and delta material | supporting evidence for review only |
| `README.md` | human entry point and reading order | explanatory only |
| `navigation/artifact-catalog.md` | inventory only | lowest proposal-local authority |

## Derived or non-authoritative surfaces

| Surface | Status | Rule |
| --- | --- | --- |
| `/.octon/generated/proposals/registry.yml` | generated discovery projection | may list this proposal, but never outranks `proposal.yml` or `architecture-proposal.yml` |
| `resources/*.md` copies and excerpts | retained packet-local evidence | helpful for review, never live repo authority |
| prompt files that reference archived packets | supporting execution aids | may guide implementation, but do not outrank live constitutional or governance surfaces |

## Boundary rules

1. Only `framework/**` and `instance/**` are authored authority.
2. `state/**` is authoritative only as live control truth and retained evidence.
3. `generated/**` is derived and never a source of truth over retained evidence.
4. Raw `inputs/**` must never become a direct runtime or policy dependency.
5. This packet may shape durable implementation, but no promoted target may
   depend on the packet path after promotion.
6. Claim status may only move back to `complete` after retained evidence and
   validator outputs satisfy the bounded recertification burden.

## Conflict resolution order for this packet

1. Durable constitutional, governance, runtime-control, and retained-evidence
   authorities in the live repo.
2. `proposal.yml`
3. `architecture-proposal.yml`
4. `00-master-proposal-packet.md`
5. `architecture/*.md`
6. `specs/*.md`
7. `traceability/*.md`
8. `resources/*.md`
9. `README.md`
10. `navigation/artifact-catalog.md`
