---
behavior:
  phases:
    - name: "Configure"
      steps:
        - "Parse domain_path, criteria, evidence_depth, severity_threshold, and domain_profiles_ref"
        - "Resolve target mode: observed (path exists) or prospective (path missing but valid .octon domain target)"
        - "Load domain profile registry for baseline expectations"
        - "Enumerate in-scope files (observed) or comparator domains and profile evidence (prospective)"
    - name: "Surface Mapping"
      isolation: true
      steps:
        - "Map top-level surfaces and subsurfaces"
        - "Assign stated/observed responsibilities"
        - "Capture path-level evidence for each mapped surface"
        - "In prospective mode, mark absent surfaces explicitly and map expected surface shape from profile baseline"
    - name: "External Evaluation"
      isolation: true
      steps:
        - "Evaluate modularity, discoverability, coupling, operability, change safety, and testability"
        - "Treat in-repo governance/contracts as evidence only"
        - "Record strengths and liabilities with falsifiable claims"
        - "Tag each finding as observed-evidence or prospective-inference"
    - name: "Gap and Excess Analysis"
      isolation: true
      steps:
        - "Identify missing surfaces/subsurfaces"
        - "Identify redundant or overlapping surfaces/subsurfaces"
        - "Identify over-engineered structures with low external value"
        - "For prospective mode, separate currently-missing implementation gaps from design-level risks"
    - name: "Self-Challenge"
      steps:
        - "Re-check evidence sufficiency for each major claim"
        - "Demote claims that lack strong path-level support"
        - "Capture unresolved unknowns and blocking questions"
        - "Verify no fabricated on-disk evidence appears in prospective mode"
    - name: "Report"
      steps:
        - "Generate sectioned report with required output contract"
        - "Prioritize recommendations by impact/risk and implementation cost"
        - "Emit assumptions explicitly"
        - "State target mode and evidence confidence profile"
  goals:
    - "Domain architecture map grounded in file-path evidence"
    - "Externally-oriented evaluation independent of local doctrine"
    - "Actionable recommendations with clear tradeoffs"
    - "Explicit unknowns where evidence is insufficient"
    - "Consistent critique quality for existing and planned domains"
---

# Behavior Phases

This skill runs a six-phase architecture critique loop. Each analysis phase must
complete before the next to keep findings attributable and reproducible.

## Target Modes

- `observed` - Domain path exists and is audited directly.
- `prospective` - Domain path is missing but valid as a Octon domain target.
  The run critiques architecture readiness using profile baselines and
  comparator-domain evidence.

## Severity Heuristic

- `CRITICAL` - Structural flaw likely to cause failures, unsafe changes, or major operability risk
- `HIGH` - Significant maintainability/coupling risk with clear downstream impact
- `MEDIUM` - Notable clarity/discoverability or testability issue
- `LOW` - Minor improvement opportunity with limited risk impact
