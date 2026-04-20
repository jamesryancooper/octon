---
title: Octon Terminology Glossary
description: Canonical definitions for Octon's whole-system, runtime, governance, and traceability terms.
status: Active
---

# Octon Terminology Glossary

## Purpose

Define the canonical meaning of Octon's core terminology so durable authority
surfaces use the same words for the same concepts.

Use the companion naming constitution for normative term-selection rules and
alias boundaries. Use this glossary for definitions.

## Canonical System Terms

### Constitutional Engineering Harness

The whole Octon system: constitutional kernel, governance, runtime, assurance,
observability, lab, evidence, state, generated projections, and
engineering-oriented action surfaces.

Use for Octon as a whole.

### Governed Agent Runtime

Octon's execution core: the durable runtime that assembles context, mediates
capability use, enforces policy, coordinates execution, records state, accepts
intervention, supports rollback and recovery, and retains evidence.

Use for the runtime core, not for the whole of Octon.

### Harness

Controlled shorthand for **Constitutional Engineering Harness** after the full
term has been established, or for retained terms such as **HarnessCard**. Do
not use as a vague synonym for prompt, model, framework, or orchestrator.

## Agent Terms

### Model

The reasoning and generation engine. The model supplies cognition but is not
the agent by itself.

### Agent Definition

A static role and configuration contract that specifies objectives, behavioral
instructions, allowed capability packs, policy bindings, escalation behavior,
model routing, and success criteria.

### Agent

The live operational composite produced when a model executes inside the
Governed Agent Runtime under an Agent Definition, with active state, scoped
capabilities, and a current objective.

### Objective

The immediate outcome a run or agent is pursuing.

## Capability And Runtime Terms

### Capability Surface

The total universe of actions the runtime can potentially expose, such as
repo, shell, filesystem, browser, UI, API, retrieval, telemetry, and
multimodal surfaces.

### Capability Pack

A scoped, governed bundle of allowed actions granted to an Agent Definition,
run, mission, or execution route.

### Tool

A concrete callable operation or integration exposed through a capability
pack. Tool availability does not bypass capability-pack governance.

### Sandbox

The isolated environment where execution occurs.

### Control Plane

The governance subsystem that handles authorization, approvals, limits,
revocations, policy evaluation, escalation, oversight, and audit controls.

### Execution Plane

The work-performing subsystem that dispatches actions, calls tools, executes
workflow stages, retries, and advances state transitions.

### Governance Policy

Durable rules and constraints that determine which actions are allowed,
denied, escalated, or gated.

## Continuity Terms

### Run

The atomic consequential execution unit. Run contracts are the canonical
boundary for material execution.

### Mission

A longer-horizon continuity container that can coordinate or relate multiple
runs.

### Session

A bounded live interaction or active execution window.

### State

Authoritative operational truth needed to control, continue, pause, resume, or
recover execution.

### Memory

Intentionally retained reusable knowledge across sessions or runs.

### Working Context

The material assembled into the model's current context for a particular step
or turn.

## Traceability Terms

### Evidence

Retained proof of what happened: receipts, traces, logs, artifacts, outputs,
validation results, decisions, and replay material.

### Provenance

Lineage showing where an output, claim, artifact, decision, or state
transition came from.

### Assurance

The validation and verification discipline used to prove correctness,
reliability, policy conformance, recoverability, and safety.

### RunCard

A disclosure artifact for an execution run, subordinate to durable authority
and retained evidence.

### HarnessCard

A disclosure artifact for harness-level lab or assurance evidence, subordinate
to durable authority and retained evidence.

## Deprecated Or Bounded Terms

### Model Harness

Banned as a primary term. It is too model-centric and under-describes
governance, continuity, capability control, and runtime execution.

### Agent Harness

Allowed only as external-facing comparison language for the execution core. Do
not use as Octon's whole-system classification.

### Scaffold

Banned as a primary term. It is too temporary and lightweight for Octon's
constitutional, assurance, and governance surfaces.

### Framework

Banned as a primary classification for Octon. It is too broad and
underspecified.

### Bot / Assistant

Banned as primary architecture terms. They are interface-centric and do not
describe Octon's governed execution substrate.

### Orchestrator

Valid only for a coordination component or role. Banned as a whole-system
name.

### Platform

Avoid as a primary architecture classification. It may be used in product or
deployment discussions only when the architecture classification has already
been stated.
