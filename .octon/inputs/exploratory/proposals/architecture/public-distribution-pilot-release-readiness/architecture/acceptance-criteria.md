# Acceptance Criteria

## AC-01

Disposable public-style, private, and local-artifact/offline projects complete install, verify, neutral initialization, update, interruption recovery, and rollback.

## AC-02

Linux x86-64, macOS ARM64, and Windows x86-64 pass the full matrix; any demotion is an explicit maintainer decision recorded before release.

## AC-03

Tier 2 preview failures are visible and non-blocking without being reported as supported success.

## AC-04

Fault injection at every update transaction boundary recovers to one verified state and preserves all project-owned hashes.

## AC-05

The approved public candidate has exact export parity, required repository controls, checksums, SBOM, attestations, and immutable-release readiness. "Required repository controls" and "immutable-release readiness" are defined by the public-release-candidate-v1 contract (`.octon/framework/constitution/contracts/disclosure/public-release-candidate-v1.schema.json`), owned by `public-distribution-public-repository-controls`; this criterion consumes that definition and does not redefine it.

## AC-06

The aggregate receipt references fresh child-owned evidence, reports all six blocker groups clear, and explicitly states that publication still requires a separate maintainer action. The six blocker groups are enumerated by the parent blocker map (`.octon/inputs/exploratory/proposals/architecture/octon-public-distribution-model/resources/first-release-blocker-map.yml`, BR-01 through BR-06); that file is the enumeration source and this criterion adds no group of its own.

## Aggregate Gate

All criteria above must pass on the exact reviewed implementation revision.
A general statement that tests pass is insufficient; evidence must identify
the behavior, boundary, negative case, and retained receipt.

