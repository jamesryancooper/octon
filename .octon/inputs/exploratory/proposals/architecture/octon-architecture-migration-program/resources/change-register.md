# Contract, Schema, Workflow, and Retirement Register

| Family | Owning packet(s) | Required discipline |
| --- | --- | --- |
| authority/grant/revocation/guard | RP-01 | typed repository/source/`O`/`S`/target/policy/operation/issuer/expiry/revocation/consequence scope; version/freeze before persistence; deny substitution |
| runtime operation/store/checkpoint/reconstruction | RP-03 exact storage entries; RP-07 exact evidence entries; RP-08 outcome use | one writer and serialized registry edits |
| broker IPC/handle/credential/service | RP-04 | Design and Dependency Receipt for IPC/Keychain choices |
| closed Git/ref effects | RP-05 primitive | exact-object non-executing import; source-ref CAS; target `O -> S` CAS; conditional expected-tip delete; no generic service |
| route/verdict/history/protected PR/mirror | RP-06 predicate and publication specialization | eligible B defaults no-PR; full exact `V`; policy-selected PR; `S -> Q`; local main remains a post-land mirror |
| retention/signature/head/reserve/compaction | RP-07 | physical capacity and anti-rollback proof |
| result/reconciliation/cleanup/run health | RP-08 | honest UNKNOWN/manual_intervention; no retry or route switch while UNKNOWN; cleanup-deferred honesty; no exactly-once overclaim |
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

Retirements include candidate-head writers/verifiers, every Octon-owned human or
agent direct-main route, current autonomous checkout-held publication, ambient
Git/credential paths, loose-file authority, dual writers, redundant provider
workflows, destructive unlanded cleanup, direct adapter bypasses, and same-tree activation only after census,
proof, replacement, rollback, and owning child authorization.
