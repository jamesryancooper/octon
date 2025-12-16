# Evaluate Workspace

## Context

Evaluate a `.workspace` directory for token efficiency and agent effectiveness.

## Instructions

1. Read the target `.workspace` files
2. For each file, assess against these criteria:
   - **Essentiality:** Does an agent *need* this?
   - **Token efficiency:** Can it be more concise?
   - **Redundancy:** Is it duplicated elsewhere?
   - **Actionability:** Does it enable immediate action?
   - **Failure prevention:** Does it prevent a specific failure mode?

3. Classify content:
   - Agent-facing → stays in `.workspace/`
   - Human-facing → moves to `.humans/`

4. Check token budgets:

   | Scope         | Target    | Max    |
   |---------------|-----------|--------|
   | Total harness | ~2,000    | ~5,000 |
   | Single file   | ~300      | ~500   |
   | START.md      | ~200      | ~300   |

## Output

1. **Keep** — Elements to retain (with justification)
2. **Cut/Merge** — Elements to remove or consolidate
3. **Move to `.humans/`** — Human-facing content
4. **Minimal structure** — Proposed lean structure
5. **Gaps** — Missing essential elements
