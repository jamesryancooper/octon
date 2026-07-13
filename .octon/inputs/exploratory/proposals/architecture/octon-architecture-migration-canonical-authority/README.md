# Canonical Authority and Exact Launch Guards

This temporary RP-01 architecture packet specifies the authority semantic
foundation for the migration program. It is not runtime authority, an
implementation authorization, a support claim, or a trust-root promotion.

## Purpose

Create one installed, candidate-immutable evaluator/policy/binary/config/receipt
interface with typed scope semantics and an exact one-shot guard immediately
before every admitted candidate launch. RP-01 defines semantics; RP-03 later
persists them and must consume the frozen versioned interface.

## Reading Order

1. `proposal.yml`
2. `resources/packet-contract.yml`
3. `architecture/target-architecture.md`
4. `architecture/current-state-gap-map.md`
5. `architecture/acceptance-criteria.md`
6. `architecture/implementation-plan.md`
7. `architecture/validation-plan.md`
8. `architecture/operator-disclosure.md`
9. `resources/traceability.yml`
10. `support/implementation-grade-completeness-review.md`

## Exit

The packet exits only through the canonical proposal lifecycle after its own
review, operator disposition, implementation authorization, proof, promotion,
conformance, and archive receipts. Parent evidence cannot replace child proof.
