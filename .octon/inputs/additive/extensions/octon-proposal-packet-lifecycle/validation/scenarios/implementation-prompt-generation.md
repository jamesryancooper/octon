# Implementation Prompt Generation

## Target Kind

`generate-implementation-prompt`

## Expected Behavior

The route generates `support/executable-implementation-prompt.md` from the
packet's live manifests, promotion targets, validation plan, and acceptance
criteria. The prompt must be executable enough for direct implementation,
including target end state, scope boundaries, workstreams, generated/runtime
publication needs, validation commands, retained evidence, rollback posture,
terminal criteria, and optional delegated work only when explicitly authorized
and scope-bounded.
