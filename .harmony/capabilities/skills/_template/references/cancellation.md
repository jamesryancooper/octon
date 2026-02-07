# Cancellation Reference

**Required when capability:** `cancellable`

Mid-execution stopping behavior for the {{skill_name}} skill.

## Cancellation Points

The skill can be safely cancelled at these points:

| Phase | Cancellation Point | Cleanup Required |
|-------|-------------------|------------------|
| {{phase_1}} | {{point}} | Yes/No |
| {{phase_2}} | {{point}} | Yes/No |
| {{phase_3}} | {{point}} | Yes/No |

## Cleanup Procedures

When cancelled, the skill performs:

1. **Immediate cleanup:**
   - {{cleanup_action_1}}
   - {{cleanup_action_2}}

2. **State preservation:**
   - {{what_state_is_saved}}
   - {{where_it_is_saved}}

3. **Resource release:**
   - {{resource_1}}
   - {{resource_2}}

## Partial Results

| Cancellation Point | Partial Output Available | Output Location |
|--------------------|--------------------------|-----------------|
| {{point_1}} | Yes/No | {{path}} |
| {{point_2}} | Yes/No | {{path}} |

## Resume After Cancel

Can this skill resume after cancellation?

| Scenario | Resumable | How to Resume |
|----------|-----------|---------------|
| {{scenario_1}} | Yes/No | {{instructions}} |
| {{scenario_2}} | Yes/No | {{instructions}} |

## Cancellation Signals

The skill responds to these cancellation signals:
- {{signal_1}} — {{behavior}}
- {{signal_2}} — {{behavior}}

## Timeout Behavior

| Phase | Default Timeout | On Timeout |
|-------|-----------------|------------|
| {{phase_1}} | {{duration}} | {{action}} |
| {{phase_2}} | {{duration}} | {{action}} |
