# Decision Record Plan

## ADR to add

| ADR | Purpose |
|---|---|
| `091-execution-role-hard-cutover.md` | Records the hard-cut replacement of agency ontology with execution roles. |

## ADR content

The ADR must include:

- context: frontier-governance target state;
- decision: execution role replaces agent/assistant/team/actor;
- deletions: `framework/agency/**`, durable subagents, persona authority;
- new roots: `framework/execution-roles/**`;
- execution hierarchy: objective -> mission -> run-contract -> workflow instance -> stage-attempt;
- proof obligations: context packs, support tuples, rollback, evidence;
- rejected alternatives: compatibility bridge, dual ontology, actor umbrella.

## ADR index

Update `/.octon/instance/cognition/decisions/index.yml` to include ADR 091.

## Closure

The ADR is authoritative rationale only after promotion. It must not point to this proposal as a live dependency.
