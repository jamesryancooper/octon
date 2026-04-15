# Packet Refresh And Supersession: Re-Ground And Detect Drift

Re-ground the existing packet against the live repository.

## Shared Contracts

- inspect the base repo anchors declared in this bundle `manifest.yml`
- apply `../../shared/repository-grounding.md`

## Output

Record packet-time drift, already-landed work, stale assumptions, and whether
the existing packet can be refreshed in place or now requires supersession.
