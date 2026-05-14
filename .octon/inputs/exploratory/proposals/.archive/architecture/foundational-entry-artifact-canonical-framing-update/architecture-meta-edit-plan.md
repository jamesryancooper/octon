# Architecture Meta Edit Plan

_Status: In-review proposal packet artifact_


## Targets

- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `.octon/framework/cognition/_meta/terminology/glossary.md`

## Specification edit

Add a short section near Purpose or Structural Invariants:

```markdown
## Canonical Runtime Framing

Octon's core runtime is a Governed Workflow Runtime for consequential software work. It compiles the execution harness for each admitted workflow and allows agents to participate only as bounded, evidenced activity nodes. Workflow state owns control flow; agents do not.
```

## Glossary edits

Add:
- Governed Workflow Runtime
- Task-Specific Execution Harness
- Bounded Agent Node
- Evidenced Activity Node

Constrain:
- Governed Agent Runtime
- Autonomy
- Orchestrator
- Harness

## Contract registry

Do not change unless doc-target metadata or delegated registries require explicit entries. If changed, ensure machine-readable authority remains intact and proposal paths are not referenced as authority.
