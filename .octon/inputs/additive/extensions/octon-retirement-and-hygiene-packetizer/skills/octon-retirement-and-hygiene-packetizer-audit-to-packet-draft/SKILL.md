---
name: octon-retirement-and-hygiene-packetizer-audit-to-packet-draft
description: Run the audit-to-packet-draft flow.
metadata:
  author: Octon Framework
  updated: "2026-04-15"
skill_sets: [executor, integrator]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*) Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Audit To Packet Draft

Use this skill when you want structured `repo-hygiene` audit evidence turned
into:

- a reconciliation summary
- a non-authoritative `cleanup-packet-inputs.yml` draft
- an optional migration proposal draft

This flow may invoke `repo-hygiene audit`, but it must never write into the
live build-to-delete packet.
