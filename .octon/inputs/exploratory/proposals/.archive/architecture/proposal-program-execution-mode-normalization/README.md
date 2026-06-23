# Proposal Program Execution Mode Normalization

## Problem

Parent manifests and child registries used inconsistent execution-mode vocabulary such as sequenced-gated and gated-parallel.

## Goal

Normalize or alias execution modes across program manifests, registries, contracts, validators, and planner code.

## Dependencies

- lifecycle-validator-runtime-resolver

## Boundary

This child packet is planning lineage only until a later accepted implementation route. It does not implement durable behavior and does not authorize archive, cleanup, delivery, git mutation, PR creation, or `cleaned` claims.
