# Implementation Plan

## Step 1: Select Alias Name

Use `octon-proposal-run-program-delivery` for command surfaces and "Run Program to Clean Delivery" as the operator-facing label.

## Step 2: Delegate To Canonical Delivery

Wire the alias to the existing `proposal-program-delivery` wrapper without adding an independent workflow.

## Step 3: Update Discovery Surfaces

Update command manifests, lifecycle extension command docs, and bundle matrix references so operators can find the alias.

## Step 4: Add Boundary Validation

Add validation proving the alias delegates, names the canonical wrapper, and does not bypass required input, verification, correction, closeout, archive, cleanup, or terminal proof gates.

## Step 5: Record Evidence

Record child-owned implementation, conformance, drift/churn, closeout, and no-authority-widening evidence.
