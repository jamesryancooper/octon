# Independent Octon Architecture & Migration Review

> **RESEARCH AND DECISION INPUT ONLY — NOT AUTHORITATIVE OCTON ARCHITECTURE.**
> This review does not approve implementation, change Octon architecture, create
> authority, promote a decision, or authorize any provider/credential/publication/
> deployment/trust-root action. It does not replace ADRs or an Octon proposal program.

## Readiness verdict

# ▶ READY_WITH_BLOCKING_DECISIONS

The repository + this review contain enough to **author** the formal migration
proposal program (packets, boundaries, dependencies, and acceptance tests are all
defined and evidence-grounded). Privileged implementation may **not** begin until:

1. **Three blocking operator decisions** are settled — OD-01 (evidence signing vs
   git-anchored; recommend git-anchored), OD-06 (gate multi-party federation off for
   the solo vertical; recommend yes), OD-08 (ratify the trust-root inventory +
   human-anchored epoch-0 bootstrap).
2. **The PP-00 blocker corrections** land — G-B1 correct overstated claims; **G-B2
   pin the authority decision function** (lead-verified: `authorize_execution` today
   shells out to a candidate-editable policy file + bash runner); G-B3 disable
   autonomous direct-main + managed git hooks; G-B4 full git-extension allowlist;
   G-B5 make every `OCTON_*` override fail-closed.

The architecture is **sound** and the direction **confirmed** — the gaps are additive
around a strong core, not a rewrite. See `synthesis/proposal-program-readiness.md` for
why this is neither "ready to build now" nor "broken."

## The core finding in one sentence

Octon has the **right authorization primitive** (a strong single-use effect-token
verifier) but applies it to the **wrong set of paths** — the credentialed
autonomous-agent launch runs on a separate self-attesting plane, agents inherit
ambient credentials in the canonical repo with no OS sandbox, there is no broker/
store/signing, and even the authority engine's own Allow/Deny decision is computed by
executing candidate-editable code.

## Baseline

| | |
|---|---|
| Commit reviewed | `c5b1f5760c78ff521cca6b054e4e8fef5300505b` (branch `main`, clean) |
| Host | macOS 26.5.2 arm64; rustc 1.93.1; gh 2.92.0 |
| Intake unit | `octon-architecture-and-migration-handoff-v2.0.0` — integrity verified 94/94 |
| Findings | 66 (Phase 1) + 40 (Phase 3) = 106; highest-severity lead-verified from source |
| Decision alignment | 2 satisfied · 9 partial · 8 contradicted · 5 absent (of 24) |
| Independence | No sibling review read; a prior-session memory hint was treated as untrusted and re-derived |

## How to read this review

1. `synthesis/executive-summary.md` — start here.
2. `synthesis/final-review.md` — the 14 required questions + verdict.
3. `phase-1/comprehensive-review.md` + `final-decision-to-repository-crosswalk.yml` — what current Octon is.
4. `phase-2/migration-architecture.md` — the smallest safe migration.
5. `phase-3/assurance-review.md` + `fault-injection-plan.md` — adversarial pass + proof plan.
6. `synthesis/recommended-workgroup-sequence.yml` — WG-00…WG-09 with entry/exit/rollback/proof.
7. `synthesis/remaining-operator-decisions.yml` — the 9 decisions (3 blocking).

## Directory map

```
README.md · review-manifest.yml
provenance/  repository-baseline · source-register · subagent-register · limitations · integrity-index.sha256
evidence/    command-log.jsonl · subagents/ (raw Phase 1 + Phase 3 structured findings)
phase-1/     comprehensive-review · decision crosswalk · finding register · architecture diagram · authority-effect-credential map · support-claim review · unresolved facts
phase-2/     current-to-target crosswalk · preserve-modify-add-retire · migration architecture · gap register · component/contract map · dependency graph · safe intermediate states · compatibility/retirement · rollback/recovery · packet map · operator decisions
phase-3/     assurance review · adversarial register · bypass/threat · fault-injection plan · simplification register · solo usability · readiness gates · proof-of-architecture · support-claim proof map · residual risks
synthesis/   final-review · executive-summary · recommendation register · remaining operator decisions · proposal-program readiness · workgroup sequence · review-limitations
```

## Recommended first authorized step

Author and execute **WG-00 / PP-00** (baseline + blocker corrections — low-risk, no
privileged runtime change), and run the FD-020 digest-drift test (F11) as the one
dynamic proof available today. WG-00's exit unlocks the proof-of-architecture sequence
WG-01…WG-07.

---
*Review ID: `architecture-migration-review-20260712T015106Z-57f6e8`. Completed
2026-07-12 UTC. Reviewer: independent Claude (Opus 4.8 [1m] + orchestrated subagents),
Claude Code. Non-authoritative.*
