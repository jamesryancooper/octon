# Implementation Plan: Superpowers Skills Integration into Octon Harness

## Context

The [obra/superpowers](https://github.com/obra/superpowers) repository contains 14 agent skills. After analysis, we identified skills that genuinely expand octon's skill set coverage (filling gaps in guardian, collaborator, delegator, and stack-agnostic foundation categories), patterns to fold into existing skills, and artifacts better implemented as workflows or commands.

## Summary

| Category | Count | Items |
|----------|-------|-------|
| New skills | 5 | systematic-debugging, audit-completion, test-driven-development, brainstorm-design, delegate-tasks |
| Existing skill enhancements | 2 | spec-to-implementation (+writing-plans patterns), resolve-pr-comments (+receiving-code-review patterns) |
| New workflow | 1 | complete-branch |
| New command | 1 | setup-worktree |
| **Total new files** | **31** | |
| **Total modified files** | **10** | |

---

## Part A: New Skills (5)

### A1. `systematic-debugging` (quality-gate)

**Gap filled:** No general-purpose debugging methodology (only CI-specific `triage-ci-failure`).

**Directory:** `.octon/framework/capabilities/skills/quality-gate/systematic-debugging/`

**Files:**

- `SKILL.md` — executor + guardian, root-cause-first methodology with "Iron Law: no fixes without root cause investigation first"
- `references/phases.md` — 4 phases: Investigate (read errors, reproduce, check recent changes, gather evidence) -> Hypothesize (2-3 ranked hypotheses with evidence for/against) -> Fix (minimal targeted fix) -> Prevent (regression test, document root cause)
- `references/io-contract.md` — params: target, error, scope; output: debugging report
- `references/safety.md` — deny-by-default, max 10 files modified, no error suppression
- `references/validation.md` — acceptance criteria: hypothesis validated with evidence, regression test added, report generated
- `references/examples.md` — 2 worked examples (TypeError investigation, case where obvious fix was wrong)

**Key content from superpowers source:**

- Iron Law enforcement
- "Read error messages carefully" protocol
- Multi-component diagnostic instrumentation
- Evidence-based hypothesis ranking
- Anti-pattern: fixing the first thing that looks wrong

**Frontmatter:**

```yaml
skill_sets: [executor, guardian]
capabilities: []
allowed-tools: Read Glob Grep Edit Bash(npm) Bash(npx) Bash(git) Write(/.octon/state/evidence/validation/analysis/*) Write(logs/*)
```

---

### A2. `audit-completion` (quality-gate)

**Gap filled:** Guardian skill set underrepresented; no verification enforcement skill.

**Directory:** `.octon/framework/capabilities/skills/quality-gate/audit-completion/`

**Files:**

- `SKILL.md` — guardian only (not executor), enforces "Iron Law: no completion claims without fresh verification evidence"
- `references/validation.md` — acceptance criteria: every claim has fresh evidence, verification actually run, failures documented not rationalized
- `references/safety.md` — read-only against source, Bash scoped to test/build/lint only
- `references/examples.md` — standard audit pass, audit catching premature "Done!" claim

**Key content from superpowers source:**

- Gate Function: IDENTIFY claims -> RUN verification -> READ output -> VERIFY against criteria -> CLAIM with evidence
- Common Failures table (stale evidence, assumed success, partial check, rationalization, premature claim)
- Red Flags list ("should", "probably", "seems to", expressing satisfaction before verification)
- Rationalization Prevention table ("Should work now" -> RUN it, "I'm confident" -> confidence != evidence)
- Forbidden response patterns

**Design note:** This is a pure guardian — no executor phases, just the gate function table. Simpler reference set (no phases.md needed).

**Frontmatter:**

```yaml
skill_sets: [guardian]
capabilities: []
allowed-tools: Read Glob Grep Bash(npm) Bash(npx) Bash(git) Write(/.octon/state/evidence/validation/analysis/*) Write(logs/*)
```

---

### A3. `test-driven-development` (foundations/development-practices)

**Gap filled:** All foundation skills are framework-specific; no cross-cutting development practice.

**Directory:** `.octon/framework/capabilities/skills/foundations/development-practices/test-driven-development/`

**Files:**

- `SKILL.md` — specialist (reference/pattern skill like react-best-practices), "Iron Law: no production code without a failing test first"
- `references/glossary.md` — TDD terms: RED, GREEN, REFACTOR, Test Double, Arrange-Act-Assert, Test Isolation, Regression Test
- `references/examples.md` — 3 language-agnostic examples (new function, bug fix, refactor-while-green)

**Key content from superpowers source:**

- Red-Green-Refactor cycle with explicit rules per phase
- Test Isolation rules table
- Anti-Patterns table (writing tests after code, testing implementation details, green-bar addiction, over-engineering in GREEN, skipping REFACTOR)
- "Write code before test? Delete it. Start over." enforcement
- Stack-agnostic: works with any framework (Jest, pytest, XCTest, Go testing, etc.)

**Design note:** This is a `specialist` skill (like react-best-practices), not an `executor`. It provides rules and patterns, not automated phases. New sub-directory `development-practices/` under foundations for stack-agnostic practices.

**Frontmatter:**

```yaml
skill_sets: [specialist]
capabilities: []
allowed-tools: Read Glob Grep Write(logs/*)
```

---

### A4. `brainstorm-design` (ideation -- new group)

**Gap filled:** `.octon/inputs/exploratory/ideation/` domain exists but has zero skills; `collaborator` skill set barely used (only `refine-prompt`).

**Directory:** `.octon/framework/capabilities/skills/ideation/brainstorm-design/`

**Files:**

- `SKILL.md` — executor + collaborator, turns vague ideas into validated designs through iterative dialogue
- `references/phases.md` — 5 phases: Clarify (one question at a time, multiple choice preferred, max 5 questions) -> Explore (2-3 approaches with tradeoffs, recommendation) -> Converge (refine chosen approach, resolve remaining decisions) -> Design (200-300 word sections, validate each) -> Document (compile into design doc)
- `references/interaction.md` — dialogue protocol: clarification questions, approach selection, section validation checkpoints
- `references/io-contract.md` — params: idea, context; output: design document in /.octon/inputs/exploratory/drafts/
- `references/examples.md` — 2 examples (notification system brainstorm, user changes direction mid-design)

**Key content from superpowers source:**

- Dialogue Rules table (one question at a time, multiple choice preferred, 2-3 approaches, 200-300 word sections, validate each section)
- YAGNI ruthlessly in designs
- Project context awareness (check files, docs, recent commits first)
- Incremental validation pattern
- Design output format (architecture, components, data flow, error handling, testing)

**New capabilities.yml group:**

```yaml
ideation:
  description: Explore and refine ideas through structured dialogue
  path: ideation/
  members: [brainstorm-design]
```

**Frontmatter:**

```yaml
skill_sets: [executor, collaborator]
capabilities: []
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/drafts/*) Write(logs/*)
```

---

### A5. `delegate-tasks` (orchestration -- new group)

**Gap filled:** `delegator` skill set has zero skills; first skill with `agent-delegating` capability.

**Directory:** `.octon/framework/capabilities/skills/orchestration/delegate-tasks/`

**Files:**

- `SKILL.md` — coordinator + delegator, dispatches fresh subagent per task with two-stage review gates
- `references/orchestration.md` — DAG pattern: parse-plan -> dispatch-task -> review-spec -> review-quality; max 3 concurrent subagents
- `references/agents.md` — agent definitions (task-executor, spec-reviewer, code-quality-reviewer), fan-out-fan-in strategy, failure policy
- `references/io-contract.md` — params: plan (file), max_concurrent; output: delegation report, run state
- `references/safety.md` — max depth 1 (no sub-sub-agents), max 20 tasks, no auto-merge of conflicts, review gates mandatory
- `references/examples.md` — 5-task delegation with 2 parallel groups

**Key content from superpowers `subagent-driven-development` + `dispatching-parallel-agents`:**

- Fresh Context Per Task principle (prevent context pollution)
- Two-Stage Review: spec compliance (does it match acceptance criteria?) then code quality (conventions, tests, error handling)
- Parallel dispatch for independent problem domains
- Domain-based grouping for related failures
- Depends_on: `spec-to-implementation` (recommended, produces compatible plan format)

**New capabilities.yml group:**

```yaml
orchestration:
  description: Coordinate and delegate work across agents
  path: orchestration/
  members: [delegate-tasks]
```

**Frontmatter:**

```yaml
skill_sets: [coordinator, delegator]
capabilities: []
allowed-tools: Read Glob Grep Bash(git) Write(/.octon/state/evidence/validation/analysis/*) Write(runs/*) Write(logs/*)
```

---

## Part B: Existing Skill Enhancements (2)

### B1. Fold `writing-plans` into `spec-to-implementation`

**Files to modify:**

- `.octon/framework/capabilities/skills/synthesis/spec-to-implementation/SKILL.md`
- `.octon/framework/capabilities/skills/synthesis/spec-to-implementation/references/phases.md`

**What to add to SKILL.md:**

After the "Task Anatomy" section (line ~76), add a new "Step Granularity" subsection:

- **Bite-sized steps** within each task (2-5 minutes each)
- **Explicit file paths** per step: `Create: path`, `Modify: path:lines`, `Test: path`
- **TDD integration per step:** test step first (RED) -> implementation step (GREEN) -> verify step -> commit boundary
- **Commit boundaries** within tasks (each test+implementation pair = one commit)

Add row to "Decomposition Principles" table:

```
| Step granularity | Each task has 2-5 minute steps with explicit file paths |
```

**What to add to references/phases.md:**

Phase 3 (Decompose) -- add new steps after existing ones:

```yaml
- "For each task: decompose into bite-sized steps (2-5 min each)"
- "For each step: specify action verb + explicit file path"
- "For implementation steps: pair with TDD test step"
- "Define commit boundaries within each task"
```

Add new "Step Decomposition" subsection in Phase 3 prose body with:

- File-first steps pattern (Create/Modify/Test/Delete with paths)
- TDD pairing pattern (RED -> GREEN -> REFACTOR -> Commit per step)
- Commit boundary rules

---

### B2. Fold `receiving-code-review` into `resolve-pr-comments`

**Files to modify:**

- `.octon/framework/capabilities/skills/quality-gate/resolve-pr-comments/SKILL.md`
- `.octon/framework/capabilities/skills/quality-gate/resolve-pr-comments/references/phases.md`

**What to add to SKILL.md:**

After "Comment Classification" table (line ~74) and before "Parameters", add new sections:

1. **Cognitive Evaluation Discipline** — READ -> UNDERSTAND -> VERIFY -> EVALUATE -> RESPOND -> IMPLEMENT sequence with gating questions per phase

2. **Forbidden Responses** table — "You're absolutely right!" (fawning), "Great catch!" (flattery before verification), "Let me implement that now" (skipping evaluation), "Done!" without evidence

3. **Source-Specific Handling** table — trust levels for trusted partner, team peer, external contributor

4. **Unclear Feedback Protocol** — if ANY item unclear, STOP all implementation, group unclear items, request clarification

5. **Technical Pushback** guidance — acknowledge concern, explain why current approach is correct with evidence, suggest documentation improvement if applicable

**What to add to references/phases.md:**

Phase 2 (Classify) — add steps:

```yaml
- "For each comment, apply cognitive evaluation: READ -> UNDERSTAND -> VERIFY"
- "Check if reviewer's assertion is factually correct before classifying"
- "Flag unclear comments for clarification before proceeding"
- "Identify comments where technical pushback is warranted"
```

Phase 3 (Plan) — add steps:

```yaml
- "Group unclear items into a single clarification request"
- "GATE: If ANY unclear items exist, stop planning and request clarification"
- "For each comment requiring pushback, draft the reasoning with evidence"
- "Apply source-specific handling based on reviewer trust level"
```

Add "Pre-Resolution Evaluation" subsection in Phase 3 prose with the cognitive evaluation discipline, unclear item handling, and forbidden response check.

---

## Part C: New Workflow (1)

### C1. `complete-branch` (quality-gate)

**Gap filled:** No branch completion workflow with test verification gate.

**Directory:** `.octon/framework/orchestration/workflows/quality-gate/complete-branch/`

**Files:**

- `WORKFLOW.md` — Entry point with steps list, prerequisites (on non-main branch, clean tree), failure conditions
- `01-verify-tests.md` — **Mandatory gate.** Detect test runner (package.json/Makefile/pytest/go test), run suite, STOP if tests fail
- `02-determine-base.md` — Find base branch (upstream tracking -> main -> master -> ask), summarize ahead/behind
- `03-present-options.md` — Show 4 options: merge locally, push+PR, keep as-is, discard. Confirm destructive choices
- `04-execute-choice.md` — Execute chosen option (merge, gh pr create, no-op, branch -D). Error handling for merge conflicts, push failures
- `05-verify.md` — Final verification gate per chosen option

**Workflow manifest entry:**

```yaml
- id: complete-branch
  display_name: Complete Branch
  group: quality-gate
  domain: git
  path: quality-gate/complete-branch/
  summary: Guide completion of development work with test verification and option selection.
  status: active
  triggers:
    - "complete this branch"
    - "finish the branch"
    - "merge or PR"
    - "done with this branch"
```

**Workflow registry entry:**

```yaml
complete-branch:
  version: "1.0.0"
  commands: ["/complete-branch"]
  parameters:
    - name: branch
      type: text
      required: false
      description: "Branch to complete (default: current branch)"
  access: human
  depends_on: []
```

**Workflow group update:** Add `complete-branch` to `workflow_group_definitions.quality-gate.members[]`.

---

## Part D: New Command (1)

### D1. `setup-worktree`

**Gap filled:** No git worktree guidance as an atomic command.

**File:** `.octon/framework/capabilities/commands/setup-worktree.md`

**Content:** Directory selection priority (adjacent to repo -> designated dir -> inside repo with .gitignore), creation steps with `git worktree add`, management commands (list, remove, prune), safety rules (never delete main worktree, use `git worktree remove` not `rm -rf`).

**Commands manifest entry:**

```yaml
- id: setup-worktree
  display_name: Setup Worktree
  path: setup-worktree.md
  summary: Create isolated git worktrees with smart directory selection.
  access: human
  argument_hint: "<branch-name>"
```

---

## Part E: Registry Updates

All registry files that need modification:

| File | Changes |
|------|---------|
| `.octon/framework/capabilities/skills/manifest.yml` | Add 5 new skill entries |
| `.octon/framework/capabilities/skills/registry.yml` | Add 5 new skill registry entries |
| `.octon/framework/capabilities/skills/capabilities.yml` | Add 2 new groups (ideation, orchestration), update quality-gate and foundations members |
| `.octon/framework/orchestration/workflows/manifest.yml` | Add complete-branch entry + update quality-gate group members |
| `.octon/framework/orchestration/workflows/registry.yml` | Add complete-branch entry |
| `.octon/framework/capabilities/commands/manifest.yml` | Add setup-worktree entry |

---

## Implementation Sequence

### Phase 1: Infrastructure (do first -- unblocks everything)

1. Update `capabilities.yml` — add ideation + orchestration groups, update quality-gate + foundations members

### Phase 2: New Skills (parallelizable -- 5 independent skills)

2. `systematic-debugging` — SKILL.md + 5 reference files
2. `audit-completion` — SKILL.md + 3 reference files
3. `test-driven-development` — SKILL.md + 2 reference files
4. `brainstorm-design` — SKILL.md + 4 reference files
5. `delegate-tasks` — SKILL.md + 5 reference files

### Phase 3: Existing Skill Enhancements (parallelizable)

7. Enhance `spec-to-implementation` — SKILL.md + phases.md
2. Enhance `resolve-pr-comments` — SKILL.md + phases.md

### Phase 4: Workflow + Command (parallelizable)

9. `complete-branch` workflow — WORKFLOW.md + 5 step files
2. `setup-worktree` command — 1 file

### Phase 5: Registry Updates (final -- after all artifacts exist)

11. Update skill manifest.yml (5 entries)
2. Update skill registry.yml (5 entries)
3. Update workflow manifest.yml (1 entry + group update)
4. Update workflow registry.yml (1 entry)
5. Update commands manifest.yml (1 entry)

## Verification

- Confirm all new skill directories follow `{group}/{skill-id}/SKILL.md` pattern
- Confirm all manifest paths match actual directory paths
- Confirm all reference files match declared capabilities (per capability_refs in capabilities.yml)
- Confirm all registry I/O paths use valid `{{placeholder}}` syntax
- Confirm SKILL.md frontmatter `name` matches directory name
- Confirm no duplicate IDs across manifests
