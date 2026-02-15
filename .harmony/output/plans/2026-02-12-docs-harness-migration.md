# Plan: Migrate Harness Documentation into `.harmony/`

## Context

The `docs/` directory contains ~256 files. Approximately 160 (~62%) are harness
content (principles, practices, methodology, architecture, governance) that tells
agents how to operate and should travel with the harness. The remaining ~96
(~38%) are project-specific (dev environment, engine catalogs, tech stack
choices, feature specs, service implementation docs).

This plan migrates harness content into `.harmony/` subsystems following
Option C: distribute into existing subsystems by semantic domain, with a new
`cognition/architecture/` for cross-cutting architecture docs.

**Guiding principle:** Content belongs where the agent looks for it.
Reasoning goes in cognition. Working practices go in agency. Standards go in
quality. Patterns go in scaffolding. Workflows go in orchestration.

## Decision Updates (2026-02-12)

1. **Continuity-plane docs are rewritten before migration.** We will not move
   `docs/architecture/continuity-plane/*` verbatim because they currently
   describe a legacy `.continuity/` model that does not match the active
   `.harmony/continuity/` contract.
2. **Principles are consolidated into one canonical file.**
   `docs/principles.md` and `docs/principles/README.md` are merged into a
   single canonical `.harmony/cognition/principles/principles.md` before migration
   to avoid drift.
3. **`docs/TASKS/*` becomes manifest-backed workflows, not a new primitive.**
   Task guides are rewritten into `.harmony/orchestration/workflows/tasks/`
   entries with `manifest.yml` and `registry.yml` coverage.

---

## Destination Map

### `.harmony/cognition/_meta/architecture/` (NEW)

Harness and methodology architecture docs. Cross-cutting structural reasoning.

**From `docs/architecture/` (core harness architecture):**

- `overview.md` (17K) — Harmony Structural Paradigm
- `agent-as-runtime.md` (10K) — agent-as-runtime model
- `agent-runtime-caveats.md` (10K) — agent runtime risk model
- `agent-architecture.md` (20K) — target agent model
- `agent-roles.md` (12K) — planner/builder/verifier roles
- `governance-model.md` (14K) — HITL gates, risk rubric, CI gates
- `kaizen-subsystem.md` (20K) — self-improvement loop
- `observability-requirements.md` (17K) — OTel instrumentation
- `tooling-integration.md` (24K) — CI/CD and agent integration
- `migration-playbook.md` — adoption guidance
- `layers.md` (12K) — vertical slices vs layers
- `contracts-registry.md` (7K) — OpenAPI/JSON Schema registry
- `mape-k-loop-modeling.md` (10K) — Monitor-Analyze-Plan-Execute loop
- `repository-blueprint.md` (22K) — generic repo structure template
- `monorepo-polyglot.md` (28K) — polyglot workspace organization
- `monorepo-layout.md` (15K) — physical layout
- `resources.md` (60K) — resource index
- `feature-unit-taxonomy.md` — feature/unit classification
- `comparative-landscape.md` — landscape analysis
- `slices-vs-layers.md` — slices vs layers terminology

**From `docs/architecture/knowledge-plane/` (1 file):**

- `knowledge-plane.md` — system knowledge design (specs, contracts, code, tests)

**From `docs/architecture/harness/` (cross-cutting harness meta-docs only):**

- `README.md` (35K) — overall harness specification
- `taxonomy.md` — harness domain taxonomy
- `shared-foundation.md` — shared foundation model
- `dot-files.md` — dot-file conventions
- `context.md` — context subsystem design
- Graph models (7 files): `context-graph.md`, `impact-graph.md`,
  `intent-graph.md`, `memory-graph.md`, `permission-graph.md`,
  `plan-graph.md`, `state-graph.md`

> **Note:** Remaining `harness/` files are distributed by subsystem below.
> `content-plane/` stays in `docs/` (project-specific). `continuity-plane/`
> is rewritten then moves to `.harmony/continuity/_meta/architecture/`.
> `scratchpad.md` and `projects.md` move to `.harmony/ideation/_meta/architecture/`.
> `decisions/` moves to `.harmony/cognition/decisions/`.

### `.harmony/cognition/decisions/` (EXISTS — additions)

Architecture decision records.

**From `docs/architecture/decisions/`:**

- `adr-flowkit-integration.md` — FlowKit integration model ADR

### `.harmony/agency/_meta/architecture/` (NEW)

Agency subsystem specification and design docs.

**From `docs/architecture/harness/`:**

- `agents.md` — agent model specification
- `assistants.md` — assistant model specification

**From `docs/architecture/harness/agency/` (4 files):**

- `README.md`, `architecture.md`, `specification.md`, `finalization-plan.md`

### `.harmony/capabilities/_meta/architecture/` (NEW)

Capabilities subsystem specification and design docs.

**From `docs/architecture/harness/`:**

- `commands.md` — command system specification

**From `docs/architecture/harness/skills/` (18 files):**

- All skill architecture docs: README.md, alignment-policy.md, architecture.md,
  capabilities.md, comparison.md, creation.md, declaration.md,
  design-conventions.md, discovery.md, execution.md, harness-resolution.md,
  invocation.md, migration-guide.md, reference-artifacts.md, skill-format.md,
  skill-sets.md, specification.md, validation.md

### `.harmony/orchestration/_meta/architecture/` (NEW)

Orchestration subsystem specification and design docs.

**From `docs/architecture/harness/`:**

- `missions.md` — mission system specification
- `workflows.md` — workflow system specification

**From `docs/architecture/harness/workflows/`:**

- `specification.md` — detailed workflow specification

### `.harmony/continuity/_meta/architecture/` (NEW)

Continuity subsystem specification and design docs.

**From `docs/architecture/harness/`:**

- `progress.md` — progress tracking specification

**From `docs/architecture/continuity-plane/` (rewrite-first):**

- Rewrite `README.md`, `continuity-plane.md`, and `three-planes-integration.md`
  to align with `.harmony/continuity/` (`log.md`, `tasks.json`,
  `entities.json`, `next.md`) and remove legacy `.continuity/` paths.
- Move rewritten files into `.harmony/continuity/_meta/architecture/`.

### `.harmony/ideation/_meta/architecture/` (NEW)

Ideation subsystem specification and design docs.

**From `docs/architecture/harness/`:**

- `scratchpad.md` — human-led ideation/scratchpad model
- `projects.md` — human-led ideation/projects model

### `.harmony/scaffolding/_meta/architecture/` (NEW)

Scaffolding subsystem specification and design docs.

**From `docs/architecture/harness/`:**

- `templates.md` — template system specification
- `examples.md` — examples specification
- `prompts.md` — prompts specification
- `scripts.md` — scripts specification

### `.harmony/quality/_meta/architecture/` (NEW)

Quality subsystem specification and design docs.

**From `docs/architecture/harness/`:**

- `checklists.md` — completion checklist specification

### `.harmony/cognition/principles/` (NEW)

Foundational reasoning: pillars, principles, purpose, methodology.

**Canonical file decision (consolidate first):**

- Consolidate `docs/principles.md` and `docs/principles/README.md` into one
  canonical `.harmony/cognition/principles/principles.md`.
- Preserve non-overlapping sections from both files (index + threshold defaults
  + anti-principles + alignment tables).

**From `docs/principles/` (23 guide files):**

- All individual principle guides except `README.md` (accessibility-baseline,
  contract-first,
  deny-by-default, determinism, guardrails, hitl-checkpoints, idempotency,
  locality, monolith-first-modulith, no-silent-apply, observability-as-a-contract,
  ownership-and-boundaries, progressive-disclosure, reversibility, security-and-privacy-baseline,
  simplicity-over-complexity, single-source-of-truth, small-diffs-trunk-based,
  determinism-and-provenance, documentation-is-code, flags-by-default,
  learn-continuously, roadmap)

**From `docs/pillars/` (7 files):**

- All pillar docs → `.harmony/cognition/principles/pillars/`
  - README.md, continuity.md, direction.md, focus.md, insight.md, trust.md,
    velocity.md

**From `docs/purpose/` (3 files):**

- All purpose docs → `.harmony/cognition/principles/purpose/`
  - convivial-purpose.md, resonant-computing-design-stack.md, roadmap.md

### `.harmony/cognition/methodology/` (NEW)

AI-native development methodology.

**From `docs/methodology/` (16 files + templates):**

- All methodology docs: README.md, implementation-guide.md, risk-tiers.md,
  spec-first-planning.md, flow-and-wip-policy.md, ci-cd-quality-gates.md,
  auto-tier-assignment.md, sandbox-flow.md, adoption-plan-30-60-90.md,
  tooling-and-metrics.md, performance-and-scalability.md, reliability-and-ops.md,
  security-baseline.md, methodology-as-code.md, architecture-and-repo-structure.md,
  tiny-team-assessment.md
- `templates/` subdirectory (README.md, spec-tier1.yaml, spec-tier2.yaml,
  spec-tier3.yaml)

### `.harmony/cognition/context/` (EXISTS — additions)

Shared vocabulary and reference material.

**From `docs/` root:**

- `GLOSSARY.md` → `glossary-repo.md` (keep existing `glossary.md` as harness glossary)
- `RISK-TIERS.md` → `risk-tiers.md`
- `metrics-scorecard.md`
- `COST-MANAGEMENT.md` → `cost-management.md`

### `.harmony/agency/practices/` (NEW)

How agents and humans work together.

**From `docs/practices/` (3 files):**

- `commits.md`, `pull-request-standards.md`, `README.md`

**From `docs/` root:**

- `operating-model.md` → `.harmony/agency/practices/operating-model.md`
- `DAILY-FLOW.md` → `.harmony/agency/practices/daily-flow.md`
- `START-HERE.md` → `.harmony/agency/practices/start-here.md`

### `.harmony/quality/` (EXISTS — additions)

Standards and enforcement.

**From `docs/` root:**

- `testing-strategy.md`
- `security-and-privacy.md`
- `data-handling-and-retention.md`

### `.harmony/orchestration/` (EXISTS — additions)

Operational workflows and incident response.

**From `docs/` root:**

- `INCIDENTS.md` → `incidents.md`
- `incident-response.md`

**From `docs/TASKS/` (rewrite-first to workflows):**

- Rewrite task guides into manifest-backed workflows under
  `.harmony/orchestration/workflows/tasks/`:
  - add-api-endpoint.md, add-ui-feature.md, fix-a-bug.md,
    handle-security-issue.md, onboard-new-developer.md, run-data-migration.md
- Add workflow entries to `orchestration/workflows/manifest.yml` and
  `orchestration/workflows/registry.yml` (`format: single-file`).

### `.harmony/scaffolding/patterns/` (NEW)

Reusable design patterns and guidelines.

**From `docs/` root:**

- `api-design-guidelines.md`
- `domain-modeling.md`
- `adr-policy.md`

**From `docs/documentation-standards/`:**

- `README.md` → `.harmony/scaffolding/templates/documentation-standards.md`

### `.harmony/capabilities/` (EXISTS — additions)

Capability-specific reference material.

**From `docs/` root:**

- `KITS.md` → `.harmony/capabilities/services/_meta/docs/kits-reference.md`
- `AI-GUARDRAILS.md` → `.harmony/capabilities/services/guard/guardrails-guide.md`

**From `docs/services/` (core guides only):**

- `agent-guide.md` → `.harmony/capabilities/services/_meta/docs/agent-guide.md`
- `developer-overview.md` → `.harmony/capabilities/services/_meta/docs/developer-overview.md`
- `comms-guide.md` → `.harmony/capabilities/services/_meta/docs/comms-guide.md`
- `mcp-guide.md` → `.harmony/capabilities/services/_meta/docs/mcp-guide.md`
- `appendices.md` → `.harmony/capabilities/services/_meta/docs/appendices.md`

---

## What Stays in `docs/`

**Project-specific architecture:**

- `docs/architecture/content-plane/` (13 spec files + archive) — product content
  infrastructure (flat-file content compiler, content graph). This is product
  architecture for what Harmony publishes, not harness methodology.
- `docs/architecture/a11ykit.md` — accessibility kit spec (project-specific kit)
- `docs/architecture/repo-layout-for-new-engineers.md` — onboarding guide to
  this project's monorepo layout
- `docs/architecture/runtime-architecture.md` — LangGraph product runtime
- `docs/architecture/runtime-policy.md` — product runtime policy
- `docs/architecture/nextjs-astro-vercel.md` — frontend tech stack
- `docs/architecture/containerization-profile.md` — Docker configuration
- `docs/architecture/python-runtime-workspace.md` — Python workspace
- `docs/architecture/self-contained-repos.md` — repo patterns

**Project-specific guides:**

- `docs/development/` — terminal environment, theme, tmux
- `docs/engines/` — AI engine catalog
- `docs/runtimes/` — runtime infrastructure
- `docs/agents/`, `docs/ai/`, `docs/patterns/` — stubs
- `docs/specs/` — feature specifications (shadcn-ui, speckit)
- `docs/SHIPPING.md` — Vercel-specific deployment
- `docs/glossary-and-conventions.md` — project-specific naming

**Service implementation docs (stay in `docs/services/`):**

- All subdirectories: `planning/`, `architecture/`, `authoring/`, `delivery/`,
  `governance/`, `interfaces/`, `modeling/`, `operations/`, `quality/`,
  `retrieval/`
- `docs/services/README.md` — stays as project-level service catalog

**Documentation templates (project-specific examples):**

- `docs/documentation-standards/template/` — project scaffolding examples

---

## Cross-Reference Update Strategy

Every moved file may be referenced by other files via relative paths. The
strategy:

1. **After each wave**, grep for all old paths and update references in both
   `.harmony/` and `docs/`.
2. **Leave a forwarding note** in `docs/` for any moved file that was
   previously a well-known entry point (e.g., `docs/principles.md`). The note
   is a single line: `Moved to .harmony/cognition/principles/principles.md`.
3. **Update `CLAUDE.md`** after migration to point to new locations.
4. **Update `.harmony/START.md`** to reflect new paths.
5. **Update `.harmony/scope.md`** to document the expanded harness boundary.
6. **For any migrated task workflow**, verify `orchestration/workflows/manifest.yml`
   and `orchestration/workflows/registry.yml` include matching entries.

---

## Migration Waves

### Wave 0: Normalization (Pre-Migration)

Resolve source inconsistencies before moving files.

**Required rewrites/consolidation:**

- Rewrite `docs/architecture/continuity-plane/*` to match current
  `.harmony/continuity/` contract.
- Consolidate `docs/principles.md` + `docs/principles/README.md` into one
  canonical principles document.
- Convert `docs/TASKS/*` guides into workflow-form documents with
  manifest/registry coverage.

**Moves:** 0
**Cross-ref updates:** Light (prepare-only)

#### Wave 0 Detailed Execution Checklist

**0.1 Principles consolidation**

- Merge `docs/principles.md` + `docs/principles/README.md` into one normalized
  source doc at `docs/principles.md` (temporary normalization location).
- Keep only one source of truth for principles index + threshold defaults +
  anti-principles + methodology alignment.
- Remove/replace duplicated content in `docs/principles/README.md` with a short
  forwarding note during transition.

**0.2 Continuity-plane rewrite**

- Rewrite `docs/architecture/continuity-plane/README.md`,
  `docs/architecture/continuity-plane/continuity-plane.md`, and
  `docs/architecture/continuity-plane/three-planes-integration.md` so all paths
  and contracts align with:
  - `.harmony/continuity/log.md`
  - `.harmony/continuity/tasks.json`
  - `.harmony/continuity/entities.json`
  - `.harmony/continuity/next.md`
- Remove legacy `.continuity/` storage model references.

**0.3 TASKS-to-workflows conversion**

- Convert each file in `docs/TASKS/` into a workflow-form document targeting
  `.harmony/orchestration/workflows/tasks/` with naming aligned to workflow IDs.
- Add discoverable entries for each task workflow in:
  - `.harmony/orchestration/workflows/manifest.yml`
  - `.harmony/orchestration/workflows/registry.yml`
- Use `format: single-file` entries unless split into multi-step directories.

**0.4 Pre-migration verification gate**

- `rg` sweep confirms no stale `.continuity/` references remain in rewritten
  continuity docs.
- `rg` sweep confirms principles references point to
  `.harmony/cognition/principles/principles.md`.
- Workflow discovery check confirms all converted `tasks/*` workflows resolve
  through manifest + registry.
- Forwarding-note policy defined for:
  - `docs/principles.md`
  - `docs/principles/README.md`
  - `docs/TASKS/*`

**Wave 0 Outputs**

- Normalized source docs ready for migration wave execution.
- Zero unresolved naming collisions for principles canonical file.
- No non-discoverable orchestration artifacts introduced.

### Wave 1: Cognition Layer (principles, pillars, purpose, methodology)

These are self-contained with few inbound references from other docs.

**Creates:**

- `.harmony/cognition/principles/` (23 principle guides + consolidated `principles.md`)
- `.harmony/cognition/principles/pillars/` (7 pillar files + README)
- `.harmony/cognition/principles/purpose/` (3 purpose files)
- `.harmony/cognition/methodology/` (16 methodology files + templates/)

**Moves:** ~55 files
**Cross-ref updates:** Update `docs/principles.md` references, `CLAUDE.md`,
`START.md`

### Wave 2: Architecture — Core + Cross-Cutting

Core architecture flat files and cross-cutting harness meta-docs into cognition.

**Creates:**

- `.harmony/cognition/_meta/architecture/` (20 core architecture files + 12 cross-cutting harness meta-docs)
- `.harmony/cognition/_meta/architecture/knowledge-plane/` (1 file)

**Adds to existing:**

- `.harmony/cognition/decisions/` (1 ADR)

**Moves:** ~34 files
**Cross-ref updates:** Heavy. Architecture docs reference each other extensively.
Run a full grep sweep for `docs/architecture/` paths and update.

### Wave 2b: Architecture — Subsystem Specs

Distribute harness subsystem specs to their respective subsystems.
Split from Wave 2 to isolate the heaviest cross-referencing.

**Creates:**

- `.harmony/agency/_meta/architecture/` (6 files — agents, assistants, agency spec)
- `.harmony/capabilities/_meta/architecture/` (19 files — commands, skills spec)
- `.harmony/orchestration/_meta/architecture/` (3 files — missions, workflows spec)
- `.harmony/continuity/_meta/architecture/` (4 files — progress + rewritten continuity-plane specs)
- `.harmony/ideation/_meta/architecture/` (2 files — scratchpad, projects spec)
- `.harmony/scaffolding/_meta/architecture/` (4 files — templates, examples, prompts,
  scripts spec)
- `.harmony/quality/_meta/architecture/` (1 file — checklists spec)

**Moves:** ~39 files
**Cross-ref updates:** Moderate. Update internal `harness/` cross-references to
point to new subsystem locations. Update subsystem READMEs to reference their
new `architecture/` subdirectories.

### Wave 3: Agency, Quality, Orchestration, Scaffolding

Smaller moves distributed across subsystems.

**Creates:**

- `.harmony/agency/practices/` (3 practice files)
- `.harmony/orchestration/workflows/tasks/` (6 single-file workflows + manifest entries)
- `.harmony/scaffolding/patterns/` (3 pattern files)

**Moves to existing dirs:**

- 3 files → `.harmony/agency/practices/` (operating-model, daily-flow, start-here)
- 3 files → `.harmony/quality/` (testing, security, data-handling)
- 2 files → `.harmony/orchestration/` (incidents, incident-response)
- 3 files → `.harmony/cognition/context/` (risk-tiers, metrics, cost)
- 1 file merged/additional context → `.harmony/cognition/context/glossary-repo.md`

**Moves:** ~25 files
**Cross-ref updates:** Moderate. Update `CLAUDE.md`, `START.md`, subsystem READMEs.

### Wave 4: Capabilities (service guides)

Move core service guides into the harness capabilities layer.

**Moves:**

- 5 service guides → `.harmony/capabilities/services/`
- 2 reference docs → `.harmony/capabilities/services/`

**Moves:** ~7 files
**Cross-ref updates:** Update service README, `CLAUDE.md`.

### Wave 5: Cleanup

- Update `CLAUDE.md` with final paths
- Update `.harmony/START.md` with expanded orientation
- Update `.harmony/scope.md` with new harness boundary
- Update `.harmony/cognition/README.md` with new subdirectories
- Add forwarding notes in `docs/` for moved entry points
- Verify no broken cross-references remain
- Update `.harmony/conventions.md` if naming conventions changed
- Ensure `cognition/context/index.yml` indexes new context docs (including `glossary-repo.md`)

---

## New Orientation Files Needed

Each new directory needs a `README.md` for orientation, plus one canonical
principles file:

- `.harmony/cognition/_meta/architecture/README.md`
- `.harmony/cognition/principles/principles.md` (canonical consolidated principles file)
- `.harmony/cognition/principles/pillars/README.md` (from `docs/pillars/README.md`)
- `.harmony/cognition/principles/purpose/README.md`
- `.harmony/cognition/methodology/README.md` (from `docs/methodology/README.md`)
- `.harmony/agency/_meta/architecture/README.md` (from `docs/architecture/harness/agency/README.md`)
- `.harmony/agency/practices/README.md` (from `docs/practices/README.md`)
- `.harmony/capabilities/_meta/architecture/README.md`
- `.harmony/orchestration/_meta/architecture/README.md`
- `.harmony/continuity/_meta/architecture/README.md`
- `.harmony/ideation/_meta/architecture/README.md`
- `.harmony/scaffolding/_meta/architecture/README.md`
- `.harmony/quality/_meta/architecture/README.md`
- `.harmony/orchestration/workflows/tasks/README.md`
- `.harmony/scaffolding/patterns/README.md`

---

## Verification

After each wave:

1. No broken relative links within `.harmony/`
2. No broken references from `docs/` to moved files (forwarding notes in place)
3. `CLAUDE.md` points to correct locations
4. `.harmony/START.md` orientation is accurate
5. Subsystem READMEs reflect new contents
6. `git status` shows clean moves (use `git mv` for history preservation)
7. All migrated task workflows are discoverable via
   `orchestration/workflows/manifest.yml` and `orchestration/workflows/registry.yml`

After all waves:

8. `.harmony/` is fully self-contained for harness operation
9. `docs/` contains only project-specific content
10. Copying `.harmony/` to another repo includes all governance, principles,
   methodology, architecture, practices, and quality standards
11. Agent can boot from `CLAUDE.md` → `.harmony/START.md` and find everything
    it needs without reaching into `docs/`

---

## Risk Notes

- **Waves 2/2b are the largest and most cross-reference-heavy.** The split
  into 2 (core + cross-cutting) and 2b (subsystem specs) helps isolate
  concerns, but both waves need grep sweeps for path updates.
- **Normalization is mandatory before moves.** `continuity-plane` docs and
  `docs/TASKS/*` need rewrite/conversion before migration to avoid importing
  stale architecture and non-discoverable artifacts.
- **`docs/architecture/harness/` is 48 files totaling ~200KB** distributed
  across 8 subsystem `architecture/` dirs. This increases `.harmony/` size
  but keeps specs co-located with the subsystems they describe. Internal
  `harness/` cross-references must be rewritten to span subsystem boundaries.
- **Some `docs/methodology/` files are very large** (README.md 56K,
  implementation-guide.md 55K). Consider whether these need trimming
  before migration.
- **Forwarding notes in `docs/`** prevent broken bookmarks but add
  maintenance surface. Remove them after a settling period.

---

## Estimated Scope

| Wave      | Files moved | New directories | Cross-ref updates |
|-----------|-------------|-----------------|-------------------|
| 0         | 0           | 0               | Light (prep)      |
| 1         | ~55         | 4               | Light             |
| 2         | ~34         | 3               | Heavy             |
| 2b        | ~39         | 7               | Moderate          |
| 3         | ~25         | 3               | Moderate          |
| 4         | ~7          | 0               | Light             |
| 5         | 0           | 0               | Final sweep       |
| **Total** | **~160**    | **17**          |                   |
