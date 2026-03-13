---
title: Observability Requirements
description: Structured logs, distributed tracing, correlation to the Knowledge Plane, and redaction practices to support speed with safety.
---


# Observability Requirements: Spans, Logs, Trace Linking, and Redaction

Related docs: [monorepo polyglot (normative)](./monorepo-polyglot.md), [runtime architecture](/.octon/cognition/_meta/architecture/runtime-architecture.md), [runtime policy](/.octon/cognition/_meta/architecture/runtime-policy.md), [knowledge plane](../../runtime/knowledge/knowledge.md), [tooling integration](./tooling-integration.md), [python runtime workspace example](/.octon/scaffolding/practices/examples/stack-profiles/python-runtime-workspace.md)

To fulfill our pillar of **Velocity through Agentic Automation and Trust through Governed Determinism**, we need deep insight into system behavior at runtime without compromising privacy or security. Observability is the practice of instrumenting the system so that we can understand its internal states from its outputs (logs, metrics, traces). Our observability plan is comprehensive: we require structured **logging**, **distributed tracing** across components, correlation of those traces to knowledge in the Knowledge Plane, and careful **redaction** of sensitive data to protect user privacy and comply with regulations. This section lays out the observability requirements and how they tie into HSP.

## Logging and Structured Events

Every component in the system must produce logs that are:

- **Structured**: Rather than ad-hoc print statements, logs should be in a parseable format (JSON or key-value). Each log entry should include standard fields like timestamp, severity level, module name, trace/context ID, and a message or event name. Structured logs make it far easier to filter and analyze automatically (for both humans and AI).

- **Contextualized**: Using a tracing context (see below), logs from a single transaction can be tied together. Also, logs should include relevant IDs (e.g., user ID, request ID) where appropriate, to correlate with domain entities.

- **Meaningful levels**: We will use log levels (DEBUG, INFO, WARN, ERROR) consistently. E.g., WARN for recoverable issues, ERROR for serious problems. The system should run normally at INFO level without overwhelming volume.

- **No sensitive data**: PII or secrets should not appear in logs. We enforce this by policy and by scanning logs for patterns (e.g., using a Data Loss Prevention regex). If we must log something sensitive (like an email ID in a debug scenario), we either hash or truncate it. For example, logging "User email prefix: johnd\*\*\*@domain.com" instead of full email. Or better, reference a user by an internal ID rather than personal details.

- **Complete coverage**: At minimum, key events have log entries. Requirements:

  - Each external request (HTTP API call, CLI command, etc.) logs an entry at start and completion (with result code and duration).

  - Each significant business operation (like "OrderPlaced event processed" or "PaymentCharged") logs success or failure.

  - Errors/exceptions always log an ERROR with stack trace (and trace ID for correlation).

  - Security relevant events (failed login attempts, permission denials) are logged for audit.

- **Performance logs**: For performance critical sections, we might log times. However, heavy performance observability is usually better done via metrics or tracing rather than logs (to avoid log bloat). We'll do a bit of both: e.g., log slow queries above threshold as WARN with query name and time (to catch outliers).

These logs will be collected by our logging infrastructure (e.g., feeding into ElasticSearch or a cloud log service). The Knowledge Plane might not store all raw logs (too voluminous), but it will store summary or link to log entries via trace IDs.

## Distributed Tracing

We implement **distributed tracing** (using OpenTelemetry or similar) across our TypeScript apps, feature packages, and Python runtimes (including the LangGraph-based implementation of the platform runtime service). This means:

- Each incoming request is assigned a **Trace ID** and **Span IDs** for sub-operations.

- As requests flow through different modules (or even external services), the trace context is propagated (via HTTP headers or context objects).

- We create spans for meaningful segments: e.g., "HTTP request handling", "DB query", "call to external API", "Cache lookup", etc. Each span records start time, end time, and metadata (like which query or which external endpoint).

- This yields a trace timeline for each request, which helps us understand performance and where time is spent or where errors occur.

**Requirements for tracing:**

- **Propagation**: All module boundaries (especially across processes such as `apps/*` ↔ `agents/*` ↔ the platform runtime service) must propagate trace context. Use W3C trace context (traceparent/tracestate) with OpenTelemetry. Even within the monolith, propagate context through async/background work.

- **Span tagging**: Each span should be tagged with relevant info: e.g., span for a DB call tag the SQL operation name, span for an external call tag the service name and method, etc. Also include success/failure status on span.

- **Error association**: If an error occurs within a span, that span is marked as errored and includes error details. This way, one can see in the trace where something went wrong.

- **Runtime run attributes**: All spans associated with platform runtime executions MUST include standardized attributes such as `flow_id`, `flow_version`, `run_id`, `caller_kind`, `caller_id`, `project_id`, `environment`, and `risk_tier`. These attributes allow Kaizen/governance, SREs, and agents to slice and analyze behavior consistently across apps, agents, and runtimes (see `runtime-architecture.md`).
- **Correlation**: Link root traces to PR/build identifiers and deployment versions. Emit or propagate correlation fields so PR ↔ build ↔ trace can be queried and recorded in the Knowledge Plane for provenance and faster rollbacks. CI must publish a correlation payload to the Knowledge Plane (see Tooling Integration: `POST /kp/correlation`) for both TypeScript and Python pipelines (for example, platform runtime tests under `platform/runtimes/flow-runtime/**`).

- **Sampling**: We might not trace every single request if volume is high (some systems sample for performance). But at least a percentage or all requests in lower envs are traced. For key user journeys or when errors are happening, ideally we have those traced. We can use dynamic sampling: e.g., sample all error traces, sample slower requests at higher rate, etc. Initially, given a small team and not enormous traffic, we might trace 100% in dev/staging and a good percentage in prod.

- **Trace Queryability**: The tracing data will be sent to a tracing backend (Jaeger, Zipkin, or a cloud equivalent). We should be able to query traces by attributes (like see traces where a certain query took >1s, or traces for user X if allowed). The Knowledge Plane can integrate with this by storing some linking keys (e.g., if a test fails, KP might fetch a trace of the failing scenario or at least link to relevant traces).

**Using Traces:** These traces are golden for:

- Debugging performance issues (see exactly where the latency comes).

- Debugging distributed issues (like a request fails in one service out of many).

- The Planner agent can use trace data to identify e.g. "the checkout transaction spends 50% of time in inventory service" which might lead to a performance improvement plan.

- Analyzing dependencies: trace data can build a map of which components call which (like an architectural view).

- Ensuring determinism – differences in traces over time can reveal non-deterministic behavior or memory leaks (if spans get slower gradually).

- The Verifier in CI could run a mini trace-enabled test scenario to verify no unexpected network calls, etc.

## Metrics

Although not explicitly listed in the title, metrics are part of observability. We will gather key metrics:

- Application metrics (throughput, latency of endpoints, error rates per endpoint, resource usage, etc.).

- Domain metrics (e.g., number of orders processed per hour, success rate of payments).

- Infrastructure metrics (CPU, memory, disk I/O, etc., from the runtime environment).

These metrics are emitted perhaps via the same instrumentation (OpenTelemetry also covers metrics). They will go to a monitoring system (Prometheus or cloud monitor). We set alerts on important ones (like error rate jumps, latency SLO violations).

Metrics link to traces and logs by time and context. E.g., if an alert triggers that error rate >5%, one can jump into logs/traces around that time to see specifics[arxiv.org](https://arxiv.org/html/2506.22185#:~:text=Google%20promote%20various%20services%20to,29%2C%2040%20%2C%20%2031).

## Redaction and Privacy

We have strict rules to ensure observability does not violate privacy:

- **No personal data in logs/traces**: Instead of logging full user PII, log a user ID or anonymized token. If absolutely needed (like debugging a user-specific bug), we can use a secure method to map ID to PII outside logs (like dev can query DB with user ID if needed). If we have to log something like an email or name, we must mask it (like initial letter of last name or something). Also things like passwords or credit card numbers are NEVER logged (and ideally never in memory in plain text either).

- **Compliance**: SBOM and policy in Knowledge Plane to ensure we abide by things like GDPR (the system should be able to delete a user's data if requested – logs might be exempt if anonymized, but traces ideally no PII so they don't conflict with deletion requests).

- **Log Storage**: Ensure logs/traces are stored securely (access controlled) and with retention policies (don't keep them forever; e.g., logs maybe 30-90 days retention depending on need).

- **Redaction Tools**: Implement automated redaction where possible. E.g., if logs might contain user input (which could be anything, including PII), we could run a sanitizer on those fields. For instance, if we log an HTTP request payload, and it has a field "ssn": "123-45-6789", perhaps our logging pipeline can detect patterns and redact or hash them. There are libraries and services for this (some APMs have PII filtering).

- **AI Privacy**: If our agents (Planner/Builder/Verifier) utilize external AI APIs, we must ensure not to send sensitive code or data to them. For example, if using a cloud LLM for code suggestions, we might mask identifiers or avoid sending secrets. OpenAI API policies, for instance, require not sending personal data. In our context, code might not be personal but could be proprietary – we handle that by using either self-hosted models or trusting certain services. But the Knowledge Plane and logs with user data definitely should not be shipped to an external service. Likely we won’t send runtime logs to an LLM anyway. If an agent needs to reason about production issue, it will use aggregated, anonymized info from knowledge plane.

## Trace Linking to Knowledge Plane

We make sure each trace can be connected back to the static context:

- We might tag traces with a "spec ID" if possible. For instance, if a particular user action corresponds to a requirement or use-case ID, we can annotate the entry span with that (assuming we can map URL or action to a requirement ID from knowledge). Example: trace for "POST /orders" could have a tag `req=FR-ORD-01 (Place Order)`. This requires maintaining a mapping of endpoints to requirement IDs in the Knowledge Plane (could be part of our documentation).

- If a test case runs and fails, and it produces a trace (like integration test), that trace could be logged and associated with the test ID in knowledge plane. So Planner can retrieve "trace of failing test X".

- SBOM events might be less about traces, but logs for dependency loading or errors can be correlated with components.

- The Knowledge Plane could also store some aggregate trace data: e.g., average latency of certain operation over last week (which it can get from metrics). But more likely, it just references the metrics system rather than duplicating data.

## Observability as a Safety Net

Observability is not just for debugging, it's a safety mechanism:

- It allows quick detection of anomalies (which ties to fail-fast, fail-closed – if something is off, we catch it).

- The team (and AI agents) can verify that changes produce expected outcomes. E.g., if we deploy a performance fix, the metrics/traces should confirm improvement[thrawn01.org](https://thrawn01.org/posts/determinism-in-software---the-good,-the-bad,-and-the-ugly#:~:text=In%20part%2C%20games%20achieve%20high,a%20high%20bar%20for%20reliability). If not, maybe the fix didn't work or is not in effect; the Planner might iterate or reconsider.

- Observability data feeds into our continuous improvement. For example, error logs are directly mined by Planner to identify new bug-fix plans (like earlier NPE example).

- It also helps with **determinism**: If we observe a lot of variance in metrics or flaky behavior in traces, that's a sign of nondeterministic issues (like race conditions or memory leaks). By having that visibility, we can plan to address them. Many microservice anomalies only surface when combining traces, logs, metrics[arxiv.org](https://arxiv.org/html/2506.22185#:~:text=Google%20promote%20various%20services%20to,29%2C%2040%20%2C%20%2031), so our approach to unify these is crucial for diagnosing problems that static tests might not catch.

## Tooling & Implementation specifics

We'll likely use:

- **OpenTelemetry SDK** in our code (since it supports logs, traces, metrics in one).

- A logging framework like log4j or Winston (depending on language) configured to output structured JSON and integrate with OpenTelemetry context (so logs have trace IDs).

- **Jaeger** or **Zipkin** as tracing backend (self-hosted) or a cloud APM like Datadog, New Relic for convenience if budget allows, which will give nice UIs to view traces and logs correlated.

- **Elastic Stack** or a cloud log service for logs.

- **Prometheus/Grafana** for metrics if self-hosting, or cloud monitor alternative.

We ensure all environments (dev/staging/prod) have enough observability to debug issues that arise. Possibly more verbose in dev (trace everything) and more sampling in prod.

**Redaction Implementation**:

- At logging call sites, developers should avoid including PII. Code reviews will check that (governance can treat logging of PII as a policy violation – Verifier can scan log statements if they contain suspicious patterns like `%s` near "password" etc.).

- A log processor can scrub known fields (like if we log HTTP request bodies, maybe run a RegEx to remove anything looking like email, etc.). Or better, don't log whole bodies unless necessary.

- Ensure secure handling of logs (encrypt at rest if needed, especially if containing any user data).

- In traces, we avoid spans with personal info. E.g., span names will be generic (not "process order for John Doe", but "process order for userId 123").

## Checklist (Embed in CI and Reviews)

- Required spans and naming: emit key spans for kits/control-plane operations (e.g., `kit.*`) and business operations; include stable resource attributes.
- Correlate everything: ensure a `trace_id` is available in PR annotations and CI outputs that link PR ↔ build ↔ trace ↔ deployment.
- No PII/PHI in logs/traces: enforce via Guard/Redaction layer (cross‑cutting; see `.octon/cognition/_meta/architecture/slices-vs-layers.md`) at log/write boundaries; fail checks on violations.
- Sampling and cardinality: keep identifiers low-cardinality; prefer attributes over dynamic span names.
- DORA/operational events: record PR, promote, and rollback events for timeline analysis.
- Accessibility: integrate automated a11y checks for key UIs and treat failures as policy/evaluation violations surfaced alongside observability reports.
- Kaizen scaffolding: allow Autopilot PRs to add missing spans/logs on recently changed paths; include a sample trace outline and evidence of improved coverage.

By rigorously applying these observability requirements, we create a **living view** of the system that both humans and AI can utilize. This is crucial for a small team – it’s like having an additional team member that constantly watches the system and tells you what's happening, which amplifies our capabilities to manage the system as it grows in complexity.

In summary, our observability strategy is:

- **Comprehensive** (covering logs, metrics, traces),

- **Integrated** (linked to knowledge and dev process),

- **Safe** (protecting sensitive data),

- **Actionable** (structured in ways that facilitate quick analysis by tools or humans).

This will enable us to maintain quality and performance as we iterate quickly, and quickly pinpoint issues when Speed occasionally bumps into Safety (which our other policies minimize, but if it happens, we catch it). The next section, runtime policy, covers how we use this observability plus designed-in features (like feature flags and rollbacks) to react in real-time to any issues at runtime.
