# Dependencies Reference

**Required when capability:** `external-dependent`

External service requirements for the {{skill_name}} skill.

## External Dependencies

| Service | Purpose | Required | Fallback |
|---------|---------|----------|----------|
| {{service_1}} | {{why_needed}} | Yes/No | {{fallback_behavior}} |
| {{service_2}} | {{why_needed}} | Yes/No | {{fallback_behavior}} |
| {{service_3}} | {{why_needed}} | Yes/No | {{fallback_behavior}} |

## Configuration

### {{Service 1}}

**Required environment:**
```
{{ENV_VAR_1}}={{description}}
{{ENV_VAR_2}}={{description}}
```

**Connection parameters:**
| Parameter | Default | Description |
|-----------|---------|-------------|
| {{param_1}} | {{default}} | {{description}} |
| {{param_2}} | {{default}} | {{description}} |

### {{Service 2}}

**Required environment:**
```
{{ENV_VAR_1}}={{description}}
```

## Health Checks

Before execution, verify:

| Dependency | Health Check | Timeout |
|------------|--------------|---------|
| {{service_1}} | {{how_to_check}} | {{timeout}} |
| {{service_2}} | {{how_to_check}} | {{timeout}} |

## Failure Modes

| Dependency | Failure Mode | Skill Behavior |
|------------|--------------|----------------|
| {{service_1}} | Unavailable | {{what_happens}} |
| {{service_1}} | Timeout | {{what_happens}} |
| {{service_1}} | Rate limited | {{what_happens}} |
| {{service_2}} | Unavailable | {{what_happens}} |

## Rate Limits

| Service | Limit | Handling Strategy |
|---------|-------|-------------------|
| {{service_1}} | {{requests/time}} | {{strategy}} |
| {{service_2}} | {{requests/time}} | {{strategy}} |

## Offline Mode

Can this skill operate without external dependencies?

| Mode | Available Features | Limitations |
|------|-------------------|-------------|
| Full online | All | None |
| Degraded | {{features}} | {{limitations}} |
| Offline | {{features}} | {{limitations}} |
