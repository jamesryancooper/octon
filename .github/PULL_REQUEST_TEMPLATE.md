Policy reference: `.octon/framework/execution-roles/practices/pull-request-standards.md`
Reminder: Run `@codex review`.

## What

One or two sentences describing what this PR changes.

## Why

The problem this solves and why it matters. Include `Closes/Fixes/Resolves #...`
or `No-Issue: <reason>`.

## How

Approach summary, including non-obvious design choices and alternatives rejected.

## Profile Selection Receipt

Required for governance/migration/refactor work. Use `n/a` only when this PR is purely local and non-governance.

- Semantic version source(s):
- Release state (`pre-1.0` or `stable`):
- `change_profile` (`atomic` or `transitional`):
- Hard-gate facts (downtime, coordination, migration/backfill, rollback, blast radius, compliance):
- Tie-break status:
- `transitional_exception_note` (required when `pre-1.0` + `transitional`):

## Implementation Plan

Required for governance/migration/refactor work. Use `n/a` only when no implementation plan is needed.

- Workstreams and scope:
- Public interfaces/types/contracts affected:
- Test scenarios:
- Assumptions/defaults:

## Impact Map (code, tests, docs, contracts)

List impacted code, tests, docs, and contract surfaces.

## Compliance Receipt

- [ ] Selected exactly one execution profile before planning/implementation.
- [ ] Applied release-maturity gate from semantic version.
- [ ] Enforced pre-1.0 default (`atomic`) unless hard gates required `transitional`.
- [ ] Included `transitional_exception_note` when required.
- [ ] Included tie-break escalation when applicable.
- [ ] Updated impacted contracts/docs/tests.
- [ ] Honored charter change-control constraint (no direct principles charter edits without override evidence).

## Exceptions/Escalations

List any exceptions/escalations, owners, and target resolution dates; otherwise write `none`.

## Tradeoffs

Known compromises, remaining risks, and any follow-up tickets.

## Testing

How this was verified (automated and manual), including edge cases covered.

## Rollout

Release strategy (flags, migration sequencing, canary/gradual rollout) or `n/a`.

## Convivial Purpose Check

- [ ] Feature expands genuine user capability (not synthetic engagement).
- [ ] Attention and interruption behavior are justified and user-controllable.
- [ ] No manipulative patterns or dark-pattern mechanics are introduced.
- [ ] Data collection/extraction risk is minimal and explicitly justified.

## Risk Rubric

- Risk class: [ ] Trivial [ ] Low [ ] Medium [ ] High
- Rollback plan:
- Rollback handle:
- Flags changed (name, owner, expiry, rollout):
- Autonomy eligibility: [ ] autonomy:auto-merge [ ] autonomy:no-automerge

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
- [ ] Reviewer feedback addressed with fix, commit, push, reply; reviewer-owned threads confirmed by reviewer/maintainer or resolved under the documented solo-maintainer exception

## Screenshots / Notes

Screenshots/recordings for visual changes plus any additional reviewer context.
