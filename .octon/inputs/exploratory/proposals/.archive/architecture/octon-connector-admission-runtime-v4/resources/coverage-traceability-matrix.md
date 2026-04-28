# Coverage Traceability Matrix

| Source requirement | Existing evidence | Proposed change | Acceptance proof |
| --- | --- | --- | --- |
| Connector -> operation -> capability packs | Capability-pack registry exists | `connector-operation-v1.schema.json` requires pack mapping | Validator rejects unknown pack |
| Material-effect classification | Material side-effect inventory exists | Operation requires material class | Validator rejects unknown class |
| Support posture | Support-targets finite model exists | Admission requires support tuple/proof refs | No generated widening test passes |
| Policy/authorization | Execution authorization exists | Operation receipt links to grant/effect token | Negative bypass test passes |
| Evidence | Evidence roots exist | Connector evidence root and receipt schema | Retained evidence test passes |
| Campaign boundaries | Campaign criteria defer campaigns | Connector proposal does not promote campaigns | Campaign gate remains no-op/deferred |
| Release future | No release envelope selected | Connector design supports future release provider operations | Deferred ledger records release scope |
