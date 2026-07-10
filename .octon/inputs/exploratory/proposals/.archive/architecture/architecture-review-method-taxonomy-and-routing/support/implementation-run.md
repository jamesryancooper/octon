# Implementation Run — Architecture Review Method Taxonomy And Routing

proposal_id: architecture-review-method-taxonomy-and-routing
route: run-packet-implementation
run_id: 20260709-arms-program-clean-delivery-04-architecture-review-method-taxonomy-and-routing
verdict: pass
implemented_at: 2026-07-10T00:18:38Z
promotion_evidence_count: 19
authority_class: non-authority support receipt; durable authority remains in promoted framework artifacts

## What Landed (atomic, additive)

All promotion targets landed together as one coherent change; there is no
intermediate live state with a half-declared method layer.

1. `naming.yml` → `architectural-review-naming-v2`. Added a `methods` block
   (`default: balanced-architecture-review-method` + six-entry catalog with
   `lens_profile_ref` bindings). All existing `mechanism`, `method`,
   `canonical_modes`, `invocation_aliases`, `command_facades`, `schema_names`,
   `validator_names`, and `legacy_aliases` preserved verbatim. No slug renamed;
   no alias retired.
2. `review-routing.yml` → `architectural-review-routing-v2`. Added a
   `method_selection` block (`default_method`, `allowed_methods_by_route`,
   `escalation_map`, `constitutional_conflict_routes_to`) and appended
   `unknown_method` and `missing_method_record` to `fail_closed_conditions`.
   The nine routes, `default_route`, and original eight conditions preserved
   verbatim.
3. `README.md` — appended the five companion method rows to the Canonical Names
   table (Balanced row relabeled "Method (default)"), added a "Methods And
   Selection" note, and added an Architecture Lens Bank reference link.
4. `balanced-architecture-review-method.md` — appended a navigation-only
   "Related" section. Required Sequence, Octon Fit Gates, and Output Contract
   text unchanged (no doctrine change).
5. `validate-architectural-review-naming.sh` — added the v2 method-layer checks
   (schema_version, `methods.default`, six canonical slugs) and NC-A
   (lens-bank binding), plus a `--methods-fixture` path override. All existing
   assertions retained.
6. `validate-architectural-review-routing.sh` — added the v2 method-selection
   checks (schema_version, `default_method`, both fail-closed conditions
   present), NC-B (unknown method not in naming catalog), and NC-C
   (missing method record over child-controlled routing-decision samples), plus
   a `--methods-fixture` path override. All existing assertions retained.
7. Fixtures under
   `.octon/framework/assurance/runtime/_ops/fixtures/architectural-review/method-taxonomy-routing/`:
   `pass/`, `fail-method-without-profile/`, `fail-unknown-method/`,
   `fail-missing-method-record/`.

## Slug Decision Confirmed Against Live Lens Bank

The six canonical method slugs in `architecture/slug-reconciliation-decision.md`
equal the live `lens-bank.yml` `suite_methods[].slug` values verbatim (set
equality, 6 == 6). Phase-0 (`architecture-lens-bank-foundation`) did not
re-issue different slugs; the dependency binds with zero edits to
`lens-bank.yml`. See `lens-bank-binding-proof.txt`.

## Validation Results

Positive controls (errors=0): naming + routing live validators; naming +
routing `--methods-fixture pass`.
Negative controls (fail closed, non-zero exit, errors=1): NC-A
(method-without-profile), NC-B (unknown-method), NC-C (missing-method-record) —
each fails for exactly one intended reason.
Dependency binding + no-regression (errors=0): phase-0 lens-reference validator;
workflows, lifecycle-gates, extension-split validators; additive-only git-diff
proof.

The full validator test harness could not run under the unattended sandbox
(`rm -rf` cleanup trap + fixed `/tmp` scratch writes require interactive
approval); each wrapped validator was run directly instead. See the evidence
README for the compatibility argument for the harness's `--root` controls.

## Evidence Paths

Child promotion evidence root:
`.octon/state/evidence/validation/proposals/architecture-review-method-taxonomy-and-routing/`
(19 artifacts; see `README.md` there for the index).

## Known Pre-Existing Out-Of-Scope Condition (not a blocker for this child)

`validate-proposal-standard.sh` reports a global generated-projection drift:
`.octon/generated/proposals/registry.yml` is stale relative to the full set of
proposal manifests in the working tree (recovery hint:
`generate-proposal-registry.sh`). This is pre-existing program residue, not
caused by this child's implementation:
- `registry.yml` was already modified in the working tree at run start and was
  never touched by this route.
- This child touched no proposal manifest; its own registry entry is present and
  correct (the post-implementation drift gate confirms
  "proposal registry contains current packet entry").
- The staleness reflects sibling program-child packets in the working tree, not
  this packet.

Refreshing the shared registry here would sweep in unrelated sibling program
state and exceed this child's declared promotion targets. Registry projection
freshness is owned by the parent program / `promote-proposal` route. Evidence:
`structural-proposal-standard-preexisting-registry-drift.txt`. The
implementation-conformance and post-implementation drift/churn gates for THIS
packet both pass (errors=0). This condition does not block this child's clean
promotion of its declared framework targets.

## Status Handling

`proposal.yml#status` remains `accepted`. The `promote-proposal` lifecycle route
owns the rewrite to `implemented`. No implemented/closeout/archive-ready claim is
made here.
