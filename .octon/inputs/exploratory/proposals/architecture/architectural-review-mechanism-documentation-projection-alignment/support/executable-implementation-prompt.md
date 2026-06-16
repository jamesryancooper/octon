# Executable Implementation Prompt

- prompt_id: architectural-review-mechanism-documentation-projection-alignment-implementation-20260615
- generated_at: 2026-06-16T00:55:00Z
- packet: `.octon/inputs/exploratory/proposals/architecture/architectural-review-mechanism-documentation-projection-alignment`
- proposal_status_required: `accepted`
- profile_selection: `release_state=pre-1.0`, `change_profile=atomic`
- packet_digest: `sha256:62706955cd3e3991a577073e797538e43bdbef0b2e6da7744b8882aa69a14758`
- implementation_authority_refs:
  - `support/proposal-review.md`
  - `support/pre-integration-architecture-review.yml`
  - `support/implementation-grade-completeness-review.md`

## Role

Act as the accountable Octon orchestrator for this accepted architecture
packet. Implement only the accepted promotion targets and preserve all authority
boundaries recorded in the packet.

## Accepted Promotion Targets

- `.octon/framework/cognition/practices/methodology/architectural-review/`
- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`
- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/product/features/architectural-review-mechanism.md`
- `.octon/framework/product/features/README.md`
- `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md`
- `.octon/framework/orchestration/runtime/workflows/manifest.yml`
- `.octon/framework/orchestration/runtime/workflows/registry.yml`
- `.octon/framework/capabilities/runtime/skills/manifest.yml`
- `.octon/framework/capabilities/runtime/skills/registry.yml`
- `.octon/framework/capabilities/runtime/commands/manifest.yml`
- `.octon/framework/capabilities/runtime/commands/`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-skills-commands.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-workflows.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-governed-cross-surface-mechanisms.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/generated/effective/capabilities/`

## Required Implementation

1. Add a navigation-only product feature entry for
   `architectural-review-mechanism`.
2. Keep product feature docs explicit that the feature entry is discoverability
   metadata and does not authorize review outcomes, lifecycle gates, generated
   publication, or closeout.
3. Preserve `architecture-readiness-audit` as the canonical readiness mode.
4. Keep `audit-architecture-readiness` retired outside allowed historical,
   retired-name documentation, and validator contexts.
5. Retain `domain-architecture-audit` and `surface-architecture-audit` as the
   canonical methodology/report-schema mode names.
6. Treat `audit-domain-architecture` and `audit-surface-architecture` as
   validator-enforced invocation aliases for the canonical domain and surface
   modes.
7. Update the governed cross-surface mechanism index and detail page so every
   declared architectural-review mode has runtime implementation refs,
   generated refs, retained evidence refs, or an explicit not-applicable
   rationale.
8. Clarify command facade coverage for readiness, domain, and surface audit
   modes. If a mode has no generated host command, document the rationale and
   enforce that rationale in validators.
9. Extend validators and tests so they fail closed for:
   - stale readiness naming;
   - undeclared domain/surface aliases;
   - missing command facade rationale;
   - missing product feature entry or rationale;
   - missing governed mechanism coverage;
   - proposal-local backrefs in durable authority;
   - generated authority overclaims;
   - stale generated capability/proposal projections.
10. Refresh generated outputs only by running owning scripts.

## Validation Commands

Run and retain output for at least these checks:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/architectural-review-mechanism-documentation-projection-alignment
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/architectural-review-mechanism-documentation-projection-alignment
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/architectural-review-mechanism-documentation-projection-alignment
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/architectural-review-mechanism-documentation-projection-alignment --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/architectural-review-mechanism-documentation-projection-alignment/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/architectural-review-mechanism-documentation-projection-alignment --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-workflows.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-skills-commands.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-cross-surface-mechanisms.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-artifact-handles.sh
bash .octon/framework/capabilities/_ops/scripts/validate-capability-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
git diff --check
```

## Publication Commands

Run publication only through canonical scripts:

```sh
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh
```

If a generated proposal artifact index has an owning script in the repository,
run that script rather than editing the artifact by hand.

## Evidence Requirements

- Record implementation evidence in `support/implementation-run.md`.
- Retain validation and publication logs under
  `.octon/state/evidence/proposals/architectural-review-mechanism-documentation-projection-alignment/`.
- Replace `support/implementation-conformance-review.md` with a passing receipt
  only after durable implementation and generated publication checks pass.
- Replace `support/post-implementation-drift-churn-review.md` with a passing
  receipt only after conformance passes and no unresolved drift/churn remains.

## Rollback Posture

Rollback is a normal git revert of authored docs, manifests, registries,
command surfaces, validators, and tests, followed by publication scripts to
regenerate derived outputs from the reverted authored state. Retain proposal
support, validation logs, and implementation evidence for auditability.

## Terminal Closeout And Archive

After implementation and verification pass, run the proposal-packet terminal
closeout route for outcome `archive-ready`, then archive through the proposal
lifecycle archive route with disposition `implemented`. Preserve the original
path, archive timestamp, promotion evidence, terminal receipt refs, generated
proposal registry freshness, and retained evidence refs.

Refuse closeout or archive if any required validator fails, any implementation
receipt remains failing, any scaffold receipt remains unreplaced, any generated
projection is not refreshed through its owning script, any accepted promotion
target is unresolved, any packet digest freshness check is out of date, or any
authority boundary is widened.

## Change Delivery

Close the coherent Change through `branch-no-pr` only. Do not open a pull
request as fallback. Commit only the coherent packet implementation scope,
push the task branch, run hosted no-PR preflight and exact SHA checks, land only
after governed branch-no-pr authorization validates, perform governed branch
cleanup only after cleanup authorization validates, sync local `main` to the
landed hosted commit, and emit final current-state proof after the final
mutation.

## Non-Authority Boundaries

This prompt is proposal-local support material. It does not authorize
implementation, acceptance, closeout, archive readiness, branch landing, or
generated publication by itself.
