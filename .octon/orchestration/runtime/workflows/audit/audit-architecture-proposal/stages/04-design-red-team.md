---
name: design-red-team
title: Run Rigorous-Mode Design Red-Team
description: Execute prompt 03 and persist the rigorous-mode adversarial report.
---

# Step 4: Run Rigorous-Mode Design Red-Team

## Input

- `bundle/plan.md`
- target proposal at `package_path`
- canonical stage prompt for the design red-team pass

## Purpose

Pressure-test the audited package before any rigorous-mode mutation stages run.

## Actions

1. Load the canonical design red-team stage prompt.
2. Substitute `<PACKAGE_PATH>` with the target proposal path.
3. Execute the prompt against the current package state.
4. Persist the resulting report at:
   - `bundle/reports/03-design-red-team.md`
5. Record the highest-risk design ambiguities and unsafe implementation paths.

## Output

- `bundle/reports/03-design-red-team.md`
- Risk inventory for the hardening stage

## Proceed When

- [ ] Design Red-Team Report exists
- [ ] High-risk architectural weaknesses are explicit
- [ ] Findings are suitable as input to design hardening
