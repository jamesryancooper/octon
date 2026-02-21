---
title: Decisions
description: Agent-readable summary of key decisions affecting this harness.
mutability: append-only
---

# Decisions

Key decisions that constrain or guide work in this harness. For full rationale, see `.harmony/cognition/decisions/`.

**ADRs:**
- [ADR-001](../decisions/001-harmony-shared-foundation.md) — Shared `.harmony/` foundation (D007)
- [ADR-002](../decisions/002-consolidated-scratchpad-zone.md) — Consolidated `ideation/scratchpad/` zone (D003, D005, D008, D009)
- [ADR-003](../decisions/003-projects-elevation-and-funnel.md) — Projects elevation and idea funnel (D010, D011, D012)
- [ADR-004](../decisions/004-refactor-workflow.md) — Refactor workflow and universal commands (D013, D014, D015, D016)
- [ADR-005](../decisions/005-workflow-meta-architecture.md) — Workflow meta-architecture and gap remediation (D017, D018, D019, D020)
- [ADR-006](../decisions/006-prompt-refiner-skill.md) — Prompt refiner skill with 10-phase pipeline (D021, D022, D023, D024)
- [ADR-007](../decisions/007-primitives-documentation.md) — Central primitives documentation (D025, D026)
- [ADR-008](../decisions/008-skills-architecture-refactor.md) — Skills architecture refactor and agentskills.io alignment (D027, D028, D029, D030, D031, D032)
- [ADR-009](../decisions/009-manifest-discovery-and-validation.md) — Manifest-based discovery and validation tooling (D033, D034, D035, D036, D037, D038, D039)
- [ADR-011](../decisions/011-agency-subsystem-finalization.md) — Agency subsystem finalization and actor taxonomy consolidation (D043)
- [ADR-021](../decisions/021-bounded-surfaces-contract-and-agency-migration.md) — Bounded surfaces contract and agency clean-break migration (D045)
- [ADR-022](../decisions/022-orchestration-bounded-surfaces-clean-break-migration.md) — Orchestration bounded surfaces clean-break migration (D046)
- [ADR-023](../decisions/023-capabilities-bounded-surfaces-clean-break-migration.md) — Capabilities bounded surfaces clean-break migration (D047)
- [ADR-024](../decisions/024-assurance-bounded-surfaces-clean-break-migration.md) — Assurance bounded surfaces clean-break migration (D048)
- [ADR-026](../decisions/026-engine-bounded-surfaces-clean-break-migration.md) — Engine bounded surfaces clean-break migration
- [ADR-027](../decisions/027-cognition-bounded-surfaces-clean-break-migration.md) — Cognition bounded surfaces clean-break migration (D049)

## Active Decisions

| ID | Decision | Choice | Constraint | Date |
|----|----------|--------|------------|------|
| D001 | State format | JSON over YAML | Must parse without external dependencies | 2025-12-10 |
| D002 | Token budget | ~2,000 target, ~5,000 max | Leave context window for actual work | 2025-12-10 |
| D003 | Human-led zones | `ideation/scratchpad/` and `ideation/projects/` directories | Human-led content in designated zones; agents MUST NOT access autonomously | 2026-01-14 |
| D004 | Boot sequence | 7-step process | Ensures consistent orientation | 2025-12-18 |
| D005 | Human-led collaboration | `ideation/scratchpad/` and `ideation/projects/` | Human-led collaboration allowed when explicitly directed; autonomous access forbidden | 2026-01-14 |
| D007 | Shared foundation | Single .harmony/ root organized by capability | Everything under .harmony/; organized by cognitive function | 2026-01-13 |
| D008 | Consolidated scratchpad | `ideation/scratchpad/` with subdirectories | `inbox/`, `archive/`, `ideas/`, `brainstorm/` are subdirectories of `ideation/scratchpad/` | 2026-01-14 |
| D009 | Human-led zone naming | `ideation/scratchpad/` over `.scratch/` | Explicit, self-documenting name preferred over shorter abbreviation | 2026-01-13 |
| D010 | Projects location | Harness level (`ideation/projects/`) | Projects live at harness level, not in `ideation/scratchpad/`; direct artifact flow to `cognition/context/` | 2026-01-14 |
| D011 | Brainstorm stage | Single-file exploration in `ideation/scratchpad/brainstorm/` | Filter stage between ideas and projects; most ideas die here | 2026-01-14 |
| D012 | The Funnel | ideas → brainstorm → projects → missions → context | Clear pipeline from raw ideas to permanent knowledge | 2026-01-14 |
| D013 | Refactor verification | Mandatory verification gate | Refactors cannot be declared complete until all audit searches return zero | 2026-01-14 |
| D014 | Continuity artifact immutability | Append-only during refactors | Historical records (`continuity/log.md`, `decisions/*.md`) must not be modified, only appended | 2026-01-14 |
| D015 | Universal commands | Symlink from harness to `.harmony/capabilities/runtime/commands/` | Commands defined once in `.harmony/`, symlinked to `.cursor/`, `.claude/` | 2026-01-14 |
| D016 | Mutability frontmatter | `mutability: append-only` property | Files with this property must not have existing content modified; check before editing | 2026-01-14 |
| D017 | Workflow versioning | Semantic versioning in frontmatter | Increment version when modifying workflows; use Version History section | 2026-01-14 |
| D018 | Step idempotency | Required `## Idempotency` section | All workflow step files must include idempotency checks with Check, If Already Complete, Marker | 2026-01-14 |
| D019 | Harness symlinks | Required for `access: human` commands | Commands must be symlinked to all harness directories (`.cursor/`, `.claude/`) | 2026-01-14 |
| D020 | Meta-workflows | `workflows/workflows/` directory | Workflows for creating, evaluating, and updating workflows live in dedicated domain | 2026-01-14 |
| D021 | Prompt refiner skill | 10-phase pipeline in `.harmony/capabilities/runtime/skills/prompt-refiner/` | Use `/refine-prompt` before complex tasks; refines intent, adds context, validates feasibility | 2026-01-14 |
| D022 | Persona assignment | Explicit role/expertise in refined prompts | Refined prompts include Execution Persona section with role, level, perspective, style | 2026-01-14 |
| D023 | Negative constraints | Anti-patterns and forbidden approaches | Refined prompts include "What NOT To Do" section; prevents common mistakes and scope creep | 2026-01-14 |
| D024 | Intent confirmation | User confirms before execution | Refined prompts summarize understanding and request confirmation; skip with `--skip_confirmation` | 2026-01-14 |
| D025 | Primitives documentation | Central reference in `.harmony/cognition/context/primitives.md` | Consult before creating new primitives; explains when to use each type | 2026-01-14 |
| D026 | Seven primitives | Skills, Commands, Workflows, Assistants, Checklists, Prompts, Templates | These are the canonical building blocks; new primitives require ADR | 2026-01-14 |
| D027 | Skill naming convention | Verb-noun pattern (e.g., `refine-prompt`) | Skill names must use verb-noun for action-oriented clarity | 2026-01-15 |
| D028 | Progressive disclosure | Three-tier: SKILL.md + references/ + assets/ | Keep SKILL.md under 500 lines; details in references/ | 2026-01-15 |
| D029 | Reference file structure | phases.md, io-contract.md, safety.md, examples.md, validation.md | Standard files for all skills; machine-parseable YAML frontmatter | 2026-01-15 |
| D030 | Hierarchical harness authority | DOWN only, not UP or SIDEWAYS | Harnesses can write to descendants; cannot write to ancestors or siblings | 2026-01-15 |
| D031 | Output permission tiers | Tier 1 (outputs/), Tier 2 (/.harmony/**), Tier 3 (root/**) | Tier 1 always allowed; Tier 2/3 require declaration and scope validation | 2026-01-15 |
| D032 | Documentation split | Monolithic skills.md → 10 focused documents | Each document under 300 lines; single responsibility | 2026-01-15 |
| D033 | Four-tier progressive disclosure | manifest → registry → SKILL.md → references | Load in tiers; ~50 tokens at discovery, <5000 at activation | 2026-01-17 |
| D034 | Manifest as Tier 1 discovery | Centralized index in manifest.yml | Read manifest.yml first for skill routing; ~50 tokens per skill | 2026-01-17 |
| D035 | Validation tooling | validate-skills.sh with 21 checks | Run validation before commits; CI enforces in pr.yml | 2026-01-17 |
| D036 | Principles documentation | Formal .harmony/cognition/principles/ directory | 8 principles documented; reference when designing new features | 2026-01-17 |
| D037 | display_name extension | Title Case derived from id | Human-readable name; derivable but explicit for clarity | 2026-01-17 |
| D038 | Placeholder validation | `{{snake_case}}` format enforced | Paths use `{{placeholder}}`; validation catches deprecated formats | 2026-01-17 |
| D039 | CI integration | skills-validation job in pr.yml | tiktoken for accurate token counting; --strict mode | 2026-01-17 |
| D040 | Live ruleset pattern | `external-dependent` capability with WebFetch | Skills can fetch rules at runtime from external URLs; stays current without harness updates; requires network; no offline fallback by default | 2026-02-09 |
| D041 | Platforms skill group | New `platforms/` group parallel to `foundations/` | Deployment platform skills (Vercel, etc.) organized separately from language/framework foundations; both use family pattern (parent SKILL.md + children) | 2026-02-09 |
| D042 | Reference knowledge skills in manifest | Foundation children with `specialist` skill set appear in manifest.yml with triggers | Unlike scaffolding children (`disable-model-invocation: true`), reference knowledge skills are independently invocable and need manifest triggers for routing | 2026-02-09 |
| D043 | Agency actor taxonomy | Canonical artifact model is agents + assistants + teams | `subagents/` removed as first-class artifact; routing and validation now use `agency/manifest.yml` and actor registries | 2026-02-11 |
| D044 | Immutable engineering charter | `.harmony/cognition/principles/principles.md` is immutable (`mutability: immutable`, `agent_editable: false`) | Agents must not modify the charter; policy evolution requires a versioned successor plus ADR | 2026-02-20 |
| D045 | Bounded surface separation | Separate runtime artifacts, governance contracts, and operating practices where materially applicable | First rollout is clean-break migration of agency to `actors/`, `governance/`, and `practices/` with CI enforcement of legacy-path removal | 2026-02-20 |
| D046 | Orchestration bounded surfaces | Apply bounded surfaces to orchestration using canonical `runtime/`, `governance/`, and `practices/` surfaces | Legacy orchestration root paths are removed and CI validators enforce no reintroduction | 2026-02-20 |
| D047 | Capabilities bounded surfaces | Apply bounded surfaces to capabilities using canonical `runtime/`, `governance/`, and `practices/` surfaces | Legacy capabilities root runtime/policy paths are removed and CI validators enforce no reintroduction | 2026-02-20 |
| D048 | Assurance bounded surfaces | Apply bounded surfaces to assurance using canonical `runtime/`, `governance/`, and `practices/` surfaces | Legacy assurance root governance/checklist/standards/runtime paths are removed and CI validators enforce no reintroduction | 2026-02-20 |
| D049 | Cognition bounded surfaces | Apply bounded surfaces to cognition using canonical `runtime/`, `governance/`, and `practices/` surfaces | Legacy cognition root runtime/governance/practices paths are removed and CI validators enforce no reintroduction | 2026-02-20 |

## Decision Format

When adding decisions:

```markdown
| ID | Decision | Choice | Constraint | Date |
|----|----------|--------|------------|------|
| DXXX | What was decided | What we chose | Why it matters to agents | YYYY-MM-DD |
```

- **ID**: Sequential identifier (D001, D002, ...)
- **Decision**: Brief name of what was decided
- **Choice**: The option selected
- **Constraint**: How this affects agent behavior
- **Date**: When decided

## Superseded Decisions

Move here when a decision is replaced. Include reference to replacement.

| ID | Decision | Superseded By | Date |
|----|----------|---------------|------|
| D006 | Scratch vs inbox semantics | D008 | 2026-01-13 |

## Decision Addenda

### 2026-02-21

- [ADR-028](../decisions/028-agency-runtime-surface-clean-break-rename.md) — Agency runtime surface clean-break rename (D050)

| ID | Decision | Choice | Constraint | Date |
|----|----------|--------|------------|------|
| D050 | Agency runtime surface canonicalization | Replace `agency/actors/` with `agency/runtime/` as the only runtime surface | Active docs/contracts/validators must resolve agency runtime artifacts through `agency/runtime/*`; `agency/actors` is deprecated and blocked by validation gates | 2026-02-21 |

### 2026-02-21 (continued)

- [ADR-029](../decisions/029-quality-gate-domain-split-clean-break-migration.md) — Quality-gate domain split clean-break migration (D051)

| ID | Decision | Choice | Constraint | Date |
|----|----------|--------|------------|------|
| D051 | Quality-gate domain split | Replace monolithic `quality-gate/` runtime domains with focused `audit/`, `remediation/`, and `refactor/` domains | Active docs/contracts/validators must resolve these capabilities and workflows through new domain paths only; legacy `quality-gate` path/group authority is deprecated and blocked by validation gates | 2026-02-21 |

### 2026-02-21 (continued II)

- [ADR-030](../decisions/030-documentation-audit-clean-break-rename.md) — Documentation audit clean-break rename (D052)

| ID | Decision | Choice | Constraint | Date |
|----|----------|--------|------------|------|
| D052 | Documentation workflow canonical rename | Replace `documentation-quality-gate` with `documentation-audit` as the only workflow id/command/path for docs release checks | Active docs/contracts/validators must route through `documentation-audit`; legacy `documentation-quality-gate` identifier/path is deprecated and blocked by validation guardrails | 2026-02-21 |

### 2026-02-21 (continued III)

- [ADR-031](../decisions/031-cognition-runtime-migrations-surface-split.md) — Cognition runtime migrations surface split (D053)

| ID | Decision | Choice | Constraint | Date |
|----|----------|--------|------------|------|
| D053 | Cognition migration record surface split | Keep migration doctrine in `cognition/practices/methodology/migrations/`, move dated migration records to `cognition/runtime/migrations/`, and centralize migration evidence reports in `output/reports/migrations/` | Active docs/contracts/validators must resolve migration records through `cognition/runtime/migrations/*` and block dated migration records under the practices migration policy surface | 2026-02-21 |

### 2026-02-21 (continued IV)

- [ADR-032](../decisions/032-migration-evidence-bundle-format.md) — Migration evidence bundle format (D054)

| ID | Decision | Choice | Constraint | Date |
|----|----------|--------|------------|------|
| D054 | Migration evidence bundle canonical format | Replace flat migration evidence files with bundle directories containing `bundle.yml`, `evidence.md`, `commands.md`, `validation.md`, and `inventory.md` under `output/reports/migrations/<YYYY-MM-DD>-<slug>/` | Active docs/contracts/validators must enforce bundle directories and required bundle files; flat `*-evidence.md` forms in `output/reports/migrations/` are deprecated and blocked by validation guardrails | 2026-02-21 |

### 2026-02-21 (continued V)

- [ADR-033](../decisions/033-adr-discovery-and-evidence-surface.md) — ADR discovery and evidence surface (D055)

| ID | Decision | Choice | Constraint | Date |
|----|----------|--------|------------|------|
| D055 | ADR discovery and evidence surface | Keep ADRs as canonical single files, add `runtime/decisions/index.yml` for discovery, and add optional decision evidence bundles under `output/reports/decisions/<NNN>-<slug>/` | Active docs/contracts/validators must resolve ADR discovery through the decisions index and enforce decision bundle file contracts when decision evidence bundles are present | 2026-02-21 |

### 2026-02-21 (continued VI)

- [ADR-034](../decisions/034-planning-services-native-first-no-python.md) — Planning+Execution services native-first, no-Python core runtime (D056)
- [ADR-035](../decisions/035-cognition-discovery-and-governance-hardening.md) — Cognition discovery and governance hardening (D057)

| ID | Decision | Choice | Constraint | Date |
|----|----------|--------|------------|------|
| D056 | ADR numeric identity normalization | Renumber planning-services native-first ADR from `013` to `034` so each ADR numeric prefix is unique in runtime decisions | Decision indexes, ADR filenames, and validators must enforce unique numeric ADR identity and id/path numeric alignment | 2026-02-21 |
| D057 | Cognition discovery and governance hardening | Adopt machine-readable governance/practices indexes, section-level heavy-doc indexes, stronger cognition drift watchers, and operational scorecard contract | Cognition discovery must resolve via indexes (`governance/index.yml`, `practices/index.yml`, methodology/architecture section indexes); validators fail closed on index/path/decision-identity drift | 2026-02-21 |
