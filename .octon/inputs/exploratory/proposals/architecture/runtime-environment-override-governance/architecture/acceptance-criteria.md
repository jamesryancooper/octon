# Acceptance Criteria

The accepted architecture — whichever option human governance selects — must
pin down every row below before implementation planning may begin.

## Per-Override Disposition and Governance-Tier Table (required)

Acceptance must record, for each in-scope input, exactly one disposition —
`removed`, `converted-to-explicit-receipted-input`, or (Option A only)
`retained-as-contracted-break-glass` — **and** exactly one governance
classification: `normal-system-governed`, `exceptional-system-governed`,
`human-break-glass`, or `removed`. Replacement paths must carry the maximum
self-governance their preconditions allow; `human-break-glass` may be assigned
only to operations that override a deny, bypass normal preconditions, perform
emergency recovery outside admitted policy, or execute governance-directed
exceptional action.

| Input | Recommended (Option B) disposition | Governance classification |
| --- | --- | --- |
| `OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE` | converted-to-explicit-receipted-input (publication path only, machine-checked preconditions, auto-deny) | exceptional-system-governed |
| `OCTON_POLICY_MODE_OVERRIDE` | removed as ambient; explicit policy-mode request/config field replaces it | normal-system-governed |
| `OCTON_EFFECTIVE_POLICY_MODE` | removed | removed |
| `OCTON_EXECUTION_ROLE_KIND` / `OCTON_EXECUTION_ROLE_ID` | converted to explicit request/config fields | normal-system-governed |
| `OCTON_EXECUTION_INTENT_ID` / `OCTON_EXECUTION_INTENT_VERSION` | converted to explicit request fields | normal-system-governed |
| `stage_only_behavior` | retained, documented in policy-interface contract | normal-system-governed (documented config) |
| (override of any denial or precondition above) | human-issued directive, rank 1, receipted, scoped, post-use review | human-break-glass |

## Required Criteria

1. **Allowed/forbidden inventory:** a complete, validator-checked inventory of
   environment variables the runtime may read, with every authority-affecting
   ambient read forbidden. New unlisted `OCTON_*` reads in authority paths
   fail validation.
2. **Protected-mode behavior (fail closed):** in `hard-enforce`/protected
   contexts (`octon.yml#execution_governance`), the run **fails closed with a
   reason code** when an in-scope authority-affecting ambient variable is
   present in the environment (after the deprecation phase); in non-protected
   contexts the variable is ignored and surfaced as an actionable warning
   receipt naming the variable and its explicit replacement. Ambient env vars
   provably cannot affect protected authority decisions in any phase.
3. **Required retained receipts (all replacement paths):** every replacement
   path writes or links retained evidence — the publication-bootstrap input
   emits a receipt (with the stale-tolerance reason) linked into the
   publication receipt chain; explicitly selected policy mode appears in
   policy receipts; execution role and intent appear as explicit bound inputs
   in decision artifacts and receipts. (Option A equivalent: every break-glass
   use emits a retained break-glass receipt with operator identity, scope,
   and expiry.)
4. **Validator / negative-control expectations:** an env-override invariance
   negative control exists, runs in the assurance plane, and fails closed on
   any decision drift under adversarial `OCTON_*` settings; a **positive
   proof** shows the route-bundle publication bootstrap completes through the
   explicit receipted path with the ambient variable absent **and with no
   human step** while its preconditions are provable, and **fails closed**
   when any precondition is unprovable; the existing raw-read denial control
   remains green.
4d. **Maximum self-governance:** every legitimate replacement path is
   system-governed at tier 1 or tier 2; human involvement is required only
   for true break-glass (deny override, precondition bypass, emergency
   recovery outside admitted policy, governance-directed action) or
   governance acceptance itself. Acceptance is blocked if any routine
   operation — publication bootstrap included — newly requires human
   approval merely because ambient env vars were removed.
4a. **Explicit-field sourcing:** policy mode and execution role/intent are
   sourced exclusively from explicit request/config fields; role identity is
   validated on the same authority path as other execution authorization
   inputs. No `env::var` read remains on any authority-decision path outside
   declared non-authority diagnostics.
4b. **`stage_only_behavior` bounded:** the field is documented (variants,
   default, failure behavior) and constrained so no variant can convert a
   STAGE_ONLY decision into material execution without explicit
   re-authorization; the effects-layer non-ALLOW rejection remains the
   enforced backstop.
4c. **Operator ergonomics preserved:** legacy-variable presence produces a
   clear, actionable message (named variable, ignored/rejected status,
   documented replacement); replacement commands/fields are documented before
   enforcement flips; local development and test flows work through explicit
   config and non-authority fixtures.
5. **Documentation surfaces:** `policy-interface-v1.md` documents all
   remaining environment inputs and `stage_only_behavior`; a runtime
   environment-input contract exists in `framework/engine/runtime/spec/`;
   the source review's authority-boundary gap is closed in the next
   architecture review cycle.
6. **Rollback posture:** the change is atomic (`change_profile: atomic`);
   rollback is revert of the landed change set; no data migration; the
   publication path must remain able to publish a fresh route bundle
   immediately after rollback (see `support/rollback-plan.md`).
7. **Evidence before implementation planning:** human governance decision
   recorded (option selected); per-override disposition table accepted;
   negative-control design accepted; and — after acceptance — the targeted
   Prompt 4 Architecture Readiness Audit gate evidence exists at its retained
   evidence path and is cited by this packet
   (`architecture/implementation-plan.md` precondition 3; not yet run).
   Implementation planning may not begin while any row is undecided or the
   Prompt 4 gate evidence is missing (readiness gate).
8. **Candidate fail-closed rule:** text and id reserved for the new FCR rule,
   to be authored only through the charter amendment policy (human approval,
   aligned docs and validators in the same change).

## Closure Condition

Zero unresolved source findings in scope: F-01 and F-02 each map to a
completed disposition, receipt, validator, and documentation row
(`navigation/traceability-map.md`). F-03 and F-05 are recorded deferrals with
owners in `proposal.yml`, not closure blockers.
