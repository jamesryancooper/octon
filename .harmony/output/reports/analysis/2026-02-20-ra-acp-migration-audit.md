# Audit Report: Reversible Autonomy (RA) + ACP Migration

- Date: 2026-02-20
- Branch: `codex/audit-ra-acp-migration`
- Auditor mode: evidence-first (code, policy/schema, runtime tests, receipts/logs)

## 1) Summary Verdict

**Verdict: Pass with issues**

The RA+ACP migration is materially enforced in runtime and CI: ACP gating is active for promote/finalize phases, deny-by-default remains fail-closed, receipts/logging are emitted on wrapper-mediated decisions, and policy reason codes are stable.

Open issues remain around taxonomy/document consistency and explicit ACP-4 coverage in current runtime regression scripting.

## 2) Checklist Table

| Area | Status | Notes |
|---|---|---|
| Docs migration | PASS | HITL runtime doc removed; ACP + DBD principles aligned to RA model. |
| Policy + schema contract | PASS | RA/ACP sections present in policy and required by schema. |
| Engine authority (decisioning) | PASS | ACP evaluated in shared Rust policy engine with stable decision enum/reason codes. |
| Wrappers/integration | PASS WITH ISSUES | Promote/finalize gating wired in service and agent wrappers; no dedicated per-domain wrapper set beyond generic gateway. |
| Quorum | PASS | ACP-2/3 quorum + attestation role/hash binding enforced; missing quorum -> stage-only. |
| Budgets | PASS | Budget exceedance drives stage-only/deny and emits reason codes/receipts. |
| Circuit breakers | PASS | Breaker actions implemented (`stop`, `halt`, `rollback+kill-switch`) and tested. |
| Receipts + append-only oversight | PASS WITH ISSUES | Wrapper paths emit receipts/digests/index/log append; raw `acp-enforce` CLI path does not emit receipt artifacts by itself. |
| CI parity | PASS WITH ISSUES | CI runs same validator/runtime suite; explicit ACP-4 deny case absent from current runtime smoke script. |
| Regression/compatibility | PASS | Services/skills/runtime policy tests pass under strict profile; no runtime HITL dependency found. |

## 3) Evidence Links and Findings

### 3.1 Docs and migration state

- HITL doc removal guard:
  - `.harmony/capabilities/_ops/scripts/validate-ra-acp-migration.sh:32`
  - `.harmony/capabilities/_ops/scripts/validate-ra-acp-migration.sh:35`
- ACP principle exists and defines promotion gate/quorum/budgets/receipts:
  - `.harmony/cognition/principles/autonomous-control-points.md:14`
  - `.harmony/cognition/principles/autonomous-control-points.md:28`
  - `.harmony/cognition/principles/autonomous-control-points.md:84`
  - `.harmony/cognition/principles/autonomous-control-points.md:137`
  - `.harmony/cognition/principles/autonomous-control-points.md:173`
- Deny-by-default principle explicitly delegates promotion to ACP (not standing human approvals):
  - `.harmony/cognition/principles/deny-by-default.md:33`
  - `.harmony/cognition/principles/deny-by-default.md:40`
  - `.harmony/cognition/principles/deny-by-default.md:154`

Command evidence:
- `./.harmony/capabilities/_ops/scripts/validate-ra-acp-migration.sh` -> `RA+ACP migration regression checks passed.`
- `test -f .harmony/cognition/principles/hitl-checkpoints.md` -> `missing`

### 3.2 Policy contract + schema + reason codes

- Policy sections present:
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:89` (`acp`)
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:372` (`reversibility`)
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:413` (`budgets`)
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:446` (`quorum`)
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:455` (`attestations`)
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:476` (`circuit_breakers`)
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:512` (`receipts`)
- Schema requires the same sections:
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.schema.json:7`
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.schema.json:17`
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.schema.json:273`
- Stable ACP reason codes catalog:
  - `.harmony/capabilities/_ops/policy/reason-codes.md:46`
  - `.harmony/capabilities/_ops/policy/reason-codes.md:72`

Command evidence:
- `./.harmony/capabilities/_ops/scripts/run-harmony-policy.sh doctor --policy ... --schema ... --reason-codes ...` -> `{ "valid": true }`

### 3.3 Control plane/engine authority

- ACP decision enum includes ALLOW/STAGE_ONLY/DENY/ESCALATE:
  - `.harmony/runtime/crates/policy_engine/src/lib.rs:365`
  - `.harmony/runtime/crates/policy_engine/src/lib.rs:381`
- ACP entrypoints + internal evaluator:
  - `.harmony/runtime/crates/policy_engine/src/lib.rs:910`
  - `.harmony/runtime/crates/policy_engine/src/lib.rs:916`
  - `.harmony/runtime/crates/policy_engine/src/lib.rs:922`
- Phase normalization + stage-only/escalate behavior:
  - `.harmony/runtime/crates/policy_engine/src/lib.rs:1200`
  - `.harmony/runtime/crates/policy_engine/src/lib.rs:1175`
  - `.harmony/runtime/crates/policy_engine/src/lib.rs:1182`
- Reversibility/budget/quorum/breaker enforcement in engine:
  - `.harmony/runtime/crates/policy_engine/src/lib.rs:1307`
  - `.harmony/runtime/crates/policy_engine/src/lib.rs:1457`
  - `.harmony/runtime/crates/policy_engine/src/lib.rs:1640`
  - `.harmony/runtime/crates/policy_engine/src/lib.rs:1111`

### 3.4 Stage vs promote boundary and wrapper enforcement

- ACP gate only runs for `promote|finalize`:
  - `.harmony/capabilities/services/_ops/scripts/enforce-deny-by-default.sh:201`
- Missing/invalid phase for mutating operations forced to `promote` + stage-only reason injection:
  - `.harmony/capabilities/services/_ops/scripts/enforce-deny-by-default.sh:262`
  - `.harmony/capabilities/services/_ops/scripts/enforce-deny-by-default.sh:276`
  - `.harmony/capabilities/services/_ops/scripts/enforce-deny-by-default.sh:399`
- Service wrapper calls ACP after deny-by-default enforcement and blocks promotion on non-allow:
  - `.harmony/capabilities/services/_ops/scripts/enforce-deny-by-default.sh:506`
  - `.harmony/capabilities/services/_ops/scripts/enforce-deny-by-default.sh:536`
- Agent runtime wrapper builds ACP request, calls ACP enforce, emits receipt, and treats STAGE_ONLY as staged/non-promoted state:
  - `.harmony/capabilities/services/execution/agent/impl/agent.sh:675`
  - `.harmony/capabilities/services/execution/agent/impl/agent.sh:701`
  - `.harmony/capabilities/services/execution/agent/impl/agent.sh:711`
  - `.harmony/capabilities/services/execution/agent/impl/agent.sh:725`

### 3.5 ACP taxonomy and mapping consistency

Taxonomy source:
- `.harmony/capabilities/_ops/policy/acp-operation-classes.md:12`
- `.harmony/capabilities/_ops/policy/acp-operation-classes.md:19`
- `.harmony/capabilities/_ops/policy/acp-operation-classes.md:29`
- `.harmony/capabilities/_ops/policy/acp-operation-classes.md:35`

Policy mapping source:
- `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:134` (`git.commit` ACP-1)
- `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:149` (`git.merge` protected ACP-2)
- `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:247` (`fs.soft_delete` ACP-3)
- `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:261` (`fs.hard_delete` finalize ACP-4 deny on missing)
- `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:274` (`db.migrate` ACP-2)
- `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:289` (`db.tombstone` ACP-3)
- `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:304` (`db.hard_delete` finalize ACP-4)
- `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:348` (`resource.detach` ACP-3)
- `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:363` (`resource.finalize_destroy` ACP-4)

### 3.6 Reversibility and soft-destruction implementation

- Policy requires reversibility for ACP-1+ and blocks irreversible primitives outside break-glass:
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:372`
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:406`
- Agent wrapper sets default reversible primitive + rollback handle and applies reversible primitive script:
  - `.harmony/capabilities/services/execution/agent/impl/agent.sh:621`
  - `.harmony/capabilities/services/execution/agent/impl/agent.sh:636`
  - `.harmony/capabilities/services/execution/agent/impl/agent.sh:647`
- Reversible primitive implementations:
  - `.harmony/capabilities/_ops/scripts/policy-reversible-primitives.sh:36` (fs soft delete -> trash manifest)
  - `.harmony/capabilities/_ops/scripts/policy-reversible-primitives.sh:79` (db tombstone manifest)
  - `.harmony/capabilities/_ops/scripts/policy-reversible-primitives.sh:108` (resource detach/archive manifest)

### 3.7 Quorum + attestation binding

- Policy quorum requirements:
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:446`
- Required attestation fields and hash binding:
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:455`
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:470`
- Runtime test assertions for ACP-2 stage-only without independent quorum + allow with verifier/recovery:
  - `.harmony/capabilities/_ops/tests/test-deny-by-default-runtime.sh:508`
  - `.harmony/capabilities/_ops/tests/test-deny-by-default-runtime.sh:527`

### 3.8 Budgets + circuit breakers

- Budget sets and breaker sets in policy:
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:413`
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:476`
- Engine breaker actions and mapping:
  - `.harmony/runtime/crates/policy_engine/src/lib.rs:1120`
  - `.harmony/runtime/crates/policy_engine/src/lib.rs:1694`
- Wrapper breaker action runner and rollback/kill-switch behavior:
  - `.harmony/capabilities/_ops/scripts/policy-circuit-breaker-actions.sh:118`
  - `.harmony/capabilities/_ops/scripts/policy-circuit-breaker-actions.sh:138`
  - `.harmony/capabilities/_ops/scripts/policy-circuit-breaker-actions.sh:141`
  - `.harmony/capabilities/_ops/scripts/policy-circuit-breaker-actions.sh:171`

### 3.9 Receipts + append-only oversight

- Receipt writer creates immutable receipt/digest entries and appends ACP decision log/index:
  - `.harmony/capabilities/_ops/scripts/policy-receipt-write.sh:104`
  - `.harmony/capabilities/_ops/scripts/policy-receipt-write.sh:148`
  - `.harmony/capabilities/_ops/scripts/policy-receipt-write.sh:169`
  - `.harmony/capabilities/_ops/scripts/policy-receipt-write.sh:186`
- Policy requires receipts for ACP-1+ on all decisions:
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:512`
  - `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:513`

### 3.10 CI and assurance parity

- CI workflow executes strict validator and SLO report:
  - `.github/workflows/deny-by-default-gates.yml:34`
  - `.github/workflows/deny-by-default-gates.yml:39`
- Validator runs policy doctor + services/skills checks + runtime tests:
  - `.harmony/capabilities/_ops/scripts/validate-deny-by-default.sh:246`
  - `.harmony/capabilities/_ops/scripts/validate-deny-by-default.sh:344`

Command evidence (local):
- `./.harmony/capabilities/_ops/scripts/validate-deny-by-default.sh --all --profile strict` -> all checks passed; runtime deny-by-default tests `38 passed, 0 failed`.
- `cargo test -p policy_engine` -> `21 passed, 0 failed` (3 unit + 18 integration).
- `./.harmony/capabilities/_ops/scripts/policy-rollout-mode.sh slo-report --fail-on-breach` -> passed with JSON metrics output.

## 4) Fail-Closed Matrix (Executed)

| Case | Command | Result |
|---|---|---|
| Unknown `operation.class` | `run-harmony-policy.sh acp-enforce --request /tmp/acp-unknown-class.json` | `DENY`, `ACP_RULE_NO_MATCH`, exit 13 |
| Missing required `operation.class` | `run-harmony-policy.sh acp-enforce --request /tmp/acp-missing-class.json` | `DENY`, `ACP_RULE_NO_MATCH`, exit 13 |
| Malformed policy YAML | `run-harmony-policy.sh acp-enforce --policy /tmp/policy-malformed.yml ...` | deny envelope (`DDB025_RUNTIME_DECISION_ENGINE_ERROR`), exit 2 |
| Schema-mismatch policy | `run-harmony-policy.sh doctor --policy /tmp/policy-schema-mismatch.yml ...` | `valid:false`, required section/property failures, exit 1 |
| Missing phase on mutating op | runtime test script | `STAGE_ONLY`, includes `ACP_PHASE_REQUIRED` |
| Missing quorum/evidence for ACP-2 promote | runtime test script | `STAGE_ONLY`, includes `ACP_QUORUM_MISSING` |
| ACP-4 finalize without break-glass | `run-harmony-policy.sh acp-enforce --request /tmp/acp4-request.json` | `DENY`, `effective_acp: ACP-4`, includes `RA_BREAK_GLASS_REQUIRED` |

## 5) Controlled Scenario Artifacts (Receipts/Digests/Logs)

### ACP-1 operation (stage-only)
- Run: `runtime-acp-receipt-4527-77479`
- Receipt: `.harmony/continuity/runs/runtime-acp-receipt-4527-77479/receipt.json`
- Digest: `.harmony/continuity/runs/runtime-acp-receipt-4527-77479/digest.md`
- Ledger: `.harmony/capabilities/_ops/state/logs/acp-decisions.jsonl` (entry with same run_id)
- Key fields verified: `run_id,timestamp,actor,profile,operation,phase,effective_acp,decision,reason_codes,reversibility,attestations,budgets,counters`

### ACP-2 promote without quorum (STAGE_ONLY)
- Run: `runtime-agent-quorum-stage-25324-77479`
- Receipt: `.harmony/continuity/runs/runtime-agent-quorum-stage-25324-77479/receipt.json`
- Digest: `.harmony/continuity/runs/runtime-agent-quorum-stage-25324-77479/digest.md`
- Ledger: `.harmony/capabilities/_ops/state/logs/acp-decisions.jsonl`
- Decision: `STAGE_ONLY` with `ACP_QUORUM_MISSING` and role mismatch reason code

### ACP-2 promote with quorum (ALLOW)
- Run: `runtime-agent-quorum-allow-19229-77479`
- Receipt: `.harmony/continuity/runs/runtime-agent-quorum-allow-19229-77479/receipt.json`
- Digest: `.harmony/continuity/runs/runtime-agent-quorum-allow-19229-77479/digest.md`
- Ledger: `.harmony/capabilities/_ops/state/logs/acp-decisions.jsonl`
- Decision: `ALLOW`; proposer/verifier/recovery attestations present and hash-bound

### ACP-4 finalize without break-glass (DENY)
- Direct check executed: `/tmp/acp4-request.json` via `acp-enforce` -> `DENY` (`ACP-4`, `RA_BREAK_GLASS_REQUIRED`)
- Existing receipt-backed run evidence:
  - `.harmony/continuity/runs/audit-ra-acp4-deny/receipt.json`
  - `.harmony/continuity/runs/audit-ra-acp4-deny/digest.md`
  - `.harmony/capabilities/_ops/state/logs/acp-decisions.jsonl` (run_id `audit-ra-acp4-deny`)

## 6) Gaps and Fixes

### Gap A: Taxonomy mismatch for `fs.soft_delete`

- Impact: Policy/docs inconsistency can cause incorrect operator expectations and migration mistakes.
- Evidence:
  - Taxonomy says ACP-3 if broad, ACP-1 if local: `.harmony/capabilities/_ops/policy/acp-operation-classes.md:19`
  - Policy enforces ACP-3 unconditionally for `fs.soft_delete`: `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml:247`
- Files to change:
  - `.harmony/capabilities/_ops/policy/acp-operation-classes.md`
  - or `.harmony/capabilities/_ops/policy/deny-by-default.v2.yml` (add scoped ACP-1 branch if intended)
- Recommended fix:
  - Choose one canonical behavior and align both files; if dual behavior is intended, encode target-based match rules in policy.
- How to test:
  - `run-harmony-policy.sh doctor ...`
  - runtime ACP eval with local vs broad `target.path` payloads
  - `validate-deny-by-default.sh --all --profile strict`

### Gap B: ACP-4 deny path is not explicitly asserted in current runtime smoke script

- Impact: Critical irreversible path could regress without CI catching it in the shell-level runtime suite.
- Evidence:
  - Explorer review of `.harmony/capabilities/_ops/tests/test-deny-by-default-runtime.sh` found no explicit ACP-4 test branch.
- Files to change:
  - `.harmony/capabilities/_ops/tests/test-deny-by-default-runtime.sh`
- Recommended fix:
  - Add a test case constructing `phase=finalize`, `operation.class=fs.hard_delete` or `db.hard_delete`, `break_glass=false`, then assert `DENY` + `RA_BREAK_GLASS_REQUIRED` and receipt/log emission.
- How to test:
  - `./.harmony/capabilities/_ops/tests/test-deny-by-default-runtime.sh`
  - `./.harmony/capabilities/_ops/scripts/validate-deny-by-default.sh --all --profile strict`

### Gap C: Raw `acp-enforce` CLI path does not itself emit receipt/digest artifacts

- Impact: Direct engine invocations can bypass oversight artifacts unless callers use wrapper receipt writer.
- Evidence:
  - `run-harmony-policy.sh acp-enforce` returns decision JSON only (no artifact path creation); receipt generation occurs in wrapper scripts (`policy-receipt-write.sh`).
- Files to change:
  - `.harmony/capabilities/_ops/scripts/run-harmony-policy.sh`
  - or keep contract explicit in docs and enforce wrapper-only usage for runtime paths
- Recommended fix:
  - Either add an optional `--emit-receipt` mode in ACP CLI wrapper or codify/enforce “runtime must call wrapper gate that emits receipts”.
- How to test:
  - Direct `acp-enforce` invocation should produce (or explicitly forbid) missing receipt behavior with deterministic policy outcome.

## 7) Risk Notes

- Residual risk: taxonomy drift (`acp-operation-classes.md` vs policy rule logic) can silently undermine runbook expectations.
- Residual risk: ACP-4 shell-level regression coverage is currently indirect (engine tests + historical receipts), not explicit in runtime smoke harness.
- Residual risk: users/scripts calling raw ACP engine CLI can obtain policy decisions without guaranteed receipt emission unless wrapper path is used.

