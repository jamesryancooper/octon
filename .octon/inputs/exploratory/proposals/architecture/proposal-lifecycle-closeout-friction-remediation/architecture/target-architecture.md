# Target Architecture

## Problem Statement

The completed `architectural-review-mechanism-documentation-projection-alignment`
run succeeded, but its lifecycle exposed repeatable friction:

- publication freshness was discovered late during terminal closeout;
- executable prompt and review digest freshness required careful manual
  sequencing;
- archive workflow residue needed later cleanup classification;
- `branch-no-pr` landed using an explicitly allowed empty hosted check set;
- sandbox-restricted git ref and network writes required escalated reruns of
  governed helpers;
- final terminal proof worked, but only after all mutation and cleanup steps
  were manually sequenced.

## Desired End State

Proposal lifecycle closeout has a clearer and more deterministic route:

1. Packet creation and review documentation explicitly separate
   implementation-grade completeness from proposal acceptance and
   implementation authorization.
2. Implementation prompt generation includes an immediate digest-refresh
   requirement so prompt changes cannot silently stale proposal review.
3. Terminal closeout has an explicit publication-freshness preflight bundle for
   capability, extension, runtime route, host projection, proposal registry, and
   proposal artifact outputs.
4. Archive workflow residue is either automatically classified as eligible
   local run residue when safe or retained with explicit rationale when it is
   active control state or durable evidence.
5. `branch-no-pr` landing authorization records a stronger rationale when an
   empty hosted check set is explicitly allowed.
6. Branch landing and cleanup helpers tell operators when sandboxed execution
   is expected to fail because git ref writes, fetches, pushes, or remote
   branch checks are required.
7. Terminal current-state proof remains the final post-mutation evidence-only
   proof and does not become authority for landing, cleanup, or generated
   publication.

## Ownership Boundary

This packet does not own a new operator-facing packet delivery wrapper. It owns
the mechanism hardening that such a wrapper would delegate to: terminal
closeout freshness, archive residue classification, branch-no-pr empty-check
rationale, branch cleanup authorization posture, sandbox guidance, and related
validator coverage.

The related `proposal-packet-delivery-wrapper` packet owns the aggregate
delivery workflow, command, skill, profile schema, receipt schema, delivery
validators, and wrapper-specific fixtures. Implementations of this packet must
not create duplicate wrapper surfaces.

## Architecture Principles

- Preserve existing lifecycle gates; reduce surprise, not rigor.
- Keep publication freshness validator-backed and script-owned.
- Keep generated outputs derived-only.
- Keep cleanup authorization distinct from cleanup detection.
- Keep `branch-no-pr` branch-only and PR-free.
- Require validators and tests for every durable behavioral claim.
- Keep operator-facing packet delivery wrapper ownership in
  `proposal-packet-delivery-wrapper`.

## Non-Authority Surfaces

The proposal packet, generated proposal projections, local terminal evidence,
chat summaries, dashboards, host state, and model memory remain informative
only. Durable implementation must stand on framework, instance, control, and
retained evidence surfaces according to constitutional precedence.
