# Cognition

Context, decisions, and analyses that inform agent work.

## Contents

| Subdirectory | Purpose | Index |
|--------------|---------|-------|
| `architecture/` | Cross-cutting harness and methodology architecture docs | — |
| `principles/` | Canonical principles, pillar docs, and purpose docs | `principles/principles.md` |
| `methodology/` | AI-native development methodology | `methodology/README.md` |
| `context/` | Shared reference material (decisions, lessons, glossary, constraints, risk) | `context/index.yml` |
| `decisions/` | Full Architecture Decision Records (numbered: `001-*.md`) | — |
| `analyses/` | In-depth analytical documents | — |

## Interaction Model

**Reference material.** Access files by explicit path when context is needed. Read `context/index.yml` for the file index with "when to read" guidance.

### Key Context Files

| File | When to Read |
|------|-------------|
| `context/constraints.md` | Before any work — know hard limits |
| `context/decisions.md` | Before making decisions that might duplicate past choices |
| `context/lessons.md` | Before proposing approaches (check anti-patterns) |
| `context/glossary.md` | When encountering harness-specific terms |
| `context/glossary-repo.md` | When encountering repo-wide terms |
| `context/primitives.md` | When deciding what type of artifact to create |

### Mutability

- `context/decisions.md` is append-only. Never modify existing entries.
- All files in `decisions/` are append-only (full ADRs).
- Other context files are mutable.
