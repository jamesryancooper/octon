# Packet Sequence

## Phase 1: Parallel Foundations

- `public-distribution-legacy-exposure-readiness`
- `public-distribution-repository-role-contracts`

The exposure child gates external repository transition. The role child gates
architecture and ownership-dependent implementation.

## Phase 2: Gated Parallel Foundations

After `public-distribution-repository-role-contracts` verifies:

- `public-distribution-portable-base-clearance`
- `public-distribution-downstream-core-delivery`
- `public-distribution-local-storage-evidence`

## Phase 3: Materialization And Root Migration

- `public-distribution-portable-dropin-export` follows role contracts,
  portable-base clearance, and local-storage policy because those children
  share the root manifest boundary.
- `public-distribution-self-hosting-workspace-migration` follows role
  contracts and local-storage policy.

## Phase 4: Public Controls And Octon Storage

- `public-distribution-public-repository-controls` follows clearance and
  portable export.
- `public-distribution-self-hosting-octon-storage-migration` follows role,
  local-storage, and root workspace migration.

## External Repository Setup Barrier

After exposure readiness and public-control tooling pass, the maintainer may
approve an exact dry-run operations plan. Repository creation, rename, archive,
visibility, rulesets, security settings, and first public-tree import remain
outside program orchestration.

Before the original `owner/octon` name is reused, this barrier also requires
the hosted-surface exposure inventory, immutable repository-ID bindings,
private-workspace cutover for every known writer, a negative stale-endpoint
push test, and explicit maintainer acceptance of residual unknown-clone risk.

## Phase 5: Pilot

`public-distribution-pilot-release-readiness` follows all implementation
children named in its registry dependencies plus approved repository setup for
live public checks.

## Final Gate

A passing pilot receipt means technically ready for a release decision. It does
not authorize the first push or final release publication.
