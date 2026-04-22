# Implementation Dependency Matrix

| Workstream | Depends on | Blocks |
| --- | --- | --- |
| Health contract | Contract registry, root manifest, validators | All closure certification. |
| Authorization coverage | Runtime spec, side-effect inventory, authority engine | Runtime target-state score. |
| Support partition | Support targets, admissions, dossiers | Support claim closure. |
| Support-pack alignment | Support partition, pack registries | Live tuple proof. |
| Publication freshness | Generated/effective metadata, publication receipts | Runtime consumption of generated/effective outputs. |
| Pack normalization | Framework packs, instance governance, runtime admissions | Support-pack alignment. |
| Extension lock normalization | Instance extensions, active/quarantine state, generated/effective extensions | Publication freshness and extension closure. |
| Boot simplification | Ingress manifest, bootstrap START, closeout workflows | Operator target-state quality. |
| Proof bundles | Evidence obligations, validators, representative runs | Support and architecture closure. |
| Compatibility retirement | Retirement register, workflow compatibility state | Complexity/maintainability target state. |
