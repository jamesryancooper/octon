# Run Journal Runtime Hardening Proposal Packet

Proposal ID: `octon-run-journal-runtime-hardening`

This packet defines the implementation proposal for the single highest-leverage
next step identified by the frontier harness research: harden Octon's existing
canonical run event ledger into the durable, typed, append-only, causally
replayable **Run Journal** for the **Governed Agent Runtime**.

The proposal is intentionally narrow. It does not broaden Octon into browser/API
support, MCP admission, multi-agent orchestration, or full Mission redesign. It
implements the substrate required for those later moves to be promotion-safe.

## Packet status

- Proposal kind: `architecture`
- Status: `archived`
- Promotion scope: `octon-internal`
- Proposal path: `.octon/inputs/exploratory/proposals/.archive/architecture/octon-run-journal-runtime-hardening/`
- Canonicality: proposal-local only; not runtime authority until promoted.

## Core decision

Octon already defines canonical run event ledgers under runtime constitutional
contracts. This proposal closes the implementation gap by aligning those
contracts with the runtime engine specs and crates so that every consequential
Run has:

1. an append-only canonical control journal at
   `.octon/state/control/execution/runs/<run-id>/events.ndjson`,
2. an integrity manifest at
   `.octon/state/control/execution/runs/<run-id>/events.manifest.yml`,
3. a mutable-but-derived `runtime-state.yml` view,
4. retained closeout evidence under `.octon/state/evidence/runs/<run-id>/`,
5. generated operator views derived only from canonical control/evidence roots,
6. validators that reject missing, conflicting, non-causal, non-replayable, or
   policy-bypassing execution records.

## Recommended read order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `resources/repository-baseline-audit.md`
5. `resources/architecture-evaluation.md`
6. `resources/implementation-gap-analysis.md`
7. `architecture/target-architecture.md`
8. `architecture/current-state-gap-map.md`
9. `architecture/file-change-map.md`
10. `architecture/implementation-plan.md`
11. `architecture/validation-plan.md`
12. `architecture/acceptance-criteria.md`
13. `architecture/migration-cutover-plan.md`
14. `architecture/cutover-checklist.md`
15. `architecture/closure-certification-plan.md`

## Non-authority notice

This packet lives under `.octon/inputs/exploratory/proposals/**`. Under Octon's
repository rules, it is exploratory/proposal material and must not be consumed as
runtime authority, policy authority, support-target authority, or generated
read-model authority until explicitly promoted through Octon's governance path.
