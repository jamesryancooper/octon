---
decisions:
  - id: deployment-target
    point: "Phase 3: Deploy"
    question: "Should this run target preview or production?"
    branches:
      - condition: "environment is production"
        label: prod
        next_phase: "Run `vercel --prod`"
      - condition: "environment is preview or omitted"
        label: preview
        next_phase: "Run `vercel`"

  - id: preflight-gate
    point: "Phase 1: Pre-flight"
    question: "Are CLI, auth, and project link prerequisites satisfied?"
    branches:
      - condition: "All prerequisites pass"
        label: continue
        next_phase: "Phase 2: Build Verification"
      - condition: "Any prerequisite fails"
        label: stop
        next_phase: "Escalate with setup instructions"

default_path: ["Pre-flight", "Build Verification", "Deploy", "Report"]
---

# Decision Reference

Branching is limited to prerequisite gating and deployment target selection.

- Failed preflight stops execution before deployment.
- Target selection controls command path (`vercel` vs `vercel --prod`).
