# Implementation Scope and Non-Goals

## Scope

This packet implements **deterministic Context Pack Builder v1** as a governed runtime capability. The implementation target includes only the surfaces necessary to make context assembly:
- constitutional-contract aligned
- deterministic enough to replay
- evidence-backed
- authorization-bound
- support-target-safe
- validator-enforced

## In scope

1. Strengthen the existing `context-pack-v1` constitutional contract additively.
2. Add a runtime builder specification that defines deterministic assembly behavior.
3. Add a context-pack receipt schema and canonical retained evidence path.
4. Bind context-pack receipts and model-visible hashes into run evidence, instruction-layer evidence, grant/receipt evidence, and runtime events.
5. Add a repo-local context packing policy for trust, freshness, QoS, and omission rules.
6. Add validators, tests, and CI gating.
7. Keep support-target scope unchanged while strengthening required proof.

## Not in scope

- redesigning Run Journal
- redesigning Authorized Effect Tokens
- redesigning Mission authority
- introducing a memory subsystem
- broadening support-target admission to new hosts, tools, or adapters
- introducing a second context or policy plane
- replacing the instruction-layer manifest
- treating generated summaries as runtime truth
- introducing browser/API context ingestion beyond current support rules

## Boundary rule

The packet may refine constitutional runtime contracts, engine runtime specs, repo-local governance policy, and assurance validators. It may not create any new source of runtime authority outside `framework/**` and `instance/**`, and it may not make `generated/**` or proposal-local surfaces authoritative.
