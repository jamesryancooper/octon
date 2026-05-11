# Acceptance Criteria

_Status: Draft acceptance criteria_

The proposal is acceptable for implementation only when the correction scope and
tests are explicit enough to prevent both false success and false failure.

## Required Outcomes

- `octon lifecycle plan --lifecycle proposal-program --target <parent-program>`
  can produce a valid plan for a structurally valid proposal program when the
  effective catalog has unrelated packs with `lifecycle_contracts: []`.
- A pack with a non-empty lifecycle contract declaration but no
  `lifecycle-contract` capability profile still fails closed.
- A missing lifecycle contract projection still fails closed.
- Proposal standard validation no longer depends on accidental resolution to a
  Bash version that cannot run the registry generator, or it fails with a clear
  preflight message before misleading packet errors.
- `generate-proposal-registry.sh --check` continues to detect real registry
  drift.
- Fallback/manual lifecycle creation has a declared retained-evidence surface and
  cannot be confused with completed Lifecycle Autopilot route execution.
- Product documentation and support claims match the implemented and validated
  route behavior.

## Non-Acceptance Conditions

- The fix treats generated effective catalog files as authored authority.
- The fix widens support for Durable Objects, MCP, external workflow engines,
  workflow statecharts, task-specific harness schemas, agent-node contracts, or
  workflow replay.
- The fix weakens fail-closed behavior for real lifecycle-contract declaration
  errors.
- The fix leaves registry synchronization validation dependent on an unsupported
  shell without an actionable diagnostic.
