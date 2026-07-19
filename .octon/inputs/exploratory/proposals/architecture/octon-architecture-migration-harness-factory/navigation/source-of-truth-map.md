# Proposal Reading and Precedence Map

## Authority Boundary

Current canonical repository authority outranks this proposal. The specified
reconciliation is the controlling non-authoritative planning baseline. This
packet may define a future compiler and adapter seam, but neither can mint
authority, reinterpret an authority decision, or become control truth.

## External Sources

| Concern | Source | Role |
| --- | --- | --- |
| Constitutional authority | `.octon/framework/constitution/**` and `.octon/instance/**` | Governs authority, evidence, ownership, topology, and policy. |
| Proposal lifecycle | `.octon/inputs/exploratory/proposals/README.md` and proposal standards | Governs this packet's shape and lifecycle. |
| Reconciled packet boundary | Reconciliation `reconciled-proposal-packet-map.yml` entry RP-11 | Controls purpose, scope, dependencies, proof, and exclusions. |
| Reconciled decisions | FD-020, FD-023, RF-015, RF-016, RF-024, RF-030, PO-FD-020, PO-FD-023, UE-010, UE-011, ED-006 | Controls traceability and future gates. |
| Current implementation facts | Task-harness contracts, route bundle/resolver, adapter contracts/manifests, and `lifecycle_executor` | Establishes the repository-grounded starting point. |

## Proposal-Local Precedence

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/packet-contract.yml`
4. `resources/traceability.yml`
5. `architecture/target-architecture.md`
6. `architecture/acceptance-criteria.md`
7. `architecture/implementation-plan.md`
8. remaining architecture and navigation documents
9. `README.md`

## Planned Durable Ownership

| Concern | Planned owner | Boundary |
| --- | --- | --- |
| Canonical input precedence, normalization, serialization, and invalidation | RP-11 Harness Factory | Compiles already-approved inputs; does not approve or widen them. |
| Effective Harness manifest and compile receipt contracts | RP-11 | Exact, strict, versioned records; generated instances remain projections/evidence. |
| Manifest/source digest binding at authorization and immediate spawn | RP-11 integration symbols consuming RP-01 | Adds exact binding and revalidation; RP-01 retains authority semantics and decision ownership. |
| Generic executor adapter identity, lifecycle interface, registry, and component conformance | RP-11 | Non-authoritative execution seam; no provider may bypass it. |
| Workspace Project and Profile records | RP-10 | RP-11 consumes exact refs/digests and never refreshes them during a run. |
| Candidate isolation and disposable execution boundary | RP-02 | RP-11 launches only through the provided isolation/guard interface. |
| Verifier/publication provider specialization | RP-06 | Consumes generic adapter concepts where useful; not owned or implemented here. |
| Recovery/effect specialization | RP-08 | Not owned or implemented here. |
| Child-agent contract, limits, and provider mapping | RP-13 | May implement a child-specific adapter consumer after RP-11; no shared semantic ownership. |
| Integrated provider-equivalence and support proof | RP-14 | Independently reproduces component and specialization outcomes for promotion. |

## Shared `lifecycle_executor` Ownership

RP-11 owns these exact planned modules/symbol surfaces:

- `adapter.rs`: new `ExecutorAdapter` lifecycle trait,
  `ExecutorAdapterRegistry`, typed prepared handle/outcomes,
  `resolve_adapter`, and the sole generic dispatch;
- `request.rs`: exact Harness/compile-receipt/adapter identity bindings required
  by dispatch;
- `result.rs`: generic lifecycle observation, usage, cancellation, retirement,
  and receipt references;
- `authorization.rs`: only the expected Harness/source digest parameters and
  validation inside existing `authorize_before_dispatch`; authority predicates
  and decisions remain RP-01-owned;
- `input_binding.rs`: new `HarnessFactory`, `HarnessCompileRequest`,
  `HarnessSourceManifest`, `HarnessCompileReceiptBody`, and `compile_harness`
  orchestration, plus `revalidate_harness_binding_immediately_before_spawn`;
- `context_pack.rs` and `generated.rs`: deterministic typed source enumeration
  consumed by `HarnessFactory`, not policy selection;
- `codex.rs`: the one real primary-provider implementation of the generic
  lifecycle trait;
- `mock.rs`: fake conformance adapters and deterministic fixtures only;
- `auto.rs` and `claude.rs`: removal or conversion of hardcoded/provider-name
  dispatch; a live secondary implementation is prohibited unless separately
  claimed and admitted;
- `observer.rs`: existing provider-neutral observation functions revised only
  to consume exact adapter/operation identity from typed outcomes;
- `lib.rs`: module exports needed by the generic seam; and
- `tests/adapter.rs`: generic component conformance and bypass negatives.

RP-13 may later add a separately named child-specific module and mapping that
implements or consumes this trait. It may not redefine the trait, registry,
Harness compiler, or primary/fake component conformance owned by RP-11.

The four RP-01 census seams are shared integration surfaces. RP-01 owns the
final consuming guard at each seam; RP-11 owns only registry/prepared-handle
consumption and provider-neutral dispatch. RP-01 integrates first, followed by
RP-02 isolation where applicable, then RP-11 adapter integration.

## Derived and Operational Surfaces

- effective Harness manifests, source manifests, compile receipts, generated
  route bundles, and resolved route handles are deterministic projections;
- lifecycle observations and usage records are evidence, not authorization;
- `.octon/generated/proposals/registry.yml` remains a discovery projection and
  is intentionally not edited by this child authoring task; and
- retained implementation proof is written only through the evidence owner at
  `.octon/state/evidence/validation/proposals/octon-architecture-migration-harness-factory/`.

## Conflict Rule

When any compiled input, resolved handle, adapter declaration, authorization
binding, or immediate-spawn digest disagrees, launch fails closed. No provider,
legacy executor string, generated route output, or compatibility path may
select a broader result or dispatch directly.
