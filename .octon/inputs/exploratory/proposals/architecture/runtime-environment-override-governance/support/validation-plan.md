# Validation Plan

Expected validation for the accepted architecture (Option B framing; Option A
equivalents noted where they differ). Defined here; not executed by this
packet.

1. **Environment-override inventory check.** A validator enumerates every
   `env::var` read in authority-affecting crates (`authority_engine`,
   `policy_engine`, `core`, `kernel` authority paths) and fails on any read
   not declared in the runtime environment-input contract. Pattern precedent:
   `validate-no-raw-generated-effective-runtime-reads.sh`.
2. **Env-override invariance negative control.** With protected/hard-enforce
   context bound, set each in-scope `OCTON_*` variable to adversarial values
   and prove authorization decisions, effective policy mode, recorded
   execution role, intent binding, and route-bundle verification outcomes are
   byte-identical to the unset baseline. Also run with a break-glass directive
   active to prove ambient variables do nothing even then. Retained under the
   assurance evidence roots.
3. **Stale route-bundle bootstrap: self-governed positive and negative
   proofs.** With ambient variables absent and the current route bundle
   deliberately stale, prove the publication path completes through the
   explicit receipted publication-bootstrap input **with no human step**
   (preconditions machine-provable: caller identity, stale-tolerance
   necessity, single-publication scope), emits the bootstrap receipt, and
   links it into the publication receipt chain. Then prove the fail-closed
   half: with any precondition unprovable (wrong caller, bundle not actually
   stale, out-of-scope request), the input is automatically denied with a
   reason code and no bypass occurs. Finally prove the ambient variable is no
   longer read anywhere outside declared test fixtures.
4. **Ambient rejection in protected mode.** With a protected/hard-enforce
   context and any in-scope ambient variable present, prove the run fails
   closed with the declared reason code (enforcement phase) or emits the
   warning receipt while remaining decision-invariant (deprecation phase).
5. **Policy-mode explicit-field behavior.** Prove effective policy mode is
   bound only from explicit request/config fields; declared development modes
   (`shadow`, `soft-enforce`) remain selectable through approved config in
   non-protected contexts **without any human approval step**; ambient
   settings produce no mode change in any context.
6. **Execution-role and intent explicit-field behavior.** Prove role identity
   and intent refs are bound from explicit request/config fields, validated on
   the authorization path (`INTENT_MISSING`/`INTENT_REF_INVALID` checks
   retained), and recorded in decision artifacts and receipts as explicit
   inputs.
7. **Ignored/deprecated env var messaging.** Prove presence of each legacy
   variable produces the actionable message (variable name, ignored/rejected
   status, pointer to the explicit replacement), and that warnings are
   receipted so residual usage is measurable during the deprecation phase.
8. **`stage_only_behavior` documentation and bound check.** Prove
   `policy-interface-v1.md` documents the field (variants, default, failure
   behavior) and that no variant path can convert STAGE_ONLY into material
   execution without explicit re-authorization (effects-layer non-ALLOW
   rejection test stays green). Doc-runtime consistency validators pass.
9. **Documentation coverage.** The runtime environment-input contract exists
   in `framework/engine/runtime/spec/`; `policy-interface-v1.md` documents all
   remaining environment inputs; migration/deprecation guidance is published
   before the enforcement flip (migration phase 5 gate).
9a. **Break-glass boundary proof.** Prove true break-glass remains available
   only through the governed human-directive path (rank-1 artifact with
   retained receipt, scope, duration, post-use review), that it is the only
   route that can override a tier-2 automatic denial, and that no ambient
   mechanism can substitute for it.
9b. **Self-governance regression check.** Enumerate the routine operations
   affected by the change (publication, policy-mode selection in permitted
   contexts, role/intent binding, local dev/test flows) and prove none of
   them gains a new manual coordination gate after the ambient variables are
   removed.
10. **Non-authority and no-publication checks (packet lifecycle).**
    `validate-proposal-standard.sh --package <this packet>
    --skip-registry-check` and `validate-architecture-proposal.sh --package
    <this packet>` pass; `validate-input-non-authority.sh` passes; `git status`
    over `.octon/generated/**` shows zero changes from proposal work —
    no generated/effective publication occurs during packet activity
    (registry regeneration is deferred to a governed publication step).
