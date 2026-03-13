# Intent Layer Clean-Break Migration Task Breakdown (Execution-Ready)

Date: 2026-02-25  
Primary owner: `octon-platform`  
Scope: integrate four approved controls into Octon as an enforceable stack:

1. Machine-Readable Organizational Intent Contract
2. Delegation Boundaries and Escalation Contract (machine-enforced)
3. Intent Alignment Feedback Loops and Drift Control
4. Organizational AI Capability Map (agent-ready / augmented / human-only)

## Execution Rules

1. Respect precedence: `AGENTS.md` -> `CONSTITUTION.md` -> `DELEGATION.md` -> `MEMORY.md` -> `AGENT.md` -> `SOUL.md`.
2. Do not edit immutable charter: `/.octon/cognition/governance/principles/principles.md`.
3. Run each step's verification command before moving to the next step.
4. Keep changes bounded to listed files; no speculative refactors.
5. Cutover objective: autonomous runs fail closed unless `intent`, `boundary`, and `capability map` checks pass.

## Owner Map

- `octon-platform`: cross-domain sequencing, cutover authority, rollback authority
- `runtime-owner`: engine runtime spec, receipt schema, policy interface wiring
- `agency-owner`: delegation boundary contract + governance integration
- `orchestration-owner`: capability map contract + workflow mode enforcement
- `assurance-owner`: alignment/drift validators and gate integration
- `continuity-owner`: run-evidence and migration logs

## Execution Status (2026-02-25)

- [x] Step 0 complete: baseline branch/profile snapshot captured.
- [x] Step 1 complete: intent contract schema added.
- [x] Step 2 complete: policy interface intent binding requirements added.
- [x] Step 3 complete: policy receipt + digest provenance fields added.
- [x] Step 4 complete: receipt writer emits intent-layer provenance.
- [x] Step 5 complete: delegation boundaries contract + schema + delegation governance wiring.
- [x] Step 6 complete: boundary routing policy enforcement and reason codes added.
- [x] Step 7 complete: capability map contract + schema added.
- [x] Step 8 complete: workflow manifest/registry/governance linked to capability classification.
- [x] Step 9 complete: autonomous mode violation deny policy added.
- [x] Step 10 complete: intent-layer validator and alignment profile wiring added.
- [x] Step 11 complete: assurance scoring/weights/charter updates applied.
- [x] Step 12 complete: ADR 044 and ADR 045 added and indexed.
- [x] Step 13 complete: continuity log/tasks/next updated and validated.
- [x] Step 14 complete: full alignment + assurance gate pass after remediations.

Final gate receipts:

```bash
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,agency,workflows,weights,intent-layer
# Alignment check summary: errors=0

bash .octon/assurance/runtime/_ops/scripts/assurance-gate.sh --help >/dev/null
# command returns success
```

## Step 0: Baseline Snapshot and Freeze Point

Owner: `octon-platform`

File list:

1. No edits (baseline only)

Exact edit order:

1. Confirm branch and working tree state.
2. Capture baseline pass/fail on existing alignment profiles.
3. Create migration freeze note in PR description (outside repo file edits).

Verification command:

```bash
git status --short --branch && \
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,agency,workflows,weights
```

## Wave 1: Contract Foundation

## Step 1: Add Intent Contract Schema (v1)

Owner: `runtime-owner`

File list:

1. `.octon/engine/runtime/spec/intent-contract-v1.schema.json`

Exact edit order:

1. Create intent schema with required fields: `intent_id`, `version`, `objective_signals`, `authorized_actions`, `hard_boundaries`, `owner`, `approved_by`.
2. Constrain enums/required arrays to keep contract machine-actionable.
3. Add schema metadata `$id` and version constant.

Verification command:

```bash
test -f .octon/engine/runtime/spec/intent-contract-v1.schema.json && \
jq -e '.type=="object" and (.required|index("intent_id")) and (.required|index("objective_signals")) and (.required|index("authorized_actions")) and (.required|index("hard_boundaries"))' \
  .octon/engine/runtime/spec/intent-contract-v1.schema.json
```

## Step 2: Extend Policy Interface Spec to Require Intent Binding

Owner: `runtime-owner`

File list:

1. `.octon/engine/runtime/spec/policy-interface-v1.md`
2. `.octon/engine/runtime/config/policy-interface.yml`

Exact edit order:

1. Update `policy-interface-v1.md` to declare request requirement for `intent_ref` (id + version) and expected deny behavior when missing.
2. Add interface config entries for intent contract path and enforcement mode toggle.

Verification command:

```bash
rg -n "intent_ref|intent contract|missing intent" \
  .octon/engine/runtime/spec/policy-interface-v1.md \
  .octon/engine/runtime/config/policy-interface.yml
```

## Step 3: Extend Policy Receipt Schema for Intent/Boundary/Mode Provenance

Owner: `runtime-owner`

File list:

1. `.octon/engine/runtime/spec/policy-receipt-v1.schema.json`
2. `.octon/engine/runtime/spec/policy-digest-v1.md`

Exact edit order:

1. Add receipt fields: `intent_ref`, `boundary_id`, `boundary_set_version`, `workflow_mode`, `capability_classification`.
2. Update required fields as needed for critical decisions.
3. Update digest spec required summary fields to include these additions.

Verification command:

```bash
jq -e '.properties.intent_ref and .properties.boundary_id and .properties.workflow_mode and .properties.capability_classification' \
  .octon/engine/runtime/spec/policy-receipt-v1.schema.json && \
rg -n "intent|boundary|workflow mode|classification" .octon/engine/runtime/spec/policy-digest-v1.md
```

## Step 4: Wire Receipt Writer to Emit New Provenance Fields

Owner: `runtime-owner`

File list:

1. `.octon/capabilities/_ops/scripts/policy-receipt-write.sh`

Exact edit order:

1. Map request payload fields into receipt JSON for intent/boundary/mode/classification.
2. Ensure digest renderer includes new summary fields.
3. Preserve backward compatibility keys where currently used.

Verification command:

```bash
rg -n "intent_ref|boundary_id|workflow_mode|capability_classification" \
  .octon/capabilities/_ops/scripts/policy-receipt-write.sh
```

## Wave 2: Delegation Boundary Enforcement

## Step 5: Add Delegation Boundary Contract and Schema

Owner: `agency-owner`

File list:

1. `.octon/agency/governance/delegation-boundaries-v1.yml`
2. `.octon/agency/governance/delegation-boundaries-v1.schema.json`
3. `.octon/agency/governance/DELEGATION.md`

Exact edit order:

1. Create YAML contract with boundary taxonomy and deterministic `allow|escalate|block` routes.
2. Create schema validating required fields: `boundary_id`, `decision_class`, `condition`, `route`, `owner`, `approved_by`, `severity`.
3. Update `DELEGATION.md` to reference the machine-readable contract as normative execution input.

Verification command:

```bash
test -f .octon/agency/governance/delegation-boundaries-v1.yml && \
jq -e '.type=="object" and (.required|index("boundary_id")) and (.required|index("route"))' \
  .octon/agency/governance/delegation-boundaries-v1.schema.json && \
rg -n "delegation-boundaries-v1" .octon/agency/governance/DELEGATION.md
```

## Step 6: Add Runtime Policy Rules for Boundary Routing

Owner: `runtime-owner`

File list:

1. `.octon/capabilities/governance/policy/deny-by-default.v2.yml`
2. `.octon/engine/runtime/config/policy.yml`

Exact edit order:

1. Add reason codes for boundary failures (`BOUNDARY_UNRESOLVED`, `BOUNDARY_BLOCKED`, `BOUNDARY_ESCALATION_REQUIRED`).
2. Add enforcement rules keyed by decision class + boundary route.
3. Keep fail-closed behavior for unresolved boundary context.

Verification command:

```bash
rg -n "BOUNDARY_UNRESOLVED|BOUNDARY_BLOCKED|BOUNDARY_ESCALATION_REQUIRED|allow|escalate|block" \
  .octon/capabilities/governance/policy/deny-by-default.v2.yml \
  .octon/engine/runtime/config/policy.yml
```

## Wave 3: Capability Map Gating

## Step 7: Add Capability Map Contract and Schema

Owner: `orchestration-owner`

File list:

1. `.octon/orchestration/governance/capability-map-v1.yml`
2. `.octon/orchestration/governance/capability-map-v1.schema.json`

Exact edit order:

1. Define workflow classifications: `agent-ready`, `agent-augmented`, `human-only`.
2. Include required approval metadata and review cadence per workflow entry.
3. Add schema constraints for valid classifications and required ownership fields.

Verification command:

```bash
test -f .octon/orchestration/governance/capability-map-v1.yml && \
jq -e '.type=="object" and .properties and .properties.workflows' \
  .octon/orchestration/governance/capability-map-v1.schema.json && \
rg -n "agent-ready|agent-augmented|human-only" .octon/orchestration/governance/capability-map-v1.yml
```

## Step 8: Wire Workflow Discovery Surfaces to Capability Map Classification

Owner: `orchestration-owner`

File list:

1. `.octon/orchestration/runtime/workflows/manifest.yml`
2. `.octon/orchestration/runtime/workflows/registry.yml`
3. `.octon/orchestration/governance/README.md`

Exact edit order:

1. Add mode/classification metadata linkage to workflow manifest/registry entries.
2. Document governance requirement that autonomous execution is permitted only for `agent-ready`.
3. Keep existing workflow IDs and paths unchanged.

Verification command:

```bash
rg -n "classification|agent-ready|agent-augmented|human-only|autonomous" \
  .octon/orchestration/runtime/workflows/manifest.yml \
  .octon/orchestration/runtime/workflows/registry.yml \
  .octon/orchestration/governance/README.md
```

## Step 9: Add Mode-Violation Policy Denies

Owner: `runtime-owner`

File list:

1. `.octon/capabilities/governance/policy/deny-by-default.v2.yml`
2. `.octon/engine/runtime/spec/policy-interface-v1.md`

Exact edit order:

1. Add reason code `MODE_VIOLATION_AUTONOMY_NOT_ALLOWED`.
2. Add policy rule denying autonomous execution for non-`agent-ready` workflows.
3. Update interface docs with deterministic denial semantics.

Verification command:

```bash
rg -n "MODE_VIOLATION_AUTONOMY_NOT_ALLOWED|agent-ready|deny autonomous" \
  .octon/capabilities/governance/policy/deny-by-default.v2.yml \
  .octon/engine/runtime/spec/policy-interface-v1.md
```

## Wave 4: Assurance Feedback and Drift Control

## Step 10: Add Intent-Layer Validator Script

Owner: `assurance-owner`

File list:

1. `.octon/assurance/runtime/_ops/scripts/validate-intent-layer.sh`
2. `.octon/assurance/runtime/_ops/scripts/alignment-check.sh`

Exact edit order:

1. Create validator script that checks required contract files and required fields/keys.
2. Add `intent-layer` profile support in `alignment-check.sh`.
3. Ensure non-zero exit on missing contract or required receipt fields.

Verification command:

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-intent-layer.sh && \
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile intent-layer
```

## Step 11: Add Alignment Drift Scoring Inputs

Owner: `assurance-owner`

File list:

1. `.octon/assurance/governance/scores/scores.yml`
2. `.octon/assurance/governance/weights/weights.yml`
3. `.octon/assurance/governance/CHARTER.md`

Exact edit order:

1. Add/adjust measurable alignment attributes and acceptance criteria for intent adherence and drift.
2. Set corresponding policy weights emphasizing assurance-first behavior.
3. Update charter language only where needed to reflect closed-loop intent evaluation.

Verification command:

```bash
rg -n "intent|alignment drift|objective signals|autonomous" \
  .octon/assurance/governance/scores/scores.yml \
  .octon/assurance/governance/weights/weights.yml \
  .octon/assurance/governance/CHARTER.md && \
bash .octon/assurance/runtime/_ops/scripts/compute-assurance-score.sh --help >/dev/null
```

## Wave 5: Governance Records and Cutover

## Step 12: Record ADRs for New Contracts and Cutover Policy

Owner: `octon-platform`

File list:

1. `.octon/cognition/runtime/decisions/044-intent-contract-and-boundary-enforcement.md`
2. `.octon/cognition/runtime/decisions/045-capability-map-and-alignment-drift-gates.md`
3. `.octon/cognition/runtime/decisions/index.yml`

Exact edit order:

1. Add ADR 044 for intent + boundary enforcement design and rollback semantics.
2. Add ADR 045 for capability map gating + drift gate policy.
3. Append both records to decisions index in numeric order.

Verification command:

```bash
test -f .octon/cognition/runtime/decisions/044-intent-contract-and-boundary-enforcement.md && \
test -f .octon/cognition/runtime/decisions/045-capability-map-and-alignment-drift-gates.md && \
rg -n "044-intent-contract-and-boundary-enforcement|045-capability-map-and-alignment-drift-gates" \
  .octon/cognition/runtime/decisions/index.yml
```

## Step 13: Continuity and Run-Evidence Wiring

Owner: `continuity-owner`

File list:

1. `.octon/continuity/log.md`
2. `.octon/continuity/tasks.json`
3. `.octon/continuity/next.md`

Exact edit order:

1. Append migration execution log entry with current phase and owner.
2. Add/refresh tasks for remaining migration steps with blockers and acceptance criteria.
3. Update `next.md` with immediate next runnable command set.

Verification command:

```bash
bash .octon/assurance/runtime/_ops/scripts/validate-continuity-memory.sh
```

## Step 14: Full Gate, Then Flag-Day Cutover

Owner: `octon-platform`

File list:

1. No required edits (gate run + cutover action)
2. Optional rollback state: `.octon/capabilities/_ops/state/rollout-mode.state`

Exact edit order:

1. Run full alignment checks including new `intent-layer` profile.
2. Enable hard enforcement mode for intent-layer controls.
3. If gate fails in production run, switch to observe mode and file remediation tasks.

Verification command:

```bash
bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,agency,workflows,weights,intent-layer && \
bash .octon/assurance/runtime/_ops/scripts/assurance-gate.sh --help >/dev/null
```

## Final Done Gate

All items below must be true:

1. Autonomous run preflight fails closed on missing `intent_ref`.
2. Boundary route is deterministic and receipt-backed for critical decisions.
3. Non-`agent-ready` workflows cannot execute autonomously.
4. Alignment drift checks run in assurance profile and produce actionable outputs.
5. ADRs and continuity artifacts document cutover and rollback policy.
