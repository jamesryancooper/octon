# Instance Ingress

This is the canonical internal ingress surface for this repository's
super-rooted Octon harness.

Enable reliable agent execution that is deterministic enough to trust,
observable enough to debug, and flexible enough to evolve.

The machine-readable ingress declaration lives at
`/.octon/instance/ingress/manifest.yml`. Treat that manifest as the source of
truth for mandatory reads, optional overlays, conditional overlays, adapter
parity targets, and the branch closeout gate.

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

## Topology Reference

- authored authority lives only under `framework/**` and `instance/**`
- mutable operational truth and retained evidence live under `state/**`
- generated outputs live under `generated/**` and remain derived-only
- raw `inputs/**` never becomes a direct runtime or policy dependency
- `inputs/exploratory/ideation/**` remains human-led
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

## Branch Closeout Gate

Use `branch_closeout_gate` from `/.octon/instance/ingress/manifest.yml` as the
canonical closeout contract. Do not ask one fixed closeout question after
every file-changing turn.

The broader Git/worktree/PR/remediation workflow contract lives at
`/.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`.
Use that contract together with the ingress manifest when closeout, review
remediation, or helper semantics need interpretation.

The ingress manifest owns:

- when closeout may trigger
- how worktree and PR context are detected
- when autonomous versus manual merge lanes apply
- when prompts are suppressed and status should be reported instead
- the deprecated compatibility fallback for adapters that still read it

This ingress surface intentionally does not restate the prompt matrix or
full deprecated fallback matrix. The manifest remains authoritative; the
compatibility fallback prompt is retained here only for parity:
`Are you ready to closeout this branch?`
