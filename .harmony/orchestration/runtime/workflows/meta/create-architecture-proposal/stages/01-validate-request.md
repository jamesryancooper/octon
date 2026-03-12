---
title: Validate Architecture Proposal Request
description: Validate inputs, package id format, class, and target path.
---

# Step 1: Validate Architecture Proposal Request

## Purpose

Confirm that the request can produce one valid standard-governed architecture proposal
under `/.proposals/architecture/`.

## Actions

1. Validate `proposal_id` against `^[a-z][a-z0-9-]*$`.
2. Validate `package_class` as `domain-runtime` or `experience-product`.
3. Parse `promotion_targets` as one or more repo-relative durable paths.
4. Resolve target package path:
   `.proposals/architecture/<proposal_id>/`
5. Stop if the target package directory already exists.

## Proceed When

- [ ] Package id format is valid
- [ ] Package class is valid
- [ ] Implementation targets are non-empty
- [ ] Target package path is free
