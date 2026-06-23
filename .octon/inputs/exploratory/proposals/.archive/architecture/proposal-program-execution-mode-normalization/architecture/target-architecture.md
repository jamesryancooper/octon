# Target Architecture

Normalize or alias execution modes across program manifests, registries, contracts, validators, and planner code.

## Target Behavior

- sequenced-gated is either migrated or explicitly aliased to a supported execution mode with no semantic loss.
- Registry execution_mode and manifest program_execution_mode no longer create contradictory planner signals.
- Dependency gates and phase ordering remain enforced.

## Safety Properties

- Child authority is preserved.
- Parent summaries cannot satisfy child-owned evidence.
- Generated outputs remain derived-only and non-authoritative.
- Material side effects remain explicitly authorization-gated.
- PR fallback remains forbidden where branch-no-PR delivery is in scope.
