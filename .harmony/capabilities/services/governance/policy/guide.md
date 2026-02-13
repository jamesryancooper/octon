# Policy — Rules & Guardrails

- **Purpose:** Codifies repo/delivery policies (licenses, versions, paths, CODEOWNERS) and enforces AI-run gates aligned to Harmony.
- **Responsibilities:** encoding declarative rules, validating policy schemas, gating plans/runs/PRs, scoping path/owner rules, emitting status checks.
- **Harmony alignment:** advances governance and safety gates via consistent policy contracts consumed by orchestration services; enforces ASVS/SSDF-aligned guardrails early.
- **Integrates with:** Plan (plan gates), Agent (runtime gates), Dev/Doc (targets), Stack (enforce profile), Compliance (standards enforce), Headers (security policy gates), Patch (PR gates).
- **I/O:** reads `policy/*.yml`, `CODEOWNERS`, stack profile; emits decision JSON and CI/PR status checks.
- **Wins:** Stops risky changes early with clear, actionable reasons; consistent, auditable enforcement.
- **Common Qs:** *Soft vs hard rules?* Both—warn or block. *Who writes rules?* Teams via YAML/CODEOWNERS reviewed in PRs. *Where do gates run?* Plan/Agent during plans/runs and Patch in CI.
- **Implementation Choices (opinionated):**
  - Open Policy Agent (OPA): declarative, fast policy evaluation across JSON/YAML inputs.
  - PyYAML: parse and validate `policy/*.yml` configurations.
  - pathspec: gitignore/CODEOWNERS-style path matching for scoped rules.
- **Harmony default:** Encode **ASVS v5** controls, **NIST SSDF** activities, branch protection, **CODEOWNERS**, and path policies that reflect hexagonal boundaries.
