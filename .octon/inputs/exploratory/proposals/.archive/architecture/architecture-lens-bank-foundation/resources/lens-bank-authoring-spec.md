# Lens Bank Authoring Spec

The concrete content the implementation must author. This spec is proposal-local
lineage; the durable authority is the framework artifacts once promoted.

## Artifact 1 — `architecture-lens-bank.md` (lens doctrine)

Path:
`.octon/framework/cognition/practices/methodology/architectural-review/architecture-lens-bank.md`

Required sections:

1. **Purpose and scope** — one shared bank for the whole Architecture Review
   Method Suite; lenses are reusable analysis tools; methods own question,
   scope, routing, and output contract; lenses never own those. Cross-reference
   `balanced-architecture-review-method.md` as the default method.
2. **Lens catalog** — all 18 lenses in two tiers with, per lens: id, tier
   (core/extended), the question it asks, the evidence artifact it produces, and
   when it is worth applying. Content is fixed by
   `resources/source-context.md` §"Lens Catalog (18 lenses, two tiers)".
3. **Method lens profiles (human view)** — the R/O/— profile table for all six
   methods, mirroring `lens-bank.yml`. The doc and the YAML must agree; the YAML
   is the machine-checked contract.
4. **Clean-sheet vs Greenfield complementarity** — verbatim intent from the
   source: clean-sheet is an unconstrained comparison lens inside a broader
   review; Greenfield is a method whose output is reference architecture only.
5. **Sprawl controls** — the four authored rules: (1) new-lens admission
   requires a named decision/evidence/routing outcome; (2) no private lens
   catalogs; (3) the lens-reference validator fails closed on undefined lens id
   or missing profile; (4) lens retirement follows naming/retirement discipline
   (explicit legacy alias, no silent removal).

Non-goals stated in the doc: this bank creates no method, no routing, no gate,
no schema, and grants no review output authority.

## Artifact 2 — `lens-bank.yml` (machine-readable registry)

Path:
`.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml`

Shape (illustrative; final field names finalized at implementation against the
sibling `naming.yml`/`review-routing.yml` conventions):

```yaml
schema_version: "architectural-review-lens-bank-v1"
mechanism_family_slug: "architectural-review"
lens_tiers:
  - "core"
  - "extended"
lenses:
  - id: "system-job-framing"
    tier: "core"
  - id: "domain-model"
    tier: "core"
  - id: "current-reality-map"
    tier: "core"
  - id: "steelman-chestertons-fence"
    tier: "core"
  - id: "complexity-separation"
    tier: "core"
  - id: "clean-sheet-reference"
    tier: "core"
  - id: "quality-attribute-scenarios"
    tier: "core"
  - id: "tradeoff-adr"
    tier: "core"
  - id: "failure-and-recovery"
    tier: "core"
  - id: "authority-boundary"
    tier: "core"
  - id: "validation-strategy"
    tier: "core"
  - id: "non-goals-deletion"
    tier: "core"
  - id: "security-threat-model"
    tier: "extended"
  - id: "data-truth-lineage"
    tier: "extended"
  - id: "contracts-compatibility"
    tier: "extended"
  - id: "operability-observability-evidence"
    tier: "extended"
  - id: "evolution-fitness"
    tier: "extended"
  - id: "sequencing-mvp-migration"
    tier: "extended"
method_profiles:
  balanced-architecture-review-method:
    required:
      - "system-job-framing"
      - "current-reality-map"
      - "steelman-chestertons-fence"
      - "complexity-separation"
      - "clean-sheet-reference"
      - "tradeoff-adr"
      - "failure-and-recovery"
      - "authority-boundary"
      - "validation-strategy"
      - "non-goals-deletion"
    optional:
      - "domain-model"
      - "quality-attribute-scenarios"
      - "security-threat-model"
      - "data-truth-lineage"
      - "contracts-compatibility"
      - "operability-observability-evidence"
      - "evolution-fitness"
      - "sequencing-mvp-migration"
  greenfield-reference-architecture-review-method:
    required:
      - "system-job-framing"
      - "domain-model"
      - "clean-sheet-reference"
      - "quality-attribute-scenarios"
      - "failure-and-recovery"
      - "authority-boundary"
      - "validation-strategy"
      - "non-goals-deletion"
      - "security-threat-model"
      - "data-truth-lineage"
      - "contracts-compatibility"
      - "operability-observability-evidence"
      - "evolution-fitness"
      - "sequencing-mvp-migration"
    optional:
      - "current-reality-map"
      - "complexity-separation"
      - "tradeoff-adr"
  tradeoff-review-method:
    required:
      - "quality-attribute-scenarios"
      - "tradeoff-adr"
    optional:
      - "system-job-framing"
      - "domain-model"
      - "current-reality-map"
      - "steelman-chestertons-fence"
      - "complexity-separation"
      - "clean-sheet-reference"
      - "failure-and-recovery"
      - "authority-boundary"
      - "validation-strategy"
      - "non-goals-deletion"
      - "security-threat-model"
      - "data-truth-lineage"
      - "contracts-compatibility"
      - "operability-observability-evidence"
      - "evolution-fitness"
      - "sequencing-mvp-migration"
  failure-mode-review-method:
    required:
      - "current-reality-map"
      - "failure-and-recovery"
      - "authority-boundary"
      - "validation-strategy"
      - "security-threat-model"
      - "operability-observability-evidence"
    optional:
      - "system-job-framing"
      - "quality-attribute-scenarios"
      - "data-truth-lineage"
      - "contracts-compatibility"
  evolution-fitness-review-method:
    required:
      - "current-reality-map"
      - "validation-strategy"
      - "contracts-compatibility"
      - "operability-observability-evidence"
      - "evolution-fitness"
    optional:
      - "system-job-framing"
      - "domain-model"
      - "steelman-chestertons-fence"
      - "complexity-separation"
      - "quality-attribute-scenarios"
      - "failure-and-recovery"
      - "authority-boundary"
      - "non-goals-deletion"
      - "data-truth-lineage"
      - "sequencing-mvp-migration"
  boundary-authority-review-method:
    required:
      - "current-reality-map"
      - "authority-boundary"
    optional:
      - "system-job-framing"
      - "domain-model"
      - "steelman-chestertons-fence"
      - "failure-and-recovery"
      - "validation-strategy"
      - "non-goals-deletion"
      - "security-threat-model"
      - "data-truth-lineage"
      - "contracts-compatibility"
```

Every `required`/`optional` entry above is transcribed directly from the
source profile table (R → required, O → optional, — → omitted). The method
slugs for the five companions are provisional; the phase-1
taxonomy-and-routing child owns the canonical method slugs in `naming.yml` v2.
Because this child is the seed and the slugs are not yet fixed, the validator
(below) checks profile↔lens-id integrity and MUST NOT hard-couple to method
slugs that only exist after phase-1; slug reconciliation is a phase-1
dependency-input obligation recorded in `architecture/implementation-plan.md`.

## Balanced Required Sequence Expressed As Lens Ids (no doctrine change)

The parent design fixes: "Balanced's required set is exactly its existing
required sequence expressed as lens ids." The live
`balanced-architecture-review-method.md` Required Sequence + Output Contract map
onto the ten Balanced-required lens ids as follows. This mapping is authored as
an appendix in `architecture-lens-bank.md`; the Balanced doc itself is not
edited.

| Balanced sequence / output element (live doc) | Lens id |
| --- | --- |
| Step 1: Frame review charter | method framing (charter precedes lens work; not a lens) |
| Step 2: Identify the fundamental job | `system-job-framing` |
| Step 3: Map current reality across all surfaces | `current-reality-map` |
| Steps 4–5: Steelman + Chesterton's Fence | `steelman-chestertons-fence` |
| Step 6: Separate essential vs accidental/other complexity | `complexity-separation` |
| Step 7: Stale/valid constraints, hidden contracts, bottlenecks, leverage | folded into `current-reality-map` + `complexity-separation` |
| Step 8: Build clean-sheet reference design | `clean-sheet-reference` |
| Step 9: Compare current state vs clean-sheet | method activity across `current-reality-map` + `clean-sheet-reference` |
| Step 10: Produce realistic target architecture | method output (not a single lens) |
| Step 11: Routing, authority boundaries, evidence, validators, rollback, revisit | `authority-boundary` + `validation-strategy` |
| Output: option comparison and recommendation | `tradeoff-adr` |
| Output: failure-mode and second-order-effect analysis | `failure-and-recovery` |
| Output: explicit non-goals / what to delete | `non-goals-deletion` |

Resulting Balanced required lens set (10): `system-job-framing`,
`current-reality-map`, `steelman-chestertons-fence`, `complexity-separation`,
`clean-sheet-reference`, `tradeoff-adr`, `failure-and-recovery`,
`authority-boundary`, `validation-strategy`, `non-goals-deletion`. This exactly
equals the Balanced `R` column of the source profile table, proving adoption is
cross-reference-only.

## Artifact 3 — `validate-architectural-review-lens-references.sh`

Path:
`.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lens-references.sh`

Fail-closed rules (both are negative controls in fixtures):

1. **Undefined lens id in a method reference.** If any method doc or method
   profile references a lens id not defined under `lenses[].id` in
   `lens-bank.yml`, the validator exits non-zero.
2. **Defined method missing a profile.** If a method known to the bank has no
   `method_profiles.<method>` entry (or an empty required set where the source
   mandates one), the validator exits non-zero.

Positive control: the shipped `lens-bank.yml` with all 18 lenses and complete
profiles passes. The validator follows the existing
`validate-architectural-review-*.sh` conventions (argument parsing, `[OK]`/
`[ERROR]` lines, `Validation summary: errors=N`, non-zero exit on error) so it
composes with the existing architectural-review validator suite.

## Fixtures

Retained under the assurance test tree (final path chosen at implementation to
match sibling fixtures):

- `pass/lens-bank.yml` + a method-reference sample that cites only defined lens
  ids and complete profiles → validator passes.
- `fail-undefined-lens/` → a method reference cites `nonexistent-lens` →
  validator fails.
- `fail-missing-profile/` → a `lens-bank.yml` omits a required method profile →
  validator fails.
