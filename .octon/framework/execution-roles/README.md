# Execution Roles

Canonical execution-role model and governance boundary for the Octon harness.
Enable reliable execution that is deterministic enough to trust, observable
enough to debug, and flexible enough to evolve.

## Bounded Surfaces

| Type | Purpose | Index |
|------|---------|-------|
| `_meta/architecture/` | Execution-role subsystem architecture and specification docs | `_meta/architecture/README.md` |
| `runtime/` | Runtime execution-role artifacts | `runtime/README.md` |
| `governance/` | Supporting delegation and memory overlays beneath the orchestrator path | `governance/README.md` |
| `practices/` | Human and execution-role operating practices plus commit/PR standards | `practices/README.md` |

## Final Ontology

The canonical durable noun is `execution role`.

The only operator-facing role kinds are:

- `orchestrator`
- `specialist`
- `verifier`
- `composition profile`

Rejected as canonical Octon ontology:

- `agent`
- `assistant`
- `team`
- `actor`
- durable `subagent`
- `persona`
- identity-file authority

`subagent` survives only as runtime or external terminology for a delegated
specialist invocation context.

## Discovery

Read in this order:

1. `registry.yml` for the canonical execution-role inventory
2. `runtime/orchestrator/ROLE.md` for the default accountable execution role
3. `governance/DELEGATION.md` when delegation or supervision boundaries matter
4. `governance/MEMORY.md` when continuity, context, or evidence ownership matters
5. `runtime/specialists/registry.yml` for bounded specialist routing
6. `runtime/verifiers/registry.yml` for independent verification roles
7. `runtime/composition-profiles/registry.yml` for reusable non-executing handoff profiles

## Runtime Model

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

Consequential execution remains run-first. A mission is a continuity and
autonomy container, not the atomic execution unit. Workflows survive only where
they add governance, evidence, authorization, recovery, publication, or
support-proof value.

## Kernel Path

The execution-role kernel path is fixed:

`framework/constitution/**` -> `instance/ingress/AGENTS.md` -> `runtime/orchestrator/ROLE.md`

Governance overlays are supporting contracts, not required constitutional
layers.
