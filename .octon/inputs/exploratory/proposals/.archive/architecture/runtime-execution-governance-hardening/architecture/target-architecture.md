# Target Architecture

## Historical end state

The durable architecture promoted from this packet is:

1. one shared execution-authorization boundary governs service, workflow, and
   executor paths
2. workflow and stage execution require explicit grants and emit matching
   receipts
3. retained execution evidence lives under durable run-evidence roots rather
   than ad hoc workflow-local layouts
4. protected execution posture is hard-enforced in runtime, docs, and CI
5. external executor behavior is constrained by durable runtime contracts

## Boundary posture

- material execution remains routed through durable runtime authority code and
  specs outside the proposal workspace
- retained run evidence remains in durable `state/evidence/runs/**` roots
- runtime architecture documents and CI guards project the same governance
  model
- proposal paths remain non-canonical after promotion and archival
