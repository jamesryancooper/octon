---
name: dispatch
title: "Dispatch"
description: "Launch parallel partition x pass jobs with deterministic receipts."
---

# Step 3: Dispatch

## Purpose

Run a bounded multi-pass matrix in one job: each partition is audited across required passes and seeds.

## Actions

1. For each partition, run passes A-D independently (lens isolation).
2. For each pass, execute with deterministic seed policy.
3. Capture per-run receipt fragment:
   - `partition`, `pass`, `seed`, `findings_hash`, `status`, `report_path`.
4. Continue through partial failures; do not abort all jobs unless all fail.

## Output

- Partition/pass receipt set
- Raw pass reports
- Dispatch status matrix

## Proceed When

- [ ] At least one partition/pass result exists
- [ ] Failures are documented with impact scope
