# Stage 09: Emit Delivery Receipt

Emit an aggregate receipt conforming to `proposal-program-delivery-receipt-v1` and validate it with `validate-proposal-program-delivery-receipt.sh`. The receipt must name the retained delivery evidence index by path, schema version, validator ref, validator verdict, evidence-only posture, source-receipt digest-bound posture, and `circular_digest_required: false`.

Materialize a compact retained delivery evidence index conforming to `proposal-program-delivery-evidence-index-v1` with `generate-proposal-program-delivery-evidence-index.sh`, then validate it with `validate-proposal-program-delivery-evidence-index.sh`.

Required checks:

- All source receipts are cited by path or durable evidence reference plus digest.
- Parent summaries do not replace target-owned child receipts.
- Disclosure tiers, non-authority classifications, excluded evidence classes, stop condition IDs, owning next routes, and downgrade rationale are recorded.
- Order policy, retained readiness preflight, clean-worktree route, include-path classification, and lifecycle postmortem status are recorded.
- The aggregate receipt records a non-circular retained evidence-index binding by path and validator posture, not by index digest.
- The retained evidence index records refs, digests, disclosure tiers, route, outcome, validator results, and non-authority classification only.
- The retained evidence index does not authorize delivery, archive, landing, cleanup, execution, child lifecycle outcomes, or child receipt replacement.
- Compact blocker-remediation receipts are validated when repeated fingerprint, repeated full workflow directory, file-count, or byte-count budget triggers apply; they remain evidence-only and cannot satisfy child-owned, delivery, archive, cleanup, Change, branch cleanup, generated-publication, terminal-proof, or proposal-status receipts.
- No-dispatch attempt ledgers are validated when repeated unchanged no-dispatch or max-step states apply; they remain evidence-only and cannot satisfy child-owned, delivery, archive, cleanup, Change, branch cleanup, generated-publication, terminal-proof, or proposal-status receipts.
- Compact continuation is denied when required receipts, retained full evidence refs, blocker classification, or route-owned recovery proof would be lost.
- Open blockers prevent downstream outcome claims.
- The receipt records the highest outcome that has current passing owning evidence.
- Aggregate receipt, readiness projection, parent summary, or evidence index substitution for child-owned evidence emits `SC-009-parent-summary-substitution`.
