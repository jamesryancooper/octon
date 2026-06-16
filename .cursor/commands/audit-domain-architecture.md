---
title: Audit Domain Architecture
description: Invoke the domain architecture audit alias for the canonical domain-architecture-audit mode.
access: agent
argument-hint: domain_path=<path> [criteria=<csv>]
---

# Audit Domain Architecture

Invoke the skill at:

- `/.octon/framework/capabilities/runtime/skills/audit/audit-domain-architecture/`

`audit-domain-architecture` is an operator invocation alias for the canonical Architectural Review Mechanism mode `domain-architecture-audit`.
The skill is read-only and emits retained audit evidence; this command does not
create a lifecycle gate or proposal acceptance authority.
