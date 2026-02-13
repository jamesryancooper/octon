---
title: Harmony Principles
description: Canonical principles index and thresholds that translate Harmony pillars into enforceable day-to-day engineering and governance behavior.
---

# Harmony Principles

Status: Active (Production)
Last updated: 2026-02-13

Principles are Harmony's operational translation layer between philosophy and execution.

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

Harmony principles are the decision layer between pillars and methodology. They define how day-to-day technical choices preserve the six pillars while optimizing for velocity, maintainability, scalability, reliability, security, and simplicity.

For small teams, default to the smallest viable process, design, and tooling that preserves quality and governance. Escalate ceremony only for higher-risk changes.

## Principle Index

| Category | Principle | Summary | Pillars | Guide |
|---|---|---|---|---|
| Foundational | Progressive Disclosure | Layer context from concise to deep to preserve focus. | Focus, Insight | [Guide](./progressive-disclosure.md) |
| Foundational | Simplicity Over Complexity | Prefer minimal viable solutions; add complexity only with evidence. | Focus, Velocity | [Guide](./simplicity-over-complexity.md) |
| Foundational | Single Source of Truth | Keep each core fact/contract authoritative in one place. | Continuity, Trust | [Guide](./single-source-of-truth.md) |
| Foundational | Locality | Keep context and ownership near the work surface. | Focus, Continuity | [Guide](./locality.md) |
| Foundational | Deny by Default | Deny dangerous actions unless explicitly permitted. | Trust | [Guide](./deny-by-default.md) |
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
| Agentic | No Silent Apply | Agents produce proposals; humans authorize material side-effects. | Trust, Direction | [Guide](./no-silent-apply.md) |
| Agentic | Determinism and Provenance | Persist model/prompt/run metadata for reproducibility and auditability. | Trust, Insight, Continuity | [Guide](./determinism-and-provenance.md) |
| Agentic | Idempotency | Make mutating operations safe under retries and partial failures. | Trust, Velocity | [Guide](./idempotency.md) |
| Agentic | Guardrails | Apply policy/eval/security gates fail-closed across agent loops. | Trust | [Guide](./guardrails.md) |
| Agentic | HITL Checkpoints | Use risk-tiered human checkpoints at consequential decisions. | Direction, Trust | [Guide](./hitl-checkpoints.md) |

## Concrete Threshold Defaults

These defaults are normative unless a documented waiver applies:

- Branch lifetime: `<= 1 working day`.
- PR size: `<= 400 changed lines` (adds + deletes; generated/lock files excluded).
- One PR, one concern: no mixed refactor + feature + migration in a single diff.
- First human review response: `<= 4 working hours` for active PRs.
- AI deterministic settings: `temperature <= 0.3` for code/spec changes; higher values require explicit PR justification.
- Waiver duration: `<= 7 days` or until merge (whichever is sooner).
- Flag hygiene: each flag must have owner + expiry and be removed within `<= 2 release cycles` after GA.
- Rollback-first rule: if safe fix-forward is not possible within `15 minutes`, execute rollback.
- Incident postmortem SLA: publish within `48 hours` of incident mitigation.
- Mutating APIs and kit calls: `idempotency_key` is mandatory.
- Observability evidence: changed flows must emit OTel spans + structured logs and include a representative `trace_id` in PR evidence.
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
| Spec-first changes (one-pager + ADR + micro-STRIDE) | Contract-first; Documentation is Code; HITL Checkpoints | Covered |
| No silent apply (Plan -> Diff -> Explain -> Test) | No Silent Apply; HITL Checkpoints; Guardrails | Covered |
| Deterministic AI config + drift controls | Governed Determinism; Determinism and Provenance | Covered |
| Observability required (`trace_id` evidence) | Observability as a Contract | Covered |
| Idempotency + rollback + flags | Idempotency; Reversibility; Flags by Default | Covered |
| Fail-closed governance | Guardrails; Deny by Default; Security and Privacy Baseline | Covered |
| Local-first privacy-first handling | Security and Privacy Baseline; Deny by Default | Covered |
| Cost and efficiency guardrails | Learn Continuously; Guardrails; Small Diffs, Trunk-based | Covered |
| Supply-chain provenance and attestation | Determinism and Provenance; Security and Privacy Baseline | Covered |
| Small-batch policy | Small Diffs, Trunk-based; Reversibility | Covered |
| Waiver discipline (time-boxed exceptions) | Guardrails; HITL Checkpoints | Covered |

## Related Docs

- `.harmony/cognition/principles/pillars/README.md`
- `.harmony/cognition/methodology/README.md`
- `.harmony/cognition/architecture/governance-model.md`
- `.harmony/cognition/architecture/observability-requirements.md`
- `.harmony/cognition/architecture/runtime-policy.md`
- `.harmony/cognition/knowledge-plane/knowledge-plane.md`
