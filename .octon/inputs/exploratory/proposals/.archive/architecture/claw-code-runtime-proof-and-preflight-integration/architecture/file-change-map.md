# File Change Map

| Target artifact | Change class | Authority class | New / existing | Why touched | Concepts served | Required for real usability? | Migration needed? |
|---|---|---|---|---|---|---|---|
| `.octon/framework/lab/scenarios/registry.yml` | edit | framework authority | existing | register repo-shell-supported scenario | 1 | yes | no |
| `.octon/framework/lab/scenarios/packs/repo-shell/repo-shell-supported-scenario.yml` | create | framework authority | new | authored repo-shell-supported scenario pack | 1 | yes | no |
| `.octon/framework/engine/runtime/adapters/host/repo-shell.yml` | edit | framework authority | existing | reference classifier semantics and receipt expectations | 2 | yes | no |
| `.octon/framework/engine/runtime/spec/policy-interface-v1.md` | edit | framework authority | existing | define classifier payload/receipt expectations | 2 | yes | no |
| `.octon/instance/governance/policies/repo-shell-execution-classes.yml` | create | instance authority (enabled overlay-compatible policy surface) | new | repo-specific path/command classification rules | 2 | yes | no |
| `.octon/framework/observability/governance/failure-taxonomy.yml` | edit | framework authority | existing | expand failure classes for doctor, preflight, degraded startup, and scenario proof | 4 | yes | no |
| `.octon/framework/observability/governance/reporting.yml` | edit | framework authority | existing | require short machine-grounded summaries citing failure classes | 4 | yes | no |
| `.octon/instance/bootstrap/START.md` | edit | instance authority | existing | point onboarding to bootstrap-doctor and its receipt posture | 3 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/manifest.yml` | edit | framework authority | existing | make new workflows discoverable | 1,3,5 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/registry.yml` | edit | framework authority | existing | make new workflows discoverable | 1,3,5 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/README.md` | edit | framework authority | existing | list new workflows and their role | 1,3,5 | no, but strongly recommended | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/agent-led-happy-path/README.md` | edit | framework authority | existing | add bootstrap-doctor prerequisite | 3 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/agent-led-happy-path/workflow.yml` | edit | framework authority | existing | require or consume bootstrap-doctor readiness result | 3 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/bootstrap-doctor/README.md` | create | framework authority | new | operator/runtime entrypoint for preflight | 3 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/bootstrap-doctor/workflow.yml` | create | framework authority | new | canonical doctor workflow contract | 3 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/bootstrap-doctor/stages/01-inline.md` | create | framework authority | new | stage logic for doctor workflow | 3 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/repo-consequential-preflight/README.md` | create | framework authority | new | operator/runtime entrypoint for branch freshness preflight | 5 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/repo-consequential-preflight/workflow.yml` | create | framework authority | new | canonical preflight workflow contract | 5 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/repo-consequential-preflight/stages/01-inline.md` | create | framework authority | new | stage logic for branch freshness and broad-verification guard | 5 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/run-repo-shell-supported-scenario/README.md` | create | framework authority | new | operator/runtime entrypoint for supported scenario execution | 1 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/run-repo-shell-supported-scenario/workflow.yml` | create | framework authority | new | canonical scenario-run workflow contract | 1 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/run-repo-shell-supported-scenario/stages/01-inline.md` | create | framework authority | new | stage logic for repo-shell-supported scenario execution | 1 | yes | no |
| `.octon/instance/governance/policies/branch-freshness.yml` | create | instance authority (enabled overlay-compatible policy surface) | new | repo-specific freshness action policy | 5 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/add-api-endpoint/workflow.yml` | edit | framework authority | existing | require repo-consequential-preflight before broad verification | 5 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/add-ui-feature/workflow.yml` | edit | framework authority | existing | require repo-consequential-preflight before broad verification | 5 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/fix-a-bug/workflow.yml` | edit | framework authority | existing | require repo-consequential-preflight before broad verification | 5 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/handle-security-issue/workflow.yml` | edit | framework authority | existing | require repo-consequential-preflight before broad verification | 5 | yes | no |
| `.octon/framework/orchestration/runtime/workflows/tasks/run-data-migration/workflow.yml` | edit | framework authority | existing | require repo-consequential-preflight before broad verification | 5 | yes | no |
| `.octon/framework/assurance/functional/suites/repo-shell-execution-classification.yml` | create | framework authority | new | validate repo-shell classifier behavior | 2 | yes | no |
| `.octon/framework/assurance/functional/suites/bootstrap-doctor-readiness.yml` | create | framework authority | new | validate doctor workflow receipt/output integrity | 3,4 | yes | no |
| `.octon/framework/assurance/functional/suites/repo-consequential-preflight.yml` | create | framework authority | new | validate freshness preflight behavior and receipt integrity | 4,5 | yes | no |
| `.octon/framework/assurance/functional/suites/repo-shell-supported-scenario.yml` | create | framework authority | new | validate scenario workflow registration and proof output expectations | 1,4 | yes | no |
| `state/control/execution/runs/<run-id>/checkpoints/bootstrap-doctor.yml` | runtime-emitted | control truth | runtime family | materialize doctor checkpoint | 3 | yes | no |
| `state/control/execution/runs/<run-id>/checkpoints/repo-consequential-preflight.yml` | runtime-emitted | control truth | runtime family | materialize freshness preflight checkpoint | 5 | yes | no |
| `state/evidence/lab/<scenario-run-id>/**` | runtime-emitted | retained evidence | runtime family | retain scenario proof, replay bundle, and related evidence | 1 | yes | no |
| `state/evidence/validation/publication/**` | runtime-emitted | retained evidence | runtime family | retain publication-ready receipts for doctor/scenario/preflight claims | 1,3,5 | yes | no |
| `generated/cognition/summaries/operators/**` | runtime-generated | derived view | runtime family | operator digests and degraded summaries | 3,4,5 | yes, as a derived touchpoint | no |
