# Executable Implementation Prompt: Mechanism Index Foundation

proposal_path: `.octon/inputs/exploratory/proposals/architecture/mechanism-index-foundation`
next_route: `run-packet-implementation`

## Implementation Scope

Implement only the accepted child packet for `mechanism-index-foundation`.
Create the governed cross-surface mechanisms architecture index foundation.

Live repo state at prompt generation:

- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/` is missing and must be created.
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml` exists and may be updated only for structural doc-target or path-family registration needed by this foundation.

Promotion targets:

- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`

## Workstreams

1. Create `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/README.md` as the index entry point.
2. Add a short non-authority banner stating that the mechanism index is architecture/governance documentation, not runtime, policy, support, closeout, cleanup, generated-effective, operator read-model, or retained-evidence authority.
3. Add a layered terminology guide that uses `product features` in product docs, `governed cross-surface mechanisms` in architecture/governance docs, and concrete runtime/operator terms for lifecycles, workflows, routes, state machines, receipts, commands, and skills.
4. Add a glossary for feature, mechanism, lifecycle, state machine, workflow, route, contract, capability, subsystem, control plane, and evidence plane.
5. Add an authority-class guide and mechanism entry template requiring authoritative surfaces, product contracts, runtime specs, runtime implementations, mutable operational truth, retained evidence, generated-effective non-authority, generated operator read models, raw/input surfaces, publication-input-only surfaces, navigation-only surfaces, compatibility-only surfaces, validators/tests, explicit non-authority boundaries, and ownership/delegation boundaries.
6. Add boundary notes for lifecycle versus workflow versus route versus state machine, repo hygiene delegation not ownership, Mission Runner candidate preparation not material execution, and lifecycle interaction receipts as non-authorizing context.
7. Register the index location in `.octon/framework/cognition/_meta/architecture/contract-registry.yml` only if needed for discoverability or doc-target classification.

## Authority Boundaries

- Do not implement runtime behavior.
- Do not mutate `.octon/state/control/**` or `.octon/state/evidence/**`.
- Do not publish generated-effective outputs or generated operator read models.
- Do not treat raw inputs, proposal packets, host state, chat history, model memory, tool availability, or product feature catalog entries as authority.
- Do not collapse proposal lifecycle, Change closeout, worktree closeout, and repo hygiene.

## Validation

Run these checks at minimum:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-index-foundation --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-index-foundation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-index-foundation --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-index-foundation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-index-foundation
```

Add any available architecture, link, or path/class validators that cover the promoted index files.

## Evidence And Receipts

After implementation, produce:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

The conformance receipt must name each promoted file, show that every promotion target above is covered, and explain how the index remains non-authoritative.

The drift/churn receipt must state whether any created surface duplicates existing architecture docs, whether any proposal-local path leaked into promoted docs, and whether cleanup or rollback is needed.

## Rollback Posture

Rollback is manual: remove the new index directory and revert any contract-registry registration if the index claims runtime, policy, support, closeout, cleanup, generated-effective, operator read-model, or retained-evidence authority.

## Terminal Criteria

Implementation is complete only when promoted files exist, validation passes, and both required receipts pass. Refuse closeout/archive claims until `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md` exist, pass their validators, and confirm no unresolved authority-boundary risk remains.
