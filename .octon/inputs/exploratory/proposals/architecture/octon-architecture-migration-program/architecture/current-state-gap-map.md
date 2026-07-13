# Current-State Gap Map

| Current state | Material gap | Owning packets |
| --- | --- | --- |
| Strong governance and runtime seams exist, but writer/launcher/provider claims need containment and truthful inventory. | Unsafe or overstated routes must be disabled before privileged work. | RP-00 |
| Authority, lifecycle, files/journals, and provider effects span multiple seams. | One immutable authority interface, isolated candidate, transactional store, and supervised broker are not yet proved together. | RP-01–RP-04 |
| Git and GitHub automation exist. | Sanitized Git, separate exact-SHA verification, deterministic publication, and derived workflow ownership need proof. | RP-05–RP-06 |
| Evidence and recovery contracts exist. | Authenticity, physical terminal capacity, retention, UNKNOWN reconciliation, and a complete Class B vertical remain unproved. | RP-07–RP-08 |
| Evolution machinery exists. | Semantic trust closure and prior-version exact activation are not yet proved. | RP-09 |
| Project/Harness/extension/agent concepts exist in partial forms. | Minimal non-authoritative projects, deterministic full-input Harnesses, signed private extensions, and bounded children need clean ownership and proof. | RP-10–RP-13 |
| Reconciliation defines product budgets. | Independent exact-commit dogfood and claim reproduction have not run. | RP-14 |

## Git Lifecycle Reassessment

| Finding | Current-authority observation | Recommended target | Owner |
| --- | --- | --- | --- |
| `BNP-F-001` | `.github/workflows/pr-auto-merge.yml` uses `pull_request_target`, checks out candidate-head code, and executes it with write-capable credentials. | RP-00 disables the writer; no broker ever checks out or executes candidate code. | RP-00, RP-06 |
| `BNP-F-002` | Current no-PR authorization is locally self-issued and lacks the complete grant, issuer, policy, expiry, revocation, signature, and exact tuple binding. | RP-01 grant plus RP-06 `V` bind the complete `O/S` tuple; RP-07 supplies the bounded role-signature proof without taking grant or verdict semantics. | RP-01, RP-06, RP-07 |
| `BNP-F-003` | Required route checks more readily prove context/static alignment than substantive exact-candidate safety; Main Guard observes after `main` changes. | Equal substantive validation completes before effect; post-land verification is independent. | RP-06, RP-14 |
| `BNP-F-004` | A normal non-force push does not pin recorded `O` when target advances to another ancestor of `S`. | RP-05 performs one server-observed `O -> S` CAS or refuses. | RP-05, RP-08 |
| `BNP-F-005` | PR automation is not bound to one expected-base/head/review-state tuple. | RP-06 owns a complete frozen PR gate and each provider effect is reconciled. | RP-06, RP-08 |
| `BNP-F-006` | Legacy cleanup can delete closed-unmerged work and governed cleanup has a compare/delete race. | RP-08 requires landed proof; RP-05 offers only conditional expected-tip deletion. | RP-08, RP-05 |
| `BNP-F-007` | Squash yields `Q != S`, invalidating source-ancestry cleanup assumptions. | RP-06 proves provider association and tree/patch equivalence from `S` to `Q`. | RP-06 |
| `BNP-F-008` | Current no-PR can land multiple commits despite a one-squash-commit trunk promise. | History shape freezes before `V`; one curated commit defaults, bounded series require full-range admission. | RP-06 |
| `BNP-F-009` | In-band receipts prove shape more readily than provider state or causation. | RP-07 signs role-separated direct observations and a monotonic terminal anchor outside project Git. | RP-07 |
| `BNP-F-010` | Current local/direct-main concepts conflict with candidate-first hosted publication. | Octon `direct-main` is removed; canonical local `main` is a post-land mirror only. | RP-00, RP-06 |
| `BNP-F-011` | Race, invalid authority, and `UNKNOWN` have been ambiguously described as PR escalation conditions. | Route freezes before effect; invalid/collision/`UNKNOWN` denies or reconciles without route switching. | RP-08, RP-06 |
| `BNP-F-012` | Speed and burden have not been compared under an equal substantive floor. | RP-14 proves safety, latency, recovery, preservation, prompt, and false-escalation budgets. | RP-14 |
| `BNP-F-013` | Provider-visible candidate/source-ref effects lack explicit closed ownership. | RP-05 owns sealed ref primitives; RP-06 owns PR policy; RP-08 owns results/recovery. | RP-05, RP-06, RP-08 |

Bounded current provider evidence was refreshed on 2026-07-13: candidate run
`29249394310`, main route run `29249511200`, main guard run `29249511103`, and
Main Push Safety run `29249511080`. The route checks passed and the candidate
landed, then substantive Main Push Safety failed. The landed range
`d78ee8b42cb3a39557bbe39b66cb5d156946172a..71df92e0ecae6b07c924872931601d51f107e181`
contained two commits. Active ruleset `12881449` had no bypass actors, required
four route checks, enforced linear/non-fast-forward/deletion protection, and did
not universally require PRs. These observations are evidence, not authority or
target proof; raw workflow logs are not retained in project Git.

Creation-time baseline drift affects only the named reviews/reconciliation,
proposal prompt, and closeout/refinement evidence; no material target source
family changed. The fixed fifteen boundaries therefore remain admitted.
