# Hybrid Solo-First Landing Decision

## Decision

Adopt a hybrid solo-first landing model for Change closeout.

Octon should reserve PR-backed closeout for Changes that need hosted review,
external signoff, unresolved review discussion, protected or high-impact
governance handling, team collaboration, release automation, or explicit
operator PR publication. Validated branch-isolated work that does not need
those gates may land through `branch-no-pr` without opening a PR, but only when
provider rules allow route-neutral fast-forward updates and Octon can prove the
exact landed remote ref.

## Route Semantics

`direct-main` remains for clean, current `main` and low-risk Changes.

`branch-no-pr` becomes a hosted-capable branch route. Its hosted `landed` and
`cleaned` outcomes require a pushed branch, exact-SHA validation, fast-forward
ancestry from `origin/main`, a valid Change receipt, rollback evidence, cleanup
disposition, and provider ruleset compatibility.

`branch-pr` remains the review/publication route. PRs are not removed from
Octon; they become mandatory only when route predicates require them.

`stage-only-escalate` is selected when route selection, validation, permissions,
branch freshness, provider rules, or landing feasibility is blocked.

## Safety Position

No-PR does not mean no validation, no push, or no hosted enforcement. A
`branch-no-pr` hosted landing is valid only when `origin/main` equals the
recorded `landed_ref` after a fast-forward-only update. Local checkpoints,
branch-local commits, and pushed-only branches must never claim hosted landing.

## Small-Team Position

For a two or three person trusted team, the same route model remains valid, but
landing authority can be restricted. Shared ownership, unresolved review
discussion, unclear risk, or external signoff forces `branch-pr`; solo-owned
low- or medium-risk branch work may still use `branch-no-pr`.
