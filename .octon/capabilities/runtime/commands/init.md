---
title: Initialize Project
description: Generate canonical .octon bootstrap files plus root ingress adapters and objective-contract artifacts.
access: agent
argument-hint: "[@project-root] [--force] [--dry-run] [--list-objectives] [--objective <id>] [--objective-owner <name>] [--objective-approved-by <name>] [--no-claude-alias] [--with-boot-files] [--with-agent-platform-adapters] [--agent-platform-adapters <csv>]"
---

# Initialize Project `/init`

Initialize project-level files after dropping `.octon/` into a repository.

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
| `@project-root` | No | Target project root. Defaults to parent of current `.octon/`. |
| `--force` | No | Overwrite canonical `.octon` bootstrap artifacts and refresh root ingress adapters. |
| `--dry-run` | No | Show actions without writing files. |
| `--list-objectives` | No | Print the common Octon objectives that `/init` can scaffold and exit. |
| `--objective <id>` | No | Select a common objective non-interactively (otherwise `/init` prompts when interactive and defaults to `general-purpose` when not). |
| `--objective-owner <name>` | No | Set the generated intent contract `owner` field. Defaults to the current system user. |
| `--objective-approved-by <name>` | No | Set the generated intent contract `approved_by` field. Defaults to the same value as `owner`. |
| `--no-claude-alias` | No | Deprecated compatibility flag. Root `CLAUDE.md` remains a required ingress adapter and will still be refreshed. |
| `--with-boot-files` | No | Also generate `BOOT.md` and `BOOTSTRAP.md` from templates. |
| `--with-agent-platform-adapters` | No | Opt in to adapter bootstrap config generation (`enabled.yml`). |
| `--agent-platform-adapters` | No | Comma-separated adapter IDs to enable (default: `openclaw`). |

## Implementation

Run:

```bash
.octon/scaffolding/runtime/_ops/scripts/init-project.sh [--repo-root <path>] [--force] [--dry-run] [--list-objectives] [--objective <id>] [--objective-owner <name>] [--objective-approved-by <name>] [--no-claude-alias] [--with-boot-files] [--with-agent-platform-adapters] [--agent-platform-adapters <csv>]
```

Behavior:

1. Render canonical `/.octon/AGENTS.md` from `.octon/scaffolding/runtime/bootstrap/AGENTS.md`.
2. Refresh repo-root `AGENTS.md` and `CLAUDE.md` ingress adapters to `/.octon/AGENTS.md`.
3. Resolve a common objective from `.octon/scaffolding/runtime/bootstrap/objectives/` and generate `/.octon/OBJECTIVE.md` plus `.octon/cognition/runtime/context/intent.contract.yml`.
4. Use `.octon/agency/manifest.yml` `default_agent` for contract paths.
5. Enforce developer-context policy limits for the generated AGENTS contract content before writing ingress adapters.
6. Optionally render `BOOT.md` and `BOOTSTRAP.md` for BOOT compatibility.
7. Render root `alignment-check` shim from `.octon/scaffolding/runtime/bootstrap/alignment-check`.
8. Optionally generate adapter bootstrap config at `.octon/capabilities/runtime/services/interfaces/agent-platform/adapters/enabled.yml` (opt-in only).
9. Preserve canonical `.octon` files unless `--force` is supplied; always refresh drifted ingress adapters.

## Output

- `.octon/AGENTS.md` (generated or skipped)
- root `AGENTS.md` ingress adapter (created, refreshed, or skipped)
- `.octon/OBJECTIVE.md` (generated or skipped)
- `.octon/cognition/runtime/context/intent.contract.yml` (generated or skipped)
- `BOOT.md` and `BOOTSTRAP.md` (optional; generated or skipped)
- `alignment-check` shim (generated or skipped)
- `.octon/capabilities/runtime/services/interfaces/agent-platform/adapters/enabled.yml` (optional; generated or skipped)
- root `CLAUDE.md` ingress adapter to `/.octon/AGENTS.md` (created, refreshed, or skipped)
- Summary of actions/warnings

## References

- **Script:** `.octon/scaffolding/runtime/_ops/scripts/init-project.sh`
- **Bootstrap Assets:** `.octon/scaffolding/runtime/bootstrap/AGENTS.md`, `.octon/scaffolding/runtime/bootstrap/BOOT.md`, `.octon/scaffolding/runtime/bootstrap/BOOTSTRAP.md`, `.octon/scaffolding/runtime/bootstrap/alignment-check`, `.octon/scaffolding/runtime/bootstrap/objectives/`
- **Ingress Validation:** `.octon/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh`
- **Intent Contract Schema:** `.octon/engine/runtime/spec/intent-contract-v1.schema.json`
- **Canonical:** `.octon/README.md#adopting-in-other-repos`
