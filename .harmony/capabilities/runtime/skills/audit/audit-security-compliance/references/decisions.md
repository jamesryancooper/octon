---
decisions:
  - id: baseline-selection
    point: "Phase 1: Configure"
    question: "Which baseline should this run use for policy/control intent?"
    branches:
      - condition: "policy_baseline_ref and/or control_baseline_ref exists and is readable"
        label: explicit_baseline
        next_phase: "Use referenced baseline artifacts for expected control checks"
      - condition: "baseline refs unavailable, but in-scope artifacts contain sufficient local baselines"
        label: inferred_baseline
        next_phase: "Use local evidence baseline and mark inference boundaries"
      - condition: "No reliable baseline can be established"
        label: baseline_blocked
        next_phase: "Escalate with explicit evidence gap"

  - id: scope-discovery-strategy
    point: "Phase 1: Configure"
    question: "How are in-scope security/compliance surfaces discovered?"
    branches:
      - condition: "artifact globs produce auditable surfaces"
        label: artifact_driven
        next_phase: "Use discovered artifact inventory for layer checks"
      - condition: "artifact discovery returns empty set"
        label: empty_scope
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
    "Policy and Control Coverage",
    "Secrets and Access Safeguards",
    "Dependency and Evidence Readiness",
    "Self-Challenge",
    "Report",
  ]
---

# Decision Reference

Branching is controlled by baseline selection, artifact discovery reliability,
and done-gate mode.

Decision guardrails:

- Prefer explicit policy/control baselines when available.
- If baselines are inferred, mark confidence boundaries clearly.
- Never imply strict remediation pass criteria unless `post_remediation=true`.
