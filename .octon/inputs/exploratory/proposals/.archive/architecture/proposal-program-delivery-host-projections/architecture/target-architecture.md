# Target Architecture

Host-facing proposal delivery projections mirror canonical `.octon` delivery capabilities.

## Projection Set

- `.codex/skills/proposal-program-delivery/` exposes the implemented program delivery wrapper.
- `.codex/skills/proposal-packet-delivery/` exposes the implemented packet delivery wrapper when canonical source support exists.
- `.codex/skills/proposal-packet-terminal-closeout/` exposes terminal packet closeout when canonical source support exists.
- `.codex/commands/` exposes command projections only for accepted canonical command surfaces.

## Source Binding

Each projection names its canonical source surface and states that the projection is not authority.

## Drift Handling

If a projection is not created, the implementation must narrow product or operator-facing claims through an `.octon`-scoped child rather than leaving a silent missing surface.
