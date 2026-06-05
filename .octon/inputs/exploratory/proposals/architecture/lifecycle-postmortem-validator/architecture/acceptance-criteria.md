# Acceptance Criteria

- Validator script exists and has clear usage.
- Test harness exercises positive and negative fixtures.
- Fixture coverage includes generated-authority, raw-input-authority,
  unresolved-ref, invalid-final-judgment, missing-section, and missing-Octon
  invariant cases.
- Fixture coverage includes Unknown-as-Pass, missing invariant evidence gap,
  and missing blocking correction for material invariant failures.
- Fixture coverage includes missing invariant validity/evolution review,
  invalid recommendation category, missing required change, weak
  change-control bar, and invariant-change-approved cases.
- Functional suite registration points to the validator and fixtures.
- Instance assurance registration points to the validator, test harness, and
  retained validation evidence root.
- Validator can be run directly by humans and from the meta workflow.
- Validator reports actionable diagnostics without authorizing any lifecycle
  action.
