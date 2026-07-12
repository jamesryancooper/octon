# Proof of Architecture

> Non-authoritative. The minimum executable proof that the target boundary is real,
> corrected by the Phase 3 adversarial findings. Reviewed commit `c5b1f5760c…`.

## The single artifact that proves the boundary

One integration test, green end-to-end, composed of the fault sub-assertions so the boundary
is proven **under fault, not just on the happy path**:

```
operator intent
  → digest-bound harness factory (runtime_resolver; drift denied — F11)
  → authorize_execution grant   ← decision function PINNED (F13): candidate cannot edit
                                    deny-by-default.v2.yml / runner / override env
  → ONE-SHOT ExecutorLaunch verified at EVERY spawn site (F14): lifecycle_executor AND
     pipeline.rs; spawn DENIED without a valid, unconsumed, unrevoked token
  → credentialless (F9: sentinel absent, gh unauth on BOTH paths),
     seatbelt-sandboxed candidate in a disposable worktree (F10: 4 escapes denied,
     canonical refs byte-identical)
  → agent edits/tests/commits in isolation, NO ambient credentials
  → the ONLY durable effect is a brokered exact-SHA branch-no-PR push:
       broker holds creds, runs sanitized git (F15: extensions neutralized),
       refuses on target-race (F5) and attributes the attempt (F16)
  → transactional reserve→consume→terminal in the store:
       concurrent consume exactly-once (F1); 4 kill-points both-or-neither (F2);
       revocation wins the race (F6)
  → mid-flight kill reconciles clean: push-landed/record-lost → zero re-push (F3);
       duplicate dispatch → one effect (F4)
```

**PASS iff:** the spawn is denied without a verified ExecutorLaunch; with it, the candidate is
credentialless and sandboxed; the only durable effect is the brokered exact-SHA push; a
target-race is refused; a mid-flight kill reconciles with no double effect; **and** a
prompt-injected candidate with repo write cannot alter the authority decision, reach an
un-gated spawn, set an override env var, edit its own gate, or execute a git extension (the
L1-07 red-team, all six vectors denied with a journaled denial).

## Required demonstrations (corrected)

Beyond the intake's list, Phase 3 adds four that the plan-as-written missed:
- Candidate cannot edit the `authorize_execution` Allow/Deny (policy file / runner / override) — **new, BLOCKER (L1-01)**.
- **Every** spawn site (not just lifecycle_executor) is dominated by ExecutorLaunch — **new (L1-02)**.
- Reconcile attributes a landed ref to *this* attempt, not a bare `ls-remote` — **new (L1-09)**.
- The second credentialed CI plane is removed, not narrowed (build-from-head enforcer, release-please) — **new (L1-05)**.
Plus the intake's: no push/creds from candidate; missing/forged/revoked/expired/mismatched
authority fails; duplicate → one effect; git hooks/config cannot execute under broker privilege;
candidate cannot redefine the verifier; source/target SHA mismatch blocks or escalates; crash
after uncertain result reconciles before retry; missing terminal evidence blocks success;
candidate work preserved during provider outage.

## Prerequisite packets

Per `proposal-program-packet-map.yml`: PP-01, PP-02, PP-03, PP-04, PP-05, PP-06, PP-07 —
**plus the BLOCKER corrections** G-B1..G-B5 (pinned decision, full git allowlist, fail-closed
env, honest claims, credential inventory) which must precede privileged work. With L2's
simplifications, the net-new component count for this proof is **~3** (broker=store+git+creds
as one process, isolation launcher, and the exact-SHA registration inside the broker) plus a
provider-delegated verifier — not a large build.

## Explicit non-goals

The proof does **not** cover, and must not claim: federation/multi-project continuity;
distributed consensus; signing-key management (git-anchoring is the default evidence property —
OD-01 B); Linux sandbox parity; native Windows; off-git tamper-evidence; complete sandbox
un-escapability (F10 proves tested classes only); real-disk capacity (F7 is DEPLOYMENT_LOCAL);
out-of-tree verifier immutability beyond the operator's App/protected-repo configuration
(CONFIGURATION_DERIVED). These are the honest limits recorded in `residual-risk-register.yml`.

## Why this is the right proof for a solo builder

It is one integration test on one macOS machine against one scratch remote. It proves the
*whole* boundary (authorize → guard → isolate → broker → verify → land → reconcile) under the
realistic adversary (a misbehaving candidate), using the cheapest faults that exercise each
link. It requires no infrastructure the operator must run, and every sub-assertion maps to an
exact current code location (see `fault-injection-plan.md`), so it can be written incrementally
as each packet lands and composed at PP-07. FD-020's digest-drift deny (F11) is the one piece
already provable today and should be run first as a cheap confidence anchor.
