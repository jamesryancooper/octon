# Octon Retirement And Hygiene Packetizer Extension Pack

This bundled additive pack joins `repo-hygiene`, retirement coverage
reconciliation, and ablation-plan drafting into one reusable operator-facing
workflow.

It is designed to:

- orchestrate the existing `repo-hygiene` modes without weakening their
  destructive posture
- reconcile findings against the canonical retirement registry, retirement
  register, closeout review packet, and claim gate
- force protected and claim-adjacent surfaces into `never-delete` outcomes in
  extension-authored drafts
- draft non-authoritative cleanup packet inputs and optional migration proposal
  drafts for human review

## Buckets

- `skills/` - composite and leaf skill contracts for each planning flow
- `commands/` - thin command wrappers for the dispatcher and each leaf route
- `templates/` - non-authoritative draft shapes for cleanup inputs, ablation
  plans, and optional migration proposal drafts
- `context/` - routing and flow-level dependency guidance
- `validation/` - compatibility profile, scenarios, and pack-local tests

## User-Facing Problem

Core Octon already provides:

- `repo-hygiene` for detection and structured audit evidence
- `retirement-registry.yml` for registered transitional or historical targets
- `retirement-register.yml` for claim-facing retained-surface status
- `closeout-reviews.yml` for build-to-delete review packet truth
- `claim-gate.yml` for claim readiness

What it does not provide directly is one reusable operator-facing capability
that joins those surfaces into:

- one reconciliation summary
- one coverage gap analysis
- one guarded cleanup-packet input draft
- one guarded ablation-plan draft

## V1 Flows

- `scan-to-reconciliation`
- `audit-to-packet-draft`
- `registry-gap-analysis`
- `ablation-plan-draft`

## Flow Summary

| Flow | When To Use It | Primary Output |
| --- | --- | --- |
| `scan-to-reconciliation` | quick read-only hygiene review | reconciliation summary under skill evidence |
| `audit-to-packet-draft` | structured hygiene evidence already exists or should be produced now | `cleanup-packet-inputs.yml`, draft summary, optional migration proposal draft |
| `registry-gap-analysis` | retirement coverage may be stale, incomplete, or contradictory | `gap-analysis.md` and `gap-analysis.yml` |
| `ablation-plan-draft` | findings need a governed cleanup plan rather than raw detector output | `ablation-plan.md` and `ablation-targets.yml` |

## Entry Points

- composite command: `/octon-retirement-and-hygiene-packetizer`
- leaf commands:
  - `/octon-retirement-and-hygiene-packetizer-scan-to-reconciliation`
  - `/octon-retirement-and-hygiene-packetizer-audit-to-packet-draft`
  - `/octon-retirement-and-hygiene-packetizer-registry-gap-analysis`
  - `/octon-retirement-and-hygiene-packetizer-ablation-plan-draft`

## Activation And Publication

- Repo-owned desired activation remains in `/.octon/instance/extensions.yml`.
- V1 lands disabled by default to preserve additive opt-in posture.
- Runtime-facing publication continues to flow through:
  - `/.octon/generated/effective/extensions/**`
  - `/.octon/generated/effective/capabilities/**`
- Raw pack paths under `inputs/additive/extensions/**` remain non-authoritative.

## Outputs

- retained run evidence under
  `/.octon/state/evidence/runs/skills/octon-retirement-and-hygiene-packetizer/**`
- optional checkpoints under
  `/.octon/state/control/skills/checkpoints/octon-retirement-and-hygiene-packetizer/**`
- optional migration proposal drafts under
  `/.octon/inputs/exploratory/proposals/migration/<proposal_id>/`

All pack-authored outputs remain draft or evidence surfaces only.

## Validation

Primary validation guidance lives under `validation/README.md`.

The pack-local suite covers:

- additive boundary enforcement
- route publication and dispatcher behavior
- repo-hygiene composition
- protected and claim-adjacent guardrails
- non-authoritative migration proposal drafting
- host-projection publication from published capability routing

## Boundary

This pack is additive only.

It must not:

- update retirement authority surfaces
- auto-attach outputs to the live build-to-delete packet
- auto-delete, auto-demote, or auto-register targets
- mint runtime or policy authority from raw pack paths

Runtime-facing discovery must continue to flow through published effective
extension and capability outputs. Repo trust remains in
`/.octon/instance/extensions.yml`.
