---
name: octon-proposal-packet-lifecycle-create
description: Run the create-proposal-packet bundle.
license: MIT
compatibility: Octon proposal packet lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-04-30"
  updated: "2026-04-30"
skill_sets: [executor, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Proposal Packet Lifecycle Create

Normalize source context, classify the scenario, create a standard proposal
packet at the canonical active path, and validate it. Store source lineage in
`resources/**` and creation prompts in `support/**`. Preserve audit,
evaluation, and target-thesis traceability; create archive-ready structured
Markdown artifacts; and keep proposal-local material non-authoritative.
