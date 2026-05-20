# Exploratory Plans

`inputs/exploratory/plans/*.md` contains advisory planning artifacts. Plans may
guide future implementation, review, or migration work, but they are not evidence, workflow state, policy, or runtime authority.

## Allowed Artifacts

Plan filenames must be date-prefixed and end with one of these planning roles:

- `*-plan.md`
- `*-implementation-plan.md`
- `*-migration-plan.md`
- `*-task-breakdown.md`
- `*-checklist.md`
- `*-assessment.md`
- `*-backlog.md`

Receipt-like material does not belong here. Use `state/evidence/**` for
completion receipts, validation receipts, migration receipts, and closeout
evidence.

## Disposition

Plans may be implemented through a separate governed Change, superseded by a
newer plan, converted into a proposal packet when design authority is missing,
or retained as non-authoritative planning history.
