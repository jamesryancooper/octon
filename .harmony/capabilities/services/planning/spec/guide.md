# Spec — Spec‑First, Powered by GitHub's Spec Kit

Spec (`speckit`) wraps GitHub's Spec Kit to author, validate, and publish Harmony‑aligned specifications, then provides these validated inputs to Plan. Plan owns ADRs and BMAD.

> Terminology note: "Spec" refers to our AI Services Platform service (code `speckit`) that wraps GitHub's Spec Kit. Mentions of the upstream tool explicitly use "GitHub's Spec Kit".

## Quick Snapshot

- Slash commands: `/speckit.constitution`, `/speckit.specify`, `/speckit.clarify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement` (+ optional `/speckit.analyze`, `/speckit.checklist`)
- Wrapper ops: `init` (bootstrap), `validate` (specify check + structure), `render` (publish via Doc), `diagram` (hand off to Diagram)
- Inputs: repo, agent, and `specify` CLI; optional contracts under `specs/<NNN>-<feature>/contracts/`
- Outputs: `.specify/memory/constitution.md`, `specs/<NNN>-<feature>/{spec.md, plan.md, tasks.md, data-model.md, research.md, quickstart.md, contracts/*}`
- Artifacts: Deterministic docs and scripts under `.specify/` and `specs/` per Spec
- ADRs & BMAD: handled by Plan (not Spec)

## What It Does

- Wraps GitHub’s Spec Kit CLI to run slash‑command workflows reliably across agents
- Validates prerequisites and structure (`specify check`, folders/files) and normalizes outputs
- Integrates with Doc (publish) and Diagram (render diagrams); exposes telemetry hooks
- Emits review‑ready artifacts; aligns to ASVS/NIST SSDF and Harmony Core Comms

## Wins

- Consistent, auditable specs and ADRs across the monorepo
- Faster planning with clear contracts and acceptance criteria
- Spec‑first flow that maps directly to Harmony’s Lean AI‑Accelerated Methodology
- Smooth handoff to Plan/Agent with contract‑driven boundaries

## Opinionated Implementation Choices

- Use GitHub’s Spec Kit as the authoritative workflow and artifacts
- Externalize contracts under `packages/contracts/**`
- CI gates: oasdiff on API contracts, schema validation (where applicable), content linting

## Core Responsibilities

- Orchestrate Spec workflows (constitution/spec/plan/tasks/implement) via wrapper
- Ensure required artifacts exist and are well‑formed per Spec's structure
- Validate contracts are linked and versioned where present
- Delegate publishing to Doc and diagram rendering to Diagram
- Do not own ADRs/BMAD (Plan owns both) or long‑lived state

## Ecosystem Integrations

- Plan: consumes Spec artifacts (spec/plan/tasks) and owns ADRs + BMAD
- Agent: optional MCP tools to drive Spec wrapper steps (guarded; off by default)
- Doc: publishes docs; Diagram: renders diagrams
- Test/Policy/Eval: gates for contracts, security, and standards

## Operating Modes / Usage Recipes

### mode: init — bootstrap Spec project

- What it does: run `specify init` and scaffold `.specify/` and `specs/<NNN>-<feature>/spec.md`
- I/O: writes `.specify/**` (scripts/memory) and `specs/<NNN>-<feature>/spec.md`
- Wins: consistent starting point; agent/tooling wired up
- Opinionated choices: enforce recommended flags; record environment for reproducibility

Example

```bash
speckit init --feature feature-name --owner you@org --out docs/specs/feature-name
```

### mode: validate — prerequisites + structure

- What it does: run `specify check` and verify required artifacts (constitution/spec/plan/tasks)
- I/O: reads `.specify/**` and `specs/<NNN>-<feature>/**`; emits Core Comms error envelopes
- Wins: prevents drift and missing contracts; CI‑friendly output

Example

```bash
speckit validate --path docs/specs/feature-name
```

### mode: render — publish with Doc

- What it does: hand off to Doc for site rendering and navigation entries
- I/O: Doc build artifact; optional `manifest.json` for published pages
- Wins: single‑path author → publish flow

Example

```bash
speckit render --path docs/specs/feature-name --publish
```

## Signals/Capabilities (optional)

- `spec.present`: `specs/<NNN>-<feature>/spec.md` exists
- `plan.present`: `plan.md` exists (after `/speckit.plan`)
- `tasks.present`: `tasks.md` exists (after `/speckit.tasks`)
- `contracts.linked`: contracts folder present and referenced

## I/O & Contracts

- API endpoints (if exposed as a service): OpenAPI at `packages/contracts/openapi.yaml`
- Schemas: optional JSON Schemas for contracts or spec front matter (e.g., `packages/contracts/schemas/spec-frontmatter.schema.json`)
- Inputs/Outputs: Spec‑generated Markdown/docs in `.specify/` and `specs/<NNN>-<feature>/`

## Artifacts & Layout (Spec)

```plaintext
/.specify/
  memory/constitution.md
  scripts/*.sh
  templates/*-template.md
specs/<NNN>-<feature>/
  spec.md
  plan.md
  tasks.md
  data-model.md
  quickstart.md
  research.md
  contracts/
    api-spec.json
    signalr-spec.md
```

## Versioning & Compatibility

- Track `specify` CLI version and template set; record in run metadata/history
- Backward compatibility: additive changes in docs; contract breaking changes require version bumps

## Configuration & Tuning

Minimal config

```yaml
enabled: true
required_fields: [title, contracts, slos, threat_model]
defaults:
  slo_targets: { api_availability: 99.9, api_p95_ms: 300 }
```

Advanced knobs

```json
{
  "validation": { "strict": true, "deny_unknown": true },
  "adr": { "required": true, "status_allow": ["Proposed","Accepted","Superseded"] }
}
```

## Sizing & Capacity (optional)

- Designed for small repos to large monorepos; spec runs are CPU‑light
- CI cost is dominated by contract validation (oasdiff, schema); cache results

## Publishing / Serving (optional)

- Doc integration: publish to docs site
- Optional MCP provider to expose tools to agents (stdio for local, wss for remote)

## Wrapper Benefits (Why a thin wrapper)

- Agent abstraction: invoke `specify` consistently across IDE/CLIs; recover from UX quirks
- Governance by default: enforce clarify/analyze/checklist before implement
- Observability: emit spans/logs/metrics; attach run metadata and artifacts
- CI hand‑offs: compose spec→plan→tasks→analyze→PR flows with required checks
- Security hygiene: centralized env/secrets and redaction

## Feature Roadmap: High‑Impact Add‑Ons (Harmony‑aligned)

- Now (0–2 weeks)
  - Feature: Pre‑implementation gates with machine‑readable reports
  - Outcome: Enforce clarify → analyze → checklist before implement; CI can block on structured failures.
  - Feature: Prompt History Records (PHR) under `history/`
  - Outcome: Durable audit trail and reproducibility for every run.
  - Feature: PR status checks via GitHub Checks API
  - Outcome: Inline annotations and blocking checks surface issues directly in PRs.

- Next (2–6 weeks)
  - Feature: Agent context sync (AGENTS.md per agent)
  - Outcome: Prevent stale‑context execution; require up‑to‑date context before implement.
  - Feature: Versioned template selection & release pinning
  - Outcome: Deterministic renders and safer rollbacks via `history/version.json`.
  - Feature: OpenTelemetry GenAI telemetry + budgets/circuit breakers
  - Outcome: End‑to‑end traces with budget enforcement for cost/latency.

- Later (6+ weeks)
  - Feature: Security gates (CodeQL, Semgrep, OSV on SBOM/lockfiles)
  - Outcome: Block merges on critical findings; strengthen supply‑chain hygiene.
  - Feature: Repro dev env from plan (Dev Containers) + Mermaid rendering
  - Outcome: One‑command reproducible environments; diagrams render automatically in docs.
  - Feature: SBOM + provenance attestations; protected deploy previews
  - Outcome: Compliance‑ready releases with signed provenance and gated previews.

## Validation & Health

- Validate tools and structure; verify contracts folder presence/links
- Drift/parity checks: required Spec artifacts present and parsable
- Health probes: `speckit validate --path ...` returns non‑zero on failures

## Observability (optional)

- Logs/metrics/traces: `{kit: "speckit", op, path, duration_ms, outcome}`
- Redaction/privacy: no secrets in specs; mask file paths if needed

## Harmony Alignment

- Spec‑first, contract‑driven; OpenAPI/JSON‑Schema enforced in CI
- Auditability via reproducible artifacts/snapshots and ADRs
- Security baseline: OWASP ASVS/NIST SSDF mapping in every spec
- Modular CI/CD: tiny PRs, previews, feature flags; rollback via Patch/Release
- See `apps/docs/src/content/docs/methodology/README.md`

## Minimal Interfaces (copy/paste)

```bash
# Bootstrap
speckit init --feature feature-name --out . --ai claude

# Validate (CI gate: tools + structure)
speckit validate --path .
```

## Contracts & Schemas

- Keep OpenAPI/JSON‑Schema under `packages/contracts/**`
- Optional spec front matter schema: `packages/contracts/schemas/spec-frontmatter.schema.json`
- Example Spec: `docs/specs/speckit/`
- Runbook: `.harmony/capabilities/services/planning/spec/runbook.md`

## Troubleshooting

- InvalidInput → missing artifacts or invalid structure; run `specify check` via `speckit validate`
- NotFound → feature directory not created; ensure `/speckit.specify` ran and `SPECIFY_FEATURE` is set (if used)
- Conflict → existing files differ; use wrapper idempotent options or review diffs
- Transient → CI contract diff fetch failed; retry or pin base ref

## Common Questions

- How does this relate to GitHub’s Spec Kit?
  - We wrap GitHub's Spec Kit with our Spec wrapper to standardize runs and wire governance/telemetry; follow GitHub's Spec Kit docs for commands and artifacts.
- Do I need to expose an MCP provider?
  - Optional. Expose `speckit.init|validate|render|diagram` as tools per the MCP Provider Guide.
- What about agent guardrails?
  - Use pre/post validators from the Agent Layer Guide; enforce budgets and schema validation on mutating tool calls.
