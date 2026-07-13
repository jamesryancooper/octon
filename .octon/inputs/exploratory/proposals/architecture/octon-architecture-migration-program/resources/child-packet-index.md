# Child Packet Index

| Logical | Workgroup | Child proposal | Fixed dependencies |
| --- | --- | --- | --- |
| RP-00 | RWG-00 | `octon-architecture-migration-containment` | none |
| RP-01 | RWG-01 | `octon-architecture-migration-canonical-authority` | RP-00 |
| RP-02 | RWG-02 | `octon-architecture-migration-candidate-isolation` | RP-00 |
| RP-03 | RWG-03 | `octon-architecture-migration-transactional-runtime-store` | RP-01 |
| RP-04 | RWG-04 | `octon-architecture-migration-local-broker` | RP-01, RP-02, RP-03 |
| RP-05 | RWG-05 | `octon-architecture-migration-sanitized-git` | RP-04 |
| RP-06 | RWG-06 | `octon-architecture-migration-verification-publication` | RP-01, RP-03, RP-05 |
| RP-07 | RWG-07 | `octon-architecture-migration-signed-evidence` | RP-03, RP-04, RP-06 |
| RP-08 | RWG-08 | `octon-architecture-migration-recovery-class-b` | RP-06, RP-07 |
| RP-09 | RWG-09 | `octon-architecture-migration-self-development-trust-activation` | RP-06, RP-07, RP-08 |
| RP-10 | RWG-10 | `octon-architecture-migration-workspace-projects` | RP-01 |
| RP-11 | RWG-11 | `octon-architecture-migration-harness-factory` | RP-01, RP-02, RP-10 |
| RP-12 | RWG-12 | `octon-architecture-migration-extension-supply-chain` | RP-07, RP-11 |
| RP-13 | RWG-12 | `octon-architecture-migration-bounded-child-agents` | RP-08, RP-11 |
| RP-14 | RWG-13 | `octon-architecture-migration-solo-dogfood-promotion` | core: RP-08, RP-09, RP-10, RP-11; program closeout: RP-12, RP-13 |

All children are required sibling proposals and remain draft. The parent does
not own child receipts, targets, statuses, archives, or terminal outcomes.
