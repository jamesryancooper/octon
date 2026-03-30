# Instance Ingress

This is the canonical internal ingress surface for this repository's
super-rooted Octon harness.

Enable reliable agent execution that is deterministic enough to trust,
observable enough to debug, and flexible enough to evolve.

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
  - `.octon/framework/agency/runtime/agents/orchestrator/AGENT.md`
- optional supporting overlays:
  - `.octon/framework/agency/governance/DELEGATION.md`
  - `.octon/framework/agency/governance/MEMORY.md`
- active workspace objective pair:
  - `.octon/instance/charter/workspace.md`
  - `.octon/instance/charter/workspace.yml`
- compatibility workspace-charter shims:
  - `.octon/instance/bootstrap/OBJECTIVE.md`
  - `.octon/instance/cognition/context/shared/intent.contract.yml`
- optional bootstrap orientation:
  - `.octon/instance/bootstrap/START.md`

## Read Order

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

## Super-Root Topology

- `framework/` holds portable authored Octon core.
- `instance/` holds repo-specific durable authored authority.
- `inputs/` holds non-authoritative additive and exploratory inputs.
- `state/` holds operational truth and retained evidence.
- `generated/` holds rebuildable outputs only.

Only `framework/**` and `instance/**` are authored authority surfaces. Raw
`inputs/**` must never become direct runtime or policy dependencies.
`framework/constitution/**` is the supreme repo-local control regime within
those authored authority surfaces.

## Human-Led Zone

`/.octon/inputs/exploratory/ideation/**` is human-led. Autonomous access is
blocked unless a human explicitly scopes the request.

## Execution Profile Governance

Before planning or implementation:

1. select exactly one `change_profile`
2. record `release_state`
3. emit a `Profile Selection Receipt`

For this repository, `pre-1.0` defaults to `atomic` unless a hard gate requires
`transitional`.

## Branch Closeout Gate

After any turn that changes files, ask exactly:

`Are you ready to closeout this branch?`
