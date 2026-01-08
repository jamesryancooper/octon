# CodeModKit — Guided Refactors & Migrations (AST)

- **Purpose:** Tree-safe codemods with previews.
- **Responsibilities:** language-specific transforms, codemod packs, dry-runs.
- **Integrates with:** DevKit (edge fixes), EvalKit (quality), PatchKit (PRs), StackKit (policy).
- **I/O:** diffs, migration reports.
- **Wins:** Confident large changes.
- **Common Qs:** *Multi-lang?* Yes—adapters per language.

## Minimal Interfaces (copy/paste scaffolds)

### CodeModKit (apply codemods)

```json
{
  "language": "ts",
  "codemods": ["codemods/retry-policy.ts"],
  "preview": true
}
```