---
decisions:
  - id: ruleset-availability
    point: "Phase 1: Fetch Ruleset"
    question: "Is the configured ruleset reachable and parseable?"
    branches:
      - condition: "Ruleset fetch and parse succeed"
        label: proceed
        next_phase: "Phase 2: Discover Files"
      - condition: "Ruleset fetch fails or parse is unusable"
        label: abort
        next_phase: "Escalate with dependency error"

  - id: scope-cap
    point: "Phase 2: Discover Files"
    question: "Does discovered file count exceed bounded audit scope?"
    branches:
      - condition: "File count <= 500"
        label: continue
        next_phase: "Phase 3: Scan and Classify"
      - condition: "File count > 500"
        label: escalate
        next_phase: "Request narrower target/filter"

default_path: ["Fetch Ruleset", "Discover Files", "Scan and Classify", "Report"]
---

# Decision Reference

The workflow is linear after two upfront gates:

- External ruleset must be reachable.
- Scope must stay inside bounded file limits.

If either gate fails, the run exits with an explicit audit limitation.
