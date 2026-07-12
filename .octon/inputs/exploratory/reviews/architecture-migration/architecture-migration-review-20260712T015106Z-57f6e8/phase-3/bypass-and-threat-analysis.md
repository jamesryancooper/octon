# Bypass and Threat Analysis

> Non-authoritative. Threat model: the attacker is a **prompt-injected or misbehaving
> candidate agent** with (today) repo write access and inherited ambient credentials.
> This is the realistic Octon adversary — not an external network attacker. Reviewed
> commit `c5b1f5760c…`.

## Attacker capability TODAY (before migration)

The candidate agent can, at HEAD, perform each of the following with cited evidence:

| # | Capability | Mechanism | Evidence |
|---|---|---|---|
| T1 | Push/merge/deploy with operator credentials | No `env_clear` at any spawn; child inherits `GH_TOKEN`/`GITHUB_TOKEN`/SSH | `codex.rs:416-452`, B-01/J-02 |
| T2 | Grant itself any authority | Edit `deny-by-default.v2.yml` (or the policy runner) so ACP returns `Allow` | `policy.rs:432,672`, L1-01 |
| T3 | Substitute/soften the authority | `OCTON_POLICY_RUNNER_OVERRIDE` (prod-unrestricted), `OCTON_POLICY_MODE_OVERRIDE`→shadow, `OCTON_ALLOW_STALE_…`→fail-open | `policy.rs:309`, `policy_engine/lib.rs:969`, `core/config.rs:11`, L1-03/04 |
| T4 | Execute code under operator creds via git | Plant hooks / `.gitattributes` filter / `credential.helper` / `url.insteadOf` — git runs unsanitized | `workflow.rs:4853/5713`, C-001/C-002, L1-08 |
| T5 | Self-certify its own PR merge | `pr-auto-merge.yml` cargo-builds the enforcer from PR head under `AUTONOMY_PAT` | `pr-auto-merge.yml`, L1-05 |
| T6 | Commit directly on main | `route_selection_order` lists `direct-main` first | `default-work-unit.yml:299`, C-005 |
| T7 | Spawn agents unmediated | `pipeline.rs:1856` and `lifecycle_executor` spawn with no ExecutorLaunch guard | L1-02, A-02 |

This is a **fully permeable boundary** today: T1–T7 each let the candidate reach durable,
consequential effects outside any enforced authorization. That is the honest current-state
security posture, and it is why the migration is worth doing.

## Residual attacker capability AFTER the Phase 2 plan *as written*

The migration closes T1 (env_clear + broker), T6 (route order), and most of T4/T5/T7 — but
the adversarial pass shows four vectors survive unless scope is extended:

| Survives | Why the plan-as-written misses it | Corrective packet |
|---|---|---|
| T2 (edit the decision) | PP-01 routes through `authorize_execution`, but that function's decision input is candidate-editable (L1-01); PP-08 base-ref gates are merge-time, not the runtime authorize path | PP-01 must pin/compile the decision |
| T3 (override env) | Phase 2 §3.5 hardened only the stale-bundle var; the policy-runner/mode overrides are unlisted | PP-01/PP-02 env deny+scrub list |
| T7-partial (pipeline spawn) | PP-01 named only `lifecycle_executor` | PP-01 must gate `pipeline.rs:1856` too |
| T5-partial (second CI plane) | PP-06 narrows `pr-auto-merge` but not the cargo-build-from-head enforcer or `release-please` | PP-06 pins the enforcer; inventories every `AUTONOMY_PAT` workflow |

**Corrected boundary definition.** "One unavoidable boundary" is achieved only when a
red-team candidate cannot: (i) alter the `authorize_execution` decision, (ii) reach any
un-gated spawn, (iii) set a policy-override env var that changes a decision, (iv) edit its
own merge/route gate, (v) execute code via a git extension point, or (vi) push/merge with
inherited credentials. The pass criterion is the enumerated set, not the two-plane split.

## Git extension-point surface (the full list PP-05 must cover — L1-08)

`--no-verify` + `hooksPath=/dev/null` covers hooks only. The candidate also controls, via
repo-local `.git/config` (through `include.path`/`includeIf`) and worktree files:
`core.sshCommand`/`GIT_SSH_COMMAND`, `credential.helper`, `.gitattributes` clean/smudge/
filter/diff/textconv drivers, `url.<base>.insteadOf`, `core.editor`/`sequence.editor`,
`core.pager`, `uploadpack.packObjectsHook`, `core.alternateRefsCommand`, `.gitmodules`
submodule URLs, `alias.*`, `gpg.program`. The broker's git must run with an **allowlist-clean
environment** (`GIT_CONFIG_NOSYSTEM=1`, `GIT_CONFIG_GLOBAL=/dev/null`, `GIT_CONFIG_SYSTEM=/dev/null`,
`GIT_ATTR_NOSYSTEM=1`, explicit `-c` clearing of the above) and refuse to operate on a
working tree containing candidate-authored `.gitattributes`/`.gitmodules` until re-validated.

## Second-control-plane inventory (must be a single credentialed plane — FD-006)

The broker must be the *only* credentialed durable-effect plane. The GitHub Actions plane
is not fully removed by PP-06 as written: `pr-auto-merge.yml` (build-from-head enforcer),
`release-please.yml` (`contents:write` + `AUTONOMY_PAT` on push-to-main), and any other
`AUTONOMY_PAT` workflow (`autonomy-release-health`, `pr-triage`, `pr-clean-state-enforcer`)
each constitute a credentialed plane. PP-06 must inventory all of them and prove none can be
edited by a candidate to change its own merge/publish outcome, or the single-broker invariant
(and the "no second control plane" out-of-scope rule) is violated.

## Summary

The migration converts a fully-permeable boundary (T1–T7 all open) into a boundary with a
small, enumerable residual — **provided** the four scope extensions above are added. Without
them, the "single unavoidable boundary" claim would be overstated at PP-08 completion (L1-07).
With them, the residual reduces to the honestly-unprovable existential/deployment items in
`residual-risk-register.yml` (sandbox completeness, out-of-tree config correctness, off-git
tamper-evidence).
