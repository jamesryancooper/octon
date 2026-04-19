---
title: Execution-Role Subsystem Specification
description: Canonical specification for execution roles, invocation, contracts, and boundaries in .octon/framework/execution-roles.
spec_refs:
  - OCTON-SPEC-101
  - OCTON-SPEC-004
  - OCTON-SPEC-006
---

# Execution-Role Subsystem Specification

## Purpose

Define the final contract for the `.octon/framework/execution-roles`
subsystem after the hard cutover from legacy agency ontology.

## Final Ontology

The canonical durable noun is `execution role`.

Allowed operator-facing role kinds:

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

`subagent` remains runtime-only external terminology for a delegated isolated
specialist context and must not become a durable artifact family.

## Execution Hierarchy

```text
objective
  -> mission
    -> run-contract
      -> workflow instance
        -> stage-attempt
```

- `run-contract` is the atomic consequential execution unit.
- `mission` is continuity and autonomy only.
- `workflow instance` survives only for governance, evidence, recovery,
  publication, or support-proof value.
- `stage-attempt` is local procedural execution.

## Role Semantics

### Orchestrator

The orchestrator is the single accountable execution role for each
consequential run. Exactly one orchestrator is legal per consequential run.

### Specialist

A specialist is a bounded, stateless, scoped helper. Specialists operate only
inside the orchestrator's granted envelope and may not own mission lifecycle,
mutate continuity directly, widen authority, or delegate recursively.

### Verifier

A verifier is an optional independent execution role used only when
materiality, separation of duties, support-proof, or weak deterministic proof
requires materially separate judgment.

### Composition Profile

A composition profile is reusable handoff and routing configuration. It does
not execute and cannot authorize.

## Memory and Context Boundary

- No execution role owns canonical memory.
- Work owns continuity.
- Runtime owns control truth.
- Evidence owns proof.
- Generated cognition is derived context only.
- Consequential runs must bind a context pack before authorization.

## Runtime Boundary

Execution roles never authorize themselves. Consequential execution must route
through the engine-owned boundary:

```text
ExecutionRequest -> authorize_execution -> GrantBundle -> ExecutionReceipt
```

Consequential requests must carry:

- `execution_role_ref`
- `context_pack_ref`
- `risk_materiality_ref`
- `support_target_tuple_ref`
- `rollback_plan_ref`
- requested capability packs
- adapter tuple
- control root
- evidence root

## Required Files

```text
.octon/framework/execution-roles/
├── README.md
├── manifest.yml
├── registry.yml
├── governance/
│   ├── DELEGATION.md
│   └── MEMORY.md
├── runtime/
│   ├── orchestrator/
│   │   ├── ROLE.md
│   │   └── role.yml
│   ├── specialists/
│   │   ├── registry.yml
│   │   └── <id>/{SPECIALIST.md,specialist.yml}
│   ├── verifiers/
│   │   ├── registry.yml
│   │   └── <id>/{VERIFIER.md,verifier.yml}
│   └── composition-profiles/
│       ├── registry.yml
│       └── <id>/{PROFILE.md,composition-profile.yml}
└── practices/
    └── *.md
```

## Delegation Rules

- The orchestrator may delegate only to specialists.
- Specialists may not delegate further.
- Verifiers remain independent of the work product they assess.
- Composition profiles may describe a topology but may not execute.
- Skills and workflows may shape execution but must not mint role authority.

## Support and Capability Constraints

- Capability packs remain governance-grade envelopes.
- Support claims remain bounded by tuple-admitted support targets.
- Adapters remain replaceable, non-authoritative boundaries.
- Browser/API/multimodal execution is live only when runtime-real,
  replayable, redacted, leased, compensable, and dossier-backed.
