# StackKit — Tech Stack Design & Governance

- **Purpose:** Defines and governs the tech stack from AI‑grounded evidence, emitting a codified `stack.yml` and ADRs other kits consume under Harmony gates.
- **Responsibilities:** curating stack profiles, enforcing version/compatibility policies, recording ADRs with rationale, proposing upgrades/migrations, emitting scaffolding defaults (delegating scaffolding to ScaffoldKit).
- **Harmony alignment:** advances interoperability via consistent profiles/ADRs consumed across kits; exposes governance hooks so stack decisions are policy‑ and eval‑gated.
- **Integrates with:** SearchKit (external evidence), QueryKit (internal usage evidence), ScaffoldKit (scaffold from profile), DiagramKit (architecture visuals), Dockit (ADRs), DepKit (advisories/upgrades), MigrationKit (db choices → plans), PolicyKit/EvalKit (gates), PatchKit (PRs).
- **I/O:** reads `stack/stack.yml` and evidence packs; emits updated `stack/stack.yml` constraints and `docs/adr/**` entries.
- **Wins:** Reproducible, auditable stack choices; safer upgrades with clear rationale.
- **Implementation Choices (opinionated):**
  - ruamel.yaml: round‑trip `stack.yml` while preserving comments and ordering.
  - jsonschema: validate profile structure and required fields.
  - semver: compare/enforce version ranges for policy checks.
- **Common Qs:**
  - *Enforce versions?* Yes—PolicyKit/EvalKit gate PRs against the profile.
  - *Migrations?* MigrationKit handles schema/data; DevKit handles code.
  - *Greenfield scaffolds?* ScaffoldKit generates from the chosen profile.
  - *Upgrades?* DepKit proposes with SearchKit evidence; StackKit records policy.

---

## Minimal Interfaces (copy/paste scaffolds)

### StackKit (profile)

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