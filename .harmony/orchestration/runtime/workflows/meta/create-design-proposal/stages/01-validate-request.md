---
title: Validate Design Package Request
description: Validate inputs, package id format, class, and target path.
---

# Step 1: Validate Design Package Request

## Purpose

Confirm that the request can produce one valid standard-governed design proposal
under `/.proposals/design/`.

## Actions

1. Validate `proposal_id` against `^[a-z][a-z0-9-]*$`.
2. Validate `proposal_class` as `domain-runtime` or `experience-product`.
3. Parse `promotion_targets` as one or more repo-relative durable paths.
4. Resolve target package path:
   `.proposals/design/<proposal_id>/`
5. Stop if the target package directory already exists.

## Proceed When

- [ ] Package id format is valid
- [ ] Package class is valid
- [ ] Implementation targets are non-empty
- [ ] Target package path is free
