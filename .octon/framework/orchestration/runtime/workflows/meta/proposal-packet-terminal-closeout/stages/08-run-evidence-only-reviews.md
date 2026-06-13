---
title: Run Evidence-Only Reviews
description: Run post-integration architecture review and terminal evaluator hooks without granting authority.
---

# Step 8: Run Evidence-Only Reviews

## Consumed Evidence

- Conformance and drift/churn pass evidence.
- Hygiene classification evidence.

## Produced Evidence

- Post-integration architecture review evidence when applicable.
- Packet terminal evaluator or lifecycle-postmortem evidence when required.
- State ledger entry `run-evidence-only-reviews`.

## Actions

1. Run post-integration architecture review after conformance and drift pass
   when the packet is an architecture packet or the profile requires it.
2. Run the packet terminal evaluator or lifecycle-postmortem hook when the
   terminal run is blocked, nonterminal, cancelled, rollback, or repeated
   retry.
3. Record both outputs as evidence-only.
4. Block if either output is used as closeout, archive, publication, cleanup,
   branch, promotion, or terminal verdict authority.

## Side Effect Class

Evidence-only review and retained evidence write.

## Re-Entry Condition

Re-enter when review evidence changes or terminal run state changes to blocked,
nonterminal, cancelled, rollback, or repeated retry.

## Stop Condition

Stop with `blocked` when evidence-only outputs are overclaimed.

## Receipt Fields

- `evidence_only_reviews.post_integration_architecture_review_ref`
- `evidence_only_reviews.post_integration_architecture_review_authority`
- `evidence_only_reviews.packet_terminal_evaluator_ref`
- `evidence_only_reviews.packet_terminal_evaluator_authority`
- `evidence_only_reviews.lifecycle_postmortem_ref`
- `evidence_only_reviews.lifecycle_postmortem_authority`
- `state_ledger[].state_id: run-evidence-only-reviews`
