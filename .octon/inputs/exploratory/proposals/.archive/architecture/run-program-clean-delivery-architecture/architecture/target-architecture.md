# Target Architecture

`run-program-to-clean-delivery` is a governed wrapper/profile over the existing
proposal-program lifecycle runner and Proposal Program Delivery workflow. It
does not add a competing authority root.

The capability owns route sequencing, default continuation, preflight binding,
blocker classification, and next-route reporting. Existing owners keep their
authority:

- proposal packets own child receipts;
- proposal program routes own parent receipts;
- archive routes own archive metadata;
- closeout-change owns Change receipt, landing, and branch cleanup;
- closeout-worktree owns worktree partitioning;
- repo-hygiene-cleanup owns deletion;
- extension publication scripts own generated effective extension refresh;
- terminal proof validators own clean-state proof.

The default requested target is `cleaned`, but actual outcome remains
evidence-based and may stop at `blocked`, `implemented`, `archive-ready`,
`landed`, or `synced` when the next required owner lacks fresh passing
evidence.

## Route State Model

| State | Owning surface | Required current evidence | Blocked outcome | Next route |
| --- | --- | --- | --- | --- |
| `accepted_program_bound` | `proposal-program` lifecycle runner | accepted parent review digest, child registry, run checkpoint | `blocked:unaccepted-program` | `review-program` or packet revision |
| `delivery_profile_bound` | Proposal Program Delivery `bind-profile` | valid `proposal-program-delivery-profile-v1` profile | `blocked:invalid-delivery-profile` | revise profile or packet |
| `readiness_preflight_passed` | Proposal Program Delivery preflight | retained readiness receipt with git write, cleanliness, review freshness, child receipt compatibility, tooling, route legality, and generated freshness checks | `blocked:readiness-preflight-failed` | owning remediation route from receipt |
| `children_terminal` | child packet lifecycle routes | child-owned implementation, conformance, drift/churn, closeout, archive, and blocker receipts by path plus digest | `blocked:child-evidence-missing-or-stale` | child proposal-packet route |
| `feature_catalog_drift_clear` | Proposal Program Delivery drift stage | parent-local drift receipt plus child-owned drift receipts where applicable | `blocked:feature-catalog-drift` | owning documentation or child route |
| `archive_handoff_complete` | packet closeout and archive routes | closeout pass receipt, archive authorization, archive metadata, terminal freshness after relocation | `blocked:archive-not-authorized` | closeout-packet or archive-proposal |
| `change_closeout_complete` | closeout-change or closeout-worktree | Change receipt, landing authorization, hosted proof, rollback handles, branch cleanup authorization when claimed | `blocked:change-closeout-incomplete` | closeout-change or closeout-worktree |
| `terminal_clean_proven` | terminal proof validators | local main, origin/main, and landed ref equality; worktree hygiene; terminal current-state proof | `blocked:terminal-proof-failed` | terminal proof validation or cleanup owner |
| `delivery_receipt_emitted` | Proposal Program Delivery receipt stage | aggregate delivery receipt and evidence index validated as non-authorizing | `blocked:delivery-receipt-invalid` | Proposal Program Delivery correction |

## Affected Artifact Map

| Artifact | Current assumption | Required architecture delta | Owner | Priority | Rationale |
| --- | --- | --- | --- | --- | --- |
| `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml` | Already declares Proposal Program Delivery as aggregate-only and lists handoff owners. | Preserve aggregate-only authority; add or confirm stop-condition and generated-freshness references only if runner routing later needs explicit clean-delivery continuation fields. | proposal-program lifecycle contract owner | P0 | This is the lifecycle route inventory source, but raw additive input is publication input only. |
| `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml` | Already sequences bind, preflight, child lifecycle, closeout/archive, Change closeout, cleanup/sync proof, and receipt stages. | Keep as canonical delivery workflow; future workflow-handoff packet may tighten done gates, stop classes, and receipt fields. | Proposal Program Delivery workflow owner | P0 | Clean delivery should be a profile over this workflow, not a new workflow family. |
| `stages/02-delivery-readiness-preflight.md` | Records preflight checks before expensive continuation. | Ensure generated freshness, dirty/stale source posture, route-owned clean worktree, and include-path classification are explicit blockers. | Proposal Program Delivery workflow owner | P0 | Prevents unsafe mutation and repeated rediscovery of authority blockers. |
| `stages/04-run-or-resume-child-lifecycles.md` and `stages/05-validate-child-receipts.md` | Preserve child receipt ownership. | Keep parent summaries non-substitutive and require child evidence path plus digest. | child packet lifecycle owners | P0 | Prevents parent evidence substitution. |
| `stages/06-validate-feature-catalog-drift.md` | Validates parent and child feature-catalog drift. | Keep drift evidence non-authorizing and block delivery when child or parent drift remains unresolved. | product documentation route owner | P1 | Avoids stale product-surface claims after delivery. |
| `stages/06-route-closeout-and-archive.md` | Routes packet closeout and archive handoff. | Preserve archive-owner boundary and terminal freshness after archive mutation. | closeout-packet and archive-proposal owners | P0 | Delivery must not archive directly. |
| `stages/07-route-change-closeout.md` | Routes Change closeout and hosted mutation. | Require branch-no-pr or selected Change route evidence before landing, sync, cleanup, or branch deletion claims. | closeout-change or closeout-worktree owner | P0 | Git and hosted effects stay outside delivery authority. |
| `stages/08-validate-cleanup-sync-proof.md` | Validates cleanup, sync, terminal proof, and worktree hygiene. | Require cleanup authorization before deletion and reject `cleaned` on dirty worktree or stale terminal proof. | repo-hygiene-cleanup and terminal proof owners | P0 | Final clean state must be proof-backed. |
| `stages/09-emit-delivery-receipt.md` | Emits aggregate receipt and evidence index. | Keep aggregate receipt evidence-only; record highest evidence-backed outcome and all open blockers. | Proposal Program Delivery workflow owner | P0 | Aggregate output cannot authorize missing target-owned receipts. |
| `.octon/framework/engine/runtime/spec/proposal-program-readiness-projection-v1.md` | Defines read-only diagnostic projection and non-authority boundary. | Reuse as the readiness view; do not let projection authorize dispatch, closeout, archive, implementation, or generated publication. | runtime spec owner | P1 | Gives the wrapper one current-state lens without minting authority. |
| `.octon/framework/engine/runtime/spec/extension-publication-handle-v1.md` | Defines generated effective extension publication handle checks. | Bind raw additive source changes to `publish-extension-state.sh` and `validate-extension-publication-state.sh`; generated outputs remain derived-only. | extension publication owner | P0 | Prevents raw input source from becoming runtime authority. |

## Explicit Exclusions

- No mutation of `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`; that belongs to `run-program-clean-delivery-runner-routing`.
- No command, skill, capability registry, or product feature catalog mutation; those belong to `run-program-clean-delivery-operator-surface`.
- No validator or fixture implementation; that belongs to `run-program-clean-delivery-validators`.
- No evidence metadata schema or terminal proof writer mutation; that belongs to `run-program-clean-delivery-evidence-metadata`.
- No Change closeout, worktree closeout, repo hygiene deletion, archive relocation, branch deletion, generated publication, or `cleaned` claim from this packet.

## Additive Extension Publication Boundary

The additive lifecycle contract at
`.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
is an authored extension source asset, not runtime authority. Runtime consumers
may rely only on the published generated effective extension state:

- `.octon/generated/effective/extensions/catalog.effective.yml`
- `.octon/generated/effective/extensions/artifact-map.yml`
- `.octon/generated/effective/extensions/generation.lock.yml`
- `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party/context/lifecycles/proposal-program.contract.yml`

Future implementation that changes the additive source must use
`.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh`
and must validate with
`.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh`.
Runtime route state must then validate through runtime effective publication
checks such as `validate-runtime-effective-state.sh`,
`validate-runtime-effective-route-bundle.sh`, and
`validate-no-raw-generated-effective-runtime-reads.sh` when route-bundle
consumption is affected. Direct edits to generated effective outputs are
forbidden.

## Stop-Condition Taxonomy

| Stop id | Machine-checkable condition | Owning route or validator | Required receipt or evidence | Blocked outcome | Next route |
| --- | --- | --- | --- | --- | --- |
| `SC-001-authority-gap` | No target-owned receipt exists for a claimed transition. | route that owns the transition | receipt path plus digest, or explicit `not-applicable` receipt | `blocked:authority-gap` | owning route; otherwise packet revision |
| `SC-002-ownership-conflict` | Two routes claim the same mutation or evidence authority. | lifecycle runner and proposal review | blocker ledger entry citing conflicting owners | `blocked:ownership-conflict` | operator escalation or architecture revision |
| `SC-003-unsafe-mutation` | Git write preflight fails, source is dirty/stale without route-owned clean worktree, or include-path classification is absent. | Proposal Program Delivery preflight and closeout-change/worktree | retained preflight receipt and worktree classifier | `blocked:unsafe-mutation` | closeout-worktree or Change closeout preflight |
| `SC-004-external-approval-required` | The selected route requires human, hosted, branch, exception, or landing approval not present in retained evidence. | closeout-change or authority engine | approval, exception, landing, or branch authorization receipt | `blocked:approval-required` | closeout-change or human approval route |
| `SC-005-stale-evidence` | Stored digest, event head, review digest, or receipt freshness no longer matches current source. | proposal review gate or targeted freshness validator | freshness diagnostic with current and stored digest | `blocked:stale-evidence` | review, child route rerun, or freshness refresh |
| `SC-006-generated-freshness-drift` | Generated effective extension, capability, proposal, or runtime route output is stale or edited by hand. | owning publisher and freshness validators | publication receipt, generation lock, and validator pass | `blocked:generated-freshness-drift` | owning publisher script |
| `SC-007-local-private-evidence-leakage` | Hosted/shared closeout proof cites local/private-only evidence as authority. | evidence disclosure and terminal proof validators | disclosure-tier validation failure or terminal proof diagnostic | `blocked:publishable-evidence-gap` | evidence metadata or Change closeout route |
| `SC-008-validation-failure` | Required validator exits nonzero. | validator owner | compact validator log with command, cwd, exit code, and evidence ref | `blocked:validation-failure` | correction route or packet revision |
| `SC-009-parent-summary-substitution` | Parent summary, delivery receipt, readiness projection, or evidence index is used as child-owned evidence. | child receipt validator and delivery receipt validator | negative-control validator result | `blocked:parent-summary-substitution` | child proposal-packet route |
| `SC-010-cleaned-proof-gap` | `cleaned` is requested but terminal proof, final sync, branch cleanup, or worktree hygiene is missing or stale. | terminal proof and closeout validators | terminal current-state proof and cleanup/sync receipts | `blocked:cleaned-proof-gap` | terminal proof, repo hygiene, or Change closeout |
