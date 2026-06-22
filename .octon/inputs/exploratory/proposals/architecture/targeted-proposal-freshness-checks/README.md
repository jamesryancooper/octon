# Targeted Proposal Freshness Checks

## Problem

Full registry and terminal freshness checks were rerun after small proposal-local mutations.

## Goal

Add safe targeted freshness checks for one proposal plus dependency refs while retaining full registry as final gate.

## Dependencies

- complete-program-blocker-vector-planner-output

## Boundary

This child packet is planning lineage only until a later accepted implementation route. It does not implement durable behavior and does not authorize archive, cleanup, delivery, git mutation, PR creation, or `cleaned` claims.
