# Target Architecture

Option B (removal/replacement) is this packet's selected recommended
direction, pending human governance acceptance; if governance selects Option A
instead, the acceptance criteria file defines the equivalent
break-glass-contract target. Operational flexibility preservation, the
break-glass boundary, and the migration plan live in
`operational-flexibility-and-migration.md`.

## Replacement Architecture Per Override

Governance tiers per `operational-flexibility-and-migration.md` §1:
tier 1 = normal system-governed; tier 2 = exceptional system-governed with
stricter evidence; tier 3 = human break-glass; removed = no replacement
needed. Human involvement appears only at tier 3.

| Ambient input (today) | Governance tier | Explicit replacement (target) | Path restriction and preconditions | Retained evidence | Ambient acceptance |
| --- | --- | --- | --- | --- | --- |
| `OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE` | **2 — exceptional system-governed** | Explicit receipted publication-bootstrap input (typed parameter/bound input on the publication command that today self-sets the variable, `kernel/src/commands/mod.rs:1111-1114`). Proceeds **without any human step** when preconditions are machine-provable; human break-glass enters only to override an automatic denial. | Usable **only** by the route-bundle publication path. Machine-checked preconditions: caller is the publication path; the current bundle/lock is stale or digest-drifted; this publication regenerates that same bundle; bypass scope limited to this one publication. Any precondition unprovable → automatic denial. | Publication-bootstrap receipt recording caller proof, the stale-tolerance necessity, and scope, linked into the publication receipt chain under `state/evidence/validation/publication/**` | **Never** — the variable is not read; presence triggers ignore-and-warn (deprecation phase) or protected-mode rejection (enforcement phase) |
| `OCTON_POLICY_MODE_OVERRIDE` | **1 — normal system-governed** | Explicit policy-mode request/config field. Declared development modes (`shadow`, `soft-enforce` per `octon.yml#execution_governance.policy_mode.allowed_development_modes`) remain usable **without human approval** through approved config. | Non-protected contexts only; protected/hard-enforce contexts reject ambient-driven mode change categorically | Policy receipt records the explicitly selected mode and its source | Never |
| `OCTON_EFFECTIVE_POLICY_MODE` | **removed** | Removed outright (fallback duplicate of the above) | n/a | n/a | Never |
| `OCTON_EXECUTION_ROLE_KIND` / `OCTON_EXECUTION_ROLE_ID` | **1 — normal system-governed** | Explicit execution-role fields in request/config context; role identity validated on the same authority path as other execution authorization inputs (bound into the ExecutionRequest and checked at grant time, like support tuple and context bindings). No human step for normal binding; overriding a role outside admitted policy is a tier-3 event. | Authority engine request-builder only | Role identity appears in the authorization decision artifact and receipts as an explicit bound input | Never |
| `OCTON_EXECUTION_INTENT_ID` / `OCTON_EXECUTION_INTENT_VERSION` | **1 — normal system-governed** | **Declared authority-affecting** (intent binding gates autonomous execution per `policy-interface-v1.md:105-135`) and therefore converted to explicit request fields validated by the existing intent checks (`INTENT_MISSING` / `INTENT_REF_INVALID`) — no ambiguity remains. Overriding intent outside admitted policy is a tier-3 event. | Authority engine request-builder only | Intent ref retained in request/grant/receipt bindings as today, now from an explicit source | Never |
| `stage_only_behavior` (config field, F-02) | **1 — normal system-governed** (documented config) | Retained as governed configuration, fully documented; constrained so that no variant can convert a STAGE_ONLY decision into material execution without explicit re-authorization (the effects.rs non-ALLOW rejection remains the backstop) | Policy engine configuration only | Policy receipts record the active behavior variant | n/a (config file, not ambient) |

## Target State

1. **Ambient environment is a declared non-authority surface for authority
   decisions.** No code path in `authorize_execution()`, policy evaluation,
   effect-token verification, or route-bundle verification reads process
   environment to alter its decision. The boundary recorded as a gap in the
   source review's `authority-boundary-map.yml` (`ambient-process-environment`)
   becomes `status: closed-by-construction`.
2. **Publication bootstrap is explicit, receipted, and self-governed.** The
   route-bundle publication command accepts an explicit bypass input
   (parameter or bound run input, not environment), permitted only on the
   publication path, gated by machine-checked preconditions (caller identity,
   stale-tolerance necessity, single-publication scope) with automatic denial
   when any precondition is unprovable, and emitting a retained
   publication-bootstrap receipt under
   `state/evidence/validation/publication/**` linked to the resulting
   publication receipt. No human step is required while preconditions hold;
   human break-glass exists only to override a denial.
3. **Execution role and intent are explicit request fields.** Absent-value
   defaults live in configuration or the request builder, not `env::var`
   reads inside the authority engine.
4. **Policy mode has no ambient override.** The policy launcher's mode is
   bound from governed configuration and the run's policy digest; the
   wrapper-export mechanism is replaced by explicit invocation input.
5. **`stage_only_behavior` is documented** in `policy-interface-v1.md` with
   its variants, default, and failure behavior (F-02).
6. **A candidate fail-closed rule exists** (new FCR id, append-only per the
   reason-code contract): ambient environment input to an authority decision
   routes DENY. Constitutional file changes follow the charter amendment
   policy (human approval + aligned doc/validator updates).
7. **A negative control exists**: a validator that sets each in-scope
   `OCTON_*` variable to adversarial values in a protected-mode context and
   proves authority decisions, policy mode, recorded role, and route-bundle
   verification outcomes are invariant; wired into the assurance plane like
   the existing raw-read denial control (EVI-025 pattern).

## Authority Model Preservation

- No new authority surface is created; one undeclared surface is eliminated.
- `framework/**`-only authority placement unchanged; the new spec contract,
  FCR rule, and validator are authored framework surfaces landed through the
  governed route after acceptance.
- Deny-by-default is strengthened: FCR-025/026 hold unconditionally except
  through an explicit, receipted, validator-covered publication input.
- No second control plane: process environment is removed as a
  control-affecting channel; nothing replaces it except governed artifacts
  that already exist (run contracts, grants, receipts).

## Out of Target

Implementation patches, unrelated runtime refactors, support-target changes,
generated/effective publication, proposal program creation, constitutional
amendment drafting (the candidate FCR rule is defined here only as an
acceptance requirement for later governed authoring).
