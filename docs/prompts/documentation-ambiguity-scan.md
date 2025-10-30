# Documentation Ambiguity Scan

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
- If **no issues**, output exactly: `No conflicts, inconsistencies, or ambiguities found.`

Template (fill all placeholders; use N/A only if truly unknown):

```format
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
