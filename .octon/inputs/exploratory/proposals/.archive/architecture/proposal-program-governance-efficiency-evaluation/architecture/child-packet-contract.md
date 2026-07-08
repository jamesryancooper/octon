# Child Packet Contract

This parent program coordinates five sibling child packets:

- `proposal-governance-efficiency-report-contract`
- `proposal-governance-efficiency-evidence-collector`
- `proposal-governance-efficiency-scoring-and-classification`
- `proposal-governance-efficiency-operator-surface`
- `proposal-governance-efficiency-validation-and-documentation`

## Authority Boundary

The parent may coordinate ordering, dependency gates, aggregate risk, aggregate validation intent, and closeout readiness. The parent must not edit or satisfy child manifests, child receipts, child promotion targets, child validation verdicts, child archive metadata, child cleanup dispositions, or child terminal outcomes.

## Child Duties

Each child owns its proposal manifest, subtype manifest, promotion targets, acceptance criteria, validation plan, implementation-grade completeness review, review receipt, implementation prompt, conformance receipt, drift/churn receipt, validation evidence, closeout receipt, archive handling, cleanup disposition, and terminal proof when those stages apply.

## Parent Duties

The parent owns only program coordination artifacts:

- `resources/child-packet-index.yml`
- `resources/child-packet-index.md`
- `architecture/packet-sequence.md`
- `architecture/child-packet-contract.md`
- `architecture/program-closeout-plan.md`
- parent-local validation and closeout coordination evidence

## Negative Controls

- Parent summaries cannot satisfy child-owned receipts.
- Advisory governance findings cannot authorize lifecycle transitions.
- Generated projections cannot authorize delivery, closeout, archive, cleanup, or terminal proof.
- Proposal-local files cannot replace retained run evidence when retained evidence is required.
