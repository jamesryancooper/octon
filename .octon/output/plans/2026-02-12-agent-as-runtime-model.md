# Plan: Document and Codify the Agent-as-Runtime Model

## Context

Through a design conversation, we established that the Octon harness
(`.octon/`) should adopt the **agent-as-runtime model**: the harness ships as
pure declarative content (YAML, JSON Schema, Markdown) with zero project-local
executables and zero project-local runtime dependencies. The AI agent itself is
the runtime — it reads contracts, interprets rules, runs fixtures for
calibration, and enforces
governance. Teams can optionally ask the agent to generate native implementations
from contracts when determinism is needed.

Dependency boundary for this model:

- **In scope (must ship in repo):** contracts, schemas, rules, fixtures,
  conventions, and documentation
- **Out of scope (host-provided prerequisites):** agent runtime, model access,
  and minimal tool adapter (`read`, `glob`, `grep`, `bash`)

This plan creates the documentation and convention files that codify this model.

---

## What Changes

### Phase 1: Architecture Documents (2 new files)

**1. `docs/architecture/agent-as-runtime.md`** (~12-15 KB)

The core normative document. Covers:

- The model: harness = pure content, agent = runtime
- What ships: the content standard (manifests, schemas, rules, fixtures, conventions — no scripts, no binaries)
- Dependency boundary: no project-local runtime vs host-provided prerequisites
- The interpretation loop: agent reads contract → runs fixtures to calibrate → applies rules to real content
- Contract anatomy: schemas + rules + fixtures + behavioral invariants + error semantics
- Relationship to the platform runtime (harness runtime vs product runtime — distinct concerns)
- Tiered validation: structural (thin tools, no agent) vs semantic (agent-interpreted)
- Implementation generation: from contract to native code, contract as source of truth
- Agent compatibility: lowest-common-denominator tool interface + capability profile

Cross-references: `agent-architecture.md`, `runtime-architecture.md`, `runtime-policy.md`, `governance-model.md`

**2. `docs/architecture/agent-runtime-caveats.md`** (~10-12 KB)

All eight caveats with problem/impact/mitigation/residual-risk structure:

1. Non-determinism → fixtures as acceptance tests
2. No semantic CI without agent availability → deterministic Tier 1 + semantic Tier 2
3. Speed → content-hash caching
4. Cost → run only when it matters
5. Auditability → run records with evidence
6. Offline operation → graceful degradation
7. Agent compatibility variance → capability profile + conformance fixtures
8. Reproducibility variance → rule versioning + pinned generation metadata

Includes a risk summary table and residual risk matrix.

Cross-references: `agent-as-runtime.md`, `governance-model.md`, `conventions/run-records.md`

---

### Phase 2: Service Conventions (5 new files)

All in `.octon/capabilities/services/conventions/`. Follow existing convention
pattern: YAML frontmatter (`title`, `scope`, `applies_to`), terse, single-concern.

**3. `conventions/rich-contracts.md`** (~4-6 KB)

What makes a contract rich enough for agent interpretation AND native generation:

- Completeness criteria (schemas, rules, fixtures, invariants, error semantics)
- Required vs optional components
- Contract versioning
- Compatibility profile (required tool surface + optional capabilities)
- Conformance fixture pack requirements for cross-agent validation
- Relationship to implementation (contract is authoritative, implementation is derived)

**4. `conventions/declarative-rules.md`** (~3-5 KB)

Rule format that replaces shell script logic:

- YAML rule structure (id, description, condition, target, severity, action)
- Rule categories: structural, semantic, policy
- Evaluation semantics (fail-closed default, deterministic ordering)
- Caching via content-hash keys

**5. `conventions/fixtures.md`** (~2-4 KB)

Fixture format for calibration and acceptance testing:

- Directory layout: `fixtures/` within each service
- Naming: `{case-name}.fixture.json`
- Schema: `input`, `expected_output`, `metadata`
- Positive/negative/edge-case requirements
- How agents use fixtures for behavioral anchoring

**6. `conventions/validation-tiers.md`** (~3-4 KB)

The two-tier validation model:

- Tier 1: structural (JSON Schema validation, file existence — no agent needed)
- Tier 1 validator contract (deterministic):
  - Inputs: `repo_root`, `service_path`, `contract_version`
  - Outputs: `status`, `validator_version`, `contract_hash`, `check_results[]`, `errors[]`
  - Exit codes: `0=pass`, `1=validation-fail`, `2=invalid-contract`, `3=tool-error`
  - Constraints: no network, no model calls, deterministic file-order traversal
- Tier 2: semantic (agent interprets declarative rules, calibrated by fixtures)
- When each tier runs:
  - Tier 1 on every PR and local pre-commit
  - Tier 2 on protected branches, release gates, and on-demand
- Caching and run record integration
- Offline behavior (Tier 1 available, Tier 2 degrades gracefully)

**7. `conventions/implementation-generation.md`** (~3-5 KB)

Workflow for generating native implementations:

- Source of truth invariant (contract authoritative, implementation derived)
- 5-step workflow: completeness check → generate → fixture validation → iterate → accept
- Regeneration triggers (schema change, rule change, fixture addition)
- Placement convention (`impl/` directory, generated file markers)
- Required reproducibility manifest (`impl/generated.manifest.json`) fields:
  - `contract_version`
  - `contract_hash`
  - `fixture_set_hash`
  - `rule_set_hash`
  - `agent_id`
  - `agent_version`
  - `model_id`
  - `prompt_hash`
  - `tool_surface_version`
  - `generated_at` (UTC timestamp)

---

### Phase 3: Updates to Existing Files (5 edits)

**8. `.octon/capabilities/services/capabilities.yml`**

Add new convention references to `base_conventions`:

- `rich_contracts`, `declarative_rules`, `fixtures`, `validation_tiers`, `implementation_generation`

**9. `.octon/capabilities/services/_scaffold/template/SERVICE.md`**

Extend frontmatter with new fields:

- `rules: rules/` (declarative rule directory)
- `fixtures: fixtures/` (fixture directory)
- `compatibility_profile: compatibility.yml` (minimum/optional agent capabilities)
- Remove hardcoded `impl.entrypoint` shell assumption — make it optional with a note that implementation is derived from contract
- Add generated implementation metadata pointer:
  - `generation_manifest: impl/generated.manifest.json`

**10. `.octon/capabilities/services/README.md`**

Add new convention files to the Contents table. Update Interface Types to note
that `shell` implementations are optionally generated from contracts, not required.
Add a dependency-boundary note (project-local vs host-provided prerequisites).

**11. `docs/architecture/agent-architecture.md`**

Add a brief section (~1 KB) positioning the agent-as-runtime model as a
complementary paradigm for harness interpretation. Cross-reference to
`agent-as-runtime.md`.

**12. `docs/principles.md`**

Add threshold in "Concrete Threshold Defaults":

- Contract drift: generated implementations must pass all fixture cases to be considered valid
- Validation cache TTL: content-hash based, invalidated on file change
- Tier 1 validator contract compliance: required fields + exit-code semantics
- Reproducibility minimum: generated manifests must include pinned metadata fields

---

## Creation Order

```text
Phase 1 (no dependencies):
  1. docs/architecture/agent-as-runtime.md
  2. docs/architecture/agent-runtime-caveats.md

Phase 2 (references Phase 1 for context):
  3. conventions/rich-contracts.md          ← can parallelize 3-5
  4. conventions/declarative-rules.md       ← can parallelize 3-5
  5. conventions/fixtures.md                ← can parallelize 3-5
  6. conventions/validation-tiers.md        ← references 3, 4, 5
  7. conventions/implementation-generation.md ← references 3, 5

Phase 3 (references Phases 1-2):
  8-12. Updates to existing files           ← can parallelize all 5
```

---

## Critical Files to Read During Implementation

- `.octon/capabilities/services/conventions/run-records.md` — pattern for convention format
- `.octon/capabilities/services/conventions/error-codes.md` — pattern for convention format
- `.octon/capabilities/services/_scaffold/template/SERVICE.md` — template to update
- `.octon/capabilities/services/capabilities.yml` — registry to update
- `.octon/capabilities/services/README.md` — contents table to update
- `docs/architecture/agent-architecture.md` — existing agent model to extend
- `docs/principles.md` — thresholds section to extend

---

## Verification

After all files are created:

1. All new docs follow YAML frontmatter pattern matching existing conventions
2. All cross-references between documents are valid paths
3. `capabilities.yml` lists all new convention files
4. `_scaffold/template/SERVICE.md` includes rules, fixtures, compatibility profile, and generation manifest fields
5. Services README reflects new conventions in contents table and dependency-boundary language
6. `validation-tiers.md` defines Tier 1 deterministic validator inputs/outputs/exit codes
7. `implementation-generation.md` defines required pinned metadata fields in generated manifests
8. No orphan references — every new doc is referenced from at least one existing doc

---

## Implementation Status (Synced 2026-02-12)

### Phase 1

- [x] `docs/architecture/agent-as-runtime.md`
- [x] `docs/architecture/agent-runtime-caveats.md`

### Phase 2

- [x] `.octon/capabilities/services/conventions/rich-contracts.md`
- [x] `.octon/capabilities/services/conventions/declarative-rules.md`
- [x] `.octon/capabilities/services/conventions/fixtures.md`
- [x] `.octon/capabilities/services/conventions/validation-tiers.md`
- [x] `.octon/capabilities/services/conventions/implementation-generation.md`

### Phase 3

- [x] `.octon/capabilities/services/capabilities.yml`
- [x] `.octon/capabilities/services/_scaffold/template/SERVICE.md`
- [x] `.octon/capabilities/services/README.md`
- [x] `docs/architecture/agent-architecture.md`
- [x] `docs/principles.md`

### Verification Status

- [x] New convention/architecture docs include YAML frontmatter
- [x] Cross-references validated for newly introduced files
- [x] `capabilities.yml` includes all new convention references
- [x] `SERVICE.md` template includes rules/fixtures/compatibility/generation fields
- [x] Services README includes new conventions and dependency-boundary note
- [x] `validation-tiers.md` defines Tier 1 validator contract and exit codes
- [x] `implementation-generation.md` defines required pinned provenance fields
- [x] Services validator enforces presence of all convention docs
