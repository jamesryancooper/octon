---
decisions:
  - id: contract-baseline-selection
    point: "Phase 1: Configure"
    question: "Which observability baseline should this run use?"
    branches:
      - condition: "observability_contract_ref exists and is readable"
        label: explicit_contract
        next_phase: "Use referenced contract as baseline expectations"
      - condition: "observability_contract_ref missing, but in-scope artifacts express usable baseline signals"
        label: inferred_baseline
        next_phase: "Use local evidence baseline and mark inference boundaries"
      - condition: "No reliable baseline can be established"
        label: baseline_blocked
        next_phase: "Escalate with explicit evidence gap"

  - id: surface-discovery-strategy
    point: "Phase 1: Configure"
    question: "How are in-scope service surfaces discovered?"
    branches:
      - condition: "service manifests found via service_manifest_glob"
        label: manifest_driven
        next_phase: "Use service manifest inventory as primary surface list"
      - condition: "no manifests found but scope has candidate observability artifacts"
        label: artifact_driven
        next_phase: "Use artifact-linked surfaces and mark reduced confidence"
      - condition: "neither manifests nor artifacts produce auditable surfaces"
        label: no_surfaces
        next_phase: "Escalate with empty-scope audit result"

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
    "Signal Contract Coverage",
    "SLO and Alert Coverage",
    "Runbook and Dashboard Coverage",
    "Self-Challenge",
    "Report",
  ]
---

# Decision Reference

Branching is controlled by baseline selection, surface discovery reliability,
and done-gate mode.

Decision guardrails:

- Prefer explicit contract baselines when available.
- If baselines are inferred, mark confidence boundaries clearly.
- Never imply strict remediation pass criteria unless `post_remediation=true`.
