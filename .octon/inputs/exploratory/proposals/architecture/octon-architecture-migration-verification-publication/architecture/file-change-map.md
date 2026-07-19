# File Change Map

This map declares planned durable ownership. A target may be absent before
implementation; absence is not evidence of completion.

| Target | Current assumption | Required change | Owner | Priority | Rationale |
| --- | --- | --- | --- | --- | --- |
| .octon/framework/product/contracts/default-work-unit.yml | RP-00 owns the containment route slice; current Change routing predates the final classifier | Replace only the final publication-route subsection with a validated reference/projection of canonical `change-publication.yml`; no duplicate predicate survives | RP-06 after RP-00 | P0 | Makes one final route source explicit |
| .octon/framework/product/contracts/default-work-unit.md | Narrative projects current routing | Align final candidate-first/no-direct-main/no-fallback semantics to the canonical publication policy | RP-06 after RP-00 | P0 | Prevents operator/policy drift |
| .octon/framework/engine/runtime/adapters/host/github-control-plane.yml | Declares a host adapter but does not own the complete immutable-verifier and publication specialization | Bind verifier identity, exact verdict, deterministic route, PR source/create/update/merge requests/results, `S -> Q`, provider observations, projection source, and drift behavior | RP-06 | P0 | Establishes one durable specialization boundary |
| .octon/framework/engine/runtime/adapters/host/github-control-plane/ | Exact source/generator design selected, not implemented | Add the selected manifest, two templates, RP-01-token-gated publisher, validator, and receipt schema | RP-06 | P0 | Resolves the target-family split before any projection change |
| .octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs | Current command surface does not expose the reconciled route decision as one immutable operation | Add or narrow route-evaluation command integration without adding a normal command concept | RP-06 | P1 | Keeps routing inside the existing runtime surface |
| .octon/framework/engine/runtime/crates/kernel/src/request_builders/mod.rs | Request construction does not bind the complete verdict and frozen predicate digest | Build the exact typed verification/publication request from RP-01 and RP-03 identities | RP-06 consuming RP-01/RP-03 | P0 | Prevents policy or identity substitution |
| .octon/framework/engine/runtime/crates/kernel/src/side_effects/mod.rs | Side-effect dispatch lacks the RP-06 route specialization | Dispatch only a valid route decision and exact RP-05 primitive request | RP-06 consuming RP-05 | P0 | Separates selection from physical Git execution |
| .octon/framework/engine/runtime/crates/authorized_effects/src/lib.rs | Generic typed effects exist but no minimum verifier/publication data boundary is accepted | Add only sealed verdict, route, PR subeffect, `S -> Q`, mirror, and landed-fact data needed by existing authority and broker interfaces | RP-06 with RP-01 interface review | P0 | Keeps publication data exact without granting authority |
| .octon/framework/engine/runtime/spec/exact-sha-verdict-v1.schema.json | No accepted exact-verdict schema exists | Add complete identity, source, target, target-pre, policy, harness, evidence, time, expiry, and revocation binding | RP-06 | P0 | Makes candidate-immutable proof machine-checkable |
| .octon/framework/engine/runtime/spec/publication-route-decision-v1.schema.json | No single route-decision schema exists | Add typed deny, Class B no-PR, protected PR, Class C, and local Class A outcomes | RP-06 | P0 | Makes adaptive publication deterministic and auditable |
| .octon/framework/constitution/contracts/adapters/exact-sha-verdict-v1.schema.json | No constitutional mirror constrains the runtime verdict boundary | Add the minimum stable cross-boundary verdict contract through the constitutional route | RP-06 with constitutional owner | P0 | Prevents a runtime-only trust rule |
| .octon/framework/engine/runtime/spec/material-side-effect-inventory.yml | Protected CI is inventoried but verifier/publisher separation and workflow disposition are incomplete | Record verifier as non-mutating, publisher as exact effect consumer, and legacy projected owners as keep/merge/retire | RP-06 | P0 | Makes every live provider effect plane enumerable |
| .octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml | Current coverage does not bind verifier identity, verdict consumer, route decision, and publisher permissions end to end | Add producer/consumer identity, denial, credential-separation, projection, and negative-test coverage | RP-06 | P0 | Proves context names and candidate code cannot bypass authority |
| .octon/instance/governance/policies/change-publication.yml | One durable immutable A/B/C and Class-B/PR predicate policy is absent | Encode settled/retired ROD-002 lineage as typed, versioned, digest-bound policy | RP-06 implementing accepted intake intent; no new operator vote | P0 | Gives every route one deterministic source |
| .octon/instance/governance/capability-packs/git.yml | Git capability posture predates the broker-only publication route | Narrow provider/Git capabilities to exact broker consumption and verifier read/check emission | RP-06 consuming RP-05 | P1 | Prevents credential or route widening |
| .octon/framework/execution-roles/practices/standards/github-control-plane-contract.json | Provider control-plane contract lacks the exact verifier/publication specialization | Add identity, permission, check-binding, ruleset, projection, and drift constraints | RP-06 | P0 | Makes provider conformance explicit |
| .octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml | Current change-route language does not encode the frozen RP-06 predicate | Project the accepted deterministic route without redefining default work-unit authority | RP-06 for route fields | P1 | Aligns operator and runtime behavior |
| .octon/framework/assurance/runtime/_ops/tests/verification-publication/ | Dedicated RP-06 assurance suite is absent | Add candidate mutation, duplicate context, exact binding, permission, route, provider drift, projection, and UX fixtures | RP-06 | P0 | Supplies PO-FD-007/010/011 and UE-006/015 proof |
| .octon/state/evidence/validation/proposals/octon-architecture-migration-verification-publication/ | Child proof is absent | Retain identity, verdict, route, provider, projection, rollback, conformance, and drift evidence | RP-06 lifecycle/proof owners | P0 | Keeps evidence child-owned |

## Consumed But Not Owned

- RP-00 owns only the earlier containment slice of
  `.octon/framework/product/contracts/default-work-unit.{yml,md}`. RP-06 later
  owns the exact final publication-route subsection and migrates canonical
  classification to `change-publication.yml` atomically.
- .octon/instance/governance/support-targets.yml remains RP-14 final-claim
  ownership and is not widened here.
- RP-01 authority issuance, RP-03 operation/attempt transitions, and RP-05 Git
  execution remain frozen dependencies.
- RP-11 owns the generic executor-adapter interface; RP-06 owns only the
  verifier/publication specialization.
- .github/** is an affected host projection family, not an octon-internal
  promotion target. Its 42 current workflows are censused; outputs cannot
  change until the selected .octon source/generator is implemented and its
  token-bound publication is separately authorized.

## Generated And Downstream Effects

Later implementation may refresh .github projections, the generated proposal
registry, or other indexes only through their owning generators and receipts.
Their downstream effect does not authorize direct child edits or mixed target
families.
