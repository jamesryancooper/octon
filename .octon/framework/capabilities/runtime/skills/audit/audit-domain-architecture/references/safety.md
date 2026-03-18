---
safety:
  mode: read-only
  allowed_writes:
    - "../../../output/reports/*"
    - "_ops/state/logs/*"
  forbidden:
    - "Editing files in the audited domain path"
    - "Treating governance artifacts as binding optimization targets"
    - "Presenting unverified assumptions as facts"
    - "Failing fast solely because the target domain is not yet created"
---

# Safety and Boundaries

## Non-Negotiables

- Read-only critique of the target domain.
- Governance/contracts are analyzable inputs, not mandatory constraints.
- Recommendations must optimize for external robustness, clarity, and maintainability.
- Prospective mode must mark inferred structure explicitly and avoid fabricated evidence.

## Failure Handling

1. If target path is missing but valid as a `.octon/<domain>` target, switch to prospective mode.
2. If required evidence cannot be collected, stop extending unsupported claims.
3. Mark the area as unknown.
4. Add a concrete follow-up question for evidence collection.
