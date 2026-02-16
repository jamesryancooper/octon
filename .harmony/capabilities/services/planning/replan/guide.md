# Replan Guide

Use this service when a plan must adapt to partial failure, missing dependencies,
or runtime context changes.

- `command`: `replan`
- `planPath` or `plan`: source plan artifact
- `blockedSteps`: list of step IDs to skip for this replanning cycle
- `allowMissingDependencies`: include steps with dangling deps by converting them to new roots

Output order and delta entries are deterministic.
