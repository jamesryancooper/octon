# Risk Register

| Risk ID | Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- | --- |
| R-01 | Host-scoped actual state accidentally becomes repo authority. | medium | high | Keep desired requirements in repo and actual installs/evidence outside repo. |
| R-02 | `/init` silently expands into a host mutation lane. | medium | high | Make provisioning a separate command and document the boundary explicitly. |
| R-03 | Multiple repos on one system clobber each other’s tool versions. | medium | high | Use side-by-side versioned installs keyed by tool id, version, and platform. |
| R-04 | Teams reintroduce `/tmp` as the unofficial steady-state cache. | medium | medium | Make `/tmp` explicitly non-canonical in contracts and docs. |
| R-05 | CI and local environments diverge architecturally. | medium | medium | Use the same host-tool contracts and resolver in both, differing only in host-home root. |
| R-06 | Vendored binaries leak into exports or snapshots. | low | high | Add export and boundary validation that forbids repo-local binary caches. |
