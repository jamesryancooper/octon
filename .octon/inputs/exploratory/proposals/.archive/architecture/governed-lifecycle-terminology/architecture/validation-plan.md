# Validation Plan

## Structural Proposal Validation

- `validate-proposal-standard.sh --package <packet>`
- `validate-architecture-proposal.sh --package <packet>`
- `validate-proposal-implementation-readiness.sh --package <packet>`
- `validate-proposal-review-gate.sh --package <packet> --require-implementation-authorization`

## Product And Runtime Validation

- `validate-product-feature-catalog.sh`
- `validate-product-roadmap.sh`
- `test-validate-product-feature-catalog.sh`
- `test-validate-product-roadmap.sh`
- `validate-proposal-implementation-conformance.sh --package <packet>`
- `validate-proposal-post-implementation-drift.sh --package <packet>`

## Terminology Sweeps

- Search active product/runtime/extension sources for current capability uses
  of `Lifecycle Autopilot`.
- Confirm retained matches are historical, archived, compatibility, or unrelated
  Kaizen/Autopilot references.
- Search for `Governed Lifecycle Control Loop` and verify it appears only in
  explanatory prose.
- Search for bare current-product substitutions that shorten `Governed
  Lifecycle Orchestration` to ambiguous `orchestration`.

## Generated Output Checks

- If source extension input changes, run the extension publication/host
  projection refresh required by the existing extension workflow.
- Regenerate proposal registry and check it matches generated projection.
