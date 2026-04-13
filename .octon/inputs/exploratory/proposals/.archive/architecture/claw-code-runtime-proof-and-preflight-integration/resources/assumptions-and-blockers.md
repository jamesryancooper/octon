# Assumptions and Blockers

## Packet-time assumptions

1. The live repo remains on `main` with the currently observed super-root and constitutional layout.
2. The enabled overlay points listed in `instance/manifest.yml` remain unchanged during implementation.
3. Workflow discovery continues to depend on `framework/orchestration/runtime/workflows/manifest.yml` and `registry.yml`.
4. Generated operator summaries remain a legal derived family under `generated/cognition/summaries/operators/**`.
5. No active packet already claims to implement the selected concept set end-to-end.

## Packet-time findings that reduce uncertainty

- The repo already has lab scenario roots and scenario packs.
- The repo already has a repo-shell adapter contract.
- The repo already has observability governance surfaces.
- The repo already has task workflows and a canonical onboarding workflow.
- The active architecture packet is adjacent, not directly duplicative.

## Current blockers

No hard blockers were found that force `defer` or `reject` for the selected concept set.

## Watch items

- If implementation discovers that workflow composition cannot express doctor/preflight prerequisites cleanly, use the packet’s minimal fallback paths without dropping receipt requirements.
- If assurance suite conventions differ from the assumed `functional/suites/*.yml` pattern, adjust within the assurance subsystem rather than inventing a new validation domain.
- If the active packet begins to absorb this exact concept scope before implementation starts, re-run the sibling-packet necessity check.
