# Change-First Default Work Unit Policy

## Purpose

This proposal codifies a product stance for Octon: the default work unit is a Change. Pull Requests are optional publishing and review outputs, not the default unit of work.

The packet is exploratory proposal material. It does not modify runtime policy until promoted into the targets listed in `proposal.yml`.

## Reading Order

1. `proposal.yml`
2. `policy-proposal.yml`
3. `policy/decision.md`
4. `policy/routing-model.md`
5. `implementation/implementation-map.md`
6. `policy/policy-delta.md`
7. `policy/enforcement-plan.md`
8. `navigation/source-of-truth-map.md`
9. `navigation/artifact-catalog.md`
10. `resources/source-context.md`
11. `support/creation-prompt.md`
12. `support/implementation-grade-completeness-review.md`
13. `support/executable-implementation-prompt.md`
14. `support/implementation-conformance-review.md`
15. `support/post-implementation-drift-churn-review.md`

## Scope

This proposal covers the default work unit contract, Git and GitHub routing semantics, durable evidence expectations, automated route selection, the pre-1.0 Work Package to Change Package cutover, and the downstream contracts, standards, workflows, adapters, manifests, validators, and practice documents required to keep Octon coherent for solo-developer operation.

It does not prescribe a GitHub-first workflow or make proposal-local files authoritative. It does require a complete target-state rename from Work Package to Change Package, with no compatibility aliases or shims retained in active authoritative surfaces.

## Promotion Exit

Exit requires a canonical Change-first policy contract, downstream references that treat PRs as optional outputs, a completed Change Package runtime taxonomy, implementation-specific Git adapters that route direct-main, branch-only, and PR-backed paths, validators that prove no runtime surface still assumes PRs, branches, GitHub, or legacy Work Package terminology are the default work unit, and a linked repo-local alignment path for `.github/**` host projections.
