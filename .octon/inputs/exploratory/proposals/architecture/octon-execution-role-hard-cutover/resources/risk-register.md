# Risk Register

| ID | Risk | Type | Impact | Mitigation |
|---|---|---|---|---|
| R1 | Hard deletion breaks undiscovered references to `framework/agency/**`. | Hard-cutover | High | Whole-repo grep and hard-cut validator before merge. |
| R2 | New execution-role schema under-specifies specialist boundaries. | Architecture | High | Specialist validator: stateless, bounded, no mission ownership, no widening. |
| R3 | Browser/API support remains claimed without runtime services. | Support-claim | Critical | Service-manifest/support-dossier validator fails closed. |
| R4 | Context packs become paperwork rather than runtime input. | Runtime | High | Execution request v3 requires context_pack_ref; receipts link evidence. |
| R5 | Generated cognition leaks authority into context packs. | Governance | High | Context-pack validator requires authority labels and generated-derived flags. |
| R6 | Workflow deletion removes useful governance gates. | Deletion | Medium | Workflow classification must prove governance/evidence/recovery value before deletion. |
| R7 | Charter/support schema vocabulary remains misaligned. | Governance | High | Support validation blocks cutover until aligned. |
| R8 | Runtime event surface becomes second control plane. | Architecture | High | Events are projections; canonical roots remain control/evidence. |
| R9 | Verifier becomes default multi-agent overhead. | Complexity | Medium | Verifier activation criteria required. |
| R10 | Proposal accidentally becomes dependency. | Proposal hygiene | High | Promotion-target backreference scan and proposal validator. |
