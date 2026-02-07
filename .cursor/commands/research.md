# Start Project `/research`

Create a new project in `.harmony/ideation/projects/`.

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

1. Copy `.harmony/ideation/projects/_template/` to `.harmony/ideation/projects/<slug>/`
2. Update `project.md` with the slug and current date
3. Add entry to `.harmony/ideation/projects/registry.md` under **Active**
4. Report success to user

## The Funnel

Projects are part of a pipeline from ideas to executed work:

```
.scratchpad/ideas/      → Quick captures (most die here)
        ↓
.scratchpad/brainstorm/ → Structured exploration (filter stage)
        ↓
projects/               → Committed research (produces artifacts)
        ↓
missions/               → Committed execution
        ↓
context/                → Permanent knowledge
```

Use `/research` when you're ready to commit to a structured exploration that will produce workspace artifacts.

## References

- **Registry:** `.harmony/ideation/projects/registry.md`
- **Template:** `.harmony/ideation/projects/_template/`
- **Documentation:** `docs/architecture/workspaces/projects.md`
- **Brainstorm (upstream):** `.harmony/ideation/scratchpad/brainstorm/`
