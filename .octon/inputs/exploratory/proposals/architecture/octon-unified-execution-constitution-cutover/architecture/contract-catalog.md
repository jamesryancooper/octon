# Contract Catalog

## Contract families

### Constitutional contracts
- Harness Charter
- constitutional precedence files
- fail-closed obligations
- evidence obligations
- support-target schema

### Objective contracts
- Workspace Charter
- Mission Charter
- Run Contract
- Execution Attempt / Stage Contract

### Authority contracts
- ApprovalRequest
- ApprovalGrant
- ExceptionLease
- Revocation
- QuorumPolicy
- DecisionArtifact

### Adapter contracts
- Model Adapter Contract
- Host Adapter Contract
- Capability / Tool Contract

### Runtime contracts
- Run Manifest (or canonical runtime-state equivalent)
- Checkpoint
- Continuity Artifact
- Rollback / Compensation Posture
- Replay Pointer / Bundle Contract

### Assurance and observability contracts
- Assurance Report
- Intervention Record
- Measurement Record
- Failure Taxonomy Record
- RunCard
- HarnessCard
- Evidence Retention Contract

## Lifecycle expectations by contract class
- authored contracts live under `framework/**` or `instance/**`
- runtime control artifacts live under `state/control/**`
- continuity artifacts live under `state/continuity/**`
- retained evidence and disclosure live under `state/evidence/**`
- generated projections are non-authoritative
