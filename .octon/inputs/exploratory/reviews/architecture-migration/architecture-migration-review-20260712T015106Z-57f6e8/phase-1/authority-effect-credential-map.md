# Authority, Effect, and Credential Map (current repository)

> Reviewed commit `c5b1f5760c78ff521cca6b054e4e8fef5300505b`. All rows are
> CURRENT_REPOSITORY_FACT (STATICALLY_INSPECTED) unless marked. This supersedes
> the intake's inherited map with fresh-baseline evidence.

## Authorization surfaces (who can make an authorization-like decision)

| Surface | Role today | Canonical? | Evidence |
|---|---|---|---|
| `authority_engine::authorize_execution` | Produces `GrantBundle`; verifies route-bundle freshness, intent, policy-mode vs environment, executor profile, write scope | **Yes, for kernel paths** | `execution.rs:2000-2216` |
| `authority_engine::verify_authorized_effect` | Single-use effect-token verifier (decision/id/kind/scope/digest/expiry/revocation/budget/egress + consume) | **Yes** — the strong primitive | `effects.rs:210-667` |
| `lifecycle_executor::authorize_before_dispatch` | Self-writes a `DelegationProof` from caller-supplied `invocation_authority`; **no** authority_engine call | **No — competing plane** | `authorization.rs:39-151`; `adapter.rs:109` |
| GitHub Actions `pr-auto-merge.yml` | Decides merge eligibility via PR-head-checked-out shell scripts; holds `AUTONOMY_PAT`; cron + `pull_request_target` | **No — second credentialed CI plane** (CONFIGURATION_DERIVED) | `pr-auto-merge.yml:1-333` |
| `change-route-projection.yml` jobs | The four required status checks that gate main; live in candidate tree | **No — candidate authors own verdict** (PROVIDER_OBSERVED for ruleset) | `change-route-projection.yml:124-167`; live ruleset C-006 |
| `kernel commands/trust.rs` `trust_domain_add` | Flips domain `blocked→stage_only` on presence of any `--approval-ref` string | Presence-only, not validated | `trust.rs:297-341` |
| `OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE` env | Substitutes route-bundle freshness verify with a bypass branch | Env-driven softening of the gate | `execution.rs:2013-2044` |

## Durable-effect writers (every physical mutation path of note)

| Effect | Executed by | Gated by canonical authority? | Evidence |
|---|---|---|---|
| Agent process launch (Codex/Claude) | `lifecycle_executor` `codex.rs`/`claude.rs`; pipeline `run_with_stdin` | **No** (self-attested proof only; studio launch is the sole ExecutorLaunch-gated spawn) | `codex.rs:254,416-452`; `pipeline.rs:1846-1866`; `commands/mod.rs:736` |
| `git commit` / branch land / push | Shell helpers under `execution-roles/_ops/scripts/git/`; kernel `workflow.rs` `Command::new("git")` | Partially (kernel effects gated; agent-run git not); unsanitized config | `git-branch-commit.sh:104`; `workflow.rs:4853,5601,5713` |
| Managed git hooks (post-merge/post-checkout) | Installed into `.git/hooks`; run `git-pr-cleanup.sh` (ff-merge, ref writes) | **No** — run outside any authorization envelope | `git-autonomy-hooks-install.sh:30-133` |
| PR auto-merge | `protected-ci-auto-merge.sh` → gated Rust `protected-ci auto-merge` | Terminal merge gated; eligibility candidate-influenceable | `pr-auto-merge.yml:285-333`; `commands/mod.rs:1413-1573` |
| Kernel command/workflow/pipeline subprocesses | kernel | **Yes** — `authorize_execution` + `verify_authorized_effect` | `commands/mod.rs:610-968`; `workflow.rs:794,952` |
| Authority/grant/token/decision state writes | authority_engine | Non-atomic `fs::write` (no fsync/rename) | `policy.rs:81-97`; `authority.rs:412` |
| Release binaries | `runtime-binaries.yml` (unsigned, from HEAD) | No signing/preauthorized activation | `runtime-binaries.yml:122-182` |

## Credential custody (where durable secrets live and who reaches them)

| Credential | Custody today | Reachable by candidate agent? | Evidence |
|---|---|---|---|
| `GITHUB_TOKEN`/`GH_TOKEN` (gh keychain) | Host `gh` keychain / ambient env; `connector-credentials.yml` declares `externally_managed`, `default_route: deny` | **Yes** — inherited via unscrubbed env at spawn | `codex.rs:416-452`; `connector-credentials.yml:1-35` |
| SSH agent (`SSH_AUTH_SOCK`) | Host session; inherited | **Yes** — not scrubbed | B-06 |
| Provider API keys (ANTHROPIC/OPENAI) | Ambient env | **Yes** — not scrubbed | J-02 |
| `AUTONOMY_PAT` | GitHub Actions secret | Only in CI, but usable by PR-head scripts under `pull_request_target` | `pr-auto-merge.yml:23-25` |
| Signing key | **None exists** | n/a — no signing anywhere | E-01 |
| Octon-owned vault/keyring | **None exists** (no keyring crate dependency) | n/a | B-06 |

## Target owner mapping (for Phase 2)

| Surface | Target owner |
|---|---|
| `lifecycle_executor` launch | Consumes canonical grant + one-shot ExecutorLaunch effect; retires self-attesting DelegationProof to evidence-only |
| Candidate agent | Credentialless, in an OS-sandboxed disposable environment with isolated Git state |
| Durable credentials | Single local credential-holding broker (separate process); agents credentialless by construction |
| Git | Sanitized broker-owned config + narrow command surface; no hooks/includes/filters |
| Exact-SHA verifier | Candidate-immutable, out-of-tree, keyed to a pre-registered SHA |
| Evidence | Broker/verifier-signed checkpoints (or FD-014 reworded to "hash-chained + git-anchored") |
| Trust root | Previous-version verifier + separate proof-gated staged rollback-capable activation |

**Bottom line:** the canonical authority is real and strong but does not dominate
the agent-launch effect; no broker or credential boundary exists; the only hard
provider boundary is the main ruleset, whose semantic checks are candidate-authored.
