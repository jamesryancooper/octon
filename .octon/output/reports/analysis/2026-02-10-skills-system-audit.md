# Skills System Architectural Audit

Date: 2026-02-10

Selected Context: archetype=library/SDK/CLI/tooling (primary), platform/infra (secondary); testing=§8.3; operations=§9.2; risk_tier=B; mode=full-documentation.

## Scope and Method

- Audited artifacts:
  - `.octon/capabilities/skills/manifest.yml`
  - `.octon/capabilities/skills/capabilities.yml`
  - `.octon/capabilities/skills/registry.yml`
  - All `SKILL.md` files under `.octon/capabilities/skills/` (34 files)
  - `.octon/capabilities/skills/_template/`
  - `docs/architecture/harness/skills/README.md`
  - All files under `docs/architecture/harness/skills/`
- External baseline references:
  - [agentskills.io/specification](https://agentskills.io/specification)
  - [agentskills.io/what-are-skills](https://agentskills.io/what-are-skills)
  - [agentskills.io/integrate-skills](https://agentskills.io/integrate-skills)
- Validation approach:
  - Programmatic cross-file consistency checks for manifest/capabilities/registry/SKILL.md joins.
  - Per-skill compliance matrix generation (pass/warn/fail per criterion).
  - Documentation-to-implementation drift checks with line-level evidence.

## Executive Summary

- The core three-layer model (manifest + capabilities + registry) is structurally strong, but consistency is currently broken in key places: `skill_group_definitions.members` does not match manifest membership for `foundations` and `platforms`.
- Spec-compliance is mixed: 22/34 `SKILL.md` files pass frontmatter validity, but 12 fail (mostly name-to-parent-directory mismatch, plus invalid template/archive frontmatter placeholders).
- Capability-to-reference contracts are not being met in practice: all 15 manifested skills are missing at least one reference file required by resolved capabilities (29 missing references total).
- Documentation is materially out of sync with implementation in multiple files (schema version examples, old path examples, `skill_mappings` key usage, and contradictory registry guidance).
- Extensibility is adequate for current code-review/refactor/synthesis flows, but partial for many future archetypes (monitoring, multimodal, adaptive, long-running async, conversation-centric skills) without schema extensions.

## Phase 1: Spec Compliance (agentskills.io Baseline)

### Baseline Rules Applied

From the agentskills.io pages above:

- `SKILL.md` frontmatter requires `name` and `description`.
- `name` constraints: 1-64 chars, lowercase letters/numbers/hyphens, no leading/trailing/consecutive hyphens, should match directory name.
- Keep `SKILL.md` concise (progressive disclosure; heavy detail in referenced files).
- File references should be relative and one level deep under `references/`, `scripts/`, or `assets/`.
- Descriptions should explain both what the skill does and when to use it.

### Findings by Criterion

1. Frontmatter validity:

- Overall: `pass=22`, `fail=12` across 34 `SKILL.md` files.
- Manifested skills only: `pass=10`, `fail=5`.
- High-signal failures (manifested skills):
  - `foundations/postgres/best-practices/SKILL.md`
  - `foundations/react/best-practices/SKILL.md`
  - `foundations/react/composition-patterns/SKILL.md`
  - `foundations/react-native/best-practices/SKILL.md`
  - `platforms/vercel/deploy/SKILL.md`
- Root cause: `name` matches manifest `id`, but not immediate parent directory (spec expectation is parent-directory alignment).

2. Description quality:

- Overall: `pass=18`, `warn=14`, `fail=2`.
- Fails are template/archive placeholder files lacking concrete descriptions.
- Warnings are primarily missing explicit “when to use” phrasing in frontmatter description text (the body often includes usage guidance).

3. Optional field correctness (`license`, `compatibility`, `metadata`, `allowed-tools`):

- Overall: `pass=22`, `warn=12`, `fail=0`.
- Warnings: 12 files use comma-delimited `allowed-tools` strings (e.g., `Read, Grep, Glob, ...`) while Octon docs define space-delimited format (`docs/architecture/harness/skills/skill-format.md:90`) and validator parser tokenizes on spaces (`.octon/capabilities/skills/scripts/validate-skills.sh:337-339`).

4. Progressive disclosure (`SKILL.md` under 500 lines):

- Overall: `pass=34`, `fail=0`.
- Longest file remains under threshold.

5. Directory/reference structure:

- Overall: `pass=33`, `fail=1`.
- Failure: `archive/v1-archetype-model/SKILL.md` references `references/...` files that do not exist in that directory; archive content uses `template-references/` instead.

### Compliance Summary

- Active runtime catalog is mostly compliant except for directory/name mismatch in 5 manifested skills.
- Non-runtime template/archive files introduce strict-spec failures that can confuse automated validators unless explicitly excluded from compliance scans.

## Phase 2: Internal Consistency Audit

### 1) ID Alignment (manifest ↔ registry ↔ SKILL.md)

Status: **pass (manifested skills)**

- All 15 manifest skills exist in registry and have SKILL files.
- All 15 manifested SKILL frontmatter `name` values match manifest `id` exactly.

Status: **warn (global filesystem view)**

- There are 19 additional `SKILL.md` files not represented in manifest (mostly foundation subskills and template/archive artifacts).
- This is either intentional non-routable content or an incomplete catalog boundary; it should be explicit in policy.

### 2) Summary/Description Alignment

Status: **warn**

- Most skills align.
- 6 skills show weak lexical alignment between manifest `summary` and first sentence of SKILL `description` (notably `refine-prompt`, `audit-migration`, `react-best-practices`, `react-composition-patterns`, `react-native-best-practices`, `postgres-best-practices`).
- This is primarily wording drift, not a hard semantic conflict.

### 3) Capability Validity

Status: **pass**

- All manifest `capabilities` are present in `valid_capabilities`.
- No invalid capability tokens found.

### 4) Skill Set Resolution

Status: **mixed**

- Syntax validity: pass (all declared `skill_sets` resolve in `skill_set_definitions`).
- Reference fulfillment: fail in practice (see next check).

### 5) Group Membership Consistency

Status: **fail**
Evidence:

- `capabilities.yml` defines `foundations` members as foundation wrapper IDs (`python-api-foundation`, etc.) and `platforms` member `vercel-foundation` (`.octon/capabilities/skills/capabilities.yml:80-88`).
- Manifest uses operational skills like `react-best-practices`, `react-composition-patterns`, `react-native-best-practices`, `postgres-best-practices`, `vercel-deploy` (`.octon/capabilities/skills/manifest.yml:160-307`).
- Result: 5 manifest skills are not in their declared group members; 6 group members do not exist in manifest.

### 6) Reference File Completeness (`capability_refs`)

Status: **fail**

- For resolved capabilities, required reference files are missing in all 15 manifested skills.
- Missing references: 29 total.
- Common missing files: `decisions.md`, `checkpoints.md`, and domain `glossary.md` depending on capability bundles.
- This breaks the stated capability→reference contract in `capabilities.yml` (`.octon/capabilities/skills/capabilities.yml:130-147`).

### 7) Registry Completeness and Schema Health

Status: **pass with tooling drift risk**

- Every manifest skill has a registry entry.
- Parameter types are valid (`text|boolean|file|folder`) and I/O entries are structurally well-formed.
- Drift risk: `validate-skills.sh` currently assumes flat `SKILLS_DIR/$skill_id` directories and fails immediately against grouped paths (e.g., `synthesis/...`) (`.octon/capabilities/skills/scripts/validate-skills.sh:1085-1089`, `.octon/capabilities/skills/scripts/validate-skills.sh:1147`).

### 8) Documentation Accuracy vs Implementation

Status: **fail (material drift)**
Key mismatches:

- Outdated internal paths:
  - `README.md` points to `.octon/capabilities/skills/refactor/` and `.octon/capabilities/skills/refine-prompt/`, but real paths are grouped (`quality-gate/refactor/`, `synthesis/refine-prompt/`) (`docs/architecture/harness/skills/README.md:156-157`).
  - `creation.md` references `.octon/capabilities/skills/create-skill/` instead of `meta/create-skill/` (`docs/architecture/harness/skills/creation.md:18`).
- Schema/version drift:
  - Discovery examples still show `schema_version: "1.2"` for manifest/registry, but implementation is `2.0` and `3.0` (`docs/architecture/harness/skills/discovery.md:30`, `docs/architecture/harness/skills/discovery.md:158`; actual in manifest/registry headers).
- Key-name drift:
  - Multiple docs sections use `skill_mappings:` while current registry schema nests I/O under `skills.<id>.io` (`docs/architecture/harness/skills/discovery.md:238`, `docs/architecture/harness/skills/creation.md:266`, `docs/architecture/harness/skills/architecture.md:266`).
- Contradictory compliance guidance:
  - `specification.md` checklist says both “No outputs in registry.yml” and “I/O mappings exist in registry.yml” (`docs/architecture/harness/skills/specification.md:331-332`), while registry clearly stores outputs.
- Missing field coverage:
  - Manifest includes `group`, but discovery manifest field table omits this field (`docs/architecture/harness/skills/discovery.md:83-94`).

## Phase 3: Extensibility and Flexibility Evaluation

### 3a) Capability Taxonomy Completeness

Assessment scale: `full` = expressible without schema changes; `partial` = possible but lossy; `gap` = requires new concepts.

| Archetype | Current Fit | Why | Missing Capability Vocabulary |
|---|---|---|---|
| Data transformation (ETL/cleaning/conversion) | partial | `executor`, `contract-driven`, `idempotent` help | `data-transforming`, `schema-evolving`, `lineage-aware`, `batch-windowed` |
| Generative/creative | partial | `specialist` + `human-collaborative` covers review loops | `generative`, `style-conditioned`, `variant-producing` |
| Monitoring/observability | partial | `external-dependent`, `task-coordinating`, `stateful` partially fit | `event-driven`, `alerting`, `threshold-based`, `scheduled` |
| Authentication/security | partial | `safety-bounded`, `self-validating` cover guardrails | `secret-handling`, `privileged-operation`, `security-scanning`, `compliance-reporting` |
| Testing (gen/coverage/mutation) | partial | `self-validating` and `executor` are useful | `test-generating`, `coverage-aware`, `mutation-testing` |
| Documentation (API/changelog/diagrams) | full/partial | `specialist` generally sufficient for static docs | `diagram-generating` helpful but not mandatory |
| Communication (Slack/email/routing) | partial | `human-collaborative` + `external-dependent` works for simple cases | `notification-routing`, `approval-gated-send`, `channel-aware` |
| Learning/adaptive | gap | No explicit memory/feedback capability | `adaptive`, `feedback-learning`, `memory-backed` |
| Multi-modal (image/audio/video) | gap | No modality semantics in capabilities | `multimodal-input`, `multimodal-output`, `media-transforming` |
| Long-running/async (hours/days) | partial | `stateful` + `resumable` helps | `long-running`, `polling`, `timer-driven` |
| Conversational (multi-turn dialogue) | partial | `human-collaborative` approximates checkpoints | `dialogue-managed`, `context-window-managed` |

### 3b) Structural Flexibility

1. Single `SKILL.md` model:

- Good for concise skills.
- Limitation: no first-class support for multi-entrypoint or variant skill definitions.

2. Flat additive capability model:

- Simple and understandable.
- Limitation: cannot express conditional/negative capabilities without manual re-declaration.

3. Skill set granularity (7 sets):

- Strong base for present system.
- `specialist` is overloaded; missing explicit sets for observer/notifier/generator patterns.

4. I/O contract model:

- Strong for file/directory artifacts with determinism tags.
- Limitation: no native external sink types (API, DB), streaming outputs, or variant output contracts.

5. Parameter types (`text|boolean|file|folder`):

- Adequate for minimal CLI-style inputs.
- Limitation: lacks number, enum, list, object, and secret parameter primitives.

6. Trigger matching:

- Natural-language triggers are user-friendly.
- Limitation: precision decreases as catalog grows; lacks structured intent patterns and confidence weighting.

7. Dependency model (`depends_on`):

- Present but underused.
- Limitation: no optional dependencies, no version constraints, no cycle policy.

8. Lifecycle states:

- `active|deprecated|experimental` is a good start.
- Missing practical states: `draft`, `disabled`, `archived`, `version-locked`.

### 3c) Scaling Concerns

1. Manifest token budget:

- At ~50 tokens/entry, expected growth:
  - 50 skills: ~2.5k tokens
  - 100 skills: ~5k tokens
  - 500 skills: ~25k tokens
- Current single manifest approach will become expensive/noisy at large N without sharding or two-pass indexing.

2. Config proliferation:

- Per-skill directories (`configs/resources/runs/logs`) are workable at current scale.
- At 100+ skills, discoverability and maintenance will degrade unless generated defaults/inheritance reduce boilerplate.

3. Cross-skill composition:

- Current pipeline model is linear/minimal (single example in registry).
- Complex workflow needs (branching, retries, conditional paths, fan-out/fan-in) are not yet represented.

## Phase 4: Recommendations

### 1) Critical Fixes (Immediate)

1. Resolve manifest/group mismatch in `capabilities.yml` group members for `foundations` and `platforms`.
2. Decide and enforce one naming invariant for nested skills:
   - Option A: directory name must equal skill id (spec-strict).
   - Option B: maintain grouped directories but document and validate an adapted rule.
3. Reconcile capability-to-reference contract:
   - Either add missing refs per resolved capability, or explicitly downgrade those mappings from required to advisory.
4. Fix `validate-skills.sh` path assumptions so grouped skill paths validate correctly.
5. Remove documentation contradictions around registry outputs and `skill_mappings` vs `skills.<id>.io`.

### 2) Capability Gaps to Add (Targeted)

Proposed additions (minimal high-impact set):

- Execution/ops: `scheduled`, `polling`, `long-running`.
- Integration: `external-output` (API/DB sinks), `streaming-output`.
- Security: `secret-handling`, `security-scanning`.
- Learning: `adaptive`, `feedback-aware`.
- Modalities: `multimodal-input`, `multimodal-output`.

### 3) Structural Improvements (Without Over-Engineering)

- Keep current three-file architecture; add incremental schema upgrades:
  - Parameter types: add `number`, `enum`, `list`, `object`, `secret`.
  - I/O kinds: extend beyond `file|directory` with `api`, `database`, `stream`.
  - Triggers: add optional `patterns` block (regex/intent keys) while retaining natural-language triggers.
  - Dependencies: add optional `optional`, `version_constraint`, and cycle detection policy.
- Add machine-checkable policy for “non-routable SKILL files” (template/archive/foundation subskills) so compliance tooling can include/exclude deterministically.

### 4) Documentation Gaps to Update

- Update path examples to grouped layout across README/creation/discovery.
- Replace `skill_mappings` docs with current `skills.<id>.io` schema.
- Update schema version examples to current values.
- Document `group` field in discovery schema tables.
- Remove contradictory checklist item in specification regarding outputs in registry.

### 5) Things to Leave Alone

- Three-layer progressive-disclosure model (`manifest.yml` → `capabilities.yml` → `registry.yml`) is well-structured and should remain.
- Current 17-capability base taxonomy is coherent and useful for present workflows.
- Determinism annotations (`stable|variable|unique`) in registry I/O are valuable and should be preserved.
- `allowed-tools` as SKILL frontmatter source of truth is the right direction; only normalization/validator alignment is needed.
- `<500` line discipline for `SKILL.md` plus external reference files is a good maintainability constraint.

## Appendix A: Per-Skill Compliance Matrix

| Skill | Frontmatter | Description | Optional Fields | Progressive Disclosure | Directory Structure | Notes |
|---|---|---|---|---|---|---|
| `_template/SKILL.md` | fail | fail | pass | pass | pass | description_missing_or_length_invalid; frontmatter_parse_error; missing_description; missing_name |
| `archive/v1-archetype-model/SKILL.md` | fail | fail | pass | pass | fail | description_missing_or_length_invalid; frontmatter_parse_error; missing_description; missing_name; missing_referenced_files |
| `foundations/postgres/best-practices/SKILL.md` | fail | pass | pass | pass | pass | name_parent_mismatch |
| `foundations/python-api/SKILL.md` | fail | warn | pass | pass | pass | description_missing_when_to_use_cue; name_parent_mismatch |
| `foundations/python-api/contract-first-api/SKILL.md` | pass | pass | warn | pass | pass | allowed_tools_not_space_delimited |
| `foundations/python-api/contributor-guide/SKILL.md` | pass | pass | warn | pass | pass | allowed_tools_not_space_delimited |
| `foundations/python-api/dev-toolchain/SKILL.md` | pass | pass | warn | pass | pass | allowed_tools_not_space_delimited |
| `foundations/python-api/infra-manifest/SKILL.md` | pass | pass | warn | pass | pass | allowed_tools_not_space_delimited |
| `foundations/python-api/scaffold-package/SKILL.md` | pass | pass | warn | pass | pass | allowed_tools_not_space_delimited |
| `foundations/python-api/test-harness/SKILL.md` | pass | pass | warn | pass | pass | allowed_tools_not_space_delimited |
| `foundations/react/SKILL.md` | fail | pass | pass | pass | pass | name_parent_mismatch |
| `foundations/react/best-practices/SKILL.md` | fail | pass | pass | pass | pass | name_parent_mismatch |
| `foundations/react/composition-patterns/SKILL.md` | fail | pass | pass | pass | pass | name_parent_mismatch |
| `foundations/react-native/SKILL.md` | fail | pass | pass | pass | pass | name_parent_mismatch |
| `foundations/react-native/best-practices/SKILL.md` | fail | pass | pass | pass | pass | name_parent_mismatch |
| `foundations/swift-macos-app/SKILL.md` | fail | warn | pass | pass | pass | description_missing_when_to_use_cue; name_parent_mismatch |
| `foundations/swift-macos-app/cli-interface/SKILL.md` | pass | pass | warn | pass | pass | allowed_tools_not_space_delimited |
| `foundations/swift-macos-app/contributor-guide/SKILL.md` | pass | warn | warn | pass | pass | allowed_tools_not_space_delimited; description_keyword_match_weak |
| `foundations/swift-macos-app/daemon-service/SKILL.md` | pass | pass | warn | pass | pass | allowed_tools_not_space_delimited |
| `foundations/swift-macos-app/data-layer/SKILL.md` | pass | pass | warn | pass | pass | allowed_tools_not_space_delimited |
| `foundations/swift-macos-app/scaffold-package/SKILL.md` | pass | pass | warn | pass | pass | allowed_tools_not_space_delimited |
| `foundations/swift-macos-app/test-harness/SKILL.md` | pass | pass | warn | pass | pass | allowed_tools_not_space_delimited |
| `meta/build-mcp-server/SKILL.md` | pass | warn | pass | pass | pass | description_missing_when_to_use_cue |
| `meta/create-skill/SKILL.md` | pass | warn | pass | pass | pass | description_missing_when_to_use_cue |
| `platforms/vercel/SKILL.md` | fail | warn | pass | pass | pass | description_missing_when_to_use_cue; name_parent_mismatch |
| `platforms/vercel/deploy/SKILL.md` | fail | warn | pass | pass | pass | description_missing_when_to_use_cue; name_parent_mismatch |
| `quality-gate/audit-migration/SKILL.md` | pass | warn | pass | pass | pass | description_missing_when_to_use_cue |
| `quality-gate/audit-ui/SKILL.md` | pass | warn | pass | pass | pass | description_missing_when_to_use_cue |
| `quality-gate/refactor/SKILL.md` | pass | warn | pass | pass | pass | description_missing_when_to_use_cue |
| `quality-gate/resolve-pr-comments/SKILL.md` | pass | warn | pass | pass | pass | description_missing_when_to_use_cue |
| `quality-gate/triage-ci-failure/SKILL.md` | pass | warn | pass | pass | pass | description_missing_when_to_use_cue |
| `synthesis/refine-prompt/SKILL.md` | pass | warn | pass | pass | pass | description_missing_when_to_use_cue |
| `synthesis/spec-to-implementation/SKILL.md` | pass | warn | pass | pass | pass | description_missing_when_to_use_cue |
| `synthesis/synthesize-research/SKILL.md` | pass | pass | pass | pass | pass |  |

## Appendix B: Capability Gap Analysis Table

| Archetype | Expressible Today | Blocking Gaps | Suggested Additions |
|---|---|---|---|
| Data transformation | Partial | No first-class lineage/schema-evolution semantics | `data-transforming`, `schema-evolving`, `lineage-aware` |
| Generative/creative | Partial | No explicit variant/style generation capability | `generative`, `style-conditioned`, `variant-producing` |
| Monitoring/observability | Partial | No event/schedule/alert semantics | `event-driven`, `scheduled`, `alerting` |
| Authentication/security | Partial | No secret lifecycle or security scan semantics | `secret-handling`, `security-scanning` |
| Testing | Partial | No capability for coverage/mutation-specific workflows | `coverage-aware`, `mutation-testing`, `test-generating` |
| Documentation | Mostly yes | Diagram generation and format targeting are implicit only | `diagram-generating` (optional) |
| Communication | Partial | No explicit outbound comms routing/approval model | `notification-routing`, `approval-gated-send` |
| Learning/adaptive | No | No memory/feedback capability class | `adaptive`, `feedback-aware` |
| Multi-modal | No | No media modality vocabulary | `multimodal-input`, `multimodal-output` |
| Long-running/async | Partial | No polling/timer semantics | `long-running`, `polling`, `timer-driven` |
| Conversational | Partial | Multi-turn dialogue state not explicit | `dialogue-managed`, `context-window-managed` |
