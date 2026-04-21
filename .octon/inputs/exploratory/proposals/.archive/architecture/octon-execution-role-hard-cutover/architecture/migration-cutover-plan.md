# Migration Cutover Plan

## Purpose

Despite the filename, this is not a compatibility migration. It is the operational
cutover plan for one atomic hard break.

## Pre-cutover prerequisites

- Working tree is clean.
- Proposal is accepted.
- Promotion targets are reviewed.
- All new schemas and validators are authored.
- Deletion inventory is approved.
- Support-target live claims are classified.
- Browser/API runtime-real evidence is available or claims are removed.
- Rollback is defined as whole-change revert only.

## Atomic cutover sequence

1. Add `framework/execution-roles/**`.
2. Add v3 execution request/receipt schemas and runtime event schema.
3. Update constitution, root README, root manifest, cognition umbrella, overlay registry, and instance manifest.
4. Update support targets, egress, budgets, capability architecture, service manifest, lab, observability, and assurance references.
5. Reduce workflow manifest to governance-critical workflows.
6. Delete `framework/agency/**`.
7. Delete active experimental external adapter.
8. Run proposal validator.
9. Run hard-cutover validator.
10. Run schema validators.
11. Run support-target tuple validators.
12. Run workflow manifest validators.
13. Run runtime conformance tests.
14. Generate retained promotion evidence.
15. Mark proposal implemented only after durable targets stand without proposal references.

## Deletion timing

Deletions occur in the same cutover commit set as additions. There is no bridge
period.

## Archive handling

This packet is archived only after promoted targets exist and retained promotion
evidence is recorded. The archive remains historical lineage only.

## No dual path

The following are explicitly forbidden after cutover:

- agency and execution-roles coexisting as active authority;
- agent and orchestrator registries coexisting;
- assistant and specialist registries coexisting;
- team and composition-profile registries coexisting;
- mission-only execution fallback;
- browser/API support claims without runtime proof.
