---
title: Architecture Readiness Audit
description: Invoke the canonical architecture-readiness audit workflow for readiness evidence.
access: agent
argument-hint: <target-path> [severity_threshold=<level>]
---

# Architecture Readiness Audit

Invoke the canonical workflow at:

- `/.octon/framework/orchestration/runtime/workflows/audit/architecture-readiness-audit/`

The workflow contract is the execution authority. This command is a thin
operator-facing facade for the canonical `architecture-readiness-audit` mode and
does not restore the retired readiness-audit alias.
