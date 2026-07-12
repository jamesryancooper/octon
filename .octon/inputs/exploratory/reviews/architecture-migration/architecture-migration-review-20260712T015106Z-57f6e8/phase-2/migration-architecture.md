# Phase 2 — Migration Architecture (smallest safe path)

> Research and decision input only. Non-authoritative. Grounded in Phase 1
> evidence at commit `c5b1f5760c78ff521cca6b054e4e8fef5300505b`. This designs the
> **smallest** migration that produces testable improvements; it does not redesign
> Octon and preserves every working primitive.

## 0. Governing insight that shapes the whole migration

Phase 1 established one dominant fact: **Octon already contains the correct
authorization primitive** (`authority_engine::verify_authorized_effect`, a
single-use, deny-by-default, digest-bound effect-token verifier) and **already
applies it correctly on the kernel command/workflow/pipeline paths**. The gap is
that the highest-consequence effect — launching a credentialed autonomous agent —
runs on a *separate self-attesting plane* (`lifecycle_executor::authorize_before_
dispatch`) that has no dependency on the authority engine.

Therefore the migration is **not a rewrite**. It is: (1) route the one ungated
effect through the existing primitive, (2) add the few missing runtime components
(broker, isolation, transactional store) the target needs, and (3) correct
overstated claims and inverted route ordering. The strengths (harness factory,
adapters, extension catalog, promotion_blockers reader) are preserved intact.

## 1. Target component set vs current reality

| Target component (intake) | Current status | Migration verb |
|---|---|---|
| Octon CLI + mission inbox | CLI exists; no cross-project inbox | Extend |
| Workspace Project + mission state | Singleton Profile; no durable project identity | Add (minimal, non-authority) |
| Deterministic Harness Factory | **Exists, digest-bound, resolver-enforced** | Preserve |
| Authority engine | Strong for kernel paths | Preserve + extend to agent launch |
| SQLite/WAL runtime store | **Absent** (loose YAML/NDJSON) | Add |
| Credentialless candidate launcher | Spawns in canonical repo, inherits creds | Replace launcher; add isolation |
| Local broker | **Absent** | Add |
| Sanitized Git adapter | Unsanitized; hooks installed | Add + retire hook-install |
| Optional GitHub effect worker | Broad PAT in candidate-editable workflow | Modify (scope App) or mark optional |
| Independent exact-SHA verifier | Candidate-editable checks | Replace (move out-of-tree) |
| Signed evidence/checkpoints | **No signing exists** | Add signing OR reword claims |
| Trust activation + rollback controller | Advisory CLI, unwired | Add enforcement + inert landing |

Net new components: **broker, transactional store, isolation launcher, sanitized
git adapter, out-of-tree verifier, signing (or claim correction), trust-activation
enforcement.** Everything else is preserve/extend.

## 2. The target boundary in one picture

```
operator intent
  -> Workspace Project + mission (identity only, never authority)
  -> Harness Factory compiles digest-bound effective manifest      [PRESERVE]
  -> authority_engine::authorize_execution issues a GrantBundle     [PRESERVE]
  -> ONE-SHOT ExecutorLaunch effect issued + verify_authorized_effect  [EXTEND primitive to this path]
  -> credentialless candidate launched in OS-sandboxed disposable env
       with isolated Git state (separate GIT_DIR/worktree)          [ADD]
  -> agent edits/tests/commits in isolation; NO ambient credentials [ADD env_clear+broker]
  -> durable effects (push/merge/deploy) requested from LOCAL BROKER [ADD]
       broker holds credentials; runs sanitized git; verifies exact  [ADD]
       source SHA + target pre-SHA via candidate-immutable verifier  [REPLACE]
  -> default: verified branch-no-PR landing; escalate to PR on risk  [MODIFY route order]
  -> transactional store records reserve->consume->outcome->terminal [ADD]
  -> signed (or git-anchored) bounded evidence + reconciliation      [ADD/reword]
  -> trust-root changes land inert; separate proof-gated activation  [ADD]
```

The critical property: **there is exactly one unavoidable chokepoint between "agent
wants a durable effect" and "the effect happens" — the local broker, which alone
holds credentials and alone runs sanitized privileged git, and which refuses any
effect lacking a verified one-shot authorization.** This is the single boundary the
whole target rests on.

## 3. Migration by area (preserve / extend / modify / replace / retire / add)

### 3.1 Canonical authority unification (FD-003, FD-004) — the keystone
- **Preserve** `authorize_execution` + `verify_authorized_effect` verbatim.
- **Modify** `lifecycle_executor` to depend on `authority_engine` and, immediately
  before `build_executor_command` spawns Codex/Claude, issue an `ExecutorLaunch`
  effect from the active grant and `verify_authorized_effect` (single_use); abort
  on any rejection.
- **Retire** the self-attesting `DelegationProof` as *authority*: demote it to
  evidence-only annotation (its fail-closed governance checks — contract,
  evidence-gate, context-binding, HumanBoundaryRequired — are valuable and are
  **preserved**, but subordinated to the canonical grant).
- **Make it unavoidable**: turn the `side_effects` INVENTORY (`ExecutorLaunch`
  currently `dead_code`) into an enforced invariant — a test/assertion that every
  material class is reached only via a verified effect.

### 3.2 Credentialless native isolation (FD-006, FD-008)
- **Add** `Command::env_clear()` + explicit non-credential allowlist at *both*
  spawn paths (lifecycle_executor and the authority_engine/pipeline path — B-03).
- **Add** a runtime-owned macOS `sandbox-exec` (seatbelt) / App Sandbox profile
  applied at spawn (not the executor CLI's self-declared flag); refuse to launch on
  unsupported platforms; Linux experimental.
- **Add** isolated Git state: launch candidate work in a disposable worktree/clone
  with a separate `GIT_DIR`; canonical refs/objects unchanged until brokered
  promotion. **Preserve** the existing worktree-hygiene classifier as a backstop.

### 3.3 Local broker + credential migration (FD-006, FD-009, FD-007)
- **Add** one local credential-holding broker (separate process). It alone holds
  durable credentials and exposes a narrow typed effect surface (push, land, merge,
  deploy). Agents call it without ever receiving raw secrets.
- **Add** the sanitized git adapter *inside the broker*: all credentialed git runs
  with `GIT_CONFIG_NOSYSTEM=1`, `GIT_CONFIG_GLOBAL=/dev/null` (or broker-owned
  config), `-c core.hooksPath=/dev/null`, `-c core.fsmonitor=false`,
  `-c protocol.*.allow=never`, `--no-verify`. A validator fails any git call that
  bypasses the adapter.
- **Retire** `git-autonomy-hooks-install.sh` managed hooks; move the post-merge
  cleanup convergence into an explicit authorization-gated command.
- **Keep** credentials externally managed (gh keychain) per `connector-credentials.yml`
  — the broker interposes so agents cannot reach them, rather than Octon becoming a
  vault. FD-007's scoped App is **optional**; if adopted, mint a least-privilege
  single-repo App and keep its policy code out of the candidate tree.

### 3.4 Transactional runtime store (FD-005, FD-012, FD-013)
- **Add** one embedded transactional store (rusqlite + WAL) as the authoritative
  substrate for grants, effect tokens, operation attempts, reservations, revocation,
  reconciliation. **One writer, local, no external infrastructure** — this is the
  minimum-complexity choice, not a distributed ledger.
- **Modify** single-use consume to a transactional CAS (`UPDATE ... WHERE
  status<>'consumed'`), closing the TOCTOU (D-02/J-04).
- **Add** an attempt lifecycle: record `pending` before an external effect, outcome
  after; on restart, reconcile each `pending` with an idempotent probe (e.g. `git
  ls-remote` — did the ref land?) before any retry (D-05).
- **Add** capacity reservation in the *same* transaction as the operation (FD-013);
  **retire** the standalone route-write-lease file as authority (demote to a derived
  projection). Keep the existing NDJSON journal as a derived export.
- **Preserve** the inline network-egress exception-lease model (E-05 — it is not a
  standalone service and satisfies FD-013's negative constraint).

### 3.5 Adaptive verified publication (FD-010, FD-011)
- **Modify** `route_selection_order` in `default-work-unit.yml`: for autonomous
  Class B, remove `direct-main` from the order (or gate it behind an operator-only
  predicate); make `branch-no-pr` the default; automatic PR escalation on the
  FD-010 conditions. **Retire** autonomous direct-main.
- **Replace** the exact-SHA verifier: move the required checks out of the
  candidate-editable tree (a GitHub App or a protected verifier repo the candidate
  cannot edit), keyed to a pre-registered exact SHA computed by the broker, not
  re-derived from the pushed head.
- **Modify** the broker to perform the push and refuse if the resolved head SHA ≠
  authorized landed_commit or target pre-SHA moved (target-race).
- **Add** the stale-route-bundle env bypass (`OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE`)
  gate: require a signed run-scoped exception artifact instead of a bare env var
  (J-08).

### 3.6 Signed evidence + retention (FD-014) — decision-gated
Two honest options; **operator must pick** (see operator-decisions):
- **(A) Implement signing**: ed25519 (or operator-held HMAC) over event-log heads
  and checkpoints, signed by the broker/verifier, *verified* (not recomputed) at
  closeout/promotion. Add a `signature` field to `checkpoint-v2` and RunCheckpoint.
- **(B) Reword claims**: replace "sign/signed/signature" in FD-014 and all
  schema/docs with "hash-chained and git-anchored", rename the capability-layer
  `signature` (E-03), and make quorum verify identity/binding not string presence.
- Either way: **preserve** the honest completeness/fail-closed rules (E-06) and add
  a bounded-retention + compaction that re-anchors a verifiable head.

### 3.7 Self-development + trust activation (FD-017, FD-018)
- **Add** a required merge gate that, for any diff touching declared trust-root/
  authority surfaces, fails closed unless a valid promotion receipt + accepted
  decision request + recertification result exist and validate — **wiring the
  already-strong `promotion_blockers()` reader onto the enforced path**.
- **Modify** trust-root certification gates to run verifier scripts/gate workflows
  from the **base ref**, not the PR head (kills same-change self-certification,
  F-017-2).
- **Add** inert landing: a staged-activation primitive so a trust-root change lands
  dormant and a separate, later, operator-preauthorized activation record makes it
  effective (F-017-3).
- **Add** exact-version, previous-version-verified, rollback-capable harness
  activation; sign release artifacts (or pin an out-of-tree verifier). **Modify**
  `trust_domain_add` to validate the approval artifact, not its mere presence (J-06).

### 3.8 Projects, harness, extensions (FD-019, FD-020, FD-021, FD-023)
- **Preserve** the Harness Factory (FD-020), adapters (FD-023), extension catalog
  (FD-021), and Profile "never authority" (FD-019) — all satisfied or nearly so.
- **Add** a minimal `workspace-project-v1` identity record (project_id, repo
  identity, maximum locality boundary, `profile_revision_ref`) — explicitly
  non-authority, `additionalProperties:false`.
- **Small hardening**: populate `digest_sha256` on bundled packs; add
  rollback-to-generation for the catalog.

### 3.9 Product scope + usability (FD-001, FD-002, FD-024)
- **Modify** the "Class A/B/C" collision: rename the retention taxonomy; add a
  crosswalk binding FD-002's consequence classes onto the mission_class × ACP model
  so a routine reversible change on an isolated branch clears ACP-2 with the
  *independent SHA verifier as the second quorum member* — zero human prompts.
- **Demote/flag** federation/trust-compact breadth (H-04) behind an off-by-default
  feature for the solo vertical.
- **Add** an operator-mode `octon doctor` (broker/credential/mission/storage health)
  and a cross-project `octon inbox`.
- **Trim** non-load-bearing CI gates for the solo path (simplification — Phase 3).

## 4. What this migration deliberately does NOT do

It introduces **no** second control plane, second broker, distributed consensus,
multi-writer state, VM, enterprise identity, public marketplace, persistent agent
org, universal PR ceremony, or autonomous direct-main work. It adds exactly one
broker, one transactional store, one isolation mechanism, one out-of-tree verifier,
and one activation controller — each closing a specific, testable gap. The count of
net-new subsystems (≈6) is the minimum that makes the target boundary real.

## 5. Migration shape summary

- **Preserve** (working, keep): authority primitive + kernel mediation pattern,
  harness factory + resolver, adapters, extension catalog, Profile non-authority,
  promotion_blockers reader, transition-scoped degradation, honest completeness rules,
  network-egress exception-lease model.
- **Extend**: authority to the agent-launch path; evidence to signed/anchored
  bounded checkpoints; project/harness to minimal identity.
- **Modify**: route ordering; git to sanitized; consume to transactional CAS; claims
  to honest wording; Class A/B/C naming.
- **Replace**: file state as transaction boundary → SQLite/WAL; candidate-editable
  verifier → out-of-tree; candidate launcher → isolated credentialless launcher.
- **Retire**: self-attesting DelegationProof-as-authority, ambient credentials,
  managed git hooks, autonomous direct-main, standalone route-write-lease authority,
  overbroad "signed/complete-mediation" claims.
- **Add**: broker, SQLite/WAL store, isolation, sanitized git adapter, out-of-tree
  verifier, reconciliation, inert trust landing + activation controller, workspace
  project identity, operator doctor + inbox.
