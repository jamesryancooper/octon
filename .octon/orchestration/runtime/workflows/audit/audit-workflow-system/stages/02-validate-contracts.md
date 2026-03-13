---
name: validate-contracts
title: "Validate Contracts"
description: "Evaluate manifest, registry, workflow, and capability-map contract integrity."
---

# Step 2: Validate Contracts

## Purpose

Detect hard contract breakage before scoring or scenario rehearsals.

## Actions

1. Validate manifest, registry, and on-disk path parity.
2. Validate `execution_profile` alignment against workflow behavior and registry I/O.
3. Validate workflow entrypoints, declared step files, and frontmatter minimums.
4. Validate capability-map references and command uniqueness.

## Output

- Contract/schema findings
- Path and profile validation evidence

## Proceed When

- [ ] Contract integrity checks completed
- [ ] High-severity structural failures are surfaced as findings

## Idempotency

Contract validation is a deterministic static pass over the same inventory and must produce stable findings for the same input tree.
