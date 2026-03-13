---
name: verify
title: Verify Completion
description: Validate bounded change-risk audit contract and mode-specific done-gate outcomes.
---

# Step 11: Verify Completion

## Verification Checklist

- [ ] Planned layers executed or skipped as configured
- [ ] Consolidated change-risk report exists
- [ ] Bounded-audit bundle exists
- [ ] Findings are deduplicated with stable IDs
- [ ] Findings include acceptance criteria
- [ ] Coverage metadata exists and is internally consistent
- [ ] Convergence metadata exists
- [ ] Done-gate expression is recorded

## Outcome Rules

- Discovery mode (`post_remediation=false`): pass if contract artifacts are valid and recommendation rationale is explicit.
- Post-remediation mode (`post_remediation=true`): fail unless done-gate is true.

## Workflow Complete When

- [ ] Verification checklist passes for selected mode
- [ ] Result documented with rationale
