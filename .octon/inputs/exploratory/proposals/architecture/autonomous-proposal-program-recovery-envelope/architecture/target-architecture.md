# Target Architecture

Add a bounded autonomous recovery envelope for low-risk governed routes until the next material side effect.

## Target Behavior

- Envelope can autonomously run low-risk routes such as generated refresh, review refresh, lifecycle-residue classification, evidence-index materialization, and diagnostics.
- Envelope stops before archive, push, landing, cleanup deletion, branch deletion, PR creation or merge, external publication, and cleaned claim.
- Every autonomous recovery action retains route evidence and reruns the failed gate plus surrounding gate set.

## Safety Properties

- Child authority is preserved.
- Parent summaries cannot satisfy child-owned evidence.
- Generated outputs remain derived-only and non-authoritative.
- Material side effects remain explicitly authorization-gated.
- PR fallback remains forbidden where branch-no-PR delivery is in scope.
