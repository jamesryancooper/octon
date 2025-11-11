# ToolKit — Action Wrappers (Shell/Git/HTTP/FS)

- **Purpose:** Unified, sandboxed action adapters with timeouts/retries.
- **Responsibilities:** shell exec, git ops, HTTP calls, file IO, Vercel CLI wrappers.
- **Integrates with:** AgentKit (execution), GuardKit (sandbox policies), ObservaKit (logs), CacheKit (memo).
- **I/O:** action results, artifacts.
- **Wins:** Safer, predictable side-effects with consistent telemetry.
- **Harmony default:** Deny-by-default paths; redact outputs; require approvals for destructive ops.
