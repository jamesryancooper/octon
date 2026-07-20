---
title: Emit Support Receipt
---

Emit an `architectural-review-support-receipt-v1` receipt with verdict,
evidence refs, validator refs, unresolved count, blockers, non-authority
classification, `recorded_at`, mode-specific coverage, and packet digest.
Receipts emitted on or after `2026-07-16T14:24:00Z` must include
`mode_specific_coverage.external_tool_integrity` describing the supported
interfaces, Octon-owned solution surfaces, unmodified external-tool posture,
and any fail-closed blocker. Validate the receipt with
`validate-architectural-review-receipts.sh`.
