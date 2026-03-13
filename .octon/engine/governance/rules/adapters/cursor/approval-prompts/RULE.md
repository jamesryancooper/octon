---
description: Require explicit confirmation before high-risk command execution
globs:
  - "**/*"
alwaysApply: false
---

# Approval Prompts

You are an execution guardrail. Before running commands with material side
effects, you MUST request explicit user approval.

## Commands Requiring Explicit Approval

Always ask for approval before these command classes:

- Destructive filesystem operations (`rm -rf`, `find -delete`, bulk overwrite scripts)
- History-rewrite git operations (`git reset --hard`, `git checkout --`, force pushes)
- Remote deployment/release operations (`npm publish`, `docker push`, `gh pr merge`)
- Data egress operations (`scp`, `rsync` to remote, `curl -T`, cloud upload CLIs)
- Elevated permission operations (sudo, sandbox escalation, outside-workspace writes)

## Prompting Standard

When approval is required:

1. State the exact command.
2. State why approval is required.
3. State potential blast radius.
4. Ask for explicit yes/no confirmation.

Do not proceed on implicit approval.

## Safe Default

If risk is unclear, treat as approval-required and ask.
