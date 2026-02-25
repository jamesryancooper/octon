---
title: Initialize Project
description: Generate project-level bootstrap files from .harmony templates.
access: agent
argument-hint: "[@project-root] [--force] [--no-claude-alias] [--with-boot-files] [--with-agent-platform-adapters] [--agent-platform-adapters <csv>]"
---

# Initialize Project `/init`

Initialize project-level files after dropping `.harmony/` into a repository.

## Usage

```text
/init
/init @path/to/project-root
/init @path/to/project-root --force
/init @path/to/project-root --with-boot-files
/init @path/to/project-root --with-agent-platform-adapters
/init @path/to/project-root --with-agent-platform-adapters --agent-platform-adapters openclaw,crewai
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `@project-root` | No | Target project root. Defaults to parent of current `.harmony/`. |
| `--force` | No | Overwrite existing `AGENTS.md` with rendered template. |
| `--dry-run` | No | Show actions without writing files. |
| `--no-claude-alias` | No | Skip creating/verifying `CLAUDE.md -> AGENTS.md` alias. |
| `--with-boot-files` | No | Also generate `BOOT.md` and `BOOTSTRAP.md` from templates. |
| `--with-agent-platform-adapters` | No | Opt in to adapter bootstrap config generation (`enabled.yml`). |
| `--agent-platform-adapters` | No | Comma-separated adapter IDs to enable (default: `openclaw`). |

## Implementation

Run:

```bash
.harmony/scaffolding/runtime/_ops/scripts/init-project.sh [--repo-root <path>] [--force] [--dry-run] [--no-claude-alias] [--with-boot-files] [--with-agent-platform-adapters] [--agent-platform-adapters <csv>]
```

Behavior:

1. Render `AGENTS.md` from `.harmony/scaffolding/runtime/templates/AGENTS.md`.
2. Use `.harmony/agency/manifest.yml` `default_agent` for contract paths.
3. Enforce developer-context policy limits for generated `AGENTS.md` (`max_bytes`,
   `max_sections`, and allowed top-level sections) before writing.
4. Optionally render `BOOT.md` and `BOOTSTRAP.md` for BOOT compatibility.
5. Render root `alignment-check` shim from `.harmony/scaffolding/runtime/templates/alignment-check`.
6. Optionally generate adapter bootstrap config at `.harmony/capabilities/runtime/services/interfaces/agent-platform/adapters/enabled.yml` (opt-in only).
7. Create `CLAUDE.md -> AGENTS.md` symlink when safe.
8. Preserve existing files unless `--force` is supplied.

## Output

- `AGENTS.md` (generated or skipped)
- `BOOT.md` and `BOOTSTRAP.md` (optional; generated or skipped)
- `alignment-check` shim (generated or skipped)
- `.harmony/capabilities/runtime/services/interfaces/agent-platform/adapters/enabled.yml` (optional; generated or skipped)
- `CLAUDE.md` symlink to `AGENTS.md` (created, verified, or skipped)
- Summary of actions/warnings

## References

- **Script:** `.harmony/scaffolding/runtime/_ops/scripts/init-project.sh`
- **Templates:** `.harmony/scaffolding/runtime/templates/AGENTS.md`, `.harmony/scaffolding/runtime/templates/BOOT.md`, `.harmony/scaffolding/runtime/templates/BOOTSTRAP.md`, `.harmony/scaffolding/runtime/templates/alignment-check`
- **Canonical:** `.harmony/README.md#adopting-in-other-repos`
