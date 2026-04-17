# Migration / Cutover Plan

## Overall posture

This is an **additive same-root refinement**, not a topology migration.

The repo already has:

- PR-first protection on `main`
- branch worktree helpers
- draft-first PR creation
- required GitHub merge gates

The cutover is therefore about aligning ingress, docs, skills, and helper
semantics around the workflow the repo already mostly implements.

## Safe rollout sequence

1. **Packet and manifest first**
   - land the packet
   - accept the target state and scope boundaries

2. **Ingress contract and durable prose**
   - add `branch_closeout_gate`
   - update ingress `AGENTS.md`
   - update playbook and overview docs

3. **Review-semantics alignment**
   - update PR standards
   - update remediation skill
   - update companion PR-template wording in the same branch

4. **Helper clarification and housekeeping**
   - clarify `git-pr-ship.sh`
   - document or implement worktree-directory cleanup

5. **Scenario validation**
   - verify each closeout context
   - verify manual and autonomous lanes
   - verify blocked states suppress misleading prompts

## No-migration rationale

- no new top-level authored root is created
- no support-target declaration changes
- no GitHub ruleset replacement
- no dual workflow regime is required once the branch lands

## Compatibility posture

To avoid breaking older adapters immediately:

- keep `branch_closeout_prompt` as a deprecated fallback if needed
- treat `branch_closeout_gate` as canonical when present

This preserves backward compatibility while establishing the better contract.

## Rollback / reversal

If the refinement proves incorrect or too disruptive:

1. revert ingress, practice-doc, skill, and helper changes in one change set
2. keep historical proposal artifacts and retained review evidence
3. keep the older fallback scalar prompt if it was retained for compatibility
4. reopen the packet only after the failure mode is understood

## What must survive rollback

- GitHub as the final merge gate
- `main` as PR-first
- branch worktrees as the preferred implementation unit
- the rule against author-side resolution of reviewer-owned threads
- this packet's non-authoritative historical lineage
