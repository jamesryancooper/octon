---
title: Plan Charter Alignment I/O Contract
description: Input and output contract for the plan-charter-alignment skill.
---

# I/O Contract

## Inputs

- `charter_path`: path to the charter being remediated
- `findings_source`: audit report or findings package to plan against
- `target_score`: desired minimum score after remediation
- `change_profile`: optional override if already fixed by higher-precedence governance
- `release_state`: optional override when not derivable from metadata
- `scope`: default planning scope

## Outputs

- one markdown plan with the required five top-level sections,
- one execution log,
- one per-skill log index entry.

## Output Expectations

The plan should be directly implementable:

- no unresolved implementation decisions for the charter file itself,
- explicit assumptions and defaults,
- grouped change bundles,
- concrete validation scenarios.
