# Risk Register

| Risk ID | Risk | Severity | Mitigation | Owner |
| --- | --- | --- | --- | --- |
| R-001 | Workflow retry id collision recurs during archive or promote retry. | high | Add attempt-suffixed workflow run ids or replay-safe resume proof before retry. | `proposal-program-runner-workflow-retry-ids` |
| R-002 | Parent program evidence is mistaken for child-owned receipts. | high | Preserve child receipt ownership in contracts, runner summaries, reviews, and closeout evidence. | Parent and every child |
| R-003 | Closeout/worktree handoff becomes runner-owned cleanup or Git mutation. | high | Keep handoff interactions non-authorizing and route through `closeout-change`, `closeout-worktree`, or cleanup helpers. | `proposal-program-runner-change-handoff-checkpoints` |
| R-004 | Promotion dispatch accepts evidence for the wrong child. | high | Bind selected child id, receipt digests, write-scope digest, authority-zone decision, and route delegation basis before dispatch. | `proposal-program-runner-promotion-evidence-binding` |
| R-005 | Generated/effective drift is discovered only after avoidable workflow failure. | medium | Add pre-dispatch freshness classification where detectable and route recovery to canonical publication paths. | `proposal-program-runner-publication-freshness-preflight` |
| R-006 | Broad manifest targets allow accidental scope widening. | medium | Use `architecture/file-change-map.md` as the review boundary and require child-owned accepted reviews before durable mutation. | This packet and downstream children |
| R-007 | Review freshness churn blocks parent orchestration because volatile evidence changed. | medium | Keep reviewed digest boundaries focused on reviewed packet artifacts and add regression coverage. | `proposal-program-runner-parent-review-churn` |
| R-008 | Regression tests miss the original terminal failure pattern. | high | Add duplicate workflow id negative control and end-to-end terminal-routing fixture. | `proposal-program-runner-terminal-routing-tests` |
