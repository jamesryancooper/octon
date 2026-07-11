---
source_id: SRC-013
source_type: conversation-turn
sequence: 13
supplied_at: "2026-07-09T19:44:19.000Z"
turn_id: "019f4868-dbed-7d13-91a1-c1abcded5f97"
capture_status: complete
disclosure_status: local-only
authority_mode: non-authoritative
---

# SRC-013: Generated mirror explanation

## User Message

Explain the generated mirror model in concise, plain language.



## Assistant Message 1 (final_answer)

A **generated mirror** is a public repository built automatically from an approved subset of a separate private workspace.

- The private workspace is where Octon is developed.
- An export process selects only publication-approved framework files and neutral templates.
- It rejects project-specific inputs, authority, state, evidence, generated outputs, host projections, and other private material.
- The validated export is pushed into the public repository as a clean distribution.
- The public repository does not share the private workspace’s Git history.
- Changes are not made directly in the public repository. They are made in the private workspace, reviewed, and exported again.

In short:

```text
Private workspace -> validate and filter -> public generated mirror
```

The public repository contains only what users need to install Octon, not the full environment used to develop it.

