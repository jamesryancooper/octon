# Current-State Gap Map

| Current repository evidence | Gap | Required RP-01 change |
| --- | --- | --- |
| `authority_engine` already exposes policy, record, execution, and runtime-state seams. | Candidate-immutability and the complete evaluator/policy/bin/config/receipt identity are not proved as one indivisible interface. | Version the interface and bind every input and implementation identity in the decision receipt. |
| `lifecycle_executor/src/authorization.rs` performs lifecycle admission while candidate processes are spawned from four enumerated kernel/lifecycle seams. | Admission does not yet structurally dominate each final spawn and at-most-once consumption is unproved. | Add `authorization::consume_candidate_launch_guard` immediately before each enumerated spawn and reject every unowned candidate-spawn path through static and dynamic fitness checks. |
| Authorization coverage specs exist. | Path, Git-ref, URI, wrong-repository, stale epoch, and revocation boundary semantics remain unresolved by UE-001/UE-002. | Define typed comparisons and adversarial matrices. |
| Runtime state is currently represented across multiple surfaces. | RP-03 has not yet supplied one transactional writer. | Freeze a persistence-neutral semantic API; prohibit RP-03 from changing semantics during migration. |

The exhaustive current partition is frozen in
`resources/candidate-launch-census.yml`. The closed-world launcher inventory at
the reviewed baseline contains 919 launcher keys; four source seams are
candidate execution and the remainder are utility, control, provider, build,
test, publication, or bootstrap subprocesses governed by their existing effect
boundaries rather than the RP-01 final candidate guard.
