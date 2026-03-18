# Instance Ingress

This is the canonical internal ingress surface for this repository's
super-rooted Octon harness.

## Behavioral Contract

- default agent: `.octon/framework/agency/manifest.yml`
- constitution: `.octon/framework/agency/governance/CONSTITUTION.md`
- delegation: `.octon/framework/agency/governance/DELEGATION.md`
- memory: `.octon/framework/agency/governance/MEMORY.md`
- execution contract: `.octon/framework/agency/runtime/agents/architect/AGENT.md`
- identity contract: `.octon/framework/agency/runtime/agents/architect/SOUL.md`
- objective brief: `.octon/instance/bootstrap/OBJECTIVE.md`
- active intent contract:
  `.octon/instance/cognition/context/shared/intent.contract.yml`

## Read Order

1. `.octon/instance/bootstrap/START.md`
2. `.octon/instance/bootstrap/scope.md`
3. `.octon/instance/bootstrap/conventions.md`
4. `.octon/instance/bootstrap/catalog.md`
5. `.octon/framework/cognition/_meta/architecture/specification.md`
6. `.octon/framework/cognition/governance/principles/README.md`
7. `.octon/state/continuity/repo/log.md`
8. `.octon/state/continuity/repo/tasks.json`

## Super-Root Topology

- `framework/` holds portable authored Octon core.
- `instance/` holds repo-specific durable authored authority.
- `inputs/` holds non-authoritative additive and exploratory inputs.
- `state/` holds operational truth and retained evidence.
- `generated/` holds rebuildable outputs only.

Only `framework/**` and `instance/**` are authored authority surfaces. Raw
`inputs/**` must never become direct runtime or policy dependencies.

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
