---
title: Pre-Integration Architecture Review
description: Invoke the mandatory native architecture proposal review workflow before acceptance or implementation authorization.
access: agent
argument-hint: <proposal-path>
---

# Pre-Integration Architecture Review

Invoke the canonical workflow at:

- `/.octon/framework/orchestration/runtime/workflows/audit/pre-integration-architecture-review/`

The workflow, not this command, is the execution contract. It must produce a
schema-backed `architectural-review-support-receipt-v1` receipt that passes
`validate-architectural-review-receipts.sh --mode pre-integration-architecture-review --require-pass`.
