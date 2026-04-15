# Current-State Observations

## Repo-Grounded Facts Used For This Packet

1. The concept-integration prompt set is now pack-local under
   `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/octon-concept-integration-pipeline/`.
2. The skill exposes `alignment_mode` with default `auto`, but the current
   contract does not bind execution to a retained freshness receipt.
3. The prompt-set alignment companion already exists and is pack-local.
4. The prompt-set README still frames the alignment prompt as a companion,
   which is the correct conceptual role.
5. The extension effective family already publishes command and skill
   `routing_exports`.
6. The native prompt modeling service already exists as a fail-closed harness
   service with deterministic compilation behavior.
7. Proposal-registry generation remains blocked by unrelated active proposal
   debt elsewhere in the repository, so packet validation may need
   `--skip-registry-check` until that debt is cleared.

## Design Consequence

The preferred fix should reuse Octon's existing authored/generated/evidence
split rather than leaving prompt freshness as a convention inside the skill
alone.
