# Target Architecture

## Boundary

This repo-local packet changes only files outside .octon. A separate Octon-internal child owns .octon storage and index migration. GitHub platform effects remain outside both packets.

## Proposed Components

- Root Git posture and a versioned pre-push public-remote guard delivered at `.githooks/pre-push`.
- Workspace-only workflow and release freeze changes.
- Valid ownership metadata for a solo maintainer.
- Host projection regeneration and local tracking policy.
- Forward migration preflight and rollback receipt.
- A remote-cutover and repository-name-reuse guard that consumes the legacy
  packet's known-writer inventory before the original public name is reused.

## File-Level Work Areas

- `.gitignore`
- `.github/workflows/release-please.yml`
- `.github/workflows/runtime-binaries.yml`
- `CODEOWNERS`
- `.codex/`
- `.claude/`
- `.cursor/`
- `.githooks/pre-push` (the durable public-remote guard)
- `release-please-config.json`
- `.release-please-manifest.json`

## Ownership

- The private workspace owns root Git and CI posture.
- Canonical framework tooling owns how host projections are regenerated, but root copies are projections.
- The maintainer approves any untracking operation and remote-safety exception.
- The Octon storage migration owns later .octon path untracking.

## Security And Publication Implications

- The `.githooks/pre-push` guard must inspect destination identity and fail closed for the public distribution from this workspace; activating it via `core.hooksPath` is a manual migration step recorded in the run journal.
- The active workspace clone and every known workspace writer must be repointed
  to the private workspace before the old `owner/octon` name can identify the
  new public repository. GitHub rename redirects are not a safety boundary.
- No PAT remains required for workspace release automation.
- Host projection removal from tracking must preserve local regeneration inputs and avoid exposing content in receipts.

## Automation Allocation

### Deterministic Automation

- Validate remote role and block a workspace-to-public push.
- Detect placeholder ownership and unsafe workflow credentials.
- Regenerate host projections and compare deterministic parity where supported.
- Preview root-level tracking changes without deletion.

### AI-Assisted Review

- Review workflow intent and summarize root tracking diffs.
- Classify ambiguous host files for maintainer review without changing Git posture.

AI output remains review input and cannot clear provenance, accept exposure,
authorize deletion, approve publication, or waive a failed deterministic gate.

### Maintainer-Only Authority

- Approve root tracking changes and remote-role configuration.
- Retain account and credential custody.
- Authorize any later repository transition operation.

## Negative Controls

- No .octon file is modified or untracked by this packet.
- No workspace workflow can publish the public distribution.
- No public distribution remote is accepted as a workspace push destination.
- No stale original-name URL is accepted after repository-name reuse, even if
  it previously redirected to the legacy repository.
- No host projection is deleted merely because it becomes untracked.
- No placeholder owner remains in active metadata.

## Deferred Work And Triggers

- Public contribution workflows activate only after contribution intake is approved.
- GitHub App publication activates only after repeated cross-repository operations justify it.
- Organization transfer activates after multiple-maintainer custody is required.

## Residual Risks

- A user can bypass local hooks with explicit Git options.
- `core.hooksPath` is per-clone configuration; a clone without the recorded manual activation step lacks the `.githooks/pre-push` guard.
- Host projection regeneration may expose drift if current projections were manually edited.
- Root and .octon migration packets must remain synchronized.
- Unknown stale clones remain a residual name-reuse risk after all known
  writers are migrated; the maintainer must accept that risk explicitly.
