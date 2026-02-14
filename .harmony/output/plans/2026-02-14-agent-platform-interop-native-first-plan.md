# Plan: Native-First Agent Platform Interop (Provider-Agnostic)

## Context

Harmony must run independently with no external agent platform. Agent platforms are optional and may only extend or complement Harmony. This plan codifies a provider-agnostic interop layer that preserves Harmony as the source of truth for governance, memory, continuity, and quality gates.

This plan also integrates selected runtime concepts (session policy, context budgeting, pruning policy, compaction discipline, memory flush evidence, routing precedence, and presence contracts) into Harmony core semantics while keeping provider-specific implementation details in adapters.

---

## Non-Negotiables

1. Native mode is mandatory: Harmony must operate with zero adapters installed.
2. Platform integrations are optional: extension or complement only.
3. Core contracts must remain provider-agnostic.
4. Provider-specific terms and keys are allowed only inside adapter paths.
5. Material side effects remain governed by:

- `.harmony/cognition/principles/no-silent-apply.md`
- `.harmony/cognition/principles/hitl-checkpoints.md`
- `.harmony/cognition/principles/deny-by-default.md`

---

## Ownership Boundary (Canonical)

| Capability | Harmony Core Owns | Adapter/Platform Owns |
|---|---|---|
| Session policy semantics | Scope/reset/send classes and policy invariants | Mapping to platform API/settings |
| Context budget semantics | Budget model, thresholds, and output schema | Provider token/char accounting details |
| Pruning semantics | Policy classes and guardrails | Native pruning calls and storage internals |
| Memory + compaction semantics | Memory classes, retention, flush-before-compaction policy | Provider memory APIs and persistence backend |
| Multi-agent governance | Routing precedence and delegation rules | Session spawning/transport implementation |
| Presence contract | Required heartbeat fields and evidence requirements | Runtime signal emission |
| Governance controls | HITL, no-silent-apply, fail-closed policy | Platform-specific approval plumbing |
| Provider internals | Out of scope | In scope for adapters only |

This table is promoted into the interop contract as normative content.

---

## Target Structure (Domain-Scoped)

```text
.harmony/capabilities/services/interfaces/agent-platform/
  README.md
  contract.md
  schema/
    capabilities.schema.json
    session-policy.schema.json
  adapters/
    registry.yml
    openclaw/
      adapter.yml
      mapping.md
      compatibility.yml
      fixtures/
```

Rationale: keep adapter architecture explicit under the `interfaces/` domain while preserving clear adapter boundaries.

---

## Versioning Model (Explicit Scope)

1. `interop_contract_version`

- Location: `.harmony/cognition/context/agent-platform-interop.md`
- Scope: governance semantics and boundary rules

2. `adapter_schema_version`

- Location: `.harmony/capabilities/services/interfaces/agent-platform/schema/*.json`
- Scope: machine-readable adapter interface

3. `adapter_version`

- Location: `.harmony/capabilities/services/interfaces/agent-platform/adapters/<id>/adapter.yml`
- Scope: provider implementation release and compatibility range

Compatibility policy:

- Major: breaking behavioral or schema change
- Minor: backward-compatible additive change
- Patch: corrections and clarifications with no contract break

---

## Phases and Exit Gates

## Phase 0: Contract and ADR

Deliverables:

1. Add `.harmony/cognition/context/agent-platform-interop.md`.
2. Add context index entry in `.harmony/cognition/context/index.yml`.
3. Add ADR `.harmony/cognition/decisions/012-agent-platform-interop-native-first.md`.
4. Update quality gates:

- `.harmony/quality/complete.md`
- `.harmony/quality/session-exit.md`

Required content:

- Native-first invariants
- Ownership boundary table
- Fail-closed fallback rules
- Versioning scope and compatibility policy

Exit gate:

- Contract approved
- ADR approved
- Native-first gate added to quality checklists

## Phase 0.5: Existing Coupling Baseline Audit

Purpose: audit current platform-specific references before enabling enforcement.

Deliverables:

1. Baseline report:

- `.harmony/output/reports/2026-02-14-platform-coupling-baseline.md`

2. Classification:

- `allowed-domain`
- `needs-migration`
- `blocked-in-core`

3. Allowlist for temporary exceptions with owners and expiry.

Exit gate:

- Baseline + allowlist approved
- Migration backlog created for `needs-migration` items

## Phase 1: Native Core Mechanisms (No Adapters)

Deliverables:

1. Add core service docs:

- `.harmony/capabilities/services/interfaces/agent-platform/README.md`
- `.harmony/capabilities/services/interfaces/agent-platform/contract.md`

2. Add schemas:

- `.harmony/capabilities/services/interfaces/agent-platform/schema/capabilities.schema.json`
- `.harmony/capabilities/services/interfaces/agent-platform/schema/session-policy.schema.json`

3. Add commands:

- `.harmony/capabilities/commands/context-budget.md`
- `.harmony/capabilities/commands/validate-session-policy.md`

4. Register commands in:

- `.harmony/capabilities/commands/manifest.yml`

5. Register `agent-platform` service metadata in:

- `.harmony/capabilities/services/manifest.yml`
- `.harmony/capabilities/services/registry.yml`

6. Update memory and compaction semantics:

- `.harmony/agency/MEMORY.md`
- `.harmony/cognition/context/compaction.md`

Compaction/memory semantics added in this phase:

1. Budget warning threshold at `>= 80%`.
2. Mandatory memory flush trigger at `>= 90%` or explicit compaction request.
3. Flush sequence:

- classify session artifacts
- redact sensitive values
- persist durable summary only
- emit evidence record

4. If flush fails, compaction blocks unless explicit HITL waiver.

Evidence output:

- `.harmony/output/reports/<date>-memory-flush-evidence.md`

Exit gate:

- All commands run in native mode
- No adapter dependency
- Evidence record generated for compaction-triggered flushes

## Phase 2: Enforcement Unification (No Parallel Validators)

Decision: extend existing validator instead of adding overlapping scripts.

Primary script:

- `.harmony/capabilities/services/_ops/scripts/validate-service-independence.sh`

Enhancements:

1. Add modes:

- `services-core`
- `platform-core`
- `adapters`

2. Enforce provider-term boundary:

- provider terms are blocked outside `.harmony/capabilities/services/interfaces/agent-platform/adapters/**`

3. Add wrapper command:

- `.harmony/capabilities/commands/validate-platform-interop.md`

Exit gate:

- Anti-coupling checks pass for core paths
- Any exceptions are explicitly allowlisted and time-bounded

## Phase 3: Adapter Framework + OpenCLAW Adapter #1

Definition:

- OpenCLAW refers to the autonomous agent platform documented at `https://docs.openclaw.ai`.

Why first:

1. Strong overlap with target concepts (session lifecycle, pruning, context introspection, memory, multi-agent).
2. Clear public documentation for deterministic mapping.

Deliverables:

1. Add adapter registry:

- `.harmony/capabilities/services/interfaces/agent-platform/adapters/registry.yml`

2. Add OpenCLAW adapter:

- `.harmony/capabilities/services/interfaces/agent-platform/adapters/openclaw/adapter.yml`
- `.harmony/capabilities/services/interfaces/agent-platform/adapters/openclaw/mapping.md`
- `.harmony/capabilities/services/interfaces/agent-platform/adapters/openclaw/compatibility.yml`
- `.harmony/capabilities/services/interfaces/agent-platform/adapters/openclaw/fixtures/*`

3. Keep bootstrap integration opt-in only:

- update `.harmony/scaffolding/_ops/scripts/init-project.sh`
- update `.harmony/capabilities/commands/init.md`

Exit gate:

- OpenCLAW adapter passes conformance checks
- Removing adapter does not impact native mode

## Phase 4: Conformance and Degradation Tests

Deliverables:

1. Adapter conformance suite:

- capability matrix validation
- fallback behavior validation
- evidence hook validation
- compatibility range validation

2. Degradation tests:

- provider unavailable
- partial capability support
- stale adapter version
- permission denied on critical action

Exit gate:

- Deterministic fail-closed behavior for unsupported critical capabilities
- Evidence records present for all degraded paths

## Phase 5: Adapter #2 Proof of Agnosticism

Deliverables:

1. Implement second provider adapter under same contract.
2. Confirm adapter-only diff for onboarding.

Exit gate:

- No core contract/schema changes required for adapter #2
- Confirms provider-agnostic architecture in practice

---

## Borrowed Concepts Integrated into Harmony Core

1. Session policy semantics (scope/reset/send classes)
2. Context budget model and reporting
3. Pruning policy classes
4. Memory flush-before-compaction policy
5. Multi-agent routing precedence rules
6. Presence evidence schema

These are provider-agnostic and become Harmony-native semantics.

## Concepts Remaining in Platforms

1. Provider API names and config keys
2. Session database/storage internals
3. Tokenization/model accounting internals
4. Provider UI/runtime execution internals
5. Provider-specific transport/tool plumbing

---

## Measurable Success Criteria

1. Native mode passes required checks with zero adapters installed.
2. `context-budget` command emits deterministic native-mode report output.
3. Compaction-triggered runs emit `memory_flush` evidence artifact.
4. Anti-coupling validator reports zero provider-term leaks in core paths.
5. Adding provider #2 requires adapter-only changes.

---

## Risks and Mitigations

1. Risk: enforcement blocks existing valid docs that mention platforms.

- Mitigation: Phase 0.5 baseline allowlist with owner and expiry.

2. Risk: compaction flush policy becomes too strict.

- Mitigation: HITL override path with explicit waiver evidence.

3. Risk: adapter sprawl and inconsistent quality.

- Mitigation: conformance suite required before adapter activation.

---

## Immediate Next Actions

1. Execute Phase 0 artifact creation.
2. Execute Phase 0.5 baseline audit and approval.
3. Begin Phase 1 native command/schema implementation.
