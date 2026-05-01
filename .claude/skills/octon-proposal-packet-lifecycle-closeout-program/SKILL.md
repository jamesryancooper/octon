---
name: octon-proposal-packet-lifecycle-closeout-program
description: Run the closeout-proposal-program bundle.
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

# Proposal Packet Lifecycle Closeout Program

Execute gated program closeout after required child lifecycle states are
implemented, archived, rejected, superseded, or explicitly deferred.
