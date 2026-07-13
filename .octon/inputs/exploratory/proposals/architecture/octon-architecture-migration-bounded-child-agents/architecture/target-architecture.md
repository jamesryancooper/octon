# Target Architecture

## Decision

Implement FD-022 as a temporary `MissionChildRun` specialization over existing
lifecycle scheduling, RP-11 deterministic Harness/generic adapter, and RP-08
reconciliation. Implement only RP-13's child-mapping contribution to FD-023.
Do not create another scheduler, runtime, store, authority source, generic
adapter, agent account, or organization model.

## Distinct Identity Model

`ProgramChild` and `MissionChildRun` remain different types:

- `ProgramChild` is an existing durable proposal/program work item with packet
  lifecycle and closeout semantics.
- `MissionChildRun` is one temporary model-backed execution attempt inside one
  parent mission/run. It has no account, home, standing membership, reusable
  identity, autonomous lifecycle, or post-terminal authority.

A child ID is unique within repository/mission/parent-run lineage and is never
reissued. A retry that requires a new provider task/session after reconciled
terminal failure receives a new attempt identity. A replacement after unknown
outcome receives an entirely new child identity only after RP-08 reconciles and
RP-13 retires the predecessor.

## Accepted ROD-005 Resource Baseline

ROD-005 accepts the lowest useful concurrency and conservative, adjustable
wall-clock, step, attempt/retry, token, cost, and evidence ceilings for Solo
Local. Exact numbers are not invented here. Engineering must bind provisional,
enforceable values before design exit, measure actual queue time, completion
rate, usage, evidence growth, cancellation, and recovery, and widen only one
dimension at a time when retained dogfood evidence proves material benefit
without violating the accepted safety boundary.

Later tuning is a governed configuration update, not another architecture
disposition. Any future operator-defined spending or interruption ceiling is an
additional configuration cap. Depth one, one generic child contract, and named
roles as templates rather than authority classes are accepted design
boundaries, not new operator choices.

Engineering conformance determines whether each dimension is hard-enforced,
measurement-only, or unsupported for a provider mapping. Provider-native use
after conformance is part of the accepted target state, not a ROD-005 choice.
Until engineering binds enforceable provisional values and every applicable
dependency, conformance, and proof gate passes, mission child launch is
disabled. Unsupported hard dimensions deny admission; they are never silently
downgraded to measurement.

## Role Templates

Planner, researcher, implementer, tester, adversarial reviewer, and integrator
may exist as fixed prompt/output/tool templates. A template can narrow:

- expected output schema and acceptance evidence;
- allowed candidate paths and tools;
- context subset;
- budget slice; and
- provider mapping eligibility.

A role name cannot grant authority, credentials, capability packs, external
effects, broader scope, additional depth, or persistence. Dynamic roles and
self-selected/recruited roles are unsupported.

## Strict Admission Intersection

The effective child envelope is:

```text
parent run grant
∩ mission objective and scope
∩ Workspace Project boundary and protected paths
∩ exact child Task-Specific Harness
∩ fixed role-template narrowing
∩ candidate-isolation boundary
∩ provider-child mapping capabilities
∩ remaining parent and accepted ROD-005 configuration budgets
```

Every dimension is explicit and digest-bound. Missing, stale, ambiguous,
incomparable, or widening values deny. Parent defaults are not copied when they
would grant more than the child request. The parent retains ownership of all
canonical mission/run transitions and material effects.

Initial child scope is candidate-only:

- one fresh independent disposable repository/candidate root;
- explicit repository-relative write roots and exclusion of parent/sibling/
  canonical control, evidence, credential, and Git metadata roots;
- no canonical remote mutation, publication, broker/effect token, provider
  admin, or durable external effect;
- read-only context limited to the exact child Harness; and
- output limited to candidate artifacts and typed evidence for parent
  reconciliation.

## ED-001 Premise

RP-13 relies on a dynamically proved dependency-chain implementation of
ED-001: native sandboxing, independent disposable repository, and a useful
short-lived/non-exportable primary-provider session independent of the effect
broker. RP-13 cannot choose or modify that mechanism. If the child can read
durable credentials, export/reuse its provider session, access canonical Git,
or cannot perform useful positive model work, admission remains disabled and
the owning dependency must be revised.

## Exact One-Shot Child Guard

Each admitted child receives one guard binding:

- repository/project/mission/parent run/child/attempt identities;
- parent decision/grant and strict intersection digest;
- exact child Harness/source-manifest/compile-receipt digests;
- isolated candidate repository root/identity and provider session identity;
- child provider mapping/adapter identity and conformance version;
- role template and complete budget/enforcement posture;
- allowed tools/output/evidence destinations;
- cancellation token/revocation refs; and
- issued/expiry/one-shot consumption and non-reuse identity.

RP-13 supplies and validates child-specific bindings through RP-11. It does not
change guard issuance, predicates, consumption, or authority semantics. A
wrong, stale, expired, revoked, widened, already-consumed, or cross-child guard
denies before provider launch.

## Scheduler Reuse and Budget Enforcement

The existing lifecycle-program scheduler contributes only reusable mechanics:

- dependency-ready batch selection;
- bounded concurrency and locks;
- step/attempt counters and retry ceilings;
- wall-clock timeout and cancellation propagation;
- terminal observation/evidence hooks; and
- recovery handoff.

RP-13 maps a `MissionChildRun` job into those mechanics without importing
proposal packet/closeout identity or adding a queue/worker. Scheduler state is
bounded by the parent mission/run and vanishes after terminal reconciliation
and retained evidence.

| Dimension | Initial posture |
| --- | --- |
| Depth | Hard fixed at one; no child spawn API exists. |
| Concurrency | Hard scheduler/lock limit from the minimum of the configured accepted ROD-005 ceiling and parent remaining allowance. |
| Steps | Hard scheduler counter; next step denies at ceiling. |
| Attempts/retries | Hard attempt counter; retry only after reconciled prior attempt and within ceiling. |
| Wall-clock timeout | Hard supervisor deadline followed by cancel/terminate/reconcile. |
| Tokens | Hard only when provider/API can cap the exact child request and report compatible usage; otherwise measured or unsupported. |
| Cost | Hard only when preflight/runtime enforcement can prevent overrun; estimates/after-the-fact usage are measurement. |
| Evidence volume | Hard bounded by RP-08/RP-07 capacity interface where declared; otherwise admission denies a hard claim. |

Token Budget Ledger records provenance and measured/estimated values. It never
authorizes or proves a hard ceiling without the child-budget enforcement
receipt.

## Child Provider Mapping

RP-11 owns `ExecutorAdapter`, registry, and generic
`prepare/launch/observe/cancel/usage/retire` semantics. RP-13 adds a distinct
strict `MissionChildProviderMapping` that translates the child contract into
those operations:

- `prepare`: verify exact child contract/guard/Harness/isolation/budget and
  ensure provider child/grandchild/credential/export features are disabled;
- `launch`: create exactly one provider-native child task/session under the
  consumed guard;
- `observe`: return child task state/output refs without declaring parent
  mission success;
- `cancel`: bind parent/mission/revoke/timeout/budget/operator trigger to the
  exact provider task and process group;
- `usage`: return enforceable/measured/unsupported dimensions with provenance;
  and
- `retire`: release/revoke provider task/session handles and report residue.

`child.rs` owns generic child-to-adapter mapping; `child_codex.rs` owns only a
conditionally admitted primary-provider child mapping. It cannot redefine
RP-11's generic `codex.rs`, adapter trait, or provider support. Fake child
mappings prove success/failure/unknown/cancel/usage/retire edges. A mapping is
live only while current conformance and the existing proof and promotion gates
admit it.

## Child Lifecycle

| State | Meaning | Allowed next state |
| --- | --- | --- |
| `candidate` | Requested child; no guard/session/repository exists. | `admitted`, `denied` |
| `admitted` | Strict scope/budget/depth/provider/isolation checks pass and exact contract exists. | `prepared`, `denied`, `revoked` |
| `prepared` | Fresh repository/session and unconsumed one-shot guard are bound. | `running`, `cancel_requested`, `failed` |
| `running` | Exact guard consumed and one provider task/process active. | `observing`, `cancel_requested`, `timed_out`, `failed` |
| `observing` | Terminal/unknown provider result and output/evidence are being reconciled. | `reconciled`, `cancel_requested`, `unknown` |
| `unknown` | Outcome is not safely attributable/terminal. | `reconciled`, `cancel_requested` through RP-08 only |
| `cancel_requested` | Provider cancel and process-group termination are in progress. | `reconciled`, `unknown` |
| `reconciled` | Output/candidate/evidence and parent disposition are known without child-owned parent mutation. | `retiring` |
| `retiring` | Guard/session/task/candidate ownership revocation and tombstone are in progress. | `retired`, `retirement_blocked` |
| `retired` | Terminal evidence complete; all reusable resources revoked/released; identity tombstoned. | terminal |
| `denied` | Admission failed before launch; any staged resources are retired. | `retiring`, then `retired` |
| `retirement_blocked` | Residual resource or missing evidence prevents safe terminal claim. | `retiring` after repair/reconciliation |

Provider process exit alone is not `reconciled` or `retired`. A terminal child
result does not append parent mission/run success; the parent reconciler
validates output and performs canonical transitions.

## Cancellation and Unknown Outcome

Parent/mission revocation, operator cancellation, timeout, hard-budget
exhaustion, invalidated guard/Harness, or parent close triggers cancellation.
RP-13 requests provider cancel through the child mapping and process-group
termination through RP-11's generic implementation. The exact task/process/
session identity is observed until terminal or unknown.

Unknown launch/cancel/terminal response is handed to RP-08 with exact child,
guard, provider task, process, candidate, and evidence refs. No blind retry,
replacement, candidate deletion, identity reuse, or success inference occurs.
A replacement child is possible only after the predecessor is reconciled and
retired and always receives new identities/resources.

## Output Reconciliation and Terminal Retirement

The child writes only its isolated candidate/evidence surfaces. Parent
reconciliation validates output schema, scope-diff, validation evidence,
conflicts, and current parent state. Accepted output may be incorporated by the
parent's existing candidate route; rejected output remains evidence or is
discarded under retention. The child never merges/publishes.

Retirement requires one receipt proving:

- final provider/process observation or RP-08 reconciled unknown;
- output/candidate/evidence preservation/disposition;
- cancellation token and one-shot guard revoked/consumed/non-reusable;
- provider child task and session released/revoked/non-reusable;
- process group absent or explicitly reconciled;
- candidate repository ownership released and deleted only after required
  output/evidence preservation;
- temporary locks/leases released;
- child/attempt identity tombstoned in canonical lineage; and
- no live ref permits resume, retry, recruitment, or new work as that identity.

## Degraded Operation

If child policy, provider mapping, isolation/session, guard, budget enforcement,
cancellation, reconciliation, capacity, or retirement is unavailable, new
child launch fails closed while the parent continues or resumes through the
single-agent RP-11 route where its own authority permits. Active children are
cancelled/reconciled/retired; their output and parent work are preserved.

## Unsupported Remainder

Persistent agents or organizations, named-role authority classes, reusable
agent accounts/HOMEs/sessions, credentials, canonical Git, publication or
durable effects, depth above one, grandchildren, child-created children,
self-recruitment, dynamic delegation, standing queues/workers, cross-mission
children, silent budget downgrade, child-owned parent transitions, and
unretired identity reuse are unsupported.
