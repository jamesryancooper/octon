# Risk Register

| Risk ID | Risk | Likelihood | Impact | Mitigation | Owner |
| --- | --- | --- | --- | --- | --- |
| R-01 | Static or dependency tools generate false positives, causing over-deletion pressure. | medium | high | Require confidence tiers, reader scans, and ablation routing for nontrivial cases. | octon-maintainers |
| R-02 | A new hygiene subsystem accidentally becomes a second control plane. | low | high | Keep classification in one repo-owned policy and route all destructive outcomes into the existing retirement spine. | Octon governance |
| R-03 | Repo-local workflow integration is forgotten because it sits outside active proposal promotion targets. | medium | medium | Explicitly label `.github/**` edits as dependent implementation surfaces in the file-change map and follow-up gates. | octon-maintainers |
| R-04 | Cleanup work silently widens support scope or capability-pack usage. | low | high | Reuse existing support-target and pack admissions; no new pack or support changes in scope. | Octon governance |
| R-05 | Historical or claim-adjacent surfaces are misclassified as ordinary bloat. | medium | high | Protect active release and current review packet surfaces dynamically; require retirement routing and claim-gate review. | Octon governance |
| R-06 | Baseline audit produces many findings and stalls adoption. | medium | medium | Separate architecture landing from cleanup execution; require only baseline evidence plus blocking-finding control for closure. | octon-maintainers |
| R-07 | Existing legacy proposal examples mislead reviewers about the current packet contract. | medium | medium | Use live standards and validators as the contract source; treat old packets as context only. | packet reviewers |
