# Stage 03: Validate Program State

Resolve the current target program and rerun accepted-review/readiness gates from repository state.

Required checks:

- The proposal review digest is current.
- The program is accepted and implementation-authorized.
- Open blockers are zero.
- Child packet scope is current and unambiguous.
- The retained delivery-readiness preflight receipt is fresh and passing before expensive lifecycle continuation.
- Generated prompts and proposal-local summaries are treated as instructions or context only, never as authority for implementation, closeout, archive, landing, cleanup, sync, or `cleaned` claims.
