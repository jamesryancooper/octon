# Policy Deviations

- Profile: `ci-reliability`
- Repo: `my-repo`
- Run mode: `ci`
- Maturity: `prod`
- Enforcement phase: `phase1`
- Total deviations: `3`
- Permitted: `2`

## Deviations

| Subsystem | Class | Attribute | Old | New | Declared | Permitted | Expired | ADR | Changelog | Evidence | Issues |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| `runtime` | `control-plane` | `auditability` | 5 | 4 | true | true | false | true | true | `.octon/output/assurance/results/repo-my-repo__run-mode-ci__maturity-prod__profile-ci-reliability.md` | none |
| `assurance` | `control-plane` | `testability` | 5 | 4 | true | false | false | true | false | `.octon/assurance/practices/standards/testing-strategy.md` | hard: missing_changelog_reference |
| `scaffolding` | `productivity` | `usability` | 4 | 5 | false | true | false | false | false | none | warn: missing_deviation_record |
