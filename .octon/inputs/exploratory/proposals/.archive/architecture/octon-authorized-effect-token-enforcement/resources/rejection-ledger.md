# Rejection Ledger

| Candidate idea | Disposition | Reason |
|---|---|---|
| New Control Plane for token approvals | reject | Existing Control Plane and `authorize_execution` boundary are sufficient. |
| Token enforcement only in docs | reject | Leaves pseudo-coverage and bypass risk. |
| Generated token registry as authority | reject | Violates generated non-authority discipline. |
| Broad support-target expansion while tokenizing | reject | Scope must not admit browser/API/frontier surfaces. |
| Tokens for every read-only operation | reject | Overly broad; focus on material side effects. |
| Ambient GrantBundle as callee authority | reject | The callee must receive a typed effect token/guard. |
| Public `new` constructor as sufficient | reject | A token-shaped value is not authority without ledger verification. |
| Replay that re-executes consumed side effects | reject | Replay must default to dry-run/simulation. |
| Single broad `ServiceInvocation` for all effects without inventory rationale | reject unless justified | Over-broad classes hide coverage gaps. |
