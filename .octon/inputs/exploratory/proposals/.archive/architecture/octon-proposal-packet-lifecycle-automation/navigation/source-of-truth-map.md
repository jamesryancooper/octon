# Source Of Truth Map

## Purpose

This file defines the proposal-local reading order, authority boundaries, and
evidence model for this temporary architecture proposal.

## External Authorities

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Repository ingress and execution posture | `AGENTS.md`, `.octon/instance/ingress/AGENTS.md` | Defines mandatory reads and execution posture. |
| Constitutional kernel | `.octon/framework/constitution/**` | Outranks proposal-local lifecycle automation claims. |
| Proposal workspace contract | `.octon/inputs/exploratory/proposals/README.md` | Defines proposal placement, non-authority, and read order. |
| Proposal standards | `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`, `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md` | Define manifest and subtype requirements. |
| Extension pack model | `.octon/inputs/additive/extensions/**`, `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Raw extension packs are non-authoritative additive inputs until published. |
| Published extension runtime view | `.octon/generated/effective/extensions/**`, `.octon/generated/effective/capabilities/**` | Runtime-facing generated outputs after publication. |
| Proposal registry projection | `.octon/generated/proposals/registry.yml` | Discovery-only projection rebuilt from manifests. |

## Proposal-Local Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/target-architecture.md`
5. `architecture/reusable-patterns.md`
6. `architecture/proposal-program-pattern.md`
7. `architecture/lifecycle-route-matrix.md`
8. `architecture/implementation-plan.md`
9. `architecture/validation-plan.md`
10. `architecture/acceptance-criteria.md`
11. `navigation/artifact-catalog.md`
12. `/.octon/generated/proposals/registry.yml`

## Proposal-Local Roles

| Artifact | Role | Authority level |
| --- | --- | --- |
| `proposal.yml` | Identity, scope, promotion targets, lifecycle status, and exit contract | Highest proposal-local |
| `architecture-proposal.yml` | Architecture subtype contract | Secondary proposal-local |
| Architecture documents | Working target, plan, validation, and closeout design | Proposal working surface |
| Resource documents | Source context, risk, evidence, and baseline support | Supporting evidence |
| Support prompts | Packet-specific execution aids | Non-authoritative operational support |
| `navigation/artifact-catalog.md` | Packet inventory | Inventory only |

## Boundary Rules

- The proposed extension pack may author reusable prompt logic, routing,
  commands, skills, validation fixtures, and context docs.
- The extension pack must not make proposal packets authoritative.
- Proposal packets remain temporary implementation aids under
  `.octon/inputs/exploratory/proposals/**`.
- Proposal program parent packets coordinate canonical child proposal packets;
  they do not contain nested child proposal package directories and do not
  override child proposal manifests.
- Packet-specific generated prompts belong in packet `support/**` and remain
  operational aids.
- Full source context and manual prompt lineage belong in packet `resources/**`.
- Runtime-facing extension consumption must flow through generated effective
  extension and capability outputs.
- Closeout automation may operate GitHub and CI surfaces, but PR comments,
  labels, check dashboards, chat, model memory, and external tools do not
  become authority, control truth, or evidence unless retained through Octon
  evidence surfaces.
