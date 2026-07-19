# Validation Plan

All implementation validation below is future work. Draft structural checks
prove packet form only; they cannot satisfy FD-022, UE-013, encode and prove the
accepted ROD-005 baseline, the ED-001 dependency premise, or the child component
of FD-023.

## Layer 0 — Lifecycle, Dependencies, and Ownership

- Run proposal-standard, architecture, implementation-readiness, and review
  gates at one stable packet digest.
- Verify the exact selected design receipt and accepted RP-02/RP-08/RP-11
  packet digests.
- Verify their implemented interfaces and current shared-symbol and writer
  ownership before RP-13 source edits.
- Retain ED-001, UE-013, and provider-dynamic proof as Layers 3 through 7 gates
  for implementation completion, use, or promotion.
- Compare all 44 targets and shared symbols against parent ownership.

Required result: accepted lifecycle gates, source-entry readiness, and no
authority/store/recovery, generic adapter, isolation/session, scheduler, or
sibling semantic overlap. This layer does not claim ED-001 or UE-013 proof.

## Layer 1 — Strict Contracts, Mirrors, and Policy

Validate MissionChildRun, child budget, terminal retirement, provider mapping,
Harness, Agent Node, Run Lifecycle, Token Ledger, registries, policy, and
template. Exercise missing, unknown, wrong-type/version, ambiguous, stale, and
cross-identity fields plus mirror/template drift.

Required result: contracts are strict and non-authoritative; policy remains
disabled until the accepted ROD-005 configuration and exact conformance are current.

## Layer 2 — Scope, Budget, Role, and Guard Admission

Generate pairwise and multi-input intersection fixtures for parent, mission,
Workspace Project, Harness, role, isolation, provider mapping, and remaining
budgets. Attempt path/scope/tool/capability/depth/limit widening, role-authority
injection, stale input, incomparability, missing data, forged budget usage, and
expired/revoked/replayed/wrong-child/wrong-session/wrong-candidate guards.

Required result: effective scope and every ceiling are no broader than every
input; unsupported hard dimensions deny; exactly one exact guard can launch.

## Layer 3 — Isolation, Credentials, Git, and Useful Work

Run a useful admitted model task in a fresh independent candidate repository
and short-lived/non-exportable session. Probe environment, HOME, Keychain,
credential helpers, sockets, session material, canonical `.git`, remotes,
config, worktrees, parent/sibling control/evidence/candidates, symlink/alias/
case traversal, provider admin, broker/effect routes, network destinations, and
durable external effects.

Required result: useful candidate output exists, while credentials/session
material, canonical Git, siblings, authority and durable effects remain
unreachable and unchanged.

## Layer 4 — Depth, Recruitment, Scheduling, and Limits

- Probe prompt, tool, model, provider, runtime, RPC, and filesystem surfaces
  for spawn/recruit/delegate/grandchild or persistent-agent creation.
- Race concurrency/locks; exercise steps, attempts/retries, wall timeout, token,
  cost, and evidence boundaries just below/at/above every configured ROD-005 ceiling.
- Census processes, schedules, queues, workers, stores, registries, and symbols
  before/after activation.

Required result: depth is one, no descendant path exists, declared hard limits
stop before overrun or admission denies, and no new scheduler/control plane
appears.

## Layer 5 — Child Provider Mapping Conformance

Run fake and conditionally admitted primary child mappings through exact
prepare/launch/observe/cancel/usage/retire success, failure, timeout, unknown,
duplicate/late response, malformed output, missing usage, and residue cases.
Trace the call graph and mutate generic adapter/registry/support identities.

Required result: RP-13 consumes unchanged RP-11 operations, bypass is absent,
and mapping admission fails on any identity or conformance mismatch.

## Layer 6 — Cancellation and Unknown Reconciliation

Trigger parent/mission revoke, operator cancel, timeout, hard-budget exhaustion,
guard/Harness invalidation, and parent close at every child state. Inject lost
launch/cancel/terminal responses, provider cancel failure, process-group kill
failure, late output, concurrent observer, restart, and ambiguous terminal
evidence.

Required result: exact provider task/process is targeted; unknown stays blocked
and routes through RP-08; no blind retry, replacement, deletion, reuse, or
success inference occurs.

## Layer 7 — Output, Retirement, Replacement, and Rollback

- Validate output schema, allowed diff, conflicts, evidence, and parent-state
  digests before candidate incorporation.
- Interrupt before/after every preservation, guard/session/task/process/lock/
  candidate release, and tombstone step; rerun retirement.
- Attempt resume/retry/recruitment/rebinding with every retired identity.
- Replace a reconciled failed child and compare all old/new identities.
- Execute the complete disable/cancel/reconcile/retire/single-agent rollback.

Required result: parent authority/state changes only through its canonical
reconciler; retirement is idempotent; all old resources reject reuse;
replacement is wholly new; parent/candidate work survives rollback.

## Layer 8 — UX, Burden, Regression, and Architecture Negatives

Verify concise child progress, blocked/unknown reason, cancellation, output
disposition, and retirement in existing mission status/inbox. Count routine
prompts after proof-driven admission. Run ProgramChild proposal-program, single-agent Harness,
mission, recovery, token-ledger, and provider regressions. Scan for persistent
organization/account, credentials, canonical Git, generic-adapter changes,
second scheduler/store/authority/broker/recovery controller, and proposal-path
dependencies.

Required result: zero routine prompts for admitted normal work after accepted
configuration and proof-driven admission,
one existing mission UX, preserved ProgramChild and single-agent behavior, and
no unsupported architecture.

## Planned Command Floor

```text
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-bounded-child-agents
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-bounded-child-agents
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-bounded-child-agents
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-bounded-child-agents
bash .octon/framework/assurance/runtime/_ops/scripts/validate-mission-child-agent-contract.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-workflow-statechart-harness.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-agent-node-model-call-contract.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-token-budget-ledger.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-mission-child-agent-contract.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-token-budget-ledger.sh
```

All kernel/lifecycle-executor mission-child tests and existing ProgramChild,
Harness, recovery, mission, provider, and token regressions are mandatory. New
UE-013 dynamic proof cannot be replaced by static schema checks.

## Retained Evidence

Retain exact implementation, accepted ROD-005 configuration, dependency, policy, contract, Harness,
guard, parent/mission/project/child/attempt, isolation/candidate/session,
provider mapping/task/process, budget/enforcement/usage, cancellation/unknown/
reconciliation, output, retirement/tombstone/replacement, rollback, UX, and
architecture-scan identities under the declared evidence root. Credentials,
exportable session material, raw secrets, and unbounded logs are prohibited.

## Promotion Gate

PO-FD-022 and PG-13-BOUNDED-CHILDREN pass only when Layers 1 through 8 pass at
the same exact implementation/dependency/policy identity. RP-13's PO-FD-023
component is separately bound for RP-14 integrated proof. No support claim or
implementation authorization follows from draft validation.
