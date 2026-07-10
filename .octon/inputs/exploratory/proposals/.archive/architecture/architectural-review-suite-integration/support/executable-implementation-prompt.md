# Executable Implementation Prompt — Architectural Review Suite Integration

- proposal_path: `.octon/inputs/exploratory/proposals/architecture/architectural-review-suite-integration`
- proposal_id: `architectural-review-suite-integration`
- proposal_kind: `architecture` (subtype `surface-refactor`)
- change_profile: `atomic` (additive, in-place extension of existing surfaces; no intermediate live state)
- parent_program: `architecture-review-method-suite-program` (child `architectural-review-suite-integration`, phase-3, group `integration`)
- generated_by: `octon-proposal-lifecycle generate-packet-implementation-prompt`
- authority_class: non-authority executable prompt. `proposal.yml` and `architecture-proposal.yml` are the packet-local lifecycle authority; durable authority is the promoted framework artifacts. Support files (including this prompt) are operational aids and are never implementation proof.

You are implementing this accepted, review-authorized architecture packet directly.
Implement **only** the declared promotion targets, record evidence under the child
promotion evidence root, run the declared validation, handle blockers fail-closed,
and do not broaden the packet beyond its promotion targets. This is an **atomic**
landing: the four families below (workflow method-recording, navigation, validator,
projection refresh) land as one coherent change with no intermediate live state
where a half-declared method layer is recorded, described, or asserted.

This child **integrates** the already-landed Architecture Review Method Suite (shared
lens bank, five companion method docs plus Greenfield, `naming.yml` v2,
`review-routing.yml` v2 `method_selection`, and the v2 report/routing-decision
schemas). It creates **no** new mechanism, workflow mode, lifecycle gate, evidence
root, or review-output authority.

---

## 0. Preflight gate (fail closed before any durable edit)

Run and require zero errors before writing any framework file:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh \
  --package .octon/inputs/exploratory/proposals/architecture/architectural-review-suite-integration \
  --require-implementation-authorization
```

Refuse to proceed unless the packet has a fresh accepted `support/proposal-review.md`
with `implementation_prompt_authorized: yes`, zero open blocking findings, and a fresh
strict Pre-Integration Architecture Review receipt
(`support/pre-integration-architecture-review.yml`, verdict `pass`, 0 unresolved,
0 blockers).

**Dependency precondition (verify, do not assume).** Implementation may begin only
after all three phase-2 dependencies have passed their own `verification` gate
(parent registry `dependency_gate: verification`); parent-program evidence never
satisfies this gate:

- `greenfield-reference-architecture-review-method`
- `companion-architecture-review-methods`
- `architectural-review-schema-extensions`

Confirm each is archived with disposition `implemented` (or otherwise verification-
passed with a child-owned receipt). If any dependency is not verification-passed,
**stop** and report a blocked gate.

**Re-ground the landed suite against the live repository at HEAD** (phase 1 of the
implementation plan). Confirm each assumption below; where the live tree disagrees,
**stop** and trigger a parent registry/design revision — do not implement a stale
claim or apply a local workaround (repository wins):

- `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml`
  is `architectural-review-naming-v2` with the six-method catalog and
  `balanced-architecture-review-method` as default.
- `.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml`
  is `architectural-review-routing-v2` with a `method_selection` block
  (`default_method`, `allowed_methods_by_route`, `escalation_map`) and fail-closed
  `unknown_method` / `missing_method_record` conditions.
- `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml`
  and `architecture-lens-bank.md` are present.
- `.octon/framework/constitution/contracts/assurance/architectural-review-report-v2.schema.json`
  and `…/architectural-review-routing-decision-v2.schema.json` require `method` and
  `lenses_applied`; `…/architectural-review-support-receipt-v1.schema.json` is
  method-free with `additionalProperties: false` and its drift guard intact.
- The four review-occasion workflow directories, the product feature note, the
  governed mechanism entry, `index.yml`, `validate-architectural-review-workflows.sh`,
  and `validate-architectural-review-lens-references.sh` exist as the surfaces this
  child extends.

---

## 1. Target end state

The existing Architectural Review Mechanism operates the method layer with **no new
authority**:

1. **Method-id run evidence.** Each of the four review occasions —
   `pre-integration-architecture-review`, `post-integration-architecture-review`,
   `current-state-mechanism-architecture-review`, and `architecture-readiness-audit`
   — records the selected review method id (and the lens profile actually applied)
   in run evidence through the existing `architectural-review-routing-decision-v2` or
   `architectural-review-report-v2` artifact, written inside the existing run-evidence
   root `.octon/state/evidence/runs/workflows/{run_id}/architectural-review/<mode>/`.
   No new stage, gate, evidence root, or artifact family is introduced. The support
   receipt remains `architectural-review-support-receipt-v1` and stays **method-free**.
2. **Navigation-only feature description.** `product/features/architectural-review-mechanism.md`
   describes the method layer (method catalog, shared lens bank, v2
   report/routing-decision schemas, method-selection mechanics) and carries the
   per-occasion advisory. It authorizes nothing.
3. **Governed mechanism record.** `governed-cross-surface-mechanisms/mechanisms/architectural-review-mechanism.md`
   and `index.yml` reference the v2 schemas, `lens-bank.yml`, the method catalog in
   `naming.yml`, the `method_selection` semantics in `review-routing.yml`, and
   `validate-architectural-review-lens-references.sh`, and document the
   method-selection mechanics (navigation only).
4. **Per-occasion method advisory.** Balanced Architecture Review is stated as the
   default for every occasion; companion methods are recommended on the named
   escalation conditions (target does not exist yet → Greenfield; ≥2 viable designs →
   Tradeoff; failure behavior in doubt → Failure-Mode; long-lived fitness in doubt →
   Evolution/Fitness; authority placement in doubt → Boundary/Authority). The advisory
   is authored in in-scope surfaces (feature note, mechanism entry, workflow configure
   stages) that lifecycle prompts consult **by reference**. Gates are unchanged.
5. **Workflows validator asserts method recording.**
   `validate-architectural-review-workflows.sh` asserts, for each of the four
   occasions, that method-id recording is present and that the support receipt remains
   method-free, retaining every prior check, and ships a negative-control fixture that
   fails on a missing method record.
6. **Derived-only projection refresh.** The affected generated projections are
   refreshed only through their canonical publishers, with retained evidence of the
   refresh run.
7. **Green closing validator sweep.** The full architectural-review validator suite
   plus the proposal-standard, architecture-subtype, and product-feature-catalog
   validators pass.

**Behavior preservation.** Balanced remains the default, so a caller that selects no
method is unchanged. Method selection is advisory run evidence only; it grants no
review output any lifecycle, acceptance, promotion, or closeout authority. The
pre-integration support receipt (v1) remains the sole lifecycle-gating review
artifact.

---

## 2. In-scope surfaces (owned write scopes)

Durable writes are limited to these registry-declared write scopes plus the declared
child evidence root, and nothing else:

- `.octon/framework/orchestration/runtime/workflows/audit/`
- `.octon/framework/product/features/`
- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- (fixtures) `.octon/framework/assurance/runtime/_ops/fixtures/architectural-review/`
- (evidence) `.octon/state/evidence/validation/proposals/architectural-review-suite-integration/`

Owned file families (exact promotion targets; confirm live stage filenames — they are
listed below as observed at generation time):

- `.octon/framework/orchestration/runtime/workflows/audit/pre-integration-architecture-review/`
- `.octon/framework/orchestration/runtime/workflows/audit/post-integration-architecture-review/`
- `.octon/framework/orchestration/runtime/workflows/audit/current-state-mechanism-architecture-review/`
- `.octon/framework/orchestration/runtime/workflows/audit/architecture-readiness-audit/`
- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/mechanisms/architectural-review-mechanism.md`
- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/index.yml`

| Path | Change |
| --- | --- |
| `…/workflows/audit/pre-integration-architecture-review/workflow.yml` + `stages/01-configure.md`, `stages/02-balanced-review.md` | Review stage emits routing-decision-v2/report-v2 with `method` + `lenses_applied` into the existing run-evidence root; configure stage records the selected method (Balanced default) + advisory; receipt stage (`stages/03-receipt.md`) and the v1 support receipt untouched |
| `…/workflows/audit/post-integration-architecture-review/workflow.yml` + `stages/01-configure.md`, `stages/02-evidence-review.md` | Same method-id recording; `stages/03-receipt.md` unchanged |
| `…/workflows/audit/current-state-mechanism-architecture-review/workflow.yml` + `stages/01-configure.md`, `stages/02-mechanism-review.md` | Same method-id recording; `stages/03-receipt.md` unchanged |
| `…/workflows/audit/architecture-readiness-audit/workflow.yml` + `stages/*` | Record selected method id in run evidence; readiness verdict semantics unchanged |
| `.octon/framework/product/features/architectural-review-mechanism.md` | Navigation-only method-layer section + per-occasion advisory; no authority language |
| `…/governed-cross-surface-mechanisms/mechanisms/architectural-review-mechanism.md` | Reference v2 schemas, lens bank, method catalog, `method_selection`, lens-references validator; document method-selection mechanics (navigation) |
| `…/governed-cross-surface-mechanisms/index.yml` | Add v2 schema refs, `lens-bank.yml`, method-doc/method-catalog refs, and `validate-architectural-review-lens-references.sh` to the mechanism entry |
| `…/_ops/scripts/validate-architectural-review-workflows.sh` | Assert method-id recording per occasion + support-receipt method-freeness; keep all existing checks |
| `…/_ops/fixtures/architectural-review/workflow-method-recording/` (new) | Positive control + negative control (missing method record) fixtures |
| `.octon/state/evidence/validation/proposals/architectural-review-suite-integration/` | Child promotion evidence root (validator runs, NC runs, projection-refresh evidence) — created at implementation |

---

## 3. Out-of-scope surfaces (do not touch)

- `…/methodology/architectural-review/**` — `naming.yml`, `review-routing.yml`,
  `lens-bank.yml` / `architecture-lens-bank.md`, and all method docs are landed
  dependencies owned by phase-0 through phase-2 children. Consume them; do not edit.
- `…/constitution/contracts/assurance/architectural-review-*.schema.json` — owned by
  the schema-extensions child. The support receipt stays **v1** and method-free; do
  not add a `method`/`lenses_applied` field to it and do not weaken its drift guard.
- The receipt stage of each workflow (`stages/03-receipt.md`) and the pre-integration
  gate semantics — unchanged.
- Architecture-readiness and surface-architecture audit doctrine — cited and composed
  with, never modified. For the readiness workflow, record the method id in run
  evidence only; do not change readiness verdict semantics.
- `.claude/commands/**`, `.claude/skills/**` — command/skill facades are the
  conditional phase-3 sibling, out of scope here.
- Proposal-lifecycle prompt sources under `.octon/inputs/additive/extensions/**` — see
  the write-scope open item in §4a. Do not edit them here.
- `.octon/generated/**` — never a direct write scope; refreshed only by canonical
  publishers (§5b).

Do not create any new mechanism, lifecycle gate, routed workflow mode, evidence root,
artifact family, or command/skill facade, and do not grant any review output
authority. **This packet declares no governed mechanism integration gates**, so no
`support/governed-mechanism-integration-evaluation.yml` and no governed-mechanism
integration profile/receipt validators are required; the governed-mechanism entry is
extended navigation-only.

---

## 4. Ordered workstreams (atomic — all land together)

### 4a. Resolve the lifecycle-advisory-placement open item first (decision, not an edit)

The charter asks for lifecycle advisory text so lifecycle prompts can recommend a
method per review occasion. The proposal-lifecycle prompt sources
(`.octon/inputs/additive/extensions/**`) are **not** in this child's write scopes. The
recorded design decision (AC-05, `implementation-plan.md`): author the advisory in the
in-scope surfaces (feature note, mechanism entry, workflow configure stages) that
lifecycle prompts consult **by reference**; edit **no** prompt source and change **no**
gate. If implementation determines a prompt-source edit is strictly required, that is
a write-scope expansion — **stop and raise a parent registry revision**, do not expand
silently.

### 4b. Workflow method-recording family

For each of the four occasions, extend the **configure** and **review** stages plus
the `workflow.yml` `artifacts` block so the run emits the selected method id and lens
profile into the existing `architectural-review-routing-decision-v2` or
`-report-v2` artifact under the existing run-evidence root
`.octon/state/evidence/runs/workflows/{run_id}/architectural-review/<mode>/`:

- **configure** stage records the selected method (Balanced default) and states the
  per-occasion advisory.
- **review** stage emits the v2 routing-decision/report artifact carrying `method`
  (bound to the `naming.yml` catalog) and `lenses_applied` (bound to `lens-bank.yml`
  ids), fail-closed on `unknown_method` / `missing_method_record` per routing v2.
- **receipt** stage and the v1 support receipt are **unchanged** (no method field).

Add no new stage, gate, artifact family, or evidence root. Occasion stage assets
observed at generation time: `pre-integration` (`02-balanced-review.md`),
`post-integration` (`02-evidence-review.md`), `current-state-mechanism`
(`02-mechanism-review.md`), `architecture-readiness-audit` (multi-stage;
`03-primary-audit.md` … `07-report.md`). Re-confirm exact filenames on the live tree
before editing.

### 4c. Navigation family

- Extend `product/features/architectural-review-mechanism.md` with a navigation-only
  method-layer section (method catalog, lens bank, v2 schemas, method-selection
  mechanics) and the per-occasion advisory. No authority language (no new gate, mode,
  or review-output authority).
- Extend `mechanisms/architectural-review-mechanism.md` and `index.yml` to reference
  the v2 schemas, `lens-bank.yml`, the method catalog, `method_selection`, and
  `validate-architectural-review-lens-references.sh`, and document the
  method-selection mechanics as navigation.

### 4d. Validator family

Extend `validate-architectural-review-workflows.sh`, preserving its conventions
(`[OK]`/`[ERROR]` lines, `Validation summary: errors=N`, non-zero exit on failure) and
retaining **every** existing check (dir presence, `workflow-contract-v2`,
name/manifest/registry binding, legacy-route absence). Add:

- for each of the four occasions, assert the workflow records the selected method id in
  run evidence (via the v2 routing-decision/report artifact family);
- assert the support receipt remains method-free (no `method` / `lenses_applied`);
- a path/fixture override (the validator currently hard-codes `WORKFLOW_ROOT` with no
  `--root`; add a `--root`/path-override convention, mirroring the sibling routing
  validator, so the negative-control fixture can be exercised without mutating the
  live workflows).

Author fixtures under
`.octon/framework/assurance/runtime/_ops/fixtures/architectural-review/workflow-method-recording/`
(mirror the sibling `method-taxonomy-routing/` layout):

- `pass/` — a workflow occasion that records the method id → validator passes.
- `fail-missing-method-record/` — a workflow occasion that omits method-id recording →
  validator fails (**NC-01** `missing_method_record`).

### 4e. Projection refresh

Run each affected projection's canonical publisher (§5b) and retain the refresh-run
evidence. Perform the refresh at a **clean-tree publication boundary** so whole-file
regeneration does not sweep in unrelated working-tree changes (the review's
nonblocking finding on the deferred registry refresh). Never hand-edit
`.octon/generated/**`.

---

## 5. Validation commands and evidence outputs

Run from repo root. Retain every run's stdout/stderr under the child promotion
evidence root
`.octon/state/evidence/validation/proposals/architectural-review-suite-integration/`.
Parent-program evidence never substitutes for these child receipts, and packet-local
`support/**` files are never implementation proof.

### 5a. Closing validator sweep (each must exit 0 on the reviewed revision)

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-routing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-workflows.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lifecycle-gates.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-extension-split.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-skills-commands.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lens-references.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh \
  --package .octon/inputs/exploratory/proposals/architecture/architectural-review-suite-integration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh \
  --package .octon/inputs/exploratory/proposals/architecture/architectural-review-suite-integration
bash .octon/framework/assurance/runtime/_ops/tests/test-architectural-review-validators.sh
```

Negative controls (must fail closed — non-zero exit, errors>0 — using the
`--root`/path-override convention added in §4d):

```sh
# NC-01 missing method record (workflows validator against fixture)
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-workflows.sh \
  --root .octon/framework/assurance/runtime/_ops/fixtures/architectural-review/workflow-method-recording/fail-missing-method-record
```

Also demonstrate the inherited negative controls without weakening them:

- **NC-02 (receipt method drift):** a support-receipt fixture carrying `method` /
  `lenses_applied` fails `validate-architectural-review-receipts.sh`
  (`receipt_schema_drift`). Prove the guard still fires; do not relax it.
- **NC-03 (unknown method):** a recorded method id outside `naming.yml`'s catalog is
  fail-closed (`unknown_method`) per routing v2 — re-confirm via
  `validate-architectural-review-routing.sh`; do not add or relax it.
- **NC-04 (generated write attempt):** no change appears under `.octon/generated/**`
  except as canonical-publisher output (`--check`/freshness clean after refresh).
- **NC-05 (authority language):** the feature note and mechanism additions introduce
  no new gate, mode, or review-output authority (reviewed against the mechanism's
  non-authority boundary).

### 5b. Derived-only projection refresh (canonical publishers only)

Refresh each affected projection through its canonical publisher and retain the
refresh-run output as evidence; then prove freshness (publisher `--check`/freshness
mode clean). Never hand-edit generated output.

```sh
# Proposal registry projection (reflects this packet + suite children)
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh
# Proposal artifact index
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh
# Effective routing / runtime route bundle (reflects routing v2 method_selection)
bash .octon/framework/assurance/runtime/_ops/scripts/generate-runtime-effective-route-bundle.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-effective-freshness.sh
```

Confirm the exact publisher entrypoints and `--check` invocations against the live
scripts before running; if a listed projection turns out not to index these surfaces,
record "no generated surface indexes these files" in the evidence rather than forcing
a spurious refresh. The product feature catalog (`product/features/catalog.yml`) is
manual, not generated — its coherence is proven by
`validate-product-feature-catalog.sh` and `validate-feature-catalog-drift-closeout.sh`
in §5a, not by a publisher.

### 5c. Required retained evidence (child promotion evidence root)

- Full closing-sweep runs (each errors=0) from §5a.
- NC-01 negative-control run (non-zero exit demonstrated) plus NC-02..NC-05 proofs.
- Publisher refresh-run output and the post-refresh freshness/`--check` proof.
- A `git diff` proof that no support receipt gained a `method`/`lenses_applied` field,
  no out-of-scope path changed, and no direct `.octon/generated/**` edit was made.
- A per-acceptance-criterion evidence map (AC-01..AC-08) identifying, for each, the
  behavior, boundary, negative case, and retained receipt (a general "validators pass"
  statement is insufficient).

---

## 6. Acceptance criteria (all must hold)

AC-01 method-id recorded in review run evidence for all four occasions via the v2
routing-decision/report artifact, inside the existing run-evidence root, with no new
stage/gate/artifact family/root;
AC-02 support receipt unchanged and method-free, drift guard intact;
AC-03 Balanced default preserved; unknown-method / missing-method-record fail-closed,
neither added nor relaxed;
AC-04 navigation-only feature + mechanism + `index.yml` method-layer descriptions,
referencing the lens-references validator, with no new authority;
AC-05 per-occasion advisory in feature note, mechanism entry, and configure stages;
prompts consult by reference; no prompt-source edit; gates unchanged;
AC-06 workflows validator asserts method recording per occasion + receipt
method-freeness, retains all prior checks, ships NC-01 fixture;
AC-07 derived-only projection refresh via canonical publishers with retained evidence;
no direct `.octon/generated/**` write; feature-catalog drift validator passes;
AC-08 green closing validator sweep on the exact reviewed revision with all negative
controls firing.
See `architecture/acceptance-criteria.md` for the authoritative text and the aggregate
gate (two consecutive clean sweeps, no new findings, write-scope discipline held
throughout).

---

## 7. Post-implementation gates (executable — required after durable changes land)

After the durable changes are in the working tree and validation has been run and
retained, produce the following **in order**. These are mandatory; do not claim
implemented / closeout / archive-ready while any is missing, failing, unresolved, or
blocked.

1. Create/update `support/implementation-run.md` with at least:
   - `verdict` (pass only when all durable targets landed and all validation passed),
   - `implemented_at` (UTC timestamp),
   - `promotion_evidence_count` (count of retained evidence artifacts under the child
     promotion evidence root),
   and a summary of what landed per family, the validation results, and evidence paths.

2. Create/update `support/implementation-conformance-review.md`, then run and retain:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh \
     --package .octon/inputs/exploratory/proposals/architecture/architectural-review-suite-integration
   ```

3. Create/update `support/post-implementation-drift-churn-review.md`, then run and
   retain:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh \
     --package .octon/inputs/exploratory/proposals/architecture/architectural-review-suite-integration
   ```

Preserve promotion targets, declared validation, retained evidence, rollback notes,
generated outputs, downstream references, and explicit exclusions throughout.

**Status handling.** Leave `proposal.yml#status` as `accepted`. Do **not** hand-edit it
to `implemented`. The `promote-proposal` lifecycle route performs the
implemented-status rewrite once the post-implementation receipts pass. Refuse closeout and archive readiness while any required gate is missing or failing. Refuse any
implemented, closeout, or archive-ready claim while either post-implementation receipt
is missing, failing, unresolved, or blocked.

---

## 8. Rollback posture

Registry rollback posture is `manual`; the change is additive, so each family reverts
independently (see `architecture/rollback-plan.md`):

1. **Workflow method-recording family** — revert restores the prior `workflow.yml` /
   stage bytes for all four occasions; the support receipt was never changed, so the
   gating path is unaffected.
2. **Navigation family** — revert restores the prior feature note, mechanism entry, and
   `index.yml` bytes; navigation-only, so no behavior changes.
3. **Validator family** — revert restores the prior
   `validate-architectural-review-workflows.sh` and removes the new fixtures.
4. **Projection refresh** — re-run the canonical publishers after the reverts so the
   generated projections match the reverted framework state; no manual generated edits
   to undo.

After a revert, re-run the affected canonical publishers and the full
architectural-review validator suite plus the packet validators to prove the
repository returned to a coherent pre-promotion state; retain a rollback receipt under
the child evidence root. Rolling back this child does **not** roll back the landed
method docs, lens bank, naming/routing v2, or v2 schemas (separately owned). No
rollback step writes under `.octon/generated/**` by hand or edits another child's
write scope; if a revert cannot restore one coherent state, stop with a precise manual
recovery note and make no further writes.

---

## 9. Blocker handling (fail closed)

Resolve blockers inside this packet's target architecture, or report a **blocked gate
outcome** with evidence. Do not invent new authority, do not widen support claims, and
do not treat proposal-local `support/**` files as implementation proof. Specifically
stop and report blocked if:

- the review-gate preflight fails, or any phase-2 dependency is not verification-passed;
- the live suite surfaces disagree with the packet's assumptions (parent
  registry/design revision required — repository wins);
- a required change would fall outside the four declared write scopes plus the child
  evidence root (raise a parent registry revision, do not expand silently);
- the lifecycle-advisory placement is found to strictly require a prompt-source edit
  (parent registry revision, per §4a);
- any negative control (NC-01..NC-05) cannot be made to fire, or the support-receipt
  drift guard would have to be weakened to pass.

---

## 10. Terminal criteria

Implementation is complete for this route when: all four occasions record the selected
method id in v2 run evidence with the support receipt unchanged and method-free; the
feature note, mechanism entry, and `index.yml` carry the navigation-only method-layer
descriptions and per-occasion advisory with no new authority; the workflows validator
asserts method recording and receipt method-freeness and NC-01 fires against its
fixture; the affected generated projections are fresh via their canonical publishers
with retained evidence and no direct `.octon/generated/**` edit; the closing validator
sweep in §5a is green across two consecutive clean passes with all negative controls
firing and no new findings; AC-01..AC-08 hold with per-criterion evidence;
`support/implementation-run.md`, `support/implementation-conformance-review.md`, and
`support/post-implementation-drift-churn-review.md` exist with passing conformance and
drift validators; `proposal.yml#status` remains `accepted`; and all evidence is
retained under
`.octon/state/evidence/validation/proposals/architectural-review-suite-integration/`.

Next route after passing post-implementation receipts: `promote-proposal`, then packet
verification (`/octon-proposal-run-packet-verification-and-correction-loop`).
