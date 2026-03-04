---
title: Harmony Principles
description: Canonical principles index and thresholds that translate Harmony pillars into enforceable day-to-day engineering and governance behavior.
---

# Harmony Principles

Status: Active (Production)
Last updated: 2026-03-04

Principles are Harmony's operational translation layer between philosophy and execution.

## Machine Discovery

- `index.yml` - canonical machine-readable principles index.

```text
Convivial Purpose (WHY)
        ↓
   Six Pillars (WHAT)
        ↓
   Principles (HOW) ← You are here
        ↓
   Methodology (WHEN)
        ↓
      Kits (WITH)
```

## Scope

Harmony principles are the decision layer between pillars and methodology. They define how day-to-day technical choices preserve the six pillars while optimizing for velocity, maintainability, scalability, reliability, security, and minimal sufficient complexity.

For small teams, default to the smallest robust solution that meets constraints for process, design, and tooling while preserving quality and governance. Escalate ceremony only for higher-risk changes.

## Taxonomy (Charter vs Guides)

The principles surface contains three distinct artifact classes:

- **Charter**: `principles.md` (constitutional, human-override controlled).
- **Operational guides**: individual principle guides (for day-to-day execution behavior).
- **Mapping/index contracts**: `charter-map.yml` and `index.yml` (machine-readable traceability and discovery).

Machine-readable mapping from charter principles (`P1..P10`) to operational guides is canonical in:

- [charter-map.yml](./charter-map.yml)

## Constitutional Charter (Human-Override Controlled)

- Canonical charter: [Engineering Principles & Standards (Authoritative)](./principles.md)
- Classification: constitutional artifact (`mutability: immutable`, `agent_editable: false`, `risk_tier: critical`, `change_policy: human-override-only`)
- Agent rule: agents MUST NOT modify `principles.md` without explicit human override instructions
- Evolution model: default to versioned successor (`principles-vYYYY-MM-DD.md`) plus ADR; direct edits to `principles.md` require explicit human override + override evidence
- Major framing-shift rule: require an explicit human override block in `principles.md` with rationale, responsible owner, review date, override scope, review/agreement evidence, and intentional non-automated exception log linkage.
- Direct-edit evidence ledger: `../exceptions/principles-charter-overrides.md`
  must receive an append-only record for each override edit.
- Active framing: `agent-first`, `system-governed`, and `complexity calibration` language is defined in `principles.md`.

## Charter-to-Guide Mapping

| Charter area | Operational guide SSOTs |
|---|---|
| SSOT and documentation discipline | [Single Source of Truth](./single-source-of-truth.md), [Documentation is Code](./documentation-is-code.md), [Progressive Disclosure](./progressive-disclosure.md) |
| Boundaries and contracts | [Ownership and Boundaries](./ownership-and-boundaries.md), [Contract-first](./contract-first.md) |
| Managed complexity and complexity fitness | [Complexity Calibration](./complexity-calibration.md), [Monolith-first Modulith](./monolith-first-modulith.md) |
| Quality and operational readiness | [Observability as a Contract](./observability-as-a-contract.md), [Reversibility](./reversibility.md), [Small Diffs, Trunk-based](./small-diffs-trunk-based.md) |
| Security and privacy | [Security and Privacy Baseline](./security-and-privacy-baseline.md), [Deny by Default](./deny-by-default.md), [Guardrails](./guardrails.md) |
| Exceptions and governance | [Arbitration and Precedence](./arbitration-and-precedence.md), [Autonomous Control Points](./autonomous-control-points.md), [Waivers and Exceptions](../exceptions/waivers-and-exceptions.md) |
| RA/ACP control contracts | [RA/ACP Glossary](../controls/ra-acp-glossary.md), [RA/ACP Promotion Inputs Matrix](../controls/ra-acp-promotion-inputs-matrix.md), [Flag Metadata Contract](../controls/flag-metadata-contract.md), [Promotable Slice Decomposition](../controls/promotable-slice-decomposition.md) |
| Convivial impact contract | [Convivial Impact Minimums](../controls/convivial-impact-minimums.md), [Convivial Impact Minimums (YAML)](../controls/convivial-impact-minimums.yml) |

## Normative SSOT Map

Use one canonical source per governance topic to prevent drift:

| Topic | Canonical principle (SSOT) | Scope |
|---|---|---|
| Promotion/contraction to durable state | [Autonomous Control Points](./autonomous-control-points.md) | stage/promote/finalize semantics, receipts, budgets, quorum, recovery windows |
| Capability attempts and permissions | [Deny by Default](./deny-by-default.md) | fail-closed capability evaluation, scoped grants/exceptions, deterministic permission decisions |
| Replay/provenance and receipt lineage | [Determinism and Provenance](./determinism-and-provenance.md) | required replay fields, provenance fields, receipt-linked reproducibility |
| Telemetry contract | [Observability as a Contract](./observability-as-a-contract.md) | telemetry profiles and minimum signals, constrained by ACP budget/circuit policy |
| Convivial impact minima | [Convivial Impact Minimums](../controls/convivial-impact-minimums.md) | required non-trivial planning/review fields for capability, attention, manipulation, and extraction risks |

## Arbitration & Precedence

### Arbitration Rules

Arbitration resolves principle tensions without weakening RA/ACP governance.
Canonical arbitration contract: [Arbitration and Precedence](./arbitration-and-precedence.md).

Hierarchy:

- **Assurance > Productivity > Integration**

Routine autonomy scope:

- ACP-1 through ACP-3 are routine autonomous operation levels.
- ACP-4 is break-glass only, blocked by default, and out-of-band from normal runs.

Rules:

1. For durable state changes, ACP policy decisions are the final promotion authority.
2. For capability attempts, deny-by-default decisions are the final authorization authority.
3. Assurance principles override Productivity principles, and Productivity overrides Integration when conflicts remain.
4. `No Silent Apply` is satisfied by receipts/evidence/rollback handles, never by standing human approvals.
5. Owner attestation is a quorum input only; it never replaces ACP policy evaluation or required risk-tier quorum.
6. Determinism defaults apply to promote decisions and receipts; bounded variance requires policy bounds and provenance.
7. Observability profile choices must stay within ACP budget/circuit envelopes; downgrades require reason code + receipt linkage.
8. Trunk speed and threshold checks are evaluated per promotable slice, not full mission duration.
9. Any override/waiver must be time-boxed, reason-coded, append-only, and receipt-linked.

Vocabulary normalization:

- Prefer `ACP decision outcome` over `approval`.
- Prefer `policy gate pass` over `sign-off` unless explicitly describing ACP-4 break-glass escalation.

Worked examples:

- Example A (`Small Diffs, Trunk-based` vs ACP): if a change is ready to merge quickly but has material side effects, it must still pass stage -> ACP gate -> promote before durable apply.
- Example B (`Observability as a Contract` vs budgets): if `full` telemetry breaches budget/circuit policy, use approved `sampled` profile and record the waiver in the receipt.

Recording requirement:

- When arbitration is applied, write an append-only decision record (for example ADR under `.harmony/cognition/runtime/decisions/`).
- Include arbitration rationale and affected rule IDs in run receipts/digests (for example `.harmony/continuity/runs/*/receipt.json` note fields).

## Principle Index

| Category | Principle | Summary | Pillars | Guide |
|---|---|---|---|---|
| Foundational | Progressive Disclosure | Layer context from concise to deep to preserve focus. | Focus, Insight | [Guide](./progressive-disclosure.md) |
| Foundational | Complexity Calibration | Favor minimal sufficient complexity; add complexity only with explicit constraint evidence and fitness checks. | Focus, Velocity, Trust | [Guide](./complexity-calibration.md) |
| Foundational | Single Source of Truth | Keep each core fact/contract authoritative in one place. | Continuity, Trust | [Guide](./single-source-of-truth.md) |
| Foundational | Locality | Keep context and ownership near the work surface. | Focus, Continuity | [Guide](./locality.md) |
| Foundational | Arbitration and Precedence | Resolve principle conflicts through deterministic governance tie-breaks. | Trust, Direction | [Guide](./arbitration-and-precedence.md) |
| Foundational | Deny by Default | Deny dangerous actions unless explicitly permitted. | Trust | [Guide](./deny-by-default.md) |
| Foundational | Portability and Independence | Keep core behavior self-contained, tech-agnostic, and OS-agnostic by default. | Velocity, Trust, Continuity | [Guide](./portability-and-independence.md) |
| Core | Monolith-first Modulith | Start modular monolith-first; split only with measured evidence. | Focus, Velocity | [Guide](./monolith-first-modulith.md) |
| Core | Contract-first | Define and govern API/data contracts before implementation. | Direction, Trust | [Guide](./contract-first.md) |
| Core | Small Diffs, Trunk-based | Merge small, single-purpose changes continuously. | Velocity, Trust | [Guide](./small-diffs-trunk-based.md) |
| Core | Flags by Default | Separate deploy from release with server-side flags and cleanup discipline. | Velocity, Trust | [Guide](./flags-by-default.md) |
| Core | Governed Determinism | Make runtime and AI behavior reproducible through pinning and variance controls. | Trust, Insight | [Guide](./determinism.md) |
| Core | Observability as a Contract | Require traces/logs/metrics as part of change completeness. | Continuity, Trust, Insight | [Guide](./observability-as-a-contract.md) |
| Core | Security and Privacy Baseline | Enforce least-privilege, redaction, and fail-closed defaults by policy. | Trust | [Guide](./security-and-privacy-baseline.md) |
| Core | Accessibility Baseline | Treat accessibility verification as a release gate, not polish work. | Direction, Trust | [Guide](./accessibility-baseline.md) |
| Core | Documentation is Code | Version specs, ADRs, and runbooks with the same rigor as implementation. | Direction, Continuity | [Guide](./documentation-is-code.md) |
| Core | Reversibility | Ensure every material change has a tested rollback path. | Trust, Velocity | [Guide](./reversibility.md) |
| Core | Ownership and Boundaries | Encode ownership and architecture boundaries in tooling and review. | Focus, Continuity, Trust | [Guide](./ownership-and-boundaries.md) |
| Core | Learn Continuously | Convert incidents and outcomes into small evidence-backed improvements. | Insight, Continuity | [Guide](./learn-continuously.md) |
| Agentic | No Silent Apply | Agents produce proposals; durable side-effects require ACP evidence and receipts. | Trust, Direction | [Guide](./no-silent-apply.md) |
| Agentic | Determinism and Provenance | Persist model/prompt/run metadata for reproducibility and auditability. | Trust, Insight, Continuity | [Guide](./determinism-and-provenance.md) |
| Agentic | Idempotency | Make mutating operations safe under retries and partial failures. | Trust, Velocity | [Guide](./idempotency.md) |
| Agentic | Guardrails | Apply policy/eval/security gates fail-closed across agent loops. | Trust | [Guide](./guardrails.md) |
| Agentic | Autonomous Control Points | Use policy-gated ACPs for consequential promotions with stage-only fallback and receipts. | Direction, Trust | [Guide](./autonomous-control-points.md) |

### Agentic Principles

- [Autonomous Control Points](./autonomous-control-points.md)
- [No Silent Apply](./no-silent-apply.md)
- [Determinism and Provenance](./determinism-and-provenance.md)
- [Idempotency](./idempotency.md)
- [Guardrails](./guardrails.md)

## Concrete Threshold Defaults

These defaults are normative unless a documented waiver applies:

- Branch lifetime: `<= 1 working day`.
- PR size: `<= 400 changed lines` (adds + deletes; generated/lock files excluded).
- One PR, one concern: no mixed refactor + feature + migration in a single diff.
- When human review is configured, first response target: `<= 4 working hours` for active PRs.
- AI deterministic settings: deterministic mode by default for code/spec changes; higher variance requires explicit policy/receipt justification.
- Waiver duration: `<= 7 days` or until merge (whichever is sooner).
- Flag hygiene: each flag must have owner + expiry and be removed within `<= 2 release cycles` after GA.
- Rollback-first rule: if safe fix-forward is not possible within `15 minutes`, execute rollback.
- Incident postmortem timing guidance: target publication within `48 hours` of incident mitigation.
- Mutating APIs and kit calls: `idempotency_key` is mandatory.
- Observability evidence: changed flows must emit OTel spans + structured logs and include a representative `trace_id` in receipts (and PR projection when PR exists).
- Contract drift threshold: generated implementations are valid only when all required fixtures pass.
- Validation cache policy: content-hash keyed; invalidate immediately on relevant file change.
- Tier 1 validator compliance: required input/output fields and exit-code semantics (`0/1/2/3`) must be preserved.
- Reproducibility minimum: generated implementation manifests must include pinned provenance metadata (contract/rule/fixture hashes, agent/model identifiers, prompt hash, tool surface, timestamp).

## Anti-Principles (Explicitly Rejected)

- Early microservices/choreography without measured need.
- Long-lived branches and big-bang PRs.
- Flaky tests, unbounded retries, and non-deterministic builds.
- Secret or PII/PHI leakage to logs, traces, or third-party tooling.
- Heavy correctness-critical logic at the edge when server runtimes are required.
- Implicit cross-slice coupling and reach-in imports.

## Methodology Guarantee Alignment

| Methodology guarantee | Backing principles | Status |
|---|---|---|
| Spec-first changes (one-pager + ADR + micro-STRIDE) | Contract-first; Documentation is Code; Autonomous Control Points | Covered |
| No silent apply (Plan -> Diff -> Explain -> Test) | No Silent Apply; Autonomous Control Points; Guardrails | Covered |
| Deterministic AI config + drift controls | Governed Determinism; Determinism and Provenance | Covered |
| Observability required (`trace_id` evidence) | Observability as a Contract | Covered |
| Idempotency + rollback + flags | Idempotency; Reversibility; Flags by Default | Covered |
| Fail-closed governance | Guardrails; Deny by Default; Security and Privacy Baseline | Covered |
| Local-first privacy-first handling | Security and Privacy Baseline; Deny by Default | Covered |
| Cost and efficiency guardrails | Learn Continuously; Guardrails; Small Diffs, Trunk-based | Covered |
| Supply-chain provenance and attestation | Determinism and Provenance; Security and Privacy Baseline | Covered |
| Small-batch policy | Small Diffs, Trunk-based; Reversibility | Covered |
| Waiver discipline (time-boxed exceptions) | Guardrails; Autonomous Control Points | Covered |
| Self-contained, stack/host/environment-agnostic operation | Portability and Independence | Covered |

## Related Docs

- `.harmony/cognition/governance/principles/charter-map.yml`
- `.harmony/cognition/governance/principles/arbitration-and-precedence.md`
- `.harmony/cognition/governance/controls/convivial-impact-minimums.md`
- `.harmony/cognition/governance/pillars/README.md`
- `.harmony/cognition/practices/methodology/README.md`
- `.harmony/cognition/_meta/architecture/governance-model.md`
- `.harmony/cognition/_meta/architecture/observability-requirements.md`
- `.harmony/cognition/_meta/architecture/runtime-policy.md`
- `.harmony/cognition/runtime/knowledge/knowledge.md`
