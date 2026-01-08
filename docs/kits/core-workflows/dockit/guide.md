# Dockit — Documentation Pipeline

- **Purpose:** Creates and improves Markdown docs via grounded rewrites and validations, adding a governed documentation pipeline aligned with Harmony.
- **Responsibilities:** normalizing style/structure, grounding with citations, fixing links/TOC/front matter, generating diffs/changelogs, validating against style/lint profiles.
-- **Harmony alignment:** advances consistent contracts and interoperability; wires governance hooks so doc outputs are cited, reviewable, and policy‑gated.
- **Integrates with:** QueryKit (grounding facts), PromptKit (templates), PlanKit/AgentKit (plans + runs), PatchKit (PRs), PolicyKit/EvalKit/ComplianceKit (gates).
- **I/O:** reads `docs/**` and style/lint profiles; emits `docs_out/**` with rewritten Markdown, diffs, and changelog.
- **Wins:** Cited, consistent docs; faster reviews through small, predictable diffs.
- **Implementation Choices (opinionated):**
  - markdown-it-py: structured AST for safe heading/link/TOC transforms.
  - python-frontmatter: reliable YAML front matter read/write.
  - mdformat: consistent Markdown formatting after AI edits.
- **Common Qs:**
  - *Meaning changes?* No—preserves meaning unless requested.
  - *Code blocks?* Can update; pair with EvalKit/PolicyKit gates.
  - *Templates live where?* PromptKit.
  - *How do changes ship?* PatchKit opens PRs; gates apply.

## Minimal Interfaces (copy/paste scaffolds)

### Dockit (improve docs)

```json
{
  "paths": ["docs/**"],
  "style_profile": "prompts/style/default.yml",
  "lint_profile": "prompts/lint/markdown.yml",
  "grounding": {"provider": "querykit", "min_citations": 2}
}
```