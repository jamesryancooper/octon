# Rejection Ledger

This packet explicitly rejects the following alternatives.

| Rejected alternative | Reason |
|---|---|
| Greenfield runtime journal unrelated to existing contracts | Octon already has canonical runtime contracts; greenfield replacement would create architecture drift. |
| Runtime-state as source of truth | Existing state-reconstruction principle says event ledger wins. |
| Generated operator read model as runtime input | Violates generated/read-model non-authority. |
| Host checks/comments/labels as lifecycle authority | Host surfaces are projections only. |
| Browser/API/MCP admission bundled into this step | Would broaden scope and weaken promotion safety. |
| Untyped logs as replay basis | Cannot prove causal, policy, or evidence completeness. |
| Replay that repeats live effects by default | Unsafe and violates authorization boundary. |
| Per-adapter event formats | Breaks support-target portability and replay. |
| Model-produced self-report as closeout evidence | Insufficient for constitutional execution proof. |
| Multi-agent expansion before journal hardening | Subagent evidence stitching needs causal journal first. |
