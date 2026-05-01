---
name: octon-proposal-packet-lifecycle-closeout
description: Run the closeout-proposal-packet bundle.
license: MIT
compatibility: Octon proposal packet lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-04-30"
  updated: "2026-04-30"
skill_sets: [executor, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Bash(git status) Bash(git diff) Bash(gh pr) Write(/.octon/inputs/exploratory/proposals/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Proposal Packet Lifecycle Closeout

Execute gated closeout for one proposal packet. Refuse closeout when required
checks, review conversations, evidence, staging, archive, or sync gates fail.
