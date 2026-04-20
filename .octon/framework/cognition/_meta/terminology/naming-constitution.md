---
title: Octon Naming Constitution
description: Canonical terminology authority for Octon's whole-system and execution-core naming.
status: Active
---

# Octon Naming Constitution

## Purpose

Define the canonical naming rules for Octon as a whole, for its execution
core, and for the related runtime, governance, state, memory, evidence, and
assurance vocabulary used across durable authored authority surfaces.

## Authority And Scope

This document is the normative terminology authority for durable authored
terminology under `/.octon/**`. It is subordinate to the constitutional kernel
and aligns with the umbrella architecture specification. Use this constitution
to keep documentation, specs, schemas, comments, and operator-facing guidance
from collapsing distinct concepts into ambiguous language.

Terminology changes must not mint new authority, widen support claims, or
introduce new class roots, control roots, or execution semantics.

## Top-Level Naming Decision

The canonical classification for the whole system is:

> **Constitutional Engineering Harness**

The canonical classification for Octon's execution core is:

> **Governed Agent Runtime**

The canonical classification for the live operating entity is:

> **Agent**

The canonical classification for the cognition engine is:

> **Model**

The canonical one-sentence form is:

> **Octon is a Constitutional Engineering Harness whose execution core is a Governed Agent Runtime.**

## Core Principle

An agent is not the model alone. An agent is the live composite produced when
a model operates inside a governed runtime under an agent definition, with
scoped capabilities, active state, and a current objective.

Therefore:

- **Model** is cognition.
- **Agent Definition** is the static role and configuration contract.
- **Governed Agent Runtime** is the governed execution machinery.
- **Constitutional Engineering Harness** is Octon's whole-system
  constitutional, governance, runtime, assurance, observability, evidence,
  and engineering substrate.
- **Agent** is the operational composite in execution.

## Preferred Terms

Use these terms as the canonical vocabulary in durable documentation, specs,
schemas, comments, and operator-facing guidance:

- **Constitutional Engineering Harness**
- **Governed Agent Runtime**
- **Model**
- **Agent Definition**
- **Agent**
- **Objective**
- **Capability Surface**
- **Capability Pack**
- **Governance Policy**
- **Control Plane**
- **Execution Plane**
- **Sandbox**
- **Session**
- **Run**
- **Mission**
- **State**
- **Memory**
- **Working Context**
- **Evidence**
- **Provenance**
- **Assurance**
- **HarnessCard**
- **RunCard**

## Controlled Aliases

The following terms may appear only as secondary, backward-compatible, or
externally familiar labels:

| Alias | Allowed use | Required boundary |
| --- | --- | --- |
| **Harness** | Short form after **Constitutional Engineering Harness** has already been established. | Must not imply a prompt wrapper or runtime-only layer. |
| **Octon Harness** | Legacy-friendly shorthand for the full system. | Prefer **Constitutional Engineering Harness** in new canonical text. |
| **governed autonomous engineering harness** | Transitional legacy phrase found in historical wording. | Replace with **Constitutional Engineering Harness** in new canonical text. |
| **Agent Harness** | External-facing comparison term for the execution core when needed. | Must not name the whole of Octon. Prefer **Governed Agent Runtime**. |
| **Runtime** | Shorthand for **Governed Agent Runtime** once established. | Must not include constitution, lab, assurance, or proposal lifecycle unless explicitly expanded. |
| **Orchestrator** | Specific coordination component or role. | Must not name the whole runtime or harness. |

## Banned Primary Terms

These terms are banned as primary names for Octon or its execution core:

- **Model Harness**
- **Model Wrapper**
- **Prompt Wrapper**
- **Scaffold**
- **Framework**
- **Bot**
- **Assistant**
- **System Prompt**
- **Orchestrator** as a whole-system name
- **Control Plane** as a whole-system name
- **Agent Harness** as a whole-system name
- **Platform** as the canonical architecture classification

These terms may appear only in explanatory contrast, migration notes,
historical references, or external comparison sections.

## Exact Usage Rules

### Rule 1: Use **Constitutional Engineering Harness** for Octon as a whole

Correct:

> Octon is a Constitutional Engineering Harness.

Incorrect:

> Octon is a model harness.

### Rule 2: Use **Governed Agent Runtime** for Octon's execution core

Correct:

> Octon's execution core is a Governed Agent Runtime.

Incorrect:

> The Governed Agent Runtime is all of Octon.

### Rule 3: Never call the model the agent

Correct:

> The model provides cognition inside the agent.

Incorrect:

> The model is the agent.

### Rule 4: Use **Agent Definition** for static role and configuration contracts

Correct:

> The code-repair Agent Definition binds the repo and shell Capability Packs.

Incorrect:

> The code-repair agent file is the agent.

### Rule 5: Use **Agent** only for the live operational composite

Correct:

> The agent resumed the run after operator intervention.

Incorrect:

> The YAML file is the agent.

### Rule 6: Distinguish **Capability Surface** from **Capability Pack**

Correct:

> Browser, shell, API, repo, and filesystem are capability surfaces. The run
> received the repo and shell Capability Packs.

Incorrect:

> The agent can use every runtime capability because the surface exists.

### Rule 7: Distinguish **Control Plane** from **Execution Plane**

Correct:

> The control plane granted authorization; the execution plane performed the
> operation.

Incorrect:

> The control plane wrote the patch.

### Rule 8: Distinguish **State** from **Memory**

Correct:

> Run status, approvals, revocations, checkpoints, and pending actions are
> state. Retained reusable repo knowledge is memory.

Incorrect:

> The transcript is state and memory.

### Rule 9: Distinguish **Working Context** from **Memory**

Correct:

> Working context is the assembled in-scope material for this model step.

Incorrect:

> The model's context window is the memory layer.

### Rule 10: Distinguish **Evidence** from **Provenance**

Correct:

> Evidence proves what happened. Provenance shows where an output, claim, or
> decision came from.

Incorrect:

> Provenance is just logging.

### Rule 11: Use **Run** as the atomic consequential execution unit

Correct:

> The run contract is the atomic consequential execution path.

Incorrect:

> Mission is the atomic execution unit.

### Rule 12: Use **Mission** only for long-horizon continuity

Correct:

> The mission coordinates multiple runs toward a long-horizon objective.

Incorrect:

> Every one-off action is a mission.

### Rule 13: Do not blanket-replace **harness**

**Harness** remains valid in **Constitutional Engineering Harness**,
**HarnessCard**, historical labels, and established umbrella naming. The
intended migration is not a destructive replacement of every `harness` token.

### Rule 14: Do not widen live support claims through terminology

Terminology changes must not imply newly admitted support targets, new
capability surfaces, or broader autonomy modes. Support claims remain bounded
by support-target declarations, governance exclusions, and evidence
obligations.

### Rule 15: Canonical terminology files must stand alone

The naming constitution and glossary must remain self-contained durable
authority surfaces. They may cite other durable authority, but they must not
depend on proposal-local paths for their meaning.

## Transitional Language

Use this note where a short migration explanation is needed:

> Historical Octon text may use **Octon Harness**, **Harness**, or
> **governed autonomous engineering harness**. New canonical text should
> classify the whole system as a **Constitutional Engineering Harness** and
> its execution core as a **Governed Agent Runtime**.

## Examples

### Correct

- Octon is a Constitutional Engineering Harness.
- Octon's execution core is a Governed Agent Runtime.
- A model provides cognition inside an agent.
- An Agent Definition supplies role, objectives, policies, and capability
  bindings.
- A Capability Pack grants a scoped subset of the broader Capability Surface.
- The control plane authorizes and the execution plane acts.
- Run state is checkpointed before material execution.
- Evidence proves what happened; provenance explains where it came from.

### Incorrect

- Octon is a Model Harness.
- The model is the agent.
- Mission is the atomic execution unit.
- The control plane performed the tool call.
