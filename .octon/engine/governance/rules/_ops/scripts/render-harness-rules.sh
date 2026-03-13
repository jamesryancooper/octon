#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROFILE_ID="${1:-}"

if [[ -z "$PROFILE_ID" ]]; then
  echo "Usage: $0 <profile-id>"
  echo "Supported profile ids: approval-prompts"
  exit 1
fi

if [[ "$PROFILE_ID" != "approval-prompts" ]]; then
  echo "Unsupported profile id: $PROFILE_ID"
  echo "Supported profile ids: approval-prompts"
  exit 1
fi

if [[ ! -f "$RULES_DIR/profiles/approval-prompts.yml" ]]; then
  echo "Missing profile file: $RULES_DIR/profiles/approval-prompts.yml" >&2
  exit 1
fi

cat > "$RULES_DIR/adapters/codex/approval-prompts.rules" <<'RULES'
# Approval prompt rules for Codex execpolicy.
# Canonical profile: .octon/engine/governance/rules/profiles/approval-prompts.yml

prefix_rule(
    pattern = ["rm", "-rf"],
    decision = "prompt",
    justification = "Destructive filesystem deletion requires explicit approval.",
    match = ["rm -rf build", "rm -rf .cache"],
    not_match = ["rm -f file.txt"],
)

prefix_rule(
    pattern = ["git", "reset", "--hard"],
    decision = "forbidden",
    justification = "History-rewrite is blocked; use non-destructive alternatives unless explicitly reconfigured.",
    match = ["git reset --hard", "git reset --hard HEAD~1"],
)

prefix_rule(
    pattern = ["gh", "pr", "merge"],
    decision = "prompt",
    justification = "Remote merge actions require explicit approval.",
    match = ["gh pr merge 123", "gh pr merge 123 --auto"],
)

prefix_rule(
    pattern = ["npm", "publish"],
    decision = "prompt",
    justification = "Publishing artifacts is an external side effect and requires approval.",
    match = ["npm publish"],
)

prefix_rule(
    pattern = ["docker", "push"],
    decision = "prompt",
    justification = "Pushing container images is an external side effect and requires approval.",
    match = ["docker push ghcr.io/org/app:latest"],
)
RULES

cat > "$RULES_DIR/adapters/cursor/approval-prompts/RULE.md" <<'RULEMD'
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
RULEMD

echo "Rendered adapters for profile: $PROFILE_ID"
