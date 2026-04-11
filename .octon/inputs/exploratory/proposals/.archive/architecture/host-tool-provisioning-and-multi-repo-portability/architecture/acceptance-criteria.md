# Acceptance Criteria

## Packet-readiness gates

| Gate ID | Condition | Proof burden |
| --- | --- | --- |
| AC-11 | The packet conforms to the active proposal contract and is archive-ready without chat reconstruction. | Valid manifests, required docs, navigation files, packet manifest, checksums. |
| AC-12 | The packet includes a profile selection receipt and coherent atomic cutover model. | `architecture/migration-cutover-plan.md`, `architecture/conformance-card.md`. |

## Implementation acceptance gates

| Gate ID | Condition | Evidence burden | Blocking note |
| --- | --- | --- | --- |
| AC-01 | A framework host-tool registry and contract family exist. | files exist, parse, and are validator-covered | blocks implementation use |
| AC-02 | A repo-owned host-tool requirements surface exists. | requirement manifest exists and parses | blocks implementation use |
| AC-03 | A provisioning command exists in the framework command lane. | command manifest entry, command doc, implementation script | blocks implementation use |
| AC-04 | Actual host installs resolve into a host-scoped Octon home outside the repo. | path resolution tests and provisioning receipts | blocks target-state closure |
| AC-05 | Multiple repos on one host can share cached tool installs while retaining independent desired requirements. | multi-repo integration tests | blocks target-state closure |
| AC-06 | `/init` remains repo bootstrap only and does not silently install host tools. | bootstrap docs and command behavior | blocks target-state closure |
| AC-07 | `repo-hygiene` is integrated onto the host-tool subsystem. | requirement binding plus resolution usage | blocks target-state closure |
| AC-08 | No host-specific binaries or caches are committed under `/.octon/**`. | structural validation and export-profile checks | blocks target-state closure |
| AC-09 | Host-tool provisioning emits retained receipts and repo runs record resolved tool versions. | host-home evidence plus repo run evidence | blocks target-state closure |
| AC-10 | A host-tool governance validator exists and passes. | validator script plus clean validation output | blocks closure claims |
