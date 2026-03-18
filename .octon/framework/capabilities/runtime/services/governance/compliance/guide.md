# Compliance — Standards Mapping & Evidence

- **Purpose:** Map OWASP ASVS v5 and NIST SSDF controls to concrete tasks and produce auditable, AI-assisted evidence bundles.
- **Responsibilities:** mapping controls to tasks, normalizing evidence, correlating ADR/PR links, generating coverage matrices, emitting gate statuses.
- **Integrates with:** Policy (gates), Eval (consumes checks), Doc (ADR/spec links), Patch (PR annotations/evidence).
- **I/O:** inputs: control catalogs (ASVS/SSDF), Eval reports, ADR/PR metadata, SBOM links; outputs: coverage matrices, evidence bundles, PR status checks.
- **Wins:** Demonstrates due care with minimal overhead; accelerates approvals and audits.
- **Octon default:** Advances governance and interoperability via consistent control contracts and gating hooks; maintains per‑PR and per‑release auditability.

- **Implementation Choices (opinionated):**
  - LangGraph: orchestrates long-running, stateful evidence aggregation across checks and releases.
  - RAGatouille: retrieves and ranks relevant ADR/PR/report snippets to justify control coverage.
  - CycloneDX Python lib: reads and links SBOM artifacts as compliance evidence.
