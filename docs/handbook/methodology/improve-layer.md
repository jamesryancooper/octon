# Improve Layer (Kaizen/Autopilot)

**Purpose:**

The *Improve* layer is an internal, autonomous “kaizen” system that continuously proposes **small, reversible, evidence‑based improvements** across the repo—docs, tests, observability, performance, and governance—without bypassing human control. It runs on schedules and triggers, opens PRs with proof (plan/diff/tests/trace), and defers approvals to code owners.

> TL;DR
>
> - Treat improvements as a product: sensors → evaluators → planners → actuators → reports.
> - Only tiny, safe changes can autopilot; everything else is “copilot” (PR + human approval).
> - Never pushes to protected branches; never self‑approves; always leaves an audit trail.

---

## Scope & Non‑Goals

**In‑scope:**

- Documentation hygiene (linting, link fixes, template normalization, missing ADR links)
- Governance hygiene (risk rubric nits, required sections, CODEOWNERS coverage hints)
- Observability scaffolding (add missing spans/logs on changed paths, sample trace outlines)
- Preview/E2E smoke coverage checks and wiring suggestions
- Contract drift detection and suggested schema/API updates
- Performance nudges (bundle size notes, caching headers, perf budget deltas)
- Feature‑flag hygiene (stale‑flag diff, owner mapping, expiry annotations)

**Out‑of‑scope / Non‑goals:**

- Changes that materially alter runtime behavior without human approval
- Secret access, key management, or policy exceptions
- Merging/approving its own PRs; cutting releases; production deployments

---

## Architecture

```plaintext
/improve/
  policies/        # YAML/JSON: risk rubric, change-type gates, CI gates
  evaluators/      # Scripts to assess repo state (docs, contracts, OTel, perf, flags)
  codemods/        # Safe AST transforms and recipe-based refactors (low-risk only)
  agents/          # Planners that create issues/PRs with evidence (PatchKit wrappers)
  reports/         # Weekly Kaizen report (SLO burn, perf/cost deltas, hygiene score)
.github/workflows/improve.yml   # Scheduled and manual runners
```

Complements existing `infra/ci/*`, `docs/prompts/*`, and `scripts/*` (e.g., flags hygiene, smoke checks).

**Data flow:**

1. **Sensors** collect signals: CI outcomes, preview smoke results, OTel traces/logs, DORA/SRE metrics, perf budgets.
2. **Evaluators** compare signals to policy (e.g., required sections present, span coverage ≥ threshold, bundle size < budget).
3. **Planners** cut work into *tiny, reversible* tasks with acceptance criteria.
4. **Actuators** open PRs with a structured template and attach artifacts (diff/tests/trace/screenshot/report).
5. **Safety** rules enforce that bots cannot push or approve to protected branches; approvals delegated to CODEOWNERS.
6. **Reporting** synthesizes a weekly kaizen digest.

---

## Starter Backlog

**Autopilot (safe by default):**

- Docs hygiene PRs: fix lint/links/titles; normalize templates; surface missing ADR links.
- Flags cleanup PR: weekly stale‑flags diff with owners/expiry.
- Observability scaffolding PRs: add missing spans/logs on changed paths and attach a sample trace outline.
- Preview smoke wiring: ensure top routes are covered; failures reference `scripts/smoke-check.sh`.

**Copilot (evidence + owner approval):**

- Contract drift fixes: auto‑adjust JSON‑Schema/OpenAPI snippets; include `oasdiff` output.
- Perf budget nudges: reduce bundle bloat or add caching; include budget deltas.
- Threat‑model test PRs: generate unit/contract tests from spec prompts (STRIDE checklist).

## Ownership & Governance

- **Area owners**: Defined via CODEOWNERS; all Improve PRs route to the relevant owners.
- **Bot identity**: `@repo-improve-bot` (or similar) for clarity and auditability.
- **Labels**: `autopilot`, `copilot`, `needs-owner`, `risk:low|med|high`, `docs`, `observability`, `contracts`, `perf`, `flags`.
- **Merging policy**: Autopilot PRs still require at least one human approval; bots cannot approve.
- **Change freeze respect**: Improve layer observes release freezes and incident stop‑the‑line rules.

---

## Risk Model & Guardrails

| Change type                        | Examples                                                       | Track            | Preconditions                                  | Merge policy            |
| ---------------------------------- | -------------------------------------------------------------- | ---------------- | ---------------------------------------------- | ----------------------- |
| **Docs/content-only**              | Markdown lint fixes, TOC, link repairs, template normalization | **Autopilot**    | CI green; no code changes                      | Human review required   |
| **Dev‑only hygiene**               | Comments, README badges, non-executable metadata               | **Autopilot**    | Tests unaffected                               | Human review required   |
| **Observability scaffolding**      | Add missing spans/logs with no logic change                    | **Copilot**      | Trace plan attached; preview smoke passes      | Owner approval          |
| **Contract drift fix (suggested)** | JSON Schema/OpenAPI snippet updates                            | **Copilot**      | `oasdiff` report attached; contract tests pass | Owner approval          |
| **Perf/cost nudge**                | Reduce bundle, add cache headers                               | **Copilot**      | Budget deltas attached; no regression          | Owner approval          |
| **Threat‑model tests**             | Generate tests from STRIDE/spec prompts                        | **Copilot**      | STRIDE checklist attached; tests‑only change   | Owner approval          |
| **Runtime behavior**               | Any functional change                                          | **Out-of-scope** | —                                              | Must be human‑initiated |

**Non‑negotiables:**

- No direct pushes to protected branches
- No self‑approvals
- AI configuration pinned and versioned
- Produces artifacts for every suggestion (evidence‑based)

---

## Triggers & Schedules

- **Daily (weekdays)**: Docs hygiene, preview smoke coverage audit, stale-flag scan
- **Weekly**: Kaizen report, perf/cost budget deltas, span coverage report
- **Event‑based**: SLO burn rate, CI flakiness spikes, contract drift detection, perf regressions, DORA regressions, cost anomalies

> Default schedule: weekdays at 12:00 **America/Chicago**; configurable via `on.schedule`.

---

## CI Wiring (GitHub Actions skeleton)

```yaml
name: Improve
on:
  workflow_dispatch:
  schedule:
    - cron: "0 18 * * 1-5"  # 12:00 PM America/Chicago = 18:00 UTC

permissions:
  contents: write
  pull-requests: write

jobs:
  docs-hygiene:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with: { version: 9 }
      - run: pnpm -w install --frozen-lockfile
      - run: pnpm -w exec markdownlint .
      - run: pnpm -w exec vale docs/ || true
      - run: node improve/agents/open-pr-docs-hygiene.mjs

  preview-smoke:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Preview smoke check (non-blocking example)
        run: |
          export SMOKE_URLS="${SMOKE_URLS:-$SMOKE_ROUTES}"
          export SMOKE_ROUTES="${SMOKE_ROUTES:-https://example.com/ https://example.com/healthz https://example.com/api/ready}"
          bash scripts/smoke-check.sh || true

  flags-hygiene:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: node scripts/flags-stale-report.js
      - run: node improve/agents/open-pr-stale-flags.mjs

  observability-scaffold:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: node improve/evaluators/otel-coverage.mjs --threshold 0.7
      - run: node improve/agents/open-pr-otel-scaffold.mjs

  contracts-drift:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pnpm -w exec oasdiff ./packages/contracts/openapi.yaml ./dist/openapi.from-code.json --format md > ./improve/reports/oasdiff.md || true
      - run: node improve/agents/open-pr-contract-drift.mjs
```

---

## Configuration (Policy Examples)

**`/improve/policies/risk.yml`:**

```yaml
change_types:
  docs:
    track: autopilot
    requires:
      - ci_green
      - no_runtime_change
  dev_hygiene:
    track: autopilot
    requires: [ci_green]
  observability_scaffold:
    track: copilot
    requires: [trace_plan, preview_smoke_green]
  contract_drift:
    track: copilot
    requires: [oasdiff_attached, contract_tests_green]
  perf_nudge:
    track: copilot
    requires: [budget_deltas_attached]
  threat_model_tests:
    track: copilot
    requires: [stride_checklist_attached, spec_prompts_attached]
non_negotiables: [no_push_protected, no_self_approve, ai_config_pinned]
```

**`/improve/policies/gates.yml`:**

```yaml
required_sections:
  - docs/README.md
  - docs/ARCHITECTURE.md
  - docs/ADR/
min_span_coverage: 0.70
max_bundle_kb: 250
preview_smoke_routes:
  - /
  - /healthz
  - /api/ready
```

---

## PR Template (used by agents)

**`.github/PULL_REQUEST_TEMPLATE/improve.md`:**

```md
### Why
- What signal triggered this? (link to report)

### What changed (low-risk, reversible)
- …

### Evidence
- CI run: …
- Artifacts: oasdiff/report, trace plan, preview smoke link

### Safety
- Change type: docs | dev_hygiene | observability_scaffold | contract_drift | perf_nudge
- Track: autopilot | copilot
- Non-negotiables enforced: ✅ no push to protected, ✅ no self-approve, ✅ AI config pinned
```

---

## Reports

Weekly report generated to `/improve/reports/YYYY‑WW.md` with:

- **Hygiene score** (docs coverage, span coverage, bundle budget adherence)
- **Incidents & freezes observed** (links)
- **Top recommendations** (ranked, with projected impact/cost)
- **Merged Improve PRs** (by area)

---

## Extending the Improve Layer

1. Add a new evaluator script under `improve/evaluators/` (emit JSON with findings and severity).
2. Register it in `improve/agents/*` planner to open a PR with a standardized template.
3. Update `policies/risk.yml` with the new `change_type` and preconditions.
4. Add a job to `improve.yml` or hook an existing job’s step.

**Evaluator output contract:**

```json
{
  "change_type": "docs",
  "title": "Normalize headings in ADRs",
  "evidence": { "report": "improve/reports/2025-11-09-docs.md" },
  "diff": "...optional unified diff...",
  "risk": "low"
}
```

---

## Security & Compliance

- Uses least privilege GitHub token; write access limited to PR creation.
- Respects CODEOWNERS and branch protections; cannot push to protected branches.
- AI usage (if any) must be **pinned, versioned, and logged**; prompts live in repo and are reviewed like code.
- No secrets or production data access; telemetry is metadata only.

---

## Rollout Plan

**Phase 0 (Dry Run)**: Generate reports only; no PRs.

**Phase 1 (Autopilot)**: Enable docs/dev‑hygiene PRs; limited surface area; measure noise vs. value.

**Phase 2 (Copilot)**: Add observability scaffolds, contract drift suggestions, and perf nudges behind labels and owner approval.

**Success criteria:**

- +X% docs completeness
- +Y% span coverage on changed paths
- −Z% bundle size or build time
- Fewer flaky CI reruns; faster MTTR on hygiene regressions

---

## FAQ

**Does this replace engineers?** No. It proposes tiny, reversible changes with evidence; humans approve and own outcomes.

**Will it spam PRs?** Guarded by schedules, thresholds, and policy; all actions are rate‑limited and label‑gated.

**What happens during an incident or freeze?** Improve layer observes freezes and stop‑the‑line rules and will only file issues, not PRs.

**How do I disable a job?** Comment out the job in `improve.yml` or set a repo variable/flag the job checks before running.

---

**Drop‑in usage:**

- Copy this file to `docs/improve/README.md` (or link from your methodology doc)
- Add the `/improve/` directory and `improve.yml` workflow
- Configure `policies/*` to match your org’s risk rubric and gates

### README snippet (pasteable)

```md
> Layer: Self‑Improvement (Kaizen/Autopilot)
> Purpose: Continuously propose tiny, reversible improvements to docs, tests, observability, and guardrails.
> Scope: Autopilot for trivial/low‑risk changes; Copilot PRs for anything touching runtime behavior.
> Inputs: CI results, DORA/SRE metrics, OTel traces/logs, risk rubric.
> Outputs: PRs with evidence (plan/diff/tests/trace), weekly reports, and policy updates.
> Safety: No direct pushes or approvals; AI configs pinned; human checkpoints enforced.
```
