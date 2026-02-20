---
dependencies:
  services:
    - name: vercel_cli
      type: cli
      required: true
      availability_check: "vercel --version"
      purpose: "Fetch deployment metadata and status from Vercel"

    - name: deployment_endpoint
      type: http
      required: false
      availability_check: "HTTP reachability check when URL is available"
      purpose: "Optional readiness signal for externally reachable deploy URL"

failure_handling:
  transient:
    - condition: "Network timeout while checking URL"
      action: "Mark verification as degraded and include retry guidance"
  terminal:
    - condition: "Vercel CLI unavailable or unauthenticated"
      action: "Stop and escalate with setup instructions"
---

# Dependency Reference

`deploy-status` depends on Vercel CLI status signals and may optionally verify
the returned deployment endpoint with a lightweight network check.
