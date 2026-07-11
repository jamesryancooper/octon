# Child Packet Index

| Phase | Child | Primary responsibility | Dependencies |
| --- | --- | --- | --- |
| phase-1 | `public-distribution-legacy-exposure-readiness` | Git and hosted-surface exposure, stale-writer inventory | None |
| phase-1 | `public-distribution-repository-role-contracts` | role contracts | None |
| phase-2 | `public-distribution-portable-base-clearance` | portable clearance | `public-distribution-repository-role-contracts` |
| phase-2 | `public-distribution-downstream-core-delivery` | schema-bound lock and downstream delivery | `public-distribution-repository-role-contracts` |
| phase-2 | `public-distribution-local-storage-evidence` | dependency-closed local storage and evidence semantics | `public-distribution-repository-role-contracts` |
| phase-3 | `public-distribution-portable-dropin-export` | portable export | `public-distribution-repository-role-contracts`, `public-distribution-portable-base-clearance`, `public-distribution-local-storage-evidence` |
| phase-3 | `public-distribution-self-hosting-workspace-migration` | workspace root migration | `public-distribution-repository-role-contracts`, `public-distribution-local-storage-evidence` |
| phase-4 | `public-distribution-public-repository-controls` | public controls and repository-identity preflight | `public-distribution-portable-base-clearance`, `public-distribution-portable-dropin-export` |
| phase-4 | `public-distribution-self-hosting-octon-storage-migration` | subtype-aware workspace Octon storage | `public-distribution-repository-role-contracts`, `public-distribution-local-storage-evidence`, `public-distribution-self-hosting-workspace-migration` |
| phase-5 | `public-distribution-pilot-release-readiness` | pilot readiness | `public-distribution-legacy-exposure-readiness`, `public-distribution-portable-dropin-export`, `public-distribution-downstream-core-delivery`, `public-distribution-local-storage-evidence`, `public-distribution-public-repository-controls`, `public-distribution-self-hosting-workspace-migration`, `public-distribution-self-hosting-octon-storage-migration` |

All children are required, non-deferred canonical siblings. The root workspace
migration and Octon storage migration are intentionally separate because their
promotion target families, validation, and rollback operations differ.
