# Phase 3 — Independent Assurance Review

> Non-authoritative. Adversarial review of BOTH the accepted target design AND the
> reviewer's own Phase 2 migration plan, at commit `c5b1f5760c…`. Four independent
> red-team lanes ran on Opus 4.8[1m]; the lead independently re-verified the
> highest-severity assurance findings against current source. 40 findings total.

## 0. The most important result: the authority *decision function* is candidate-editable

Phase 1 called `authority_engine` "genuinely strong for the kernel paths." Phase 3
**corrects that in a load-bearing way**, and the lead verified it directly:

**`authorize_execution` computes its own Allow/Deny by shelling out to candidate-editable code.**
`execution.rs:2946` calls `compose_policy_receipt`, which at `policy.rs:432` runs
`Command::new("bash").arg(&policy_runner).arg("acp-enforce").arg("--policy").arg(&policy_file)`
where:
- `policy_runner` defaults to `.octon/framework/engine/runtime/policy` — a **repo-tracked, candidate-editable** script (`policy.rs:313`);
- `policy_file` is `.octon/framework/capabilities/governance/policy/deny-by-default.v2.yml` — **repo-tracked, candidate-editable** (`policy.rs:672`);
- the bash runner is spawned **un-sandboxed, in the trusted parent, with inherited credentials**;
- `OCTON_POLICY_RUNNER_OVERRIDE` (`policy.rs:309-313`) accepts an **arbitrary** runner path in production: the guard `!cfg!(test) || override_path.starts_with(&cfg.repo_root)` short-circuits to `true` whenever `cfg!(test)` is false, so the repo-root restriction **never runs outside tests** (verified L1-03).

**Consequence.** The token *verifier* (`verify_authorized_effect`) is strong, but the
*decision* it enforces is produced by candidate-editable inputs and a candidate-editable
(or env-substitutable) runner. A prompt-injected candidate with repo write can edit
`deny-by-default.v2.yml` to emit `decision: Allow`, or point `OCTON_POLICY_RUNNER_OVERRIDE`
at an allow-all binary, and the "canonical authority" issues an ExecutorLaunch/effect for
attacker-chosen scope. The Phase 2 keystone (PP-01: route the agent launch through
`authorize_execution`) therefore does **not** by itself produce an unavoidable boundary —
it routes through an authority whose decision function the candidate controls. This is the
single most important correction this review makes to its own plan, and it is
**BLOCKER_BEFORE_PRIVILEGED_IMPLEMENTATION** (L1-01).

**Repair (folded into PP-01/00, not deferred to PP-08):** treat the ACP policy file and
runner as trust-root — pin them to a base-ref/out-of-tree digest verified inside
`authorize_execution`, or embed the deny-by-default decision logic in the compiled kernel
instead of an in-tree bash runner; add `OCTON_POLICY_RUNNER_OVERRIDE` / `OCTON_POLICY_MODE_OVERRIDE`
to a deny/scrub list on the authority process.

## 1. Bypasses that survive the Phase 2 plan as written

| # | Bypass | Verified? | Class | Fix |
|---|---|---|---|---|
| L1-01 | Authority decision function is candidate-editable (policy file + bash runner + override) | **Lead-verified** | BLOCKER | Pin/compile the decision; scrub override env |
| L1-02 | Second agent spawn `pipeline.rs:1856` guarded only by a *conditional* RepoMutation verify, never ExecutorLaunch | **Lead-verified** | BLOCKER | PP-01 must gate every spawn site, unconditionally |
| L1-03 | `OCTON_POLICY_RUNNER_OVERRIDE` accepts any path in production builds | **Lead-verified** | high | Gate behind `cfg!(test)` or pin digest |
| L1-04 | `OCTON_POLICY_MODE_OVERRIDE`→shadow; `OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE` fails **open** | **Lead-verified** | high | Fail closed; signed exception; enumerate all `OCTON_*` overrides as prohibited |
| L1-05 | `pr-auto-merge.yml` cargo-**builds the enforcer from PR head**; `release-please.yml` a second `AUTONOMY_PAT` plane | CONFIG_DERIVED | REQ_BEFORE_CLASS_B_PUB | Pinned release binary / App; inventory every PAT workflow |
| L1-06 | Base-ref fix has a hole: push-triggered guards use the head's own YAML; in-tree gate params (route order, protected-surface list) editable | STATIC | REQ_BEFORE_TRUST_ROOT | Out-of-tree pin for inventories + route order; inert landing; epoch-0 anchor |
| L1-08 | PP-05 git-sanitization list omits `core.sshCommand`, `credential.helper`, `include.path/includeIf`, `.gitattributes` filter/textconv drivers, `url.insteadOf`, `.gitmodules`, aliases, `gpg.program` | STATIC | medium | Allowlist-clean env, not deny-list; full extension surface in the negative suite |
| L1-09 | Reconcile via bare `git ls-remote` cannot attribute a landed ref to *this* attempt | STATIC | REQ_BEFORE_CLASS_B_PUB | Attempt-bound ref namespace / atomic pre-SHA compare |

The lead accepts all eight. L1-01/02/03/04 were re-derived from source in this session
(`policy.rs:309-343,432`; `pipeline.rs:1369-1393,1856`; `core/config.rs:11`;
`policy_engine/lib.rs:969`). L1-05/06/08/09 are accepted at their stated evidence class.

## 2. What this means for the "one unavoidable boundary" claim

The target's central promise is **exactly one chokepoint** between "agent wants a durable
effect" and "the effect happens." Phase 3 shows the Phase 2 plan, *as written*, leaves at
least four residual privileged paths even after PP-08 completes (L1-07 threat model):
1. the in-tree/overridable authority decision function (L1-01/03/04),
2. the un-gated `pipeline.rs` agent spawn (L1-02),
3. the second credentialed CI plane not fully removed (L1-05, `release-please` + `pr-auto-merge` build-from-head),
4. in-tree self-gate editing on push-triggered guards (L1-06).

**The plan is directionally correct but its scope is incomplete.** Every one of these is a
concrete, additive fix — none requires a redesign — but each must be added to the relevant
packet's scope and acceptance test *before* the "single boundary" claim can be made. The
corrected acceptance criterion is the L1-07 red-team: a prompt-injected candidate with repo
write + inherited creds must be denied at the boundary across **all** of these vectors, not
just the two-plane split, with a journaled denial.

## 3. Self-modified verification and bootstrap trust

Beyond L1-06, the review confirms a genuine **epoch-0 / bootstrap-trust gap**: the base-ref
verifier chain has no external anchor for the very first trusted ref, and the trust-root
inventory + route order live in the candidate-editable tree. FD-018 activation cannot be
sound until (a) an explicit trust-root inventory is pinned out-of-tree, (b) an operator-
anchored epoch-0 bootstrap is defined (OD-08), and (c) trust-root edits land **inert** so a
post-merge push guard is never the only control. This is REQUIRED_BEFORE_TRUST_ROOT_AUTOMATION.

## 4. Degraded-mode fail-open

The `OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE` path fails **open** — it substitutes the
FD-020 digest verification with a publication *bypass* (`execution.rs:2013-2044`,
`core/config.rs:11`). Combined with credential inheritance (agents see the env today), the
one dynamically-provable strength (FD-020 digest binding) can be switched off from the run
environment. Phase 2 §3.5 hardened only this one var; Phase 3 requires **all** `OCTON_*`
override/bypass vars be enumerated as prohibited and made fail-closed (L1-04).

## 5. Net assessment

The adversarial pass **confirms the migration's direction and materially sharpens its
scope**. The strengths hold (single-use verifier, digest-bound factory, adapters). But the
review's own Phase 1 was too generous about the authority plane, and its Phase 2 keystone
was under-scoped: closing the two-plane split is necessary but not sufficient. The corrected
scope (pin the decision function; gate every spawn; fail-closed env; remove — not narrow —
the second CI plane; full git-extension allowlist; attempt-bound reconcile) is what makes the
"one unavoidable boundary" claim honest. These corrections are captured as blockers in
`implementation-readiness-gates.yml` and as the L1-07 red-team in `proof-of-architecture.md`.
