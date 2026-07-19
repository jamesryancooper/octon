# Acceptance Criteria

## Entry Criteria

- Accepted RP-02, RP-08, and RP-11 packet digests and the RP-13 design receipt
  are frozen for proposal authorization.
- Exact dependency implementation interfaces and current shared symbol/writer
  ownership verify before RP-13 source edits.
- ED-001 useful credentialless isolation and local/provider hard-limit
  enforcement prove against the exact implementation before live mapping use.
- The selected ROD-005 configuration stays launch-disabled until all applicable
  mapping, UE-013, and conformance gates pass.
- Existing ProgramChild scheduler primitives and MissionChildRun-specific
  symbols have exclusive owners at the implementation commit.

## Target Criteria

| ID | Required condition | Proof |
| --- | --- | --- |
| RP13-AC-001 | Every child has a unique temporary MissionChildRun/attempt identity bound to exact parent, mission, project, Harness, guard, isolation, provider mapping, and budget identities. | Strict schema validation and binding mutation matrix. |
| RP13-AC-002 | Effective scope/budget equals the strict parent/mission/project/Harness/role/isolation/provider/remaining-limit intersection; missing/incomparable/widening input denies. | Generated intersection fixtures and field-by-field widening attacks. |
| RP13-AC-003 | Child can perform useful admitted model work but cannot read/export credentials or provider session material, access canonical Git/remotes/config, sibling/parent control/evidence/candidate areas, or perform durable external effects. | Useful-positive fixture plus environment/HOME/Keychain/Git/path/effect negative matrix. |
| RP13-AC-004 | Each launch consumes one exact unexpired/unrevoked guard; stale, wrong-child, wrong-Harness, wrong-session/root/mapping/budget, replayed, or double-use guard denies before launch. | Guard/TOCTOU/adversarial launch matrix. |
| RP13-AC-005 | Depth is exactly one and no child prompt/tool/provider/runtime surface can spawn, recruit, delegate, create a grandchild, or create persistent agent identity. | API/call-graph/prompt/tool/provider probes and filesystem/state scan. |
| RP13-AC-006 | Existing lifecycle scheduler primitives enforce the configured accepted ROD-005 concurrency, steps, attempts/retries, and wall-clock timeout without creating another scheduler/queue/worker. | Race/ceiling tests and process/store/schedule census. |
| RP13-AC-007 | Token, cost, and evidence dimensions are labeled hard-enforced, measurement-only, or unsupported; every declared hard ceiling stops before overrun or admission denies. | Provider capability matrix, near/at/over-limit fixtures, forged/missing usage, and unsupported-hard denial. |
| RP13-AC-008 | Role templates only narrow prompt/output/context/tools/budget and cannot grant authority, capabilities, credentials, depth, persistence, or effects. | Authority-shaped role/template negatives and before/after authority digests. |
| RP13-AC-009 | The admitted provider-child mapping consumes RP-11 generic prepare/launch/observe/cancel/usage/retire without modifying/bypassing the generic adapter or provider support policy. | Call graph, fake/primary mapping conformance, and direct-bypass denial. |
| RP13-AC-010 | Parent/mission revoke, operator cancel, timeout, hard-budget exhaustion, and invalidated binding target the exact provider task/process group and preserve parent/candidate work. | Cancel trigger/state matrix and process-group sentinel tests. |
| RP13-AC-011 | Lost launch/cancel/terminal response remains unknown and reconciles through RP-08 before retry/replacement/retirement; desired state alone never proves causation. | Lost-response/concurrent actor/restart fixtures and recovery receipts. |
| RP13-AC-012 | Child output stays in isolated candidate/evidence surfaces and cannot mutate parent mission/run/authority; parent validates and reconciles it before any incorporation. | Write-scope enforcement, output schema/diff validation, and parent state digests. |
| RP13-AC-013 | Terminal retirement preserves output/evidence, revokes/releases guard/session/provider task/process/candidate locks, writes tombstone, and denies identity/session/guard/candidate reuse. | Failure injection at every retirement step plus post-retirement reuse matrix. |
| RP13-AC-014 | A replacement child after reconciled predecessor failure/unknown uses entirely new identity, guard, session, provider task, candidate area, and budget while retaining lineage. | Replacement lineage and old-resource rejection fixtures. |
| RP13-AC-015 | Child progress, block, cancel, unknown, and retirement appear concisely in existing mission status/inbox; normal admitted work creates zero routine prompts after accepted configuration and proof-driven admission. | Golden CLI/read-model outputs and prompt/intervention count. |
| RP13-AC-016 | Disabling child launch cancels/reconciles/retires active children and preserves parent progress/output; single-agent RP-11 continuation remains available where authorized. | Cutover rollback and degraded-mode mission fixture. |
| RP13-AC-017 | ProgramChild proposal lifecycle semantics remain unchanged and cannot be treated as a persistent MissionChildRun. | Type/schema/call-path separation and proposal-program regression suite. |
| RP13-AC-018 | No persistent organization/account, credentials, canonical Git, depth greater than one, new scheduler/runtime/store/authority/broker/recovery controller, or generic adapter change exists. | Architecture/filesystem/process/symbol/ownership audit. |

## Proof Obligations

Passing RP13-AC-001 through RP13-AC-018 satisfies PO-FD-022 and
PG-13-BOUNDED-CHILDREN. RP13-AC-009 through RP13-AC-011 and RP13-AC-013 supply
RP-13's child-specialization contribution to PO-FD-023 and
PG-14-PROVIDER-CONFORMANCE. RP-14 remains the independent integrated promotion
owner.

## Exit Criteria

- the accepted ROD-005 provisional configuration, ED-001 premise, and exact
  RP-08/RP-11 receipts are current;
- all schema, scope, credential, depth, budget, provider mapping, cancellation,
  unknown, output, retirement, replacement, UX, rollback, and regression tests
  pass at one implementation;
- UE-013 and child PO-FD-023 component evidence are retained under the declared
  root;
- architecture, implementation conformance, and drift/churn reviews pass;
- generated views are refreshed only through owners; and
- no durable target depends on this proposal path.

These are future gates. None is claimed as executed by this draft.
