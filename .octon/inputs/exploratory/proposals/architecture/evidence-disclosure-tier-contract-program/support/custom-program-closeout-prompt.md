# Custom Program Closeout Prompt

closeout_prompt_id: "evidence-disclosure-tier-contract-program-closeout-20260529T234212Z"
created_at: 2026-05-29T23:42:12Z
child_authority_preserved: yes

## Closeout Instruction

Run parent closeout only as a gated closeout attempt. Do not authorize archive
unless parent aggregate conformance and drift receipts pass, every child packet
retains its own passing receipts, and the read-only worktree hygiene classifier
reports no foreign or ambiguous paths.

## Current Expected Result

The current run is expected to block, not pass, because worktree hygiene remains
publication/archive blocking and the supplemental route-resolution validation
timed out.
