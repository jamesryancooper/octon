---
title: Staff Platform Engineer Prompt
description: Prompt describing the mission, methodology alignment, and deliverables for the staff platform engineer role.
---

## Role: **Staff Platform Engineer (Monorepos & DX)**

## Mission

Recommend 2–3 real-world **Turborepo** repository structures we should model after, and propose a lean baseline layout + `turbo.json` + CI/CD guardrails that align with our methodology and hosting stack. Use concrete file-level references from the repos listed below.

## Context — Our methodology (must align)

* **Spec-first:** Spec Kit one-pager + ADR for every meaningful change (problem, scope, API/UI contracts, SLIs/SLOs, non-functionals, micro-threat model mapped to OWASP ASVS & NIST SSDF).
* **Agentic agile (BMAD):** Convert Spec → BMAD story (context packets, agent plan, acceptance criteria). Use **Cursor** to generate plans/diffs/tests from the Spec with **human checkpoints** and **license checks**.
* **Flow over ceremony:** Trunk-Based Development with short-lived branches, tiny PRs, **Vercel Preview** per PR, feature flags, guarded auto-promote to prod, instant rollback (promote prior preview). ([Vercel][1])
* **Reliability guardrails:** SLIs/SLOs, error budgets, alerts on budget burn, blameless postmortems.
* **Security by default:** Embed OWASP ASVS + NIST SSDF in CI: static analysis (CodeQL/Semgrep), dep & license scan, secret scanning, **SBOM**, contract tests.
* **Architecture:** 12-Factor, **monolith-first** in a **Turborepo** monorepo with **Hexagonal** boundaries enforced by contract tests; observability via **OpenTelemetry** + structured logs.
* **Turborepo requirements:** clear `turbo.json` pipelines, well-scoped `outputs` for caching, and **Vercel Remote Cache** (or equivalent) for fast CI/PR previews. ([Turborepo][2])

## Starter directory target

```
repo/
  apps/
    web/            # Next.js
    api/            # Node API (or Next API routes)
  packages/
    domain/         # core business logic
    adapters/       # db, http clients
    contracts/      # OpenAPI/JSON Schemas, Pact files
    ui-kit/         # shared React UI
  infra/
    ci/             # GH Actions workflows (CodeQL/Semgrep/SBOM/etc.)
    otel/           # OpenTelemetry config
  docs/
    specs/          # Spec Kits, ADRs
  turbo.json
  CODEOWNERS
```

## What to deliver

1. **Comparative recommendation (2–3 models):**

   * For each model, cite repo(s) and **point to specific paths/files** (e.g., `apps/*`, `packages/*`, `infra/*`, `turbo.json`, CI workflows).
   * Explain why the structure fits our size (two devs) and goals (speed with safety).
   * Call out trade-offs and what we’d trim/add for our case (e.g., contracts pkg, OTel folder).

2. **Proposed baseline for us (v1):**

   * **`turbo.json` tasks**: `dev`, `build`, `typecheck`, `lint`, `test`, plus `contracts:check`, `deps:scan`, `sbom`, `secrets:scan`, `preview:vercel`. Use **Turborepo task graph** conventions and **package-level overrides** where needed. ([Turborepo][2])
   * **Caching**: enable **Vercel Remote Cache** and document the `turbo login/link` flow and CI usage. ([Vercel][3])
   * **CI/CD**: GH Actions workflows for CodeQL, Semgrep, dep/license scan, SBOM, contract tests, and Preview per PR (auto-comment URL), with **guarded promote** to prod. (Preview deployment behavior must align with Vercel docs.) ([Vercel][1])
   * **Branching & releases**: trunk-based, tiny PRs, feature-flagged releases, instant rollback via promoting prior preview.
   * **Hexagonal** boundaries: show how `domain` + `adapters` + `contracts` enforce boundaries (e.g., API contracts validated in CI).
   * **Observability**: base OTel config (`infra/otel/`) and structured logs pattern for `apps/api`.

3. **90-day evolution path (brief):** how the structure scales (more apps, packages, teams) without breaking our principles.

## Evaluation criteria

* **Direct evidence from repos** (paths, `turbo.json`, CI files).
* **Low ceremony** (two-dev friendly) with strong safety nets.
* **Preview-driven** flow with cache-accelerated CI. ([Vercel][4])
* **Security + reliability** built-in, not bolted on.
* **Clear migration** steps for our current code.

## Reference repos (use these first; cite specific files/paths)

* **belgattitude/nextjs-monorepo-example** — teaching-quality monorepo template. ([GitHub][5])
* **cal.com** — large Turborepo monorepo + handbook notes. ([Cal.com Handbook][6])
* **openstatus** — compact, modern monorepo. ([GitHub][7])
* **documenso** — OSS e-signature app (look for monorepo/turbo patterns). ([GitHub][8])
* **formbricks** — see `turbo.json` and CI hygiene. ([GitHub][9])
* **dub** — polished SaaS repo with shared packages. ([GitHub][10])
* **unkey** — minimal, clean baseline. ([GitHub][11])
* **nextjs** / **vercel/examples** — official patterns to borrow. ([GitHub][12])
* **turborepo** docs — authoritative on `turbo.json`, structuring, Next.js guidance, and remote cache. ([Turborepo][2])

> If any repo above isn’t actually Turborepo-based, still mine it for **monorepo organization**, CI patterns, and contracts/testing ideas; just be explicit about what you’re borrowing.

## Constraints

* Assume **Vercel** hosting, **Turborepo**, TypeScript, PNPM (or Yarn).
* Timebox: produce the recommendation and baseline PR plan in **one working day**.

---

**Notes for you:** Use Vercel’s **Preview Deployments** for PRs and **Remote Caching** to keep feedback loops fast; configure `outputs` in `turbo.json` correctly so caching is effective. ([Vercel][1])

[1]: https://vercel.com/docs/deployments?utm_source=chatgpt.com "Deploying to Vercel"
[2]: https://turborepo.com/docs/reference/configuration?utm_source=chatgpt.com "Configuring turbo.json | Turborepo"
[3]: https://vercel.com/docs/monorepos/remote-caching?utm_source=chatgpt.com "Remote Caching - Vercel"
[4]: https://vercel.com/docs/monorepos?utm_source=chatgpt.com "Using Monorepos - Vercel"
[5]: https://github.com/belgattitude/nextjs-monorepo-example?utm_source=chatgpt.com "belgattitude/nextjs-monorepo-example - GitHub"
[6]: https://handbook.cal.com/engineering/codebase/monorepo-turborepo?utm_source=chatgpt.com "Monorepo / Turborepo | Handbook - Cal.com"
[7]: https://github.com/openstatusHQ/openstatus?utm_source=chatgpt.com "GitHub - openstatusHQ/openstatus: Uptime monitoring & API monitoring ..."
[8]: https://github.com/dharmikjagodana-baruzotech/documenso-monorepo?utm_source=chatgpt.com "dharmikjagodana-baruzotech/documenso-monorepo - GitHub"
[9]: https://github.com/formbricks/formbricks/blob/main/turbo.json?utm_source=chatgpt.com "formbricks/turbo.json at main - GitHub"
[10]: https://github.com/dubinc/dub?utm_source=chatgpt.com "GitHub - dubinc/dub: The modern link attribution platform. Loved by ..."
[11]: https://github.com/unkeyed/unkey?utm_source=chatgpt.com "GitHub - unkeyed/unkey: The Developer Platform for Modern APIs"
[12]: https://github.com/vercel/examples/blob/main/solutions/monorepo/README.md?utm_source=chatgpt.com "examples/solutions/monorepo/README.md at main · vercel/examples"
