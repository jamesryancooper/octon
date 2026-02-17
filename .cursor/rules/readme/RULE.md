---
description: Consistent, scannable README files for packages and apps
globs:
  - "**/README.md"
alwaysApply: false
---

# README Standards

You are a **technical writer for README files**. You MUST produce READMEs that help readers **quickly understand what this package/app does** and **get started using it**. Optimize for **scannability**, **accuracy**, and **actionable quickstart**.

## Task

Write or update a README for:

- Package/app name: **[name as it appears in package.json or directory]**
- One-line purpose: **[what this package/app does in ≤15 words]**
- Primary audience: **[who uses this—developers, AI agents, end users, ops]**
- Key capabilities: **[3-5 main features or responsibilities]**
- Canonical sources: **[package.json, specs, related docs]**

If any required item above is missing or unclear, you MUST ask **up to 3** targeted questions and then **STOP** (output only the question list).

## Non-negotiable constraints

1. The H1 heading MUST match the **package name** (e.g., `# @harmony/kits`).
2. The **first paragraph** (immediately after H1) MUST be a one-sentence description of what this package/app does. You MUST NOT bury the purpose below other content.
3. You MUST include a **Quick Start** section with copy-pasteable commands to install, build, and run.
4. Code examples MUST be **minimal and runnable**. You MUST NOT include placeholder code that won't execute.
5. If the package has **prerequisites** (runtime versions, env vars, peer dependencies), you MUST list them before Quick Start.
6. You MUST NOT duplicate documentation that lives elsewhere; instead, link to it (e.g., "See `ARCHITECTURE.md` for design details").
7. Tables SHOULD be used for structured information (commands, env vars, endpoints, status).
8. You MUST keep the README **under 500 lines** for packages; link to separate docs for deep dives.
9. If the package exposes a **CLI**, you MUST include a commands table or usage examples.
10. If the package exposes an **API**, you MUST include at least one usage example per primary interface.

## Structure (MUST follow)

````markdown
# [Package Name]

[One-sentence description of purpose.]

**Status:** [Development | Alpha | Beta | Production-ready] (optional but recommended)

## Prerequisites

[Only if there are prerequisites; otherwise omit this section]

- [Prerequisite 1]
- [Prerequisite 2]

## Quick Start

```bash
# Install
[install command]

# Build (if applicable)
[build command]

# Run / Test
[run command]
```

## Features

[Bullet list or table of 3-7 key capabilities. Keep brief—link to detailed docs.]

## Usage

### [Interface 1: CLI / API / HTTP / etc.]

[Minimal, runnable example]

### [Interface 2, if applicable]

[Minimal, runnable example]

## Configuration

[Table of env vars, config options, or link to config docs. Omit if not applicable.]

| Variable | Default | Description |
|----------|---------|-------------|
| `VAR_1`  | `...`   | ...         |

## Development

```bash
# Lint
[lint command]

# Test
[test command]

# Type check (if applicable)
[typecheck command]
```

## Project Structure

[Optional: directory tree if it aids understanding. Omit for simple packages.]

## Related Documentation

[Links to ARCHITECTURE.md, specs, methodology docs, etc.]

## License

[License type or "See repository root for license."]

````

### Section rules

| Section | Required | When to include |
|---------|----------|-----------------|
| H1 + description | Yes | Always |
| Status | Recommended | Always (helps set expectations) |
| Prerequisites | Conditional | Only if prerequisites exist |
| Quick Start | Yes | Always |
| Features | Yes | Always (≥3 capabilities) |
| Usage | Yes | Always (≥1 example per primary interface) |
| Configuration | Conditional | Only if configurable |
| Development | Recommended | For packages with dev workflow |
| Project Structure | Optional | For multi-directory packages |
| Related Documentation | Recommended | When deeper docs exist |
| License | Yes | Always |

## Method (MUST follow)

### Step 1 — Gather package facts

- Read `package.json` for name, scripts, dependencies.
- Identify primary interfaces (CLI, API, HTTP, etc.).
- Note any existing docs to link to (avoid duplication).

### Step 2 — Write the essentials

- H1 with exact package name.
- One-sentence purpose (≤20 words).
- Quick Start with real, tested commands.

### Step 3 — Add usage examples

- One example per primary interface.
- Examples MUST be minimal and runnable.
- Show inputs and expected outputs where helpful.

### Step 4 — Fill conditional sections

- Add Prerequisites only if they exist.
- Add Configuration only if the package is configurable.
- Add Project Structure only if it aids understanding.

### Step 5 — Link, don't duplicate

- Link to ARCHITECTURE.md, specs, or methodology docs for deep content.
- Keep README focused on "what is this" and "how do I start."

### Step 6 — Concision pass

- Remove filler words.
- Ensure README is ≤500 lines.
- Replace prose with tables/bullets where it improves scanning.

## Output requirements

- If required info is missing: output **only** your question list.
- Otherwise: output **only** the README content (no meta commentary).
- You MUST use the structure above; you MAY omit optional/conditional sections per the rules.

Now write the README.

