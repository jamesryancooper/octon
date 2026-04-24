# Rejection Ledger

| Rejected option | Reason |
|---|---|
| Create a new workflow engine as the execution authority | Would create a rival control plane and duplicate existing runtime contracts. |
| Treat `runtime-state.yml` as authoritative lifecycle state | Conflicts with Run Journal source-of-truth rule. |
| Let generated/operator read models repair lifecycle state | Violates generated non-authority invariant. |
| Widen support targets while implementing lifecycle | Scope creep; lifecycle proof should strengthen existing support claims first. |
| Retroactively claim all historical runs are lifecycle-conformant | Unsafe unless deterministic reconstruction succeeds. |
| Implement lifecycle as proposal-local scripts | Proposals are non-authoritative and temporary. |
| Rely on CLI conventions instead of runtime enforcement | Does not protect programmatic or adapter execution paths. |
| Make mission state the atomic lifecycle authority | Conflicts with Run as atomic consequential execution unit. |
| Allow live replay without fresh authorization | Violates side-effect safety and replay rules. |
