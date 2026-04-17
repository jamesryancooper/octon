# File Change Map

## Durable target artifacts

| Target artifact | Class | Existing/New | Why it is touched | Migration required? | Concept(s) served | Required for genuine usability? |
|---|---|---|---|---|---|---|
| `/.octon/instance/ingress/manifest.yml` | instance ingress authority | existing/edit | Replace the scalar closeout prompt with a contextual closeout gate contract | additive same-root | contextual gate | yes |
| `/.octon/instance/ingress/AGENTS.md` | ingress projection | existing/edit | Project the contextual gate and stop requiring the same question after every file-changing turn | additive same-root | contextual gate | yes |
| `/.octon/framework/agency/practices/git-autonomy-playbook.md` | agency practice doc | existing/edit | Generalize the workflow to any worktree-capable Git environment and rewrite closeout behavior | additive same-root | operator model; helper semantics | yes |
| `/.octon/framework/agency/practices/git-github-autonomy-workflow-v1.md` | workflow overview doc | existing/edit | Align durable overview with contextual closeout, manual/autonomous lanes, and worktree-native execution | additive same-root | operator model; merge lanes | yes |
| `/.octon/framework/agency/practices/pull-request-standards.md` | PR policy doc | existing/edit | Clarify reviewer-owned thread resolution and ready-state semantics | additive same-root | review remediation | yes |
| `/.octon/framework/agency/_ops/scripts/git/git-pr-ship.sh` | local helper projection | existing/edit | Clarify that the helper requests readiness or merge intent rather than proving readiness | additive same-root | helper semantics | maybe |
| `/.octon/framework/agency/_ops/scripts/git/git-pr-cleanup.sh` | local helper projection | existing/edit | Document or automate worktree-directory pruning after PR closure | additive same-root | housekeeping | maybe |
| `/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/SKILL.md` | skill contract | existing/edit | Align remediation behavior with reviewer-owned thread resolution and merge-block semantics | additive same-root | review remediation | yes |

## Companion alignment surfaces outside manifest promotion scope

These should be updated in the implementing branch, but they are not manifest
promotion targets because this proposal is `promotion_scope: octon-internal`.

| Companion surface | Existing/New | Why it still matters |
|---|---|---|
| `.github/PULL_REQUEST_TEMPLATE.md` | existing/edit | Must stop implying that authors should resolve reviewer-owned threads themselves |
| `AGENTS.md`, `/.octon/AGENTS.md`, `CLAUDE.md` | existing/verify-only | Adapter parity should be checked after ingress wording changes, but no new workflow logic should live here |

## Explicitly unchanged roots

- `/.octon/framework/agency/practices/standards/commit-pr-standards.json`
- `/.octon/framework/agency/practices/standards/github-control-plane-contract.json`
- `/.octon/framework/agency/_ops/scripts/git/git-wt-new.sh`
- `/.octon/framework/agency/_ops/scripts/git/git-pr-open.sh`
- `.github/workflows/pr-triage.yml`
- `.github/workflows/pr-auto-merge.yml`
- `.github/workflows/pr-quality.yml`

These remain unchanged because the packet is mainly about aligning ingress,
practice, review semantics, and helper-script meaning around an already-live
PR-first and worktree-first control plane.
