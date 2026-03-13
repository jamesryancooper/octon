# Doc - Documentation Operations Service

- **Purpose:** Execute docs-as-code operations for drafting, updating,
  normalizing, and validating documentation artifacts.
- **Responsibilities:**
  - Generate and update specs, ADRs, guides, runbooks, and contract docs.
  - Enforce structure and terminology consistency.
  - Validate links, headings, and contract references.
  - Produce review-ready documentation diffs.
- **Octon alignment:** Implements the `Documentation is Code` principle with
  auditable, policy-aligned doc updates.
- **Canonical inputs:**
  - `.octon/cognition/governance/principles/documentation-is-code.md`
  - `.octon/scaffolding/runtime/templates/documentation-standards.md`
  - `.octon/scaffolding/runtime/templates/docs/documentation-standards/`
- **Integrates with:**
  - Query (fact gathering)
  - Prompt (templated drafting)
  - Plan/Agent (execution)
  - Patch (delivery)
  - Quality gate skill/workflow (enforcement)
- **I/O:** Reads documentation source directories (for example `docs/**`) and
  writes updated docs in place or to review branches/patches.
- **Wins:**
  - Faster doc iteration with consistent structure
  - Better release readiness through explicit runbooks and contracts
  - Lower review overhead via predictable diffs

## Operational Usage

1. Start from canonical templates in
   `.octon/scaffolding/runtime/templates/docs/documentation-standards/`.
2. Draft or update documentation in the same change set as implementation.
3. Run documentation quality enforcement before release:
   `/audit-documentation-standards` or `/audit-documentation`.
4. Merge only when docs and behavior are aligned.

## Minimal Interfaces (Scaffolds)

### Draft or refresh docs

```json
{
  "paths": ["docs/**"],
  "template_root": ".octon/scaffolding/runtime/templates/docs/documentation-standards",
  "mode": "update",
  "validate_links": true
}
```

### Run standards audit

```json
{
  "docs_root": "docs",
  "policy_doc": ".octon/cognition/governance/principles/documentation-is-code.md",
  "template_root": ".octon/scaffolding/runtime/templates/docs/documentation-standards"
}
```
