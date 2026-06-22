# Lifecycle Validator Runtime Resolver

## Problem

Planner invoked Bash-dependent validators with an incompatible shell runtime.

## Goal

Resolve the repository-supported shell/runtime before lifecycle validator dispatch without weakening gates.

## Dependencies

- none

## Boundary

This child packet is planning lineage only until a later accepted implementation route. It does not implement durable behavior and does not authorize archive, cleanup, delivery, git mutation, PR creation, or `cleaned` claims.
