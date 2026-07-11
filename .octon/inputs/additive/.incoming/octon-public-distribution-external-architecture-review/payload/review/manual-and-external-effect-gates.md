---
disclosure_status: externally-shareable-after-maintainer-review
authority_mode: non-authoritative
external_transmission_approved: false
---

# Manual And External-Effect Gates

## Repository-Local Implementation

Accepted child packets may later implement schemas, validators, exporters,
delivery code, templates, fixtures, dry-run planners, migration previews, and
runbooks within declared targets.

## API-Capable But Approval-Gated

Only after the maintainer approves an exact idempotent plan:

- create private `octon-workspace`;
- move or push workspace history to that private destination;
- rename the current repository to `octon-legacy`;
- archive or change legacy visibility;
- create empty public `octon`;
- configure metadata, rulesets, Actions, scanning, vulnerability reporting,
  tags, and immutable releases;
- import an approved public tree.

Automation must default to dry-run, bind expected repository identity and
pre-state, stop on drift, and record compensating actions where possible.

## Human-Only

- authenticator and recovery custody;
- confirmed credential revocation or rotation;
- final exposure and legacy disposition;
- ambiguous license, provenance, trademark, or publication-risk acceptance;
- encryption key and disconnected-backup custody;
- destructive evidence deletion;
- Tier 1 demotion;
- first public-tree push;
- final release publication.

## Forbidden Autonomous Effects

AI, CI merge, proposal orchestration, and draft-candidate automation cannot
waive gates, accept rights uncertainty, delete evidence, push workspace history,
or publish a release.

Source: `SRC-016`, `SRC-018`, and the parent
`resources/external-effects-boundary.md`.

