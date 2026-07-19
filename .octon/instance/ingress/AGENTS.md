# Instance Ingress

This is the canonical internal ingress surface for this repository's
super-rooted Octon harness.

Enable reliable agent execution that is deterministic enough to trust,
observable enough to debug, and flexible enough to evolve.

Octon's runtime posture is workflow-first: workflow state, run contracts,
authorization, evidence, rollback posture, and closeout own consequential
control flow. Agents participate only as bounded, evidenced activity nodes
inside admitted execution boundaries.

The machine-readable ingress declaration lives at
`/.octon/instance/ingress/manifest.yml`. Treat that manifest as the source of
truth for mandatory reads, optional overlays, conditional overlays, adapter
parity targets, and the canonical Change closeout workflow pointer.

Structural topology, class roots, publication metadata, and doc-target roles
live at `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`.
This ingress surface binds execution posture and required reads; it does not
restate the full topology registry.

## Behavioral Contract

- singular constitutional kernel:
  - `.octon/framework/constitution/CHARTER.md`
  - `.octon/framework/constitution/charter.yml`
  - `.octon/framework/constitution/precedence/normative.yml`
  - `.octon/framework/constitution/precedence/epistemic.yml`
  - `.octon/framework/constitution/obligations/fail-closed.yml`
  - `.octon/framework/constitution/obligations/evidence.yml`
  - `.octon/framework/constitution/ownership/roles.yml`
  - `.octon/framework/constitution/contracts/registry.yml`
- kernel execution profile:
  - `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`
- active workspace objective pair:
  - `.octon/instance/charter/workspace.md`
  - `.octon/instance/charter/workspace.yml`
- optional bootstrap orientation:
  - `.octon/instance/bootstrap/START.md`
- agent boundary rule:
  - agents may produce candidate artifacts, summaries, reviews,
    classifications, patches, repair suggestions, or exception
    recommendations
  - agents may not authorize effects, own workflow state, schedule themselves
    indefinitely, mutate control truth, admit connectors, or close work
- external-tool integrity:
  - agents must treat external tools as immutable dependencies
  - agents may use supported interfaces and external design evidence, but must
    keep every required solution change inside Octon's architecture and code
  - agents must not recommend forking, patching, modifying, reengineering, or
    maintaining a private derivative of an external tool

## Read Order

The ordered mandatory read set below must remain in parity with
`/.octon/instance/ingress/manifest.yml`.

1. `.octon/framework/constitution/CHARTER.md`
2. `.octon/framework/constitution/charter.yml`
3. `.octon/framework/constitution/obligations/fail-closed.yml`
4. `.octon/framework/constitution/obligations/evidence.yml`
5. `.octon/framework/constitution/precedence/normative.yml`
6. `.octon/framework/constitution/precedence/epistemic.yml`
7. `.octon/framework/constitution/ownership/roles.yml`
8. `.octon/framework/constitution/contracts/registry.yml`
9. `.octon/instance/charter/workspace.md`
10. `.octon/instance/charter/workspace.yml`
11. `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`

## Optional Orientation

Use these only after the minimal constitutional read set above is bound:

- `.octon/instance/bootstrap/START.md`
- `.octon/instance/bootstrap/scope.md`
- `.octon/instance/bootstrap/conventions.md`
- `.octon/instance/bootstrap/catalog.md`
- `.octon/state/continuity/repo/log.md`
- `.octon/state/continuity/repo/tasks.json`
- `.octon/state/continuity/scopes/<scope-id>/{log.md,tasks.json}` when the
  current work is primarily owned by a declared scope

## Conditional Orientation

For non-trivial AI-assisted governance, runtime, refactor, migration, assurance,
or repo-consequential work, read:

- `.octon/framework/execution-roles/practices/standards/ai-assisted-development-discipline.md`
- `.octon/framework/execution-roles/practices/standards/repository-reconnaissance.md`
- `.octon/framework/execution-roles/practices/standards/cleanup-pass.md`
- `.octon/framework/execution-roles/practices/standards/dependency-discipline.md`
- `.octon/framework/execution-roles/practices/standards/external-tool-integrity.md`
- `.octon/framework/execution-roles/practices/standards/validation-evidence-quality.md`

## Topology Reference

- Only `framework/**` and `instance/**` are authored authority surfaces.
- authored authority lives only under `framework/**` and `instance/**`
- mutable operational truth and retained evidence live under `state/**`
- generated outputs live under `generated/**` and remain derived-only
- raw `inputs/**` never becomes a direct runtime or policy dependency
- `inputs/exploratory/ideation/**` remains human-led
- generated summaries, raw inputs, chat, model memory, host UI state, tool
  availability, MCP server availability, Durable Object state, and external
  workflow dashboards are not authority, permission, policy, retained
  evidence, or closeout truth
- overlay legality, publication metadata, and steady-state path families are
  registry-backed rather than hand-maintained here

## Execution Profile Governance

Before planning or implementation:

1. select exactly one `change_profile`
2. record `release_state`
3. emit a `Profile Selection Receipt`

For this repository, `pre-1.0` defaults to `atomic` unless a hard gate
requires `transitional`.

## Human-Led Zone

`/.octon/inputs/exploratory/ideation/**` is human-led. Autonomous access is
blocked unless a human explicitly scopes the request.

## Change Closeout

Ingress does not own Change closeout policy.

When work reaches a credible completion point, resolve Change closeout from:

- `/.octon/framework/product/contracts/default-work-unit.yml`
- `closeout_workflow_ref` in `/.octon/instance/ingress/manifest.yml`
- `/.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`

Build-to-delete or claim-closeout governance remains distinct and lives under
`/.octon/instance/governance/contracts/closeout-reviews.yml`.
