# Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Validator becomes schema-only | Misses authority drift | Include semantic negative controls for authority classifications. |
| Validator requires live run state for all tests | Brittle CI | Use fixtures for most behavior and optional live run checks for integration. |
| Diagnostics are vague | Hard to repair reports | Emit failing field, observed value, and rerun command. |
| Validator accepts missing evidence as pass | False confidence | Require known limits and confidence degradation when evidence is missing. |
| Validator accepts invariant changes as approved | Authority leak | Add negative controls for reports that treat evaluator recommendations as enacted invariant changes. |
