# Implementation Traceability

| Proposed change | Source repo anchor | Durable target | Control target | Evidence target |
| --- | --- | --- | --- | --- |
| Stewardship Program | Super-root authority model, mission lifecycle standards | `framework/.../stewardship-program-v1.schema.json`, `instance/stewardship/.../program.yml` | `state/control/stewardship/.../status.yml` | `state/evidence/stewardship/...` |
| Stewardship Epoch | mission-control lease, autonomy budget, circuit breaker | `stewardship-epoch-v1.schema.json` | `state/control/.../epochs/.../epoch.yml` | `state/evidence/.../epochs/...` |
| Trigger/admission | orchestration practices and v2 mission handoff | trigger/admission schemas | trigger/admission control roots | trigger/admission evidence roots |
| Idle/Renewal | budget/breaker/lease semantics | admission/renewal schemas | admission/renewal control roots | retained closeout evidence |
| Campaign hook | campaign-promotion-criteria | optional cross-reference docs | campaign candidate decision | campaign candidate evidence |
