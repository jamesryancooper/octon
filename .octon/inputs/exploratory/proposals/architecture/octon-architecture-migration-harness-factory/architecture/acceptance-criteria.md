# Acceptance Criteria

## Entry Criteria

- RP-01 has exited with a frozen versioned authority and exact one-shot launch
  guard interface.
- RP-02 has exited with a frozen candidate-isolation and guarded spawn
  interface.
- RP-10 has exited with immutable Workspace Project and Project Profile refs
  and digests.
- ED-006 is represented in the serializer, invalidation, adapter, and provider
  breadth design.
- Current Harness, route/resolver, adapter, authorization-consumer, and direct
  provider call paths have been inventoried at the implementation commit.

## Target Criteria

| ID | Required condition | Proof |
| --- | --- | --- |
| RP11-AC-001 | The source manifest contains every direct/transitive project, mission, run, policy, extension, context, model, tool, validation, evidence, and rollback input with exact identity/ref/schema/digest/edge or explicit deterministic absence. | Closed-graph census, schema fixtures, and omitted/extra/duplicate/cycle negatives. |
| RP11-AC-002 | Two compiles of identical complete inputs and compiler/schema/precedence identities produce byte-identical source manifests, effective manifests, receipt bodies, and equal digests across clean processes. | Repeated and cross-process golden-byte comparison with locale/timezone/environment perturbation. |
| RP11-AC-003 | Mutating each direct or transitive input one at a time changes the source/effective digest or causes compile denial; no inherited/default/generated input escapes invalidation. | Complete generated mutation matrix with coverage receipt. |
| RP11-AC-004 | Stale, self-widened, wrong-project, wrong-mission, wrong-run, wrong-attempt, wrong-adapter, wrong-compiler, and changed-source bindings deny at canonical authorization consumption and immediate one-shot spawn. | Launch-denial matrix plus before-spawn source-race fault injection. |
| RP11-AC-005 | Every live model/host adapter manifest validates against strict current schemas and unknown/drifted/authority-shaped fields reject. | Full manifest census, schema validation, and negative fixtures. |
| RP11-AC-006 | All live provider launches resolve exact adapter identity/version/schema/conformance refs through one registry and generic interface; executor-name and direct-module bypasses are unreachable. | Static call graph, symbol scan, runtime bypass attempts, and adapter registry tests. |
| RP11-AC-007 | One real primary-provider adapter passes prepare, launch, observe, cancel, usage, and retire fixtures with typed identity-preserving outcomes. | Primary-provider component conformance report in an isolated non-production fixture. |
| RP11-AC-008 | Fake adapters reproduce success, failure, timeout, lost response, cancel race, unknown observation, malformed usage, and retirement failure without changing Octon authority/mission semantics. | Provider-neutral fixture comparison and canonical-state before/after digests. |
| RP11-AC-009 | No live secondary provider is admitted unless a separate support proposal/tuple and current conformance receipt exists; provider-specific code alone remains inactive. | Live registry/support census and unclaimed-secondary launch denial. |
| RP11-AC-010 | Generated route bundles, effective/source manifests, compile receipts, and adapter observations cannot be accepted as canonical authority or widen their sources. | Source-precedence attacks, authority-shaped projection negatives, and ownership scan. |
| RP11-AC-011 | Compiler and adapter integration creates no scheduler, policy engine, authority source, runtime store, provider verifier/publisher, recovery controller, effect executor, or child semantics. | Architecture/source-ownership review and process/store/symbol census. |
| RP11-AC-012 | A compile or adapter failure preserves candidate work and immutable inputs, fails only affected launch closed, gives a concise repair reason, and never falls back to direct provider dispatch. | Fault-injection, rollback rehearsal, and operator-output fixtures. |
| RP11-AC-013 | Every manifest promotion target and shared registry/code edit is covered by an exclusive entry/symbol owner; RP-06/RP-08/RP-13/RP-14 boundaries remain intact. | Program ownership matrix and diff-to-owner audit. |
| RP11-AC-014 | All four RP-01 candidate-launch seams carry one registry-resolved RP-11 prepared handle and one same-path RP-01 consuming guard; non-candidate utility subprocesses remain explicitly partitioned and cannot be reclassified silently. | Immutable-tree census parity, static raw-spawn negatives, and four-seam dynamic fitness tests. |

## Proof Obligations

Passing RP11-AC-001 through RP11-AC-004, RP11-AC-010 through RP11-AC-012,
and RP11-AC-014 satisfies PO-FD-020 and gate PG-11-HARNESS-BINDING. Passing
RP11-AC-005 through RP11-AC-009 supplies RP-11's component contribution to
PO-FD-023 and PG-14-PROVIDER-CONFORMANCE. It does not satisfy integrated
provider equivalence, which remains RP-14-owned after RP-06, RP-08, and RP-13
specialization proof.

## Exit Criteria

- all criteria above pass at the exact implementation commit and exact
  compiler/schema/precedence/adapter identities;
- UE-010 and the RP-11 component portion of UE-011 are retained at the declared
  proposal-validation root;
- pre-integration architecture review, implementation conformance review, and
  post-implementation drift/churn review pass;
- generated projections are refreshed only through their canonical owners;
- direct provider dispatch and legacy executor-name selection are retired; and
- no durable target depends on this proposal path.

These are future gates. None is claimed as executed by this draft.
