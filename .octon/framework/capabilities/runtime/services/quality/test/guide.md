# Test — Tests & Contracts (Playwright/Pact/Schemathesis)

- **Purpose:** Enforce UI/E2E, API contract, and fuzz tests as CI gates, adding governed contract enforcement to Octon.
- **Responsibilities:** authoring UI/E2E flows (Playwright), validating consumer/provider contracts (Pact), fuzzing OpenAPI endpoints (Schemathesis), running unit/integration suites, emitting reports/status checks.
- **Octon alignment:** advances consistent contracts and safe trunk-based flow by gating PRs with deterministic tests; aligns with agent-first, system-governed gates for hexagonal boundaries.
- **Integrates with:** Agent (executes checks), Dev (emits stubs), A11y (piggybacks UI flows), Seed (fixtures).
- **I/O:** reads `tests/**`, `openapi.*`, `pact/*.json`; emits JUnit/HTML reports and PR status checks.
- **Wins:** Prevents regressions at boundaries; stabilizes critical flows for fast, safe merges.
- **Implementation Choices (opinionated):**
  - Playwright: browser/UI and end-to-end runner for critical flows.
  - Pact: consumer/provider HTTP contract testing at service boundaries.
  - Schemathesis: OpenAPI-driven property-based fuzzing for APIs.
  - pytest: unified unit/integration runner with JUnit output.
- **Common Qs:** *Local run?* `pytest -q` and `npx playwright test` (CI mirrors). *Coverage/thresholds?* Set in `policy/test.yml`; PRs block if below. *Where to add contracts?* `pact/*.json` and OpenAPI with suites in `tests/**`.
- **Octon default:** Treat contracts as hexagonal boundary enforcement; run on every PR as a required gate.
