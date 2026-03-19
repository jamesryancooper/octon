---
io:
  inputs:
    - name: repository
      type: text
      required: false
      description: "Repository in owner/name format; defaults to the current repository"
    - name: window_runs
      type: text
      required: false
      default: "40"
      description: "Number of recent successful PR runs used for latency analysis"
    - name: top_workflows
      type: text
      required: false
      default: "5"
      description: "Number of slow or regressed workflows to inspect for step hotspots"
    - name: gate_scope
      type: text
      required: false
      default: "required"
      description: "Scope emphasized in the final report: required or all"
  outputs:
    - name: ci_latency_audit_report
      path: "/.octon/state/evidence/validation/analysis/{{date}}-ci-latency-audit-{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Human-readable CI latency audit report"
    - name: ci_latency_summary
      path: "/.octon/state/evidence/validation/analysis/{{date}}-ci-latency-audit-{{run_id}}.json"
      format: json
      determinism: unique
      description: "Machine-readable summary consumed by workflows and follow-on analysis"
    - name: run_log
      path: "/.octon/state/evidence/runs/skills/audit-ci-latency/{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Execution log for this audit run"
    - name: log_index
      path: "/.octon/state/evidence/runs/skills/audit-ci-latency/index.yml"
      format: yaml
      determinism: variable
      description: "Index of prior audit-ci-latency runs"
---

# I/O Contract

## Required Report Sections

1. Policy and Window Summary
2. Required-Path Metrics
3. Workflow Hotspots
4. Step Hotspots
5. Duplicate-Work Candidates
6. Tightening Recommendations
7. Status and Issue Action

## JSON Summary Contract

- `status`
- `issue_action`
- `window`
- `required_path`
- `workflow_metrics`
- `step_hotspots`
- `duplicate_work_candidates`
- `recommendations`

## Evidence Contract

- Required-check membership must be sourced from the GitHub control-plane contract.
- Trend math must be grounded in the requested run window.
- Every non-trivial recommendation must cite workflow or step evidence.
