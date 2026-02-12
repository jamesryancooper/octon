---
title: Harmony Principles
description: Operational principles that translate Harmony’s pillars into concrete day-to-day decisions, quality outcomes, and governance checks.
---

# Harmony Principles

Principles are Harmony’s operational translation layer between philosophy and execution: they define how decisions should be made so the pillars remain intact under real delivery pressure.

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

## Audit Snapshot (2026-02-11)

- `docs/principles.md` listed 12 core + 5 agentic principles, while `docs/principles/README.md` indexed only 8 guides.
- Only 3 canonical principles had matching detailed guides (`determinism`, `reversibility`, `hitl-checkpoints`).
- Methodology guarantees (small-batch trunk flow, observability, idempotency, fail-closed governance, no-silent-apply) were not fully represented in the principles index.
- Trust terminology drift existed (`Determinism` vs `Governed Determinism` phrasing).

This index now reflects the reconciled production set.

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
| Core | Ownership and Boundaries | Encode slice ownership and architecture boundaries in tooling and review. | Focus, Continuity, Trust | [Guide](./ownership-and-boundaries.md) |
| Core | Learn Continuously | Convert incidents and outcomes into small evidence-backed improvements. | Insight, Continuity | [Guide](./learn-continuously.md) |
| Agentic | No Silent Apply | Agents produce proposals; humans authorize material side-effects. | Trust, Direction | [Guide](./no-silent-apply.md) |
| Agentic | Determinism and Provenance | Persist model/prompt/run metadata for reproducibility and auditability. | Trust, Insight, Continuity | [Guide](./determinism-and-provenance.md) |
| Agentic | Idempotency | Make mutating operations safe under retries and partial failures. | Trust, Velocity | [Guide](./idempotency.md) |
| Agentic | Guardrails | Apply policy/eval/security gates fail-closed across agent loops. | Trust | [Guide](./guardrails.md) |
| Agentic | HITL Checkpoints | Use risk-tiered human checkpoints at consequential decisions. | Direction, Trust | [Guide](./hitl-checkpoints.md) |

## Relationship to Pillars

| Pillar | Principles |
|---|---|
| Direction through Validated Discovery | Contract-first; Accessibility Baseline; Documentation is Code; No Silent Apply; HITL Checkpoints |
| Focus through Absorbed Complexity | Progressive Disclosure; Simplicity Over Complexity; Locality; Monolith-first Modulith; Ownership and Boundaries |
| Velocity through Agentic Automation | Simplicity Over Complexity; Monolith-first Modulith; Small Diffs, Trunk-based; Flags by Default; Reversibility; Idempotency |
| Trust through Governed Determinism | Single Source of Truth; Deny by Default; Contract-first; Small Diffs, Trunk-based; Flags by Default; Governed Determinism; Observability as a Contract; Security and Privacy Baseline; Accessibility Baseline; Reversibility; Ownership and Boundaries; No Silent Apply; Determinism and Provenance; Idempotency; Guardrails; HITL Checkpoints |
| Continuity through Institutional Memory | Single Source of Truth; Locality; Observability as a Contract; Documentation is Code; Ownership and Boundaries; Learn Continuously; Determinism and Provenance |
| Insight through Structured Learning | Progressive Disclosure; Governed Determinism; Observability as a Contract; Learn Continuously; Determinism and Provenance |

## Quality Attributes Coverage Matrix

Legend: `V` velocity, `M` maintainability, `Sc` scalability, `R` reliability, `Sec` security, `Si` simplicity.

| Principle | V | M | Sc | R | Sec | Si | How the quality attribute is promoted |
|---|---|---|---|---|---|---|---|
| Progressive Disclosure | ✓ | ✓ |  |  |  | ✓ | Reduces cognitive load and review latency by presenting only the needed layer first. |
| Simplicity Over Complexity | ✓ | ✓ |  | ✓ |  | ✓ | Shrinks moving parts and failure surface area. |
| Single Source of Truth |  | ✓ |  | ✓ | ✓ | ✓ | Eliminates drift between implementations, docs, and contracts. |
| Locality | ✓ | ✓ | ✓ |  |  | ✓ | Keeps changes and understanding bounded by slice/context scope. |
| Deny by Default |  |  |  | ✓ | ✓ | ✓ | Prevents unsafe execution paths unless explicitly approved. |
| Monolith-first Modulith | ✓ | ✓ | ✓ | ✓ |  | ✓ | Delays distributed complexity while preserving clean seams for future scale. |
| Contract-first |  | ✓ | ✓ | ✓ | ✓ |  | Makes integration behavior explicit and testable before code lands. |
| Small Diffs, Trunk-based | ✓ | ✓ |  | ✓ |  | ✓ | Maintains short feedback loops and low-risk rollback units. |
| Flags by Default | ✓ |  | ✓ | ✓ | ✓ | ✓ | Supports progressive delivery and instant disablement without redeploys. |
| Governed Determinism |  | ✓ |  | ✓ | ✓ |  | Stabilizes outputs and incident diagnosis across runs and environments. |
| Observability as a Contract | ✓ | ✓ | ✓ | ✓ | ✓ |  | Makes behavior diagnosable and policy-verifiable in production. |
| Security and Privacy Baseline |  | ✓ |  | ✓ | ✓ |  | Enforces redaction, least privilege, and fail-closed security controls. |
| Accessibility Baseline |  | ✓ |  | ✓ |  | ✓ | Prevents inaccessible regressions through defined tests and gates. |
| Documentation is Code | ✓ | ✓ |  | ✓ |  |  | Preserves intent and operational context with versioned change history. |
| Reversibility | ✓ | ✓ |  | ✓ | ✓ |  | Keeps delivery safe through tested rollback and expand/contract migration paths. |
| Ownership and Boundaries | ✓ | ✓ | ✓ | ✓ | ✓ |  | Prevents architectural drift and reduces cross-team coupling risk. |
| Learn Continuously | ✓ | ✓ | ✓ | ✓ |  |  | Converts outcomes into measurable improvements and tighter defaults. |
| No Silent Apply |  | ✓ |  | ✓ | ✓ |  | Keeps high-risk side effects under explicit human authorization. |
| Determinism and Provenance |  | ✓ |  | ✓ | ✓ |  | Creates auditable AI run lineage for reproducible debugging and compliance. |
| Idempotency | ✓ |  | ✓ | ✓ | ✓ |  | Makes retries safe and reduces duplicate side effects under failure conditions. |
| Guardrails |  | ✓ |  | ✓ | ✓ | ✓ | Centralizes policy gates and blocks unsafe execution automatically. |
| HITL Checkpoints | ✓ |  |  | ✓ | ✓ |  | Applies risk-tiered approvals only where consequences are material. |

Coverage assessment: no quality attribute is under-served; all six are represented by multiple principles.

## Methodology Guarantee Alignment

| Methodology guarantee (`docs/methodology/README.md`) | Backing principles | Alignment status |
|---|---|---|
| Spec-first changes (one-pager + ADR + micro-STRIDE) | Contract-first; Documentation is Code; HITL Checkpoints | Covered |
| No silent apply (Plan → Diff → Explain → Test) | No Silent Apply; HITL Checkpoints; Guardrails | Covered |
| Deterministic AI config + drift controls | Governed Determinism; Determinism and Provenance | Covered |
| Observability required (`trace_id` evidence) | Observability as a Contract | Covered |
| Idempotency + rollback + flags | Idempotency; Reversibility; Flags by Default | Covered |
| Fail-closed governance | Guardrails; Deny by Default; Security and Privacy Baseline | Covered |
| Local-first privacy-first handling | Security and Privacy Baseline; Deny by Default | Covered |
| Cost and efficiency guardrails | Learn Continuously; Guardrails; Small Diffs, Trunk-based | Covered |
| Supply-chain provenance and attestation | Determinism and Provenance; Security and Privacy Baseline | Covered |
| Small-batch policy | Small Diffs, Trunk-based; Reversibility | Covered |
| Waiver discipline (time-boxed exceptions) | Guardrails; HITL Checkpoints | Covered |

Principles with weaker direct methodology operationalization:

- `Locality` and `Progressive Disclosure` are operationalized primarily through harness/docs structure and planning artifacts, not explicit CI gates in methodology text.

## Related Documentation

- [Principles reference](../principles.md)
- [Six Pillars](../pillars/README.md)
- [Methodology](../methodology/README.md)
- [Trust pillar](../pillars/trust.md)
- [Governance model](../architecture/governance-model.md)
