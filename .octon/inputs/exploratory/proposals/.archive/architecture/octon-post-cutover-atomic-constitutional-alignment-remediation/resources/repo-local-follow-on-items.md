# Repo-Local Follow-On Items

These items were surfaced while reconciling the supplied evaluation against current HEAD, but they are **not promotion targets of this active packet** because the packet is `octon-internal` and the proposal standard forbids mixing `.octon/**` and non-`.octon/**` promotion targets in one active proposal.

## Follow-on item 1 — root `README.md`

### Current issue

The current root README renders local absolute filesystem links such as:

- `/Users/jamesryancooper/Projects/octon/.octon`

That is not portable repository-relative documentation.

### Recommended follow-on

Create a separate `repo-local` proposal or direct repo-local doc patch that rewrites those links to repository-relative paths.

## Follow-on item 2 — root `CODEOWNERS`

### Current issue

`/CODEOWNERS` still uses placeholder usernames such as:

- `@you`
- `@teammate`

### Recommended follow-on

Create a separate `repo-local` proposal or direct repo-local patch that aligns CODEOWNERS to real GitHub identities or a durable organization-backed pattern.

## Why these are not in this packet

The proposal standard requires an active proposal to choose exactly one promotion scope:

- `octon-internal`
- `repo-local`

This packet needs `octon-internal` because the core corrective work lives under `/.octon/**`. The repo-local follow-ons should therefore be tracked explicitly but separately.
