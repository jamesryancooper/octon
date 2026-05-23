# Custom Closeout Prompt

closeout_prompt_id: proposal-packet-phase-loop-model-closeout-prompt-2026-05-23
proposal_path: .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
route_id: closeout-packet
status: operational-aid
generated_at: 2026-05-23T16:18:31Z

This prompt is an operational closeout aid for the implemented proposal packet.
It does not authorize archival, widen scope, replace workflow state, create
durable authority, or substitute for retained evidence.

## Closeout Target

Packet:

- `proposal_id`: `proposal-packet-phase-loop-model`
- `proposal_kind`: `architecture`
- `status`: `implemented`
- `promotion_scope`: `octon-internal`

Successful closeout may write or refresh only packet-local
`support/proposal-closeout.md`. It must not archive, move, stage, commit, push,
merge, delete, reset, or clean worktree paths. Archival is a separate
`archive-proposal` lifecycle route.

## Required Preflight

Before claiming closeout, re-ground against:

- `proposal.yml`
- `architecture-proposal.yml`
- `navigation/artifact-catalog.md`
- `navigation/source-of-truth-map.md`
- `support/implementation-grade-completeness-review.md`
- `support/proposal-review.md`
- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/follow-up-verification-prompt.md`
- retained verification evidence under
  `.octon/state/evidence/runs/skills/octon-proposal-lifecycle-run-packet-verification-and-correction-loop/proposal-packet-phase-loop-model/`

Then run closeout checks from the repository root:

```sh
yq -e . .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model/proposal.yml
yq -e . .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model/architecture-proposal.yml
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh --contract .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-route-bundle.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
git diff --check
```

Run the read-only worktree hygiene classifier before archive authorization:

```sh
.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh --target .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model --lifecycle proposal-packet --format yaml
```

## Implemented Closeout Blockers

Because the packet is implemented, closeout must refuse any `pass`,
`archive-ready`, or `archive_authorized: yes` claim if any of these are missing,
failing, unresolved, stale, or blocked:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model`
- `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model`

The closeout prompt must also refuse success when:

- generated proposal registry freshness is stale;
- generated effective projection or capability publication freshness is stale;
- lifecycle contract validation fails;
- retained verification evidence is absent or contradictory;
- worktree hygiene reports `foreign_or_ambiguous` paths;
- route-required PR, CI, review, merge, branch cleanup, or origin-sync gates are
  unfinished.

## Worktree And Route Hygiene

Before staging anything or claiming direct closeout, perform housekeeping over:

- tracked changes;
- unstaged changes;
- untracked files;
- ignored/generated candidates;
- derived effective projections;
- prompt scaffolding;
- retained evidence outputs;
- local skill logs and run residue.

Exclude incidental build outputs and temporary files from any final changeset.
Preserve required generated projections and retained evidence when validators
prove they are derived publication outputs or lifecycle evidence.

When the selected implementation route uses a branch or PR lane, bind PR, CI,
review, merge, cleanup, and sync behavior to:

- `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- the closeout workflow referenced by `.octon/instance/ingress/manifest.yml`

Do not restate or replace those GitHub/worktree policies in this packet.

When required checks are red, run remediation before closeout:

1. Inspect every failing check, job, and script.
2. Identify the failing contract.
3. Make the smallest target-architecture-correct fix.
4. Validate locally when reproducible.
5. Commit and push only if the selected route uses a branch lane.
6. Re-check until required checks pass or an explicit external blocker is
   recorded.

## Closeout Receipt Rules

Successful closeout writes `support/proposal-closeout.md` with at least:

```yaml
verdict: pass
closed_at: <UTC timestamp>
archive_authorized: yes
archive_disposition: implemented
promotion_evidence: <durable evidence outside this proposal packet>
```

Use `verdict: pass` and `archive_authorized: yes` only when the packet is ready
for the separate `archive-proposal` route.

If the worktree hygiene classifier reports foreign or ambiguous paths, write
`support/proposal-closeout.md` instead with:

```yaml
verdict: blocked
archive_authorized: no
selected_git_route: stage-only-escalate
worktree_hygiene_verdict: blocked
worktree_hygiene_blocker_class: worktree-hygiene-blocked
worktree_hygiene_owned_path_count: <count>
worktree_hygiene_in_scope_path_count: <count>
worktree_hygiene_foreign_path_count: <count>
worktree_hygiene_evidence: <classifier evidence path or command output reference>
next_route_condition: closeout-change or operator scope resolution
```

Do not stage, commit, push, delete, reset, archive, or otherwise clean worktree
paths from this route.

## Final Output

Return exactly one closeout status:

- `archive-ready`
- `blocked-worktree-hygiene`
- `blocked-validation`
- `blocked-route-required-check`
- `blocked-review-or-pr`
- `explicitly-deferred`

Ambiguous success language is not sufficient.
