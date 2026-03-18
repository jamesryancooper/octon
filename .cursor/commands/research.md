# Start Project `/research`

Create a new project in `.octon/inputs/exploratory/ideation/projects/`.

## Usage

```text
/research <slug>
```

**Example:**
```text
/research agent-memory-patterns
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `<slug>` | Yes | Project identifier (lowercase with hyphens) |

## Implementation

1. Copy `.octon/inputs/exploratory/ideation/projects/_template/` to `.octon/inputs/exploratory/ideation/projects/<slug>/`
2. Update `project.md` with the slug and current date
3. Add entry to `.octon/inputs/exploratory/ideation/projects/registry.md` under **Active**
4. Report success to user

## The Funnel

Projects are part of a pipeline from ideas to executed work:

```
ideation/scratchpad/ideas/      → Quick captures (most die here)
        ↓
ideation/scratchpad/brainstorm/ → Structured exploration (filter stage)
        ↓
ideation/projects/              → Committed research (produces artifacts)
        ↓
orchestration/missions/         → Committed execution
        ↓
cognition/context/              → Permanent knowledge
```

Use `/research` when you're ready to commit to a structured exploration that will produce harness artifacts.

## References

- **Registry:** `.octon/inputs/exploratory/ideation/projects/registry.md`
- **Template:** `.octon/inputs/exploratory/ideation/projects/_template/`
- **Documentation:** `.octon/inputs/exploratory/ideation/projects/README.md`
- **Brainstorm (upstream):** `.octon/inputs/exploratory/ideation/scratchpad/brainstorm/`
