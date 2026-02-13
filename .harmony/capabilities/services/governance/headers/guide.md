# Headers — Security Headers & CSP

- **Purpose:** Define and validate CSP/security headers to harden apps; AI suggests safe defaults and staged rollouts per Harmony.
- **Responsibilities:** standardizing policies, generating headers, validating against best practices, staging report‑only rollouts, managing nonce/hash helpers.
- **Harmony alignment:** advances interoperability via consistent header/CSP contracts; enables governance hooks so gates verify policies before merge and release.
- **Integrates with:** Policy/Eval/Test/Compliance (gates).
- **I/O:** CSP/header configs and validation reports.
- **Wins:** Blocks XSS/clickjacking by default; safer, auditable policy evolution.
- **Implementation Choices (opinionated):**
  - csp-evaluator: analyzes CSP strings for common bypasses to validate policies.
  - Mozilla Observatory: checks security headers against community benchmarks for actionable grades.
  - OWASP ZAP: headless scans to verify headers/CSP across routes during CI.

---
