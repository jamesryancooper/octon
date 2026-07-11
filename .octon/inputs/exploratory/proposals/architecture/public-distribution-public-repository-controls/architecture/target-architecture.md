# Target Architecture

## Boundary

Canonical templates and desired-state code live in portable framework source. Applying GitHub operations, first public-tree push, and release publication are external effects that remain maintainer-gated and are never performed by parent orchestration.

## Proposed Components

- Public-repository-only LICENSE, notices, identity, contribution, security, and generated-mirror documentation templates.
- An idempotent desired-state manifest, read-only diff, and explicit apply runbook.
- A repository-identity transition preflight that binds the private workspace,
  legacy repository, and new public repository by immutable repository IDs and
  expected names, and blocks original-name reuse until the legacy and
  workspace packets satisfy their stale-writer gates.
- Public-tree import and parity verification from an approved portable_dropin staging tree.
- Least-privilege CI with SHA-pinned Actions and verified downloads.
- Draft release-candidate build plus manual exact-release publication.
- Post-publication verification and safe rollback or withdrawal runbook.

## File-Level Work Areas

- `.octon/framework/scaffolding/runtime/templates/public-repository/` — public-repository-only LICENSE, notices, identity, contribution, security, and generated-mirror documentation templates.
- `.octon/framework/orchestration/runtime/_ops/scripts/plan-public-repository-state.sh` — idempotent GitHub desired-state manifest rendering, read-only diff, and explicit apply-plan generation.
- `.octon/framework/orchestration/runtime/_ops/tests/test-public-repository-state-plan.sh` — mocked-API tests proving dry-run idempotence, zero-mutation diffing, and detection of every required setting gap.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-public-release-candidate.sh` — release-candidate verification of checksums, SBOM, attestations, tag policy, and export-manifest parity.
- `.octon/framework/constitution/contracts/disclosure/public-release-candidate-v1.schema.json` — the release-candidate receipt contract that publication evidence must satisfy.
- `.octon/state/evidence/validation/proposals/public-distribution-public-repository-controls/` — child evidence root for compact validation receipts.

## Ownership

- Portable export owns the candidate public tree and, under PD-025, defines the installable versus public-repository-only labels in the export manifest.
- This packet owns public-repository-only scaffolding and desired-state automation, and consumes the export manifest labels without redefining them.
- This packet owns adopted decisions PD-003, PD-009, PD-011, PD-013, PD-016,
  PD-017, PD-021, and PD-022 plus conditional decision PD-027 per the parent
  decision-to-packet traceability map; PD-025 is owned by
  `public-distribution-portable-dropin-export`.
- The maintainer owns personal-account security, API plan approval, first push, and release publication.
- GitHub-native services own attestations, secret scanning, rulesets, and immutable release enforcement.

## Security And Publication Implications

- Automation defaults to dry-run and displays exact operations before apply.
- Public CI has least-privilege GITHUB_TOKEN permissions and cannot expose write credentials to untrusted pull requests.
- Actions are SHA-pinned and external downloads are hash or signature verified.
- Publication credentials are short-lived interactive maintainer credentials, not workspace secrets.

## Automation Allocation

### Deterministic Automation

- Render public-only files and verify assembled content against the export manifest's installable versus public-repository-only labels.
- Diff actual GitHub settings against desired state without mutation.
- Build candidates, checksums, SBOM, and attestations from the public commit.
- Verify exact public-tree parity, tag policy, release immutability, and published asset digests.

### AI-Assisted Review

- Summarize desired-state diffs and release-candidate evidence.
- Review public documentation for accidental workspace or contribution claims.

AI output remains review input and cannot clear provenance, accept exposure,
authorize deletion, approve publication, or waive a failed deterministic gate.

### Maintainer-Only Authority

- Maintain two independent passkeys or security keys and offline account recovery information.
- Approve an exact GitHub operations plan before apply.
- Authorize the first public-tree push and each final release publication.
- Accept name, provenance, exposure, and release risk.

## Negative Controls

- No workspace remote can push to the public repository.
- No public repository creation or first-tree import proceeds while a known
  workspace writer still targets the reusable `owner/octon` endpoint.
- No rename redirect is treated as an ownership, ancestry, or push-safety
  control after the original repository name is reused.
- No merge automatically publishes a release.
- No untrusted pull request receives secrets or write-capable execution.
- No public tree contains files absent from the approved export manifest.
- No placeholder CODEOWNERS or contribution claim remains.

## Deferred Work And Triggers

- GitHub organization ownership activates when multiple maintainers or organizational custody is needed.
- GitHub App publication activates when repeated cross-repository automation justifies credential isolation.
- Independent signing keys activate for regulated, air-gapped, or independent-registry trust.
- Public code contributions activate only after a reviewed intake and governance model exists.

## Residual Risks

- Personal-account compromise remains a concentration risk.
- GitHub-native trust depends on platform availability and identity controls.
- A maintainer can still deliberately publish the wrong approved-looking candidate without careful digest review.
- Unknown stale clones can target the new public repository after name reuse;
  the operations plan can bound and disclose this risk but cannot eliminate it.
