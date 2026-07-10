# File Change Map

Exact, exhaustive per-file change map. All paths are under the child's
registry-declared write scope
`.octon/framework/cognition/practices/methodology/architectural-review/`. Nothing
outside this directory is written.

## New Files (4) — Promotion Targets

| Path | Action | Assumption (current) | Required change | Priority | Rationale |
| --- | --- | --- | --- | --- | --- |
| `architectural-review/tradeoff-review-method.md` | create | absent; slug + lens profile exist in registries | author Tradeoff method doc (shared shape; required lenses `quality-attribute-scenarios`, `tradeoff-adr`) | P1 | method named + profiled but undocumented |
| `architectural-review/failure-mode-review-method.md` | create | absent | author Failure-Mode method doc + readiness-audit boundary statement | P1 | undocumented; overlaps readiness vocabulary and must draw the line |
| `architectural-review/evolution-fitness-review-method.md` | create | absent | author Evolution/Fitness method doc (required lenses incl. `evolution-fitness`, `contracts-compatibility`) | P1 | undocumented |
| `architectural-review/boundary-authority-review-method.md` | create | absent | author Boundary/Authority method doc + surface-audit boundary statement + Octon-only v1 note | P1 | undocumented; overlaps surface-audit classification |

## Modified Files (2) — Additive, In-Place Durable Authorities

| Path | Action | Current assumption | Required change | Priority | Rationale |
| --- | --- | --- | --- | --- | --- |
| `architectural-review/naming.yml` | edit (additive) | 4 companion `methods.catalog` entries have `display_name`, `slug`, `role`, `lens_profile_ref` but no `doc:` | add `doc: <slug>.md` to each of the 4 companion entries; nothing else changes | P1 | make the new docs discoverable from the catalog, mirroring Greenfield |
| `architectural-review/README.md` | edit (additive) | References section links Balanced + Greenfield | append 4 links (one per new doc) to the References list | P2 | discoverability parity in the mechanism index |

### Exact `naming.yml` edit shape

Add one line to each companion catalog entry, e.g. for Tradeoff:

```yaml
    - display_name: "Architecture Tradeoff Review"
      slug: "tradeoff-review-method"
      role: "companion"
      doc: "tradeoff-review-method.md"          # <-- added
      lens_profile_ref: "lens-bank.yml#method_profiles.tradeoff-review-method"
```

Repeat for `failure-mode-review-method`, `evolution-fitness-review-method`, and
`boundary-authority-review-method` with their matching `<slug>.md` filenames. No
slug, `role`, `default`, `lens_profile_ref`, `canonical_modes`, `schema_names`,
`validator_names`, or `legacy_aliases` change.

### Exact `README.md` edit shape

Append to the References section:

```markdown
- [Architecture Tradeoff Review Method](./tradeoff-review-method.md)
- [Failure-Mode Architecture Review Method](./failure-mode-review-method.md)
- [Evolution/Fitness Architecture Review Method](./evolution-fitness-review-method.md)
- [Boundary/Authority Architecture Review Method](./boundary-authority-review-method.md)
```

## Not Changed (Guardrails)

- `naming.yml` method slugs, `methods.default`, `role` values, `lens_profile_ref`
  values, `canonical_modes`, schema/validator names, legacy aliases.
- `lens-bank.yml`, `architecture-lens-bank.md`, `review-routing.yml`,
  `balanced-architecture-review-method.md`,
  `greenfield-reference-architecture-review-method.md`.
- Any file outside `architectural-review/`, including the readiness and
  surface-audit doctrine, all schemas under `constitution/contracts/assurance/`,
  all validators under `assurance/runtime/_ops/scripts/`, all workflows, feature
  notes, and generated projections.

## Generated / Derived

- No generated projection is written by this child. The proposal registry
  projection (`.octon/generated/proposals/registry.yml`) is refreshed only through
  the canonical generator in a coordinated pass; this packet's validation uses the
  registry-skip mode because unrelated visible packets are present.

## Downstream Reference Boundary

- `architectural-review-suite-integration` (phase-3) consumes the authored method
  ids when recording method selection in review evidence and advisory lifecycle
  text. That wiring is out of scope here; this child only authors the docs and
  their in-directory discoverability pointers.
