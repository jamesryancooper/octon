# Current-State Gap Map

## Summary

| Concept | Current Octon evidence | Coverage status | Gap type(s) | Operational risk if left as-is | Disposition |
|---|---|---|---|---|---|
| Authorized Effect Token contract | `authorized-effect-token-v1.md` declares typed tokens and side-effect API requirement. | partially covered | contract too thin; no consumption schema | Material APIs can still rely on ambient grants or raw inputs if enforcement is not universal. | strengthen |
| Authorized effects crate | `octon_authorized_effects` crate defines `AuthorizedEffect<T>` and effect marker types. | partially covered | public constructor; incomplete metadata; no verifier/consumption guard | Arbitrary runtime callers can construct token-like values; token lacks grant, expiry, revocation, journal, and consumption proof. | harden |
| Authority-engine token issuance | `GrantBundle` has helper methods for evidence/control/service/repo/executor effects. | partially covered | partial effect classes; no full material family mapping; no issuance ledger | Some effect paths may receive tokens; others may bypass or use untyped grant state. | extend |
| Execution authorization | `execution-authorization-v1.md` requires `authorize_execution` and receipts. | strong concept | token not yet the required consumable authority object | Authorization can remain a receipt boundary rather than API-level capability enforcement. | bind to token model |
| Authorization boundary coverage | `authorization-boundary-coverage-v1.md` requires inventory and negative controls. | strong concept | no complete promoted inventory/validator suite for token enforcement | Coverage claims may be unproved for every material family. | implement |
| Material side-effect inventory | `material-side-effect-inventory-v1.schema.json` exists. | schema only | no complete inventory file or enforcement path map observed | Missing or stale path maps can hide bypass paths. | add inventory + validator |
| Runtime events / Run Journal | `runtime-event-v1` contains broad execution events. | partial | no token lifecycle events in current enum; depends on canonical Run Journal promotion | Token mint/consume/reject/revoke events may not be replayable or auditable. | integrate after Run Journal |
| Run lifecycle | `run-lifecycle-v1.md` defines bound/authorized/running/paused/etc. | strong concept | token states not mapped to lifecycle transitions | Effects may execute in wrong lifecycle state or after revocation. | refine |
| Evidence store | `evidence-store-v1.md` defines required run evidence. | strong concept | token receipts not named as required material-run artifacts | Closure may not prove token enforcement. | refine |
| Support targets | `support-targets.yml` requires runtime-event ledgers and authority artifacts. | strong support discipline | token coverage not explicit as support proof criterion | Live support claims may not prove API-level authorization enforcement. | add proof requirement |
| Repo-shell execution classes | policy classifies shell command routes. | partial | command class route does not yet require token class match | Shell-backed effects may be classified but not token-gated. | strengthen |

## Blocking gaps

### Gap 1 — Token can be constructed too broadly

Current `AuthorizedEffect<T>` appears as a serializable value with a public constructor. That is useful for early implementation but insufficient for target-state enforcement. A target token must be ledger-backed and verifier-validated, not merely typed.

**Closure action:** make token construction authority-owned in practice by requiring verifier checks against canonical token records, private fields where feasible, token digest verification, and non-serializable `VerifiedEffect<T>` guards for actual mutation.

### Gap 2 — Token metadata is insufficient

The current token carries request/run/scope/support/capability basics, but not full authorization provenance.

**Closure action:** extend the promoted schema and implementation to include token id, grant id, decision artifact ref, grant bundle ref, issued/expires timestamps, single-use semantics, revocation ref, token record ref, journal ref, and digest.

### Gap 3 — Effect classes do not yet prove complete material-family coverage

The current v1 classes cover many material families, but the boundary-coverage contract also names outbound HTTP, model-backed execution, promotion/activation, and support-target-affecting flows.

**Closure action:** complete `material-side-effect-inventory.yml`; either map those families to existing effect classes with explicit rationale or add v2 effect kinds.

### Gap 4 — Side-effect APIs are not yet proven token-gated

The repo documents the target condition, but coverage is only real when material API signatures and tests prove direct bypass attempts fail closed.

**Closure action:** update material API signatures to require token/guard inputs and add negative bypass tests.

### Gap 5 — Token lifecycle is not yet journaled

The current event schema lacks token lifecycle events. Since this packet is sequenced after the canonical Run Journal, token events should become typed journal items.

**Closure action:** add token lifecycle event/item types and require journal append before effect consumption.

### Gap 6 — Closure evidence does not yet require token proof

Evidence Store v1 does not yet explicitly include token issuance/consumption proof in the minimum consequential run bundle.

**Closure action:** update evidence-store and validation requirements so Run closeout fails when token proof is absent for material effects.
