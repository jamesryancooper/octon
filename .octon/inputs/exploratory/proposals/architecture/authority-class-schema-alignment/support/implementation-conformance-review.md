# Implementation Conformance Review Scaffold

status: not-run

## Purpose

After durable implementation lands, verify that promoted schema and mechanism
index changes match this child packet.

## Required Checks

- Promotion targets match the child manifest.
- Product catalog remains navigation-only.
- `state/control/**` remains mutable operational truth.
- `state/evidence/**` remains retained evidence.
- Generated operator read model remains distinct from generated-effective
  non-authority.
