# Public Distribution Public Repository Controls

_Status: In review; implementation-grade complete; not accepted or authorized for implementation._

## Problem

The current hosted repository is the workspace itself. Its release workflow uses a long-lived PAT, refreshes and commits generated effective state, secret scanning is disabled, main does not require pull requests, and releases are mutable. A separate generated public mirror needs its own source-safe scaffold and controls.

## Confirmed Current Evidence

- **Confirmed evidence:** The current repository is public and has no separate distribution identity.
- **Confirmed evidence:** The current main ruleset requires checks but does not require pull requests.
- **Confirmed evidence:** Secret scanning and push protection are disabled.
- **Confirmed evidence:** The latest release is mutable and has no listed assets.
- **Confirmed evidence:** release-please uses AUTONOMY_PAT and commits generated effective state to a release branch.

## Target Outcome

Create reviewed public-repository-only content and a dry-run-first desired-state plan that enforces synthetic public history, exact export parity, secure CI, checksums, SBOM, attestations, immutable releases, protected tags, and one deliberate maintainer publication action.

## Scope

- Assemble and verify public-repository-only content using the installable and public-repository-only labels from the approved export manifest.
- Generate an idempotent dry-run GitHub operations plan and operator runbook.
- Bind all repository roles by immutable repository ID and fail closed on
  known stale writers before original-name reuse.
- Configure release candidates to build from the public repository commit.
- Keep merge and publication as separate state transitions.
- Support issues and private vulnerability reporting while external code contributions remain closed.

## Non-Goals

- No GitHub repository creation, rename, archive, visibility, rule, secret, release, or push operation in proposal creation or implementation without a separate approved apply step.
- No GitHub App, cross-repository PAT, separate signing key, second reviewer, or organization requirement.
- No public contribution intake for first release.

## Adopted Decisions Implemented

- **Sponsor decision:** Public octon is a separate generated distribution mirror with synthetic history.
- **Sponsor decision:** Public-repository-only files are classified separately from installable content; the classification labels are owned by `public-distribution-portable-dropin-export` (PD-025), and this packet consumes them without redefining them.
- **Sponsor decision:** Use normal maintainer gh or SSH authentication from a separate public checkout and no stored cross-repository PAT.
- **Sponsor decision:** Public CI produces checksums, SBOM, and GitHub/Sigstore attestations from the public commit.
- **Sponsor decision:** Merge may create a draft candidate; only a deliberate maintainer action publishes an exact commit, version, and manifest digest.

## Superseded Approaches

- **Removed or superseded:** Publishing from workspace history or a workspace remote.
- **Removed or superseded:** Release automation that uses AUTONOMY_PAT and auto-publishes on merge.
- **Removed or superseded:** Treating a generated mirror as open contribution source without an intake model.
- **Removed or superseded:** Adding a ceremonial second-person approval or self-approval environment.

## Authority Boundary

This packet remains non-authoritative input. Durable authority can arise only
from separately reviewed implementation in the declared promotion targets.
Maintainer-only decisions and external effects remain explicit gates.
