---
title: End-to-End Flow Examples
description: Examples of how the main pieces of the system work together in common scenarios.
version: v1.0.0
date: 2025-11-21
---

# End-to-End Flow Examples

This document shows how the main pieces of the system work together in common scenarios.

Each example focuses on:

- Which components are involved (apps, Agents, Engines, Kits, runtimes)
- The direction of calls
- Where decisions, execution, and governance happen

If you’re new, keep the high-level mental model in mind:

> Surfaces (apps, schedulers)
> → Agents (via factories)
> → Engines
> → Kits
> → Platform runtimes / tools / external systems

---

## 1. User asks the console to implement a feature

### 1.1 High-level flow

A user asks the console app to implement or modify a feature. The system:

1. Understands the goal.
2. Plans the work.
3. Executes the plan via flows/tools.
4. Evaluates the changes.
5. Proposes a PR.

### 1.2 Diagram

```text
User
  |
  v
apps/ai-console (UI/API)
  |
  v
packages/agents (factories/console-assistant)
  |
  v
Engines:
  PlanEngine ---> ContextEngine (optional, for RAG/context)
      |
      v
  WorkEngine -------------------------------> FlowKit + contracts/ts
      |                                       |
      |                                       v
      |                             platform/runtimes/flow-runtime
      |                                       |
      v                                       v
GovernanceEngine <--------------------- results/traces
      |
      v
ReleaseEngine -----------------------> tools (e.g. GitHub API)
      |
      v
Pull Request / Change Proposal
````

### 1.3 Step-by-step description

1. **User → console app**

   - User describes a feature: “Add a filter to the dashboard by status.”
   - `apps/ai-console` receives the request (HTTP/WebSocket).

2. **Console app → TS Agent (via factory)**

   - The app calls `createConsoleAssistant(...)` from `packages/agents/src/factories/console-assistant`.
   - The factory builds an agent with:

     - spec: what it’s allowed to do,
     - definition: how it behaves,
     - governance: risk profile, budgets, policies.

3. **Agent → PlanEngine (planning)**

   - The console agent decides the goal requires a plan.
   - It calls `PlanEngine.generatePlan({ goal, contextRef, risk })`.
   - PlanEngine:

     - Uses PlanKit + PromptKit to propose a plan.
     - Runs evals/policies (EvalKit, PolicyKit) to refine/validate the plan.
     - Returns a governed plan with evidence (scores, reasoning, run IDs).

4. **Agent → ContextEngine (optional, for context)**

   - If the plan needs repo context, the agent or PlanEngine calls ContextEngine:

     - ContextEngine uses IngestKit/IndexKit/QueryKit/SearchKit to fetch relevant code/docs.
     - Returns a structured context bundle for prompts/flows.

5. **Agent → WorkEngine (execution)**

   - The agent passes the plan to `WorkEngine.executePlan(plan, context)`.
   - WorkEngine:

     - Maps plan steps to FlowKit flows and tools.
     - Uses `contracts/ts` clients to call `platform/runtimes/flow-runtime`.
     - Handles retries, idempotency, and budgets.

6. **Flow runtime → tools & systems**

   - `platform/runtimes/flow-runtime`:

     - Executes the flow graph (e.g. code edits, test runs).
     - Calls tools (MCP, external APIs, repos) via adapters.
     - Emits telemetry (traces, logs, metrics).

7. **WorkEngine → GovernanceEngine (verification)**

   - Once execution completes (or partially completes), WorkEngine hands results to GovernanceEngine.
   - GovernanceEngine:

     - Runs eval suites (EvalKit, DatasetKit).
     - Applies policies (PolicyKit) for safety/determinism/compliance.
     - Returns a verdict + scores + evidence.

8. **Agent → ReleaseEngine (proposing changes)**

   - If governance verdict is acceptable and risk profile allows:

     - The agent calls `ReleaseEngine.prepareChange(...)`.
   - ReleaseEngine:

     - Uses PatchKit to generate diffs/PRs.
     - Uses ReleaseKit to attach metadata (changelog entries, release notes).
     - Calls external systems (e.g. GitHub) via adapters.

9. **Result → user**

   - The console agent summarizes:

     - What it changed / proposes,
     - Links to PR(s),
     - Any caveats or follow-up actions.
   - The console app returns this to the user.

---

## 2. Kaizen run improving test coverage

### 2.1 High-level flow

A scheduled or event-driven Kaizen run focuses on improving test coverage for a specific slice. The system:

1. Detects or is told where coverage is lacking.
2. Plans Kaizen work.
3. Executes improvements.
4. Evaluates impact.
5. Proposes PRs.

### 2.2 Diagram

```text
Scheduler / Event
  |
  v
Kaizen runtime (apps/* or /agents/kaizen)
  |
  v
KaizenEngine
  |      \
  |       \--> ContextEngine (repo state, coverage, flakiness)
  |
  v
PlanEngine (Kaizen-focused plan)
  |
  v
WorkEngine --------------------------------> FlowKit + contracts/ts
  |                                           |
  |                                           v
  |                                 platform/runtimes/flow-runtime
  |                                           |
  v                                           v
GovernanceEngine <---------------------- results & evidence
  |
  v
ReleaseEngine --------------------------> tools (e.g. GitHub)
  |
  v
Kaizen PR(s) / report
```

### 2.3 Step-by-step description

1. **Scheduler/Event → Kaizen runtime**

   - A scheduler (Cron, CI, event) triggers a Kaizen job:

     - “Improve test coverage for slice X.”
   - This might be:

     - a TS app under `apps/kaizen-runner`, or
     - a Python agent under `/agents/kaizen`.

2. **Kaizen runtime → KaizenEngine**

   - The Kaizen entrypoint calls `KaizenEngine.runKaizen({ sliceId, goalType: "test_coverage" })`.
   - KaizenEngine coordinates all Kaizen work.

3. **KaizenEngine → ContextEngine**

   - First, KaizenEngine needs situational awareness:

     - Current test coverage.
     - Flaky tests.
     - Recent failures.
   - It calls ContextEngine to retrieve and assemble this context from observability data, code, and test reports.

4. **KaizenEngine → PlanEngine (Kaizen plan)**

   - With context in hand, KaizenEngine calls `PlanEngine`:

     - “Create a Kaizen plan to improve test coverage for slice X.”
   - PlanEngine returns a plan focused on tests (e.g., add tests here, refactor brittle tests there).

5. **KaizenEngine → WorkEngine (execute Kaizen plan)**

   - KaizenEngine forwards the plan to WorkEngine:

     - `WorkEngine.executePlan(plan, kaizenContext)`.
   - WorkEngine runs flows via `flow-runtime`:

     - Generating tests.
     - Modifying existing tests.
     - Running test suites to validate changes.

6. **WorkEngine → GovernanceEngine (evaluate impact)**

   - Once changes are made and tests run:

     - GovernanceEngine evaluates:

       - New coverage metrics.
       - Test pass/fail profiles.
       - Safety (e.g., no suspicious changes).
   - Returns a verdict and evidence (e.g., coverage deltas, flaky test improvements).

7. **KaizenEngine → ReleaseEngine (PRs)**

   - If governance allows:

     - KaizenEngine uses ReleaseEngine to create PRs:

       - containing new/updated tests,
       - with clear descriptions and evidence.
   - ReleaseEngine manages:

     - diffs (PatchKit),
     - PRs/releases (ReleaseKit),
     - any required approvals via policies.

8. **Result → humans/observability**

   - KaizenEngine produces a report:

     - what was changed,
     - coverage improvements,
     - links to PRs.
   - This can be stored under `kaizen/` and surfaced via dashboards or notifications.

---

## 3. Context-aware question (RAG-style)

### 3.1 High-level flow

A user asks a question that requires context (docs, code, logs). The system:

1. Understands the question.
2. Retrieves relevant context.
3. Plans a response or small action.
4. Executes any necessary steps.
5. Returns an answer with grounded context.

### 3.2 Diagram

```text
User
  |
  v
App (e.g. apps/ai-console, apps/docs-assistant)
  |
  v
TS Agent (via packages/agents factory)
  |
  v
ContextEngine ------------------> Kits: IngestKit/IndexKit/QueryKit/SearchKit
  |
  v
PlanEngine (optional, for multi-step goals)
  |
  v
WorkEngine (optional, for actions)
  |
  v
Answer to user (with references)
```

### 3.3 Step-by-step description

1. **User → App**

   - User asks: “How does the flow runtime work?” or “Where is feature X implemented?”
   - The app (e.g. `apps/ai-console` or a docs assistant app) receives the question.

2. **App → TS Agent**

   - The app calls an appropriate agent factory from `packages/agents`:

     - `createDocsAssistant`, `createCodeExplorer`, etc.
   - The agent spec defines what it can access and do.

3. **Agent → ContextEngine (retrieve context)**

   - The agent recognizes the question needs repo/docs/logs context.
   - It calls `ContextEngine.getContext({ query, sliceId, entityId, risk })`.
   - ContextEngine:

     - Uses IngestKit/IndexKit/QueryKit/SearchKit to find relevant content.
     - Packages it into a prompt-ready context structure.
     - May run quick evals (via EvalKit) to score relevance.

4. **Agent → PlanEngine (optional)**

   - If the question implies a multi-step goal or follow-up actions:

     - The agent calls `PlanEngine` to create a mini-plan.
   - For simple Q&A, this step may be skipped.

5. **Agent → WorkEngine (optional, for actions)**

   - If the question includes an action:

     - “Can you update the docs?” or “Fix this error?”
   - The agent uses WorkEngine to:

     - execute plan steps (e.g. propose doc updates),
     - run flows via `flow-runtime` as needed.

6. **Agent → Answer user**

   - The agent composes a response:

     - Using the retrieved context (citations, references).
     - Optional: notes on any changes it proposes or has made.
   - The app returns this back to the user.

---

## 4. Summary mental model

Across these flows, the same pattern repeats:

- **Apps & schedulers** handle input/output and transport.
- **Agents** handle goals, roles, and UX.
- **Engines** own domain capabilities:

  - Planning, execution, context/RAG, governance, release, Kaizen.
- **Kits** provide sharp, reusable primitives.
- **Platform runtimes** execute flows and jobs safely for everyone.

As you work on new features, try to map them into one of these patterns:

- “This looks like a console-style feature implementation.”
- “This looks like a Kaizen-style improvement pass.”
- “This looks like a context-heavy Q&A.”

That will help you quickly find the right Engine(s), Agent(s), and runtimes to plug into.
