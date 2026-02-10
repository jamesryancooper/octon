# Step 1: Assess Files

Read the target `.harmony` files. Compare structure against `docs/architecture/harness/README.md` canonical definition.

## Structure Check

Verify presence of required and optional components:

| Category | Items | Status |
|----------|-------|--------|
| **Required files** | `START.md`, `scope.md`, `conventions.md` | ✅/❌ |
| **Required dirs** | `continuity/`, `quality/` | ✅/❌ |
| **Optional dirs** | `scaffolding/prompts/`, `orchestration/workflows/`, `capabilities/commands/`, `cognition/context/`, `scaffolding/templates/`, `scaffolding/examples/` | Present? |

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

