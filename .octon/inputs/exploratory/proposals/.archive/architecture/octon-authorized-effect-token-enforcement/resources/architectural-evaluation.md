# Architectural Evaluation

## Why this step is highest leverage after the Run Journal

The canonical append-only Run Journal records what happened. Authorized Effect Tokens determine what is allowed to happen. After the journal, the next highest leverage step is to ensure the runtime cannot produce material side effects from raw paths, ambient grants, generated projections, host UI state, or caller assertions.

Octon already has a strong constitutional and runtime doctrine:

- material execution must pass through `authorize_execution(request: ExecutionRequest) -> GrantBundle`;
- no material side effect may occur before a valid grant exists;
- receipts are mandatory;
- ownership, support-target routing, reversibility, budget, egress, context provenance, risk/materiality, rollback posture, and capability-pack admission participate in authority routing;
- material path coverage is invalid without inventory, negative controls, retained evidence, and receipts;
- fail-closed obligations include missing authorization-boundary proof and missing support-target proof.

Those are strong architecture claims. The remaining high-leverage improvement is to make them unavoidably true in the runtime API shape.

## Current constraints that make this necessary

### 1. Existing token doctrine is correct but incomplete

`authorized-effect-token-v1.md` already says side-effecting runtime APIs must consume typed effect tokens derived from the authorization boundary. That is the right doctrine, but it needs schema, metadata, verifier, ledger, consumption receipts, and negative bypass tests.

### 2. Existing implementation has partial token support

The `authorized_effects` crate already defines `AuthorizedEffect<T>` and effect marker types. The authority engine already imports these types and has helper methods that issue some effects from a GrantBundle. This is valuable because the proposal is not greenfield. However, current token shape is not yet closure-grade: it is too easy to treat a serializable token-shaped value as sufficient, and it lacks full grant/run/journal/revocation/consumption provenance.

### 3. Existing material path coverage contract is stronger than the current token implementation

`authorization-boundary-coverage-v1.md` already requires every material path family to bind a path id, owner, side-effect class, affected root, boundary binding point, support posture, capability-pack posture, approval posture, rollback posture, negative-path test, and retained evidence. The runtime should now use Authorized Effect Tokens as the concrete enforcement mechanism for that coverage contract.

### 4. Support-target claims need executable proof

`support-targets.yml` already requires runtime-event ledgers, authority artifacts, run evidence roots, proof bundles, and bounded admitted support. Token enforcement turns those proof requirements into an API-level invariant for live repo-shell and CI-control-plane support.

## Current surfaces that partially cover the step

| Surface | Existing coverage | Packet action |
|---|---|---|
| `authorized-effect-token-v1.md` | Declares the token doctrine. | Strengthen and reference v2 schema/consumption proof. |
| `authorized_effects` crate | Defines token and effect marker types. | Harden metadata, construction, verification, and guard semantics. |
| `authority_engine` | Issues some effects from grants. | Make token minting complete, ledger-backed, and journaled. |
| `execution-authorization-v1.md` | Declares authorization boundary. | Preserve as boundary; token is the consumable product. |
| `authorization-boundary-coverage-v1.md` | Requires path coverage and negative controls. | Add token enforcement as closure mechanism. |
| `material-side-effect-inventory-v1.schema.json` | Provides inventory schema. | Require token mappings and test refs. |
| `run-lifecycle-v1.md` | Defines state machine. | Bind token validity to Run states. |
| `evidence-store-v1.md` | Defines retained evidence. | Add token issue/consume proof. |
| `support-targets.yml` | Defines live support and evidence requirements. | Add token coverage proof without support widening. |

## What remains missing

- Complete token metadata.
- Canonical token control records.
- Token consumption receipts.
- Token lifecycle journal events/items.
- Verifier-backed `VerifiedEffect<T>` guard.
- API signature hardening across material APIs.
- Complete material side-effect inventory.
- Negative bypass tests for every material path family.
- Support-target proof update.
- Closure evidence that no raw or ambient path remains live for material effects.

## Why this does not create a rival Control Plane

The token is not a policy evaluator, approval object, or support-target authority. It is the typed runtime product of the existing authorization boundary. Policy remains in the Control Plane. The token is consumed in the Execution Plane by the Governed Agent Runtime to prove that a specific effect is allowed within the current Run.

## Architectural payoff

This step materially improves:

- authority-model correctness;
- runtime enforcement quality;
- capability boundary discipline;
- support-target proof depth;
- replay and auditability;
- operator confidence;
- negative-control assurance;
- long-running governed agentic fitness;
- maintainability of side-effect APIs.
