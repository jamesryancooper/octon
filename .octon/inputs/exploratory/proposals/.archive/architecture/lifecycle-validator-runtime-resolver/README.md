# Lifecycle Validator Runtime Resolver

## Problem

Planner invoked Bash-dependent validators with an incompatible shell runtime.

## Goal

Resolve the repository-supported shell/runtime before lifecycle validator dispatch without weakening gates.

## Dependencies

- none

## Boundary

This child packet has been returned to in-review after blocked closeout evidence. Existing implementation and closeout receipts remain proposal-local history, but this revision does not authorize archive, cleanup, delivery, git mutation, PR creation, publication, or `cleaned` claims without a later accepted review and fresh child-owned terminal evidence.
