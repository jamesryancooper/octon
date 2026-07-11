---
disclosure_status: local-only
authority_mode: non-authoritative
---

# Source Limitations

1. The thread discusses providing prior conversations as attachments, but the
   user-visible thread contains no non-text attachments or attachment files.
2. The inline thread itself contains the relevant prior prompts, decisions, and
   assistant responses, and those are captured as `SRC-001` through
   `SRC-019`.
3. `SRC-019` is the current intake request. Its assistant response was still
   in progress at capture time and is intentionally omitted.
4. Hidden system and developer instructions, injected environment context,
   private reasoning, tool calls, tool output, and unrelated repository content
   are excluded by design.
5. Source timestamps come from Codex turn metadata and are recorded to
   whole-second precision.
6. No statement in the source layer is reconciled, corrected, or promoted.
   Contradictions are resolved only in the separately labeled review layer.
7. Existing proposal resources are referenced as current planning evidence but
   are not copied into the source layer or treated as accepted authority.
8. The package has not been approved for external disclosure.

