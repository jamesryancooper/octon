# Coverage Traceability Matrix

| Source requirement | Proposed artifact | Validation / closure proof |
| --- | --- | --- |
| Stewardship Program | `stewardship-program-v1.schema.json`, `instance/stewardship/programs/<id>/program.yml` | Schema validation, program authority gate |
| Stewardship Epoch | `stewardship-epoch-v1.schema.json`, `state/control/.../epochs/<id>/epoch.yml` | Epoch gate validation |
| Event triggers | `stewardship-trigger-v1.schema.json`, trigger control/evidence roots | Trigger normalization tests |
| Admission decisions | `stewardship-admission-decision-v1.schema.json` | Admission gate tests |
| Idle mode | Admission decision outcome + idle CLI | Idle gate tests and evidence |
| Renewal decisions | `stewardship-renewal-decision-v1.schema.json` | Renewal closeout tests |
| Ledger | `stewardship-ledger-v1.schema.json` | Ledger indexes without replacing mission/run evidence |
| Evidence profiles | `stewardship-evidence-profile-v1.schema.json` | Evidence completeness tests |
| Stewardship-aware Decision Requests | Decision Request extension docs/schemas | DR blocking/resolution tests |
| Campaign hooks | campaign relationship docs + campaign gate | Campaign no-go/default-deferred tests |
