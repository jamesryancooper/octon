# Repo Evidence 04 — Retirement and Ablation Spine Excerpts

## Retirement policy

**Source:** `/.octon/instance/governance/contracts/retirement-policy.yml`

- policy id: `execution-constitution-build-to-delete`
- registry ref:
  `.octon/instance/governance/contracts/retirement-registry.yml`
- ablation workflow ref:
  `.octon/instance/governance/contracts/ablation-deletion-workflow.yml`
- rule `RET-001`: every compensating mechanism must be registered with owner,
  support scope, value metric, review date, retirement trigger, required
  ablation suite, evidence requirements, and retirement path
- rule `RET-002`: historical or compatibility-only surfaces may remain only
  when the retirement registry marks them non-authoritative and drift review
  keeps them out of the live execution path
- rule `RET-003`: deletion, demotion, or continued retention is valid only
  after drift review, support-target review, adapter review, retirement review,
  and ablation evidence are current
- rule `RET-004`: final target-state claim fails closed when any registered
  target lacks active owner, future review date, or retirement path

## Ablation workflow

**Source:** `/.octon/instance/governance/contracts/ablation-deletion-workflow.yml`

- workflow id: `ablation-driven-deletion`
- registry ref:
  `.octon/instance/governance/contracts/retirement-registry.yml`
- receipt root:
  `.octon/state/evidence/validation/publication/build-to-delete`
- decision values:
  - `delete`
  - `retain`
  - `demote`
- evidence requirements:
  - `ablation-deletion-receipt`
  - `retirement-review`
  - `current drift-review`
  - `current adapter-review`
  - `current support-target-review`
- blocking rule: deletion or final-claim approval is invalid without a current
  ablation-deletion receipt for each target evaluated in the release

## Retirement registry examples

**Source:** `/.octon/instance/governance/contracts/retirement-registry.yml`

The current registry already tracks the kinds of surfaces this proposal needs to
manage, including:

- `workspace-objective-compatibility-shims`
- `helper-authored-run-projections`
- `run-local-disclosure-mirrors`
- `lab-local-harness-card-mirrors`
- `superseded-release-disclosure-bundles`

These entries already carry paths, owner refs, support scope, value metric,
review contract ref, review date, retirement trigger, required ablation suite,
evidence requirements, and retirement path.

## Retirement register

**Source:** `/.octon/instance/governance/retirement-register.yml`

- the human-facing register already exists and is used to retain rationale and
  status for retained or historical surfaces.

## Implication for this packet

The live repository already has a mature build-to-delete governance spine. The
correct hygiene design is to extend and feed that spine, not to invent a
parallel transitional registry or a separate delete-approval system.
