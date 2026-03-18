---
decisions:
  - id: target-resolution
    point: "Phase 1: Configure"
    question: "How should the domain_path target be interpreted?"
    branches:
      - condition: "domain_path exists and is readable"
        label: observed_mode
        next_phase: "Run full analysis on observed domain surfaces"
      - condition: "domain_path does not exist but matches valid .octon domain target"
        label: prospective_mode
        next_phase: "Run readiness critique using profile baseline and comparator evidence"
      - condition: "domain_path cannot be normalized to a valid Octon domain target"
        label: invalid_target
        next_phase: "Escalate with explicit normalization failure"

  - id: criteria-selection
    point: "Phase 1: Configure"
    question: "Should the run use default external criteria or a caller-provided list?"
    branches:
      - condition: "criteria parameter is provided and non-empty"
        label: caller_criteria
        next_phase: "Use caller criteria for Phase 3 evaluation"
      - condition: "criteria parameter is absent or empty"
        label: default_criteria
        next_phase: "Use default set: modularity, discoverability, coupling, operability, change-safety, testability"

  - id: evidence-depth-selection
    point: "Phase 1: Configure"
    question: "How deep should evidence collection go for this run?"
    branches:
      - condition: "evidence_depth == quick"
        label: quick_pass
        next_phase: "Sample representative surfaces and mark blind spots aggressively"
      - condition: "evidence_depth == standard"
        label: standard_pass
        next_phase: "Enumerate full surface map and run complete criteria evaluation"
      - condition: "evidence_depth == deep"
        label: deep_pass
        next_phase: "Run full evaluation plus additional cross-surface trace checks"

  - id: recommendation-admissibility
    point: "Phase 4: Gap and Excess Analysis"
    question: "Is there enough evidence to issue a concrete architecture recommendation?"
    branches:
      - condition: "At least one high-confidence evidence set supports claim"
        label: recommendation_allowed
        next_phase: "Emit recommendation with priority, benefit, and tradeoff"
      - condition: "Evidence is sparse, conflicting, or indirect"
        label: recommendation_blocked
        next_phase: "Demote to Open Questions / Unknowns"

default_path: ["Configure", "Surface Mapping", "External Evaluation", "Gap and Excess Analysis", "Self-Challenge", "Report"]
---

# Decision Reference

Branching is controlled by target resolution, parameterization, and evidence
sufficiency.

Decision guardrails:

- Missing domains trigger prospective mode, not immediate failure.
- Criteria can be customized, but must remain externally-oriented.
- Unsupported claims are converted into explicit unknowns rather than implied facts.
