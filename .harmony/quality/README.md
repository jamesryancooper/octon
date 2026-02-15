# Quality

Quality gates and completion criteria.

## Contents

| File | Purpose | When to Use |
|------|---------|-------------|
| `_meta/architecture/README.md` | Quality subsystem specification docs | When changing quality policy model |
| `complete.md` | Definition of Done | Before marking any task complete |
| `session-exit.md` | Session exit checklist | Before ending a session |
| `testing-strategy.md` | Testing strategy and quality approach | When designing or validating tests |
| `security-and-privacy.md` | Security and privacy baseline policy | When handling sensitive data or controls |
| `data-handling-and-retention.md` | Data handling and retention standards | When designing data lifecycle behavior |
| `_ops/scripts/validate-harness-structure.sh` | Structural namespace and discovery contract validation | Before release or architecture-sensitive merges |
| `_ops/scripts/validate-audit-subsystem-health-alignment.sh` | Drift guardrail between `.harmony` architecture and `audit-subsystem-health` | When `.harmony` architecture surfaces change |

## Contract

- Read `complete.md` before marking any task as completed.
- Read `session-exit.md` before ending a session or context reset.
- These files define the quality bar. Do not skip them.
