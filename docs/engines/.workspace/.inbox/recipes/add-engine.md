---
title: Add a New Engine
description: Recipe to add a new engine to the Harmony monorepo.
version: v1.0.0
date: 2025-11-21
---

# Recipe: Add a New Engine

Engines are **subsystems built from Kits** that own a **domain capability end-to-end** (e.g. planning, execution, RAG, governance, release, Kaizen). They live under `packages/engines/*` and are import-only.

Use this recipe when you need to centralize **cross-kit orchestration + governance** that is or will be used by multiple Agents/surfaces.

---

## 1. When to create an Engine

Create an Engine if:

- Multiple Agents or apps are orchestrating **the same set of Kits** in similar ways.
- That orchestration needs:
  - budgets,
  - policies,
  - evals,
  - traceability.
- You want a named subsystem like “Planning”, “RAG/Context”, “Governance”, “Release”, “Kaizen”.

Do **not** create an Engine if:

- It’s just a thin wrapper around one Kit method → stay a Kit.
- Only one Agent uses the behavior, and it’s unlikely to be reused → keep it in the Agent definition first.

> **Sanity check:** If your new Engine could be described as “a slightly bigger helper around one Kit”, or if it needs to span planning, RAG, governance, and release all at once, it is probably either still just a Kit or actually several Engines that should be split.

---

## 2. Choose a name and location

Pick a domain name + `-engine`, e.g.:

- `plan-engine/`, `work-engine/`, `context-engine/`,
- `governance-engine/`, `release-engine/`, `kaizen-engine/`.

Create the folder:

```bash
mkdir -p packages/engines/<engine-name>/src
mkdir -p packages/engines/<engine-name>/tests
````

---

## 3. Define scope & API (before coding)

Write down:

- **Responsibility**:

  - “`PlanEngine` is responsible for turning goals/specs into governed plans.”
- **Non-goals**:

  - “It does not execute plans or ship changes.”
- **Callers**:

  - Which Agents/surfaces will use it.
- **Planned public API**:

  - Function names and types, e.g. `generatePlan`, `refinePlan`, `summarizePlanHistory`.

Start small (1–3 functions).

---

## 4. Create the Engine skeleton

Recommended structure:

```text
packages/engines/<engine-name>/
  src/
    index.ts           # public API: types + exported functions
    core.ts            # main orchestration logic
    policy.ts          # risk modes & budgets
    observability.ts   # logging/tracing/metrics helpers
    types.ts           # shared types & interfaces
    adapters.ts        # (optional) helpers to call Kits or contracts
  tests/
    <engine-name>.spec.ts
```

### `src/types.ts`

Define Engine-specific inputs/outputs:

```ts
export type RiskMode = "low" | "medium" | "high";

export interface PlanEngineInput {
  goal: string;
  contextRef?: string;
  risk: RiskMode;
  traceId?: string;
}

export interface PlanEngineOutput {
  plan: any; // Replace with PlanKit types
  evalResults: any;
  policyContext: any;
  runId: string;
}
```

### `src/policy.ts`

Centralize risk modes and budgets:

```ts
import { PlanEngineInput } from "./types";

export function applyPlanPolicies(input: PlanEngineInput) {
  // decide budgets & allowed actions based on risk
  const budgets =
    input.risk === "high"
      ? { maxCalls: 10, maxTokens: 50000 }
      : { maxCalls: 3, maxTokens: 10000 };

  return { ...input, budgets };
}
```

### `src/observability.ts`

Standardize spans/logging:

```ts
import { PlanEngineInput } from "./types";

export async function withPlanEngineSpan<T>(
  operation: string,
  input: PlanEngineInput,
  fn: (ctx: { runId: string }) => Promise<T>
): Promise<T> {
  const runId = input.traceId ?? crypto.randomUUID();
  // open span/log
  try {
    const result = await fn({ runId });
    // close span as success
    return result;
  } catch (err) {
    // close span as error
    throw err;
  }
}
```

### `src/core.ts`

Implement orchestration using Kits and contracts:

```ts
import { PlanEngineInput, PlanEngineOutput } from "./types";
import { withPlanEngineSpan } from "./observability";
import { applyPlanPolicies } from "./policy";
// import adapters calling PlanKit, EvalKit, PolicyKit, etc.

export async function generatePlanCore(
  input: PlanEngineInput
): Promise<PlanEngineOutput> {
  return withPlanEngineSpan("generatePlan", input, async ({ runId }) => {
    const policyContext = applyPlanPolicies(input);

    // 1. Call PlanKit to draft a plan
    // 2. Run evals via EvalKit
    // 3. Apply policies via PolicyKit
    // 4. Possibly iterate/refine within budgets

    return {
      plan: /* ... */,
      evalResults: /* ... */,
      policyContext,
      runId,
    };
  });
}
```

### `src/index.ts`

Export the public API:

```ts
import { PlanEngineInput, PlanEngineOutput } from "./types";
import { generatePlanCore } from "./core";

export type { PlanEngineInput, PlanEngineOutput };

export async function generatePlan(
  input: PlanEngineInput
): Promise<PlanEngineOutput> {
  return generatePlanCore(input);
}
```

---

## 5. Wire to Kits and contracts

Within the Engine:

- Call **Kits** (PlanKit, FlowKit, EvalKit, PolicyKit, etc.) for specific operations.
- If you need to call a platform runtime:

  - Ensure an API exists in `contracts/`.
  - Use the generated client from `contracts/ts`.
- Don’t import code from `platform/runtimes/*-runtime/**`.

---

## 6. Add tests

In `packages/engines/<engine-name>/tests/<engine-name>.spec.ts`:

- Test Engine behavior under different risk modes and inputs.
- Mock Kits/clients as needed.
- Verify policies and budgets are applied correctly.

---

## 7. Integrate with Agents

Update `packages/agents`:

- **`specs/`** – define which agents expose this capability.
- **`definitions/`** – call your Engine functions instead of duplicating logic.
- **`governance/`** – map agent risk levels to Engine risk modes.
- **`factories/`** – ensure the new Engine is wired into agent construction.

---

## 8. Checklist

- [ ] Engine lives under `packages/engines/<engine-name>`.
- [ ] Has a clear, small public API in `src/index.ts`.
- [ ] Uses Kits + contracts; does not import runtime internals directly.
- [ ] Embeds risk/budgets/policies where appropriate.
- [ ] Emits observability signals (runId, spans, logs, metrics).
- [ ] Is used by at least one Agent (or has a clear plan to be).
