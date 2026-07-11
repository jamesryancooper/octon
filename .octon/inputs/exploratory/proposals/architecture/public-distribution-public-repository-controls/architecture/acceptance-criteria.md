# Acceptance Criteria

## AC-01

This packet consumes the installable and public-repository-only labels defined by the `public-distribution-portable-dropin-export` export manifest, assembles the public tree's public-repository-only content exclusively from paths so labeled, and verifies that no assembled path is unlabeled or relabeled by this packet.

## AC-02

A desired-state dry run reports exact repository, ruleset, Actions, security, vulnerability, tag, and release-setting changes with zero API mutation.

## AC-03

Public main requires pull requests and status checks with zero mandatory human reviews, while force push, deletion, and routine bypass are denied.

## AC-04

Public CI uses SHA-pinned actions, verified tool downloads, least-privilege tokens, and no secret-bearing write path for untrusted pull requests.

## AC-05

Release candidates built from the public commit include SHA-256 checksums, an SBOM, GitHub/Sigstore attestations, and exact export-manifest parity.

## AC-06

Merge cannot publish; final publication requires one separate maintainer command naming exact commit, version, and manifest digest, followed by immutable-release and asset verification.

## AC-07

The dry-run repository transition binds each role to an immutable GitHub
repository ID and expected name, verifies that the private workspace remote
cutover and known-writer inventory are complete, and rejects creation or first
push to the new public `owner/octon` while any known writer still targets that
endpoint. A fixture models GitHub's rename redirect followed by original-name
reuse and proves a stale writer is blocked before object transfer. The final
apply plan records the maintainer's explicit acceptance of residual unknown
stale-clone risk.

## Aggregate Gate

All criteria above must pass on the exact reviewed implementation revision.
A general statement that tests pass is insufficient; evidence must identify
the behavior, boundary, negative case, and retained receipt.
