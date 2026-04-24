# Cutover Checklist

## Before implementation
- [x] Packet accepted for review and scope confirmed.
- [x] Emitter and consumer locations identified.
- [x] Field naming frozen.
- [x] No unresolved conflict with constitutional contract registry or overlay legality.

## Contract surfaces
- [x] `context-pack-v1` strengthened additively.
- [x] `instruction-layer-manifest-v2` updated.
- [x] canonical `run-event-v2` lifecycle events and compatibility alias maps updated.
- [x] `context-pack-builder-v1.md` added.
- [x] `context-pack-receipt-v1.schema.json` added.
- [x] grant / receipt / event schema edits landed.

## Policy and runtime
- [x] `context-packing.yml` added.
- [x] runtime contract defines pack and receipt emission.
- [x] runtime emits retained `model-visible-context.json` and hashes exact retained bytes.
- [x] active pack control-state binding target is defined.
- [x] retained evidence binding target is defined.
- [x] authorization contract can consume receipt / validity state.

## Assurance
- [x] validator added.
- [x] regression tests added.
- [x] deterministic fixtures retained.
- [x] durable `context-pack-receipt-v1` positive and negative fixtures retained.
- [x] active conformance entrypoint is durable and outside this packet.
- [x] deterministic replay requirements retained in validator contract.

## Promotion safety
- [x] support universe unchanged.
- [x] no generated-authority drift.
- [x] no proposal-local dependency in durable targets.
- [x] closure certification packet evidence complete.
- [x] checksum manifest regenerated for packet files.
