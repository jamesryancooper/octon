---
name: verify
title: Verify Completion
description: Validate architecture-readiness workflow outputs and mode-specific done-gate outcomes.
---

# Step 8: Verify Completion

## Verification Checklist

- [ ] Primary audit executed and classified the target explicitly
- [ ] Supplemental stages executed or skipped according to the target mode
- [ ] Consolidated workflow report exists
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

- [ ] Verification checklist passes for the selected mode
- [ ] Result is documented with rationale
