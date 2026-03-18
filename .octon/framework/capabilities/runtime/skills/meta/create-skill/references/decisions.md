---
decisions:
  - id: alignment-gate
    point: "Phase 1: Validate"
    question: "Can requested behavior fit existing contracts without schema changes?"
    branches:
      - condition: "aligned"
        label: proceed
        next_phase: "Phase 2: Copy Template"
      - condition: "extension-proposed"
        label: escalate
        next_phase: "Stop and produce extension proposal"

  - id: uniqueness-gate
    point: "Phase 1: Validate"
    question: "Does a skill with the same id already exist?"
    branches:
      - condition: "Skill id is unique"
        label: continue
        next_phase: "Phase 2: Copy Template"
      - condition: "Skill id already exists"
        label: stop
        next_phase: "Request rename or explicit overwrite approval"

default_path: ["Validate", "Copy Template", "Initialize", "Update Registry", "Update Catalog", "Report Success"]
---

# Decision Reference

Two blocking decisions happen before scaffolding:

- Alignment-first gate (`aligned` vs `extension-proposed`).
- Skill id uniqueness gate.

If either fails, no file writes should proceed.
