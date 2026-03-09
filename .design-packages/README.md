# Design Packages

`/.design-packages/` is a temporary workspace for implementation-oriented design
material.

## Non-Canonical Rule

Design packages are implementation aids. They are not canonical runtime,
documentation, policy, or contract authorities.

Implications:

- design packages may be archived or removed after implementation lands
- implementation outputs must point to long-lived `/.harmony/` or repo-native
  authority surfaces, not back to the design package as a source of truth
- generated workflow reports, blueprints, plans, and summaries must not claim
  that the design package is authoritative or canonical

## Authoring Rules

When creating or updating a design package:

- state clearly that the package is temporary and implementation-scoped
- describe the package as an aid, input, draft, or working design material
- avoid phrases such as `canonical`, `authoritative architecture specification`,
  or `source of truth` when referring to the design package itself
- if downstream artifacts need canonical authority, point them to the intended
  runtime or documentation surface that will survive package removal

## Lifecycle Expectation

Each design package should make its exit path obvious:

- implementation target surfaces
- archive or removal expectation after implementation
- any temporary assumptions that must be resolved before the package is retired
