# Target Architecture

Batch digest refresh after phase-stable mutations and provide deterministic stale-cause diagnostics.

## Target Behavior

- Review refresh can be deferred until an authorized phase reaches a stable digest boundary.
- Gates that need current review truth still fail closed on stale evidence.
- Diagnostics identify stale cause, last mutation class, and owning refresh route.

## Safety Properties

- Child authority is preserved.
- Parent summaries cannot satisfy child-owned evidence.
- Generated outputs remain derived-only and non-authoritative.
- Material side effects remain explicitly authorization-gated.
- PR fallback remains forbidden where branch-no-PR delivery is in scope.
