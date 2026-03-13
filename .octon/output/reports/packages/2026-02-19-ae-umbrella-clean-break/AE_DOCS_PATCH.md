# AE Docs Patch

## Objective

Update user-facing docs to explain:

- the new umbrella chain
- breaking change scope
- interpretation of umbrella rollups vs attribute-level scores

## Documentation Surfaces to Update

1. `.octon/assurance/CHARTER.md`
2. `.octon/assurance/README.md`
3. `.octon/assurance/DOCTRINE.md`
4. `.octon/README.md` (Assurance Engine section)
5. `.octon/assurance/standards/weights/weights.md`
6. `.octon/assurance/complete.md`
7. `.octon/assurance/session-exit.md`

## Required Messaging

Include this statement verbatim or equivalent:

`This release is a breaking change: the old priority chain has been removed; only Assurance > Productivity > Integration is supported.`

## Before/After Explanation Snippet

Before:

```text
Priority chain: Trust > Speed of development > Ease of use > Portability > Interoperability
```

After:

```text
Priority chain: Assurance > Productivity > Integration
```

Interpretation rule:

- Attribute scores remain primary inputs.
- Umbrella scores are rollups for governance and reporting.
- A high umbrella score does not mask low critical attribute scores.

## CHANGELOG Entry (Breaking Change)

Proposed changelog entry target:

- `weights.yml` `changelog` section (required)
- optional: add `.octon/assurance/CHANGELOG.md` if a standalone changelog is adopted

Snippet:

```markdown
## 2.0.0 - 2026-02-19

### Breaking
- Replaced priority chain with umbrella chain: Assurance > Productivity > Integration.
- Removed legacy chain semantics and compatibility handling.
- Updated AE outputs and gate reporting to umbrella terminology.

### Migration
- Update any consumers parsing `charter_outcome`/`charter_rank` to `umbrella`/`umbrella_rank`.
- Rebaseline golden scorecard fixtures.
```

## Release Note Snippet

```markdown
### Breaking: Assurance Engine Umbrella Chain

AE now prioritizes work with `Assurance > Productivity > Integration`.
Attribute-level scoring remains the source of truth; umbrella rollups are derived and used for tie-breaks/reporting.
No legacy chain compatibility is provided in this release.
```

## Downstream Migration Notes (`.octon/` Consumers)

1. Pull updated `.octon/assurance/` files and AE runtime crate changes.
2. Replace old chain identifiers in custom scripts, dashboards, and parsers.
3. Re-run scorecard generation and gate checks to refresh baselines.
4. Update any automation referencing QGE wording to AE wording.
5. Validate no old-chain strings remain:

```bash
rg -n "Trust > Speed of development > Ease of use > Portability > Interoperability|QGE|legacy QGE label" .octon .github
```

## Doc Acceptance Criteria

- [ ] Every user-facing assurance doc shows the new chain.
- [ ] Breaking change is explicit in at least one top-level read path.
- [ ] Rollup-vs-attribute interpretation guidance is present.
- [ ] Release notes and migration notes are ready for downstream adopters.
