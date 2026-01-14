# Synthesize Research `/synthesize-research`

Synthesize scattered research notes into a coherent findings document.

See `.harmony/skills/research-synthesizer/SKILL.md` for full details.

## Usage

```text
/synthesize-research <research-folder>
```

**Examples:**
```text
/synthesize-research projects/auth-patterns/
/synthesize-research .workspace/skills/sources/api-design/
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
4. Writes output to `.workspace/skills/outputs/drafts/<topic>-synthesis.md`
5. Creates run log in `.workspace/skills/logs/runs/`

## Output

```text
.workspace/skills/outputs/drafts/<topic>-synthesis.md
```

## References

- **Skill:** `.harmony/skills/research-synthesizer/SKILL.md`
- **Shared Registry:** `.harmony/skills/registry.yml`
- **Local Registry:** `.workspace/skills/registry.yml` (for input/output mappings)
- **Documentation:** `docs/architecture/workspaces/skills.md`
