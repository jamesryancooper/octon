# Contract, Schema, Workflow, and Retirement Register

| Family | Owning packet(s) | Required discipline |
| --- | --- | --- |
| authority/grant/revocation/policy/guard | RP-01 | version/freeze before persistence; deny substitution |
| runtime operation/store/checkpoint/reconstruction | RP-03 exact storage entries; RP-07 exact evidence entries; RP-08 outcome use | one writer and serialized registry edits |
| broker IPC/handle/credential/service | RP-04 | Design and Dependency Receipt for IPC/Keychain choices |
| Git/effect/publication/verdict | RP-05 primitive; RP-06 predicate/adapter | expected-old CAS; separate verifier/publisher |
| retention/signature/head/reserve/compaction | RP-07 | physical capacity and anti-rollback proof |
| run health/reconciliation/maintenance | RP-08 | honest UNKNOWN/manual_intervention; no exactly-once overclaim |
| trust inventory/install/activation/selector | RP-09 | prior-version verification; one selector |
| project/profile/inbox | RP-10 | non-authoritative, frozen active-run snapshot |
| Harness/executor adapter | RP-11 | full-input digest binding; one real primary plus fake adapters |
| extension envelope/catalog/publication | RP-12 | desired/actual/generated roles remain separate |
| child identity/budget/retirement | RP-13 | depth one, hard limits, terminal reuse denial |
| support/claim/roadmap/release | downstream owners after RP-14 | RP-14 handoff only, never direct ownership |

`.github/**` is a derived repo-local projection and never an octon-internal
promotion target. RP-06 must establish and accept the durable `.octon` source or
generator before changing workflow projections. If that cannot be proved, RP-06
is revised with a governed target-family disposition; no unlisted child is
invented.

Retirements include candidate-head writers/verifiers, direct agent main, ambient
Git/credential paths, loose-file authority, dual writers, redundant provider
workflows, direct adapter bypasses, and same-tree activation only after census,
proof, replacement, rollback, and owning child authorization.
