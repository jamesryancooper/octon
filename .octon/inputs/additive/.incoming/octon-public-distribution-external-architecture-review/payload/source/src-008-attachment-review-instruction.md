---
source_id: SRC-008
source_type: conversation-turn
sequence: 8
supplied_at: "2026-06-26T19:09:00.000Z"
turn_id: "019f0555-db4d-70b0-a144-2cb17ac4f068"
capture_status: complete
disclosure_status: local-only
authority_mode: non-authoritative
---

# SRC-008: Conversation attachment review instruction

## User Message

Add a section that explains that I will be providing each conversation as an attachment to be reviewed.


## Assistant Message 1 (final_answer)

Add this section after `Context` or before `Important files/surfaces to inspect`:

```text
Conversation Attachments:
I will provide prior conversations as attachments. Treat those attachments as review inputs and planning context, not as unquestioned authority.

For each attached conversation:
- Read it for explored findings, assumptions, decisions, risks, and unresolved questions.
- Distinguish confirmed repository evidence from conversational conclusions or recommendations.
- Carry forward useful decisions only when they remain consistent with repository evidence and the target public distribution model.
- Do not quote sensitive content from attachments unless necessary; summarize and redact where appropriate.
- If an attachment conflicts with repository evidence, prefer repository evidence and call out the conflict.
- If attachments conflict with each other, identify the conflict and recommend a resolution.
- Use the attachments to avoid redoing prior exploration unnecessarily, but independently verify any implementation-critical claim before relying on it.
```

You can insert it into the prompt like this:

```text
Context:
Octon currently lives in a full local development/workspace repository...
[existing context]

Conversation Attachments:
I will provide prior conversations as attachments. Treat those attachments as review inputs and planning context, not as unquestioned authority.

For each attached conversation:
- Read it for explored findings, assumptions, decisions, risks, and unresolved questions.
- Distinguish confirmed repository evidence from conversational conclusions or recommendations.
- Carry forward useful decisions only when they remain consistent with repository evidence and the target public distribution model.
- Do not quote sensitive content from attachments unless necessary; summarize and redact where appropriate.
- If an attachment conflicts with repository evidence, prefer repository evidence and call out the conflict.
- If attachments conflict with each other, identify the conflict and recommend a resolution.
- Use the attachments to avoid redoing prior exploration unnecessarily, but independently verify any implementation-critical claim before relying on it.

Important files/surfaces to inspect:
...
```

