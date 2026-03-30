# Constitutional Disclosure Contracts

`/.octon/framework/constitution/contracts/disclosure/**` defines normalized
disclosure artifacts for consequential runs and system-level claims.

## Live Status

Disclosure is now part of the live atomic execution model while remaining
subordinate to durable authority and retained evidence.

- RunCards summarize one consequential run from bound authority, retained
  evidence, structural/governance proof planes, observability, and replay
  references
- HarnessCards summarize one system-level support, benchmark, or release claim
  from support-target declarations plus retained proof bundles
- disclosure never mints authority, widens support, or overrides the bound run
  contract

## Canonical Files

- `family.yml`
- `run-card-v1.schema.json`
- `harness-card-v1.schema.json`

## Canonical Roots

- Authored HarnessCard source: `/.octon/instance/governance/disclosure/`
- RunCards: `/.octon/state/evidence/disclosure/runs/<run-id>/`
- HarnessCards: `/.octon/state/evidence/disclosure/releases/<release-id>/`

Historical lab-local HarnessCard mirrors may remain under
`/.octon/state/evidence/lab/harness-cards/`, but they are no longer canonical
for supported live disclosure.
