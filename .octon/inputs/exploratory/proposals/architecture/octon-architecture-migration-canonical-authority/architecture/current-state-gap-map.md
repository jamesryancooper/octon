# Current-State Gap Map

| Current repository evidence | Gap | Required RP-01 change |
| --- | --- | --- |
| `authority_engine` already exposes policy, record, execution, and runtime-state seams. | Candidate-immutability and the complete evaluator/policy/bin/config/receipt identity are not proved as one indivisible interface. | Version the interface and bind every input and implementation identity in the decision receipt. |
| `lifecycle_executor/src/authorization.rs` and kernel launch call sites perform admission work. | Exact final-guard dominance and at-most-once consumption are not proved across every spawn path. | Collapse launches behind one API and prove the static/dynamic spawn census. |
| Authorization coverage specs exist. | Path, Git-ref, URI, wrong-repository, stale epoch, and revocation boundary semantics remain unresolved by UE-001/UE-002. | Define typed comparisons and adversarial matrices. |
| Runtime state is currently represented across multiple surfaces. | RP-03 has not yet supplied one transactional writer. | Freeze a persistence-neutral semantic API; prohibit RP-03 from changing semantics during migration. |

The fixed-baseline-to-HEAD drift contains no authority/runtime source-family
change, so the reconciliation assumptions remain valid for this draft.
