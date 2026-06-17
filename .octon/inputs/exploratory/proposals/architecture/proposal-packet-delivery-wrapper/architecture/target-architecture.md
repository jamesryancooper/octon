# Target Architecture

## Problem Statement

The current packet lifecycle can run individual routes, but a single accepted
packet still requires the operator to manually sequence implementation,
promotion to implemented status, packet closeout, terminal closeout, archive,
Change closeout, branch-no-pr landing, branch cleanup, local main sync,
terminal current-state proof, and clean-worktree proof. The program lifecycle
already has a delivery wrapper that coordinates child-owned receipts without
replacing child authority. A packet-level equivalent is missing.

## Desired End State

Octon has a first-class packet delivery route:

```text
/proposal-packet-delivery target=<proposal-packet-path> outcome=cleaned route=branch-no-pr [profile=<profile-path>] [run-id=<id>]
```

The route is available only for an accepted packet with fresh proposal review
authorization and implementation authorization. It coordinates the owning
routes in order and emits a `proposal-packet-delivery-receipt-v1` aggregate
receipt.

## Workflow Stages

1. Bind delivery profile.
2. Validate accepted packet state and fresh review authorization.
3. Run or resume packet implementation through the packet implementation route.
4. Validate implementation-run, implementation conformance, and
   post-implementation drift/churn receipts.
5. Promote the accepted packet through `promote-proposal` and prove manifest
   status is `implemented`.
6. Run `closeout-packet` and require `support/proposal-closeout.md` with
   `verdict: pass` and `archive_authorized: yes`.
7. Run packet terminal closeout for `archive-ready`.
8. Archive through `archive-proposal` with disposition `implemented`.
9. Regenerate and validate proposal registry and packet artifacts.
10. Route the coherent Change through `closeout-change` or `closeout-worktree`
   with `branch-no-pr` selected and PR fallback forbidden.
11. Push the branch, run hosted no-PR preflight, validate exact SHA landing
   authorization, and land to hosted `main`.
12. Validate governed branch cleanup authorization and delete only authorized
    refs.
13. Fetch origin and sync local `main`.
14. Prove local `main == origin/main == landed_ref`.
15. Prove `git status --short` is empty.
16. Emit `proposal-packet-delivery-receipt-v1`.

## Authority Model

The delivery wrapper is an aggregate coordinator. It must not replace:

- packet implementation authority;
- promote-proposal authority;
- closeout-packet authority;
- proposal packet terminal closeout authority;
- archive-proposal authority;
- closeout-change or closeout-worktree authority;
- repo-hygiene cleanup authority;
- branch landing or cleanup helper authorization;
- generated publication scripts.

Its receipt records source refs and validation results. It cannot mint
implementation, archive, landing, cleanup, final sync, or clean-worktree truth
without fresh owning evidence.

## Terminal Claim

The wrapper may claim `cleaned` only when all of the following are true:

- packet implementation is complete and target-owned conformance plus
  drift/churn receipts pass;
- `promote-proposal` has marked the packet `implemented` with retained
  promotion evidence;
- `closeout-packet` has emitted `support/proposal-closeout.md` with
  `archive_authorized: yes`;
- terminal closeout reports archive readiness;
- archive disposition is `implemented` and proposal registry/artifacts are
  fresh;
- Change closeout landed through governed `branch-no-pr`;
- hosted landing authorization matches exact source SHA and target pre-ref;
- cleanup authorization validates and only authorized source refs are deleted;
- local `main`, `origin/main`, and `landed_ref` are equal;
- final `git status --short` is empty.

## Non-Authority Surfaces

Proposal-local files, generated prompts, generated artifacts, dashboards, host
state, chat, and model memory remain informative only. They may be cited as
source lineage or evidence pointers when permitted, but never as delivery
authority.
