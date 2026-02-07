---
title: Add a New Flow
description: Recipe to add a new flow to the Harmony monorepo.
version: v1.0.0
date: 2025-11-21
---

# Recipe: Add a New Flow

Flows are graph-like processes (often implemented in LangGraph or similar) that the **platform runtime** executes. They are typically defined in Python and hosted under `platform/runtimes/flow-runtime/**` (or similar), and accessed via `contracts/*`.

Use this recipe when you want to add a new **flow** that Engines/Agents can call via the flow runtime.

---

## 1. When to add a Flow

Add a new Flow if:

- You have a multi-step process that benefits from:
  - explicit nodes/edges,
  - checkpointing,
  - retries,
  - and runtime-level policies.
- Multiple Agents/Engines might call it.
- It should be executed in the shared flow runtime for consistency and observability.

Don’t add a Flow if:

- It’s a simple sequence better handled inside an Engine or Kit.
- It’s tightly coupled to a single app and doesn’t need flow-runtime features.

---

## 2. Define the Flow contract

First, decide:

- **Inputs/outputs** (JSON-serializable).
- **What the Flow does** (high-level description).
- **Who will call it** (which Engines/Agents).

Add or extend a contract:

1. Update the relevant API spec in `contracts/` (OpenAPI/JSON Schema) to expose an endpoint for your flow, e.g.:

   - `POST /flows/my-flow/run` with `{ input: ... }` and `{ output: ... }`.

2. Regenerate clients:

   ```bash
   # whatever script you use for codegen
   pnpm generate:contracts

````

This should update:

- `contracts/ts` – TypeScript clients.
- `contracts/py` – Python clients.

---

## 3. Implement the Flow in the runtime

In `platform/runtimes/flow-runtime/**` (or equivalent):

1. Implement the Flow graph in Python (or your runtime language of choice).
2. Expose an entrypoint that matches the contract (input/output types).
3. Ensure:

   - Checkpointing and retries are set appropriately.
   - Logging/telemetry is wired into your observability stack.
   - Policies and budgets are respected.

Keep the Flow implementation focused on **execution**. Domain logic should still live in Kits/Engines when possible.

---

## 4. Wire Flow through Kits (optional but preferred)

It’s often best practice to expose flows through a Kit, especially if they’ll be used in multiple places.

Create or extend a Kit under `packages/kits`:

```ts
// packages/kits/flow-kit/src/my-flow.ts
import { flowClient } from "@/contracts/ts"; // example import

export interface MyFlowInput {
  // ...
}
export interface MyFlowOutput {
  // ...
}

export async function runMyFlow(input: MyFlowInput): Promise<MyFlowOutput> {
  const response = await flowClient.myFlowRun({ body: input });
  return response.data; // or however your client returns it
}
```

This hides the wire-level details from Engines and Agents.

---

## 5. Use the Flow in an Engine

In a relevant Engine (e.g. `work-engine`):

```ts
import { runMyFlow } from "@/packages/kits/flow-kit/src/my-flow";

export async function executeSomeStep(...) {
  const result = await runMyFlow({ /* input */ });
  // post-process result, handle errors, etc.
}
```

Now Engines get a simple function (`runMyFlow`) instead of thinking about contracts and APIs.

---

## 6. Use the Flow in an Agent (indirectly)

Agents should normally **not** call flows directly; they should go through Engines. If a specific agent truly needs direct access, wire it via Kits (and ideally Engines), not directly to `contracts/ts`.

Example in an Agent definition:

```ts
import { executeSomeStep } from "@/packages/engines/work-engine";

export async function handleSomething(...) {
  const result = await executeSomeStep(...);
  // ...
}
```

---

## 7. Update documentation and tests

- Add or update:

  - Flow-related docs under `docs/` (if needed).
  - Engine docs (if a new Engine capability).
- Add tests:

  - Runtime-level tests for the Flow (Python).
  - Kit-level tests for any wrappers.
  - Engine tests if behavior changes.

---

## 8. Checklist

- [ ] Flow contract added/updated in `contracts/`.
- [ ] TS and Python clients regenerated.
- [ ] Flow implemented in `platform/runtimes/flow-runtime/**`.
- [ ] (Preferred) A Kit exposes a nice wrapper for the Flow.
- [ ] Engine(s) call the Flow via Kits, not directly via raw HTTP.
- [ ] Agents use Engines (or Kits) to access the Flow, not raw runtime internals.
