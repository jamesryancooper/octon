# Context, Memory, and Continuity Model

## Plane separation

| Plane | Root | Final rule |
|---|---|---|
| Authored authority | `framework/**`, `instance/**` | Defines rules, policies, contracts, schemas, and role definitions. |
| Control truth | `state/control/**` | Current mutable operational truth, including run state, approvals, exceptions, revocations, directives, and leases. |
| Continuity | `state/continuity/**` | Resumable work state and mission handoff state. |
| Evidence | `state/evidence/**` | Retained proof, receipts, replay pointers, traces, validation outputs, RunCards, HarnessCards. |
| Generated | `generated/**` | Derived read models only. |
| Inputs | `inputs/**` | Non-authoritative exploratory/additive material only. |

## Memory rule

No execution role owns canonical memory.

- Work owns continuity.
- Runtime owns control truth.
- Evidence owns proof.
- Authored surfaces own authority.
- Generated cognition owns nothing authoritative.

## Context packs

Every consequential run must bind a context pack before authorization. A context
pack must include:

- context_pack_id
- run_id
- objective_ref
- mission_ref, if any
- authoritative_sources[]
- derived_sources[]
- excluded_sources[]
- source_hashes[]
- freshness_checks[]
- authority_labels[]
- generated_input_labels[]
- token_or_context_budget
- known_omissions[]
- retrieval_or_search_steps[]
- evidence_receipt_ref

Generated cognition may appear only under `derived_sources[]` with provenance,
freshness, and explicit non-authority labeling.

## Handoff and bootstrap

Startup for consequential execution:

1. load constitutional kernel;
2. load objective;
3. resolve mission binding;
4. assemble context pack;
5. classify risk/materiality;
6. resolve support-target tuple;
7. resolve adapter tuple;
8. resolve capability packs;
9. bind rollback posture;
10. call `authorize_execution`;
11. execute only after grant;
12. emit receipts, checkpoints, replay pointers, and closeout evidence.

## Resumability

Resumability is reconstructed from:

- run control roots;
- mission continuity roots;
- retained evidence and replay pointers;
- context-pack receipts;
- rollback posture;
- checkpoints.

Chat history is not continuity.

## Compaction vs fresh reset

Compaction is allowed only as a runtime context-management technique. Fresh reset
is preferred when context is noisy, long-running, or crosses material stage
boundaries. Both methods must produce retained handoff evidence when used in a
consequential run.

## Generated cognition boundary

Generated cognition must never:

- authorize,
- approve,
- override,
- publish,
- satisfy evidence obligations,
- replace ADRs,
- replace run receipts,
- replace mission continuity.
