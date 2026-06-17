# Decision

## Decision

GitHub workflows and PR templates should project the Change-first policy rather
than define it. Direct-main Changes need push/local validation paths that do not
require PR metadata. PR workflows remain valid only for Changes routed to
`branch-pr`.

This proposal is repo-local because every promotion target is under `.github/**`
and outside `.octon/**`.
