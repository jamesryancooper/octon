# Stage 02: Validate Packet State

Resolve the current target packet and rerun accepted-review, readiness, and
implementation authorization gates from repository state.

Required checks:

- The proposal review digest is current.
- The packet is accepted and implementation-authorized.
- Open blockers are zero.
- Promotion targets are current and unambiguous.
- Strict pre-integration architecture review evidence is present, passing, and
  fresh for the current packet digest.
- Generated prompts and proposal-local summaries are treated as instructions or
  context only, never as authority for implementation, promotion, closeout,
  archive, landing, cleanup, sync, or `cleaned` claims.
