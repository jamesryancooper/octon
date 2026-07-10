# File Change Map

All durable changes land inside the registry-declared write scopes for this
child. No file outside these scopes is created or modified.

## New Files (durable, promoted at implementation)

| Path | Kind | Write scope |
| --- | --- | --- |
| `.octon/framework/cognition/practices/methodology/architectural-review/architecture-lens-bank.md` | Authored lens doctrine | methodology/architectural-review |
| `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml` | Machine-readable lens/profile registry | methodology/architectural-review |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lens-references.sh` | New validator | _ops/scripts |
| Lens-reference validator fixtures (passing + two negative controls) | Test fixtures | assurance test fixture tree |

## Files Explicitly NOT Changed

| Path | Why untouched |
| --- | --- |
| `.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md` | Balanced doctrine is cross-referenced, not edited (AC-4) |
| `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml` | v2 methods-list refactor is the phase-1 child's scope |
| `.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml` | `method_selection` semantics are phase-1 scope |
| `.octon/framework/cognition/practices/methodology/architectural-review/README.md` | Canonical-names table update is phase-1 scope |
| `.octon/framework/constitution/contracts/assurance/architectural-review-*.schema.json` | Schema v2 additions are phase-2 scope |
| Review workflow contracts under `orchestration/runtime/workflows/audit/**` | Method-recording is phase-3 integration scope |
| Architecture-readiness / surface-architecture audit doctrine | Out of scope; composed with, never modified |

## Generated Surfaces

No generated/effective output is hand-edited. If a generated methodology index
references the new files, it is refreshed only through the canonical publication
script at implementation, never by this child writing generated paths directly.
