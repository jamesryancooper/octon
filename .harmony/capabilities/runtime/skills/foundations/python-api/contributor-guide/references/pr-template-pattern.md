# Pull Request Template Pattern

Place this file at `.github/PULL_REQUEST_TEMPLATE.md`.

---

```markdown
## What

<!-- One to two sentences describing what changed. -->

## Why

<!-- Why this change is needed. Link ticket/issue. -->

Refs:

## How

<!-- Brief implementation approach and notable decisions. -->

## Tradeoffs

<!-- Risks, shortcuts, or deferred follow-ups. -->

## Testing

<!-- Commands run and key scenarios validated. -->

- [ ] `just check`

## Rollout / Rollback

<!-- Deployment or rollback notes, if applicable. -->

## Checklist

- [ ] Requirements met; edge cases handled
- [ ] Security reviewed (authz, input validation, secrets)
- [ ] Tests added or updated
- [ ] Observability updated if needed
- [ ] Conventions followed; no drift introduced
- [ ] Non-obvious decisions documented
```
