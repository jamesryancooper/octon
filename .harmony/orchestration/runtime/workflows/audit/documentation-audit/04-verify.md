---
name: verify
title: Verify Completion
description: Validate documentation bounded-audit contract and mode-specific done-gate outcomes.
---

# Step 4: Verify Completion

## Verification Checklist

- [ ] Documentation standards audit report exists
- [ ] Documentation audit report exists
- [ ] Documentation bounded-audit bundle exists
- [ ] Findings are deduplicated with stable IDs
- [ ] Findings include acceptance criteria
- [ ] Coverage metadata exists and is internally consistent
- [ ] Convergence metadata exists
- [ ] Done-gate expression is recorded

## Outcome Rules

- Discovery mode (`post_remediation=false`): pass if contract artifacts are valid and recommendation rationale is explicit.
- Post-remediation mode (`post_remediation=true`): fail unless done-gate is true.

## Actions

1. Evaluate each checklist item.
2. Mark workflow complete only if outcome rules pass for the selected mode.
3. If any item fails, return to the producing step and repair artifacts.

## Workflow Complete When

- [ ] Verification checklist passes for selected mode
- [ ] Result documented with rationale
