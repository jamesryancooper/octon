# Phases

## Phase 1 - Route Bundle

- normalize diff, grounding, target-ref, and output-mode inputs
- resolve the requested `bundle`, defaulting to `change-receipt`
- stop on conflicting target refs, ambiguous diff inputs, or unsupported
  routing inputs

## Phase 2 - Prompt Alignment Preflight

- use the selected bundle manifest plus `prompts/shared/**` as the family
  prompt contract
- fail closed in `auto` or `always` mode when prompt freshness is stale
- permit explicit degraded execution only in `skip` mode

## Phase 3 - Build Draft

- execute the selected bundle's stages and companions
- materialize checkpoint artifacts according to the selected bundle manifest
- keep every output labeled `Draft / Non-Authoritative`

## Phase 4 - Validate Boundaries

- confirm the draft cites the diff basis and grounding evidence
- confirm the selected output mode obeys the patch-target and scratch-surface
  rules
- retain a run log and any residual blockers
