# Source Material Map

## Purpose

Track how the retained root source documents inform the future live framework.

## Map

| Source document | Current role in package | Planned durable role |
|---|---|---|
| `architectural-evaluation-framework.md` | Primary conceptual source for invariants, smells, and failure modes | Methodology docs plus skill references |
| `architecture-readiness-scorecard.md` | Primary scoring model source | Skill/workflow output contract and methodology docs |
| `architectural-design-checklist.md` | Quick-check source for designers and reviewers | Methodology quick reference and skill references |
| `adr-acceptance-matrix.md` | ADR-specific review lens | Scaffolding governance pattern |
| `governed-autonomous-engineering-architecture-audit-prompt.md` | Execution prompt source for detailed audits | Skill/workflow internal prompt or stage reference |

## Rule

When a source document is promoted into a live surface, the durable target must
stand alone and must not rely on this package for authority.
