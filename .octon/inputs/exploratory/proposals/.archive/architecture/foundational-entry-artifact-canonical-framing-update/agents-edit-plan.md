# AGENTS Edit Plan

_Status: In-review proposal packet artifact_


## Objective

Update agent-facing adapter wording without adding runtime or policy text in violation of existing adapter constraints.

## Current issue

Root `AGENTS.md` and `.octon/AGENTS.md` currently say:

> Enable reliable agent execution that is deterministic enough to trust...

This is close, but still agent-first. Root `AGENTS.md` is linked repo-local
companion scope for this packet; `.octon/AGENTS.md` remains the active
octon-internal target.

## Proposed wording

```markdown
Enable reliable workflow participation by bounded agents inside Octon-governed execution boundaries. Workflow state owns control flow. Agents do not.
```

## Required preservation

- Preserve pointer to `/.octon/instance/ingress/AGENTS.md`.
- Preserve parity rule.
- Do not add detailed runtime policy in adapter files.
- Keep agent-facing language terse.

## Validation

- Byte-for-byte parity or symlink parity between root `AGENTS.md` and
  `.octon/AGENTS.md` must be restored through the linked repo-local companion
  path before durable root adapter changes land.
- No new policy text beyond framing/boundary sentence.
