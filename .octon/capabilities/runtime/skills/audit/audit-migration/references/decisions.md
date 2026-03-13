---
decisions:
  - id: execution-mode
    point: "Phase 1: Configure"
    question: "Should the run execute in unified mode or partition mode?"
    branches:
      - condition: "partition and file_filter are provided"
        label: partition_mode
        next_phase: "Phase 2 with partition-scoped coverage"
      - condition: "partition settings are absent"
        label: unified_mode
        next_phase: "Phase 2 over full scope"

  - id: optional-layer-inclusion
    point: "Phase 1: Configure"
    question: "Are optional layers enabled by provided parameters?"
    branches:
      - condition: "structure_spec provided"
        label: add_structure_diff
        next_phase: "Run structure diff after core layers"
      - condition: "template_dir provided"
        label: add_template_smoke_test
        next_phase: "Run template smoke test after core layers"
      - condition: "Neither provided"
        label: core_only
        next_phase: "Proceed with mandatory 3-layer audit"

default_path: ["Configure", "Grep Sweep", "Cross-Reference Audit", "Semantic Read-Through", "Self-Challenge", "Report"]
---

# Decision Reference

Branching is configuration driven:

- Partition parameters select scoped parallel mode.
- Optional parameters enable extra audit layers.

Core layer order remains fixed and non-interleaved.
