# Target Architecture

Resolve the repository-supported shell/runtime before lifecycle validator dispatch without weakening gates.

## Target Behavior

- Lifecycle validator dispatch resolves a supported Bash runtime before running assurance scripts.
- Gate failures still fail closed and are not masked by runtime selection.
- Runtime resolver behavior is covered by positive and negative fixtures.

## Safety Properties

- Child authority is preserved.
- Parent summaries cannot satisfy child-owned evidence.
- Generated outputs remain derived-only and non-authoritative.
- Material side effects remain explicitly authorization-gated.
- PR fallback remains forbidden where branch-no-PR delivery is in scope.
