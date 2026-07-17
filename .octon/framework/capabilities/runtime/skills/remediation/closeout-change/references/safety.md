# Closeout Change Safety

- Preserve unrelated work and exact candidate refs.
- Never select or execute direct-main.
- Never authorize or perform local/hosted no-PR landing.
- Never authorize or perform branch, ref, worktree, or cleanup mutation.
- Never report `cleaned`, `synced`, or autonomous publication success.
- Fail before mutation with `RP00_CONTAINMENT_PUBLICATION_DISABLED` or
  `RP00_CONTAINMENT_CLEANUP_DISABLED`.
- Treat dry-run cleanup as read-only inventory only.
- Treat generated, provider, host, chat, and historical receipt state as
  non-authoritative.
- Preserve and block when evidence is missing, stale, ambiguous, or denied.
