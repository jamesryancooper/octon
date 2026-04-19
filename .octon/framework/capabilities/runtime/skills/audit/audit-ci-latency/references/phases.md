# Behavior Phases

## Phase 1: Collect

- Resolve the repository and run-window parameters.
- Run the shared wrapper:
  `bash .octon/framework/execution-roles/_ops/scripts/ci/audit-ci-latency.sh`
- Confirm both Markdown and JSON outputs were produced.

## Phase 2: Classify

- Read the summary JSON first.
- Verify `status`, `issue_action`, and required-path metrics.
- Identify the slowest workflows and any breached thresholds.

## Phase 3: Recommend

- Group findings into safe tightening classes:
  - path-scope tightening
  - workflow consolidation
  - duplicate setup/build removal
  - cache or tool-install optimization
- Keep recommendations concrete and file-scoped.

## Phase 4: Report

- Present the Markdown report.
- Call out the status (`healthy`, `watch`, `breach`) and next safest tightening action.
