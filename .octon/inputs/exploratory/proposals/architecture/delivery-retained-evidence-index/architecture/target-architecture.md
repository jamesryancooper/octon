# Target Architecture

Create a compact retained delivery evidence index for local terminal proof bundles.

## Target Behavior

- Index includes refs, digests, disclosure tier, route, outcome, validator results, and non-authority classification.
- Detailed local sink content remains private/local and is not promoted as authority.
- Index is retained under state/evidence/runs/** or the canonical delivery evidence root.

## Safety Properties

- Child authority is preserved.
- Parent summaries cannot satisfy child-owned evidence.
- Generated outputs remain derived-only and non-authoritative.
- Material side effects remain explicitly authorization-gated.
- PR fallback remains forbidden where branch-no-PR delivery is in scope.
