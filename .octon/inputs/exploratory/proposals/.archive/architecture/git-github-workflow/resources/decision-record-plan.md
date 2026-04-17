# Decision Record Plan

## Durable landing posture

If this packet is accepted, the durable decisions should land primarily by
updating the existing authoritative workflow surfaces rather than by creating a
new top-level ADR family.

The required durable changes live in:

- ingress manifest and ingress `AGENTS.md`
- workflow practice docs
- remediation skill
- helper scripts

## When to add a decision record

Add or update a cognition decision only if implementation introduces a durable
rule that is broader than the workflow surfaces themselves, for example:

- a reusable ingress schema for contextual closeout gates
- a repo-wide doctrine about helper-script versus readiness semantics
- a long-lived rule for worktree-directory cleanup behavior

## Same-branch alignment expectation

If the packet is implemented, the implementing branch should update all of the
following together:

- Octon-internal promotion targets from `proposal.yml`
- companion PR-template wording outside `/.octon/**`
- parity adapters only if ingress wording changes require projection refresh

## Explicit non-goal

This packet does not propose a constitutional amendment. It stays within the
existing constitutional and workspace-charter posture.
