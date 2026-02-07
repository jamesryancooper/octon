# Step 1: Assess Files

Read the target `.workspace` files. Compare structure against `docs/architecture/workspaces/README.md` canonical definition.

## Structure Check

Verify presence of required and optional components:

| Category | Items | Status |
|----------|-------|--------|
| **Required files** | `START.md`, `scope.md`, `conventions.md` | ✅/❌ |
| **Required dirs** | `progress/`, `checklists/` | ✅/❌ |
| **Optional dirs** | `prompts/`, `workflows/`, `commands/`, `context/`, `templates/`, `examples/` | Present? |

## File Assessment Criteria

Assess each file against these criteria:

| Criterion | Question |
|-----------|----------|
| **Essentiality** | Does an agent *need* this? |
| **Token efficiency** | Can it be more concise? |
| **Redundancy** | Is it duplicated elsewhere? |
| **Actionability** | Does it enable immediate action? |
| **Failure prevention** | Does it prevent a specific failure mode? |
| **Scope alignment** | Does content match `scope.md`? |
| **Currency** | Is content up to date? |

