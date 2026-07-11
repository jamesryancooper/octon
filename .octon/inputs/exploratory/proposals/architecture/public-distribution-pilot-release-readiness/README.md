# Public Distribution Pilot And Release Readiness

_Status: In review; implementation-grade complete; not accepted or authorized for implementation._

## Problem

The first release promises installation, initialization, update, interruption recovery, rollback, and secure publication across three Tier 1 platforms. No integrated pilot or release-readiness gate currently proves those workflows together.

## Confirmed Current Evidence

- **Confirmed evidence:** Tier 1 support includes Linux x86-64, macOS ARM64, and Windows x86-64.
- **Confirmed evidence:** Current bootstrap is Bash-centric and no transactional updater exists.
- **Confirmed evidence:** The current public repository settings and releases do not meet the adopted target posture.
- **Confirmed evidence:** The public repository cannot be piloted until separately approved repository setup has occurred.

## Target Outcome

Provide an integrated, repeatable pilot harness and final readiness receipt covering public-style, private, and local-artifact/offline projects, Tier 1 fault injection, public-tree parity, release assets, and rollback without authorizing publication.

## Scope

- Exercise clean public-style, private, and offline/local-artifact projects.
- Run install, verify, initialize, update, interruption, recovery, and rollback.
- Validate local-first storage and project-owned preservation.
- Verify public-tree parity, checksums, SBOM, attestations, and immutable-release configuration.
- Produce a final readiness receipt that remains distinct from publication authorization.

## Non-Goals

- No final release publication or first public-tree push.
- No silent Tier 1 bypass.
- No Tier 2 release gating.
- No destructive testing against the maintainer's live workspace or evidence.

## Adopted Decisions Implemented

- **Sponsor decision:** All Tier 1 targets block release unless explicitly demoted before release.
- **Sponsor decision:** Tier 2 targets are non-blocking previews.
- **Sponsor decision:** Pilots cover public, private, and offline/local-artifact use.
- **Sponsor decision:** Final readiness evidence does not replace deliberate maintainer publication.
- **Sponsor decision:** Fault injection must prove interruption recovery and rollback.

## Superseded Approaches

- **Removed or superseded:** Declaring cross-platform support from build success alone.
- **Removed or superseded:** Treating one clean install as sufficient update safety evidence.
- **Removed or superseded:** Silently skipping failed Tier 1 jobs.
- **Removed or superseded:** Using the live self-hosting workspace as a destructive downstream fixture.

## Authority Boundary

This packet remains non-authoritative input. Durable authority can arise only
from separately reviewed implementation in the declared promotion targets.
Maintainer-only decisions and external effects remain explicit gates.

