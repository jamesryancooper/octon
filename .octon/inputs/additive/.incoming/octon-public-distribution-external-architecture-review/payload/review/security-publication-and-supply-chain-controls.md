---
disclosure_status: externally-shareable-after-maintainer-review
authority_mode: non-authoritative
external_transmission_approved: false
---

# Security, Publication, And Supply-Chain Controls

## First-Release Controls

- allowlist-only export from an exact commit;
- invariant denylist and negative leak fixtures;
- component license, provenance, sensitivity, and publication clearance;
- secret and sensitive-content scanning;
- public-tree manifest parity;
- SHA-256 checksums;
- SBOM;
- GitHub/Sigstore attestations;
- SHA-pinned Actions and verified external downloads;
- least-privilege `GITHUB_TOKEN`;
- no secret-bearing or write-capable untrusted pull-request execution;
- pull requests and required checks on public `main`;
- zero mandatory human reviews while there is one maintainer;
- no force push, deletion, or routine bypass;
- protected version tags and immutable releases;
- secret scanning, push protection, and private vulnerability reporting;
- separate draft candidate and final publication transitions.

## Credentials

**Sponsor decision:** Do not store a cross-repository PAT and do not require a
GitHub App initially. Use normal maintainer `gh` or SSH authentication from a
separate public checkout. The private workspace has no public push remote.

## Trust Root

**Sponsor decision:** GitHub-native attestations, checksums, SBOMs, protected
tags, and immutable releases are sufficient for the first release. A separate
signing key is deferred until a regulated, air-gapped, or independent-registry
need exists.

## Solo-Maintainer Authorization

Merge may build a draft candidate but cannot publish. Final publication is one
separate maintainer action bound to the exact commit, version, and manifest
digest. Two-person approval is not required.

## Residual Risk

A personal account remains a concentration risk. The adopted mitigation is two
independent passkeys or security keys, offline recovery information, protected
automation, exact digests, and deliberate publication.

Sources: `SRC-009`, `SRC-011`, `SRC-014`, `SRC-015`, and
`SRC-018`.

