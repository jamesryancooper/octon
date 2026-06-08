# Implementation Plan

1. Add `.octon/framework/orchestration/runtime/workflows/meta/lifecycle-postmortem/workflow.yml`.
2. Add workflow stage files for evidence binding, evaluator invocation,
   finding materialization, and final report.
3. Add a runtime command branch for `octon lifecycle postmortem --run-id`.
4. Reuse existing run lifecycle reconstruction surfaces where practical.
5. Write outputs under the retained run assurance evidence root.
6. Add done gates that forbid lifecycle authority mutation.
7. Run workflow validation and the lifecycle-postmortem validator once the
   validator child lands.

The implementation must keep the postmortem optional by default. A later policy
change may require postmortems for selected lifecycle classes, but that should
be a separate governed change.
