# Repository Grounding

Ground every draft against current repo state plus retained evidence.

## Priority Rules

- Live repo state outranks stale summaries.
- Retained evidence under `/.octon/state/evidence/**` outranks chat memory.
- Authored authority lives in `framework/**` and `instance/**` only.
- Raw `inputs/**` never becomes runtime or policy truth.
- Generated projections are derived-only and must never mint authority.

## Canonical Surfaces Relevant To This Pack

- ADR SSOT:
  `/.octon/instance/cognition/decisions/*.md`
- ADR discovery index:
  `/.octon/instance/cognition/decisions/index.yml`
- migration plans:
  `/.octon/instance/cognition/context/shared/migrations/<id>/plan.md`
- migration index:
  `/.octon/instance/cognition/context/shared/migrations/index.yml`
- rollback posture truth:
  `/.octon/state/control/execution/runs/<run-id>/rollback-posture.yml`
- retained control evidence:
  `/.octon/state/evidence/control/execution/**`
- retained publication receipts:
  `/.octon/state/evidence/validation/publication/**`

## Hard Stops

- Do not treat comments, summaries, labels, or generated views as authority.
- Do not recommend new governance or runtime surfaces from this pack.
- Do not convert a draft into canonical truth automatically.
