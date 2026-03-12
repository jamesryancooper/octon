# Existing Surface Gap Analysis

## Goal

Determine whether Harmony already contains a like-for-like architecture
evaluation framework that should be extended instead of building a new one.

## Overlap Assessment

| Surface | Current role | Why it is not sufficient alone | Decision |
|---|---|---|---|
| `audit-domain-architecture` skill | External architecture critique for a Harmony domain | Domain-only, optimized for external robustness criteria rather than governed architecture-readiness scoring and promotion gates | Keep separate; optionally reuse as supplemental evidence |
| `audit-cross-subsystem-coherence` skill | Whole-harness contract/coherence audit | Detects drift and contradictions, but does not provide the targeted scorecard, failure-mode analysis, or ADR acceptance lens from this package | Reuse as optional whole-harness evidence stage |
| `audit-subsystem-health` skill | Internal schema/config coherence audit | Focused on manifests, registries, and semantic quality, not architecture-readiness | Keep separate |
| `evaluate-harness` workflow | Structure and token-efficiency review of a `.harmony` directory | Meta structure evaluator, not a governed autonomous engineering architecture audit | Do not extend |
| `evaluate-workflow` workflow | Structure and README drift review for workflows | Workflow authoring evaluator, not architecture readiness | Do not extend |
| `audit-release-readiness` workflow | Layered release gate across readiness audits | Release-focused, downstream of architecture, and not designed to classify domain applicability | Do not extend directly |

## Conclusion

Harmony does not already contain a like-for-like architecture-readiness
framework for whole-harness and bounded-surface domain evaluation.

The best fit is a **new dedicated skill and workflow** that compose with
existing audits where useful, without changing the semantics of current
surfaces.
