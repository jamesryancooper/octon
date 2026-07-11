prompt_id: octon-public-distribution-model-program-implementation-orchestration-20260710T234248Z
generated_at: "2026-07-10T23:42:48Z"
generated_by: octon-proposal-lifecycle-generate-program-orchestration-prompt
generator_route_id: generate-program-implementation-orchestration-prompt
generation_run_id: 20260710-public-distribution-clean-worktree-01
prompt_set_id: octon-proposal-lifecycle-generate-program-implementation-orchestration-prompt
prompt_bundle_sha256: sha256:4d5f5a3826fc3797ba11147c2556137c43dc4753b117cbf6435b593af32b35f6
target_program: .octon/inputs/exploratory/proposals/architecture/octon-public-distribution-model
artifact_class: operational-aid
authority: non-authoritative
parent_status_at_generation: accepted
execution_mode: gated-parallel
release_state: pre-1.0
change_profile: atomic
worktree_baseline_lease: explicit-dirty-start
child_authority_preserved: yes
program_implementation_orchestration_execution_authorized: gated-rerun-required

# Program Implementation Orchestration Prompt — Octon Public Distribution Model

> **Classification.** This prompt is a non-authoritative operational aid. It
> coordinates child-owned proposal lifecycles; it does not implement the
> parent, create authority, grant permission, replace a run contract, satisfy a
> child receipt, or authorize an external effect. Current repository state,
> constitutional and instance authority, `proposal.yml`,
> `architecture-proposal.yml`, `resources/child-packet-index.yml`, and each
> child packet remain controlling within their declared classes. If this prompt
> disagrees with any of those surfaces, stop and revise or regenerate it after
> the owning review gate passes.

## 1. Purpose And Scope Boundary

Orchestrate the ten required, non-deferred child lifecycles of
`octon-public-distribution-model` in the registry-declared `gated-parallel`
graph. The parent owns sequencing, dependency-gate enforcement, write-scope
coordination, aggregate evidence references, blocker disposition, and its own
run receipt. The parent implements no durable distribution surface.

Each child remains an independent proposal packet at its canonical sibling
path and owns its own:

- manifest and subtype manifest;
- implementation prompt and implementation plan;
- declared promotion targets and write scope;
- implementation and retained validation evidence;
- implementation conformance and post-implementation drift/churn verdicts;
- rollback, promotion, closeout, terminal outcome, and archive metadata.

Proposal readiness permits orchestration to begin. It is not evidence that any
child implementation has completed. At generation time, expected durable
contracts, schemas, validators, fixtures, scripts, crates, templates, locks,
and evidence roots may still be absent. Do not require those outputs to exist
before their owning child implements them unless that child explicitly claims
they already exist.

## 2. Mandatory Parent Entry Gates

Before any child implementation is dispatched, re-read the current parent and
all child packets, then rerun these gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh \
  --package .octon/inputs/exploratory/proposals/architecture/octon-public-distribution-model \
  --require-implementation-authorization
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh \
  --package .octon/inputs/exploratory/proposals/architecture/octon-public-distribution-model
```

Also preserve the structural validation floor:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh \
  --package .octon/inputs/exploratory/proposals/architecture/octon-public-distribution-model \
  --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh \
  --package .octon/inputs/exploratory/proposals/architecture/octon-public-distribution-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh \
  --package .octon/inputs/exploratory/proposals/architecture/octon-public-distribution-model
```

Stop unless the parent is still `accepted`, its review is fresh and accepted,
implementation prompt generation remains explicitly authorized, all ten
required child reviews remain fresh and accepted, each child completeness
review still passes, and every command above exits successfully. Route a
failure to the owning parent or child review/revision lifecycle; never waive it
in parent text.

## 3. Mandatory Child Lifecycle Contract

Before implementing a selected child, re-read that child's current
`proposal.yml`, exactly one subtype manifest, source-of-truth map, target
architecture, implementation plan, acceptance criteria,
`support/implementation-grade-completeness-review.md`,
`support/proposal-review.md`, and strict architecture review receipt. Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh \
  --package <child-packet-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh \
  --package <child-packet-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh \
  --package <child-packet-path> \
  --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh \
  --package <child-packet-path>
```

If `support/executable-implementation-prompt.md` is absent, generate it through
the canonical child packet route before implementation. Execute implementation,
verification, correction, promotion, and later closeout only through the
child-owned proposal-packet lifecycle. The parent must not write, repair, or
simulate a child receipt.

Every implemented child must produce child-owned passing artifacts including:

- `support/implementation-run.md` with its required implementation fields and
  child promotion-evidence references;
- `support/implementation-conformance-review.md` with `verdict: pass`;
- `support/post-implementation-drift-churn-review.md` with `verdict: pass`;
- the child-declared validator, negative-control, rollback, and retained
  evidence results.

Run the generic child post-implementation floor after the child-specific tests:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh \
  --package <child-packet-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh \
  --package <child-packet-path>
```

A registry `dependency_gate: verification` is satisfied only by fresh,
child-owned passing implementation, conformance, drift/churn, and declared
validation evidence. Parent summaries and sibling receipts never satisfy it.

## 4. Child Implementation Map

The registry is authoritative for every path, dependency, phase, rollback
posture, and write scope. The summaries below aid navigation and may not widen
the exact `promotion_targets` in each child's current `proposal.yml`.

| Child | Phase / group | Hard dependencies | Rollback posture | Child-owned target summary |
| --- | --- | --- | --- | --- |
| `public-distribution-legacy-exposure-readiness` | phase-1 / exposure-readiness | none | manual | Redacted exposure schema, deterministic history/hosted-surface validator and fixtures, tests, and credential/exposure response runbook. |
| `public-distribution-repository-role-contracts` | phase-1 / role-contracts | none | manual | Four-surface topology, root profile and ownership contracts, role validator, tests, and negative fixtures. |
| `public-distribution-portable-base-clearance` | phase-2 / portable-clearance | repository-role contracts | manual | Component manifest, clearance schema, dependency/clearance validator, tests, fixtures, and child evidence. |
| `public-distribution-downstream-core-delivery` | phase-2 / downstream-delivery | repository-role contracts | rollback-route | Core-lock schema, delivery contract and crate, neutral scaffolding, initialization changes, validator, tests, and child evidence. |
| `public-distribution-local-storage-evidence` | phase-2 / local-storage | repository-role contracts | rollback-route | Dependency-closed local-private evidence and retention contracts, shell/Rust producers and consumers, Git-posture policy, architecture docs, validators, tests, fixtures, and child evidence. |
| `public-distribution-portable-dropin-export` | phase-3 / portable-export | repository-role contracts, portable-base clearance, local-storage evidence | staged-commit | `portable_dropin` profile, exact-commit exporter, profile/export validators, tests, and child evidence. |
| `public-distribution-self-hosting-workspace-migration` | phase-3 / workspace-root-migration | repository-role contracts, local-storage evidence | forward-only | Root ignore/workflow/ownership/release configuration, local host-projection posture, and versioned pre-push guard; no `.octon/**` target. |
| `public-distribution-public-repository-controls` | phase-4 / public-controls | portable-base clearance, portable export | compensating | Public-repository templates, dry-run desired-state planner and tests, release-candidate validator/schema, and child evidence. |
| `public-distribution-self-hosting-octon-storage-migration` | phase-4 / workspace-octon-storage | repository-role contracts, local-storage evidence, root workspace migration | forward-only | Storage-migration validator/tests/fixtures, exact allowlist, one reviewed instance retention contract, index-only operational migration, and child evidence. |
| `public-distribution-pilot-release-readiness` | phase-5 / pilot-readiness | exposure readiness, portable export, downstream delivery, local storage, public controls, root migration, Octon storage migration | rollback-route | Pilot harness and fixtures, additive target tiers, release-readiness validator/tests, and child evidence. |

The current exact promotion targets must be read from each child's manifest at
dispatch time. A target added, removed, or moved after its accepted review
invalidates freshness and requires child review before implementation.

## 5. Execution Sequence And Handoff Gates

Dependencies are hard implementation gates; phases are coordination groups.
Creation or review preparation may occur early, but durable implementation may
not cross an unsatisfied dependency.

1. **Phase 1 — parallel foundations.** Run
   `public-distribution-legacy-exposure-readiness` and
   `public-distribution-repository-role-contracts` independently. Neither may
   absorb the other's evidence or targets.
2. **Phase 2 — gated parallel foundations.** After repository-role contracts
   pass verification, run in parallel when file-level leases remain disjoint:
   `public-distribution-portable-base-clearance`,
   `public-distribution-downstream-core-delivery`, and
   `public-distribution-local-storage-evidence`.
3. **Phase 3 — materialization and root migration.** After their listed gates
   pass, run `public-distribution-portable-dropin-export` and
   `public-distribution-self-hosting-workspace-migration` in parallel. The
   export owns `.octon` export behavior; the root migration owns only repo-root
   Git/workflow/host-projection posture.
4. **Phase 4 — public controls and Octon storage.** Run
   `public-distribution-public-repository-controls` after clearance and export
   verify. Run `public-distribution-self-hosting-octon-storage-migration` after
   role, local-storage, and root-migration verification. They may proceed in
   parallel only with disjoint child leases.
5. **Phase 5 — pilot readiness.** Begin
   `public-distribution-pilot-release-readiness` only after all seven registry
   dependencies pass their child-owned verification gates. Live public-checkout
   work also requires the separate external repository setup barrier in §7.

A blocked or failed child does not invalidate an independent sibling whose
dependencies remain satisfied. It does block every dependent child and a
passing parent orchestration receipt. Record the exact child, owning gate, and
next child lifecycle route; do not bypass or relabel the dependency.

## 6. Shared-Surface And Dirty-Worktree Discipline

- `.octon/octon.yml` is shared by repository-role contracts, local-storage
  evidence, and portable export. Their dependency chain serializes these
  writes: roles first, local storage after roles, export after both local
  storage and its other prerequisites.
- The assurance scripts directory is shared only at directory level; current
  child write scopes name distinct validator/test files. If live inspection
  reveals same-file overlap, stop and revise the parent registry before
  parallel execution.
- Root self-hosting migration is `repo-local` and must not mutate `.octon/**`.
  Octon storage migration is `octon-internal` and must not absorb root targets.
- `.octon/state/`, `.octon/generated/`, and `.octon/inputs/` are operational
  surfaces for the Octon storage migration, not broad durable promotion
  targets. Preserve active proposal packets and required lifecycle evidence
  through terminal closeout.
- Generated projections remain derived-only and may be refreshed only by their
  canonical generators with retained freshness/publication evidence. Never
  hand-edit them or use them as authority.
- This prompt was generated under `worktree_baseline_lease:
  explicit-dirty-start`. Before child dispatch, inventory and partition the
  live worktree. Existing foreign or ambiguous changes are not child work, may
  not be reset, stashed, deleted, committed, or claimed by the program, and
  block a child whose safe write lease cannot be isolated.

## 7. External-Effects And Human-Authority Barrier

Program orchestration may implement repo-local code, contracts, schemas,
fixtures, validators, dry-run planners, migration previews, and runbooks inside
child-declared targets. It does not authorize an API apply, Git remote change,
repository creation or rename, visibility/archive mutation, credential action,
history transfer, first public-tree push, evidence deletion, Tier 1 demotion,
or release publication.

Before any separately authorized repository setup or reuse of `owner/octon`,
require all of the following outside this prompt's authority:

1. an exact, idempotent, maintainer-approved operations plan bound to immutable
   private-workspace, legacy, and public repository IDs and expected pre-state;
2. the active workspace and every known writer repointed to the private
   workspace identity;
3. a negative stale-original-name push test that fails before object transfer;
4. explicit maintainer acceptance of residual unknown-clone risk;
5. separate apply invocation and retained operation receipts.

GitHub rename redirects are convenience behavior, never an authority or safety
boundary. The first push and final release remain distinct maintainer-only
decisions even after every readiness test passes. If the external setup barrier
is not satisfied, complete only the child work that does not depend on the live
effect and report the exact blocked acceptance criteria; do not fabricate a
passing pilot or parent verdict.

## 8. Child-Specific Validation Floor

Each child must run every validator and acceptance test declared by its packet.
The following current floor is a navigation summary, not a replacement for the
live child files:

| Child | Required proof focus |
| --- | --- |
| exposure readiness | Exact-ref history plus all enabled hosted surfaces; redacted deterministic receipts; no mutation or payload leakage; incomplete access and stale writers fail closed. |
| repository roles | Four distinct surface/Git postures; disjoint core/project ownership; strict public-profile exclusions and zero packs; negative fixtures pass. |
| portable clearance | Entrypoint-derived dependency closure; zero unknown provenance/license/sensitivity/clearance states; excluded paths and inactive exceptions fail; name-search receipt is dispositioned. |
| downstream delivery | Strict canonical core lock; verified install/local-artifact path; neutral init; complete dry-run; lock-last transaction; fault recovery and rollback; project-owned hashes unchanged on all Tier 1 targets. |
| local storage | Shell/Rust/schema/consumer closure agrees on truthful `local-private` and real external objects; Git-posture matrix complete; leak, fabricated-locator, retention, backup, and restore negative controls pass. |
| portable export | Exact tracked-object reads; byte-identical rebuilds; canonical labeled manifest; zero source mutation; denylist and unknown-profile negatives; exact public-tree/no-ancestry parity. |
| root workspace migration | Public-remote and stale-name pre-push negatives; unsafe release paths frozen; ownership valid; subtype-derived ignores; host projections preserved locally; no `.octon` mutation. |
| public controls | Dry-run desired-state plan makes zero API writes; repository-ID/name-reuse negatives; least-privilege CI; manifest parity; checksum/SBOM/attestation verification; merge cannot publish. |
| Octon storage migration | Exact subtype classification and approved allowlist; backup/restore proof; index-only no-delete migration; framework and non-excepted instance hashes unchanged; leak and re-tracking negatives pass. |
| pilot readiness | Disposable public/private/offline lifecycle matrix; Tier 1 fault recovery; visible nonblocking Tier 2 results; public candidate controls and assets verified; all six blocker groups fresh; no publication. |

Retain behavior, boundary, architecture/placement, rollback, and negative-control
evidence at each child's declared evidence root. Raw sensitive evidence stays
local-private; parent aggregation records only bounded references and digests.

## 9. Program-Level Evidence And Parent Run Receipt

Retain aggregate program coordination evidence under:

```text
.octon/state/evidence/validation/proposals/octon-public-distribution-model/
```

That evidence may record child ids, current paths, statuses, receipt references
and digests, blocker dispositions, manual-gate state, and freshness. It must not
copy raw sensitive evidence or substitute for child-owned truth. Route execution
evidence remains under the canonical workflow/skill run evidence roots.

After the ten required children have the passing child-owned implementation,
conformance, and drift/churn evidence required by the program runner, write or
refresh only the parent-local receipt:

```text
.octon/inputs/exploratory/proposals/architecture/octon-public-distribution-model/support/program-implementation-orchestration-run.md
```

It must include at least:

```yaml
schema_version: program-implementation-orchestration-run-v1
run_id: 20260710-public-distribution-clean-worktree-01
verdict: pass
implemented_at: <ISO-8601 UTC timestamp>
promotion_evidence_count: <integer count of current referenced child-owned evidence>
child_authority_preserved: yes
required_child_count: 10
terminal_child_count: <current integer>
child_receipt_summary_count: <current integer>
parent_summary_not_child_evidence: true
child_receipts_remain_child_owned: true
archive_authority_granted: no
cleanup_authority_granted: no
git_mutation_authority_granted: no
child_receipt_refs:
  - <child-id>:<receipt-id>:<repo-relative receipt path>
```

Use `verdict: pass` and `child_authority_preserved: yes` only when every
required child's current implementation run, implementation-conformance, and
post-implementation drift/churn receipts pass and remain child-owned. Include
commands run, exact gate summaries, blockers or `none`, generated outputs
refreshed or `none`, and an explicit statement that the parent receipt did not
satisfy any child receipt, promotion target, validation verdict, closeout,
terminal outcome, or archive metadata.

Parent implementation orchestration does not itself authorize parent
promotion, verification, closeout, archive, cleanup, branch deletion, landing,
publication, evidence deletion, or a `cleaned` claim. Those remain later
governed routes with their own receipts and gates.

## 10. Rollback, Failure, And Closeout Refusal

Rollback is child-scoped first. Follow the registry posture and child plan,
preserve evidence needed to explain the attempt, and never rewrite parent truth
to hide a child failure.

Refuse a passing parent run receipt when any of the following holds:

- a parent or child review/completeness digest is stale, blocked, or missing;
- a required predecessor verification gate has not passed;
- any required child implementation, conformance, drift/churn, validator, or
  promotion evidence is missing or failing;
- a child needs a target or write scope not declared by its fresh accepted
  manifest and parent registry;
- parallel work would collide on a file or absorb foreign dirty-worktree state;
- child authority, archive metadata, terminal truth, or promotion evidence
  would need to move into the parent;
- generated output would need hand editing or would be treated as authority;
- an external or irreversible effect lacks its separate maintainer approval;
- raw sensitive evidence would enter proposal resources or aggregate evidence;
- a readiness result would be represented as publication or release authority.

For a recoverable child failure, record the child-owned failure and route to
that child's correction/verification loop. For a boundary, decomposition, or
write-scope failure, stop the program and revise/re-review the parent registry.
For a human-only effect, stop at the barrier and report the exact approval and
receipt required.

Parent closeout is a later route. It remains blocked until every required child
has an allowed terminal outcome with fresh child-owned closeout and archive
evidence, all six blocker groups have truthful final dispositions, and no
manual or external action is falsely represented as complete.

## 11. Generation-Time Evidence

This prompt was generated only after compact-capsule integrity and the required
route gates passed:

- prompt manifest, all retained source-asset digests, and all four required
  governance-anchor digests matched the bound capsule;
- parent review gate with implementation authorization: `errors=0`;
- program child-readiness gate: `errors=0 warnings=0` for ten required,
  non-deferred children;
- parent proposal standard: `errors=0 warnings=1`; the sole warning was the
  expected pre-implementation absence of the parent aggregate evidence target;
- architecture proposal validation: `errors=0 warnings=0`;
- program structure validation: `errors=0 warnings=0`.

No child packet, durable implementation surface, generated projection, Git
state, external system, or parent status was mutated during prompt generation.
The parent remained `accepted`; all children remained independently owned and
accepted.

## 12. Final Reporting Contract For The Later Run

When the separate program implementation-orchestration run completes, report:

- parent status before and after;
- each child id, route outcome, current receipt paths, and dependency handoff;
- parent run-receipt path and verdict;
- validators run and their final summaries;
- `promotion_evidence_count` and how it was counted;
- child-authority preservation result;
- external/manual gates crossed or still blocked;
- generated outputs refreshed, canonical generator, and freshness evidence, or
  `none`;
- dirty-worktree partition and any foreign blockers;
- exact next governed route;
- whether any parent lifecycle mutation beyond its run receipt occurred.
