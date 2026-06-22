# Acceptance Criteria

- sequenced-gated is either migrated or explicitly aliased to a supported execution mode with no semantic loss.
- Registry execution_mode and manifest program_execution_mode no longer create contradictory planner signals.
- Dependency gates and phase ordering remain enforced.

## Safety Acceptance

- No parent evidence replaces child-owned evidence.
- No PR fallback is introduced.
- No protected retained evidence is deleted.
- No generated output is hand-edited.
