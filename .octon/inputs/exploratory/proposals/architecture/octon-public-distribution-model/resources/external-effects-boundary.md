# External Effects Boundary

## Repo-Local Implementation

Accepted child packets may later create or modify only their declared promotion
targets. They may implement exporters, validators, delivery code, schemas,
templates, fixtures, dry-run API planners, migration previews, and operator
runbooks.

## API-Capable, Approval-Gated Operations

The following may be automated only after the maintainer approves an exact,
idempotent operations plan and separately invokes apply:

- create private `octon-workspace`;
- push workspace history to that private repository;
- rename the current repository to `octon-legacy`;
- archive or change legacy visibility;
- create empty public `octon`;
- set metadata, rulesets, Actions permissions, security controls, vulnerability
  reporting, tags, and immutable releases;
- initialize the public repository from an approved export.

Every operation must default to dry-run, bind repository identity and expected
pre-state, record exact requests, stop on drift, and define compensating action
where the platform supports one.

The operations sequence must bind all three repositories by immutable GitHub
repository ID, move the active workspace and every known writer to the private
identity before the original `owner/octon` name is reused, and prove a stale
original-name push is rejected before object transfer. GitHub rename redirects
are convenience behavior, not an authority or safety boundary after name
reuse. Unknown stale clones remain a disclosed residual risk.

## Human-Only Actions

- passkey, security-key, 2FA, and recovery material custody;
- final exposure and legacy disposition;
- credential revocation or rotation;
- legal, provenance, trademark, or publication-risk acceptance;
- encryption-key and disconnected-backup custody;
- destructive evidence deletion;
- Tier 1 demotion;
- authorization of the first public-tree push;
- acceptance of residual unknown stale-clone risk before original-name reuse;
- final public release publication.

## Forbidden Autonomous Effects

No proposal, parent runner, AI agent, CI merge, or draft candidate may:

- change repository identity, visibility, archive state, remotes, history, or
  credentials without the explicit apply gate;
- push workspace history to public `octon`;
- accept ambiguous rights or exposure;
- delete evidence;
- waive a failed blocker;
- publish a release.

## Creation-Run Confirmation

This proposal-creation run performs none of the effects above.
