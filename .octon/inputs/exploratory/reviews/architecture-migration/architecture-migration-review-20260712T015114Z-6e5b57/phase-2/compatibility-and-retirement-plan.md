# Compatibility and Retirement Plan

| Legacy surface | Temporary compatibility | Retirement trigger | Forbidden fallback |
|---|---|---|---|
| Lifecycle invocation mode/provenance | Read-only observability fields | All launch paths consume exact guard | Treating unattended as authority |
| File token records | Immutable import and generated projection | Store migration and recovery proof | Dual authoritative writes |
| Runtime journal/manifests | Projected human/evidence view | SQLite event/outbox is canonical | File-based sequencing under concurrency |
| policy-grant-broker.sh | Rename/retain as policy helper if useful | Local broker API owns effects | Calling it the durable-effect broker |
| Direct-main route | Parse old receipts only | Contracts/CLI/skills no longer select it | Autonomous direct-main |
| Hosted no-PR scripts | Reuse validation logic inside broker tests | Broker adapter and verifier proven | Direct ambient git push |
| Current pr-auto-merge | Disabled record only | Immutable worker, if retained, passes attack suite | Candidate checkout with token |
| Required context checks | Informational during verifier shadow | Authenticated verdict required | Context-name-only trust |
| Existing Project Profile | Descriptive input to Workspace Project | Project migration complete | Profile as authority/project ID |
| Task harness fixtures | Compiler input/compatibility parser | Digest-bound factory cutover | Fixture self-authorizes launch |
| Unsigned extension packs | Stage-only/quarantine | Signed catalog import complete | Live unpinned external pack |
| Unsigned evidence | Label and retain under legacy policy | Signed checkpoint regime active | Retroactive authenticity claim |
| Evolution promotion readiness | Retain as preflight | Exact activator owns installation | Readiness report treated as activation |

Retirement is clean-break at the authority/effect boundary. Format readers may
remain for historical inspection, but no retired format can mint, consume,
perform, verify, or activate.

