# Domain Model

## Purpose

Define the core objects used by the architecture-validation workflow.

## Core Entities

- `Target Package`
  - a temporary design package under `/.design-packages/`
  - contains prompts, contract docs, and implementation guidance
- `Workflow Run`
  - one execution of `audit-design-package`
  - parameterized by `package_path`, `mode`, and `executor`
- `Mode`
  - `rigorous` or `short`
  - determines the selected stage set
- `Stage`
  - one ordered execution unit with a report contract
  - may be evaluative, file-writing, or implementation-guidance
- `Bundle`
  - bounded workflow output directory containing reports, prompt packets, logs,
    metadata, and validation state
- `Change Manifest`
  - explicit record of file mutations for file-writing stages
- `Readiness Verdict`
  - final workflow or package status derived from validation results

## Relationships

- a `Workflow Run` operates on exactly one `Target Package`
- a `Workflow Run` selects exactly one `Mode`
- a `Mode` expands to an ordered set of `Stage` instances
- each selected `Stage` produces one stage report in the `Bundle`
- file-writing `Stage` instances must produce a `Change Manifest` or explicit
  zero-change receipt
- a `Bundle` produces one final `Readiness Verdict`
