# Assumptions and blockers

## Assumptions

- The live public GitHub repository inspected during this run is the authoritative current baseline.
- The full extracted concept set from the prior extraction run is in scope because no narrower selected subset was provided.
- Existing enabled overlay points remain available for repo-specific governance/runtime refinements.
- Existing evidence/disclosure/run-control surfaces remain the preferred anchors for any promoted changes.

## Blockers

### 1. Packet convention drift
The live repo’s active architecture packet uses a numbered-Markdown convention, not the manifest-governed convention requested here. This does not block architectural analysis, but it does block any claim that this packet shape is already repo-native.

### 2. Uninspected migration workflow content
`/.octon/octon.yml` references a `migrate-harness` workflow path, but this packet did not independently inspect its README or implementation. That blocks any stronger claim about exact migration mechanics.

### 3. Absence claims are bounded
This packet uses inspected live surfaces to judge coverage. If maintainers have unpublished/local-only supporting automation not committed to the repo, those mechanisms were necessarily out of scope for evidence.

## Non-blockers

- The absence of any `adopt` disposition is not a blocker; it is a consequence of the repo already carrying strong first-class equivalents.
- The presence of deferred/rejected concepts does not block packet closure provided they remain explicit.
