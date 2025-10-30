---
title: Documentation Conflict and Ambiguity Scan Prompt
description: Prompt for analyzing technical documentation to surface conflicts, inconsistencies, and ambiguities.
---

Task: Review the provided technical documentation (software architecture, APIs, guides, READMEs, runbooks, RFCs, ADRs, config/CI files, code snippets). Identify any **conflicts, inconsistencies, or ambiguities**, and propose clear, minimal fixes.

Definitions (classify each issue):

- **Conflict**: Statements or diagrams that cannot all be true at once (e.g., two incompatible version requirements, contradictory flow descriptions).
- **Inconsistency**: Same concept differs across the doc(s) (terminology, numbers, file paths, commands, status codes).
- **Ambiguity**: Reasonable multiple interpretations or missing actor/scope/preconditions (e.g., “should”, unstated defaults).

What to check (software-doc specific):

1) **Build & Run**: package manager alignment (npm/yarn/pnpm), Node/Python/Java versions, `tsconfig`/`pyproject`, `Dockerfile` vs README, local vs CI commands.
2) **APIs & Types**: endpoint paths, methods, auth, status codes, pagination, idempotency, request/response schemas, example payloads vs declared types.
3) **Config & Env**: env var names, defaults, precedence, feature flags (provider registration, fallbacks), secrets handling.
4) **Architecture & Diagrams**: component boundaries, data flow, sync vs async, deployment topology, repository structure.
5) **Compatibility & Versions**: semver ranges, peer deps, runtime/toolchain versions, migration steps, deprecations.
6) **Quality Gates**: lint/type-check/test coverage gating; what runs where (local vs CI), commands match tooling.
7) **Security/Privacy**: credential storage, token scopes, PII handling, encryption claims, threat/abuse considerations.
8) **Observability & Ops**: logs levels, metrics names, traces, health checks, SLOs, alerts, runbooks.
9) **Platform Differences**: Linux/Mac/Windows commands, container vs bare-metal, cloud/provider terminology.
10) **Examples**: code compiles in principle (imports/package names/paths), examples runnable with stated prerequisites.

Repo overlay: Harmony-specific checks (use in addition to above)

1) **Framework claims vs reality**: `apps/web` uses Astro 5 (`astro`), not Next.js. Flag any references to Next.js-specific features (e.g., App Router, Server Actions, PPR, `next.config.js`) that imply usage in this repo without an explicit note.
2) **Package manager & runtime**: Node `22.x` and `pnpm@10.20.0` are pinned at the root. Prefer PNPM workspace commands (e.g., `pnpm --filter @harmony/web dev`) and Turbo tasks (`pnpm turbo run <task>`). Call out docs using `npm`/`yarn`.
3) **Monorepo boundaries**: Enforce ESLint boundaries from `eslint.config.js` and TS path aliases from `tsconfig.base.json` (`@domain/*`, `@adapters/*`, `@contracts/*`, `@ui-kit/*`, `@config/*`, `@infra/*`). Flag any guidance that suggests imports violating: `domain` (no deps); `adapters` → `domain|contracts|config`; `ui` → `config`; `app` → `domain|adapters|contracts|ui|config`.
4) **Feature flags**: Verify `HARMONY_FLAG_<FLAGNAME>` env naming, boolean parsing (`1|true|yes|on`, case-insensitive), and resolution order: Provider → Env → Defaults (see `packages/config/flags.ts`).
5) **Observability defaults**: OTel endpoint defaults to `http://localhost:4318` (`infra/otel/instrumentation.ts`). Logging uses `pino` with `withTrace()` correlation in `apps/api/src/log.ts`. Flag mismatches in docs about tracing/log fields or endpoints.
6) **Contracts and CI checks**: CI runs OpenAPI breaking-change checks with `oasdiff` comparing `packages/contracts/openapi-base.yaml` → `packages/contracts/openapi.yaml` (see `infra/ci/pr.yml`). Ensure docs reference these exact paths/names.
7) **Security & supply chain gates (CI)**: Confirm docs align with CI steps: CodeQL, Semgrep, Dependency Review, TruffleHog, and SBOM generation (Syft) per `infra/ci/pr.yml`. Note expected SBOM output path `sbom/sbom.spdx.json`.
8) **Polyglot Python service**: `apps/ai-gateway` targets Python 3.14 and uses `uv` in CI (ruff, black, mypy, pytest). Flag `pip`/`virtualenv` instructions; prefer `uv` equivalents where relevant.
9) **Preview/deploy parity**: Web preview uses `astro preview` and Vercel CLI for previews (`preview:vercel`). Flag any guidance implying Next.js-specific Vercel behavior without clarifying Astro.
10) **ESM-only**: All Node packages are ESM (`"type": "module"`). Call out CommonJS patterns (`require`, `module.exports`) in examples.

Method:

- Scan headings, diagrams, tables, code/config blocks, and cross-references across files.
- Cross-check repeated claims (counts, names, flags, versions, commands, file paths).
- Quote only the **minimum** text (1–3 lines) to evidence each issue.
- Prefer section references: `§<Heading>` (→ `<Subheading>`) and file paths. If no headings, note `lines <start–end>`.

Output rules:

- Use the exact template below.
- Order issues by **Severity: Critical → Major → Minor**, then by document order.
- Each issue must include: Where, Text (short quote), Issue (type + 1–2 sentences), Severity, Why it matters (impact), Fix (actionable).
- Keep fixes prescriptive but minimal (one-sentence rewrite, or tight bullet list / patch-like suggestion).
- Recommended fixes should not introduce friction nor unnecessary complexity and should, instead, help unblock a **two-developer team** to ship **clean, efficient, stable** code fast, while meeting **enterprise-grade security, scalability, performance, and reliability**.
- If **no issues**, output exactly: `No conflicts, inconsistencies, or ambiguities found.`

Template (fill all placeholders; use N/A only if truly unknown):

```md
Status: <what you reviewed at a high level; include file(s) and breadth of scan>

Verdict: <one-sentence overall assessment + whether issues were found>

1) <concise issue title>
   - Where: <path> §<section> [→ <subsection>] | lines <start–end>
   - Text: "<short exact quote>"
   - Issue: <conflict | inconsistency | ambiguity — brief description>
   - Severity: <Critical | Major | Minor>
   - Why it matters: <impact in 1 sentence>
   - Fix: <proposed concrete change (rewrite, command, config, or code)>

2) <next issue>
   ...

Summary: <counts by type and severity + any systemic themes in ≤2 sentences>
```

Style notes:

- Use backticks for file paths, code, flags, env vars, and commands.
- Prefer active voice and neutral tone.
- Do not restate the whole document; focus on deltas that unblock correct implementation and operation.
- When suggesting commands, ensure package manager/runtime consistency with the doc.
- For this repo: prefer `pnpm` over `npm/yarn`, Node `22.x`, and `uv` for Python in `apps/ai-gateway`.
