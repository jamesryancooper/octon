# Implementation Plan

## Step 1: Extend CLI Options

Add optional `--max-steps`, `--timeout-seconds`, and
`--max-child-concurrency` fields to the `lifecycle program retry` command.

## Step 2: Thread Retry Options

Update lifecycle command dispatch and program retry execution so supplied
options override retained checkpoint execution limits for that retry attempt.
Omitted options must preserve current behavior.

## Step 3: Preserve Binding and Gates

Verify that retry option overrides still pass through existing checkpoint
binding, cancellation, worktree baseline, dependency, approval, freshness,
authority, and child-owned evidence checks.

## Step 4: Add Regression Tests

Add focused kernel tests proving default compatibility, explicit multi-step
retry, child-filter compatibility, and failure to bypass binding or authority
boundaries.

## Step 5: Update Documentation

Update lifecycle extension documentation so operators know when to use
`lifecycle program retry --max-steps` and when to keep one-step retry behavior.

## Step 6: Record Evidence

Record implementation-run, implementation-conformance, drift/churn, and
validation receipts before closeout.

