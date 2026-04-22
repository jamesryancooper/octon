# Decision Record Plan

## Required ADRs or decision records

Add durable decision records under `/.octon/instance/cognition/decisions/**` for:

1. Adoption of 10/10 target-state architecture hardening.
2. Preservation of five-class super-root model.
3. Adoption of architecture health contract.
4. Support admission/dossier partitioning by claim state.
5. Publication freshness gates for generated/effective runtime outputs.
6. Pack/extension lifecycle normalization.
7. Operator boot/closeout separation.
8. Compatibility shim retirement policy update.

## Decision record requirements

Each record should include:

- decision id;
- title;
- status;
- durable target paths;
- rationale;
- alternatives rejected;
- rollback posture;
- validation requirements;
- evidence refs;
- successor/retirement notes where applicable.

## Non-authority rule

This proposal can recommend decision records but cannot serve as a decision
record after promotion. Durable decisions must stand alone.
