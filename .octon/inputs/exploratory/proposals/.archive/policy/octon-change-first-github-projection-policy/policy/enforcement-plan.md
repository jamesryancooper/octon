# Enforcement Plan

## Validation

Before implementation, bind the upstream Change-first policy contract. After
editing `.github/**`, run the relevant repo-local workflow validators plus:

- `.octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-commit-pr-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh`

Enforcement fails if a GitHub workflow claims that PRs, branches, or GitHub are
the default work unit.
