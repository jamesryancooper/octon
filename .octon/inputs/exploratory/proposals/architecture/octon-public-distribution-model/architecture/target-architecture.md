# Target Architecture

## Current State

- The workspace and current public repository are the same Git history.
- Portability exposes `bootstrap_core`, `repo_snapshot`, `pack_bundle`,
  and `full_fidelity`, but no public `portable_dropin`.
- Export reads workspace files and can invoke source publication writers.
- Starter templates are incomplete relative to their manifest and bootstrap is
  not a verified Tier 1 cross-platform delivery path.
- No exact core lock, verified resolver, transactional updater, recovery, or
  rollback implementation exists.
- State, generated outputs, inputs, and host projections create substantial
  hosted churn and sensitivity exposure.
- Current release automation and hosted controls do not meet the adopted public
  distribution posture.
- The current public repository name is also the intended final distribution
  name; rename followed by name reuse can redirect stale workspace writers to
  the new public repository unless transition gates block them.

## Target Topology

1. **Private `octon-workspace`:** canonical framework development plus
   classified repository authority and bounded local operational material.
2. **Public `octon`:** synthetic distribution history containing only an
   approved `portable_dropin` public tree.
3. **Downstream project:** exact core lock plus project-owned authority; core is
   verified and materialized locally.
4. **Machine-local or external storage:** operational state, raw evidence,
   generated output, caches, logs, and host projections under truthful custody.

## Invariants

- Publication is allowlist-only and exact-commit based.
- Portable-by-role is not publication-cleared by default.
- Public and downstream-installable files are separately labeled.
- Project-owned paths remain unchanged by core updates.
- The base distribution contains zero additive packs.
- Generated and non-authoritative material inherits sensitivity risk.
- Git ignore is defense in depth, not the publication boundary.
- Child evidence and human gates cannot be replaced by parent orchestration.
- Storage-class changes are dependency-closed across contracts, producers,
  consumers, validators, and tests; no runtime may fabricate external custody.
- Repository roles are bound to immutable repository IDs, and original-name
  reuse waits for known-writer cutover plus maintainer residual-risk acceptance.
- Final publication is one deliberate maintainer action against an exact
  commit, version, and manifest digest.

## Program Components

| Component | Owning child |
| --- | --- |
| Legacy exposure and transition readiness | `public-distribution-legacy-exposure-readiness` |
| Repository roles and ownership contracts | `public-distribution-repository-role-contracts` |
| Component and publication clearance | `public-distribution-portable-base-clearance` |
| Exact-commit public export | `public-distribution-portable-dropin-export` |
| Downstream install and update | `public-distribution-downstream-core-delivery` |
| Local storage and evidence policy | `public-distribution-local-storage-evidence` |
| Public repository controls | `public-distribution-public-repository-controls` |
| Root workspace migration | `public-distribution-self-hosting-workspace-migration` |
| Octon storage migration | `public-distribution-self-hosting-octon-storage-migration` |
| Pilot and release readiness | `public-distribution-pilot-release-readiness` |

## Security Boundary

Raw findings and evidence remain local-private. Proposal resources retain only
redacted decisions, path references, and digests. API-capable operations default
to dry-run and require an exact maintainer-approved plan before apply. Passkeys,
recovery material, encryption keys, destructive deletion, legal acceptance,
repository-name reuse risk, first push, and final release remain human-only.
