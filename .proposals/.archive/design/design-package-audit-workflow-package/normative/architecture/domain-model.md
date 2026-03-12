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
- `Run State`
  - lifecycle status for the overall workflow execution
  - constrains whether later stages may start
- `Stage State`
  - lifecycle status for one selected stage
  - becomes authoritative only after the report is persisted
- `Bundle`
  - bounded workflow output directory containing reports, prompt packets, logs,
    metadata, and validation state
- `Prompt Packet`
  - rendered input envelope passed to one stage executor invocation
- `Execution Lock`
  - exclusive ownership marker for file-writing access to one target package
- `Change Manifest`
  - explicit record of file mutations for file-writing stages
- `Readiness Verdict`
  - final workflow or package status derived from validation results

## Relationships

- a `Workflow Run` operates on exactly one `Target Package`
- a `Workflow Run` selects exactly one `Mode`
- a `Mode` expands to an ordered set of `Stage` instances
- a `Workflow Run` owns exactly one `Run State`
- each selected `Stage` owns exactly one `Stage State`
- each selected `Stage` produces one stage report in the `Bundle`
- each selected `Stage` produces one `Prompt Packet` and one stage log
- file-writing stages require exclusive `Execution Lock` ownership of the target
  package
- file-writing `Stage` instances must produce a `Change Manifest` or explicit
  zero-change receipt
- a `Bundle` produces one final `Readiness Verdict`
