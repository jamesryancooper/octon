---
title: Integrate Architecture Guidance
description: Add contract-complete metadata, recovery guidance, and explicit verification.
---

# Step 6: Integrate Architecture Guidance

## Input

- Customized workflow files from Step 5
- Requirements from Step 2
- Template selection from Step 3

## Purpose

Ensure the new workflow is structurally complete, uses the right abstraction
boundary, and documents how side effects are verified and recovered.

## Actions

### 6.1 Complete the Canonical Contract in `workflow.yml`

Ensure `workflow.yml`, not an overview companion, carries the execution
metadata:

```yaml
version: "1.0.0"
entry_mode: "human"
execution_profile: "core"
side_effect_class: "read_only"
execution_controls:
  cancel_safe: true
coordination_key_strategy:
  kind: "none"
executor_interface_version: "workflow-executor-v1"
artifacts: []
done_gate:
  checks:
    - "verification stage passes"
constraints:
  fail_closed: true
  forbid_design_packages: true
  require_relative_local_assets: true
```

### 6.2 Keep the Workflow Boundary Honest

Reflect the Step 2 boundary decision in the workflow shape:

- If orchestration value is thin or purely single-capability, stop and collapse
  the design into a skill, command, or narrower surface instead of inflating a
  workflow.
- Keep stage count and stage responsibilities aligned with one clear reason to
  change.
- Do not invent placeholder dependency or parallel metadata when no real
  orchestration need exists.

### 6.3 Add Idempotency and Recovery Guidance to Stage Assets

For mutating or long-running stages, ensure `## Idempotency` exists with:

```markdown
## Idempotency

**Check:** [Specific signal that the stage is already complete]
- [ ] [Completion condition]

**If Already Complete:**
- [Skip or resume guidance]

**Marker:** `checkpoints/<workflow-id>/<stage>.complete`
```

If the workflow is side-effectful, add restart, rollback, or cleanup guidance
to the relevant stage assets so partial execution is recoverable.

### 6.4 Keep Dependencies in the Right Surface

- Workflow-to-workflow dependencies belong in registry metadata and reference
  updates, not ad hoc frontmatter or compatibility files.
- Keep dependency fan-out small and acyclic.
- Do not encode canonical behavior in `guide/` or root `00-overview.md`
  layouts.

### 6.5 Require Terminal Verification for Side Effects

If `side_effect_class` is `mutating` or `destructive`:

- The final stage kind must be `verification`
- The done gate must align with that terminal verification stage
- The generated README must describe the verification gate clearly

## Idempotency

**Check:** Is the workflow architecture guidance already integrated?
- [ ] `workflow.yml` carries contract-complete execution metadata
- [ ] Side-effectful workflows end in a verification stage
- [ ] Relevant mutation or long-running stages have `## Idempotency`
- [ ] No canonical authoring surface points to `guide/` or root `00-overview.md`

**If Already Complete:**
- Verify the contract and stage assets still match the current requirements
- Skip to the next step if no architecture gaps remain
- Resume remediation only for the missing items

**Marker:** `checkpoints/create-workflow/<workflow-id>/06-gaps.complete`

## Gap Fix Verification Checklist

Before proceeding, confirm:

- [ ] `workflow.yml` declares the required execution metadata
- [ ] Stage responsibilities still match the workflow boundary decision
- [ ] Side-effectful workflows terminate in verification
- [ ] Relevant mutation or long-running stages have idempotency guidance
- [ ] No deprecated `guide/` or root `00-overview.md` authoring layout is introduced

## Output

- Contract-complete `workflow.yml`
- Stage assets with recovery and idempotency guidance where needed
- Verified workflow boundary and terminal verification shape

## Proceed When

- [ ] All items in Gap Fix Verification Checklist pass
- [ ] No architecture guidance gaps remain
