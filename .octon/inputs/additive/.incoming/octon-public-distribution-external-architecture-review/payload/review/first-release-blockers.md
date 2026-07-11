---
disclosure_status: externally-shareable-after-maintainer-review
authority_mode: non-authoritative
external_transmission_approved: false
---

# First-Release Blockers

| Blocker | Name | Primary owner | Supporting children | Objective unblock test |
| --- | --- | --- | --- | --- |
| BR-01 | Exposure and repository roles | `public-distribution-legacy-exposure-readiness` | `public-distribution-repository-role-contracts`, `public-distribution-self-hosting-workspace-migration` | Exact-history exposure receipt has no unresolved material finding; credential disposition and legacy decision are explicit; workspace and public identities are distinct; synthetic-history plan passes. |
| BR-02 | Portable-base clearance | `public-distribution-portable-base-clearance` | None | Every selected component and path has resolved dependency, sensitivity, license, provenance, clearance, and name-search status; zero unknown paths and zero packs remain. |
| BR-03 | Deterministic export | `public-distribution-portable-dropin-export` | None | Two exact-commit exports are byte-identical; source mutation is zero; all denylist fixtures fail; candidate public tree exactly matches the manifest. |
| BR-04 | Tier 1 delivery | `public-distribution-downstream-core-delivery` | `public-distribution-pilot-release-readiness` | Install, verify, neutral init, update, interruption recovery, and rollback pass on every Tier 1 target with project-owned hashes unchanged. |
| BR-05 | Truthful local evidence | `public-distribution-local-storage-evidence` | `public-distribution-self-hosting-octon-storage-migration` | Local-private records use real content hashes; no unsupported external claim exists; local Git defaults, backups, retention, and compact receipt checks pass. |
| BR-06 | Public and release controls | `public-distribution-public-repository-controls` | `public-distribution-pilot-release-readiness` | Desired public settings, secure CI, checksums, SBOM, attestations, tags, immutable release behavior, and manual exact-publication gate pass without a workspace PAT or merge publication. |

## Aggregate Rule

All six primary unblock tests pass on fresh exact revisions; Tier 1 pilots pass or demotions are explicit; approved repository setup exists; no manual gate is represented as completed without its real receipt; readiness still does not publish.

## Review Requirement

A blocker is justified only when it prevents a concrete material failure, has
an objective test, and has a clear owner. Parent summaries cannot waive a
failed, stale, or missing child result.

External architect tasks:

- identify missing material failures;
- remove blockers that are maturity goals rather than release necessities;
- confirm each unblock test is measurable on an exact revision;
- verify supporting children do not create conflicting ownership.

