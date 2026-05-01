# Follow-Up Verification Prompt

Verify complete implementation of the proposal packet at:

`.octon/inputs/exploratory/proposals/architecture/octon-proposal-packet-lifecycle-automation/`

## Verification Steps

1. Inspect the live repository.
2. Confirm the `octon-proposal-packet-lifecycle` extension pack exists and
   contains all required route families.
3. Confirm the pack follows the recommended scaffold from
   `architecture/target-architecture.md`, or documents a justified alternate
   structure with equivalent lifecycle coverage.
4. Confirm shared contracts cover repository grounding, proposal authority,
   support artifact placement, evidence, verification, correction, and closeout.
5. Confirm commands and skills exist for the composite route and all leaf routes.
6. Confirm the Proposal Program pattern exists as durable extension-pack
   context and is exposed through creation, implementation, verification,
   correction, convergence, closeout-prompt, and closeout routes.
7. Confirm program validation rejects nested child proposal packet directories
   and preserves child manifest, validation, acceptance, and promotion-target
   authority.
8. Confirm validation scenarios map every manual prompt class to an automated route.
9. Confirm manual prompt variant guidance was used only as non-authoritative
   fixture or bundle-design input.
10. Confirm instance extension selection and generated effective extension
   outputs are coherent.
11. Confirm capability routing and host projections expose the routes.
12. Run proposal, extension, capability, host projection, and pack-local
   validation commands.
13. Check that generated prompts remain support artifacts and do not claim
   authority.
14. Emit findings with stable IDs, severity, affected paths, evidence,
    required correction, and acceptance criteria.

## Output

Return one of:

- `clean`
- `findings-require-correction`
- `blocked`
- `needs-packet-revision`

For every finding, include a correction prompt recommendation suitable for
materialization under `support/correction-prompts/`.
