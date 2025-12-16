---
title: Add a New Agent (TypeScript)
description: Recipe to add a new agent to the Harmony monorepo.
version: v1.0.0
date: 2025-11-21
---

# Recipe: Add a New Agent (TypeScript)

Agents are **role/goal-oriented “brains”** that use Engines and Kits to achieve objectives under governance. In TypeScript, they live in `packages/agents` as **definitions** and **factories**.

Use this recipe when you want a new **TS agent** (e.g., a new console persona, a release copilot, a Kaizen reviewer), not when you’re adding a Python runtime process.

---

## 1. When to add an Agent

Add a new TS Agent if:

- You need a new **role**:
  - “Release Copilot”, “Docs Explorer”, “RAG Helper”, “Kaizen Test Planner”, etc.
- The behavior is **goal/UX oriented**:
  - Understands user goals, chooses Engines, interprets results.
- It will be used by:
  - apps (`apps/*`),
  - tools (CLI),
  - or other orchestration layers.

If you need a long-running process in Python, see `/agents/*` and treat it as a runtime instead.

---

## 2. Create the Agent skeleton

Assume an agent called `release-copilot`.

### 2.1 Add a spec

Create `packages/agents/src/specs/release-copilot.ts`:

```ts
export interface ReleaseCopilotRequest {
  goal: string;
  branch?: string;
  risk?: "proposal_only" | "autonomous_safe";
}

export interface ReleaseCopilotResponse {
  summary: string;
  proposedChanges?: any; // e.g. PR metadata
  evidence?: any;
}

export interface ReleaseCopilotCapabilities {
  canProposePRs: boolean;
  canTriggerTests: boolean;
  canRequestApprovals: boolean;
}
````

This defines **what the agent does** and its input/output shape.

---

### 2.2 Add a definition

Create `packages/agents/src/definitions/release-copilot.ts`:

- Decide how the agent will use Engines and Kits.

```ts
import { ReleaseCopilotRequest, ReleaseCopilotResponse } from "../specs/release-copilot";
import { generatePlan as generateReleasePlan } from "@/packages/engines/plan-engine";
import { executePlan } from "@/packages/engines/work-engine";
import { evaluate } from "@/packages/engines/governance-engine";
import { prepareChange } from "@/packages/engines/release-engine";

export async function handleReleaseCopilotRequest(
  req: ReleaseCopilotRequest,
  ctx: { userId: string; traceId?: string }
): Promise<ReleaseCopilotResponse> {
  // 1. Plan
  const plan = await generateReleasePlan({
    goal: req.goal,
    contextRef: req.branch,
    risk: req.risk === "autonomous_safe" ? "high" : "medium",
    traceId: ctx.traceId,
  });

  // 2. Execute
  const workResult = await executePlan({ plan: plan.plan, traceId: ctx.traceId });

  // 3. Govern
  const evalResult = await evaluate({ artifact: workResult, context: { goal: req.goal } });

  // 4. Prepare a change (PR)
  const change = await prepareChange({ workResult, evalResult, branch: req.branch });

  return {
    summary: "Proposed release changes based on your goal.",
    proposedChanges: change,
    evidence: { plan, workResult, evalResult },
  };
}
```

This file is **pure logic**, expressed in terms of Engines (and indirectly Kits).

---

### 2.3 Add governance

Create `packages/agents/src/governance/release-copilot.ts`:

```ts
import { ReleaseCopilotRequest } from "../specs/release-copilot";

export type ReleaseCopilotRiskProfile = "proposal_only" | "autonomous_safe";

export function getReleaseCopilotRiskProfile(
  req: ReleaseCopilotRequest
): ReleaseCopilotRiskProfile {
  return req.risk ?? "proposal_only";
}

export function ensureReleaseCopilotAllowed(
  profile: ReleaseCopilotRiskProfile
) {
  // enforce allowed actions per profile
  // e.g., proposal_only -> no direct deploys
}
```

This is where you align the agent with GovernanceEngine and policies.

---

### 2.4 Add a factory

Create `packages/agents/src/factories/release-copilot.ts`:

```ts
import {
  ReleaseCopilotRequest,
  ReleaseCopilotResponse,
} from "../specs/release-copilot";
import {
  getReleaseCopilotRiskProfile,
  ensureReleaseCopilotAllowed,
} from "../governance/release-copilot";
import { handleReleaseCopilotRequest } from "../definitions/release-copilot";

export interface ReleaseCopilotAgent {
  handle(
    req: ReleaseCopilotRequest,
    ctx: { userId: string; traceId?: string }
  ): Promise<ReleaseCopilotResponse>;
}

export interface ReleaseCopilotConfig {
  // e.g. logging options, feature flags, limits, etc.
}

export function createReleaseCopilot(
  config: ReleaseCopilotConfig
): ReleaseCopilotAgent {
  return {
    async handle(req, ctx) {
      const profile = getReleaseCopilotRiskProfile(req);
      ensureReleaseCopilotAllowed(profile);
      // attach config if needed
      return handleReleaseCopilotRequest(req, ctx);
    },
  };
}
```

This is what apps and tools will import.

---

## 3. Wire the Agent into an app

In `apps/release-dashboard` (for example):

```ts
import { createReleaseCopilot } from "@/packages/agents/src/factories/release-copilot";

const copilot = createReleaseCopilot({ /* config */ });

export async function handleReleaseRequest(reqBody: any, userId: string) {
  const response = await copilot.handle(
    {
      goal: reqBody.goal,
      branch: reqBody.branch,
      risk: reqBody.risk,
    },
    { userId }
  );
  return response;
}
```

---

## 4. Checklist

- [ ] Agent spec added under `packages/agents/src/specs`.
- [ ] Agent definition added under `packages/agents/src/definitions`.
- [ ] Governance (risk, budgets, policies) lives under `packages/agents/src/governance`.
- [ ] Factory created under `packages/agents/src/factories` and used by an app/entrypoint.
- [ ] Agent logic uses Engines/Kits, not runtime internals.
