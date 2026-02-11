Policy reference: `docs/practices/pull-request-standards.md`

## What

One or two sentences describing what this PR changes.

## Why

The problem this solves and why it matters. Include ticket/issue links.

## How

Approach summary, including non-obvious design choices and alternatives rejected.

## Tradeoffs

Known compromises, remaining risks, and any follow-up tickets.

## Testing

How this was verified (automated and manual), including edge cases covered.

## Rollout

Release strategy (flags, migration sequencing, canary/gradual rollout) or `n/a`.

## Risk Rubric

- Risk class: [ ] Trivial [ ] Low [ ] Medium [ ] High
- Rollback plan:
- Flags changed (name, owner, expiry, rollout):

## Contracts and Threat Model

- OpenAPI/JSON-Schema changes:
- Threat model update/link:

## Observability and Performance

- Traces/logs/metrics for changed flows:
- Representative traces for high risk changes:
- Performance or bundle impact:

## License and Provenance

- New dependencies and licenses:
- Generated code/templates provenance notes:

## Checklist

- [ ] Requirements met; edge cases handled
- [ ] Security reviewed (authz, input validation, secrets)
- [ ] Tests added or updated
- [ ] Observability updated (logs, metrics, traces) if needed
- [ ] No speculative abstractions or unnecessary complexity
- [ ] Conventions followed; no drift introduced
- [ ] Non-obvious decisions documented (comments, ADR)

## Screenshots / Notes

Screenshots/recordings for visual changes plus any additional reviewer context.
