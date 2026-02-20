# Patch — PR & Changelog Bot

- **Purpose:** Open PRs with diffs, summaries, labels.
- **Responsibilities:** branch mgmt, PR descriptions, changelogs.
- **Integrates with:** Dev/Doc/CodeMod (diffs), Eval (risk), Notify (reviews).
- **I/O:** PR URLs, release notes.
- **Wins:** One-click ship with context.
- **Common Qs:** *Dry runs?* Yes—artifact-only mode.
- **Harmony default:** **Trunk-Based Development** with short-lived branches; open PRs against trunk with **Vercel Preview** links; status checks gate merges; rollbacks promote a known-good preview.

## Minimal Interfaces (copy/paste scaffolds)

### Patch (PR)

```json
{
  "branch": "chore/docs-refresh",
  "title": "docs: refresh API",
  "labels": ["docs","automated"],
  "dry_run": false
}
```
