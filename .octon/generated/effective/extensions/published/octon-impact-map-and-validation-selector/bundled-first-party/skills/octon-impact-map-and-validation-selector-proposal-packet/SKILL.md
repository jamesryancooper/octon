---
name: octon-impact-map-and-validation-selector-proposal-packet
description: >
  Analyze one proposal packet, resolve its subtype from proposal manifests,
  select the packet-kind validation floor, and recommend the next canonical
  route.
license: MIT
compatibility: Designed for Octon extension-pack publication and host projection.
metadata:
  author: Octon Framework
  created: "2026-04-15"
  updated: "2026-04-15"
skill_sets: [executor, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Proposal Packet Impact Map

Use this skill when the only primary input is `proposal_packet`.

Required result:

- resolve packet kind from `proposal.yml` plus the subtype manifest
- never use generated proposal registry outputs as lifecycle authority
- select the packet-kind validation floor from existing validators and audits
- recommend refresh, supersession, audit, or implementation follow-up
