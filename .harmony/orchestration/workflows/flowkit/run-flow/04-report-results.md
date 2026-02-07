---
title: Report Results
description: Summarize output and provide LangGraph Studio instructions.
---

# Step 4: Report Results

## Action

Craft a response with two sections:

### Section 1: Flow Result

Summarize the execution:

- Success or failure status
- Config path used
- Flow ID and display name
- Notable output highlights
- Links to any artifacts reported by the CLI

### Section 2: LangGraph Studio Instructions

Provide instructions to launch Studio for the same flow (do NOT launch automatically):

```bash
FLOWKIT_STUDIO_WORKFLOW_MANIFEST=<workflowManifestPath>
FLOWKIT_STUDIO_WORKFLOW_ENTRYPOINT=<workflowEntrypoint>
FLOWKIT_STUDIO_WORKSPACE_ROOT=<workspaceRoot-or-repo-root>
langgraph dev --config langgraph.json
```

**Notes to include:**

- Only include `FLOWKIT_STUDIO_WORKSPACE_ROOT` if the config defines `workspaceRoot`; otherwise remind user to run from repo root
- Mention that `langgraph.json` must contain an entry for this flow, or set the env vars above
- Do NOT launch Studio automatically—share instructions for user to copy/paste

## Final Note

Remind the user:

> `/run-flow` derives instructions from the selected `.flow.json`. Multiple flows are supported as long as each ships a config and (optionally) a LangGraph Studio entry.

## Output Format

```markdown
## Flow Result

**Status:** [Success/Failure]
**Config:** `<config-path>`
**Flow:** `<id>` — `<displayName>`

[Summary of output and any artifacts]

## LangGraph Studio

To launch Studio for this flow:

\`\`\`bash
FLOWKIT_STUDIO_WORKFLOW_MANIFEST=<workflowManifestPath>
FLOWKIT_STUDIO_WORKFLOW_ENTRYPOINT=<workflowEntrypoint>
langgraph dev --config langgraph.json
\`\`\`

[Additional notes about langgraph.json configuration]
```

## Workflow Complete

This workflow is complete. Return results to user.

