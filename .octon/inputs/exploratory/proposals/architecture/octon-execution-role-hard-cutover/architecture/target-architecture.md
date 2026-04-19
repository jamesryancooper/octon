# Target Architecture

## Executive architecture

Octon's final agency-facing subsystem is an **execution-role subsystem**, not an
agent system.

The final model is:

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

`run-contract` is the atomic consequential execution unit. `mission` is a
continuity and autonomy container. `workflow` survives only where it creates
governance, evidence, authorization, recovery, publication, or support-proof
value.

## Constitutional alignment

This target preserves the live constitutional core:

- five-class `.octon/` super-root
- authored authority only in `framework/**` and `instance/**`
- `state/control/**` as mutable operational truth
- `state/continuity/**` as resumable work state
- `state/evidence/**` as retained proof
- `generated/**` as derived-only
- `inputs/**` as non-authoritative
- explicit authority routing before material side effects
- one accountable orchestrator by default
- mission-backed long-horizon autonomy
- support claims bounded by admitted finite tuples

## Execution-role subsystem

The target repository surface is:

```text
.octon/framework/execution-roles/
  README.md
  _meta/architecture/specification.md
  registry.yml
  governance/
    DELEGATION.md
    MEMORY.md
  runtime/
    orchestrator/
      role.yml
      ROLE.md
    specialists/
      registry.yml
      reviewer/
        specialist.yml
        SPECIALIST.md
      refactor/
        specialist.yml
        SPECIALIST.md
      docs/
        specialist.yml
        SPECIALIST.md
    verifiers/
      registry.yml
      independent-verifier/
        verifier.yml
        VERIFIER.md
    composition-profiles/
      registry.yml
      high-risk-review/
        composition-profile.yml
```

No `framework/agency/**` active authority remains after cutover.

## Runtime relationship

Execution roles never authorize themselves. They participate in runs only
through the engine-owned boundary:

```text
ExecutionRequest -> authorize_execution -> GrantBundle -> ExecutionReceipt
```

Every consequential request binds:

- objective/intent reference
- mission reference when applicable
- run-contract
- execution_role_ref
- context_pack_ref
- risk_materiality_ref
- support_target_tuple_ref
- requested capability packs
- adapter tuple
- rollback_plan_ref
- evidence root
- control root
- review/supervision posture

## Browser/API/multimodal rule

Browser/API/multimodal execution is not live merely because a pack or adapter is
declared. It becomes live only when the runtime service manifest admits the
service and proof exists for replay, redaction, egress lease, compensation,
support dossier, and disclosure.

## Assurance relationship

Lab and observability become proof-producing release gates. RunCards and
HarnessCards may be generated only from retained evidence, not proposal prose or
generated summaries.
