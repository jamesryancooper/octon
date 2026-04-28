# Validation Plan

## Validation command families

- Schema validation for all new v5 schemas.
- Proposal packet validation using existing proposal standards.
- Root placement validation for new target families.
- Negative-control validation for non-authority sources.
- Promotion dry-run validation.
- Recertification dry-run validation.
- Evidence completeness validation.
- Generated/effective no-widening and no-authority validation.

## Required tests

1. Evolution Candidate without evidence refs fails.
2. Candidate with constitutional impact and no amendment request fails.
3. Candidate compiles to proposal packet but does not promote.
4. Proposal with missing accepted decision cannot promote.
5. Promotion attempting to write outside declared targets fails.
6. Promotion leaving proposal-path dependencies in durable outputs fails.
7. Promotion without retained evidence fails.
8. Recertification missing after promotion blocks closure.
9. Generated summary cannot become ADR or policy.
10. Evidence distillation output cannot auto-promote.
