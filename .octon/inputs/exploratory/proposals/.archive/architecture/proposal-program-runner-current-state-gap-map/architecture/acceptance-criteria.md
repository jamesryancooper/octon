# Acceptance Criteria

- A retained gap map inventories existing authored contracts, generated effective projections, runtime controller behavior, executor adapter support, route prompts, workflow routes, validators, hygiene tooling, publication tooling, registry tooling, evidence tiers, run lifecycle controls, and tests.
- Every identified behavior is classified as existing-and-preserve, existing-but-test-gap, implementation-gap, contract-gap, validator-gap, route-prompt-gap, or out-of-scope with rationale.
- No implementation change proceeds until the audit proves the smallest owned surface for each gap and rejects duplicate runner-local behavior.

## Negative Criteria

- Do not implement runner changes inside this audit packet.
- Do not treat generated projections, proposal packets, or chat history as authority.
- Do not rewrite behavior already owned by lifecycle routes, validators, workflows, publication scripts, registry scripts, or run lifecycle machinery.

## Terminal Criteria

- Child implementation evidence exists only after a later
  `run-packet-implementation` route.
- Child promotion is workflow-owned by `promote-proposal` and cannot be claimed
  by parent program evidence.
- Child closeout and archive remain child-owned and route-gated.
