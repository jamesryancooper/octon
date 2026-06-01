# Acceptance Criteria

- A retry after workflow failure does not reuse a canonical workflow run id.
- Existing workflow run resume is allowed only with replay-safe proof.
- Ambiguous existing run state fails closed with retained evidence.
- The final archive retry failure pattern is covered by tests.
