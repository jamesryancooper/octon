# Target Architecture

## Boundary

Clearance decides whether portable-by-role material may be published. It does not grant runtime authority, and an exported component cannot depend on an uncleared or excluded component.

## Proposed Components

- A component and dependency manifest for promised install, bootstrap, execution, validation, update, and rollback workflows.
- A component-level provenance and license record with a bounded path-override mechanism that stays inactive for the first release: PD-024 governs and permits zero provenance exceptions until a maintainer baseline revision activates the PD-008 override path.
- Sensitivity and publication-clearance status with reviewer and evidence references.
- A basic name-conflict search procedure and official-identity statement input.
- Fail-closed closure and zero-unknown-path validators.

## File-Level Work Areas

- `.octon/framework/manifest.yml` — component membership, declared entrypoint
  components for the promised workflows, and dependency edges.
- `.octon/framework/constitution/contracts/disclosure/portable-component-clearance-v1.schema.json`
  — the clearance record contract covering origin, AI-assistance, license,
  sensitivity, publication status, and the inactive path-override mechanism.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-portable-component-clearance.sh`
  — the fail-closed closure and zero-unknown-path validator.
- `.octon/framework/assurance/runtime/_ops/tests/test-portable-component-clearance.sh`
  — positive, negative, and boundary tests for the validator.
- `.octon/framework/assurance/runtime/_ops/fixtures/portable-component-clearance/`
  — checked-in synthetic leak and denylist fixtures exercised by the tests.
- `.octon/state/evidence/validation/proposals/public-distribution-portable-base-clearance/`
  — child evidence root for retained clearance receipts.

## Ownership

- Deterministic manifests own component membership and dependency closure.
- AI-assisted review may prepare inventories and likely-origin groupings.
- The maintainer owns final publication clearance and provenance acceptance.
- A specialist is required only for ambiguous third-party rights or a plausible name conflict.

## Security And Publication Implications

- Clearance records must not reproduce sensitive source content.
- Binaries, executable scripts, Rust/WASM assets, templates, prompts, fixtures, reports, and sample data receive explicit component coverage.
- Generated material carries source provenance or taint and cannot bypass clearance.

## Automation Allocation

### Deterministic Automation

- Build the component graph and fail on cycles, missing dependencies, or unknown files.
- Check license coverage and required notices by component.
- Produce release-specific clearance and provenance manifests.

### AI-Assisted Review

- Classify likely component membership and flag copied, vendor-derived, or ambiguous material.
- Draft concise provenance narratives and review summaries.

AI output remains review input and cannot clear provenance, accept exposure,
authorize deletion, approve publication, or waive a failed deterministic gate.

### Maintainer-Only Authority

- Confirm origin and publication permission.
- Approve the exact first-release component closure.
- Accept the basic name-search result or seek specialist advice.

## Negative Controls

- No exported path lacks a component, license, provenance, sensitivity, and publication status.
- No excluded component is reachable from the selected closure.
- No AI classification changes clearance without maintainer confirmation.
- No unknown-origin file is waived into the first release.

## Deferred Work And Triggers

- Formal trademark registration activates after plausible conflict, impersonation, or commercial adoption.
- Independent legal review activates for unresolved external-origin or license compatibility questions.
- Additional first-party packs use a separate reviewed pack profile after the base release.

## Residual Risks

- Component-level inheritance can miss a path-specific origin exception.
- License compatibility can require specialist interpretation.
- The smallest viable closure may still be larger than desired until promised workflows are narrowed.

