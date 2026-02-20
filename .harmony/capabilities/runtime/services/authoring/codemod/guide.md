# CodeMod — Guided Refactors & Migrations (AST)

- **Purpose:** Tree-safe codemods with previews.
- **Responsibilities:** language-specific transforms, codemod packs, dry-runs.
- **Integrates with:** Dev (edge fixes), Eval (quality), Patch (PRs), Stack (policy).
- **I/O:** diffs, migration reports.
- **Wins:** Confident large changes.
- **Common Qs:** *Multi-lang?* Yes—adapters per language.

## Minimal Interfaces (copy/paste scaffolds)

### CodeMod (apply codemods)

```json
{
  "language": "ts",
  "codemods": ["codemods/retry-policy.ts"],
  "preview": true
}
```
