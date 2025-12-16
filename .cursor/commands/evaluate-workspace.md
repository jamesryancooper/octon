# Evaluate Workspace `/evaluate-workspace`

Evaluate a `.workspace` directory for token efficiency and agent effectiveness.

## Usage

```
/evaluate-workspace @path/to/.workspace
```

Or to evaluate the root workspace:

```
/evaluate-workspace @.workspace
```

## Instructions

1. Confirm the user included a reference to a `.workspace` directory. If not, ask them to specify one (e.g., `@.workspace` or `@docs/feature/.workspace`).

2. Read all agent-facing files in the target `.workspace`:
   - Root files: `START.md`, `scope.md`, `conventions.md`, `init.sh`
   - `progress/`: `log.md`, `tasks.json`
   - `checklists/`: `done.md`
   - `prompts/`, `workflows/`, `commands/`, `context/`: all `.md` files
   - Skip dot-prefixed directories (`.humans/`, `.inbox/`, `.archive/`)

3. For each file, assess against these criteria:
   - **Essentiality:** Does an agent *need* this?
   - **Token efficiency:** Can it be more concise?
   - **Redundancy:** Is it duplicated elsewhere?
   - **Actionability:** Does it enable immediate action?
   - **Failure prevention:** Does it prevent a specific failure mode?

4. Estimate token counts (words × 1.3) and check against budgets:

   | Scope         | Target    | Max    |
   |---------------|-----------|--------|
   | Total harness | ~2,000    | ~5,000 |
   | Single file   | ~300      | ~500   |
   | START.md      | ~200      | ~300   |

5. Classify content:
   - Agent-facing → stays in `.workspace/`
   - Human-facing → move to `.humans/`

6. Produce evaluation report with these sections:
   1. **Token Analysis** — Table of files with estimated tokens vs budget
   2. **Keep** — Elements to retain (with justification)
   3. **Cut/Merge** — Elements to remove or consolidate
   4. **Move to `.humans/`** — Human-facing content identified
   5. **Minimal structure** — Proposed lean structure
   6. **Gaps** — Missing essential elements (compare against root `.workspace`)

> Reference: `.workspace/prompts/evaluate-workspace.md`
