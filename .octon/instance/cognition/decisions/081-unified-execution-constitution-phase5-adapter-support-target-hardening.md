# ADR 081: Unified Execution Constitution Phase 5 Adapter Support Target Hardening

- Date: 2026-03-29
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-29-unified-execution-constitution-phase5-adapter-support-target-hardening/plan.md`
  - `/.octon/state/evidence/migration/2026-03-29-unified-execution-constitution-phase5-adapter-support-target-hardening/`
  - `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/`

## Context

After Phase 4, Octon had support-target declarations and adapter manifests, but
the Phase 5 packet gaps were still materially open:

- model adapter manifests were thinner than the packet’s conformance posture
- the canonical host set was incomplete because CI and Studio were not
  published as host adapters
- governed browser/API pack surfaces were not explicitly modeled
- runtime support-target routing did not validate capability-pack admission or
  adapter manifest content deeply enough to count as a real fail-closed matrix

That left support-target publication partly declarative and meant unsupported
browser/API or broken adapter envelopes could still be under-enforced.

## Decision

Execute Phase 5 as an atomic adapter, pack-admission, and fail-closed
support-target hardening pass.

Rules:

1. Model adapters must publish support-tier declarations, conformance suite
   refs, contamination/reset posture, and known limitations.
2. Host adapters must publish the canonical host-family set: GitHub, CI, local
   CLI, and Studio.
3. Governed capability-pack contracts must exist for repo, git, shell, browser,
   api, and telemetry surfaces.
4. Browser and API packs remain unadmitted until criteria and evidence are
   published together.
5. Runtime authorization must validate adapter manifests and runtime pack
   admission before `ALLOW`.
6. Unsupported tuples, undeclared adapters, and unadmitted packs fail closed.

## Consequences

### Benefits

- The published support-target matrix is now explicit about both tuple support
  and capability-pack admission.
- Adapter conformance is no longer a thin declaration-only surface; runtime now
  cross-checks the authored manifests that back the claim.
- Browser/API surfaces stay honest by default because they remain governed yet
  unadmitted until future evidence exists.

### Costs

- Support-target declarations, capability surfaces, and runtime tests carry
  more structure.
- Fixture setup for kernel workflow/pipeline tests becomes richer because pack
  admission and adapter manifests now participate in authorization.
- CI gains another Phase-specific validator job.

## Completion

This decision is complete once:

- the support-target matrix is published and enforced
- new support tiers require adapter conformance evidence
- browser/API packs are governed and fail closed while unadmitted
- unsupported tuples are denied by runtime and covered by validation
