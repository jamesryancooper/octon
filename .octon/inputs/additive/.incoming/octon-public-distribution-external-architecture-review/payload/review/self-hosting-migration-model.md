---
disclosure_status: externally-shareable-after-maintainer-review
authority_mode: non-authoritative
external_transmission_approved: false
---

# Self-Hosting Migration Model

## Private Workspace Policy

The Octon workspace is a framework-development repository, not an ordinary
downstream consumer. It continues tracking canonical framework source and
repository-specific instance authority.

## Two Migration Packets

The proposal program splits migration because canonical proposals cannot mix
`.octon/**` and root repository promotion targets.

### Root Workspace Migration

Owns root Git posture, `.gitignore`, workspace workflows, ownership metadata,
release configuration, and host-projection tracking.

It removes unsafe workspace publication behavior, blocks a public distribution
push destination, and preserves local host files while making projections
regenerable.

### Octon Storage Migration

Owns forward-only tracking changes under `.octon/state/**` and
`.octon/generated/**`.

Before untracking, it classifies paths, retains required compact receipts,
verifies encrypted backup and restoration, and proves framework and instance
hashes remain unchanged. It removes index entries without deleting local bytes.

## History

**Sponsor decision:** Do not rewrite history as the default migration. Existing
history receives a separate exposure review. If a credential is exposed,
revocation or rotation occurs before Git cleanup.

## Repository Transition

The intended identities are private `octon-workspace`, public `octon`, and
legacy `octon-legacy`. Exact creation, rename, visibility, archive, and first
push actions require a separate maintainer-approved operations plan.

Sources: `SRC-010`, `SRC-011`, `SRC-014`, `SRC-015`, and
`SRC-018`.

