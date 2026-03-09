---
name: verify
title: Verify Completion
description: Validate pre-release bounded-audit contract and recommendation integrity.
---

# Step 8: Verify Completion

## Verification Checklist

- [ ] Planned stages executed/skipped as configured
- [ ] Consolidated report exists
- [ ] Pre-release bounded-audit bundle exists
- [ ] Findings are deduplicated with stable IDs
- [ ] Findings include acceptance criteria
- [ ] Coverage metadata exists and is internally consistent
- [ ] Convergence metadata exists
- [ ] Done-gate expression is recorded
- [ ] Instruction-layer manifest evidence exists for all material runs in scope
- [ ] `instruction_layers`, `context_acquisition`, and `context_overhead_ratio` are present in emitted receipts
- [ ] Alignment validator passes:
  - `bash .harmony/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh`
  - `bash .harmony/assurance/runtime/_ops/scripts/validate-developer-context-policy.sh`
  - `bash .harmony/assurance/runtime/_ops/scripts/validate-context-overhead-budget.sh`

## Outcome Rules

- Discovery mode (`post_remediation=false`): pass if contract artifacts are valid and recommendation is explicit.
- Post-remediation mode (`post_remediation=true`): fail unless done-gate is true.

## Workflow Complete When

- [ ] Verification checklist passes for selected mode
- [ ] Result documented with rationale
