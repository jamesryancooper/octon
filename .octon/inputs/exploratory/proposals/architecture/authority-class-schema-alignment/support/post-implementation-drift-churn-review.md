# Post-Implementation Drift And Churn Review Scaffold

status: not-run

## Purpose

After durable implementation lands, verify that the change did not introduce
authority-class drift, stale catalog language, or unnecessary churn.

## Required Checks

- No proposal-local path is retained by promoted targets.
- No raw input or generated output becomes authority.
- No compatibility-only surface is treated as steady-state runtime authority.
