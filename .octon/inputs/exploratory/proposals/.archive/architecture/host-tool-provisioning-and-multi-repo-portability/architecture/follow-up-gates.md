# Follow-Up Gates

## Explicitly deferred items

| Item | Why deferred | Blocking? | Reopen condition |
| --- | --- | --- | --- |
| A generalized `/doctor` umbrella command | Useful, but not required for the first host-tool provisioning architecture. | no | reopen after `provision-host-tools` lands cleanly |
| Additional package-manager adapters beyond initial installer kinds | Tool-by-tool adapter coverage can expand later. | no | reopen when a concrete unsupported host tool requires it |
| Automatic background upgrades | Risky without explicit operator approval and version pin semantics. | no | reopen after provenance and rollback posture are proven |
| Cross-user or system-wide shared tool homes | Out of scope; the first model is user-scoped. | no | reopen if a multi-user deployment model is explicitly required |

## Future hardening gates

1. Add more tool contracts only after their provenance and verification story is explicit.
2. Consider `/doctor --fix` only after `provision-host-tools` proves stable.
3. Consider repo-local generated resolution views only if they remain clearly non-authoritative.
