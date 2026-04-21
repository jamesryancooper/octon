# Octon Execution Role Hard Cutover

This proposal packet defines a single big-bang hard cutover from Octon's current
legacy agency subsystem to the final frontier-governance execution-role subsystem.

The packet is non-canonical. It lives under
`/.octon/inputs/exploratory/proposals/architecture/octon-execution-role-hard-cutover/`
and must not be consumed by runtime or policy. Its promotion targets are durable
`.octon/**` authority, runtime, governance, proof, and validation surfaces.

## Controlling decision

Octon is not an agent framework. It is a governed execution harness for
consequential frontier-model work.

The final agency-facing model is:

```text
objective
  -> mission
    -> run-contract
      -> workflow instance
        -> stage-attempt

execution roles:
  orchestrator
  specialist
  verifier
  composition profile
```

`execution role` is the canonical durable noun. `agent`, `assistant`, `team`,
`actor`, `persona`, and durable `subagent` are rejected as canonical Octon
ontology.

## Hard-cut stance

This packet does not preserve compatibility paths. It removes the legacy agency
subsystem and promotes `framework/execution-roles/**` as the only canonical
execution-role surface.

## Reading order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/target-architecture.md`
5. `architecture/final-execution-role-system-specification.md`
6. `architecture/file-change-map.md`
7. `architecture/implementation-plan.md`
8. `architecture/validation-plan.md`
9. `architecture/acceptance-criteria.md`
10. `resources/repository-baseline-audit.md`

## Non-authority notice

This packet cannot authorize, approve, execute, publish, or override any runtime
decision. Promotion must land in declared targets outside the proposal workspace.
