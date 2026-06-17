# Source Context

This packet is grounded in the clean-break delegated lifecycle automation
migration completed immediately before creation of this proposal.

Key source observations:

- Proposal packet and proposal-program lifecycle routes now use
  `delegation_contract` instead of route approval defaults.
- Lifecycle dispatch now writes retained authorization proof before route
  execution.
- Routine promotion, closeout, archive, child dispatch, retry, repair, replay,
  recovery, projection refresh, and cleanup are machine-delegable when proof
  passes.
- Human approval remains only for typed non-machine-provable boundaries such as
  scope expansion, policy override, unresolved risk acceptance, governance
  mutation, contradictory evidence resolution, stale evidence acceptance,
  authority ambiguity, unsafe resume, and external irreversible effect.
- Generated outputs and proposal-local receipts may satisfy evidence gates but
  never grant authority.

Repo-grounding sweeps found broader approval-centered surfaces outside
lifecycle, including authority engine approval artifacts, mission/runtime
`approval_required` posture, run-health read-model vocabulary, connector
posture, workflow/capability classification, and governance docs. This packet
does not assume those surfaces are wrong; it proposes evaluating and migrating
them where proof-gated delegation can preserve or improve governance.

Reference implementation surfaces:

- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/authorization.rs`
- `.octon/framework/engine/runtime/spec/lifecycle-route-execution-request-v1.schema.json`
- `.octon/framework/engine/runtime/spec/lifecycle-route-execution-result-v1.schema.json`
- `.octon/framework/engine/runtime/spec/lifecycle-program-controller-invariants.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`

Adjacent governance surfaces to evaluate later:

- `.octon/framework/constitution/contracts/authority/`
- `.octon/framework/constitution/contracts/runtime/`
- `.octon/framework/engine/runtime/crates/authority_engine/`
- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/orchestration/governance/`
- `.octon/framework/capabilities/governance/policy/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
