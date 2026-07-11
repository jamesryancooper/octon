# Target Architecture

## Boundary

Review tooling may inspect local Git objects and platform metadata, but its durable publishable output is a compact redacted disposition receipt. Raw findings remain local-private. Platform mutation is outside this packet.

## Proposed Components

- A deterministic tracked-history and ref inventory.
- A hosted-surface inventory covering every enabled GitHub publication or
  retention surface, with explicit inaccessible, absent, and dispositioned
  states rather than an implicit Git-history-only scope.
- A known-clone, automation, webhook, deploy-key, and remote-URL inventory for
  the current `owner/octon` identity before that name is reused by the new
  public distribution repository.
- Composable secret, sensitivity, provenance, and publication-restriction checks.
- A redacted finding and disposition schema, `legacy-exposure-readiness-v1`, whose receipt carries the maintainer decision record as a required field set: disposition, credential actions, timestamp, and reviewed revision.
- A credential revoke-first response runbook.
- A transition precondition validator that cannot perform GitHub mutations and rejects any receipt missing the maintainer decision field set.
- A name-reuse precondition that blocks transition until known workspace
  remotes are moved to the private identity and the maintainer acknowledges
  the residual risk from unknown stale clones.

## File-Level Work Areas

- `.octon/framework/assurance/runtime/_ops/scripts/validate-legacy-exposure-readiness.sh` — deterministic inventory, scanners, and the no-mutation transition readiness gate.
- `.octon/framework/assurance/runtime/_ops/tests/test-legacy-exposure-readiness.sh` — positive, negative, and boundary tests for the validator.
- `.octon/framework/assurance/runtime/_ops/fixtures/legacy-exposure-readiness/` — the synthetic sensitive fixtures and the sanitized-history fixture.
- `.octon/framework/constitution/contracts/disclosure/legacy-exposure-readiness-v1.schema.json` — the redacted finding, disposition, and maintainer decision receipt schema.
- `.octon/framework/orchestration/governance/legacy-exposure-response-runbook.md` — the credential revoke-first response runbook.

## Ownership

- Deterministic tooling owns inventory and classification evidence generation.
- The maintainer owns credential action, exposure interpretation, and legacy disposition.
- External specialist advice is triggered only by ambiguous legal ownership or material exposure that the maintainer cannot evaluate.

## Security And Publication Implications

- Raw scan output must default to local-private storage and avoid console disclosure.
- Receipts must use identifiers, classes, counts, and digests rather than sensitive payloads.
- A clean scan does not establish publication clearance for framework content.

## Automation Allocation

### Deterministic Automation

- Enumerate every blob reachable from every ref at the exact reviewed revision, in deterministic order.
- Enumerate enabled hosted surfaces and record their API scope, item counts,
  scan coverage, access limitations, and disposition without downloading or
  echoing restricted payloads into publishable receipts.
- Inventory known stale repository endpoints and consumers before repository
  name reuse.
- Run deterministic scanners and produce redacted counts and digests.
- Fail transition readiness when unresolved material findings exist.

### AI-Assisted Review

- Cluster redacted findings and draft a maintainer decision summary.
- Suggest likely false positives without changing scanner verdicts.

AI output remains review input and cannot clear provenance, accept exposure,
authorize deletion, approve publication, or waive a failed deterministic gate.

### Maintainer-Only Authority

- Revoke or rotate exposed credentials.
- Accept the final legacy visibility and archive disposition.
- Authorize any platform operation generated from the approved plan.

## Negative Controls

- No raw secret or private text appears in receipts, logs, or proposal resources.
- No scanner result automatically changes repository state.
- No clean current-tree scan substitutes for history review.
- No clean Git-object scan substitutes for review of enabled hosted surfaces.
- No repository rename is treated as revoking old URLs or making later reuse
  of the original name safe for stale clones.
- No visibility change is represented as revoking existing public copies.

## Deferred Work And Triggers

- History rewriting remains outside first-release scope; activate only if the maintainer chooses remediation after exposure review.
- Continuous organization-wide exposure monitoring activates only after multiple repositories or maintainers exist.

## Residual Risks

- Automated scanners can miss context-sensitive confidential material.
- Previously public clones cannot be recalled.
- Unknown stale clones or automation may still target the reused public name;
  this residual risk requires explicit maintainer acceptance.
- Final legal interpretation may require targeted specialist advice.
