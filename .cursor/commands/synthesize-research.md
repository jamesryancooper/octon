# Synthesize Research `/synthesize-research`

Synthesize scattered research notes into a coherent findings document.

See `.harmony/capabilities/skills/synthesize-research/SKILL.md` for full details.

## Usage

```text
/synthesize-research <research-folder>
```

**Examples:**
```text
/synthesize-research _state/resources/synthesize-research/projects/auth-patterns/
/synthesize-research _state/resources/synthesize-research/api-design/
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `<research-folder>` | Yes | Folder containing research notes, logs, findings |

## What It Does

1. Reads all `.md` files in the input folder
2. Extracts findings and identifies themes
3. Synthesizes into structured document with:
   - Executive summary
   - Key themes with evidence
   - Contradictions and resolutions
   - Open questions
4. Writes output to `.harmony/output/drafts/<topic>-synthesis.md`
5. Creates run log in `.harmony/capabilities/skills/_state/logs/synthesize-research/`

## Output

```text
.harmony/output/drafts/<topic>-synthesis.md
```

## References

- **Skill:** `.harmony/capabilities/skills/synthesize-research/SKILL.md`
- **Shared Registry:** `.harmony/capabilities/skills/registry.yml`
- **Local Registry:** `.harmony/capabilities/skills/registry.yml` (for input/output mappings)
- **Documentation:** `.harmony/capabilities/skills/README.md`
