---
disclosure_status: externally-shareable-after-maintainer-review
authority_mode: non-authoritative
external_transmission_approved: false
---

# Proposal Program Overview

## Parent

- ID: `octon-public-distribution-model`
- Kind: architecture
- Status: `in-review`
- Execution mode: `gated-parallel`
- Child count: 10
- Authority: sequencing and aggregate readiness only

Path:
`.octon/inputs/exploratory/proposals/architecture/octon-public-distribution-model/`

## Children And Dependencies

| Phase | Child | Dependencies | Gate |
| --- | --- | --- | --- |
| `phase-1` | `public-distribution-legacy-exposure-readiness` | None | `verification` |
| `phase-1` | `public-distribution-repository-role-contracts` | None | `verification` |
| `phase-2` | `public-distribution-portable-base-clearance` | `public-distribution-repository-role-contracts` | `verification` |
| `phase-2` | `public-distribution-downstream-core-delivery` | `public-distribution-repository-role-contracts` | `verification` |
| `phase-2` | `public-distribution-local-storage-evidence` | `public-distribution-repository-role-contracts` | `verification` |
| `phase-3` | `public-distribution-portable-dropin-export` | `public-distribution-repository-role-contracts`, `public-distribution-portable-base-clearance`, `public-distribution-local-storage-evidence` | `verification` |
| `phase-3` | `public-distribution-self-hosting-workspace-migration` | `public-distribution-repository-role-contracts`, `public-distribution-local-storage-evidence` | `verification` |
| `phase-4` | `public-distribution-public-repository-controls` | `public-distribution-portable-base-clearance`, `public-distribution-portable-dropin-export` | `verification` |
| `phase-4` | `public-distribution-self-hosting-octon-storage-migration` | `public-distribution-repository-role-contracts`, `public-distribution-local-storage-evidence`, `public-distribution-self-hosting-workspace-migration` | `verification` |
| `phase-5` | `public-distribution-pilot-release-readiness` | `public-distribution-legacy-exposure-readiness`, `public-distribution-portable-dropin-export`, `public-distribution-downstream-core-delivery`, `public-distribution-local-storage-evidence`, `public-distribution-public-repository-controls`, `public-distribution-self-hosting-workspace-migration`, `public-distribution-self-hosting-octon-storage-migration` | `verification` |

## Migration Split

The root workspace migration is `repo-local`; the Octon storage migration is
`octon-internal`. This split avoids mixed promotion target families and
separates root workflow/host rollback from state/generated index rollback.

## Coverage

- Decisions traced by the parent: 26.
- First-release blocker groups: 6.
- Every blocker has one primary child owner.
- Manual and external-effect gates are parent resources, not executable grants.

## Non-Implementation Confirmation

Proposal creation added only proposal-local planning artifacts. It did not
accept packets, implement code, update generated proposal discovery, migrate
storage, alter GitHub, push a tree, or publish a release.

External architect task: verify that the graph is acyclic, write scopes are
coherent, dependencies are sufficient, and the parent cannot substitute for
child-owned evidence.

