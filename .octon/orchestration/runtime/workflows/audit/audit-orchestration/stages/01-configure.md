---
name: configure
title: "Configure"
description: "Parse migration manifest, bounded-audit controls, and deterministic execution parameters."
---

# Step 1: Configure

## Input

- `manifest` (required)
- `scope` (default `.`)
- `severity_threshold` (default `all`)
- `strategy` (default `by-directory`)
- `post_remediation` (default `false`)
- `convergence_k` (default `3`)
- `seed_list` (optional; deterministic seed set)
- `run_cross_subsystem` (default `true`)
- `run_freshness` (default `true`)
- `max_age_days` (default `30`)

## Purpose

Build a finite audit plan with explicit taxonomy, threshold, coverage rules, and receipt metadata requirements.

## Actions

1. Parse and validate migration manifest (same validation as `audit-migration`).
2. Enumerate complete scope manifest, apply exclusions, sort deterministically.
3. Initialize coverage ledger with one row per in-scope file.
4. Resolve seed policy:
   - if `seed_list` provided, use it,
   - otherwise use deterministic defaults (`11,23,37`).
5. Build pass matrix:
   - Pass A: contract/schema invariants
   - Pass B: runtime/gates
   - Pass C: tests/CI/receipts
   - Pass D: docs/spec drift
6. Record run receipt baseline:
   - `commit_sha`, `scope_hash`, `prompt_hash`, `params_hash`, seed policy, fingerprint policy.
7. Verify required skills for enabled stages.

## Output

- Validated bounded-audit execution plan
- Scope manifest and initialized coverage ledger
- Pass matrix and seed policy
- Receipt baseline metadata

## Proceed When

- [ ] Manifest and scope are valid
- [ ] Coverage ledger initialized for all files
- [ ] Pass matrix and seed policy recorded
- [ ] Dependency checks pass
