# Stack — Tech Stack Design & Governance

- **Purpose:** Defines and governs the tech stack from AI‑grounded evidence, emitting a codified `stack.yml` and ADRs other services consume under Harmony gates.
- **Responsibilities:** curating stack profiles, enforcing version/compatibility policies, recording ADRs with rationale, proposing upgrades/migrations, emitting scaffolding defaults (delegating scaffolding to Scaffold).
- **Harmony alignment:** advances interoperability via consistent profiles/ADRs consumed across services; exposes governance hooks so stack decisions are policy‑ and eval‑gated.
- **Integrates with:** Search (external evidence), Query (internal usage evidence), Scaffold (scaffold from profile), Diagram (architecture visuals), Doc (ADRs), Dep (advisories/upgrades), Migration (db choices → plans), Policy/Eval (gates), Patch (PRs).
- **I/O:** reads `stack/stack.yml` and evidence packs; emits updated `stack/stack.yml` constraints and `docs/adr/**` entries.
- **Wins:** Reproducible, auditable stack choices; safer upgrades with clear rationale.
- **Implementation Choices (opinionated):**
  - ruamel.yaml: round‑trip `stack.yml` while preserving comments and ordering.
  - jsonschema: validate profile structure and required fields.
  - semver: compare/enforce version ranges for policy checks.
- **Common Qs:**
  - *Enforce versions?* Yes—Policy/Eval gate PRs against the profile.
  - *Migrations?* Migration handles schema/data; Dev handles code.
  - *Greenfield scaffolds?* Scaffold generates from the chosen profile.
  - *Upgrades?* Dep proposes with Search evidence; Stack records policy.

---

## Minimal Interfaces (copy/paste scaffolds)

### Stack (profile)

```yaml
runtime: node20
web: nextjs^14
db: postgres^16
queue: bullmq^5
testing: vitest^1
monorepo: turborepo
infra:
  deploy: vercel
  previews: true
  feature_flags: vercel-edge-config
  observability: opentelemetry
policies:
  licenses: [MIT, Apache-2.0]
  min_coverage: 0.7
  security_standards:
    - owasp_asvs_v5
    - nist_ssdf
rationales:
  architecture: "Monolith-first, hexagonal boundaries enforced by contract tests"
  queue: "At-least-once + latency < 30ms"
```
