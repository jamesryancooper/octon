# Current-State Gap Map

Verified against the live mechanism at
`.octon/framework/cognition/practices/methodology/architectural-review/` and the
validator directory `.octon/framework/assurance/runtime/_ops/scripts/`.

## Current State

| Surface | Today | Source of truth |
| --- | --- | --- |
| Mechanism directory | Four files: `README.md`, `balanced-architecture-review-method.md`, `naming.yml`, `review-routing.yml` | Live repo |
| Lens catalog | None. Balanced encodes its analysis steps inline as an 11-step Required Sequence and an Output Contract | `balanced-architecture-review-method.md` |
| Machine-readable lens contract | None | — |
| Method model | Single method (`architectural-review-naming-v1`, Balanced only) | `naming.yml` |
| Lens-reference validator | None | `.octon/framework/assurance/runtime/_ops/scripts/` |

## Gap → Target Traceability

| # | Source claim / gap (lens-bank-design.md) | Live gap | Target artifact / action | Acceptance ref |
| --- | --- | --- | --- | --- |
| G1 | Suite needs one shared lens bank; methods select lenses | No lens catalog exists | Author `architecture-lens-bank.md` with the 18-lens catalog, two tiers | AC-1 |
| G2 | Lens profiles are a validated cross-reference surface; prose-only would drift | No machine-readable catalog | Author `lens-bank.yml` with `lenses[]` + `method_profiles` | AC-2 |
| G3 | Validator must fail on undefined lens id or missing method profile | No validator | Author `validate-architectural-review-lens-references.sh` + fixtures with two negative controls | AC-3 |
| G4 | Balanced's required set = its existing required sequence expressed as lens ids, no doctrine change | Balanced steps are inline prose, not lens ids | Author the sequence→lens-id appendix; do not edit the Balanced doc | AC-4 |
| G5 | Six per-method profiles (Balanced + five companions) | No profiles | Encode all six profiles per the source R/O/— table | AC-2 |
| G6 | Sprawl controls are authored doctrine | Absent | Author the four sprawl-control rules in the lens bank doc | AC-5 |
| G7 | Clean-sheet is a lens, Greenfield is a method | Not stated in the mechanism | Author the complementarity statement | AC-1 |

## Re-Grounding Divergences

- The five companion **method slugs** are not yet defined in the live
  `naming.yml` (still v1, Balanced-only). The profiles in `lens-bank.yml` use
  provisional slugs; canonical slugs are fixed by the phase-1 child. The
  validator must therefore check lens-id integrity and profile completeness
  without hard-coupling to companion method slugs that only exist post-phase-1.
  This is recorded as a phase-1 dependency-input obligation, not a blocker for
  this child.
- No other divergence between `lens-bank-design.md` and the live mechanism was
  found; the design's Balanced `R` column matches Balanced's existing required
  sequence.
