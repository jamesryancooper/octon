---
title: Service Idempotency
scope: harness
applies_to: services
---

# Service Idempotency

Idempotency behavior is shared across services for deterministic retries and safe mutation control.

## Key Derivation

Default derived key format:

- `<serviceId>:<operation>:<hash>`

Hash input factors:

- service name
- operation name
- stable inputs (canonical JSON with sorted keys)
- optional git SHA
- optional lifecycle stage

## Record States

Idempotency records progress through:

- `pending`
- `completed`
- `failed`

`completed` responses may return cached result payloads when hashes match.

## Replay Semantics

- Existing `completed` with matching `inputsHash`: return cached result.
- Existing `completed` with non-matching `inputsHash`: conflict (`exit 7`).
- Existing `failed`: allow retry.
- Existing non-stale `pending`: conflict (`exit 7`).
- Stale `pending`: may be cleared and retried.

## Storage Backends

Supported storage patterns:

- in-memory (process-local)
- durable run-record backed storage

Durable storage uses run records and optional index acceleration for O(1) lookup:

- index file: `.idempotency-index.json`

## Conflict Handling

On conflict, return a structured error with:

- `exitCode: 7`
- conflicting key
- conflicting run identifier (if known)
- actionable retry guidance
