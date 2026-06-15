---
name: fixture-retention-closeout
description: Evidence-only closeout route for retaining temporary proposal fixtures as validation residue under an exact digest-bound receipt contract.
license: MIT
compatibility: Designed for Octon-aware AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-06-14"
  updated: "2026-06-14"
skill_sets: [executor, guardian]
capabilities: [safety-bounded, self-validating]
allowed-tools: Read Glob Grep Bash(git status *) Bash(bash .octon/framework/assurance/runtime/_ops/scripts/validate-fixture-retention-closeout-*) Bash(cargo run *)
---

# Fixture Retention Closeout

Use this skill when a temporary implemented proposal packet was created as validation evidence and must remain as intentional nonblocking residue for unrelated terminal/worktree hygiene checks.

## Contract

- Route through `.octon/framework/orchestration/runtime/workflows/meta/fixture-retention-closeout/workflow.yml`.
- Derive fixture identity from `fixture_path/proposal.yml` fields and current repo state.
- Require source evidence refs proving the fixture was used.
- Emit `fixture-retention-closeout-receipt-v1` under the workflow evidence bundle.
- Treat generated artifact refs as derived-only non-authority.
- Do not archive, mutate proposal status, edit generated publication, mutate Git, delete residue, or grant repo-hygiene deletion authority.
- Do not claim archive-ready or cleaned from this route.

## Validation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-fixture-retention-closeout-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-fixture-retention-closeout-receipt.sh --receipt <receipt>
```
