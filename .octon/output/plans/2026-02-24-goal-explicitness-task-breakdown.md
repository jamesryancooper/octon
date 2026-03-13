# Goal Explicitness Migration Task Breakdown (Execution-Ready)

Date: 2026-02-24  
Primary owner: `octon-platform`  
Canonical goal (authoritative text):  
`Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.`

## Execution Rules

1. Respect precedence: `AGENTS.md` -> `CONSTITUTION.md` -> `DELEGATION.md` -> `MEMORY.md` -> `AGENT.md` -> `SOUL.md`.
2. Do not edit immutable charter: `/.octon/cognition/governance/principles/principles.md`.
3. Use exact canonical goal text in required control points (no paraphrase at those points).
4. Keep edits targeted; avoid broad rewrites.
5. Run step verification command before starting the next step.

## Owner Map

- `octon-platform`: cross-domain orchestration + final convergence
- `agency-owner`: agency governance/contracts/runtime agent surfaces
- `cognition-owner`: governance purpose/pillars/methodology consistency
- `continuity-owner`: continuity architecture/readmes
- `capabilities-owner`: skills/workflows/services manifests and scaffolds
- `orchestration-owner`: workflow templates/manifests
- `scaffolding-owner`: bootstrap templates
- `assurance-owner`: regression checks and alignment gates

## Step 0: Baseline Snapshot

Owner: `octon-platform`

File list:

1. No edits (baseline only)

Exact edit order:

1. Confirm working tree state.
2. Confirm canonical goal is not yet explicit in required control points.

Verification command:

```bash
git status --short && \
CANON='Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.' && \
rg -nF "$CANON" \
  AGENTS.md \
  .octon/agency/governance/CONSTITUTION.md \
  .octon/agency/governance/DELEGATION.md \
  .octon/agency/governance/MEMORY.md \
  .octon/agency/runtime/agents/architect/AGENT.md \
  .octon/agency/runtime/agents/architect/SOUL.md || true
```

## Wave 1: Governance and Contracts

## Step 1: Root Precedence Anchor

Owner: `octon-platform`

File list:

1. `AGENTS.md`

Exact edit order:

1. In `Canonical Framing`, append canonical goal sentence verbatim.
2. Keep existing framing bullets unchanged unless needed for coherence.

Verification command:

```bash
CANON='Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.' && \
rg -nF "$CANON" AGENTS.md
```

## Step 2: Constitution Explicitness

Owner: `agency-owner`

File list:

1. `.octon/agency/governance/CONSTITUTION.md`

Exact edit order:

1. Add explicit goal statement in `Contract Scope` or `Non-Negotiables`.
2. Ensure wording remains subordinate to root `AGENTS.md`.

Verification command:

```bash
CANON='Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.' && \
rg -nF "$CANON" .octon/agency/governance/CONSTITUTION.md
```

## Step 3: Delegation Explicitness

Owner: `agency-owner`

File list:

1. `.octon/agency/governance/DELEGATION.md`

Exact edit order:

1. Add explicit goal mapping in `Delegation Principles` and/or `Delegation Packet Requirements`.
2. Keep delegation mechanics unchanged.

Verification command:

```bash
CANON='Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.' && \
rg -nF "$CANON" .octon/agency/governance/DELEGATION.md
```

## Step 4: Memory Explicitness

Owner: `agency-owner`

File list:

1. `.octon/agency/governance/MEMORY.md`

Exact edit order:

1. Add explicit goal mapping in scope/intent section.
2. Tie memory retention to observability/debuggability and safe evolution.

Verification command:

```bash
CANON='Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.' && \
rg -nF "$CANON" .octon/agency/governance/MEMORY.md
```

## Step 5: Default Agent Contracts

Owner: `agency-owner`

File list:

1. `.octon/agency/runtime/agents/architect/AGENT.md`
2. `.octon/agency/runtime/agents/architect/SOUL.md`

Exact edit order:

1. Add canonical goal sentence in AGENT scope/directive section.
2. Add concise canonical goal reference in SOUL philosophy/boundary section.

Verification command:

```bash
CANON='Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.' && \
rg -nF "$CANON" \
  .octon/agency/runtime/agents/architect/AGENT.md \
  .octon/agency/runtime/agents/architect/SOUL.md
```

## Step 6: Immutable Charter Handling Gate

Owner: `cognition-owner`

File list:

1. `.octon/cognition/governance/principles/principles.md` (read-only check)
2. Optional successor: `.octon/cognition/governance/principles/principles-v2026-02-24.md`
3. Optional ADR in `.octon/cognition/runtime/decisions/`

Exact edit order:

1. Confirm immutable charter remains unedited.
2. If principle-layer explicit canonical sentence is required, create successor + ADR + index links.

Verification command:

```bash
git diff -- .octon/cognition/governance/principles/principles.md
```

## Wave 2: Runtime and Domain Docs

## Step 7: Top-Level Harness Entrypoints

Owner: `octon-platform`

File list:

1. `.octon/README.md`
2. `.octon/START.md`

Exact edit order:

1. Add canonical goal sentence in `.octon/README.md` Purpose/Overview.
2. Add canonical goal sentence in `.octon/START.md` near top orientation.

Verification command:

```bash
CANON='Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.' && \
rg -nF "$CANON" .octon/README.md .octon/START.md
```

## Step 8: Domain Root READMEs

Owner: `octon-platform`

File list:

1. `.octon/agency/README.md`
2. `.octon/capabilities/README.md`
3. `.octon/capabilities/runtime/README.md`
4. `.octon/cognition/README.md`
5. `.octon/orchestration/README.md`
6. `.octon/continuity/README.md`
7. `.octon/engine/governance/README.md`

Exact edit order:

1. Add one-line canonical goal mapping at top of each file.
2. Keep surface catalogs unchanged.

Verification command:

```bash
CANON='Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.' && \
rg -nF "$CANON" \
  .octon/agency/README.md \
  .octon/capabilities/README.md \
  .octon/capabilities/runtime/README.md \
  .octon/cognition/README.md \
  .octon/orchestration/README.md \
  .octon/continuity/README.md \
  .octon/engine/governance/README.md
```

## Step 9: Continuity Architecture Explicitness

Owner: `continuity-owner`

File list:

1. `.octon/continuity/_meta/architecture/continuity-plane.md`
2. `.octon/continuity/runs/README.md`
3. `.octon/continuity/_meta/architecture/runs-retention.md`

Exact edit order:

1. Add explicit mapping from continuity evidence to debuggability and safe evolution.
2. Keep lifecycle/retention semantics unchanged.

Verification command:

```bash
rg -n 'determin|observ|debug|evolv|trust' \
  .octon/continuity/_meta/architecture/continuity-plane.md \
  .octon/continuity/runs/README.md \
  .octon/continuity/_meta/architecture/runs-retention.md
```

## Step 10: Purpose/Pillar Drift Fix

Owner: `cognition-owner`

File list:

1. `.octon/cognition/governance/purpose/convivial-purpose.md`
2. Any directly linked governance-purpose index files if needed

Exact edit order:

1. Replace active “five pillars” references with current six-pillar framing.
2. Preserve purpose narrative; only fix active terminology drift.

Verification command:

```bash
rg -n "five pillars|six pillars" .octon/cognition/governance/purpose/convivial-purpose.md .octon/cognition/governance/pillars/README.md
```

## Wave 3: Capabilities, Workflows, and Templates

## Step 11: Workflow and Skill Scaffold Templates

Owner: `orchestration-owner`

File list:

1. `.octon/orchestration/runtime/workflows/_scaffold/template/WORKFLOW.md`
2. `.octon/capabilities/runtime/skills/_scaffold/template/SKILL.md`
3. `.octon/capabilities/runtime/services/_scaffold/template/SERVICE.md`

Exact edit order:

1. Add required “Goal Alignment” section to `WORKFLOW.md`.
2. Add required “Goal Alignment” section to `SKILL.md`.
3. Add explicit canonical goal note to `SERVICE.md` template body/frontmatter guidance.

Verification command:

```bash
CANON='Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.' && \
rg -nF "$CANON" \
  .octon/orchestration/runtime/workflows/_scaffold/template/WORKFLOW.md \
  .octon/capabilities/runtime/skills/_scaffold/template/SKILL.md \
  .octon/capabilities/runtime/services/_scaffold/template/SERVICE.md
```

## Step 12: Runtime Manifests Goal Metadata

Owner: `capabilities-owner`

File list:

1. `.octon/orchestration/runtime/workflows/manifest.yml`
2. `.octon/capabilities/runtime/skills/manifest.yml`
3. `.octon/capabilities/runtime/services/manifest.yml`
4. `.octon/capabilities/runtime/commands/manifest.yml`

Exact edit order:

1. Add top-level goal-alignment metadata/comment to each manifest.
2. Do not modify IDs/paths/schema-critical fields.

Verification command:

```bash
rg -n "goal|reliable|determin|observ|debug|evolv|trust" \
  .octon/orchestration/runtime/workflows/manifest.yml \
  .octon/capabilities/runtime/skills/manifest.yml \
  .octon/capabilities/runtime/services/manifest.yml \
  .octon/capabilities/runtime/commands/manifest.yml
```

## Step 13: Scaffolding Bootstrap Propagation

Owner: `scaffolding-owner`

File list:

1. `.octon/scaffolding/runtime/templates/AGENTS.md`
2. `.octon/scaffolding/runtime/templates/octon/START.md`
3. `.octon/scaffolding/runtime/templates/octon/continuity/tasks.json`
4. `.octon/scaffolding/runtime/templates/octon/agency/manifest.yml`
5. `.octon/scaffolding/runtime/templates/octon/manifest.json` (template consistency fixes)

Exact edit order:

1. Add canonical goal sentence to template `AGENTS.md`.
2. Add canonical goal sentence to template harness `START.md`.
3. Seed canonical goal in template `continuity/tasks.json` goal field guidance.
4. Add goal alignment metadata/reference in template agency manifest.
5. Correct stale template structure references in template manifest if required for coherence.

Verification command:

```bash
CANON='Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.' && \
rg -nF "$CANON" \
  .octon/scaffolding/runtime/templates/AGENTS.md \
  .octon/scaffolding/runtime/templates/octon/START.md \
  .octon/scaffolding/runtime/templates/octon/continuity/tasks.json && \
rg -n "goal|alignment|assurance|runtime/agents" .octon/scaffolding/runtime/templates/octon/manifest.json
```

## Wave 4: Assurance and Regression Checks

## Step 14: Framing Validator Upgrade

Owner: `assurance-owner`

File list:

1. `.octon/assurance/runtime/_ops/scripts/validate-framing-alignment.sh`

Exact edit order:

1. Add explicit canonical goal check for required control points.
2. Keep existing framing marker checks (`agent-first`, `system-governed`, etc.) unless intentionally superseded.
3. Add drift check for active contradictory wording (for example, `five pillars` where no longer valid).

Verification command:

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-framing-alignment.sh
```

## Step 15: SSOT Drift Validator Extension

Owner: `assurance-owner`

File list:

1. `.octon/assurance/runtime/_ops/scripts/validate-ssot-precedence-drift.sh`

Exact edit order:

1. Add checks that precedence-layer goal wording does not conflict.
2. Keep existing precedence checks intact.

Verification command:

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-ssot-precedence-drift.sh
```

## Step 16: Full Alignment Gate

Owner: `octon-platform`

File list:

1. No edits (gate run)

Exact edit order:

1. Run targeted profiles first (`framing,harness`).
2. Run full relevant stack (`framing,harness,agency,workflows,skills,services,weights`).
3. Capture failures and loop back to owning step.

Verification command:

```bash
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile framing,harness,agency,workflows,skills,services,weights
```

## Final Done Gate

All items below must be true:

1. Canonical goal text is explicit in all required control points.
2. No active-doc contradiction remains (`five pillars` drift resolved in active governance-purpose surfaces).
3. Scaffold templates propagate explicit goal text by default.
4. Framing and SSOT validators pass.
5. Full alignment-check profile passes.

