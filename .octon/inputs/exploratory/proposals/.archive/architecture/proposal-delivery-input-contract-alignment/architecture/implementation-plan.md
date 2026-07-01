# Implementation Plan

## Step 1: Inventory Contract Claims

Compare delivery input requirements across workflow YAML, workflow README files, runtime commands, runtime skills, product contracts, validators, lifecycle contracts, and extension command docs.

## Step 2: Choose Canonical Semantics

For each delivery input, select one of:

- required before workflow admission;
- derived by a named preflight route;
- optional with explicit fallback behavior.

## Step 3: Align Surfaces

Update only canonical Octon surfaces listed in promotion targets so they describe the same input contract.

## Step 4: Add Validation

Add tests or validator coverage for required input acceptance, required input rejection, valid resume evidence, and packet/program differences.

## Step 5: Record Evidence

Write child-owned implementation, conformance, drift/churn, and closeout evidence. Parent evidence may summarize the result but must not satisfy this child.
