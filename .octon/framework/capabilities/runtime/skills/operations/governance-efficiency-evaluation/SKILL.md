---
name: governance-efficiency-evaluation
description: >
  Run a read-only advisory evaluator over retained lifecycle evidence to find
  governance latency, duplicated controls, automation candidates, batching
  candidates, risk-based treatment candidates, and uncertainty without
  authorizing lifecycle transitions.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-07-08"
  updated: "2026-07-08"
skill_sets: []
capabilities: []
allowed-tools: Read Bash(.octon/framework/assurance/runtime/_ops/scripts/collect-governance-efficiency-evidence.sh) Bash(.octon/framework/assurance/runtime/_ops/scripts/evaluate-governance-efficiency.sh) Bash(.octon/framework/assurance/runtime/_ops/scripts/validate-governance-efficiency-report.sh)
---

# Governance Efficiency Evaluation

Use this skill when an operator asks for advisory analysis of governance
latency, repeated controls, automation opportunities, batching opportunities,
or risk-based candidates from retained lifecycle evidence.

## Procedure

1. Identify the target proposal packet, proposal program, or retained lifecycle
   evidence path.
2. Run `collect-governance-efficiency-evidence.sh --target <path>` to collect
   read-only observations.
3. Run `evaluate-governance-efficiency.sh --target <path>` to emit the
   advisory report.
4. Validate the report with `validate-governance-efficiency-report.sh --report
   <path>` when retaining output.

## Boundaries

- Do not use evaluator output to authorize review, validation, closeout,
  cleanup, archive, terminal proof, policy mutation, lifecycle transition,
  branch landing, branch cleanup, or child receipt substitution.
- Do not treat missing evidence as a confident recommendation.
- Do not mutate proposal-local receipts, generated outputs, state/control,
  policy, branch refs, or child lifecycle state from this skill.
- Any recommendation that changes governance requires a future accepted
  proposal and its own validation evidence.
