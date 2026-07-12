# Review Limitations (final)

> Non-authoritative. Finalizes `provenance/limitations.md` with what the completed
> review did and did not establish. Reviewed commit
> `c5b1f5760c78ff521cca6b054e4e8fef5300505b`.

## Method and independence

- Single reviewer session, 2026-07-12 (UTC). Two orchestrated workflows (9 Phase 1
  subagents + 4 Phase 3 lanes) on Opus 4.8, plus independent lead reads that
  re-verified the load-bearing findings against source (authorization core, spawn
  sites, route contract, evidence/signing, policy runner, repo scale).
- **Independence:** no sibling review under `.octon/inputs/exploratory/reviews/` was
  read, searched, or cited; all subagents were barred from that tree except this
  review's own directory. No sibling directories existed at review start (verified
  empty). A prior-session memory hint about the executor mediation gap was present in
  the environment; it was treated as untrusted and every related conclusion
  independently re-derived from current source and cited as such (the central
  mediation finding and its deeper L1-01 variant are lead-verified from code).

## Evidence-class limits (what is NOT dynamically proven)

- **No code was executed.** The review is STATICALLY_INSPECTED / CONFIGURATION_DERIVED
  / ARCHITECTURAL_INFERENCE, plus read-only PROVIDER_OBSERVED (the live main ruleset,
  via `gh api`). No `cargo build/test`, no fault injection, no sandbox tests were run
  (to avoid `target/` lock contention and repo mutation). Consequently:
  - The authority engine's deny paths are read from code + tests, not executed (UF-01).
  - FD-020's digest-drift deny is inferred, not executed (UF-04 / F11 — the one cheap
    dynamic proof available today, recommended but not run here).
  - All TOCTOU / crash / concurrency findings (D-02, J-04, F1–F7) are statically
    reasoned; they become DYNAMICALLY_EXECUTED / ADVERSARIALLY_TESTED only after the
    fault harness runs.
- **Provider posture is partial.** Only the live main branch ruleset and
  `pr-auto-merge` were observed. Repo/org secrets, GitHub App installations,
  environment protection rules, and the full 42-workflow set were not exhaustively
  enumerated; additional CI authority surfaces beyond those cited may exist (UF-03).
- **Deployment-local facts** (whether a given machine actually has `GITHUB_TOKEN`/SSH
  present; real-disk headroom) are DEPLOYMENT_LOCAL and were not tested (UF-02, RR-04).
- **External executor binaries** (Codex/Claude CLIs) were not inspected; the net
  exploitability of credential inheritance from *inside* the agent is
  ARCHITECTURAL_INFERENCE (UF-02).

## Scope limits

- The review did not modify any repository file outside this review directory (verified
  clean working tree at start; only new files under the review dir were created). Build
  cache under `crates/target/` is a pre-existing gitignored artifact untouched by this
  review (no `cargo` run).
- The review did not create authoritative proposal packets, ADRs, or promote any
  decision — it is research/decision input only.
- Some intake sources are self-described as missing (13) or normalized summaries; intake
  claims were treated as unverified and re-derived where load-bearing.

## Confidence statement

The central architectural conclusions — two-plane authority with an unmediated,
credentialed agent-launch path; a candidate-editable authority decision function; no
broker/store/signing/isolation; direct-main-first routing; strong compile-time
surfaces — are **high confidence** and lead-verified from current source. The migration
design and packet structure are high confidence as *design*, medium confidence as
*effort/sequencing* (no implementation was attempted). The fault/proof plan is a
*design* whose pass/fail assertions are precise but unexecuted. The residual-risk items
(sandbox completeness, provider-config immutability, off-git authenticity, epoch-0,
broker SPOF, maintenance budget) are honestly bounded and explicitly not claimed as
proven.

## What would raise confidence

Executing WG-00 + F11 (cheap, today), then the fault harness as each packet lands;
enumerating the full provider posture (UF-03); and a dogfood window to substantiate the
solo-builder burden budgets (RR-07). None of these change the review's conclusions or
verdict; they convert inferred properties into executed ones.
