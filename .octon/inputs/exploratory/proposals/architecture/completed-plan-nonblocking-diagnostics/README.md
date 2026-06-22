# Completed Plan Nonblocking Diagnostics

## Problem

Completed archived parent plans showed stale nonblocking receipt digests as if they were actionable.

## Goal

Move irrelevant stale receipt data into compact nonblocking diagnostics when final_verdict is completed.

## Dependencies

- normalized-child-terminal-evidence-summary

## Boundary

This child packet is planning lineage only until a later accepted implementation route. It does not implement durable behavior and does not authorize archive, cleanup, delivery, git mutation, PR creation, or `cleaned` claims.
