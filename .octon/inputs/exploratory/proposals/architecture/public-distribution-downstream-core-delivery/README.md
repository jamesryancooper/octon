# Public Distribution Downstream Core Delivery

_Status: In review; implementation-grade complete; not accepted or authorized for implementation._

## Problem

No core lock, release resolver, verified artifact cache, transactional updater, interrupted-update recovery, or rollback implementation was found. Current bootstrap is Bash-centric and writes project configuration into a framework-owned path.

## Confirmed Current Evidence

- **Confirmed evidence:** Repository search found no portable_dropin core lock or core resolver/update transaction.
- **Confirmed evidence:** The bootstrap entrypoint is a Bash script, while Windows x86-64 is an adopted Tier 1 target.
- **Confirmed evidence:** Current initialization writes adapter enablement under framework capabilities.
- **Confirmed evidence:** External-project adoption requires local instance, state, generated, and ingress initialization but does not implement delivery.

## Target Outcome

Provide a cross-platform downstream delivery contract and implementation that
commits an exact, schema-validated `.octon/core.lock.yml`, verifies a release
artifact, materializes core locally, initializes neutral project-owned
surfaces, updates only core-owned paths transactionally, recovers
interruptions, and rolls back safely.

## Scope

- Install from a verified release or explicit local artifact file.
- Validate the core lock against `core-lock-v1.schema.json` before resolution
  or mutation.
- Create project-local authority only when absent and from neutral templates.
- Stage and validate updates before replacement.
- Write the lock last and preserve project-owned path hashes.
- Support Linux x86-64, macOS ARM64, and Windows x86-64 as release-blocking.

## Non-Goals

- No automatic Git commit.
- No automatic instance migration.
- No committed vendoring, internal mirror, daemon, or hosted package service for first release.
- No conversion of the self-hosting framework workspace into an artifact consumer.

## Adopted Decisions Implemented

- **Sponsor decision:** Downstream repositories commit an exact core lock and project-owned authority.
- **Sponsor decision:** Framework artifacts are retrieved from verified releases and materialized in machine-local storage.
- **Sponsor decision:** A local artifact file supports basic offline installation.
- **Sponsor decision:** Updates stage and verify before replacement, journal transitions, and write the lock last.
- **Sponsor decision:** Project-owned hashes remain unchanged and no automatic commit occurs.

## Superseded Approaches

- **Removed or superseded:** Committing a framework snapshot in every downstream repository by default.
- **Removed or superseded:** Git submodules or subtrees as the standard delivery path.
- **Removed or superseded:** In-place update without a journal or rollback snapshot.
- **Removed or superseded:** Writing project selections into framework-owned paths.

## Authority Boundary

This packet remains non-authoritative input. Durable authority can arise only
from separately reviewed implementation in the declared promotion targets.
Maintainer-only decisions and external effects remain explicit gates.
