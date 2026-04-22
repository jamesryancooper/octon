# 10of10 Target-State Transition Baseline

Recorded at `2026-04-22T18:48:51Z` on branch
`chore/octon-10of10-target-state-big-bang` before migration edits.

## Worktree state

- `git status --short`

```text
?? .octon/inputs/exploratory/proposals/architecture/octon-architecture-10of10-target-state-transition/
```

The active proposal packet exists only as an untracked exploratory input at
baseline capture time. No authored or generated migration edits had landed yet
in this branch when this evidence was recorded.

## Core source digests

```text
09f147a7ca2867e0d12922614b1830c2dfd8dbf694e675a55eb52b22eddbc08d  .octon/octon.yml
0e35dffede7769df3bc02a49f207f48b1f9a6846b9270dd6ee1b3584d928c73c  .octon/instance/governance/runtime-resolution.yml
55bacf133ca609e7cf2ef67fdaae7105bb544b833037c7f75fd4cf94152c5f4f  .octon/generated/effective/runtime/route-bundle.yml
492d755bebad82ce2ea66241cd5fc8716562c03b228823bb40daa3e7dd0162a1  .octon/generated/effective/runtime/route-bundle.lock.yml
c78993726979ae8614b8c8ead9e4c53f2dedee560d22048ca02c15928ae65ada  .octon/generated/effective/capabilities/pack-routes.effective.yml
6fe16ee4f13f7bf003d9c35c4b66314b42812ad3de90ad4739ef097b1040bed1  .octon/generated/effective/capabilities/pack-routes.lock.yml
366f868167a8ee73819c4860632168326dfc98287a2fa2bde866520b3c37ee85  .octon/generated/effective/governance/support-target-matrix.yml
84ea265f217b4f52c661390438f7c77822e986ce557a01b645c40162b797cda7  .octon/generated/effective/extensions/catalog.effective.yml
cc0a1c4cdc5afa91e11d89f1e03ee615b2b8bf66d21ac64e4ce99aad6f133395  .octon/generated/effective/extensions/artifact-map.yml
4f0babc72565e173385cf8d1c55ab8b63e7a0e177cecc7d30f64ff2baf7489a1  .octon/generated/effective/extensions/generation.lock.yml
```

## Baseline validator outcomes

- `validate-runtime-effective-artifact-handles.sh`: pass
- `validate-authorization-boundary-coverage.sh`: pass
- `validate-runtime-effective-route-bundle.sh`: fail
  - `root manifest digest drift`
  - `extensions catalog digest drift`
  - `extensions generation lock digest drift`
- `validate-publication-freshness-gates.sh`: fail
  - subchecks passed until `validate-runtime-effective-route-bundle.sh`
- `validate-architecture-health.sh`: fail
  - failed dimensions inherit the route-bundle and publication-freshness
    failures

## Baseline interpretation

The repo already has strong target-state-adjacent generated/effective metadata,
validators, retirement posture, and closure evidence roots. The active baseline
failure mode is not missing files; it is drift between the currently published
runtime route-bundle lock and newer authored/generated inputs.

That means the migration starts from a partially implemented but internally
inconsistent state:

- runtime-effective artifacts already carry `freshness.mode`,
  `allowed_consumers`, `forbidden_consumers`, and
  `non_authority_classification`
- the runtime resolver and root manifest still point at the older v1/v2/v3
  contract family
- the current route-bundle publication is stale relative to the root manifest
  and extension publication chain

## Runtime tests at baseline

No Rust build or runtime crate test suite was executed before baseline capture.
Those checks are reserved for post-edit validation after authored/runtime
reconciliation lands.
