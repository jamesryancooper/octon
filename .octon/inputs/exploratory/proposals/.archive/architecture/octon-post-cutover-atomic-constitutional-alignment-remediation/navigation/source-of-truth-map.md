# Source of Truth Map

## Durable authorities after promotion

### Live constitutional model selector

The only live constitutional-model selector after promotion is the March 30, 2026 atomic cutover receipt, as referenced from:

- `/.octon/framework/constitution/charter.yml#live_model.profile_selection_receipt_ref`

Every active constitutional family must either:

1. point `profile_selection_receipt_ref` at that same receipt, or
2. carry an explicitly named live-selector field that resolves to that same receipt while keeping older phase receipts as lineage only

No active family should imply that a March 28 or March 29 phase receipt is still the current live-model selector.

### Constitutional kernel

The supreme repo-local constitutional kernel remains:

- `/.octon/framework/constitution/CHARTER.md`
- `/.octon/framework/constitution/charter.yml`
- `/.octon/framework/constitution/precedence/{normative.yml,epistemic.yml}`
- `/.octon/framework/constitution/obligations/{fail-closed.yml,evidence.yml}`
- `/.octon/framework/constitution/ownership/roles.yml`
- `/.octon/framework/constitution/contracts/**`

### Repo-local authored authority

The durable repo-local authored authority relevant to this packet remains:

- `/.octon/instance/charter/workspace.{md,yml}`
- `/.octon/instance/bootstrap/START.md`
- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/governance/disclosure/harness-card.yml`
- `/.octon/instance/governance/ownership/registry.yml`

### Live disclosure model

The live disclosure model after promotion is:

- authored HarnessCard source: `/.octon/instance/governance/disclosure/**`
- retained run disclosure: `/.octon/state/evidence/disclosure/runs/**`
- retained release disclosure: `/.octon/state/evidence/disclosure/releases/**`

Historical mirrors may remain under:

- `/.octon/state/evidence/lab/harness-cards/**`

but they are retained lineage only, never canonical live disclosure.

### Support claims and proof

Live support claims resolve from the combination of:

- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/governance/disclosure/harness-card.yml`
- retained release disclosure under `/.octon/state/evidence/disclosure/releases/**`
- retained run disclosure and lab proof bundles referenced by the HarnessCard

A published support target without matching retained proof is not sufficient for a live claim.

### Bootstrap orientation and topology

The authoritative structural boundary remains:

- only `framework/**` and `instance/**` are authored authority
- `inputs/**` are raw, non-authoritative inputs
- `state/**` are operational truth and retained evidence
- `generated/**` are derived-only

`START.md` and `/.octon/README.md` may explain that boundary, but they may not redefine it.

### Subordinate principles surface

`/.octon/framework/cognition/governance/principles/**` remains authoritative only within the subordinate principles surface. Ownership identifiers on that surface must resolve through the ownership registry rather than placeholder values.

## Proposal status

This proposal is non-canonical. After promotion:

- canonical truth must live in the durable roots above
- this packet may remain as lineage
- no runtime, policy, or disclosure consumer may depend on this packet path
