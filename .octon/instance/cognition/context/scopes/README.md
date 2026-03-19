# Scope Context

`/.octon/instance/cognition/context/scopes/` is the canonical repo-instance
home for durable scope-local context.

## Purpose

- keep scope-specific durable context separate from shared repo context
- bind durable context to a declared `scope_id`
- keep mutable continuity and generated summaries out of `instance/**`

## Boundary Rules

- each child directory must match a declared locality `scope_id`
- durable authored context belongs here under `instance/**`
- mutable scope continuity belongs under `state/continuity/scopes/**` only
  after Packet 7 lands
- generated cognition summaries do not belong here
