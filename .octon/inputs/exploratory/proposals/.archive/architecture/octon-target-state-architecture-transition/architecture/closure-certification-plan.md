# Closure Certification Plan

## Closure artifact

Create retained evidence under:

`/.octon/state/evidence/validation/architecture-target-state-transition/closure-certification.yml`

The closure artifact must include:

- promoted commit or branch identifier;
- validator suite results;
- obligation ID uniqueness proof;
- authorization coverage report;
- generated/effective publication freshness receipts;
- support proof bundle validation;
- compatibility retirement report;
- active-doc hygiene report;
- ADR reference;
- statement that durable targets have no proposal-path dependency.

## Certification status values

- `blocked`: one or more hard gates failed.
- `stage-only`: durable work exists but proof closure is incomplete.
- `qualified`: all gates pass and support claims remain within admitted envelope.
- `implemented`: durable targets promoted and proposal ready for archive.

## Required signoff classes

- constitutional authority alignment;
- runtime authorization coverage;
- evidence/proof completeness;
- support-target sufficiency;
- compatibility retirement;
- active-doc hygiene.

## Archive gate

This proposal may move to archive only after:

1. durable targets exist outside `inputs/exploratory/proposals/**`;
2. retained promotion evidence exists;
3. proposal-path dependency scan passes;
4. generated proposal registry is rebuilt;
5. archive metadata is added to `proposal.yml` according to the proposal standard.
