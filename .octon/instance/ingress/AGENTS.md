# Instance Ingress

This is the canonical internal ingress surface for this repository's
super-rooted Octon harness.

Enable reliable agent execution that is deterministic enough to trust,
observable enough to debug, and flexible enough to evolve.

The machine-readable ingress declaration lives at
`/.octon/instance/ingress/manifest.yml`. Treat the manifest as the source of
truth for mandatory reads, optional overlays, conditional overlays, adapter
parity targets, and the branch closeout gate, including any deprecated
compatibility fallback prompt.

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
11. `.octon/framework/agency/runtime/agents/orchestrator/AGENT.md`

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

Use `branch_closeout_gate` from `/.octon/instance/ingress/manifest.yml` as the
canonical closeout contract. Do not ask one fixed closeout question after
every file-changing turn.

The broader Git/worktree/PR/remediation workflow contract lives at
`/.octon/framework/agency/practices/standards/git-worktree-autonomy-contract.yml`.
Use that contract together with the ingress manifest when closeout, review
remediation, or helper semantics need interpretation.

- trigger the gate only when:
  - a turn changed files and reached a credible completion point
  - the user explicitly asks to finish, ship, or closeout
- detect context from:
  - whether the work is on the primary `main` worktree or clone, versus a
    branch worktree
  - whether a PR exists for the current branch, and whether it is draft or
    ready
  - whether the branch belongs in Octon's autonomous lane or manual lane
- lane selection:
  - autonomous lane when the draft PR is completion-ready and the work is not
    `exp/*`, not a high-impact governance or control-plane change, and not a
    major or unknown Dependabot transition
  - manual lane for `exp/*`, high-impact governance or control-plane changes,
    and major or unknown Dependabot transitions
- suppress closeout prompting when:
  - implementation is still underway
  - required checks are red
  - author action items remain
  - a ready PR is waiting on reviewer or maintainer confirmation
  - another blocker makes closeout misleading
- use the contextual prompt that matches the current state:
  - primary `main` worktree:
    - "This work is on the main worktree, and Octon does not open PRs from `main`. Should I branch it into a feature worktree and prepare a draft PR?"
  - branch worktree with no PR:
    - "This branch worktree looks ready for PR closeout. Should I stage, commit, push, and open a draft PR?"
  - branch worktree with a draft PR in the autonomous lane:
    - "This draft PR looks ready for Octon's autonomous merge lane. Should I mark it ready and request squash auto-merge?"
  - branch worktree with a draft PR in the manual lane:
    - "This draft PR looks ready for the manual lane. Should I mark it ready for human review and keep auto-merge off?"
- Ready PR states report status instead of asking another closeout question:
  - waiting on required checks or auto-merge
  - waiting on reviewer or maintainer confirmation
  - ready in the manual lane and waiting on human review or merge
- blocked or not-ready states:
  - do not ask a closeout question; report blockers or remaining work instead
- deprecated compatibility fallback:
  - `Are you ready to closeout this branch?`
  - use only for adapters that have not yet bound the structured gate
