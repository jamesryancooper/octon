# Harness Integrity Tightening

This archived architecture proposal records the historical implementation aid
for `harness-integrity-tightening`.

The durable outputs identified in [proposal.yml](proposal.yml) were promoted
into long-lived Octon runtime, assurance, and workflow surfaces before this
packet was archived. The packet now exists only as proposal provenance and as
an archive-normalized source for registry and validator integrity.

## Historical purpose

The proposal tightened Octon's architecture contract around:

- super-root class ownership and write-root boundaries
- repo-owned outbound network policy and execution-budget policy
- retained execution evidence versus ephemeral execution scratch
- fail-closed enforcement of mutable control paths
- CI-backed architecture conformance for those invariants

## Durable target state

The target state preserved by this archive is:

- mutable execution control truth under `/.octon/state/control/execution/**`
- retained run evidence under `/.octon/state/evidence/runs/<run_id>/**`
- no mutable repo-specific state under `framework/**/_ops/**`
- repo-owned egress and budget policy surfaces outside proposal paths
- architecture-conformance automation and CI enforcing those boundaries

## Archive note

This packet was historically archived as implemented, but some required packet
files were missing from disk. The current archive shape restores the minimum
proposal-standard and architecture-proposal-standard files so registry rebuilds
and proposal validation can succeed without changing the historical promotion
claim recorded in [proposal.yml](proposal.yml).
