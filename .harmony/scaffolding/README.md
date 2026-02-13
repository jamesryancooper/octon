# Scaffolding

Templates, prompts, and examples for generating new content.

## Contents

| Subdirectory | Purpose | Index |
|--------------|---------|-------|
| `architecture/` | Scaffolding subsystem specification docs | `architecture/README.md` |
| `patterns/` | Reusable design and policy patterns | `patterns/README.md` |
| `templates/` | Boilerplate for new harnesses and artifacts | `templates/manifest.json` per template |
| `prompts/` | Task templates requiring context and judgment | `prompts/README.md` |
| `examples/` | Reference patterns for common operations | — |

## Interaction Model

**Referenced.** Look up templates by name, prompts by task type.

### Available Templates

| Template | Inherits | Purpose |
|----------|----------|---------|
| `harmony/` | — | Base harness template |
| `harmony-docs/` | `harmony/` | Documentation area harness |
| `harmony-node-ts/` | `harmony/` | Node.js / TypeScript harness |
