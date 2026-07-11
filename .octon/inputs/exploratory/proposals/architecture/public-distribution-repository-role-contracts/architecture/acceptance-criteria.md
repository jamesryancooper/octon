# Acceptance Criteria

## AC-01

The machine-readable YAML ownership contract `.octon/framework/engine/runtime/spec/core-path-ownership-v1.yml` defines all four surfaces — private workspace, synthetic public mirror, downstream repository, and machine-local or external storage — and assigns each surface its own explicit Git-posture value; `validate-repository-role-contracts.sh` fails when the YAML is invalid, when any surface is missing, when two surfaces share one undifferentiated Git-posture entry, or when a surface's posture field is absent.

## AC-02

A path ownership registry marks framework delivery paths as core-owned and instance, inputs, state, evidence, generated, host projection, and unrelated project paths as project-owned.

## AC-03

The repository-role contract reserves portable_dropin as the public-boundary role while bootstrap_core, repo_snapshot, pack_bundle, and full_fidelity retain their existing internal purposes. This child does not edit `.octon/octon.yml` or root-profile validation; portable_dropin admission and root-profile validator proof belong solely to `public-distribution-portable-dropin-export`.

## AC-04

`.octon/framework/assurance/runtime/_ops/scripts/validate-repository-role-contracts.sh` rejects live local roots, additive packs, host projections, and mixed core/project ownership from eligibility for the reserved public-boundary role, with each rejection proven by a negative fixture under `.octon/framework/assurance/runtime/_ops/fixtures/repository-role-contracts/` and exercised by `.octon/framework/assurance/runtime/_ops/tests/test-repository-role-contracts.sh`. These checks do not admit a root profile.

## AC-05

The role and path-ownership contracts state the invariant that install and update authority is limited to explicitly core-owned paths and that project-owned hashes must remain unchanged. This child validates the invariant's presence only; concrete adoption/update implementation and project-owned hash-preservation proof belong solely to `public-distribution-downstream-core-delivery`.

## Aggregate Gate

All criteria above must pass on the exact reviewed implementation revision.
A general statement that tests pass is insufficient; evidence must identify
the behavior, boundary, negative case, and retained receipt.
