# Acceptance Criteria

- Lifecycle validator dispatch resolves a supported Bash runtime before running assurance scripts.
- Gate failures still fail closed and are not masked by runtime selection.
- Runtime resolver behavior is covered by positive and negative fixtures.

## Safety Acceptance

- No parent evidence replaces child-owned evidence.
- No PR fallback is introduced.
- No protected retained evidence is deleted.
- No generated output is hand-edited.
