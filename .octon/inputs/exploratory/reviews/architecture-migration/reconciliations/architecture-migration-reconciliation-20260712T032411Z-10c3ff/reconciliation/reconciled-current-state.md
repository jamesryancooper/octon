# Reconciled Current State

## Normalized baseline

Both original reviews inspected clean `main` at commit `c5b1f5760c78ff521cca6b054e4e8fef5300505b` (commit time `2026-07-11T16:56:55-05:00`). That commit is the comparison baseline. The current Git-visible tree remains clean outside the allowed review/reconciliation tree; ignored caches were not exhaustively fingerprinted.

## Committed repository facts

- `authority_engine` contains typed grants/effects, expiry/revocation fields, `ExecutorLaunch`, and useful verification semantics.
- Lifecycle, pipeline, workflow, and workflow-leaf paths can create model/material processes without universally consuming one exact canonical launch guard. Lifecycle also applies its own `DelegationProof`/unattended authorization.
- Typed scope matching accepts reverse and non-component-boundary prefixes, so an authentic narrow scope can match a parent or sibling prefix.
- Canonical authorization shells repository-relative policy/receipt code and uses repository policy data. Production reads `OCTON_POLICY_RUNNER_OVERRIDE`, `OCTON_POLICY_BIN`, `OCTON_POLICY_MODE_OVERRIDE`, and `OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE`; these can select or weaken decision behavior when the authority process environment is controlled.
- Candidate executors use credential-capable host context and canonical repository/Git state. This proves exposure capability, not presence or use of any specific secret.
- No accepted separate local credential broker exists. The existing `policy-grant-broker.sh` is an ephemeral loose-file helper, not the FD-006 broker.
- No one SQLite/WAL store owns grants, operations, reservations, attempts, revocation, evidence outbox, reconciliation, and recovery. Current lifecycle state spans files and append operations without one transaction.
- Autonomous direct-main is selected before branch-no-PR in the default route contract. Current hosted Git helpers use ambient Git rather than a broker-owned sanitized adapter.
- Current no-PR helpers contain useful source-SHA, clean-tree, ancestry, ordinary non-force push, and synchronous post-push equality checks. Their target-pre check is check-then-push rather than an atomic server-observed expected-old update, and they do not persist a crash-safe attempt/reconciliation state.
- `pr-auto-merge.yml` uses a write credential and later executes candidate-head repository code. `release-please.yml` is another PAT/write plane. Required provider check producers are repository/candidate controlled.
- Evidence includes useful hash-linked journals and retention concepts, but accepted producer signatures, signed monotonic checkpoints, same-transaction capacity reservation, bounded raw retention, and compaction/old-snapshot proof are incomplete.
- `promotion_blockers()` has inspect/apply callers and is reusable scaffolding, but the current path does not enforce inert trust-root installation, previous-version certification, exact-version staged activation, health monitoring, or automatic rollback.
- A minimal Project Profile/locality surface, task-harness schemas, digest-bound global route bundle, runtime resolver, provider adapter manifests, extension publication/quarantine, and child scheduling/budget concepts exist. They do not complete Workspace Projects, the full per-run Harness Factory, semantics-preserving provider replacement, signed catalog import, or credentialless bounded child agents.
- Live host/model adapter manifests contain fields that drift from their strict schemas, while the current structural validator largely checks that schemas exist; lifecycle dispatch still switches on executor strings rather than consuming a uniform adapter identity.
- Child concurrency, step/retry/timeout bounds, locks, cancellation, process termination, terminal observations, and token measurement are useful. Hard token/cost enforcement, canonical child identity retirement, exact guards, credentialless isolation, narrow scope, and delegation depth are incomplete.
- The baseline tracks 40,366 files under `.octon/state`; the repository has 42 GitHub workflow files. These are maintenance inputs, not proof that every file/workflow is unnecessary.

## Working-tree observations

- Repository `HEAD` and `origin/main` are equal at the normalized commit.
- Tracked and staged content outside the allowed reconciliation/review tree is clean.
- Untracked content is confined to `.octon/inputs/exploratory/reviews/` during this process.
- The live filesystem contains additional ignored/local state; it is deployment-local and not part of the normalized committed baseline.

## Provider observations

Read-only evidence captured during Review A observed GitHub ruleset `12881449` on `main` with no bypass actors, deletion and non-fast-forward restrictions, linear history, and four strict required checks. It observed no pull-request rule. The required context names were produced by candidate-repository workflows, and the same context name appeared under different event/workflow circumstances; this demonstrates ambiguous context identity, not a proven ruleset bypass.

Actions were enabled with repository secret names including `AUTONOMY_PAT`, `OPENAI_API_KEY`, and `ANTHROPIC_API_KEY`; values were not read. Preview/Production environments had no protection rules and allowed administrator bypass. These observations are point-in-time and do not prove current deployment state after the captured timestamp.

## Architectural inferences

- The absence of one transaction creates credible double-consume, torn-state, and resurrection risks, but the original tests did not dynamically reproduce all such failures.
- Same-UID Unix socket credentials alone would not authenticate a broker request against an untrusted candidate running as the same operator; application/OS identity plus one-shot broker-side validation is required.
- A linked worktree alone cannot satisfy independent Git-state isolation because it shares the repository common directory/object state.
- A provider-native GitHub App or protected verifier repository is likely the smallest verifier/effect-worker implementation if it passes Octon conformance; no particular provider mechanism is yet selected or proved.

## Missing proof

The baseline does not dynamically prove universal launch dominance, a useful credentialless primary-provider session, macOS sandbox resistance, SQLite concurrency/crash safety, hostile Git sanitization, atomic provider CAS, causal attempt attribution, verifier identity, signed evidence authenticity/compaction, trust activation rollback, full Harness Factory binding, provider replacement, extension signing, child delegation depth, two-project/inbox continuity, continuous maintenance/reversible effect, or the target completion/speed/setup/prompt/recovery/maintenance budgets.
