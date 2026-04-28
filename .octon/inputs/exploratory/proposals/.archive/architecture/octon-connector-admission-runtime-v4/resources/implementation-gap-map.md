# Implementation Gap Map

| Gap | Required implementation |
| --- | --- |
| Operation identity | Add connector-operation schema and instance operation files. |
| Admission posture | Add connector-admission schema and repo-specific admission roots. |
| Proof bundle | Add trust dossier schema and evidence requirements. |
| Runtime posture | Add control roots for connector status. |
| Evidence | Add connector evidence roots and receipts. |
| CLI | Add inspect/admit/quarantine/retire/evidence commands. |
| Validation | Add connector validation suite and negative tests. |
| Support target | Add connector-specific proof hooks without live widening. |
| Generated views | Add derived read models only after control/evidence roots exist. |
| MCP mapping | Normalize MCP as connector operations mapping to existing packs/classes. |
