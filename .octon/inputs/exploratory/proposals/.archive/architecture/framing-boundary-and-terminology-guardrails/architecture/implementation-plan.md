# Implementation Plan

_Status: Draft child implementation plan_

This plan is proposal-local. It does not authorize durable implementation.

## Dependencies

- `foundational-entry-artifact-canonical-framing-update`

## Steps

1. Inventory current canonical naming and glossary usage for agent-first and workflow-first terms.
2. Define canonical wording, compatibility wording, prohibited wording, and proof-before-claim rules.
3. Add or update terminology validation so unsupported future-state phrases fail closed in canonical surfaces.
4. Retain review evidence proving entry artifacts do not claim live runtime support prematurely.

## Promotion Targets

- `.octon/framework/cognition/_meta/terminology/naming-constitution.md`
- `.octon/framework/cognition/_meta/terminology/glossary.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/README.md`
- `.octon/AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`

## Validation

- Terminology scan proving canonical surfaces avoid unsupported future-state claims.
- Naming-constitution and glossary consistency review.
- Generated/input non-authority scan for proposal-local and generated references.

## Evidence Required Before Canonical Claim

- Terminology audit and diff evidence.
- Validator output for forbidden future-state claims.
- Promotion receipt for any durable wording changes.

## Cutover Boundary

This child may not claim live runtime behavior until implementation-conformance and post-implementation drift/churn receipts prove durable promoted changes. Final canonical Governed Workflow Runtime terminology remains gated by `migration-cutover-compatibility-retirement`.
