# Overview

`octon-retirement-and-hygiene-packetizer` exists to close the operator gap
between detection and governed cleanup planning.

Current core surfaces already do the following:

- `repo-hygiene` detects and classifies findings
- `closeout-reviews.yml` defines the active build-to-delete packet
- `retirement-registry.yml` inventories registered transitional and historical
  targets
- `retirement-register.yml` marks claim-adjacent retained surfaces
- `claim-gate.yml` determines claim readiness

This pack adds one thing only: additive orchestration that joins those reads
into non-authoritative planning outputs.

## What Stays In Core

- authoritative hygiene classification policy
- authoritative retirement registry and register truth
- authoritative build-to-delete packet truth
- authoritative claim-gate truth
- destructive decisions and same-change updates

## What This Pack Adds

- one composite dispatcher
- four stable leaf planning flows
- reusable draft templates
- validation proving protected and claim-adjacent surfaces stay out of
  delete-safe outcomes
