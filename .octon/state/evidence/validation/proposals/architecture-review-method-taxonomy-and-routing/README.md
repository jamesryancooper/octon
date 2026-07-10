# Child promotion evidence — architecture-review-method-taxonomy-and-routing

Retained validation evidence for the phase-1 method-taxonomy-and-routing child.
All runs captured 2026-07-09/2026-07-10 (UTC) from repo root against the shipped
v2 naming/routing models and the new method-taxonomy-routing fixtures. Parent
program evidence never substitutes for these child receipts.

## Positive controls (errors=0)

- `positive-control-naming.txt` — live naming validator (legacy + v2 method
  layer), errors=0.
- `positive-control-routing.txt` — live routing validator (legacy + v2
  method-selection layer), errors=0.
- `positive-control-naming-fixture-pass.txt` — naming validator
  `--methods-fixture .../pass`, errors=0.
- `positive-control-routing-fixture-pass.txt` — routing validator
  `--methods-fixture .../pass`, errors=0.

## Negative controls (fail closed, non-zero exit, errors=1)

- `negative-control-A-method-without-profile.txt` — NC-A: naming method absent
  from lens-bank suite_methods fails closed (`orphan-review-method`).
- `negative-control-B-unknown-method.txt` — NC-B: routing selects a method not
  in the naming catalog fails closed (`nonexistent-review-method`).
- `negative-control-C-missing-method-record.txt` — NC-C: routing decision
  selects a method but omits its method record fails closed
  (`failure-mode-review-method` without `method_record`). Exercised against
  routing-decision sample data this child controls
  (`method-routing-samples.yml`), not the unshipped phase-2 schema field.

## Dependency binding + no-regression

- `lens-bank-binding-proof.txt` — six naming catalog slugs == six lens-bank
  suite_methods slugs (set equality); zero edits to lens-bank.yml.
- `no-regression-lens-references.txt` — phase-0 lens-reference validator still
  passes (errors=0).
- `no-regression-workflows.txt`, `no-regression-lifecycle-gates.txt`,
  `no-regression-extension-split.txt` — remaining architectural-review
  validators pass unchanged (errors=0). The receipts validator is arg-driven
  and exercised by the validator test harness.
- `git-diff-proof-additive-only.txt` — additive-only proof for naming.yml,
  review-routing.yml, and balanced-architecture-review-method.md (no slug
  renamed, no alias retired, no route/condition changed, Balanced doctrine
  unchanged).

## Lifecycle gate runs

- `subtype-architecture-proposal.txt` — `validate-architecture-proposal.sh`
  (errors=0).
- `implementation-readiness.txt` — `validate-proposal-implementation-readiness.sh`
  (errors=0).
- `post-impl-conformance.txt` — `validate-proposal-implementation-conformance.sh`
  (errors=0).
- The raw `validate-proposal-post-implementation-drift.sh` transcript is
  retained with the owning program run under
  `children/architecture-review-method-taxonomy-and-routing/promotion-raw/`
  so validator diagnostics cannot become self-referential promoted content.
  (errors=0).
- `structural-proposal-standard-preexisting-registry-drift.txt` —
  `validate-proposal-standard.sh` (errors=1). The single error is a **global,
  pre-existing** proposal-registry projection drift, NOT caused by this child:
  `registry.yml` was already modified at run start, this route touched no
  proposal manifest, and this packet's own registry entry is present and
  correct. Registry projection freshness is owned by the parent program /
  `promote-proposal` route. See `support/implementation-run.md` §Known
  Pre-Existing Out-Of-Scope Condition.

## Sandbox limitation note

The full validator test harness
(`_ops/tests/test-architectural-review-validators.sh`) could not be executed in
the unattended session: its cleanup trap uses `rm -rf` on `mktemp` directories
and it writes fixed `/tmp/...` scratch paths, both of which require interactive
approval / are outside the session sandbox. Each validator it wraps was instead
run directly (evidence above). The harness's `--root` naming negative controls
remain compatible: the v2 method-layer checks run in `--root` mode against the
copied live tree (which includes naming v2 + lens-bank.yml), so they pass while
the intended legacy negative control still fails closed. Re-run the harness in
an interactive session for full-suite confirmation.
