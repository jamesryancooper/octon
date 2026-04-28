# Migration and Cutover Plan

1. Land schemas and policy surfaces in `framework/**` and `instance/**`.
2. Add control/evidence root conventions.
3. Add validators in stage-only / dry-run mode.
4. Add CLI/runtime commands with fail-closed behavior.
5. Run negative controls.
6. Enable candidate creation for retained evidence sources.
7. Enable proposal compiler.
8. Enable promotion dry-run.
9. Enable promotion apply only after accepted Decision Request exists.
10. Require recertification before implemented closure.
