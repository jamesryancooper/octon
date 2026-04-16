# ADR Update Bundle Contract

This bundle drafts a non-authoritative ADR update from a diff plus retained
evidence.

## Required Outcome

- resolve one ADR target or stop
- summarize the material decision delta
- produce either:
  - inline draft markdown, or
  - a patch suggestion against an explicit ADR target path, or
  - scratch markdown under the generic skill roots

## Additional Guardrails

- never auto-edit `decisions/index.yml`
- never auto-create or rewrite decision evidence bundles
- stop when the change is operational only and does not support an ADR-level
  update
