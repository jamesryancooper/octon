---
title: A11yKit (Optional)
description: Optional kit to centralize accessibility checks as CI policy/evaluation gates. Non‑normative; aligns with existing accessibility guidance in the documentation.
---

# A11yKit (Optional)

Purpose: Provide a thin, centralized way to run accessibility checks in CI and surface results as policy/evaluation gates without changing core architecture decisions. A11yKit is implemented as a TypeScript kit under `packages/kits/a11ykit` in the polyglot monorepo and is consumed by TS apps, CI workflows, and (optionally) Python-hosted UIs via HTTP-based checks.

## Scope

- Centralize automated a11y checks for user‑facing surfaces.
- Treat violations as policy/evaluation failures; prefer deterministic, reproducible checks with artifacts.
- Keep implementation provider‑agnostic; wire into existing CI and Knowledge Plane.

## CI Integration

- Checks (examples): Axe/Playwright, Pa11y CI, Lighthouse a11y category, eslint‑plugin‑jsx‑a11y.
- Execution: run on critical pages/flows; headless where possible for determinism.
- Output: store reports as CI artifacts; publish pass/fail summary; post links to PR.
- Gating: PolicyKit/EvalKit consume results; fail‑closed on new critical violations unless waived per Governance Model.
- Polyglot awareness: A11yKit’s checks can target TS-based UIs in `apps/*` directly and any Python-rendered UIs that expose HTTP pages, using the same reporting and gating patterns. Evidence and results are recorded in the Knowledge Plane.

## Evidence & Knowledge Plane

- Persist summaries and links to detailed reports; correlate with PR/build/trace IDs for provenance.
- Track regressions and waivers in the Knowledge Plane; auto‑expire waivers.

## Adoption

- Day 0–30: baseline a11y checks recommended (lint + a few targeted flows).
- Day 31–60+: expand coverage and enforce stricter gates as surfaces grow.

## Non‑Goals

- Does not replace manual/assistive‑tech testing for critical UX flows.
- Does not alter the architecture’s quality pillar; it implements it.

Related docs: [observability requirements](./observability-requirements.md) (accessibility baseline), [governance model](./governance-model.md) (gates/waivers), [migration playbook](./migration-playbook.md) (adoption), [tooling integration](./tooling-integration.md) (gates), [knowledge plane](../../runtime/knowledge/knowledge.md) (provenance).
