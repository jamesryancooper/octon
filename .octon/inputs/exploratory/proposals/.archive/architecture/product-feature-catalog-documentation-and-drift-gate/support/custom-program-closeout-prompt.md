prompt_id: product-feature-catalog-documentation-and-drift-gate-program-closeout-20260627T192829Z
generated_by: octon-proposal-lifecycle-generate-program-closeout-prompt
target_program: .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate
route: closeout-program
artifact_class: operational-aid
authority: non-authoritative
generated_at: 2026-06-27T19:28:29Z

# Program Closeout Prompt

## Purpose

Run the closeout route for:

`.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate`

This prompt is parent-local operational guidance only. It does not authorize
promotion, archive, staging, commit, delivery, cleanup, or Change closeout by
itself. It must not satisfy child receipts, child promotion targets, child
validation verdicts, child closeout evidence, child archive metadata, rollback
handles, or child terminal outcomes.

## Required Preconditions

Before any closeout or archive-ready claim, rerun and require:

```sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate --require-implementation-authorization
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate
```

Also verify these parent-local aggregate receipts exist and have
`verdict: pass`, `unresolved_items_count: 0`, and
`child_authority_preserved: yes`:

- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`

If either aggregate receipt is missing or failing, stop with a blocked parent
closeout receipt. Do not use parent evidence to satisfy child-owned evidence.

## Child Closeout Order

Close or defer child packets in this declared sequence:

1. `.octon/inputs/exploratory/proposals/architecture/document-current-product-feature-gaps`
2. `.octon/inputs/exploratory/proposals/architecture/feature-catalog-drift-closeout-gate`
3. `.octon/inputs/exploratory/proposals/architecture/feature-catalog-drift-validator`
4. `.octon/inputs/exploratory/proposals/architecture/closeout-integration-and-receipts`

For each implemented child packet, require child-owned closeout evidence before
the parent can claim archive readiness. Child closeout evidence must use that
child's own manifest, scope, promotion targets, validators, conformance review,
post-implementation drift/churn review, and authority notes.

The parent may summarize child outcomes only after child-local evidence exists.
Parent closeout must not create child archive metadata, satisfy child receipts,
or authorize child archival.

## Mandatory Metadata Refresh

The previous verification loop left non-blocking metadata warnings. Closeout
must refresh these metadata surfaces before `archive_authorized: yes`:

- Parent and child `navigation/artifact-catalog.md` files must cover visible
  packet files after closeout evidence is written.
- `.octon/generated/proposals/registry.yml` must include the current parent
  and child proposal states after any closeout or archive metadata changes.
- `.octon/generated/proposals/artifacts/**` proposal artifact indexes, program
  spines, and child handoff capsules must be refreshed for the parent and all
  four children after closeout evidence is written and again after any archive
  relocation.

Use canonical generators rather than manual projection edits:

```sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate --write
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/document-current-product-feature-gaps --write
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/feature-catalog-drift-closeout-gate --write
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/feature-catalog-drift-validator --write
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/closeout-integration-and-receipts --write
OCTON_PROPOSAL_REGISTRY_PROJECTION_ONLY=1 /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write
```

Then prove freshness:

```sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate --check
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/document-current-product-feature-gaps --check
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/feature-catalog-drift-closeout-gate --check
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/feature-catalog-drift-validator --check
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/closeout-integration-and-receipts --check
OCTON_PROPOSAL_REGISTRY_PROJECTION_ONLY=1 /Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
```

Generated proposal registry and artifact outputs are derived-only. They do not
replace `proposal.yml`, subtype manifests, child receipts, child validation
verdicts, or archive metadata authority.

If metadata refresh fails because of unrelated repository residue, stop with
`verdict: blocked`, record the failing command, blocker class
`metadata-refresh-blocked`, and identify the smallest owner route needed. Do
not silently ignore stale metadata.

## Required Closeout Validation

After child closeout evidence and metadata refresh, rerun:

```sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate
```

For each child, rerun:

```sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child>
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <child>
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child>
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child>
```

Also rerun the durable implementation validators:

```sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --fixture missing-catalog-entry
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --fixture stale-ref
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --fixture status-mismatch
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --fixture probably-not-product-feature
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/tests/test-feature-catalog-drift-closeout.sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-workflow.sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-workflow.sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-packet-delivery.sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-packet-terminal-closeout.sh
```

Use Bash 5 for validators that rely on modern Bash behavior. If `/bin/bash`
3.2 fails with `declare: -A: invalid option`, treat that as an interpreter
issue and rerun with `/Users/jamesryancooper/.homebrew/bin/bash`.

## Worktree And Git Boundary

Resolve PR, CI, branch, merge, cleanup, and sync behavior through the shared
Git/worktree closeout contract and the closeout workflow referenced by
`.octon/instance/ingress/manifest.yml`.

This prompt does not select a Git route by itself. The parent closeout receipt
must record the selected Git route and worktree hygiene facts. Do not stage,
commit, merge, archive, delete, or clean unrelated residue unless the active
closeout route explicitly authorizes that action.

## Required Parent Closeout Receipt

Write parent-local closeout evidence at:

`.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate/support/proposal-closeout.md`

It must include at least these top-level fields:

```text
verdict: pass|blocked|fail
closed_at: <UTC timestamp>
archive_authorized: yes|no
child_authority_preserved: yes|no
selected_git_route: <route>
worktree_hygiene_verdict: pass|blocked|fail
worktree_hygiene_blocker_class: <class-or-none>
worktree_hygiene_owned_path_count: <integer>
worktree_hygiene_in_scope_path_count: <integer>
worktree_hygiene_foreign_path_count: <integer>
worktree_hygiene_foreign_fingerprint: <fingerprint-or-none>
worktree_hygiene_evidence: <path-or-summary>
cleanup_summary: <summary>
metadata_refreshed: yes|no
artifact_catalogs_refreshed: yes|no
proposal_artifact_indexes_refreshed: yes|no
proposal_registry_refreshed: yes|no
metadata_refresh_evidence: <paths-or-command-summary>
metadata_refresh_blocker_class: <class-or-none>
next_route_condition: <condition>
```

Use `verdict: pass`, `archive_authorized: yes`, and
`child_authority_preserved: yes` only when:

- all required children have child-owned terminal closeout or explicit deferral
  evidence;
- parent aggregate conformance and drift/churn receipts still pass;
- metadata refresh and freshness checks pass;
- durable targets have no active parent or child proposal-path dependencies;
- generated outputs and proposal registries remain derived-only;
- worktree hygiene is clean for the selected route; and
- parent closeout evidence does not replace child-owned authority.

Use `verdict: blocked`, `archive_authorized: no`, and
`selected_git_route: stage-only-escalate` when closeout cannot safely complete.
Record concrete blockers, failing validators, owner route, and the
nonterminal `next_route_condition`.

## Authority Boundaries

- Parent program closeout is coordination evidence only.
- Child packets preserve their own manifests, promotion targets, validators,
  receipts, closeout evidence, archive metadata, and lifecycle outcomes.
- Product feature catalog entries remain navigation-only.
- Feature catalog drift receipts are retained evidence, not runtime
  authorization or automatic documentation mutation.
- Generated proposal registry and generated proposal artifacts remain
  derived-only and cannot satisfy authority, policy, closeout, or archive truth.
- Raw inputs, host UI state, chat/model memory, tool availability, generated
  prompts, and generated summaries remain non-authority.

## Final Route Recommendation

If the parent closeout receipt passes and archive is authorized, proceed only
to the route explicitly selected by the closeout workflow for archive or Change
closeout. If any child or metadata refresh remains blocked, route to the
smallest owning child closeout/correction or metadata-refresh remediation route.
