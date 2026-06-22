# Target Architecture

Add safe targeted freshness checks for one proposal plus dependency refs while retaining full registry as final gate.

## Target Behavior

- Targeted mode validates one proposal, its generated artifact bundle, declared child/dependency refs, and cited evidence indexes.
- Generated outputs remain derived-only and are refreshed only by canonical generators.
- Full registry check remains required for final publication/delivery gates.

## Safety Properties

- Child authority is preserved.
- Parent summaries cannot satisfy child-owned evidence.
- Generated outputs remain derived-only and non-authoritative.
- Material side effects remain explicitly authorization-gated.
- PR fallback remains forbidden where branch-no-PR delivery is in scope.
