# Current-State Gap Analysis

This section turns the included MSRAOM implementation audit
(`resources/implementation-audit.md`) into a concrete implementation delta.

## Summary Judgment

The repo has implemented the **contract and policy spine** of Mission-Scoped
Reversible Autonomy, but not the full **control-plane, operator-plane, and
scenario-resolution integration** needed for long-running or always-running
agents.

### What is already real

- Mission-Scoped Reversible Autonomy is the declared canonical model.
- Mission charter v2, mission classes, mission-autonomy policy, and ownership
  registry exist.
- Execution request/receipt/policy contracts carry mission, slice, mode,
  reversibility, and recovery fields.
- ACP, grants, receipts, and `STAGE_ONLY` remain the execution-governance
  backbone.

### What remains materially incomplete

1. **Per-mission control contracts are not fully contractized or scaffolded.**
2. **Forward intent is not yet a complete, published control primitive.**
3. **Directive and schedule semantics are not fully consumed by runtime.**
4. **Autonomy burn and breaker behavior are only partly automated.**
5. **Safing and break-glass exist mostly at the policy layer.**
6. **Generated mission/operator read models are still missing.**
7. **Retained control-plane evidence emission is incomplete.**
8. **Scenario differentiation exists implicitly, but not as a materialized
   effective route shared by runtime and operator views.**
9. **At least one reader mismatch remains (`owner_ref` vs legacy `owner`).**
10. **Some repo docs overclaim surfaces that are still placeholder-only.**

## Gap Matrix

| Area | Current state | Gap | Required correction |
| --- | --- | --- | --- |
| Mission control root | Canonical path exists | Active file family is not fully schema-backed or scaffolded | Add schemas, scaffolds, validators, and writers for every required mission control file |
| Continuation lease | Runtime expects it | No visible committed schema/template family | Add `mission-control-lease-v1`, scaffold, and validator |
| Mode beacon | Fields exist in execution contracts | Operator-facing materialization is missing | Add `mode-state-v1`, runtime writer, and `Now` projection |
| Forward intent register | Runtime expects it | No complete schema, publisher, or consumer path | Add `intent-register-v1`, planner publisher, preview consumer, and `Next` projection |
| Control directives | Receipts can reference directives | Directive mutation and consumption are weakly integrated | Add `control-directive-v1`, runtime consumers, receipts, and precedence enforcement |
| Schedule semantics | Policy defines overlap/backfill/pause-on-failure | Scheduler behavior is not clearly wired | Add `schedule-control-v1` and explicit scheduler consumers |
| Autonomy burn budgets | Policy defines thresholds | No complete burn aggregation pipeline | Add runtime aggregation from receipts/incidents and state writers |
| Circuit breakers | Policy defines trip conditions/actions | Weak evidence of full runtime trip/reset behavior | Add breaker state writers, runtime consumers, and operator surfacing |
| Safing | Policy concept exists | Safe-subset enforcement is not clearly runtime-complete | Add safing subset resolution and runtime execution gating |
| Break-glass | Policy precedence exists | Mission-level operator visibility and receipts are incomplete | Add authorize-update flow, receipts, and mode-state integration |
| Control evidence | Canonical family is declared | Emission is not evident end-to-end | Add `control-receipt-v1` writers and retained evidence routes |
| Mission summaries | Canonical directories are declared | Placeholder-only in-tree | Materialize `Now / Next / Recent / Recover` |
| Operator digests | Canonical directories are declared | Placeholder-only in-tree | Add digest generator and routing |
| Scenario routing | Implicit via mission class, ACP, policy, executor profile | No effective scenario-resolution artifact | Add derived scenario resolver and generated effective output |
| Reader alignment | Mission v2 uses `owner_ref` | At least one orchestration reader still expects `owner` | Update readers, add migration shim if needed, add regression tests |

## Contradictions To Resolve

### 1. Placeholder-only generated views
The repo declares generated mission/operator summaries as canonical derived
surfaces, but the directories remain placeholder-only. The cutover must
materialize the actual views or remove the claims. This proposal chooses
**materialization**.

### 2. Runtime-required files without durable specs
The runtime expects per-mission control files such as `lease.yml`,
`intent-register.yml`, `schedule.yml`, and `autonomy-budget.yml`, but the repo
does not yet clearly expose a full contract family for them. The cutover must
make those files first-class contracts.

### 3. Mission charter reader mismatch
Mission v2 uses `owner_ref`, but older readers still appear to expect `owner`.
The cutover must make `owner_ref` canonical, update readers, and add a one-time
migration shim only if required for active missions.

### 4. Policy richness ahead of runtime resolution
`mission-autonomy.yml` contains a rich routing model, but runtime behavior does
not yet appear to consume all of it. The cutover must add an explicit resolver
and corresponding runtime integrations.

### 5. Recovery semantics partly hardcoded
Recovery windows and rollback metadata should be policy- and scenario-derived,
not hardcoded fallback values. The cutover must eliminate hidden fallback
semantics for material work.

## Design Decision

This proposal resolves the gaps by requiring one **atomic completion cutover**
rather than a series of partial follow-on patches. The repo should emerge from
the cutover with:

- one live MSRAOM implementation path,
- no placeholder-only canonical surfaces,
- no runtime-required control file without a durable contract,
- no mission/operator surface that depends on undocumented in-memory logic,
- one materialized scenario-resolution layer shared across runtime and operator
  views.
