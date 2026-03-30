# Final Claim Matrix

## Cutover Checklist

| Area | Item | Status | Evidence |
|---|---|---|---|
| Constitutional cutover | constitutional kernel created | PASS | `validate-bootstrap-ingress.sh`, `validate-harness-structure.sh`, `framework/constitution/**` |
| Constitutional cutover | ingress updated | PASS | `instance/ingress/AGENTS.md`, `validate-bootstrap-ingress.sh` |
| Constitutional cutover | old constitutional docs turned into shims | PASS | `framework/constitution/contracts/registry.yml`, `validate-phase6-simplification-deletion.sh` |
| Constitutional cutover | precedence validators active | PASS | `framework/constitution/precedence/**`, `validate-harness-structure.sh` |
| Objective and authority cutover | workspace charter root exists | PASS | `instance/charter/workspace.{md,yml}`, `validate-objective-binding-cutover.sh` |
| Objective and authority cutover | run contract required for material execution | PASS | `validate-objective-binding-cutover.sh`, `validate-runs.sh` |
| Objective and authority cutover | approvals/grants/leases/revocations active | PASS | `validate-execution-governance.sh`, `state/control/execution/{approvals,exceptions,revocations}/**` |
| Objective and authority cutover | host adapters project rather than define authority | PASS | `validate-phase5-adapter-support-target-hardening.sh`, host adapter manifests |
| Runtime and evidence cutover | run-rooted state normalized | PASS | `validate-runtime-lifecycle-normalization.sh`, `validate-runs.sh` |
| Runtime and evidence cutover | checkpoints and run continuity live | PASS | `validate-runtime-lifecycle-normalization.sh`, `validate-execution-constitution-closeout.sh` |
| Runtime and evidence cutover | replay pointers active | PASS | `validate-runtime-lifecycle-normalization.sh`, `validate-runs.sh` |
| Runtime and evidence cutover | evidence classes enforced | PASS | `validate-execution-constitution-closeout.sh`, `instance/governance/contracts/disclosure-retention.yml` |
| Proof and lab cutover | structural/governance proof preserved | PASS | `validate-phase4-proof-lab-enforcement.sh` |
| Proof and lab cutover | functional/behavioral/recovery suites active | PASS | `validate-phase4-proof-lab-enforcement.sh` |
| Proof and lab cutover | lab domain operates in substance | PASS | `validate-phase4-proof-lab-enforcement.sh`, `validate-runs.sh` |
| Proof and lab cutover | intervention disclosure enforced | PASS | `validate-runs.sh`, intervention logs under `state/evidence/runs/**` |
| Portability and support cutover | support-target matrix published | PASS | `instance/governance/support-targets.yml`, `validate-phase5-adapter-support-target-hardening.sh` |
| Portability and support cutover | adapters admitted by conformance | PASS | `validate-phase5-adapter-support-target-hardening.sh` |
| Portability and support cutover | unsupported tuples fail closed | PASS | `validate-phase5-adapter-support-target-hardening.sh`, `validate-execution-governance.sh` |
| Simplification and deletion cutover | orchestrator is canonical kernel profile | PASS | `validate-phase6-simplification-deletion.sh`, `validate-agency.sh` |
| Simplification and deletion cutover | persona overlays are optional only | PASS | `validate-phase6-simplification-deletion.sh`, `framework/agency/runtime/agents/README.md` |
| Simplification and deletion cutover | label-native authority deleted | PASS | `validate-phase6-simplification-deletion.sh`, `validate-autonomy-labels.sh` |
| Simplification and deletion cutover | duplicated constitutional prose retired | PASS | `validate-phase6-simplification-deletion.sh`, `retirement-registry.yml` |

## Final Target-State Claim Criteria

| Criterion | Status | Evidence |
|---|---|---|
| 1. constitutional kernel is supreme and singular | PASS | `instance/ingress/AGENTS.md`, `framework/constitution/**`, `framework/constitution/contracts/registry.yml`, `validate-bootstrap-ingress.sh` |
| 2. every consequential run is run-bound | PASS | `validate-objective-binding-cutover.sh`, `validate-runs.sh`, run manifests and run contracts under `state/control/execution/runs/**` |
| 3. every material action is authority-routed before effect | PASS | `validate-execution-governance.sh`, authority artifacts under `state/control/execution/**` and `state/evidence/control/execution/**` |
| 4. mission-backed and run-only autonomy are explicitly policy-bound | PASS | `instance/orchestration/missions/registry.yml`, `support-targets.yml`, `validate-objective-binding-cutover.sh` |
| 5. all required proof planes exist and are enforced for claimed support tiers | PASS | `validate-phase4-proof-lab-enforcement.sh`, `validate-assurance-disclosure-expansion.sh`, proof suite registries and retained reports |
| 6. RunCard and HarnessCard are mandatory and sufficient disclosure surfaces | PASS | `validate-assurance-disclosure-expansion.sh`, disclosure family contract, retained RunCards and HarnessCards |
| 7. evidence classes and replay indexing are enforced | PASS | `validate-execution-constitution-closeout.sh`, `validate-runs.sh`, `disclosure-retention.yml` |
| 8. support-target matrix is real and fail-closed | PASS | `validate-phase5-adapter-support-target-hardening.sh`, `validate-execution-governance.sh` |
| 9. hidden human repair is impossible without disclosure | PASS | intervention logs under `state/evidence/runs/**`, canonical approval/grant/lease/revocation artifacts, no host-native label authority, `validate-execution-governance.sh` |
| 10. transitional constitutional, persona, and host-native authority scaffolding has been retired or clearly non-authoritative | PASS | `retirement-registry.yml`, `closeout-reviews.yml`, `validate-phase6-simplification-deletion.sh`, `validate-phase7-build-to-delete-institutionalization.sh` |

## Blocking Validation Questions

| Question | Status | Evidence |
|---|---|---|
| Does every material run have a run contract and route artifact? | PASS | `validate-runs.sh`, `validate-execution-governance.sh` |
| Can the run resume from checkpoints without chat continuity? | PASS | `validate-runtime-lifecycle-normalization.sh`, `validate-execution-constitution-closeout.sh` |
| Can host labels be deleted without losing authority semantics? | PASS | `validate-phase6-simplification-deletion.sh`, `validate-execution-governance.sh` |
| Are proof planes complete enough for the claims being made? | PASS | `validate-phase4-proof-lab-enforcement.sh`, `validate-assurance-disclosure-expansion.sh` |
| Is replay interpretable and disclosure honest? | PASS | `validate-execution-constitution-closeout.sh`, `validate-assurance-disclosure-expansion.sh`, `validate-runs.sh` |
| Can unsupported tuples be shown to fail closed? | PASS | `validate-phase5-adapter-support-target-hardening.sh`, `validate-execution-governance.sh` |
