---
title: Initialize Project
description: Generate project-level bootstrap files and objective-contract artifacts from .harmony templates.
access: agent
argument-hint: "[@project-root] [--force] [--list-objectives] [--objective <id>] [--objective-owner <name>] [--objective-approved-by <name>] [--no-claude-alias] [--with-boot-files] [--with-agent-platform-adapters] [--agent-platform-adapters <csv>]"
---

# Initialize Project `/init`

Initialize project-level files after dropping `.harmony/` into a repository.

## Usage

```text
/init
/init --list-objectives
/init @path/to/project-root
/init @path/to/project-root --objective project-app-repo
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
| `--list-objectives` | No | Print the common Harmony objectives that `/init` can scaffold and exit. |
| `--objective <id>` | No | Select a common objective non-interactively (otherwise `/init` prompts when interactive and defaults to `general-purpose` when not). |
| `--objective-owner <name>` | No | Set the generated intent contract `owner` field. Defaults to the current system user. |
| `--objective-approved-by <name>` | No | Set the generated intent contract `approved_by` field. Defaults to the same value as `owner`. |
| `--no-claude-alias` | No | Skip creating/verifying `CLAUDE.md -> AGENTS.md` alias. |
| `--with-boot-files` | No | Also generate `BOOT.md` and `BOOTSTRAP.md` from templates. |
| `--with-agent-platform-adapters` | No | Opt in to adapter bootstrap config generation (`enabled.yml`). |
| `--agent-platform-adapters` | No | Comma-separated adapter IDs to enable (default: `openclaw`). |

## Implementation

Run:

```bash
.harmony/scaffolding/runtime/_ops/scripts/init-project.sh [--repo-root <path>] [--force] [--dry-run] [--list-objectives] [--objective <id>] [--objective-owner <name>] [--objective-approved-by <name>] [--no-claude-alias] [--with-boot-files] [--with-agent-platform-adapters] [--agent-platform-adapters <csv>]
```

Behavior:

1. Render `AGENTS.md` from `.harmony/scaffolding/runtime/templates/AGENTS.md`.
2. Resolve a common objective from `.harmony/scaffolding/runtime/templates/objectives/` and generate `OBJECTIVE.md` plus `.harmony/cognition/runtime/context/intent.contract.yml`.
3. Use `.harmony/agency/manifest.yml` `default_agent` for contract paths.
4. Enforce developer-context policy limits for generated `AGENTS.md` (`max_bytes`,
   `max_sections`, and allowed top-level sections) before writing.
5. Optionally render `BOOT.md` and `BOOTSTRAP.md` for BOOT compatibility.
6. Render root `alignment-check` shim from `.harmony/scaffolding/runtime/templates/alignment-check`.
7. Optionally generate adapter bootstrap config at `.harmony/capabilities/runtime/services/interfaces/agent-platform/adapters/enabled.yml` (opt-in only).
8. Create `CLAUDE.md -> AGENTS.md` symlink when safe.
9. Preserve existing files unless `--force` is supplied.

## Output

- `AGENTS.md` (generated or skipped)
- `OBJECTIVE.md` (generated or skipped)
- `.harmony/cognition/runtime/context/intent.contract.yml` (generated or skipped)
- `BOOT.md` and `BOOTSTRAP.md` (optional; generated or skipped)
- `alignment-check` shim (generated or skipped)
- `.harmony/capabilities/runtime/services/interfaces/agent-platform/adapters/enabled.yml` (optional; generated or skipped)
- `CLAUDE.md` symlink to `AGENTS.md` (created, verified, or skipped)
- Summary of actions/warnings

## References

- **Script:** `.harmony/scaffolding/runtime/_ops/scripts/init-project.sh`
- **Templates:** `.harmony/scaffolding/runtime/templates/AGENTS.md`, `.harmony/scaffolding/runtime/templates/BOOT.md`, `.harmony/scaffolding/runtime/templates/BOOTSTRAP.md`, `.harmony/scaffolding/runtime/templates/alignment-check`, `.harmony/scaffolding/runtime/templates/objectives/`
- **Intent Contract Schema:** `.harmony/engine/runtime/spec/intent-contract-v1.schema.json`
- **Canonical:** `.harmony/README.md#adopting-in-other-repos`
