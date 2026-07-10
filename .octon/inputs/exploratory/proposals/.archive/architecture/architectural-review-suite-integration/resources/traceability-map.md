# Traceability Map

Each source obligation (child charter, disposition rows, and per-child
validation floor) maps to a packet artifact, an implementation action, a
validation command, and a closure condition. `AC-*` refer to
`architecture/acceptance-criteria.md`; `G-*` to
`architecture/current-state-gap-map.md`.

| ID | Source obligation | Gap | Packet artifact | Implementation action | Validation | Closure condition |
| --- | --- | --- | --- | --- | --- | --- |
| T-01 | Record selected method id in review run evidence; no new steps/gates/roots | G-01 | `target-architecture.md`, `file-change-map.md` (scope 1), AC-01 | Review stage of each of the four occasion `workflow.yml`/stages emits routing-decision-v2/report-v2 with `method`+`lenses_applied` into existing run-evidence root | `validate-architectural-review-workflows.sh` (extended); `validate-architectural-review-routing.sh` | All four occasions record method id; no new root/gate/step |
| T-02 | Support receipt unchanged / method-free | (not a gap) | AC-02, `validation-plan.md` NC-02 | Do not touch receipt schema; leave receipt stage as-is | `validate-architectural-review-receipts.sh` drift guard | No support receipt carries `method`/`lenses_applied` |
| T-03 | Balanced default; unknown/missing method fail-closed | G-01 | AC-03, `target-architecture.md` negative controls | Consume routing v2 `method_selection`; add nothing | `validate-architectural-review-routing.sh`; workflows validator NC-01/NC-03 | Default + fail-closed behavior re-confirmed, not modified |
| T-04 | Extend product feature note (navigation-only) | G-02 | AC-04, `file-change-map.md` (scope 2) | Add method-layer section to `product/features/architectural-review-mechanism.md` | `validate-product-feature-catalog.sh`; `validate-feature-catalog-drift-closeout.sh` | Feature note describes method layer; no authority language |
| T-05 | Lifecycle advisory text so prompts can recommend a method (gates unchanged) | G-04 | AC-05, `implementation-plan.md` open item | Author advisory in feature note, mechanism entry, workflow configure stages (in-scope); prompts consult by reference; prompt-source edit → parent registry revision | Manual review vs. non-authority boundary; workflows validator | Advisory present in-scope; no prompt-source edit; gates unchanged |
| T-06 | Extend governed cross-surface mechanism entry (navigation-only) | G-03 | AC-04, `file-change-map.md` (scope 3) | Extend `mechanisms/architectural-review-mechanism.md` + `index.yml` with v2 schemas, lens bank, method catalog, lens-references validator | Governed-mechanism integration validators; manual coherence review | Mechanism entry + index coherent with landed suite |
| T-07 | Workflows validator asserts method recording | G-05 | AC-06, `validation-plan.md` NC-01 | Extend `validate-architectural-review-workflows.sh` + fixtures; keep prior checks | `test-architectural-review-validators.sh`; `validate-architectural-review-workflows.sh` | Validator asserts recording; NC-01 fires; prior checks intact |
| T-08 | Enumerate + refresh affected generated projections via canonical publishers | G-06 | AC-07, `file-change-map.md` (derived-only) | Run `generate-proposal-registry.sh`, `generate-proposal-artifact-index.sh`, route-bundle/effective-routing publisher; retain refresh evidence | Publisher `--check` modes clean; `validate-product-feature-catalog.sh` | Projections fresh; no direct `.octon/generated/**` edit; evidence retained |
| T-09 | Run full architectural-review validator suite + proposal/feature-catalog validators as closing sweep | (floor) | AC-08, `validation-plan.md` | Run the full command list | All commands in `validation-plan.md` exit 0 | Two consecutive clean sweeps, no new findings |
| T-10 | Stay inside declared write scopes; touching another scope = parent registry revision | (contract §7) | AC aggregate gate, `file-change-map.md` "Out of Scope" | Keep all edits within the four write scopes + child evidence root | Diff review vs. write scopes | No out-of-scope change without a parent registry revision |
| T-11 | Retain child-owned evidence outside proposal path | (contract §2) | `implementation-plan.md` Evidence, promotion targets | Land receipts under `.octon/state/evidence/validation/proposals/architectural-review-suite-integration/` | Evidence path exists post-implementation | Child receipts retained outside the proposal path |

## Nothing Silently Dropped

Every charter clause is represented: method-id recording (T-01), no
steps/gates/roots (T-01), feature note (T-04), mechanism entry (T-06),
lifecycle advisory (T-05), projection refresh (T-08), closing validator sweep
(T-09). The single narrowing (T-05 advisory placement) is recorded with
rationale and an escalation path, not dropped.
