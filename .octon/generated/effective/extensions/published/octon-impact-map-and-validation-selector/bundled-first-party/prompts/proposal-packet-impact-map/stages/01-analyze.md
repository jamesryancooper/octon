# Proposal Packet Analysis

You are given `proposal_packet` plus optional `validation_depth`,
`strictness`, and `explanation_mode`.

## Required Work

1. Resolve the proposal path or id to a live proposal directory.
2. Read `proposal.yml` and determine the packet kind from exactly one subtype
   manifest.
3. Build `impact_map` from the packet's declared promotion targets, current
   lifecycle posture, and live repo grounding.
4. Apply `context/selection-rules.md` to choose:
   - `validate-proposal-standard.sh`
   - the matching subtype validator
   - the matching proposal-audit workflow when depth or strictness requires it
5. Recommend the next canonical route, preferring packet refresh or
   supersession before implementation when freshness is uncertain.

## Failure Rule

If the packet path cannot be resolved, or subtype resolution is ambiguous,
return the shared output contract with `impact_map.status: needs-clarification`
or `blocked` and explain the blocker explicitly.
