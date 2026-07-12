# Phase 1 — Identical Independent Comprehensive Review

> Research and decision input only. Non-authoritative. Reviewed commit
> `c5b1f5760c78ff521cca6b054e4e8fef5300505b` (branch `main`, clean working tree),
> macOS 26.5.2 arm64. Evidence classifications per the review contract. Citations
> are `path:line` at the reviewed commit unless marked otherwise.

## 0. Method and independence

The primary architect recorded the clean baseline (the intake unit left
`current_head_commit: unknown` and `clean_repository_reverification_performed:
false`; this review supplies that reverification), verified intake integrity
(94/94 sha256 OK), then fanned out nine read-only subagents (A–H, J) on
Opus 4.8 over the runtime crates, contracts, workflows, governance, and state.
Every subagent was barred from reading any sibling review. The lead
independently re-read the highest-stakes surfaces — `authorize_execution`, the
lifecycle authorization/spawn path, the publication route contract, the
evidence/signing code, and repo scale — and corroborated the load-bearing
findings before accepting them. 66 findings resulted; none were rejected.

## 1. What Octon actually is today (CURRENT_REPOSITORY_FACT)

Octon at this commit is a **large, file-native constitutional governance system
wrapped around a 13-crate Rust runtime** (~157k LOC) that launches frontier
coding agents (Codex/Claude) against a repository, plus **42 GitHub Actions
workflows** and **~53,070 tracked files** under `.octon/`. Its spine is:

- `authority_engine` (~18k LOC): a real deny-by-default authority with
  `authorize_execution` (`execution.rs:2000`) producing a `GrantBundle`, and
  `verify_authorized_effect` (`effects.rs:210`) — a genuinely strong single-use
  effect-token verifier that checks decision=Allow, id/kind/route/scope match,
  canonical record-digest match, authority-ref existence, expiry, revocation,
  budget, egress, and single-use consumption, emitting a request+consumed
  journal pair.
- `lifecycle_executor` (~10k LOC): the engine that actually spawns the agent
  processes (Codex/Claude) via `build_executor_command` (`codex.rs:416`).
- `kernel` (~98k LOC): commands, workflow, pipeline, lifecycle drivers, trust,
  evolution, side-effects inventory.
- `runtime_resolver`: enforces the digest-bound effective route bundle in-kernel.
- Supporting crates: `policy_engine`, `replay_store`, `core`, `wasm_host`,
  `authorized_effects`, `studio`, `telemetry_sink`, `runtime_bus`,
  `assurance_tools`.

State is **loose YAML + NDJSON** files under `.octon/state/{control,evidence,
continuity}/` — there is no embedded database.

### The single architectural fact that dominates everything

**Octon has two authorization planes, and the most consequential effect uses the
weaker one.**

- Plane 1 (canonical, strong): `authority_engine::authorize_execution` +
  `verify_authorized_effect`. It is consistently applied across the kernel
  command / workflow / pipeline / service / studio paths — every one of those
  spawn sites is dominated by a prior `authorize_execution` + effect-token
  verification (A-07: `commands/mod.rs`, `workflow.rs`, `pipeline.rs`,
  `stdio.rs`). This is a real strength and a reusable primitive.
- Plane 2 (self-attesting, weak): `lifecycle_executor::authorize_before_dispatch`
  (`authorization.rs:39`) builds and writes its **own** `DelegationProof` from a
  caller-supplied `invocation_authority` map and a route-supplied
  `delegation_contract`. `lifecycle_executor` has **zero dependency on
  authority_engine** — it is absent from its `Cargo.toml`. The actual Codex/Claude
  spawn (`codex.rs:254`) consumes no canonical grant and no one-shot ExecutorLaunch
  token. The only production caller of `issue_executor_launch_effect` is the
  `octon studio` dev-app launch (`commands/mod.rs:736`), **not** an AI agent.

So the path that launches an autonomous, credentialed coding agent into the
canonical repository is exactly the path that is **not** mediated by the canonical
authority. Every downstream gap cascades from this.

This independently reproduces — from current source at HEAD — the "mediation gap"
the intake's inherited findings described: the engine enforces in-kernel, but
nothing unavoidable calls it for the agent-launch effect.

## 2. Decision-by-decision findings

Full reconciled alignment for all 24 decisions is in
`final-decision-to-repository-crosswalk.yml`. Highlights by area:

### A. Product and scope (FD-001, FD-002, FD-024)
- **FD-001 PARTIALLY_SATISFIED.** Solo intent is pervasive, but the repo carries
  genuine multi-party breadth: Trust Compacts, a Federation ledger,
  Delegated-authority Leases, cross-domain attestation and portable proof-bundle
  import/export (top-level CLI verbs `Trust`, `Proof`, `Attest`, `Delegate`,
  `Federation`; `trust.rs` alone ~1,515 LOC — H-04). Combined with 53k files, 42
  workflows, 33 governance policies, and ~185k state+generated files, the
  install/operate/diagnose/recover burden is that of an operating platform, not a
  one-person tool (H-07).
- **FD-002 CONTRADICTED.** The repo's "Class A/B/C" is an evidence-**retention**
  taxonomy (Git-inline / Git-pointer / external-digest), not the consequence
  routing FD-002 names. Real routing is a 7×5 mission_class × ACP-tier matrix;
  ordinary repo mutation maps to ACP-2 "escalate" with 2-party quorum (H-01,
  H-08) — routine ceremony, not "zero routine prompts". The name collision is a
  usability hazard.

### B. Authority and launch (FD-003, FD-004, FD-015, FD-022)
- **FD-003 PARTIALLY_SATISFIED**, **FD-004 CONTRADICTED**, **FD-022 CONTRADICTED**
  — the two-plane split above (A-01, A-02, J-01). No one-shot guard at agent
  spawn; children inherit credentials (A-03); no delegation-depth bound (A-04);
  child scope is advisory (A-05).
- **FD-015 PARTIALLY_SATISFIED.** Authorize and verify roles exist in substance;
  the four-role TCB model and an enumerated physical-writer list do not (A-06).

### C. Isolation, credentials, broker (FD-006, FD-008, FD-016)
- **FD-006 ABSENT**, **FD-008 ABSENT.** No credential-holding broker exists (the
  only "broker" is a policy-grant shell script). No spawn site applies
  `env_clear`/allowlist, so agents inherit ambient `GITHUB_TOKEN`/`GH_TOKEN`/SSH/
  API keys (B-01, B-06, J-02). No OS sandbox primitive exists anywhere
  (`sandbox-exec`/`seatbelt`/`unshare`/`seccomp` grep = zero, B-04). Candidate
  work runs in the **canonical** repo root (`--cd repo_root`) on canonical `.git`
  objects/refs — no isolated worktree (B-05). A second spawn path in
  `authority_engine`/pipeline omits the sandbox flag entirely and can add
  `--full-auto`/`--permission-mode bypassPermissions` (B-03).
- **FD-016 PARTIALLY_SATISFIED.** Transition-scoped blocking is a real strength;
  the credential-protection clause is vacuous absent a credential boundary (B-08).

### D/E. Runtime state, recovery, evidence (FD-005, FD-012, FD-013, FD-014)
- **FD-005 CONTRADICTED.** No SQLite/WAL or any transactional store; 11 non-test
  `fs::write` sites in authority_engine with zero atomic-rename/fsync (D-01,
  D-03).
- **FD-012 PARTIALLY_SATISFIED.** Single-use consume is a TOCTOU read-check-write
  (D-02, J-04); no unknown-outcome reconciliation ("did the push land?") exists
  (D-05); idempotency is an optional journal field, not enforced (D-06).
- **FD-013 PARTIALLY_SATISFIED.** No standalone lease service (E-05, good), but no
  capacity reservation in-transaction and no ENOSPC handling (E-04, D-04).
- **FD-014 CONTRADICTED.** **No cryptographic signing exists at all** — only
  unkeyed SHA-256. "Rechaining breaks checkpoint verification" is false: any
  writer can rewrite the log and recompute the public hash chain to pass
  validation (E-01, E-02). Capability "signatures" are unkeyed hashes and quorum
  only presence-counts them (E-03). The completeness/fail-closed half is honest
  (E-06) — the real tamper-evidence comes from git/GitHub history, not in-repo
  crypto.

### C(git)/publication (FD-007, FD-009, FD-010, FD-011)
- **FD-007 ABSENT.** No scoped GitHub App; provider writes use a broad
  `AUTONOMY_PAT` in a candidate-editable `pull_request_target` workflow (C-004).
- **FD-009 CONTRADICTED.** Git runs unsanitized (no `GIT_CONFIG_NOSYSTEM`,
  `hooksPath`, `--no-verify`); the repo **installs** managed post-merge/post-checkout
  hooks that run git mutations and chain prior hooks (C-001, C-002).
- **FD-010 CONTRADICTED.** `route_selection_order` in `default-work-unit.yml:295`
  lists **direct-main before branch-no-pr**, and `solo_route_selection` prefers
  direct-main for solo low-risk changes (C-005) — verified at HEAD, contradicting
  "agents never publish on main".
- **FD-011 CONTRADICTED.** The four required checks on live main
  (PROVIDER_OBSERVED, C-006) are jobs defined in the agent-editable
  `change-route-projection.yml`, and the exact-SHA job passes trivially in the
  common no-receipt path (C-003). The verifier authors its own verdict.

### F. Self-development and trust root (FD-017, FD-018)
- **FD-017 CONTRADICTED.** The evolution/promotion/recertification CLI is
  advisory and wired into no merge gate (F-017-1). Certification gates run the
  PR's **own head ref**, so a change can weaken its own validator and be certified
  by the weakened version (F-017-2). No inert landing — trust-root edits are
  effective on merge (F-017-3).
- **FD-018 ABSENT.** No operator-preauthorized, previous-version-verified, staged,
  rollback-capable activation. Release binaries are unsigned, built from HEAD;
  trust admission approval is presence-only (any `--approval-ref` string flips
  status — J-06, F-018-1). The thorough `promotion_blockers()` fail-closed reader
  exists but calls nothing and is called by nothing (F-018-2).

### G. Projects, harness, extensions, adapters (FD-019, FD-020, FD-021, FD-023)
**This area is the repository's real strength.**
- **FD-020 SATISFIED.** A deterministic, digest-bound effective-route-bundle
  factory exists, is idempotent, and the `runtime_resolver` enforces the digest
  binding in-kernel, denying on any drift or forbidden consumer (G-03, G-04).
- **FD-023 SATISFIED.** Provider-native model/host delegation via replaceable,
  non-authoritative Octon-owned adapter contracts; providers cannot widen
  authority or support tiers (G-08, G-07).
- **FD-021 PARTIALLY_SATISFIED.** Import/verify/pin/quarantine and no-marketplace
  are realized; signatures are unenforced on the bundled set and there is no
  explicit rollback-to-generation (G-05, G-06).
- **FD-019 PARTIALLY_SATISFIED.** The "never authority" half is solid; a durable
  digest-bound Workspace Project identity is absent (G-01, G-02).

## 3. Reconciliation of the inherited (intake) findings

Every inherited current-state finding was independently reverified at HEAD:

| Inherited finding | Verdict at HEAD |
|---|---|
| FIND-AUTH-001 lifecycle self-attesting plane | **CONFIRMED** (A-01, J-01) — and stronger: no authority_engine dependency at all. |
| FIND-CRED-001 candidate inherits credentials | **CONFIRMED** (B-01, B-06, J-02) — no env scrub at any spawn. |
| FIND-GIT-001 privileged Git needs protection | **CONFIRMED and worse** — hooks are actively installed and load-bearing (C-002). |
| FIND-PUB-001 candidate-controlled checks | **CONFIRMED** (C-003, C-006) — the four required main checks live in the candidate tree. |
| FIND-STATE-001 file state insufficient | **CONFIRMED** (D-01, D-03) — no DB, non-atomic writes. |
| FIND-EVID-001 hash chaining ≠ authenticity | **CONFIRMED and stronger** — no signing exists at all; "signature" fields are unkeyed hashes (E-01, E-03). |
| FIND-SELF-001 trust-root needs separation | **CONFIRMED** (F-017-2, F-018-x) — same-change self-cert reachable, no inert landing. |
| FIND-ROUTE-001 direct-main before branch-no-pr | **CONFIRMED at HEAD** (C-005) — not only at ce924420; still true in `default-work-unit.yml:295`. |

Corrections/refinements to the intake: the intake under-stated two things. (1)
The lifecycle plane is not merely "self-attesting" — it has *no linkage at all* to
the canonical authority (no crate dependency). (2) Evidence is not "hash chaining
that doesn't prove authenticity" so much as *there is no signing primitive of any
kind*, and one capability layer mislabels unkeyed hashes as "signatures" that
quorum never even verifies (E-03) — a support-claim inaccuracy sharper than the
intake described.

## 4. Preserve list (genuine strengths — do not rebuild)

1. `authority_engine::verify_authorized_effect` single-use token verifier — the
   correct primitive; extend it to the agent path rather than invent a new one.
2. The kernel command/workflow/pipeline pattern of `authorize_execution` +
   `verify_authorized_effect` before every subprocess — proof the pattern is
   implementable; it is already applied where the kernel owns the effect.
3. `protected_ci_auto_merge` (`commands/mod.rs:1413`) — a good gated model
   (file-existence-checked approval projection, bound high-risk capabilities,
   verified effects before merge).
4. `promotion_blockers()` (`evolution.rs:541`) — a thorough fail-closed reader
   (accepted decision refs, human/quorum approval, lab gate, rollback posture,
   recertification, no self-approval). It just needs to be on an enforced path.
5. The deterministic digest-bound Harness Factory + in-kernel resolver (FD-020).
6. The non-authoritative provider-adapter contracts (FD-023).
7. The extension catalog: provenance-carrying packs, digest-pinned effective
   view, quarantine, no marketplace (FD-021).
8. The Project Profile "never authority" discipline (FD-019).
9. Transition-scoped degraded operation (FD-016).
10. The `side_effects` INVENTORY that already enumerates ExecutorLaunch as a class
    requiring the boundary (J-05) — turn it from `dead_code` into an enforced
    invariant.

## 5. Consequence for the review objective

Measured against the target ("one unavoidable boundary for all supported agent
launches and durable effects; credentialless agents; broker-mediated durable
effects; verified no-PR default; safe self-development"), the repository today
**has the right authorization primitive but applies it to the wrong set of
paths**, and lacks the broker, isolation, transactional store, signing, and
inert-activation machinery the target requires. The strengths are concentrated in
the *compile-time* surfaces (harness factory, adapters, extension catalog); the
gaps are concentrated in the *runtime effect* surfaces (agent launch, credentials,
publication, evidence authenticity, trust activation). That is a favorable shape
for migration: the missing pieces are additive around a strong existing core, not
a rewrite. Details in Phase 2.
