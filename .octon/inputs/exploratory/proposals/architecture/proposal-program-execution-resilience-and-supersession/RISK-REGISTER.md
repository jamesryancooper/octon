# Risk Register

| Risk | Area | Severity | Mitigation |
| --- | --- | --- | --- |
| Loop breaker hides a recoverable route | loop control | high | Fingerprint deltas must cite changed evidence and route decisions must retain blocker ledgers. |
| Lease model widens write authority | ownership control | high | Leases may narrow mutation to declared paths only and must fail closed on ambiguous ownership. |
| Supersession drops child evidence | rescue delivery | high | Carry forward child-owned receipts by ref and digest; parent summaries cannot satisfy child gates. |
| Partition report is mistaken for cleanup authority | closeout-worktree | high | Report fields must be non-mutating and validators must reject deletion, archive, branch, delivery, or cleaned claims. |
| Program becomes one large implementation patch | change management | medium-high | Child registry fixes staging order and each child has independent promotion targets and validators. |
