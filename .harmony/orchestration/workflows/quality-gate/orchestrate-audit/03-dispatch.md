---
name: dispatch
title: "Dispatch"
description: "Launch parallel audit-migration skill instances, one per partition."
---

# Step 3: Dispatch

## Input

- Partition plan (from step 2)
- Validated manifest (from step 1)
- Scope, severity_threshold, structure_spec, template_dir (from step 1)

## Purpose

Launch parallel `audit-migration` skill instances, one per partition. Each instance receives the same manifest but a different `partition` label and `file_filter`. This is the parallelization step — all partitions run concurrently.

## Actions

1. **For each partition, launch a Task:**

   Each Task invocation runs the `audit-migration` skill with:

   - `manifest` = same manifest as the orchestration input
   - `scope` = same scope as orchestration input
   - `partition` = the partition label
   - `file_filter` = the partition's glob pattern
   - `severity_threshold` = same as orchestration input
   - `structure_spec` = same (if provided)
   - `template_dir` = same (if provided)

   Task prompt pattern:

   ```text
   Use skill: audit-migration
   manifest="{manifest}"
   scope="{scope}"
   partition="{partition_label}"
   file_filter="{file_filter}"
   severity_threshold="{severity_threshold}"
   ```

2. **Launch all Tasks in parallel:**

   Use the Task tool with multiple concurrent invocations. All partitions dispatch in a single message.

   If the Task tool is unavailable, fall back to sequential execution (run each partition one at a time in the same session).

3. **Collect Task results:**

   For each completed Task:

   - Verify the partition report was written to the expected path
   - Record: partition label, report path, status (success/failure)

4. **Handle failures:**

   - If a Task fails, record the failure with partition label and error
   - Continue with remaining partitions (do not abort all)
   - Failed partitions are flagged in the merge step

5. **Record dispatch results:**

   ```markdown
   | Partition | Status | Report Path |
   | --------- | ------ | ----------- |
   | docs | Success | .harmony/output/reports/2026-02-08-migration-audit-docs.md |
   | harmony-agency | Success | .harmony/output/reports/2026-02-08-migration-audit-harmony-agency.md |
   | harmony-capabilities | Failed | Error: context window exceeded |
   | ... | ... | ... |
   ```

## Idempotency

**Check:** All partition reports already exist at expected paths.

- [ ] For each partition, report file exists at `YYYY-MM-DD-migration-audit-{partition}.md`
- [ ] All existing reports match the current manifest (check idempotency metadata)

**If Already Complete:**

- Skip to step 4
- Re-run only failed partitions if some succeeded

**Marker:** `checkpoints/orchestrate-audit/03-dispatch.complete`

## Error Messages

- Task launch failure: "DISPATCH_FAILED: Could not launch Task for partition '{label}': {error}"
- All partitions failed: "DISPATCH_ALL_FAILED: No partition completed successfully"
- Task tool unavailable: "DISPATCH_SEQUENTIAL: Task tool unavailable, falling back to sequential execution"

## Output

- List of partition reports (paths)
- List of failed partitions (with errors)
- Dispatch summary

## Proceed When

- [ ] At least one partition report exists
- [ ] All partitions either succeeded or have documented failures
- [ ] Dispatch summary recorded
