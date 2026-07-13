# Current-State Gap Map

## Repository Baseline

The reconciliation inspected commit
`c5b1f5760c78ff521cca6b054e4e8fef5300505b`. Later repository changes have not
accepted or dynamically proved the RP-11 target.

| Current surface | Reusable strength | Gap owned by RP-11 |
| --- | --- | --- |
| Runtime/constitutional task-specific Harness schemas and specification | Existing Harness vocabulary, digests, compile receipt, and mirrored contracts | The accepted complete project/mission/run/policy/extension/context/model/tool/validation/evidence/rollback source graph and canonical invalidation rules are not fully represented/proved. |
| Runtime effective route bundle and resolver handles | Digest-bound generated routing primitives and freshness checks | A global/generated route bundle is narrower than one complete per-run source/effective Harness and cannot be treated as authorization. |
| `lifecycle_executor` context, generated assets, input binding, request, and result modules | Strong input collection, generated-file verification, request/evidence paths, and result records | Inputs are not one closed canonical graph with every direct/transitive source and one deterministic compiler identity. |
| `authorization.rs` | Existing pre-dispatch validation and delegation proof integration | Exact source/effective Harness digests are not yet the mandatory immediately revalidated spawn binding described by FD-020. |
| `adapter.rs` | `LifecycleRouteExecutor` provides a useful seam | Dispatch still matches `request.executor` strings and invokes provider modules directly rather than resolving strict adapter identity. |
| `codex.rs`, `claude.rs`, `auto.rs`, and `mock.rs` | Reusable provider execution, timeout/cancel observation, and fixtures | Provider-specific branches do not prove one generic prepare/launch/observe/cancel/usage/retire contract or bypass absence. |
| Adapter schemas and model/host manifests | Declarative non-authority, capability, replacement, and conformance concepts | Live fields drift from strict schemas and the runtime does not consume manifest identity as its sole dispatch key. |
| Execution-governance validators and adapter tests | Existing static/runtime assurance anchors | No complete each-input invalidation, immediate launch binding, live-manifest, primary/fake component equivalence, or direct-bypass suite exists. |

## Reconciled Findings

- RF-015: strong route/Harness primitives exist, but durable full per-run
  compilation and authorization binding do not. RP-10 closes the project half;
  RP-11 directly closes the Harness half and retains finding ownership.
- RF-024: schema/manifest existence cannot support completed FD-020/FD-023
  claims. RP-11 replaces those claims with end-to-end component proof.
- RF-030: live adapter schema drift and hardcoded provider-name dispatch make
  the declarative seam different from the execution seam. RP-11 directly owns
  this closure.
- RF-016 is cross-referenced only: RP-11 supplies generic adapter conformance;
  RP-12 and RP-13 retain extension and child trust properties.

## Gap-to-Owner Map

| Gap | Owner | Not owned here |
| --- | --- | --- |
| Complete source graph, precedence, canonical compiler, manifest, and receipt | RP-11 | Source authority and policy decisions |
| Exact source/effective digest at authorization/spawn | RP-11 binding integration over RP-01 | Authority predicates, grant issuance, guard semantics |
| Exact project/Profile source binding | RP-10 produces; RP-11 consumes | Project identity, inference, correction, and inbox |
| Disposable isolated spawn boundary | RP-02 provides; RP-11 consumes | Sandbox/credential isolation semantics |
| Generic adapter identity, lifecycle trait, registry, and component suite | RP-11 | Verifier/publication, effect/recovery, and child specialization |
| One real primary provider and fake adapters | RP-11 | Live secondary support claim |
| Integrated provider-equivalence proof | RP-14 | RP-11 supplies only its component receipt |

## Shared-Code Conflict Prevention

In `lifecycle_executor`, RP-11 owns the generic adapter trait/registry and the
exact binding/compiler symbols enumerated in the source-of-truth map. RP-13 may
later add a child-specific module and mapping but may not edit those semantics
without an explicit cross-packet revision. RP-01 authority changes and RP-08
recovery changes cannot be smuggled into RP-11's shared physical files.

## Evidence Honesty

The current facts are statically inspected. No two identical complete
compiles, each-input mutation matrix, compile-to-spawn race, strict live
manifest suite, real-primary/fake lifecycle equivalence suite, or bypass scan
has been retained as accepted dynamic proof. UE-010 and UE-011 remain open.
