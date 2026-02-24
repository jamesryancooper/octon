# Agent Instructions

## Behavioral Contract

Adopt the default agent persona defined by the harness:

- **Default agent:** `architect` (per `.harmony/agency/manifest.yml`)
- **Constitution:** `.harmony/agency/governance/CONSTITUTION.md`
- **Delegation policy:** `.harmony/agency/governance/DELEGATION.md`
- **Memory policy:** `.harmony/agency/governance/MEMORY.md`
- **Execution contract:** `.harmony/agency/runtime/agents/architect/AGENT.md`
- **Identity contract:** `.harmony/agency/runtime/agents/architect/SOUL.md`
- **All agents:** `.harmony/agency/runtime/agents/registry.yml`

Read and follow your agent contract before beginning work.

## Contract Layers

Contract responsibilities are intentionally split to prevent drift:

1. `AGENTS.md` (root): repository-wide routing, safety, and operational conventions.
2. `CONSTITUTION.md` (cross-agent): non-negotiable governance, conscience rubric, and red lines.
3. `DELEGATION.md` (cross-agent): delegation authority, handoff protocol, and escalation triggers.
4. `MEMORY.md` (cross-agent): memory classes, retention rules, and privacy boundaries.
5. `AGENT.md` (per agent): execution policy, orchestration rules, and task contract.
6. `SOUL.md` (per agent): identity, interpersonal stance, and ambiguity behavior.

Precedence for conflicts: `AGENTS.md` -> `CONSTITUTION.md` -> `DELEGATION.md` -> `MEMORY.md` -> `AGENT.md` -> `SOUL.md`.

## Canonical Framing

- Harmony is `agent-first` and `system-governed`.
- Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.
- Governance defaults are encoded in contracts, policies, workflows, and enforcement checks that run by default.
- Humans retain `policy authorship`, `exceptions` handling, and `escalation authority`.
- For design and implementation choices, favor `minimal sufficient complexity` and the `smallest robust solution that meets constraints`.

## Charter Change Control

- Treat `.harmony/cognition/governance/principles/principles.md` as a constitutional charter with strict change control.
- Agents MUST NOT modify `.harmony/cognition/governance/principles/principles.md` unless explicit human override instructions authorize the change.
- Default evolution path remains: create a versioned successor (`principles-vYYYY-MM-DD.md`) and record an ADR.
- For direct charter edits and major framing shifts under override, record rationale, responsible owner, review date, override scope, review/agreement evidence, and intentional non-automated exception linkage.
- Every direct charter edit under override MUST append a record to `.harmony/cognition/governance/exceptions/principles-charter-overrides.md`.
- `main` updates MUST be PR-first; direct pushes are break-glass only and require commit footer `BREAK-GLASS: OVR-YYYY-MM-DD-NNN` aligned to the override ledger.

## Harness Orientation

This repository uses a `.harmony/` harness. For full boot sequence and
structure, read `.harmony/START.md`.

`.harmony/` is organized by domain. Each domain has a `README.md` for
orientation.

- **Agency:** `.harmony/agency/` (runtime, governance, practices)
- **Capabilities:** `.harmony/capabilities/` (runtime, governance, practices)
  - Commands: `.harmony/capabilities/runtime/commands/manifest.yml`
  - Skills: `.harmony/capabilities/runtime/skills/manifest.yml`
- **Cognition:** `.harmony/cognition/` (runtime, governance, practices)
  - Context index: `.harmony/cognition/runtime/context/index.yml`
- **Orchestration:** `.harmony/orchestration/` (workflows, missions)
- **Scaffolding:** `.harmony/scaffolding/` (runtime, governance, practices)
- **Assurance:** `.harmony/assurance/` (runtime, governance, practices)
- **Continuity:** `.harmony/continuity/` (progress log, tasks, next steps)
- **Ideation:** `.harmony/ideation/` (scratchpad, projects — human-led)
- **Output:** `.harmony/output/` (reports, drafts, artifacts)
- **Engine:** `.harmony/engine/` (runtime authority, governance contracts, operating practices)

## Skills

Read `.harmony/capabilities/runtime/skills/manifest.yml` for skill discovery.

### Skill Discovery

1. Read `manifest.yml` for skill index (id, name, summary, triggers)
2. For validation/expansion, read `capabilities.yml` (skill sets, capabilities, refs)
3. After matching, read `registry.yml` for extended metadata and I/O paths
4. Load `SKILL.md` when a skill is activated (includes `allowed-tools` for tool permissions)
5. Load `references/` or `scripts/` only if needed

### Skill Invocation

- Explicit command: `/synthesize-research <path>`
- Explicit call: `use skill: synthesize-research`
- Natural triggers: Match against `triggers` in manifest

### Safety

- Follow `deny-by-default` tool policy
- Log every execution to `capabilities/runtime/skills/_ops/state/logs/`

## Workflows

Read `.harmony/orchestration/runtime/workflows/manifest.yml` for workflow discovery.

### Workflow Discovery

1. Read `manifest.yml` for workflow index (id, name, summary, triggers)
2. After matching, read `registry.yml` for extended metadata and parameters
3. Load `WORKFLOW.md` when a workflow is activated
4. Load step files (01-*.md, 02-*.md, ...) during execution

### Workflow Invocation

- Explicit command: `/audit-orchestration-workflow manifest="..."`
- Explicit call: `use workflow: audit-orchestration-workflow`
- Natural triggers: Match against `triggers` in manifest

## Commit Discipline

- Follow `.harmony/agency/practices/commits.md` for branch naming, Conventional Commit
  format, and commit quality rules.
- Use commit messages in the form `<type>(<scope>): <summary>`.

## Pull Request Discipline

- Follow `.harmony/agency/practices/pull-request-standards.md` for PR scope,
  description quality, and reviewer expectations.
- Use `.github/PULL_REQUEST_TEMPLATE.md` (or a scoped template under
  `.github/PULL_REQUEST_TEMPLATE/`) when opening PRs.
