---
title: Decisions
description: Agent-readable summary of key decisions affecting this workspace.
mutability: append-only
---

# Decisions

Key decisions that constrain or guide work in this workspace. For full rationale, see `.harmony/cognition/decisions/`.

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
| D010 | Projects location | Workspace level (`projects/`) | Projects live at workspace level, not in `ideation/scratchpad/`; direct artifact flow to `context/` | 2026-01-14 |
| D011 | Brainstorm stage | Single-file exploration in `ideation/scratchpad/brainstorm/` | Filter stage between ideas and projects; most ideas die here | 2026-01-14 |
| D012 | The Funnel | ideas → brainstorm → projects → missions → context | Clear pipeline from raw ideas to permanent knowledge | 2026-01-14 |
| D013 | Refactor verification | Mandatory verification gate | Refactors cannot be declared complete until all audit searches return zero | 2026-01-14 |
| D014 | Continuity artifact immutability | Append-only during refactors | Historical records (`continuity/log.md`, `decisions/*.md`) must not be modified, only appended | 2026-01-14 |
| D015 | Universal commands | Symlink from harness to `.harmony/capabilities/commands/` | Commands defined once in `.harmony/`, symlinked to `.cursor/`, `.claude/` | 2026-01-14 |
| D016 | Mutability frontmatter | `mutability: append-only` property | Files with this property must not have existing content modified; check before editing | 2026-01-14 |
| D017 | Workflow versioning | Semantic versioning in frontmatter | Increment version when modifying workflows; use Version History section | 2026-01-14 |
| D018 | Step idempotency | Required `## Idempotency` section | All workflow step files must include idempotency checks with Check, If Already Complete, Marker | 2026-01-14 |
| D019 | Harness symlinks | Required for `access: human` commands | Commands must be symlinked to all harness directories (`.cursor/`, `.claude/`) | 2026-01-14 |
| D020 | Meta-workflows | `workflows/workflows/` directory | Workflows for creating, evaluating, and updating workflows live in dedicated domain | 2026-01-14 |
| D021 | Prompt refiner skill | 10-phase pipeline in `.harmony/capabilities/skills/prompt-refiner/` | Use `/refine-prompt` before complex tasks; refines intent, adds context, validates feasibility | 2026-01-14 |
| D022 | Persona assignment | Explicit role/expertise in refined prompts | Refined prompts include Execution Persona section with role, level, perspective, style | 2026-01-14 |
| D023 | Negative constraints | Anti-patterns and forbidden approaches | Refined prompts include "What NOT To Do" section; prevents common mistakes and scope creep | 2026-01-14 |
| D024 | Intent confirmation | User confirms before execution | Refined prompts summarize understanding and request confirmation; skip with `--skip_confirmation` | 2026-01-14 |
| D025 | Primitives documentation | Central reference in `.harmony/cognition/context/primitives.md` | Consult before creating new primitives; explains when to use each type | 2026-01-14 |
| D026 | Seven primitives | Skills, Commands, Workflows, Assistants, Checklists, Prompts, Templates | These are the canonical building blocks; new primitives require ADR | 2026-01-14 |
| D027 | Skill naming convention | Verb-noun pattern (e.g., `refine-prompt`) | Skill names must use verb-noun for action-oriented clarity | 2026-01-15 |
| D028 | Progressive disclosure | Three-tier: SKILL.md + references/ + assets/ | Keep SKILL.md under 500 lines; details in references/ | 2026-01-15 |
| D029 | Reference file structure | behaviors.md, io-contract.md, safety.md, examples.md, validation.md | Standard files for all skills; machine-parseable YAML frontmatter | 2026-01-15 |
| D030 | Hierarchical workspace authority | DOWN only, not UP or SIDEWAYS | Workspaces can write to descendants; cannot write to ancestors or siblings | 2026-01-15 |
| D031 | Output permission tiers | Tier 1 (outputs/), Tier 2 (.harmony/**), Tier 3 (root/**) | Tier 1 always allowed; Tier 2/3 require declaration and scope validation | 2026-01-15 |
| D032 | Documentation split | Monolithic skills.md → 10 focused documents | Each document under 300 lines; single responsibility | 2026-01-15 |
| D033 | Four-tier progressive disclosure | manifest → registry → SKILL.md → references | Load in tiers; ~50 tokens at discovery, <5000 at activation | 2026-01-17 |
| D034 | Manifest as Tier 1 discovery | Centralized index in manifest.yml | Read manifest.yml first for skill routing; ~50 tokens per skill | 2026-01-17 |
| D035 | Validation tooling | validate-skills.sh with 21 checks | Run validation before commits; CI enforces in pr.yml | 2026-01-17 |
| D036 | Principles documentation | Formal docs/principles/ directory | 8 principles documented; reference when designing new features | 2026-01-17 |
| D037 | display_name extension | Title Case derived from id | Human-readable name; derivable but explicit for clarity | 2026-01-17 |
| D038 | Placeholder validation | `{{snake_case}}` format enforced | Paths use `{{placeholder}}`; validation catches deprecated formats | 2026-01-17 |
| D039 | CI integration | skills-validation job in pr.yml | tiktoken for accurate token counting; --strict mode | 2026-01-17 |

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

