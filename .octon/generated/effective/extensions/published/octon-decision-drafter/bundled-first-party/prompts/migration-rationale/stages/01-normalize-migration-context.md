# Normalize Migration Context

Normalize the migration target and grounding inputs.

## Do

1. Confirm that exactly one diff source is present.
2. Normalize `changed_paths`.
3. Resolve `migration_plan_ref` or `proposal_packet_ref` when present.
4. Collect retained evidence refs relevant to rollout, compatibility,
   validation, or publication posture.
5. Record the narrative target surface if the operator supplied one.

## Stop When

- the diff source is missing or ambiguous
- the request would require automatic edits to migration indexes or retained
  evidence bundles
