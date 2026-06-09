# Delegated Governance Contract v1

This contract defines shared proof-first delegation semantics for Octon domains
that need lifecycle-style delegation behavior without reusing lifecycle route
schema as their native domain schema.

The machine-readable contract lives at:

`/.octon/framework/constitution/contracts/authority/delegated-governance-contract-v1.schema.json`

## Role

Delegated Governance Contract v1 classifies a domain surface before dispatch.
It may prove a surface is safe delegated execution, typed human exception,
deny-only, projection-only, generated non-authority, grant consumption, an
evidence gap, or out of scope.

The contract does not authorize material execution by itself. Material
execution still requires the applicable run contract, authority route, support
posture, rollback posture, grant bundle, effect-token verification or
equivalent local guard, retained receipts, and Run Journal coverage.

## Lifecycle Mapping

Lifecycle route execution requests already carry a route-local
`delegation_contract`. That lifecycle schema remains valid, but it is now a
domain-specific projection of these shared semantics:

| Shared decision class | Lifecycle projection | Meaning |
| --- | --- | --- |
| `delegated-execution` | `delegated-execution` | A proof-bound runtime, workflow, validator, or capability may execute inside declared scope after evidence gates and dispatch receipts pass. |
| `grant-consumption` | `delegated-execution` | Execution consumes an already-bound grant and required token or equivalent guard. It never mints fresh authority. |
| `typed-human-exception` | `new-governance-decision` | A human or quorum-controlled approval, exception lease, revocation, amendment, break-glass grant, or similar explicit authority artifact is required. |
| `deny-only` | `non-dispatch` | The surface is explicitly denied for delegated execution. |
| `projection-only` | `non-dispatch` | The surface may route or summarize, but it cannot authorize execution. |
| `generated-non-authority` | `non-dispatch` | Generated output or read-model material may be evidence only when explicitly permitted; it cannot be authority. |
| `needs-more-evidence` | `non-dispatch` | Missing or stale proof blocks dispatch until retained evidence is supplied. |
| `out-of-scope` | `non-dispatch` | The surface is outside the declared delegated-governance envelope. |

## Required Semantics

Every contract instance must bind:

- decision class and lifecycle projection;
- safe delegation posture;
- explicit approval posture;
- allowed authority zones;
- declared scope source and optional scope refs;
- required evidence gates;
- required receipts before dispatch and completion;
- replay or compensation class;
- automated recovery policy;
- fail-closed behavior;
- human-only boundaries;
- typed human exception grant semantics;
- grant-consumption semantics;
- approval-posture derivation denials;
- generated/read-model non-authority rules.

## Approval Derivation Denials

Approval posture must never be derived from:

- route shape;
- workflow shape;
- extension shape;
- adapter shape;
- generic importance.

Any route that lacks explicit authority evidence, explicit delegation evidence,
or explicit typed human exception evidence fails closed. A useful operator view,
dashboard, generated projection, or read model does not become authority.

Workflow and capability classifications follow the same rule. A
`human-only` classification is valid only when it names a typed boundary that
cannot be machine-proven. A `role-mediated` classification may consume an
already-bound grant as delegated execution, but it does not create new
authority and cannot rely on route, workflow, extension, adapter, generated
capability-index, or importance shape as its approval posture.

## Grant Consumption

Grant consumption is delegated execution, not new authority. It requires:

1. a current grant ref inside the applicable authority route;
2. scope match against the contract and target;
3. effect-token consumption or an equivalent local guard required by the domain;
4. retained consumption receipts;
5. Run Journal or domain-equivalent evidence coverage.

Grant consumption must fail closed when a grant is missing, stale, revoked,
expired, already consumed, out of scope, tied to the wrong run or route, tied
to the wrong support tuple, or unsupported by retained receipts.

## Typed Human Exception Grants

Typed human exception grants create or resolve authority only through explicit
approval, exception lease, revocation, amendment, break-glass, waiver, incident
closure, or equivalent policy-backed artifacts. They must include:

- scope;
- owner;
- reason;
- evidence refs;
- expiry or retirement posture;
- revocation behavior.

The existence of a route, workflow, extension, adapter, generated projection,
operator read model, or unresolved blocker does not imply a typed human
exception grant.

## Generated And Read-Model Surfaces

Generated outputs and read models may satisfy an evidence gate only when the
contract explicitly permits that evidence use and the generated/read-model
surface cites canonical source refs and freshness metadata. They remain
forbidden as authority, policy, support, control, promotion, closeout, or
terminal truth sources.

## Recovery And Replay

Automated recovery must stay inside the declared recovery policy. Recovery may
perform bounded retry, replay from the canonical journal, compensating action,
stage-only handling, or no action according to the contract. Recovery cannot
expand scope, override policy, mint fresh authority, substitute generated
authority, reuse an out-of-scope grant, or perform external effects without a
valid token or equivalent guard.

## Related Contracts

- `/.octon/framework/constitution/contracts/authority/delegated-governance-contract-v1.schema.json`
- `/.octon/framework/orchestration/governance/delegated-governance-inventory-v1.yml`
- `/.octon/framework/engine/runtime/spec/lifecycle-route-execution-request-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
- `/.octon/framework/constitution/contracts/authority/authority-zone-v1.schema.json`
- `/.octon/framework/constitution/contracts/authority/grant-bundle-v2.schema.json`
- `/.octon/framework/engine/runtime/spec/authorized-effect-token-consumption-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
