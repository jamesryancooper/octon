# GuardKit — Safety, Secrets, PII Hygiene

- **Purpose:** Enforces runtime safety by redacting PII/secrets and validating tool calls, adding governed, AI‑aware protection aligned with Harmony.
- **Responsibilities:** redacting PII/secrets, validating tool‑call payloads, enforcing path/egress allowlists, masking artifacts/logs, flagging risky ops.
- **Harmony alignment:** Advances Security‑by‑Default (OWASP ASVS, NIST SSDF) and Interoperability via consistent redaction marks/contracts consumable across kits.
- **Integrates with:** ToolKit (sandbox/egress policies), AgentKit (run‑time gates), PolicyKit (rules), ObservaKit (redaction marks/audit), IngestKit (pre‑write redaction), VaultKit (secret patterns/masking).
- **I/O:** reads tool‑call payloads/artifacts/policies; emits redacted logs/artifacts and pass/fail safety decisions.
- **Wins:** Prevents secret/PII leaks and unsafe ops without slowing normal work.
- **Implementation Choices (opinionated):**
  - Presidio: robust PII detection/anonymization for text artifacts and logs.
  - detect-secrets: high‑signal secret scanning (patterns + entropy) for diffs/artifacts.
  - pathspec: gitignore‑style allow/deny patterns to constrain file/egress targets.
  - jsonschema: strict tool‑call payload validation to block unsafe shapes/values.
- **Common Qs:** *Secret scanning?* Yes—pattern + entropy with allowlisted baselines. • *False positives?* Deterministic allowlists and testable rules. • *Offline?* Fully local; no external telemetry.
