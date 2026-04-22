# Current-State Gap Map

| Area | Current live state | Target state | Gap class | Closing action |
|---|---|---|---|---|
| Authority model | Strong five-class root model; authored authority limited to `framework/**` and `instance/**` | Preserve | Preserve | No structural change; validate continuously |
| Root manifest | `octon.yml` owns roots, profiles, runtime inputs, generated commit defaults, execution governance | Thin root manifest with delegated runtime-resolution contract | Moderate restructuring | Move dense runtime-resolution into typed registries and generated/effective route bundle |
| Structural registry | Strong machine-readable topology registry with delegated registries/path families | Strong registry plus explicit runtime-resolution/route-bundle families | Focused gap | Add families and validator refs; reduce compatibility projection reliance |
| Ingress | Manifest-backed mandatory reads and closeout pointer | Preserve, avoid policy sprawl inside ingress | Focused gap | Keep closeout pointer, do not inline closeout policy |
| Execution authorization | Contract and implementation exist; coverage inventory exists | Runtime-proven total side-effect mediation | Hardening | Add negative-control tests and central route-bundle resolver input |
| Runtime-effective publication | Freshness contract exists; validators reference receipts | Runtime hard gate for every generated/effective read | Hardening | Add `GeneratedEffectiveHandle`, freshness v2, route-bundle lock checks |
| Support targets | Bounded support universe is explicit | Same, but path-normalized and proof-refreshed | Gap | Move admissions/dossiers to declared partitions; fix refs/proof paths |
| Pack architecture | Framework contracts + governance pack manifests + runtime pack admissions | Framework contract + governance intent + generated/effective runtime route | Moderate restructuring | Compile pack routes into generated/effective and retire duplicate runtime projection |
| Extension lifecycle | Desired/active/quarantine/published model exists; active state is bulky | Compact active state plus generated locks with dependency closure | Moderate cleanup | Move dependency closure and required inputs into lock/artifact maps |
| Evidence/proof | Strong obligations and support proof bundles exist | Continuously regenerated proof with freshness and negative controls | Hardening | Add proof refresh gates and evidence completeness checks |
| Operator views | CLI and generated projections exist | Concise architecture doctor and traceable maps | Productization gap | Add operator architecture-health projection and doctor report |
| Transitional shims | Root ingress adapters, workflow wrappers, flat support paths, older proposal refs | Explicit retirement records and no runtime dependence | Cleanup | Register, sunset, promote, or retire shims |

## Current-state finding that must be handled carefully

`support-targets.yml` declares claim-state partition roots and references paths such as
`support-target-admissions/live/...` and `support-dossiers/live/...`, while currently visible
admission and dossier files are exposed in flat directories. The target state should adopt the
partitioned model because the support architecture already declares it, while retaining flat paths
only as compatibility shims until validators and generated outputs are updated.
