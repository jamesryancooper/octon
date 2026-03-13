---
checkpoints:
  strategy: phase
  storage: ".octon/capabilities/runtime/skills/_ops/state/runs/vercel-deploy/{{run-id}}/"
  retention: session

  schema:
    - name: preflight_complete
      trigger: "After Phase 1 completes"
      contains:
        - cli_version
        - auth_status
        - project_link_status

    - name: deploy_complete
      trigger: "After Phase 3 completes"
      contains:
        - deployment_environment
        - deployment_url
        - deployment_status

recovery:
  on_resume: "Re-validate preflight before reusing previous deployment intent."
  on_input_change: "If environment changes, restart from preflight."
  on_corruption: "Discard partial state and re-run deployment phase."
---

# Checkpoint Reference

Checkpoint state preserves deployment intent and captured URL artifacts for reliable reporting.

Resume contract:

- State is stored under `.octon/capabilities/runtime/skills/_ops/state/runs/vercel-deploy/{{run-id}}/`.
- Resume re-checks CLI auth/link status before invoking deploy commands.
- Deployment URL is only considered final after successful deploy checkpoint.
