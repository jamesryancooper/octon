# Public Distribution Legacy Exposure Readiness

_Status: In review; implementation-grade complete; not accepted or authorized for implementation._

## Problem

The currently hosted repository is public and contains full workspace history. A new public distribution cannot safely proceed until the existing exposure posture is reviewed without publishing sensitive findings or confusing repository history with an approved distribution.

## Confirmed Current Evidence

- **Confirmed evidence:** The configured GitHub repository is public, active, and not archived.
- **Confirmed evidence:** Repository secret scanning and push protection are currently disabled.
- **Confirmed evidence:** Tracked workspace history includes instance, inputs, state, generated outputs, and host projections.
- **Confirmed evidence:** No canonical redacted legacy-exposure gate was found.

## Target Outcome

Provide a dry-run-first Git-history and hosted-surface exposure-review
mechanism, known-writer inventory, redacted classification receipt,
credential-response rule, and explicit maintainer disposition and name-reuse
gate for the legacy repository.

## Scope

- Inventory tracked history and current refs without reproducing sensitive content.
- Inventory every enabled hosted publication or retention surface and record
  inaccessible surfaces as blockers.
- Inventory known clones, automation, and stale repository endpoints before
  the original public name is reused.
- Classify findings by credential, private data, license/provenance, and publication restriction.
- Define revoke-first credential response and redacted receipt semantics.
- Gate rename, archive, or visibility operations on an explicit maintainer disposition.

## Non-Goals

- No repository rename, archive, visibility change, push, history rewrite, or credential revocation.
- No assertion that a public history can be retracted from existing copies.
- No legal or intellectual-property risk acceptance.

## Adopted Decisions Implemented

- **Sponsor decision:** The current repository becomes octon-legacy only after exposure review.
- **Sponsor decision:** Credential revocation precedes Git cleanup when exposure is found.
- **Sponsor decision:** Legacy remains public and archived only when the maintainer accepts the reviewed disposition.
- **Sponsor decision:** Workspace history is never the source history for the new public repository.

## Superseded Approaches

- **Removed or superseded:** Renaming the current repository directly to the final public distribution.
- **Removed or superseded:** Treating private visibility or Git cleanup as retroactive confidentiality.
- **Removed or superseded:** Recording sensitive findings verbatim in hosted Git.

## Authority Boundary

This packet remains non-authoritative input. Durable authority can arise only
from separately reviewed implementation in the declared promotion targets.
Maintainer-only decisions and external effects remain explicit gates.
