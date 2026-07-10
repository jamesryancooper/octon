# Validation Plan

This child touches methodology docs only. Per the child-packet contract
(obligation 4), a methodology-docs child must define a **doc-consistency check
against `naming.yml` and `lens-bank.yml`**; it authors no new validator (the
enforcement-surface children own validators). The floor below combines that
deterministic doc-consistency check with regression runs of the existing
architectural-review validators to prove no drift.

## Validation Floor (required to pass before acceptance/closeout)

### 1. Deterministic Doc/Registry Consistency Check

For each of the four companion slugs, assert (deterministic `yq`/`grep`, scriptable
and re-runnable):

1. **Doc exists and is named after the slug.**
   `architectural-review/<slug>.md` exists.
2. **Slug is canonical.** `<slug>` appears in `naming.yml`
   `methods.catalog[].slug` with `role: companion`.
3. **`doc:` pointer resolves.** The catalog entry's `doc:` equals `<slug>.md` and
   the file exists.
4. **Lens profile reference matches.** The doc's Lens Profile pointer equals the
   catalog entry's `lens_profile_ref`
   (`lens-bank.yml#method_profiles.<slug>`), and that profile exists in
   `lens-bank.yml`.
5. **Required/optional lens sets match verbatim.** The lens ids the doc lists as
   required (and optional) equal `lens-bank.yml` `method_profiles.<slug>.required`
   (and `.optional`) exactly — same members, no additions, no omissions.
6. **No undefined or private lenses.** Every lens id cited anywhere in the doc
   exists in `lens-bank.yml` `lenses[].id`. The doc declares no private lens
   catalog.
7. **Escalation targets are valid.** Every method slug named in the doc's
   Escalation Rules is a catalog slug in `naming.yml`, and constitutional-conflict
   routing matches `review-routing.yml`
   `method_selection.constitutional_conflict_routes_to`.
8. **Output-boundary invariant present.** The doc states output is evidence or
   proposal input only and that the pre-integration support receipt remains the
   only lifecycle-gating review artifact.
9. **Mandated boundary statements present.**
   `failure-mode-review-method.md` cites the readiness audit's mandatory
   failure-mode analysis as owner of readiness scoring;
   `boundary-authority-review-method.md` cites the surface-architecture audit as
   owner of single-unit `contract-first`/`mixed`/`markdown-first`/`human-led`
   classification and states Octon-only v1.

Pass condition: all nine assertions hold for all four docs; check output is
retained as evidence.

### 2. Regression Validators (must stay green)

Run from repo root and confirm `Validation summary: errors=0`:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh`
  — the four canonical method slugs still bind to `lens-bank.yml`
  `suite_methods`; schema_version, default, and legacy aliases unchanged. The
  additive `doc:` pointers do not perturb this validator (it does not check
  pointer existence).
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lens-references.sh`
  — lens catalog integrity and complete profiles unchanged (docs do not touch
  `lens-bank.yml`).
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-routing.sh`
  — `method_selection` and fail-closed conditions unchanged (docs do not touch
  `review-routing.yml`).

Negative controls are NOT this child's responsibility: it introduces no
enforcement surface. The `unknown_method` / `missing_method_record` fail-closed
controls are owned and negative-tested by
`architecture-review-method-taxonomy-and-routing` and
`architectural-review-schema-extensions`.

### 3. Proposal-Standard Validation

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/companion-architecture-review-methods --skip-registry-check`

  Registry check is skipped with recorded reason: unrelated visible proposal
  packets are present in the workspace, so proposal-registry regeneration is
  deferred to a coordinated projection refresh rather than mutated by this child
  route (consistent with the create-packet route's registry-skip guidance and the
  workspace's shared-generated-state hygiene). `--skip-registry-check` also avoids
  the base validator failing on a promotion target "not present yet" being scored
  as an error — those are warnings for an unimplemented draft and are expected.
- Architecture subtype required files are present: `architecture-proposal.yml`,
  `architecture/target-architecture.md`, `architecture/acceptance-criteria.md`,
  `architecture/implementation-plan.md`.

## Evidence Retention

- Child-owned validator and consistency-check output:
  `.octon/state/evidence/validation/proposals/companion-architecture-review-methods/`.
- Evidence is never written to `generated/**`. Parent program evidence never
  satisfies this child's verdict.

## Proof Threshold For Closeout

Two conditions, both required:

1. The doc/registry consistency check passes for all four docs, and the three
   regression validators report `errors=0`.
2. The proposal packet passes `validate-proposal-standard.sh` (registry-skip mode)
   with no errors, and the pre-integration architecture review support receipt is
   strict-passing before acceptance/implementation authorization (owned by the
   proposal lifecycle gate, not by this plan).
