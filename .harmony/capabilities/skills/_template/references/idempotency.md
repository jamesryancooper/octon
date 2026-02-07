# Idempotency Reference

**Required when capability:** `idempotent`

Safe retry semantics for the {{skill_name}} skill.

## Idempotency Guarantees

This skill is idempotent: running it multiple times with the same input produces the same effect.

| Operation | Idempotent? | Notes |
|-----------|-------------|-------|
| {{operation_1}} | Yes/No | {{explanation}} |
| {{operation_2}} | Yes/No | {{explanation}} |
| {{operation_3}} | Yes/No | {{explanation}} |

## Safe Retry Conditions

The skill can be safely retried when:
- {{condition_1}}
- {{condition_2}}
- {{condition_3}}

## Unsafe Retry Conditions

Do NOT retry when:
- {{condition_1}} — {{why_unsafe}}
- {{condition_2}} — {{why_unsafe}}

## Idempotency Keys

| Input | Key Derivation | TTL |
|-------|----------------|-----|
| {{input_type}} | {{how_key_is_derived}} | {{expiration}} |

## Implementation Notes

### State Checking

Before performing operations, the skill checks:
1. {{state_check_1}}
2. {{state_check_2}}

### Duplicate Detection

{{How the skill detects and handles duplicate invocations}}

### Side Effect Management

| Side Effect | How Handled |
|-------------|-------------|
| {{effect_1}} | {{strategy}} |
| {{effect_2}} | {{strategy}} |
