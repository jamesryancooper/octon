---
title: Workflow Gap Remediation Guide
description: Gap reference for directory and single-file workflow contracts.
---

# Workflow Gap Remediation Guide

This guide describes the workflow gaps that the shared evaluator and Workflow
System Audit look for. Some gaps apply differently to directory and single-file
workflows.

## Gap Summary

| Gap | Directory Workflow Expectation | Single-File Workflow Expectation |
|-----|-------------------------------|----------------------------------|
| Idempotency | Per-step `## Idempotency` guidance | Inline rerun/skip guidance |
| Dependencies | `depends_on` or explicit dependency notes | Explicit upstream assumptions |
| Branching | Declared branch or merge behavior | Inline conditional flow guidance |
| Checkpoints | `checkpoints` config and resumable steps | Resume/re-entry guidance if long-running |
| Versioning | `version` plus Version History | Version metadata or clear maintenance state |
| Parallelism | `parallel_steps` or explicit N/A | Explicitly state when work is sequential |
| Verification | Final verify step or verification gate | `Required Outcome` or equivalent verification section |

## 1. Idempotency

### Directory workflows

- Each step should say how to detect prior completion.
- Re-runs should either skip safely or explain cleanup-first behavior.

### Single-file workflows

- The workflow should explain whether it is safe to rerun.
- If the flow is interactive or stateful, call out how to resume without duplicating work.

## 2. Dependencies

### Directory workflows

- Use `depends_on` when upstream workflows are real prerequisites.
- Avoid circular workflow dependencies.

### Single-file workflows

- If the workflow assumes prior setup, say so explicitly in Prerequisites or Context.

## 3. Branching

### Directory workflows

- If the path diverges, say where and why.
- Make merge points explicit.

### Single-file workflows

- Inline conditional paths should be spelled out in the flow narrative.

## 4. Checkpoints and Resumption

### Directory workflows

- `checkpoints.enabled: true` with a storage path is the default expectation.
- Step-level idempotency should make resumption safe.

### Single-file workflows

- A long or interruptible workflow should explain how to resume at the right point.

## 5. Versioning

- Actively maintained workflows should record a `version` and a Version History section.
- If a workflow is intentionally lightweight and not fully versioned, that should be visible rather than implicit.

## 6. Parallelism

- Document parallel groups when they are real.
- If a workflow is intentionally sequential, an explicit empty or narrative “no parallel work” explanation is acceptable.

## 7. Verification

- Directory workflows should end in a verify step or explicit verification gate.
- Single-file workflows should have a `Required Outcome`, `Verification Gate`, or equivalent section describing success criteria.

## How the Shared Evaluator Uses This Guide

- Missing gap controls lower workflow scores.
- Missing verification, malformed contracts, or dependency cycles can escalate into findings.
- System-level audits also look for gap blindness in the validator path itself.
