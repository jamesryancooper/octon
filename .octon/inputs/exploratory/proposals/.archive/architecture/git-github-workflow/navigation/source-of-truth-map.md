# Source of Truth Map

## Canonical durable authority hierarchy used by this packet

| Layer | Role | Current source(s) | Why it matters here |
|---|---|---|---|
| Constitutional kernel | Supreme repo-local control regime | `/.octon/framework/constitution/**` | Prevents the workflow rewrite from minting a new control plane or treating host projections as authority |
| Workspace charter pair | Active repo objective and live execution posture | `/.octon/instance/charter/workspace.md`, `workspace.yml` | Confirms `pre-1.0`, `atomic`, and repo-local workflow hardening as in scope |
| Ingress contract | Canonical execution ingress and closeout gate contract | `/.octon/instance/ingress/manifest.yml`, `/.octon/instance/ingress/AGENTS.md` | Holds the current static `branch_closeout_prompt` that this packet replaces with a contextual gate |
| Commit and PR practice docs | Human-readable workflow rules | `/.octon/framework/agency/practices/commits.md`, `pull-request-standards.md`, `git-autonomy-playbook.md`, `git-github-autonomy-workflow-v1.md` | These are the main durable practice surfaces that currently drift from one another |
| Machine-enforced workflow contracts | Branch, commit, and merge-critical requirements | `/.octon/framework/agency/practices/standards/commit-pr-standards.json`, `github-control-plane-contract.json` | Define the current trunk contract, required checks, and review-thread-resolution rule |
| Local helper scripts | Repo-local operator projections | `/.octon/framework/agency/_ops/scripts/git/git-wt-new.sh`, `git-pr-open.sh`, `git-pr-ship.sh`, `git-pr-cleanup.sh` | Already encode most of the right operating model, but some semantics are underexplained or too eager |
| Review-remediation skill | Agent behavior contract for PR comments | `/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/SKILL.md` | Establishes the safer `fix + reply, do not self-resolve reviewer threads` posture |
| GitHub workflow layer | Host-enforced workflow projections | `.github/workflows/main-pr-first-guard.yml`, `pr-triage.yml`, `pr-autonomy-policy.yml`, `pr-auto-merge.yml`, `pr-quality.yml` | Confirms what GitHub currently enforces versus what docs merely imply |
| Companion repo-local alignment surface | PR-body structure and review checklist wording | `.github/PULL_REQUEST_TEMPLATE.md` | Must stay aligned with the Octon-internal workflow model, but is outside this packet's manifest promotion scope |

## Proposal-local authority and lineage used by this packet

| Surface | Role |
|---|---|
| `proposal.yml` | Lifecycle and promotion manifest for this packet |
| `architecture-proposal.yml` | Architecture subtype contract |
| `git-github-workflow.md` | Source exploratory memo distilled into this packet |
| `/.octon/inputs/exploratory/proposals/.archive/design/git-github-workflow/` | Historical lineage only; not current authority |

## Boundary rules for this packet

- Promotion targets remain under `/.octon/**` only, because active proposals
  may not mix `.octon/**` and non-`.octon/**` targets.
- Repo-local surfaces outside `/.octon/**` may still appear in the packet as
  required companion alignment surfaces.
- Labels, comments, and bot summaries remain non-authoritative projections.
- This packet does not widen GitHub's role into repo-local constitutional
  authority; GitHub remains the host merge gate beneath Octon's own governing
  surfaces.
- This packet does not require Codex App. Any worktree-capable Git environment
  that can identify a primary `main` worktree or clone and branch worktrees is
  in scope.
