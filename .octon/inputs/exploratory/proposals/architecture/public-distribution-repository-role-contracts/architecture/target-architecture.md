# Target Architecture

## Boundary

Architecture authority and publication safety are modeled as independent dimensions. Framework material is portable by role but cannot enter the public artifact until separately cleared.

This child stops at role, path, and update-authority boundaries. It reserves
the `portable_dropin` role but does not admit that profile, amend root-profile
validation, implement install or update behavior, or produce concrete
project-owned hash-preservation proof.

## Proposed Components

- A four-surface topology contract documented in `public-distribution-topology.md`.
- A machine-readable YAML path ownership and Git-posture registry in `core-path-ownership-v1.yml`.
- A reserved portable_dropin public-boundary role for the export child to admit.
- Core update-authority invariants and project-owned preservation rules for the downstream child to implement and prove.
- Explicit first-release exclusions and deferred-control triggers.
- A deterministic role, path, and update-authority contract validator with test harness and negative fixtures.

## File-Level Work Areas

- `.octon/README.md` — four-surface topology summary, reserved profile-role handoff, and deferred-control trigger documentation without root-profile admission.
- `.octon/framework/cognition/_meta/architecture/public-distribution-topology.md` — normative four-surface topology contract.
- `.octon/framework/engine/runtime/spec/core-path-ownership-v1.yml` — machine-readable core-owned versus project-owned path ownership and update-authority invariant contract with per-surface Git posture.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-repository-role-contracts.sh` — deterministic validator for role completeness, ownership disjointness, exclusion invariants, the reserved public-boundary role, and update-authority invariant presence; it does not validate root-profile admission or downstream operation behavior.
- `.octon/framework/assurance/runtime/_ops/tests/test-repository-role-contracts.sh` — validator test harness covering positive and negative cases.
- `.octon/framework/assurance/runtime/_ops/fixtures/repository-role-contracts/` — negative fixtures for overlapping ownership, forbidden roots in the reserved public-boundary eligibility set, and mixed-root publication claims.

## Ownership

- Framework contracts own portable core definitions.
- Instance contracts remain repository-specific authored authority.
- State and generated roots remain target-local operational or derived surfaces.
- `public-distribution-portable-dropin-export` solely owns portable_dropin admission in `.octon/octon.yml` and the corresponding root-profile validator work.
- `public-distribution-downstream-core-delivery` solely owns concrete adoption/update implementation and project-owned hash-preservation execution proof.
- This packet owns only the repository-role, path-ownership, and update-authority invariant definitions consumed by those children.
- The maintainer owns explicit exceptions and publication risk acceptance.

## Security And Publication Implications

- No role implies publication clearance by itself.
- Public-repository-only files are distinct from downstream-installable files.
- Update ownership must be machine-verifiable before replacement.

## Automation Allocation

### Deterministic Automation

- Validate path classifications and reject overlap between core and project ownership.
- Validate the reserved public-boundary role, exclusions, zero-pack posture, and update-authority invariant without treating that validation as profile admission or operation proof.
- Detect forbidden workspace-history or mixed-root publication claims.

### AI-Assisted Review

- Review taxonomy clarity and identify ambiguous path classifications.
- Draft documentation deltas from deterministic ownership data.

AI output remains review input and cannot clear provenance, accept exposure,
authorize deletion, approve publication, or waive a failed deterministic gate.

### Maintainer-Only Authority

- Approve any exception to default path ownership.
- Approve changes that widen first-release public scope.
- Resolve genuine product-scope choices that contracts cannot infer.

## Negative Controls

- No repository-role contract classifies live instance, inputs, state, generated, evidence, host, log, archive, or pack roots as eligible for the reserved public-boundary role.
- No update contract grants core ownership of target-local paths.
- No invariant-presence check is represented as concrete downstream install or update proof.
- No `.octon/octon.yml` admission or root-profile validator change is claimed by this packet.
- No documentation describes the public repository as a workspace clone or mirror.
- No Git-ignore rule is treated as the publication boundary.

## Deferred Work And Triggers

This packet owns PD-020: every deferred control below must be recorded with
its activation trigger in the delivered documentation, and the first release
activates none of them.

- GitHub organization ownership activates only when multiple maintainers or organizational custody exist.
- Public contributions activate only after an approved intake, review, and governance model exists.
- A dedicated GitHub App activates only when repeated cross-repository automation justifies isolation.
- An independent trust root or signing key activates only on a regulated, air-gapped, or independent-registry need.
- Hosted immutable evidence activates only on a collaboration, regulatory, or recovery need.
- An evidence-compaction service activates only when material evidence volume and review burden exist.
- Committed vendoring or an internal mirror activates only for a verified offline or policy-constrained adopter.
- Automatic instance migration activates only when a real instance schema transition is required.
- Tier 2 gating activates only after preview platforms produce reliable lifecycle results.

## Residual Risks

- Broad directory ownership can still hide misclassified files without component clearance.
- Future plugins or packs may need additional ownership classes.
- Documentation drift remains possible without validators.
