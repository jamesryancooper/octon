---
title: Documentation Index
description: Index of the Harmony architecture documentation.
version: v1.0.0
date: 2025-11-21
---

# Documentation Index

Welcome! This folder contains the key architecture docs and implementation recipes for this repo.

If you’re new here, start with **Architecture Overview**, then dive into **Engines**, **Agents & Factories**, and the **Run vs Import** rule. Use the **Recipes** when you’re actually building things.

---

## 1. Start Here

- **[Architecture Overview](architecture/overview.md)**  
  High-level map of the system:
  - Run vs import (runtime plane vs control/knowledge plane)
  - Where `apps/`, `/agents/`, `platform/runtimes/*-runtime`, and `packages/*` fit
  - End-to-end examples of how a request flows through Agents → Engines → Kits → runtimes

---

## 2. Core Architecture Guides

These explain the main abstractions you’ll work with.

- **[Engines Design Guide](architecture/engines.md)**  
  - What an Engine is (and isn’t)  
  - When to use a Kit vs Engine vs Agent vs Runtime  
  - Engine catalog (PlanEngine, WorkEngine, ContextEngine, GovernanceEngine, ReleaseEngine, KaizenEngine)  
  - How to design and implement a new Engine

- **[Agents & Factories Guide](architecture/agents-and-factories.md)**  
  - TS Agents in `packages/agents` (specs, definitions, governance, factories)  
  - Python agent runtimes in `/agents`  
  - How apps instantiate Agents via factories  
  - How Agents call Engines and Kits

- **[Run vs Import Guideline](architecture/run-vs-import.md)**  
  - The core rule: anything you run lives at the top level; anything you import lives under `packages/`/`contracts/`  
  - Where new code should go  
  - Good/bad examples and a pre-PR checklist

---

## 3. Recipes (How to Add X)

Use these when you’re actually changing the system.

### Capabilities & Subsystems

- **[Add a Kit](recipes/add-kit.md)**  
  For adding a new focused capability under `packages/kits/*` (e.g., new query helper, eval scorer, etc.).

- **[Add an Engine](recipes/add-engine.md)**  
  For introducing a new subsystem under `packages/engines/*` that orchestrates multiple Kits with policies, budgets, and observability.

### Agents & Flows

- **[Add an Agent](recipes/add-agent.md)**  
  For defining a new TypeScript Agent in `packages/agents`:
  - `specs/`, `definitions/`, `governance/`, `factories/`
  - Plus wiring it into an app.

- **[Add a Flow](recipes/add-flow.md)**  
  For creating a new flow executed by the platform flow runtime:
  - Define contracts
  - Implement the flow in `platform/runtimes/flow-runtime/**`
  - Wrap it in a Kit
  - Use it from an Engine/Agent

### Platform Runtimes

- **[Add a Runtime Service](recipes/add-runtime-service.md)**  
  For adding a new shared runtime under `platform/runtimes/*-runtime/**`:
  - Define responsibility and API in `contracts/`
  - Implement the runtime (server, executor, policies, observability)
  - Expose it via Kits and Engines

---

## 4. Suggested Reading Order

If you’re onboarding or designing something new:

1. **Architecture Overview**  
2. **Run vs Import Guideline**  
3. **Engines Design Guide**  
4. **Agents & Factories Guide**  
5. Relevant **Recipe(s)** for what you’re building (Kit, Engine, Agent, Flow, Runtime Service)

---

## 5. Keeping Docs Up to Date

When you:

- Add a new Engine → update the **Engines Design Guide** and/or mention it here.  
- Add a major Agent or runtime → consider adding a short note or link in this index.  
- Change repo layout conventions → update **Architecture Overview** and **Run vs Import**.

This index is meant to stay small and practical—just enough to point people to the right deeper docs.
