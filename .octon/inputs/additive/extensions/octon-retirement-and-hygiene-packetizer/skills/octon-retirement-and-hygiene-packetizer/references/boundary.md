# Boundary

## Extension-Owned Additive Workflow

- route resolution
- retirement coverage reconciliation
- gap analysis
- cleanup packet input drafting
- ablation-plan drafting
- optional migration proposal draft scaffolding

## Existing Core Surfaces Reused As-Is

- `/.octon/instance/capabilities/runtime/commands/repo-hygiene/repo-hygiene.sh`
- `/.octon/instance/governance/policies/repo-hygiene.yml`
- `/.octon/instance/governance/contracts/closeout-reviews.yml`
- `/.octon/instance/governance/contracts/retirement-registry.yml`
- `/.octon/instance/governance/retirement-register.yml`
- `/.octon/instance/governance/retirement/claim-gate.yml`
- `/.octon/instance/governance/contracts/retirement-policy.yml`
- `/.octon/instance/governance/contracts/retirement-review.yml`
- `/.octon/instance/governance/contracts/ablation-deletion-workflow.yml`

## Explicit Non-Goals

- writing governance contracts or runtime service contracts inside the pack
- mutating retirement authority artifacts
- writing live build-to-delete receipts
- introducing always-on governance, runtime, publication, or assurance gates
