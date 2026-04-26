# Concept Coverage Matrix

| Concept | Existing coverage | Proposed v1 closure | Classification |
| --- | --- | --- | --- |
| Controlled autonomy | Charter, support targets, authorization specs | Make limits reconciled, enforced, and visible | Materialize existing purpose |
| Support envelope | Authored support targets plus generated matrix/routes | Add reconciler gate and evidence bundle | Partially implemented -> implemented |
| Route resolution | Runtime route bundle and resolver metadata | Reconcile with support declarations/proof/pack routes/cards | Implemented but ungated across all surfaces |
| Capability-pack routing | Generated pack routes | Reconcile pack route posture with support/route claims | Implemented but needs cross-artifact closure |
| Proof-backed support | Support proof bundle roots | Require fresh proof for every live support claim | Partially implemented |
| Generated cannot widen authority | Constitution and architecture spec | Add validator tests for generated widening attempts | Implemented principle -> validated material behavior |
| Engine-owned authorization | `authorize_execution` contract and runtime code | Ensure all material APIs require `VerifiedEffect<T>` | Partially implemented |
| Typed effect tokens | Spec and minimal crate | Add full token metadata, verifier, consumption receipts, tests | Emerging |
| Revocation/expiry enforcement | Contracted in specs | Prove revoked/expired tokens fail on every material path | Emerging |
| Consumption evidence | Required by specs | Emit canonical token consumption receipts and run journal entries | Partial |
| Run lifecycle health | Run lifecycle state and operator read-model rules | Add generated per-run health schema/generator/validator | Missing/incomplete |
| Evidence completeness | Evidence-store contract and validators | Add migration-specific proof bundle and closure criteria | Implemented plus extension |
| Promotion safety | Proposal standards and architecture conformance | Define staged promotion and rollback path | Implemented process |
