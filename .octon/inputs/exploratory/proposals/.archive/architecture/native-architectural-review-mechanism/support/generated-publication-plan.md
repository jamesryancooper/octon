# Generated Publication Plan

## Generated Outputs

Generated outputs remain derived-only and must be produced by scripts:

- proposal registry;
- proposal artifact indices and program spines;
- child handoff capsules;
- capability and skill projections;
- host projections affected by skill or command publication.

## Required Scripted Publication

- `generate-proposal-registry.sh --write`
- `generate-proposal-artifact-index.sh --proposal <packet> --write`
- existing skill or host projection publication scripts selected by the skills
  child packet

## Validation

Publication is complete only when generated outputs validate, source digests are
fresh, and no generated output is used as authority over source manifests,
schemas, workflows, or receipts.
