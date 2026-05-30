# Implementation Plan

_Status: Parent coordination plan. Not implemented in this task._

## Profile Selection Receipt

- release_state: `pre-1.0`
- change_profile: `atomic`

## Program Steps

1. Complete child `proposal-program-runner-current-state-gap-map` before any
   implementation child applies changes.
2. Implement planning/replan loop and executor delegation slices before child
   scheduling, verification, cleanup, closeout, generated-state, or test slices
   depend on them.
3. Preserve route ownership and child authority in every child implementation.
4. Add tests and negative fixtures across all slices before claiming readiness
   for promotion, closeout, or archive.
5. Refresh generated state only through canonical scripts when authored-source
   changes require it.
6. Re-run program verification, child readiness, strict review gates, and
   handoff-only lifecycle checks after implementation but before closeout.

## Program Non-Implementation Boundary

This parent packet does not implement runner changes. It creates the governed
program and child packets for later lifecycle execution.
