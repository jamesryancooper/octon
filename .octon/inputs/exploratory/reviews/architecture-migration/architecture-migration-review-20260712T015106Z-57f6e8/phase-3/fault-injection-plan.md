# Fault-Injection and Proof Plan

> Non-authoritative. The executable fault-injection / kill-point / concurrency plan
> that would prove the target's runtime-correctness decisions. Each fault maps to an
> exact current code location (so the test can be written against the migrated code
> at that site) and states the pass assertion. None have been executed in this
> review — they are DESIGNED, not run (evidence_classification would become
> DYNAMICALLY_EXECUTED / ADVERSARIALLY_TESTED only after execution).

## Injection points mapped to current code

| ID | Property | Fault | Injection point (current) | Pass assertion |
|---|---|---|---|---|
| F1 | FD-012 single-use exactly-once | 8 concurrent `verify_authorized_effect` on one single_use token | `effects.rs:564` check vs `:658` persist (TOCTOU) → future SQLite CAS | Exactly 1 VerifiedEffect; 7× ALREADY_CONSUMED; row `consumption_count==1` |
| F2 | FD-005 both-or-neither | SIGKILL at 4 points: pre-reserve, post-reserve/pre-effect, post-effect/pre-record, post-record | `effects.rs:576` append, `:605` consumed-event, `:658` persist; `policy.rs:86` bare fs::write | Store both-or-neither; every state file parses; one `pending` attempt at point 3 |
| F3 | FD-012 unknown-outcome reconcile | push succeeds on remote, SIGKILL before terminal record | git push `lifecycle_program.rs:19499/19518`; exact-SHA `:5968` | Reconcile via ls-remote marks LANDED; **zero** re-push (push-counter==0) |
| F4 | FD-012 idempotency | duplicate dispatch (same idempotency_key), incl. across restart | entry to `verify_authorized_effect` before `effects.rs:576` | External-effect counter==1; 2nd returns recorded outcome |
| F5 | FD-011 target-race | advance target ref after authorize, before broker push | exact-SHA `lifecycle_program.rs:5968`, push `:19499` | Push REFUSED (target-race); remote ref unchanged; ends failed-safe |
| F6 | FD-004 revocation race | revoke mid-flight, and after check-passed/before-effect | revocation load `effects.rs:482-498` vs consume `:564-658` | No external effect under any interleaving where revoke commits first |
| F7 | FD-013 near-full disk | fill FS to a few KB, drive denial/failure/revocation/rollback/closeout | write path `effects.rs:1154`, `policy.rs:86` (no ENOSPC handling) | Un-reservable op DENIED up-front; reserved op always writes a parseable terminal record |
| F8 | FD-017 same-change self-cert | PR edits its own validator to `exit 0` + touches trust-root | self-dev/trust-root merge gate (PP-08); today gates run PR head | Weakened-validator PR BLOCKED by base-ref verifier; edit inert pre-activation |
| F9 | FD-006 credential scrub (negative) | sentinel secret + fake GH_TOKEN in parent; child dumps env, runs `gh auth status` | agent spawn `codex.rs:254` via `:416` (no env_clear today); **also** `pipeline.rs:1856` | Child env lacks sentinel/GH_TOKEN/SSH_AUTH_SOCK; `gh auth status` FAILS — on BOTH spawn paths |
| F10 | FD-008 sandbox escape (negative) | write outside worktree; disallowed socket; mutate canonical .git; read parent env | spawn `codex.rs:254`, `--cd repo_root` `:433/463`; no sandbox today | All 4 denied by runtime-applied sandbox; canonical refs byte-identical |
| F11 | FD-020 digest-drift deny | mutate a bundle input so digest ≠ pin | `runtime_resolver` digest binding (UF-04) | Resolver returns CAPABILITY_DENIED (executed); forbidden consumer denied |
| F12 | FD-018 activation rollback | fault at pre-validate / mid-swap / post-swap; + self-widening activation | new inert-landing + staged activation controller (PP-08) | Every fault → {old healthy, new healthy, rolled-back-to-old}; self-widen FAILS |

## Additional faults surfaced by the assurance lane (add to the suite)

| ID | Property | Fault | Pass assertion |
|---|---|---|---|
| F13 (L1-01) | Authority decision integrity | mutate `deny-by-default.v2.yml` to Allow-all; separately replace the policy runner; separately set `OCTON_POLICY_RUNNER_OVERRIDE=/tmp/allow_all` | `authorize_execution` DENIES because policy/runner digest ≠ base-ref/out-of-tree pin; override ignored in release build |
| F14 (L1-02) | Complete spawn mediation | run `pipeline.rs` path with `stage_repo_effect=None` and a missing/revoked grant | No Codex/Claude spawn occurs without a verified ExecutorLaunch |
| F15 (L1-08) | Git extension neutralization | plant `include.path`, `.gitattributes` filter/textconv, `url.insteadOf`, `core.sshCommand` | None execute when broker runs push/fetch/checkout |
| F16 (L1-09) | Attempt attribution | crash push-landed/record-lost **with a concurrent actor advancing the ref** | Reconcile classifies this attempt by `attempt_id`, not bare head; no false success/double-push |
| F17 (L1-05) | Single-plane merge | PR rewrites `protected-ci-auto-merge.sh` / kernel protected-ci to always-merge | Cannot self-merge; enforcer runs from a pinned out-of-tree artifact |

## Fault-injection harness requirements

- **Kill-point control:** a test shim that can `SIGKILL` the process at a named
  instrumentation point (feature-gated `panic!`/`abort` hooks around the four F2 points).
- **Concurrency driver:** spawn N threads/processes against one token/attempt (F1, F6).
- **FS constraint:** a loopback/quota-limited volume for F7 (DEPLOYMENT_LOCAL — see residual).
- **Remote fixture:** a scratch bare repo the broker pushes to, with a push call-counter
  for F3/F16 and ref-advancement for F5.
- **Env fixture:** sentinel secrets in the parent for F9; override vars for F13.
- **Determinism:** no `Date.now()`/random in assertions; keyed by attempt_id/token_id.

## Ordering

Runnable once the owning packet lands: F13/F14 with PP-01; F9/F10 with PP-02; F1/F2/F7 with
PP-03; F3/F4/F5/F6/F16 with PP-07; F8/F12/F17 with PP-08; F11 with PP-10 (cheapest — it is
the one fault a solo builder can execute today to upgrade FD-020 to DYNAMICALLY_EXECUTED).
The proof-of-architecture integration test (P1) composes F1+F3+F5+F9+F13+F14 into one green
end-to-end run.

## Honest limits (see residual-risk-register.yml)

- **F7 is DEPLOYMENT_LOCAL** — it proves the code reserves/denies, not the operator's real disk.
- **F10 is a regression suite of KNOWN escape classes** — it proves denial of tested paths,
  never absence of all escapes (a negative existential).
- **F8/F17 immutability is CONFIGURATION_DERIVED** — only as strong as the operator's
  GitHub App / protected-repo setup.
These must be labeled with their achievable evidence class, not presented as complete proofs.
