# Batched Review And Architecture Digest Refresh

## Problem

Review and strict architecture receipts became stale after small support mutations.

## Goal

Batch digest refresh after phase-stable mutations and provide deterministic stale-cause diagnostics.

## Dependencies

- targeted-proposal-freshness-checks

## Boundary

This child packet is planning lineage only until a later accepted implementation route. It does not implement durable behavior and does not authorize archive, cleanup, delivery, git mutation, PR creation, or `cleaned` claims.
