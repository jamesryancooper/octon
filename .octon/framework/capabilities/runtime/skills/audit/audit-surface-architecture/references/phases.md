---
behavior:
  phases:
    - name: "Configure"
      steps:
        - "Parse surface_path, surface_kind, severity rules, and convergence controls"
        - "Normalize the target path relative to /.octon/"
        - "Enumerate nearby manifests, registries, schemas, validators, docs, and support assets"
        - "Build deterministic scope inventory for coverage accounting"
    - name: "Target Resolution and Applicability Gate"
      isolation: true
      steps:
        - "Resolve whether the target maps to one durable surface unit"
        - "Auto-detect workflow, skill, watcher, automation, service/interface, methodology, or other supported surface kind"
        - "Classify unsupported multi-unit or top-level domain scopes as not-applicable"
        - "Record target class and confidence mode"
    - name: "Authority and Artifact Mapping"
      isolation: true
      steps:
        - "Identify canonical contracts, discovery/index artifacts, validators, support assets, and explanatory docs"
        - "Map consumers and responsibilities for the surface"
        - "Detect hidden authority in examples, conventions, or historical docs"
        - "Record clean coverage proof and artifact map"
    - name: "Surface Needs and Drift Analysis"
      isolation: true
      steps:
        - "Classify the authority model as contract-first, mixed, markdown-first, or human-led/non-executable"
        - "Check machine-readable vs prose obligations for the detected surface kind"
        - "Check validator coverage against true authority artifacts"
        - "Record findings for authority confusion, doc/contract drift, and avoidable split-brain duplication"
    - name: "Self-Challenge"
      steps:
        - "Re-check evidence sufficiency for each non-trivial finding"
        - "Attempt to disprove high-severity findings and downgrade if unsupported"
        - "Search for blind spots in target normalization and artifact discovery"
        - "Record unknowns where architecture claims cannot be evidenced"
    - name: "Report"
      steps:
        - "Generate required sections for surface definition, authority model, findings, target architecture, and non-goals"
        - "Emit stable finding IDs and objective acceptance criteria in bounded bundle mode"
        - "Emit coverage ledger, convergence receipt, and done-gate metadata"
        - "Write report and run log to designated output paths"
  goals:
    - "Evidence-backed authority model classification for one durable Octon surface"
    - "Deterministic detection of hidden authority, validator gaps, and doc/contract drift"
    - "Actionable remediation guidance naming exact durable artifacts"
    - "Convergence-ready outputs for discovery and post-remediation reruns"
---

# Behavior Phases

This skill runs a six-phase surface-architecture audit loop. Each mandatory
layer must complete before the next to keep findings attributable and
reproducible.

## Layer Intent

- `Target Resolution and Applicability Gate` prevents domain-scale and
  multi-unit scopes from receiving a misleading surface verdict.
- `Authority and Artifact Mapping` establishes what the surface actually owns
  before judging its architecture.
- `Surface Needs and Drift Analysis` checks authority, validation, and
  documentation fit for the target surface itself.

## Severity Heuristic

- `CRITICAL` -- Missing or unsafe authority model for an execution-bearing
  surface
- `HIGH` -- Material validator, discovery, or contract/doc split gap
- `MEDIUM` -- Partial/inconsistent authority structure reducing maintainability
- `LOW` -- Minor clarity or consistency issue with limited risk impact
