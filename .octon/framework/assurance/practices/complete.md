---
title: Definition of Done
description: Assurance criteria and completion checklist for harness tasks.
---

# Definition of Done

## Before Marking Any Task Complete

- [ ] Output matches task requirements
- [ ] Stayed within `scope.md` boundaries
- [ ] Follows `conventions.md` style rules
- [ ] Framing-complete checks passed (for framing-sensitive changes)
- [ ] Native-first rule preserved (core behavior works with zero adapters)
- [ ] Updated `/.octon/state/continuity/repo/log.md` with session summary
- [ ] Updated `/.octon/state/continuity/repo/tasks.json` status
- [ ] `validate-continuity-memory.sh` passes when continuity/memory artifacts changed
- [ ] `validate-developer-context-policy.sh` passes when developer context policy surfaces change
- [ ] `validate-context-overhead-budget.sh` passes when runtime telemetry/receipt policy surfaces change

## Assurance Criteria

### For Agent-Facing Content

- [ ] Under token budget
- [ ] Actionable (agent can act on it immediately)
- [ ] No explanatory padding ("why" belongs in `ideation/scratchpad/` or `docs/`)
- [ ] Uses lists over prose

### For Prompts/Workflows

- [ ] Clear context section (1-2 sentences)
- [ ] Numbered instructions
- [ ] Defined output/deliverable
- [ ] Tested with at least one execution

### For Agent Platform Interop Changes

- [ ] Core contracts/schemas remain provider-agnostic
- [ ] Provider-specific terms exist only in adapter paths
- [ ] `validate-service-independence.sh --mode platform-core` passes
- [ ] `validate-service-independence.sh --mode conformance` passes (when adapters are in scope)
- [ ] `validate-service-independence.sh --mode degradation` passes
- [ ] Native commands (`context-budget`, `validate-session-policy`) run without adapters

### For Filesystem Interface Changes

- [ ] Files remain source-of-truth; graph is derived from snapshots
- [ ] `validate-filesystem-interfaces.sh` passes
- [ ] Snapshot build emits deterministic `snap-*` IDs for identical inputs
- [ ] Progressive discovery commands (`discover-start`, `discover-expand`, `discover-resolve`) execute with an active snapshot

### For .octon Architecture Changes

- [ ] `bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh` passes
- [ ] `bash .octon/framework/assurance/runtime/_ops/scripts/validate-contract-governance.sh` passes
- [ ] `bash .octon/framework/assurance/runtime/_ops/scripts/validate-continuity-memory.sh` passes
- [ ] `bash .octon/framework/assurance/runtime/_ops/scripts/validate-developer-context-policy.sh` passes
- [ ] `bash .octon/framework/assurance/runtime/_ops/scripts/validate-context-overhead-budget.sh` passes
- [ ] `bash .octon/framework/assurance/runtime/_ops/scripts/validate-audit-subsystem-health-alignment.sh` passes
- [ ] `bash .octon/framework/assurance/runtime/_ops/scripts/validate-audit-convergence-contract.sh` passes
- [ ] `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness` passes
- [ ] `bash .octon/framework/assurance/runtime/_ops/scripts/validate-framing-alignment.sh` passes
- [ ] `audit-pre-release` workflow executed (or explicit rationale recorded for not running it)
- [ ] Contract coverage report exists at `.octon/generated/assurance/results/contract-coverage-latest.md`
- [ ] Material run evidence includes instruction-layer manifest and context-acquisition telemetry fields

### For Commit/PR Standards Changes

- [ ] `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile commit-pr` passes

### For Assurance Weight Governance Changes

- [ ] `bash .octon/framework/assurance/runtime/_ops/scripts/compute-assurance-score.sh --weights .octon/framework/assurance/governance/weights/weights.yml --scores .octon/framework/assurance/governance/scores/scores.yml` runs successfully
- [ ] `bash .octon/framework/assurance/runtime/_ops/scripts/assurance-gate.sh --scorecard <generated-scorecard.yml> --weights .octon/framework/assurance/governance/weights/weights.yml --scores .octon/framework/assurance/governance/scores/scores.yml` passes (or warning rationale is recorded)
- [ ] Resolver generated `.octon/generated/effective/assurance/<context>.md` and `.octon/generated/assurance/results/<context>.md`

## Common Failure Modes

| Failure | Prevention |
|---------|------------|
| **Premature completion** | Run through this checklist before marking done |
| **Scope creep** | Re-read `scope.md` if task expands |
| **Broken continuity** | Always update `/.octon/state/continuity/repo/log.md` before session end |
| **Token bloat** | Ask "does an agent need this to act?" If no, cut it or move to `ideation/scratchpad/` |
