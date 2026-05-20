# Bundle Contract

- input types:
  changed paths, Git diff refs, or an existing `octon-drift-triage` packet
- output type:
  non-authoritative remediation report under
  `/.octon/inputs/exploratory/reports/**`
- default mode:
  `select`
- optional execution mode:
  `run`

## Required Behavior

- Normalize inputs before selecting checks.
- Use the pack-authored routing and ranking sources of truth under
  `context/check-routing.yml` and `context/ranking-model.yml`.
- In `mode=select`, do not run direct checks.
- In `mode=run`, run only the selected read-only checks plus conditional
  `repo-hygiene.sh scan`.
- Emit the packet even when one or more direct checks fail.

## Forbidden Behavior

- no dispatcher or reroute behavior in v1
- no patch application
- no publication or republish from within the bundle
- no writes to `state/control/**`
- no `repo-hygiene enforce`, `audit`, or `packetize`
