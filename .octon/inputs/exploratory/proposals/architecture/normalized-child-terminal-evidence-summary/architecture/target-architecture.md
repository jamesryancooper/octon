# Target Architecture

Add or compute a normalized terminal evidence summary for child packets and archived children.

## Target Behavior

- Archived implemented children can satisfy terminal readiness through archive metadata, child closeout, conformance, drift, validation, and retained evidence indexes.
- Active non-archived implemented children still require strict implementation-run fields before terminal handling.
- Parent summaries never replace child-owned receipts.

## Safety Properties

- Child authority is preserved.
- Parent summaries cannot satisfy child-owned evidence.
- Generated outputs remain derived-only and non-authoritative.
- Material side effects remain explicitly authorization-gated.
- PR fallback remains forbidden where branch-no-PR delivery is in scope.
