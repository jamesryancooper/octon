---
title: Critic And Readiness
description: Check plan scope, staleness, duplicate work, dependency health, and compile readiness before deeper decomposition.
---

# Critic And Readiness

Before deeper decomposition or compile, check:

1. mission binding and digest freshness;
2. scope preservation and non-scope boundaries;
3. success-criteria and failure-condition coverage;
4. risk ceiling and allowed action classes;
5. required approvals and ownership refs;
6. generated, input, proposal, host, and chat authority misuse;
7. duplicate branches by scope, expected output, dependency, and action class;
8. dependency cycles and dependency status;
9. readiness fields on candidate executable leaves; and
10. support-target tuple refs without support widening.

## Outcomes

- `ready`: compile may proceed for checked leaves.
- `blocked`: compile is blocked until evidence, approvals, or dependencies are
  resolved.
- `stage_only`: compile may prepare discovery or stage-only candidates.
- `escalate`: human governance or mission owner approval is required.

No outcome authorizes execution.
