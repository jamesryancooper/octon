# Framing Migration Execution Plan (Execution-Ready)

Date: 2026-02-24  
Primary owner: `octon-platform`  
Scope: root + `.octon/**` active normative and operational artifacts (exclude direct edits to immutable `principles.md`)  
Goal: align Octon to canonical framing: agent-first purpose, managed complexity (Complexity Calibration/Fitness), and system-governed model.

## Non-Negotiable Constraints

1. Respect precedence: `AGENTS.md` > `CONSTITUTION.md` > `DELEGATION.md` > `MEMORY.md` > `AGENT.md` > `SOUL.md`.
2. Do not edit `.octon/cognition/governance/principles/principles.md` directly.
3. Favor targeted edits over broad rewrites.
4. Complete each step gate before moving to the next step.
5. Preserve `solo/tiny team` messaging in non-SSOT docs where it does not conflict with canonical framing.
6. In SSOT surfaces, prioritize cross-project agent standardization framing.

## Owner Map

- `octon-platform`: cross-domain governance + final convergence
- `cognition-owner`: principles, methodology, architecture framing
- `agency-owner`: agent contracts + onboarding language
- `assurance-owner`: charter/weights/scores + assurance checks
- `capabilities-owner`: services docs + metadata framing
- `orchestration-owner`: workflow orientation docs
- `scaffolding-owner`: templates + governance patterns

## Locked Decisions (2026-02-24)

1. Canonical complexity attribute id: `complexity_calibration`.
2. Migrate all active surfaces to current six-pillar naming.
3. Historical artifacts policy: rewrite old output reports (not freeze-as-is).
4. Historical ADR handling: annotate with superseding links only.
5. Regression validation scope: full repo (excluding `.git` only).
6. Audience policy: preserve `solo/tiny team` language in non-SSOT docs while favoring cross-project agent standardization in SSOT docs.

## Step 0: Branch + Baseline Snapshot

Owner: `octon-platform`  
Edit order:

1. No file edits.

Verification command:

```bash
git status --short
rg -n --hidden --glob '!.git' 'LEGACY_HUMAN_GOVERNED|LEGACY_RISK_TIERED_GOVERNANCE|LEGACY_SIMPLICITY_PRINCIPLE|LEGACY_SIMPLICITY_FIRST|LEGACY_SMALLEST_VIABLE|LEGACY_SIMPLICITY_ATTRIBUTE' AGENTS.md .octon
```

Exit criteria:

- Baseline drift inventory is captured before edits.

## Step 1: Immutable Charter Successor (Do Not Touch `principles.md`)

Owner: `cognition-owner`  
Edit order:

1. Create `.octon/cognition/governance/principles/principles-v2026-02-24.md`
2. Create a superseding ADR under `.octon/cognition/runtime/decisions/` documenting rationale and migration.
3. Update `.octon/cognition/governance/principles/README.md` to reference both immutable charter and active successor path.
4. Update `.octon/cognition/governance/principles/index.yml` with successor discoverability entry.

Verification command:

```bash
git diff -- .octon/cognition/governance/principles/principles.md
rg -n 'principles-v2026-02-24|complexity calibration|system-governed|agent-first' .octon/cognition/governance/principles/README.md .octon/cognition/governance/principles/index.yml .octon/cognition/runtime/decisions
```

Exit criteria:

- Successor charter exists and is linked.
- `principles.md` remains unchanged.

## Step 2: Replace Principle Surface with Complexity Calibration

Owner: `cognition-owner`  
Edit order:

1. Create `.octon/cognition/governance/principles/complexity-calibration.md`
2. Update `.octon/cognition/governance/principles/README.md` principle table + mapping.
3. Update `.octon/cognition/governance/principles/index.yml` (`principle-simplicity-over-complexity` -> `principle-complexity-calibration`, path -> `complexity-calibration.md`).
4. Update references in:
   - `.octon/cognition/governance/principles/locality.md`
   - `.octon/cognition/governance/principles/progressive-disclosure.md`
   - `.octon/cognition/governance/principles/reversibility.md`
   - `.octon/cognition/governance/principles/single-source-of-truth.md`
   - `.octon/cognition/governance/principles/monolith-first-modulith.md`

Verification command:

```bash
rg -n --hidden --glob '!.git' 'LEGACY_SIMPLICITY_PRINCIPLE|simplicity-over-complexity.md|principle-simplicity-over-complexity' .octon/cognition/governance/principles
rg -n 'Complexity Calibration|Complexity Fitness|minimal sufficient complexity|smallest robust solution that meets constraints' .octon/cognition/governance/principles
```

Exit criteria:

- New principle is canonical in principles index/README.
- Legacy principle references removed from active principles docs.

## Step 3: Agency Contract Alignment (Execution Contract First)

Owner: `agency-owner`  
Edit order:

1. Update `.octon/agency/runtime/agents/architect/AGENT.md`
2. Update `.octon/agency/_meta/architecture/architecture.md`
3. Update `.octon/agency/practices/start-here.md`
4. Update `.octon/agency/practices/daily-flow.md`
5. Update `.octon/agency/practices/operating-model.md`

Verification command:

```bash
rg -n 'simplest robust solution|Simplicity & Minimal Scope|LEGACY_SIMPLICITY_FIRST|you orchestrate AI agents|human developer orchestrating' .octon/agency
rg -n 'smallest robust solution that meets constraints|minimal sufficient complexity|system-governed|agent-first' .octon/agency/runtime/agents/architect/AGENT.md .octon/agency/practices
```

Exit criteria:

- Agency contract and onboarding surfaces match canonical framing.

## Step 4: Cross-Subsystem Normative Spec + Root Framing

Owner: `octon-platform`  
Edit order:

1. Update `AGENTS.md` (orientation phrasing only where needed)
2. Update `.octon/cognition/_meta/architecture/specification.md` (OCTON-SPEC-006 + precedence wording coherence)
3. Update `.octon/README.md`
4. Update `.octon/cognition/runtime/context/glossary-repo.md`

Verification command:

```bash
rg -n 'Risk-Tiered Human Governance|LEGACY_HUMAN_GOVERNED' AGENTS.md .octon/README.md .octon/cognition/_meta/architecture/specification.md .octon/cognition/runtime/context/glossary-repo.md
rg -n 'system-governed|policy authorship|exceptions|escalation authority|agent-first' AGENTS.md .octon/README.md .octon/cognition/_meta/architecture/specification.md
```

Exit criteria:

- Root and umbrella spec language aligns with system-governed canonical model.

## Step 5: Methodology SSOT Migration

Owner: `cognition-owner`  
Edit order:

1. Update `.octon/cognition/practices/methodology/README.md`
2. Update `.octon/cognition/practices/methodology/adoption-plan-30-60-90.md`
3. Update `.octon/cognition/practices/methodology/methodology-as-code.md`
4. Update `.octon/cognition/practices/methodology/architecture-and-repo-structure.md`
5. Update `.octon/cognition/practices/methodology/risk-tiers.md`
6. Update `.octon/cognition/runtime/context/risk-tiers.md`
7. Normalize active methodology surfaces to six-pillar naming where legacy five-pillar wording appears.

Verification command:

```bash
rg -n 'LEGACY_HUMAN_GOVERNED|LEGACY_RISK_TIERED_GOVERNANCE|Simplicity first|LEGACY_SIMPLICITY_FIRST|LEGACY_SMALLEST_VIABLE|five pillars' .octon/cognition/practices/methodology .octon/cognition/runtime/context/risk-tiers.md
rg -n 'system-governed|Complexity Calibration|Complexity Fitness|minimal sufficient complexity|smallest robust solution that meets constraints|six pillars' .octon/cognition/practices/methodology
```

Exit criteria:

- Methodology SSOT and risk-tier guidance are fully canonical.

## Step 6: Assurance Contract and Scoring Migration

Owner: `assurance-owner`  
Edit order:

1. Update `.octon/assurance/governance/CHARTER.md` (`Simplicity` -> complexity-calibrated attribute language)
2. Update `.octon/assurance/governance/weights/weights.yml` (attribute id/name + all weight maps)
3. Update `.octon/assurance/governance/scores/scores.yml` (attribute key, criteria, evidence links, conflicts)
4. Update `.octon/assurance/governance/weights/weights.md`
5. Regenerate `.octon/assurance/runtime/_ops/state/effective-weights.lock.yml`

Verification command:

```bash
bash .octon/assurance/runtime/_ops/scripts/compute-assurance-score.sh --weights .octon/assurance/governance/weights/weights.yml --scores .octon/assurance/governance/scores/scores.yml
bash .octon/assurance/runtime/_ops/scripts/assurance-gate.sh --scorecard "$(ls -t .octon/output/assurance/scorecards/*/*/scorecard.yml | head -n 1)" --weights .octon/assurance/governance/weights/weights.yml --scores .octon/assurance/governance/scores/scores.yml
rg -n '\bsimplicity\b' .octon/assurance/governance/weights/weights.yml .octon/assurance/governance/scores/scores.yml .octon/assurance/runtime/_ops/state/effective-weights.lock.yml
```

Exit criteria:

- Assurance scoring and gating run with migrated complexity attribute.

## Step 7: Capabilities Service/Platform Framing Alignment

Owner: `capabilities-owner`  
Edit order:

1. Update `.octon/capabilities/runtime/services/_meta/docs/platform-overview.md`
2. Update `.octon/capabilities/runtime/services/_meta/docs/developer-overview.md`
3. Update `.octon/capabilities/runtime/services/quality/test/guide.md`
4. Update `.octon/capabilities/runtime/services/retrieval/parse/README.md`

Verification command:

```bash
rg -n 'human-governed|simplicity over complexity|LEGACY_SIMPLICITY_ATTRIBUTE|LEGACY_SIMPLICITY_FIRST|five pillars' .octon/capabilities/runtime/services/_meta/docs .octon/capabilities/runtime/services/quality/test/guide.md .octon/capabilities/runtime/services/retrieval/parse/README.md
rg -n 'system-governed|Complexity Calibration|minimal sufficient complexity' .octon/capabilities/runtime/services/_meta/docs/platform-overview.md
```

Exit criteria:

- Capabilities docs no longer reintroduce deprecated framing.

## Step 8: Orchestration + Scaffolding Templates and Patterns

Owner: `scaffolding-owner`  
Edit order:

1. Update `.octon/orchestration/runtime/workflows/tasks/README.md`
2. Update `.octon/scaffolding/practices/prompts/research/README.md`
3. Update `.octon/scaffolding/runtime/templates/AGENTS.md`
4. Update `.octon/scaffolding/runtime/templates/octon/scaffolding/runtime/templates/AGENTS.md`
5. Update `.octon/scaffolding/governance/patterns/adr-policy.md`
6. Update `.octon/scaffolding/governance/patterns/api-design-guidelines.md`
7. Update `.octon/scaffolding/governance/patterns/domain-modeling.md`

Verification command:

```bash
rg -n 'human-led research|human-invoked|Simplicity over Complexity|five pillars' .octon/orchestration/runtime/workflows/tasks/README.md .octon/scaffolding
```

Exit criteria:

- New scaffolds and workflow docs emit canonical framing.

## Step 9: Architecture Reference Surface Normalization

Owner: `cognition-owner`  
Edit order:

1. Update `.octon/cognition/_meta/architecture/overview.md`
2. Update `.octon/cognition/_meta/architecture/governance-model.md`
3. Update `.octon/cognition/_meta/architecture/agent-architecture.md`
4. Update `.octon/cognition/_meta/architecture/kaizen-subsystem.md`

Verification command:

```bash
rg -n 'Speed with Safety|Simplicity over Complexity|Quality through Determinism|Guided Agentic Autonomy|five pillars|human-governed' .octon/cognition/_meta/architecture
```

Exit criteria:

- High-traffic architecture docs align with active canonical framing vocabulary.

## Step 10: Rewrite Historical Output Reports

Owner: `octon-platform`  
Edit order:

1. Rewrite `.octon/output/reports/packages/2026-02-18-quality-charter-qge-integration/qge-readme.md`
2. Rewrite `.octon/output/reports/packages/2026-02-18-quality-weight-model-update/FILES.md`
3. Rewrite `.octon/output/reports/packages/2026-02-18-subsystem-override-policy/SUBSYSTEM_OVERRIDE_POLICY.md`
4. Rewrite `.octon/output/reports/packages/2026-02-18-quality-charter-qge-integration/output.example.md`
5. Ensure rewritten reports reference current Assurance Engine surfaces and canonical umbrella chain.

Verification command:

```bash
rg -n 'LEGACY_QUALITY_ENGINE|\LEGACY_QUALITY_PATH|Trust > Speed of development' .octon/output/reports/packages/2026-02-18-*
rg -n 'Assurance Engine|Assurance > Productivity > Integration' .octon/output/reports/packages/2026-02-18-*
```

Exit criteria:

- Historical output reports preserve traceability and reflect current canonical framing.

## Step 11: Historical ADR Superseding Annotations

Owner: `cognition-owner`  
Edit order:

1. Add superseding-link annotations to historical ADRs that contain deprecated framing tokens.
2. Do not rewrite ADR rationale/body beyond superseding linkage metadata.

Verification command:

```bash
rg -n --hidden --glob '!.git' 'LEGACY_SIMPLICITY_PRINCIPLE|LEGACY_SIMPLICITY_FIRST|human-governed|LEGACY_QUALITY_ENGINE' .octon/cognition/runtime/decisions
rg -n --hidden --glob '!.git' 'Superseded by|Supersedes' .octon/cognition/runtime/decisions
```

Exit criteria:

- Historical ADRs retain append-only history with explicit superseding links.

## Step 12: Regression Guardrails (Automation + Checklist)

Owner: `assurance-owner`  
Edit order:

1. Create `.octon/assurance/runtime/_ops/scripts/validate-framing-alignment.sh`
2. Update `.octon/assurance/runtime/_ops/scripts/alignment-check.sh` to call framing validator.
3. Update `.octon/assurance/practices/complete.md` with framing-complete checklist item.
4. Update `.octon/assurance/practices/session-exit.md` with framing alignment check item.
5. (Optional) Add CI workflow hook in `.github/workflows/` to run framing validator.

Verification command:

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-framing-alignment.sh
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness
rg -n --hidden --glob '!.git' 'LEGACY_HUMAN_GOVERNED|LEGACY_RISK_TIERED_GOVERNANCE|LEGACY_SIMPLICITY_PRINCIPLE|LEGACY_SIMPLICITY_FIRST|LEGACY_SMALLEST_VIABLE|LEGACY_SIMPLICITY_ATTRIBUTE|LEGACY_QUALITY_ENGINE|\LEGACY_QUALITY_PATH' .
```

Exit criteria:

- Full-repo regression checks fail on deprecated framing and pass on canonical framing.

## Step 13: Final Convergence Pass

Owner: `octon-platform`  
Edit order:

1. No net-new policy edits unless gate failures require fixes.
2. Produce final migration convergence note at `.octon/output/reports/analysis/2026-02-24-framing-migration-convergence.md`.

Verification command:

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-harness-structure.sh
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness
bash .octon/assurance/runtime/_ops/scripts/compute-assurance-score.sh --weights .octon/assurance/governance/weights/weights.yml --scores .octon/assurance/governance/scores/scores.yml
git status --short
```

Exit criteria:

- All gates pass.
- No deprecated framing in active surfaces.
- Convergence report captures residual risks and closed decisions.

## Quick Rollback Plan

- If a step breaks policy tooling, revert only the step’s touched files, then rerun its gate.
- Do not roll back immutable-charter successor artifacts once referenced by ADR; instead issue follow-up correction ADR.

## Completion Definition

- All Step 1-13 exit criteria satisfied.
- No open P0/P1 framing findings remain.
- Regression checks are enforced in local alignment and CI.
