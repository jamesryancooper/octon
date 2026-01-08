---
title: Add a New Kit
description: Recipe to add a new kit to the Harmony monorepo.
version: v1.0.0
date: 2025-11-21
---
# Recipe: Add a New Kit

Kits are small, focused libraries that provide **one capability well**. They live under `packages/kits/*` and are imported by Engines, Agents, and sometimes apps.

Use this recipe when you’re adding a **new primitive capability** (e.g., a new planning helper, a RAG query helper, a specialized eval scorer), *not* a full subsystem.

---

## 1. When to create a Kit

Create a Kit if:

- It solves a **single, well-defined concern**.
- It can be reused across multiple Engines/Agents.
- It doesn’t need to run as its own process (no HTTP server, loop, etc.).
- It might later be composed into an Engine.

Do **not** create a Kit if:

- You need a larger subsystem that orchestrates multiple capabilities, policies, and telemetry → see [Add an Engine](./add-engine.md).
- It’s directly tied to one app/route with no reuse → keep it as app code first.

---

## 2. Choose a name and location

Pick a name that describes the capability, not the caller, e.g.:

- `plan-kit/`, `flow-kit/`, `eval-kit/`, `policy-kit/`, `query-kit/`, `search-kit/`, `patch-kit/`, `release-kit/`, etc.

Create the folder:

```bash
mkdir -p packages/kits/<kit-name>/src
mkdir -p packages/kits/<kit-name>/tests
````

---

## 3. Create the Kit skeleton

Minimal structure:

```text
packages/kits/<kit-name>/
  src/
    index.ts        # public API (types + exports)
    core.ts         # main implementation
    types.ts        # shared types/interfaces
    adapters.ts     # optional: external service/contract adapters
  tests/
    <kit-name>.spec.ts
```

### `src/index.ts`

- Export the Kit’s public API.
- Re-export only what callers need.

Example:

```ts
// packages/kits/query-kit/src/index.ts
export * from "./types";
export { queryDocuments, queryCodebase } from "./core";
```

### `src/types.ts`

- Define input/output types and important enums.

```ts
export interface QueryInput {
  query: string;
  topK?: number;
  sliceId?: string;
}

export interface QueryResult {
  items: Array<{
    id: string;
    title?: string;
    snippet?: string;
    score: number;
  }>;
}
```

### `src/core.ts`

- Implement the Kit’s main behavior.
- Keep it **pure or deterministic where possible**.
- Call external services via adapters or `contracts/ts` clients.

```ts
import { QueryInput, QueryResult } from "./types";
import { searchClient } from "./adapters";

export async function queryDocuments(input: QueryInput): Promise<QueryResult> {
  // validate input, set defaults
  const topK = input.topK ?? 10;
  const raw = await searchClient.search({ q: input.query, topK, sliceId: input.sliceId });
  // normalize to QueryResult
  return { items: raw.items.map(/* ... */) };
}
```

---

## 4. Integrate with contracts or external services (if needed)

If the Kit talks to a runtime or external system:

- Add/extend an OpenAPI/JSON Schema definition in `contracts/`.
- Regenerate clients in `contracts/ts`.
- Use those clients in your Kit’s `adapters.ts`.

Do **not** import runtime code from `platform/runtimes/*-runtime/**`.

---

## 5. Add tests

In `packages/kits/<kit-name>/tests/<kit-name>.spec.ts`:

- Unit tests for core logic.
- Mock external clients where necessary.
- Cover error handling and edge cases.

---

## 6. Wire it into Engines/Agents

- Update any Engines that should use this Kit.
- Search for duplicated logic the Kit replaces and refactor to use the Kit.

---

## 7. Checklist

- [ ] Kit lives under `packages/kits/<kit-name>`.
- [ ] Has `src/index.ts` and clear public API.
- [ ] Uses `contracts/ts` clients for runtime calls (no direct runtime imports).
- [ ] Has tests in `tests/`.
- [ ] Is used by at least one Engine or Agent (or has a clear future caller).
