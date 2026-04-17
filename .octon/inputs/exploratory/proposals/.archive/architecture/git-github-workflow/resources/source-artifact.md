# Source Artifact

## Primary source memo

- `git-github-workflow.md`

This packet is a structured conversion of that exploratory memo. The memo is
retained in-place as packet-local source material rather than being treated as
durable authority.

## Historical lineage considered

- `/.octon/inputs/exploratory/proposals/.archive/design/git-github-workflow/`

That archived design package captures an earlier implementation phase of
Octon's Git and GitHub workflow. It remains useful provenance, but this packet
does not inherit its mixed-scope manifest structure.

## Carry-forward findings from the memo

The memo's findings that this packet preserves are:

1. `main` is PR-first and should remain the clean integration anchor.
2. Feature branch worktrees are the correct default implementation unit.
3. Draft PRs should open early and become ready later.
4. Review remediation should be `fix + commit + reply`.
5. Reviewer-owned thread resolution must be preserved.
6. A single static closeout prompt is too weak for the actual workflow.

## Packet-specific reframing

This packet intentionally generalizes one important section of the source memo:

- source memo framing:
  - "Codex App worktree operating model"
- packet framing:
  - "worktree-capable operator model"

That change is deliberate. The workflow should be portable to any operator
environment that can identify a clean `main` worktree or clone and create
linked branch worktrees.
