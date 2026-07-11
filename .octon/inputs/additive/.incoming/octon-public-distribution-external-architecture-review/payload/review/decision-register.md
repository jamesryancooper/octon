---
disclosure_status: externally-shareable-after-maintainer-review
authority_mode: non-authoritative
external_transmission_approved: false
---

# Decision Register

This table records the current in-review baseline. It is not durable authority.

| ID | Classification | Decision | Source IDs | Current owner / implementation packet | Manual gate |
| --- | --- | --- | --- | --- | --- |
| PD-001 | Sponsor decision | Private workspace and public distribution are separate repositories. | SRC-003, SRC-004, SRC-009, SRC-010, SRC-011, SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-repository-role-contracts` | maintainer approves repository identities |
| PD-002 | Sponsor decision | Public octon is populated only from portable_dropin. | SRC-003, SRC-004, SRC-009, SRC-010, SRC-011, SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-portable-dropin-export` | maintainer approves exact first tree |
| PD-003 | Sponsor decision | Public history is synthetic and has no workspace ancestry. | SRC-003, SRC-004, SRC-009, SRC-011, SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-public-repository-controls` | maintainer authorizes first push |
| PD-004 | Sponsor decision | First release uses the smallest dependency-closed cleared base. | SRC-003, SRC-004, SRC-009, SRC-010, SRC-011, SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-portable-base-clearance` | maintainer clears exact closure |
| PD-005 | Sponsor decision | Base distribution contains zero additive packs and excludes local roots. | SRC-003, SRC-004, SRC-009, SRC-015, SRC-018 | Maintainer / `public-distribution-portable-dropin-export` | none |
| PD-006 | Sponsor decision | Export uses an exact commit, empty staging, allowlist, manifest, and deterministic parity. | SRC-003, SRC-009, SRC-015, SRC-018 | Maintainer / `public-distribution-portable-dropin-export` | none |
| PD-007 | Sponsor decision | Apache-2.0 covers core and MIT-0 covers designated copy-out templates. | SRC-009, SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-portable-base-clearance` | maintainer accepts mapping; specialist only for ambiguity |
| PD-008 | Sponsor decision | Provenance is component and release based with path overrides for exceptions. | SRC-009, SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-portable-base-clearance` | maintainer accepts provenance |
| PD-009 | Sponsor decision | Personal-account ownership is sufficient with two independent authenticators and recovery. | SRC-012, SRC-014, SRC-015, SRC-016, SRC-018 | Maintainer / `public-distribution-public-repository-controls` | maintainer performs account setup |
| PD-010 | Conditional decision | Legacy public archive depends on exposure review; revoke confirmed credentials first. | SRC-002, SRC-003, SRC-009, SRC-011, SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-legacy-exposure-readiness` | maintainer decides disposition and revokes credentials |
| PD-011 | Sponsor decision | Public code contributions are not accepted initially. | SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-public-repository-controls` | maintainer may revise later |
| PD-012 | Sponsor decision | Three Tier 1 targets block release; two Tier 2 targets are preview. | SRC-010, SRC-011, SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-pilot-release-readiness` | maintainer approves demotion |
| PD-013 | Sponsor decision | Use checksums, SBOM, GitHub/Sigstore attestations, tags, and immutable releases. | SRC-009, SRC-011, SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-public-repository-controls` | maintainer publishes exact release |
| PD-014 | Sponsor decision | Raw operational evidence uses truthful local-private custody. | SRC-002, SRC-010, SRC-011, SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-local-storage-evidence` | none |
| PD-015 | Sponsor decision | Use bounded retention, encrypted backups, compact receipts, and deferred compaction deletion. | SRC-010, SRC-011, SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-local-storage-evidence` | maintainer controls keys and deletion |
| PD-016 | Sponsor decision | Use separate-checkout gh or SSH auth and deliberate publication; no cross-repository PAT. | SRC-011, SRC-014, SRC-015, SRC-016, SRC-018 | Maintainer / `public-distribution-public-repository-controls` | maintainer invokes publication |
| PD-017 | Sponsor decision | Public repository uses PR checks, zero required reviews, no force push, scanning, and least privilege. | SRC-009, SRC-011, SRC-014, SRC-015, SRC-016, SRC-018 | Maintainer / `public-distribution-public-repository-controls` | maintainer approves exact API apply |
| PD-018 | Sponsor decision | Downstream delivery uses exact lock, verified retrieval, staged update, recovery, and rollback. | SRC-010, SRC-011, SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-downstream-core-delivery` | maintainer selects upgrade |
| PD-019 | Sponsor decision | Self-hosting workspace keeps framework source and migrates high-churn material forward-only. | SRC-010, SRC-011, SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-self-hosting-octon-storage-migration` | maintainer approves untracking |
| PD-020 | Deferred | Organization, contributions, app, independent key, hosted evidence, compaction service, vendoring, mirrors, and auto migration remain deferred. | SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-repository-role-contracts` | maintainer activates only on trigger |
| PD-021 | Sponsor decision | API-capable external effects require exact plan approval; human-only custody and publication remain manual. | SRC-011, SRC-015, SRC-016, SRC-018 | Maintainer / `public-distribution-public-repository-controls` | maintainer approves and executes |
| PD-022 | Sponsor decision | Public mirror retains issues and private vulnerability reporting while code contributions are closed. | SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-public-repository-controls` | maintainer approves public docs |
| PD-023 | Sponsor decision | Perform a basic name search and identity statement; defer registration. | SRC-009, SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-portable-base-clearance` | maintainer accepts result or seeks specialist |
| PD-024 | Sponsor decision | No provenance exception is allowed in the first release. | SRC-009, SRC-014, SRC-015, SRC-018 | Maintainer / `public-distribution-portable-base-clearance` | maintainer cannot waive without revising baseline |
| PD-025 | Sponsor decision | Public-repository-only files are distinct from downstream-installable files. | SRC-009, SRC-015, SRC-018 | Maintainer / `public-distribution-public-repository-controls` | none |
| PD-026 | Recommendation | Root workspace and Octon storage migrations have separate target and rollback domains. | SRC-018 | Maintainer / `public-distribution-self-hosting-workspace-migration` | maintainer approves each migration |

## Interpretation

- `Sponsor decision` means the latest explicit baseline adopts the decision.
- `Conditional decision` remains dependent on named evidence or maintainer
  judgment.
- `Deferred` is intentionally outside first-release implementation until its
  trigger occurs.
- `Recommendation` is an architecture decomposition decision that remains
  subject to external review.
- Full acceptance tests, repository references, and architect questions are in
  `source-traceability.yml`.

