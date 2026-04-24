# Implementation Gap Analysis

## Gap 1 — Lifecycle contract is not enough without transition enforcement

**Blocking factor:** `run-lifecycle-v1.md` defines the state machine, but the runtime must enforce it at every state-changing operation.

**Required change:** Add a lifecycle transition gate used by all run-related runtime operations and CLI commands.

**How proposal closes it:** Adds machine-readable transition schema, runtime transition gate, and negative tests.

## Gap 2 — Runtime state must be reconstructed, not trusted

**Blocking factor:** `runtime-state.yml` is a mutable derived view. If runtime code trusts it directly, state can drift from the canonical journal.

**Required change:** Reconstruct lifecycle state from journal and compare to materialized runtime state before consequential transitions.

**How proposal closes it:** Adds lifecycle reconstruction contract and drift-blocking validator.

## Gap 3 — Closeout must be a gate, not a checklist

**Blocking factor:** Run closeout requires evidence completeness, disclosure, rollback posture, and journal snapshot linkage. Those facts must block `closed` if missing.

**Required change:** Make closeout validation part of the lifecycle transition gate.

**How proposal closes it:** Defines `closed` as a gated terminal transition and adds closeout validator fixtures.

## Gap 4 — Effect-token enforcement needs lifecycle awareness

**Blocking factor:** Authorized Effect Tokens prove permission for an effect, but they must also be consumed only in valid lifecycle states.

**Required change:** State-aware token verification: material effects require valid `running` posture and active support/capability envelope.

**How proposal closes it:** Adds tests rejecting token consumption outside `running`, after revocation, after closure, or during drift.

## Gap 5 — Context binding/resume needs lifecycle semantics

**Blocking factor:** Context Pack Builder v1 produces preauthorization evidence, but lifecycle transitions must also validate context on resume, rebuild, compaction, invalidation, and authorization.

**Required change:** Transition preconditions reference context-pack freshness, receipt binding, and invalidation state.

**How proposal closes it:** Adds context-specific transition rules for `bound`, `authorized`, `paused`, and `running` states.

## Gap 6 — Support-target proof requires deterministic state reconstruction

**Blocking factor:** Support-targets demand deterministic state reconstruction, but this needs a validation surface.

**Required change:** Add lifecycle assurance validator and retained proof bundle.

**How proposal closes it:** Adds validator path and retained evidence plan under assurance.

## Gap 7 — Generated/operator views must not become lifecycle authority

**Blocking factor:** Operator read models are necessary for usability, but lifecycle enforcement must not read them as authority.

**Required change:** Read models may mirror state only after journal-derived state materialization.

**How proposal closes it:** Adds explicit non-authority tests and operator-read-model update guidance.
