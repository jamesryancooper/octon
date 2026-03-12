---
decisions:
  - id: target-resolution
    point: "Phase 2: Target Resolution and Applicability Gate"
    question: "Does the target resolve to one durable Harmony surface unit?"
    branches:
      - condition: "surface_path resolves to one supported unit"
        label: supported_surface_unit
        next_phase: "Run authority and artifact mapping"
      - condition: "surface_path resolves to a top-level domain or multi-unit scope"
        label: not_applicable_domain_scale
        next_phase: "Emit not-applicable verdict and recommend audit-domain-architecture or audit-architecture-readiness"
      - condition: "surface_path is unreadable, outside /.harmony/, or cannot be normalized"
        label: configuration_error
        next_phase: "Stop and report configuration error"

  - id: authority-classification
    point: "Phase 4: Surface Needs and Drift Analysis"
    question: "What authority model best matches the evidence?"
    branches:
      - condition: "machine-readable contracts clearly define authoritative behavior"
        label: contract_first
        next_phase: "Preserve contract-first classification and evaluate validator/doc fit"
      - condition: "authority is split across contracts, prose, or conventions"
        label: mixed
        next_phase: "Emit mixed-authority findings and target-state recommendation"
      - condition: "prose acts as canonical operational contract"
        label: markdown_first
        next_phase: "Emit markdown-first findings and target-state recommendation"
      - condition: "surface is durable guidance and not execution-bearing"
        label: human_led_non_executable
        next_phase: "Preserve non-executable classification and evaluate guidance boundaries"

  - id: evidence-sufficiency
    point: "Phase 5: Self-Challenge"
    question: "Is there enough evidence to defend the findings?"
    branches:
      - condition: "all blocking claims are path-backed"
        label: sufficient
        next_phase: "Preserve findings and classification"
      - condition: "one or more blocking claims lack support"
        label: insufficient
        next_phase: "Downgrade unsupported claims and record unknowns"

  - id: done-gate-mode
    point: "Phase 6: Report"
    question: "Should this run enforce strict done-gate pass criteria?"
    branches:
      - condition: "post_remediation == true"
        label: strict_done_gate
        next_phase: "Require convergence stability and zero open findings at/above threshold"
      - condition: "post_remediation == false"
        label: discovery_done_gate
        next_phase: "Record done-gate result for planning only"

default_path:
  [
    "Configure",
    "Target Resolution and Applicability Gate",
    "Authority and Artifact Mapping",
    "Surface Needs and Drift Analysis",
    "Self-Challenge",
    "Report",
  ]
---

# Decision Reference

Branching is controlled by target resolution, authority classification, evidence
sufficiency, and done-gate mode.

Decision guardrails:

- Domain-scale or multi-unit targets never receive a forced surface verdict.
- Authority classification follows evidence, not filename stereotypes.
- Strict remediation pass criteria apply only when `post_remediation=true`.
