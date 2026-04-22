# Support Matrix Handle v1

This contract defines the runtime posture of the generated effective support
matrix.

## Current target posture

The support matrix is publication-only for runtime. It may narrow route-bundle
publication and validation, but it must not be consumed directly as runtime
authority by the resolver.

## Required properties

- explicit source ref to `instance/governance/support-targets.yml`
- explicit claim-effect data for supported tuples
- explicit non-authority posture
- explicit route-bundle publication dependency

## Forbidden use

- direct runtime authorization
- policy authority
- support widening beyond authored support targets and admissions
