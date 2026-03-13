# Tool — Action Wrappers (Shell/Git/HTTP/FS)

- **Purpose:** Unified, sandboxed action adapters with timeouts/retries.
- **Responsibilities:** shell exec, git ops, HTTP calls, file IO, Vercel CLI wrappers.
- **Integrates with:** Agent (execution), Guard (sandbox policies), Observe (logs), Cache (memo).
- **I/O:** action results, artifacts.
- **Wins:** Safer, predictable side-effects with consistent telemetry.
- **Octon default:** Deny-by-default paths; redact outputs; require approvals for destructive ops.
