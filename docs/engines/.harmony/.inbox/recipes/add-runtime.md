---
title: Add a New Runtime Service
description: Recipe to add a new runtime service to the Harmony monorepo.
version: v1.0.0
date: 2025-11-21
---

# Recipe: Add a New Runtime Service (`platform/runtimes/*-runtime`)

Runtime services under `platform/runtimes/*-runtime/**` are **shared execution substrates** – they run flows/tasks for everyone (apps, agents, Kaizen, CI) under consistent policies and observability.

Examples:

- `flow-runtime` – executes flows/graphs.
- Future: `eval-runtime`, `batch-runtime`, `index-runtime`, etc.

Use this recipe when you want to introduce a **new platform-level runtime service**, not just another app or Python agent.

---

## 1. When to add a new runtime service

You should add a runtime service if:

- There is a class of work that:
  - needs **shared execution behavior** (checkpointing, retries, backpressure, quotas),
  - will be used by many **Agents/Engines/apps**,
  - requires **centralized policies and observability**.
- Existing runtimes (e.g. flow-runtime) aren’t a good fit for its execution model.

Examples:

- A dedicated **eval runtime** that runs eval jobs in a controlled environment.
- A **batch runtime** for long-running, large-scale batch tasks.
- A specialized **index runtime** that manages heavy indexing jobs.

You probably **do not** need a new runtime service if:

- You’re just adding a new **flow** → see [Add a Flow](./add-flow.md) and use the existing `flow-runtime`.
- You’re building a **surface** or product API → use `apps/*`.
- You’re building a **role-specific brain** → use `/agents/*`.

---

## 2. Design the runtime’s responsibility & API

Before touching code:

1. **Define responsibility in 2–3 sentences**
   For example:

   > `eval-runtime` is responsible for executing eval jobs (LLM-based or otherwise) with strict isolation, quotas, and telemetry. It is not responsible for planning evals or interpreting results; that logic lives in Engines and Kits.

2. **Identify inputs/outputs**
   - What does a “job” or “task” look like?
   - How will callers specify:
     - inputs,
     - context,
     - priority,
     - risk level?

3. **Identify callers**
   - Which Engines (GovernanceEngine, KaizenEngine, etc.) will use it?
   - Any direct callers (apps, CI)?

4. **Sketch the API surface**
   Typical operations:

   - `POST /jobs` – submit a job
   - `GET /jobs/{id}` – inspect job status/result
   - `POST /jobs/{id}/cancel` – cancel job

---

## 3. Add contracts for the new runtime

All communication with runtimes goes through **contracts**.

1. In `contracts/`, add or extend OpenAPI/JSON Schema specs with your new runtime’s API:

   - Example namespace: `evalRuntime` or `batchRuntime`.

   Define:

   - Request/response schemas.
   - Error types.
   - Any auth/tenant headers.

2. Regenerate clients:

```bash
# whatever your existing codegen command is
pnpm generate:contracts
```

This should update:

- `contracts/ts` – TypeScript clients.
- `contracts/py` – Python clients.

3. Confirm the new client functions exist and are named sanely.

---

## 4. Create the runtime service folder

Under `platform/runtimes`:

```bash
mkdir -p platform/runtimes/<name>-runtime/src
mkdir -p platform/runtimes/<name>-runtime/tests
```

Example:

```bash
mkdir -p platform/runtimes/eval-runtime/src
mkdir -p platform/runtimes/eval-runtime/tests
```

The folder will typically include:

```text
platform/runtimes/<name>-runtime/
  src/
    main.py / main.ts   # runtime entrypoint
    server/             # HTTP/gRPC/worker server
    handlers/           # request/job handlers
    executor/           # core execution logic
    policies/           # quotas, limits, risk handling
    observability/      # logging, metrics, tracing
    models/             # runtime config/models (if needed)
  tests/
    test_*.py / *.spec.ts
```

> **Language:** follow your existing runtime-language choice (often Python for flow-runtime).

---

## 5. Implement the runtime server

Inside `platform/runtimes/<name>-runtime/src`:

1. **Bootstrap a server**

   - HTTP, gRPC, or queue-based – whichever is standard in your stack.
   - Expose routes that match the `contracts/` spec.

2. **Implement handlers**

   - Each handler:

     - validates inputs,
     - enqueues work (if async),
     - or executes it directly (if synchronous),
     - returns job IDs or results.

3. **Core execution logic (`executor/`)**

   - Real work happens here:

     - running jobs,
     - invoking tools/LLMs,
     - checkpointing,
     - handling retries and errors.

4. **Policies (`policies/`)**

   - Implement quotas and limits:

     - per job,
     - per caller,
     - per risk level.
   - Fail safe (fail-closed) where appropriate.

5. **Observability (`observability/`)**

   - Emit logs, metrics, and traces for:

     - job submission,
     - job state transitions,
     - errors,
     - resource usage.

---

## 6. Avoid leaking domain logic into the runtime

Key rule:

> Runtime services should focus on **execution mechanics**, not domain orchestration.

That means:

- Don’t embed high-level **planning or governance logic** in the runtime.

  - Put that in Kits/Engines (PlanEngine, GovernanceEngine, etc.).
- Runtimes should be **generic** across slices and callers where possible.

Engines and Kits:

- Build job definitions.
- Decide which jobs to run and with what parameters.
- Interpret results.

The runtime:

- Safely executes those jobs.

---

## 7. Wire runtime usage through Kits (and then Engines)

Callers shouldn’t talk to runtimes via raw HTTP inside random apps. Instead:

1. **Add or extend a Kit** in `packages/kits` that wraps the `contracts/ts` client:

   ```ts
   // packages/kits/eval-kit/src/runtime-client.ts
   import { evalRuntimeClient } from "@/contracts/ts";

   export async function submitEvalJob(input: EvalJobInput): Promise<EvalJobId> {
     const res = await evalRuntimeClient.createJob({ body: input });
     return res.data.id;
   }

   export async function getEvalJobResult(id: EvalJobId): Promise<EvalJobResult> {
     const res = await evalRuntimeClient.getJob({ jobId: id });
     return res.data;
   }
   ```

2. **Use that Kit inside an Engine** (e.g. GovernanceEngine):

   ```ts
   import { submitEvalJob, getEvalJobResult } from "@/packages/kits/eval-kit/runtime-client";

   export async function runEvalSuite(...) {
     const jobId = await submitEvalJob(...);
     const result = await pollUntilDone(jobId);
     return result;
   }
   ```

3. **Agents call Engines**, not raw runtime clients.

This keeps runtime usage consistent and testable.

---

## 8. Integrate with Agents and Apps

- TS Agents (in `packages/agents`) should use Engines that use the new runtime via Kits.
- Python agents (/agents) should use `contracts/py` clients to talk to the new runtime:

  - Usually via orchestration logic that mirrors what Engines do on the TS side.

Apps should **not**:

- Call the runtime directly for complex domain flows.
- Reimplement orchestration that belongs in Engines.

---

## 9. Testing and rollout

1. **Unit tests** in `platform/runtimes/<name>-runtime/tests`:

   - Handler tests.
   - Executor logic tests.
   - Policy enforcement tests.

2. **Contract tests**:

   - Ensure the runtime honors the `contracts/` schema (inputs/outputs, error codes).

3. **Kit/Engine tests**:

   - Tests for any new Kit wrappers.
   - Engine tests that exercise the new runtime service via the Kit.

4. **Rollout**:

   - Deploy the runtime service.
   - Enable a small set of callers (feature flag or config).
   - Monitor logs/metrics, then expand usage.

---

## 10. Checklist

- [ ] Clear responsibility and non-goals defined for the runtime.
- [ ] API defined in `contracts/` with request/response schemas.
- [ ] TS and Python clients generated from contracts.
- [ ] Runtime implementation in `platform/runtimes/<name>-runtime/**` with:
  - [ ] Server/handlers,
  - [ ] Executor,
  - [ ] Policies,
  - [ ] Observability.
- [ ] No domain orchestration logic leaked into the runtime.
- [ ] Kits provide wrappers for runtime API usage.
- [ ] Engines call the runtime via Kits (not raw HTTP).
- [ ] Agents use Engines (or Kits) to access the runtime.
- [ ] Tests exist at runtime, Kit, and Engine layers.
