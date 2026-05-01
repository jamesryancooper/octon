# Manual Prompt Mapping

## Mapping Table

| Manual prompt | Automation route | Required preserved behavior |
| --- | --- | --- |
| `audit_aligned_proposal_packet_creation` | `create-proposal-packet` with `audit-aligned-packet` scenario | Include audit in `resources/**`; map every finding to remediation, acceptance criteria, and closure proof. |
| `concise_proposal_packet_creation` | `create-proposal-packet` with source-to-architecture fallback | Produce a complete packet from compact user input without dropping required artifacts. |
| `architectural_evaluation_proposal_packet_creation` | `create-proposal-packet` with `architecture-evaluation-packet` scenario | Preserve evaluation, gap-to-target analysis, implementation plan, validation plan, and closure readiness. |
| `highest_leverage_next_step_proposal_packet_creation` | `create-proposal-packet` with `highest-leverage-next-step-packet` scenario | Select one repo-grounded highest-leverage step and prevent scope expansion. |
| `proposal_packet_closeout` | `generate-closeout-prompt` and `closeout-proposal-packet` | Archive packet, housekeep, stage intended changes, commit, PR, fix checks, resolve reviews, merge, cleanup branches, sync. |
| `executable_implementation_prompt` | `generate-implementation-prompt` | Produce a packet-specific executable prompt that implements the packet and handles blockers without weakening target state. |
| `evaluation_prompt` | `create-proposal-packet` preflight or `explain-proposal-packet` support | Re-ground evaluation prompts against current architecture before reuse. |
| `explain_proposal_packet` | `explain-proposal-packet` | Explain problem, target state, durable outcome, changed surfaces, improvement, and follow-on work without widening scope. |
| `create_follow_up_verification` | `generate-verification-prompt` | Create packet-specific verification prompt for complete implementation or migration verification. |
| `proposal_program_pattern` | `create-proposal-program` and program lifecycle routes | Create a parent packet that coordinates canonical child proposal packets without nesting them, with aggregate implementation, verification, correction, and closeout. |

## Improvements Over Manual Prompts

- Replace hard-coded current thesis with a live-repo-derived framing contract.
- Replace one-off closeout instructions with a reusable route and safety gates.
- Replace broad "do not stop" language with bounded execution, evidence, and fail-closed blocker handling.
- Add stable finding IDs and correction prompt placement.
- Require extension publication and host projection validation.
- Add parent proposal programs for multi-packet initiatives while preserving
  child packet authority and canonical placement.
- Preserve proposal non-authority throughout all generated prompts.

## Guidance Variants

`resources/manual-prompt-variant-guidance.md` contains normalized, guidance-only
variants of each manual prompt class. The variants are intended to seed
scenario fixtures, bundle-stage examples, route companion prompts, and
validation expectations. They must not be treated as canonical prompt text or
proposal authority.
