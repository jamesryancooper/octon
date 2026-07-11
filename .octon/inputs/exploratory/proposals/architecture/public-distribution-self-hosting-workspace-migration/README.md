# Public Distribution Self-Hosting Workspace Migration

_Status: In review; implementation-grade complete; not accepted or authorized for implementation._

## Problem

The self-hosting workspace currently tracks hundreds of host-projection files, has selective ignore exceptions for generated and evidence material, contains placeholder CODEOWNERS identities, and uses workspace-history release automation. Root-level migration must be isolated from .octon storage changes to satisfy proposal target-family boundaries.

## Confirmed Current Evidence

- **Confirmed evidence:** The repository tracks .codex, .claude, and .cursor projection trees.
- **Confirmed evidence:** .gitignore contains numerous generated and evidence-specific exceptions.
- **Confirmed evidence:** CODEOWNERS contains placeholder accounts.
- **Confirmed evidence:** release-please uses a PAT and pushes generated effective state from the workspace.
- **Confirmed evidence:** The canonical proposal standard forbids mixing .octon and non-.octon promotion targets.

## Target Outcome

Adopt a private-workspace root policy that prevents public remote targeting, removes unsafe release behavior, validates ownership metadata, keeps host projections regenerable and local by default, and prepares ignore rules for a separate .octon storage untracking packet.

## Scope

- Replace placeholder ownership metadata or remove it.
- Freeze and narrow workspace release automation so it cannot publish the public distribution.
- Keep .codex, .claude, and .cursor local or regenerated unless explicitly classified.
- Add pre-push protection against a public distribution remote as a versioned `.githooks/pre-push` guard, activated via `core.hooksPath` as a recorded manual migration step.
- Move every known workspace writer to the private identity and reject the
  stale original-name endpoint before repository-name reuse.
- Prepare root ignore policy consumed by the Octon storage migration.
- Derive state, generated, evidence, and input-subtype ignore defaults plus
  bounded exception classes from the earlier machine-readable Git-posture
  contract; the later migration allowlist selects exact paths only within
  those predeclared classes.

## Non-Goals

- No deletion or untracking of .octon state, generated, evidence, instance, input, or framework paths in this packet.
- No GitHub repository rename, creation, archive, visibility, settings, push, or release operation.
- No history rewrite.
- No replacement of canonical framework source with a downloaded artifact.

## Adopted Decisions Implemented

- **Sponsor decision:** The self-hosting workspace remains a source repository and continues tracking canonical framework source.
- **Sponsor decision:** The workspace must not have a public distribution push remote.
- **Sponsor decision:** Host projections are local and regenerable by default.
- **Sponsor decision:** Workspace release automation cannot serve as public distribution publication.
- **Sponsor decision:** Migration is forward-only and does not rewrite existing history.

## Superseded Approaches

- **Removed or superseded:** Using workspace release-please output as the public distribution.
- **Removed or superseded:** Tracking all host projections as canonical source.
- **Removed or superseded:** Placeholder CODEOWNERS entries.
- **Removed or superseded:** Relying on operator memory to avoid pushing workspace history to the public repository.

## Authority Boundary

This packet remains non-authoritative input. Durable authority can arise only
from separately reviewed implementation in the declared promotion targets.
Maintainer-only decisions and external effects remain explicit gates.
