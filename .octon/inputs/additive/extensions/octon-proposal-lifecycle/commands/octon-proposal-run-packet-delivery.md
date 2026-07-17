# Packet - Run Contained Delivery

```text
/octon-proposal-run-packet-delivery target=<proposal-packet-path> outcome=implemented|archive-ready route=stage-only profile=<profile-path> run-id=<id>
```

All inputs are required. This delegates to the canonical
`proposal-packet-delivery` workflow and adds no independent authority.

Direct-main, hosted branch-no-PR, landing, sync, cleanup,
landed/synced/cleaned, and omitted/default effectful requests fail before
dispatch with `RP00_CONTAINMENT_PUBLICATION_DISABLED`. Exact work is preserved.
No Git/GitHub, provider, publication, archive relocation, cleanup, or branch
deletion is performed or delegated.
