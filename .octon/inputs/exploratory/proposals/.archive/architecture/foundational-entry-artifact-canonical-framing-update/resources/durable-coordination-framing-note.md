# Durable Coordination Framing Note

_Status: In-review proposal packet artifact_


## Decision

Durable Objects should not be part of this foundational implementation. They may be mentioned only as future live coordination adapters.

## Why

Cloudflare Durable Objects provide globally unique objects with durable storage, strong consistency, alarms, and WebSocket coordination. Those features are useful for leases, timers, operator UI, approval waits, connector gates, and budget counters.

They are also exactly why they must not become Octon authority.

## Required wording

> Durable Objects may coordinate live work in a future adapter, but Octon must still decide, authorize, evidence, replay, rollback, and close work. Durable Object state must never become Octon authority, control truth, or evidence.

## Future packet prerequisite

A future Durable Coordination Adapter Evaluation packet must wait until:
- workflow history exists;
- PEP/effect-token coverage exists;
- coordination receipts exist;
- drift/reconciliation rules exist;
- replay can reconstruct truth without Durable Object storage.
