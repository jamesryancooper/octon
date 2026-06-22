# Acceptance Criteria

- Review refresh can be deferred until an authorized phase reaches a stable digest boundary.
- Gates that need current review truth still fail closed on stale evidence.
- Diagnostics identify stale cause, last mutation class, and owning refresh route.

## Safety Acceptance

- No parent evidence replaces child-owned evidence.
- No PR fallback is introduced.
- No protected retained evidence is deleted.
- No generated output is hand-edited.
