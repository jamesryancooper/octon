# Agent Instructions

Root `AGENTS.md` and `CLAUDE.md` are ingress adapters to this canonical file.

## Behavioral Contract

Adopt the default agent persona defined by the harness:

- **Default agent:** `architect` (per `.octon/agency/manifest.yml`)
- **Constitution:** `.octon/agency/governance/CONSTITUTION.md`
- **Delegation policy:** `.octon/agency/governance/DELEGATION.md`
- **Memory policy:** `.octon/agency/governance/MEMORY.md`
- **Execution contract:** `.octon/agency/runtime/agents/architect/AGENT.md`
- **Identity contract:** `.octon/agency/runtime/agents/architect/SOUL.md`
- **Objective brief:** `.octon/OBJECTIVE.md`
- **Active intent contract:** `.octon/cognition/runtime/context/intent.contract.yml`
- **All agents:** `.octon/agency/runtime/agents/registry.yml`

Read and follow your agent contract and active objective contract before beginning work.

## Contract Layers

Contract responsibilities are intentionally split to prevent drift:

1. `/.octon/AGENTS.md` (canonical), `AGENTS.md` (root ingress), and `CLAUDE.md` (root ingress): repository-wide routing, safety, and operational conventions.
2. `CONSTITUTION.md` (cross-agent): non-negotiable governance, conscience rubric, and red lines.
3. `DELEGATION.md` (cross-agent): delegation authority, handoff protocol, and escalation triggers.
4. `MEMORY.md` (cross-agent): memory classes, retention rules, and privacy boundaries.
5. `AGENT.md` (per agent): execution policy, orchestration rules, and task contract.
6. `SOUL.md` (per agent): identity, interpersonal stance, and ambiguity behavior.

Precedence for conflicts: `AGENTS.md` (root ingress for `/.octon/AGENTS.md`) -> `CONSTITUTION.md` -> `DELEGATION.md` -> `MEMORY.md` -> `AGENT.md` -> `SOUL.md`.

## Canonical Framing

- Octon is `agent-first` and `system-governed`.
- Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.
- Governance defaults are encoded in contracts, policies, workflows, and enforcement checks that run by default.
- Humans retain `policy authorship`, `exceptions` handling, and `escalation authority`.
- For design and implementation choices, favor `minimal sufficient complexity` and the `smallest robust solution that meets constraints`.

## Execution Profile Governance (Required)

Before planning or implementing any update, addition, or refactor:

1. Select exactly one governance `change_profile`:
   - `atomic`
   - `transitional`
2. Emit a `Profile Selection Receipt` before implementation.

### Allowed Profiles and Modes

- Atomic Change Profile:
  - Clean Break
  - Big Bang Implementation
  - Big Bang Rollout
- Transitional Change Profile:
  - Phased Implementation
  - Phased Rollout

### Release-Maturity Gate

1. Determine release state using semantic versioning and record machine key `release_state`.
2. `pre-1.0` mode: version `< 1.0.0` or prerelease (`alpha`, `beta`, `rc`).
3. `stable` mode: version `>= 1.0.0` and not prerelease.
4. In `pre-1.0` mode, `atomic` is default and preferred.
5. In `pre-1.0` mode, `transitional` is allowed only when hard gates require it and MUST include machine key `transitional_exception_note` containing:
   - rationale
   - risks
   - owner
   - target removal/decommission date
6. In `stable` mode, choose profile by normal selection logic (no atomic default bias).

### Profile Selection Method (Mandatory)

Collect facts:

- downtime tolerance
- external consumer coordination ability
- data migration/backfill needs
- rollback mechanism
- blast radius and uncertainty
- compliance/policy constraints

Hard gates for `transitional`:

- zero-downtime requirement prevents one-step cutover
- external consumers cannot migrate in one coordinated release
- live migration/backfill requires temporary coexistence for correctness
- operational risk requires progressive exposure and staged validation

If none are true, select `atomic`.

Tie-break rule:

- if both profile conditions appear true, stop and escalate via profile exception request before proceeding.

### Mandatory Output Sections

Plans and implementation receipts for migration/governance-impacting work MUST include:

1. `Profile Selection Receipt`
2. `Implementation Plan`
3. `Impact Map (code, tests, docs, contracts)`
4. `Compliance Receipt`
5. `Exceptions/Escalations`

### Transitional Requirements

If `change_profile=transitional` is selected:

- define phases and phase exit criteria
- define final decommission/removal date
- remove temporary/legacy surfaces at final state
- include both phase-behavior and final-behavior tests

## Charter Change Control

- Treat `.octon/cognition/governance/principles/principles.md` as a constitutional charter with strict change control.
- Agents MUST NOT modify `.octon/cognition/governance/principles/principles.md` unless explicit human override instructions authorize the change.
- Default evolution path remains: create a versioned successor (`principles-vYYYY-MM-DD.md`) and record an ADR.
- For direct charter edits and major framing shifts under override, record rationale, responsible owner, review date, override scope, review/agreement evidence, and intentional non-automated exception linkage.
- Every direct charter edit under override MUST append a record to `.octon/cognition/governance/exceptions/principles-charter-overrides.md`.
- `main` updates MUST be PR-first; direct pushes are break-glass only and require commit footer `BREAK-GLASS: OVR-YYYY-MM-DD-NNN` aligned to the override ledger.
- `main` branch deletion is prohibited. Agents MUST refuse requests to delete `main` (local or remote).

## Harness Orientation

This repository uses a `.octon/` harness. For full boot sequence and
structure, read `.octon/START.md`.

`.octon/` is organized by domain. Each domain has a `README.md` for
orientation.

- **Agency:** `.octon/agency/` (runtime, governance, practices)
- **Capabilities:** `.octon/capabilities/` (runtime, governance, practices)
  - Commands: `.octon/capabilities/runtime/commands/manifest.yml`
  - Skills: `.octon/capabilities/runtime/skills/manifest.yml`
- **Cognition:** `.octon/cognition/` (runtime, governance, practices)
  - Context index: `.octon/cognition/runtime/context/index.yml`
- **Orchestration:** `.octon/orchestration/` (workflows, missions)
- **Scaffolding:** `.octon/scaffolding/` (runtime, governance, practices)
- **Assurance:** `.octon/assurance/` (runtime, governance, practices)
- **Continuity:** `.octon/continuity/` (progress log, tasks, next steps)
- **Ideation:** `.octon/ideation/` (scratchpad, projects — human-led)
- **Output:** `.octon/output/` (reports, drafts, artifacts)
- **Engine:** `.octon/engine/` (runtime authority, governance contracts, operating practices)

## Skills

Read `.octon/capabilities/runtime/skills/manifest.yml` for skill discovery.

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

Read `.octon/orchestration/runtime/workflows/manifest.yml` for canonical
workflow discovery.

### Workflow Discovery

1. Read `manifest.yml` for workflow index (id, group, summary, triggers)
2. After matching, read `registry.yml` for extended metadata and I/O
3. Load `<group>/<workflow-id>/workflow.yml` for the canonical contract
4. Load `stages/` assets during execution
5. Load `README.md` only when human-readable staged guidance is needed

### Invocation

- Explicit workflow command: `.octon/engine/runtime/run workflow run <workflow-id>`
- Explicit slash command: `/audit-orchestration`
- Explicit call: `use workflow: audit-orchestration`
- Natural triggers: Match against canonical workflow triggers first

## Commit Discipline

- Follow `.octon/agency/practices/commits.md` for branch naming, Conventional Commit
  format, and commit quality rules.
- Use commit messages in the form `<type>(<scope>): <summary>`.

## Pull Request Discipline

- Follow `.octon/agency/practices/pull-request-standards.md` for PR scope,
  description quality, and reviewer expectations.
- Use `.github/PULL_REQUEST_TEMPLATE.md` (or a scoped template under
  `.github/PULL_REQUEST_TEMPLATE/`) when opening PRs.

## Branch Closeout Gate (Required)

- After any conversation turn that results in file changes, the agent MUST ask
  exactly: `Are you ready to closeout this branch?`
- This gate is required even when the implementation task itself is complete.
- If the user answers "yes", run the full Git/GitHub closeout lifecycle:
  stage, commit, push, open/update PR, request auto-merge (policy permitting),
  monitor to completion, and run cleanup.
- If the user answers "no", stop after summarizing the completed work and leave
  branch state unchanged.
- Do not ask this question for read-only turns (no file changes).
