# Scaffolding

Templates, prompts, and examples for generating new content.

## Contents

| Subdirectory | Purpose | Index |
|--------------|---------|-------|
| `_meta/architecture/` | Scaffolding subsystem specification docs | `_meta/architecture/README.md` |
| `patterns/` | Reusable design and policy patterns | `patterns/README.md` |
| `templates/` | Boilerplate for new harnesses and artifacts | `templates/manifest.json` per template |
| `prompts/` | Task templates requiring context and judgment | `prompts/README.md` |
| `examples/` | Reference patterns for common operations | — |

## Interaction Model

**Referenced.** Look up templates by name, prompts by task type.

### Available Templates

| Template | Inherits | Purpose |
|----------|----------|---------|
| `AGENTS.md` | — | Project-level agent bootstrap template rendered by `/init` |
| `BOOT.md` | — | Optional recurring startup checklist template (`/init --with-boot-files`) |
| `BOOTSTRAP.md` | — | Optional one-time bootstrap checklist template (`/init --with-boot-files`) |
| `harmony/` | — | Base harness template |
| `harmony-docs/` | `harmony/` | Documentation area harness |
| `harmony-node-ts/` | `harmony/` | Node.js / TypeScript harness |
