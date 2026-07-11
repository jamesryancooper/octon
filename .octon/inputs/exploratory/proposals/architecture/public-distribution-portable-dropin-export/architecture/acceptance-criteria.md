# Acceptance Criteria

## AC-01

portable_dropin is admitted by the amended `.octon/framework/assurance/runtime/_ops/scripts/validate-root-manifest-profiles.sh`, which today hard-rejects any profile beyond bootstrap_core, repo_snapshot, pack_bundle, and full_fidelity, and remains explicitly distinct from those four; a negative case proves any other unknown profile name is still rejected.

## AC-02

Given an exact commit, export reads only tracked Git objects and produces no source-worktree, generated-state, Git-ref, remote, or repository-setting mutation.

## AC-03

The output manifest is canonically ordered and records every file's path, component, installability class, mode, size, and SHA-256 plus an aggregate digest.

## AC-04

Repeated builds from the same commit and clearance inputs are byte-identical, including normalized metadata and executable modes.

## AC-05

Denylisted, unknown, uncleared, untracked, ignored, traversal, and unsafe-link fixtures fail closed, and the base contains zero packs.

## AC-06

A parity validator proves the public repository candidate tree contains exactly the manifest-declared public tree and no workspace ancestry, measured by concrete checks: the candidate tree contains no `.git` directory and no workspace commit references, and the staged import commit has no parent commit from the workspace history.

## AC-07

Every exported path in the portable_dropin manifest is labeled installable or public-repository-only (PD-025); an export containing any unlabeled path fails closed.

## Aggregate Gate

All criteria above must pass on the exact reviewed implementation revision.
A general statement that tests pass is insufficient; evidence must identify
the behavior, boundary, negative case, and retained receipt.

