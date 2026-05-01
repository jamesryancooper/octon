# Routing Guide

Use the composite route when the user provides a lifecycle action, packet path,
source material, verification finding, or program packet. The dispatcher
prefers explicit `bundle` values, then `lifecycle_action`, then falls back to
packet creation for source-driven inputs.

## Primary Inputs

- `bundle`: explicit route id override.
- `lifecycle_action`: desired lifecycle operation.
- `packet_path`: active or archived proposal packet path.
- `source_kind`: source class such as `audit`, `architecture-evaluation`, or
  `requirements`.
- `verification_finding_id`: stable finding id for correction generation.
- `program_packet_path`: parent proposal program packet path.
- `child_packet_paths`: canonical child proposal packet paths.

## Fail-Closed Rules

- Unsupported explicit route ids deny.
- Missing routeable inputs escalate.
- Ambiguous lifecycle states escalate to packet revision or operator decision.
- Program routes reject nested child proposal package directories.
- Closeout routes refuse failing checks, unresolved reviews, or missing archive
  and evidence posture.
