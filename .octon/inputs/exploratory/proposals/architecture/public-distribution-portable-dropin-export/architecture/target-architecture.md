# Target Architecture

## Boundary

The exporter transforms cleared tracked source blobs into a staging tree. It cannot mutate source, Git refs, remotes, generated state, or public repositories. Publication is a later maintainer-gated operation.

## Proposed Components

- portable_dropin profile and strict schema.
- Git-object exact-commit reader with path and mode safety.
- Component-derived allowlist plus invariant denylist.
- Canonical sorted manifest and aggregate digest.
- Installability labeling: every exported path carries exactly one manifest label, installable or public-repository-only (PD-025); downstream install and public-repository controls consume the labels without redefining them.
- Repeated-build, source-mutation, and public-tree parity validators.
- Root-profile validator amendment admitting portable_dropin while still rejecting every other unknown profile name.
- Adversarial fixtures for unknown paths, symlink escapes, mode drift, and hidden local files.

## File-Level Work Areas

- `.octon/octon.yml` — declare the portable_dropin profile alongside the existing canonical profiles.
- `.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh` — exact-commit, staging-directory, and manifest export behavior.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-portable-dropin-export.sh` — new deterministic export validator (manifest shape, labeling, rebuild equality, source-mutation, and parity gates).
- `.octon/framework/assurance/runtime/_ops/tests/test-portable-dropin-export.sh` — new test harness covering positive and adversarial fixtures.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-root-manifest-profiles.sh` — amend the existing validator, which today hard-rejects any profile beyond bootstrap_core, repo_snapshot, pack_bundle, and full_fidelity, so portable_dropin is admitted while any other unknown profile name still fails.
- `.octon/state/evidence/validation/proposals/public-distribution-portable-dropin-export/` — child evidence root for retained validation receipts.

## Ownership

- Portable-base clearance owns which components are eligible.
- This packet owns deterministic selection and materialization behavior.
- Public-repository controls own the later repository update and release path.
- The maintainer authorizes the first public-tree push.

## Security And Publication Implications

- Git-object reads prevent ignored and untracked local files from entering source selection.
- Path normalization rejects traversal, absolute paths, device files, and unsafe links.
- Denylist invariants apply even when an allowlist is misconfigured.
- Manifest parity detects unexpected public-repository-only or installable content.

## Automation Allocation

### Deterministic Automation

- Resolve and verify the exact source commit.
- Compute closure paths and materialize only admitted blobs.
- Build canonical manifests and compare repeated exports byte-for-byte.
- Compare a candidate public tree with the manifest and reject extras or omissions.

### AI-Assisted Review

- Review denylist completeness and explain manifest diffs.
- Suggest component-boundary refinements without modifying clearance.

AI output remains review input and cannot clear provenance, accept exposure,
authorize deletion, approve publication, or waive a failed deterministic gate.

### Maintainer-Only Authority

- Approve the exact component closure and source commit.
- Authorize any later public-tree transfer.
- Accept any intentional manifest change through proposal and release review.

## Negative Controls

- Exporter cannot read untracked or ignored content.
- Exporter cannot invoke source-mutating generators or publication scripts.
- A non-empty staging directory is rejected.
- Unknown paths, extra public files, omitted manifest files, and nondeterministic timestamps fail.
- An exported path without an installable or public-repository-only label fails the export.
- The amended root-profile validator still rejects any profile name other than the five admitted profiles.
- Base export contains zero additive packs and all strict exclusions.

## Deferred Work And Triggers

- Dedicated pack export remains separate and activates only after pack review policy is implemented.
- Independent signing keys remain deferred until a regulated or air-gapped trust requirement exists.
- Remote publication automation remains in the public-repository controls packet.

## Residual Risks

- A cleared source file can still contain context-sensitive sensitive text missed by scanners.
- Cross-platform archive metadata can differ unless canonicalized.
- Public-repository-only content requires the same clearance discipline as installable content.

