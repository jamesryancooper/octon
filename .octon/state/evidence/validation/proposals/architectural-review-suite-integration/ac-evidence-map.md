# Per-Acceptance-Criterion Evidence Map — architectural-review-suite-integration

Each criterion maps to its behavior, boundary, negative case, and the retained
receipt that proves it. Paths are relative to this child promotion evidence root
unless prefixed with `.octon/`.

## AC-01 — method-id recorded in review run evidence (all four occasions)

- Behavior: each of `pre-integration`, `post-integration`,
  `current-state-mechanism`, `architecture-readiness-audit` declares a
  `*_method_selection_record` artifact writing an
  `architectural-review-routing-decision-v2` / `-report-v2` file under the
  existing run-evidence root
  `.octon/state/evidence/runs/workflows/{run_id}/architectural-review/<occasion>/`.
- Boundary: no new stage/gate/artifact family/evidence root — the record reuses
  the existing run-evidence root and the landed v2 artifact family.
- Negative case: `negative-controls/nc-01-missing-method-record.txt`
  (`missing_method_record`, errors=1).
- Receipt: `sweep-1/workflows.txt`, `sweep-2/workflows.txt` (errors=0, per-occasion
  "method-id recording artifact present in run evidence").

## AC-02 — support receipt unchanged and method-free, drift guard intact

- Behavior: the four workflows keep `architectural-review-support-receipt-v1` with
  no `method`/`lenses_applied`.
- Boundary: `diff-proof/support-receipt-method-freeness.txt` — v1 schema absent
  from changeset; no support-receipt artifact references method/lenses_applied.
- Negative case: `negative-controls/nc-02-receipt-method-drift.txt`
  (`receipt_schema_drift`, errors=1) — drift guard fires and was not relaxed.
- Receipt: `sweep-1/receipts.txt`, `sweep-2/receipts.txt` (errors=0);
  `sweep-*/workflows.txt` "support receipt artifact stays method-free" per occasion.

## AC-03 — Balanced default preserved; unknown/missing-method fail-closed

- Behavior: `balanced-architecture-review-method` is the default; a caller
  selecting no method is unchanged (recorded as Balanced).
- Boundary: fail-closed conditions `unknown_method` + `missing_method_record`
  present in `review-routing.yml` (dependency-owned), neither added nor relaxed
  by this child.
- Negative case: `negative-controls/nc-03-unknown-method-routing.txt` and
  `nc-03-unknown-method-report-v2.txt` (`unknown_method`, errors=1);
  `nc-01-missing-method-record.txt` (`missing_method_record`).
- Receipt: `sweep-*/routing.txt` (errors=0).

## AC-04 — navigation-only feature + mechanism + index method-layer descriptions

- Behavior: feature note, mechanism entry, and `index.yml` describe the method
  layer (catalog, lens bank, v2 schemas, method-selection mechanics) and
  reference `validate-architectural-review-lens-references.sh`.
- Boundary: no new authority — `negative-controls/nc-05-authority-language-review.md`.
- Negative case: NC-05 authority-language review (no new gate/mode/authority).
- Receipt: `sweep-*/product-feature-catalog.txt`,
  `sweep-*/feature-catalog-drift-closeout.txt` (errors=0).

## AC-05 — per-occasion advisory in feature note, mechanism entry, configure stages

- Behavior: Balanced default stated for every occasion with named escalation
  companions; authored in in-scope surfaces consulted by reference.
- Boundary: no proposal-lifecycle prompt source edited; gates unchanged.
- Negative case: workflows validator "configure stage records selected method
  with advisory" fails if the configure advisory is missing (see NC-01 fixture
  which keeps the advisory intact so the failure has a single cause).
- Receipt: `sweep-*/workflows.txt` "configure stage records selected method with
  advisory" per occasion (errors=0).

## AC-06 — workflows validator asserts method recording + receipt method-freeness

- Behavior: `validate-architectural-review-workflows.sh` asserts per-occasion
  method recording and support-receipt method-freeness, retaining all prior checks,
  with a `--root` fixture override and a `pass/` + `fail-missing-method-record/`
  fixture pair.
- Boundary: all prior checks retained (dir presence, `workflow-contract-v2`,
  name/manifest/registry binding, legacy-route absence).
- Negative case: `negative-controls/nc-01-missing-method-record.txt` fires against
  the fixture; `negative-controls/workflows-fixture-pass.txt` passes.
- Receipt: `sweep-*/workflows.txt` (errors=0).

## AC-07 — derived-only projection refresh via canonical publishers

- Behavior: proposal registry refreshed via `generate-proposal-registry.sh`;
  per-packet artifact index already fresh; route bundle not affected.
- Boundary: no direct `.octon/generated/**` edit — `projection-refresh/README.md`
  + `diff-proof/generated-changes.txt`.
- Negative case: NC-04 — post-refresh `--check` freshness clean; only
  publisher-owned generated files changed.
- Receipt: `projection-refresh/registry-write.txt`,
  `projection-refresh/registry-check-after.txt`,
  `.octon/state/evidence/runs/workflows/20260709-arms-program-clean-delivery-04/children/architectural-review-suite-integration/promotion-raw/artifact-index-check-before.txt`;
  `sweep-*/feature-catalog-drift-closeout.txt`.

## AC-08 — green closing validator sweep with all negative controls firing

- Behavior: full architectural-review validator suite + proposal-standard +
  architecture-subtype + product-feature-catalog validators pass across two
  consecutive clean passes.
- Boundary: negative controls NC-01..NC-05 all fire; write-scope discipline held.
- Negative case: `negative-controls/` NC-01..NC-05.
- Receipt: `sweep-1/` and `sweep-2/` (all errors=0);
  `harness-constituents/` reproduce the validator-test harness's fixture-based
  controls (see the run receipt for the environment note on the aggregate harness).
