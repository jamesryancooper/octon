# Executable Implementation Prompt — Architecture Review Method Taxonomy And Routing

- proposal_path: `.octon/inputs/exploratory/proposals/architecture/architecture-review-method-taxonomy-and-routing`
- proposal_id: `architecture-review-method-taxonomy-and-routing`
- proposal_kind: `architecture` (subtype `surface-refactor`)
- change_profile: `atomic`
- parent_program: `architecture-review-method-suite-program` (child `architecture-review-method-taxonomy-and-routing`, phase-1)
- generated_by: `octon-proposal-lifecycle generate-packet-implementation-prompt`
- authority_class: non-authority executable prompt. `proposal.yml` and `architecture-proposal.yml` are the packet-local authority; the durable authority is the framework artifacts once promoted. Support files (including this prompt) are never implementation proof.

You are implementing this accepted, review-authorized architecture packet directly.
Implement **only** the declared promotion targets, record evidence under the child
promotion evidence root, run the declared validation, handle blockers fail-closed,
and do not broaden the packet beyond its promotion targets. This is an **atomic**
landing: the naming v2 refactor, routing v2 refactor, README + Balanced
cross-reference edits, validator updates, and fixtures land as one coherent change
with no intermediate live state where a half-declared method layer is routable.

---

## 0. Preflight gate (fail closed before any durable edit)

Run and require zero errors before writing any framework file:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh \
  --package .octon/inputs/exploratory/proposals/architecture/architecture-review-method-taxonomy-and-routing \
  --require-implementation-authorization
```

Refuse to proceed unless the packet has a fresh accepted `support/proposal-review.md`
with `implementation_prompt_authorized: yes`, zero open blocking findings, and a fresh
strict Pre-Integration Architecture Review receipt.

Dependency precondition (verify, do not assume): the upstream phase-0 dependency
`architecture-lens-bank-foundation` has passed its verification gate and
`.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml`
`suite_methods` is stable. Confirm the six canonical method slugs in
`architecture/slug-reconciliation-decision.md` still equal the live
`lens-bank.yml` `suite_methods[].slug` values verbatim. If phase-0 re-issued
different slugs, **stop** and report a blocked gate (repository wins; this becomes a
parent-program registry/design revision, not a local reinterpretation).

The six canonical method slugs (fixed by this child) are:

1. `balanced-architecture-review-method` (default)
2. `greenfield-reference-architecture-review-method`
3. `tradeoff-review-method`
4. `failure-mode-review-method`
5. `evolution-fitness-review-method`
6. `boundary-authority-review-method`

---

## 1. Target end state

The Architectural Review Mechanism carries an explicit **method layer** in its
naming and routing models, additively, with Balanced Architecture Review as the
declared default and all existing surfaces preserved verbatim:

- `naming.yml` is at `architectural-review-naming-v2` with a `methods` block
  (`default: balanced-architecture-review-method` plus a six-entry catalog).
- `review-routing.yml` is at `architectural-review-routing-v2` with a
  `method_selection` block (`default_method`, `allowed_methods_by_route`,
  `escalation_map`, `constitutional_conflict_routes_to`) and two new
  `fail_closed_conditions`: `unknown_method` and `missing_method_record`.
- The mechanism `README.md` canonical-names table gains the six method rows plus a
  short "Methods And Selection" note and reference links.
- `balanced-architecture-review-method.md` gains navigation cross-references only —
  no doctrine change (Required Sequence, Octon Fit Gates, Output Contract unchanged).
- The naming and routing validators enforce the new rules and fail closed on the
  three negative controls (NC-A method-without-profile, NC-B unknown-method,
  NC-C missing-method-record), each with a fixture.
- Every `naming.yml` method slug appears in `lens-bank.yml` `suite_methods`; the
  phase-0 lens bank binds with **zero edits**.

Behavior preservation: Balanced remains the default, so routing behavior is unchanged
for callers that make no method selection. Method selection is routing semantics only
and grants no review output any lifecycle or closeout authority; the pre-integration
support receipt remains the sole lifecycle-gating review artifact.

---

## 2. In-scope surfaces (owned write scopes)

Durable writes are limited to these registry-declared write scopes and nothing else:

- `.octon/framework/cognition/practices/methodology/architectural-review/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- the assurance test fixture tree
  (`.octon/framework/assurance/runtime/_ops/fixtures/architectural-review/`) for fixtures

Owned file families (exact promotion targets):

| Path | Change |
| --- | --- |
| `…/methodology/architectural-review/naming.yml` | Additive: bump to `architectural-review-naming-v2`, add `methods` block; existing content verbatim |
| `…/methodology/architectural-review/review-routing.yml` | Additive: bump to `architectural-review-routing-v2`, add `method_selection`, append two `fail_closed_conditions`; existing routes/conditions verbatim |
| `.octon/framework/cognition/practices/methodology/architectural-review/README.md` | Additive: append six method rows + selection note + reference links; existing rows unchanged |
| `…/methodology/architectural-review/balanced-architecture-review-method.md` | Minimal: add navigation cross-references only; no doctrine change |
| `…/_ops/scripts/validate-architectural-review-naming.sh` | Additive: method-list checks + NC-A (method without lens profile) |
| `…/_ops/scripts/validate-architectural-review-routing.sh` | Additive: method-selection checks + NC-B (unknown method) + NC-C (missing method record) |
| `…/_ops/fixtures/architectural-review/method-taxonomy-routing/` (new) | `pass/`, `fail-unknown-method/`, `fail-method-without-profile/`, `fail-missing-method-record/` fixtures |
| `.octon/state/evidence/validation/proposals/architecture-review-method-taxonomy-and-routing/` | Child promotion evidence root (validator runs, NC runs, binding + no-regression proofs) |

---

## 3. Out-of-scope surfaces (do not touch)

- `lens-bank.yml` and `architecture-lens-bank.md` — phase-0 verified dependency;
  bind to `suite_methods` slugs but do not modify.
- Existing `canonical_modes`, `invocation_aliases`, `command_facades`,
  `legacy_aliases`, `schema_names`, `validator_names` in `naming.yml` — preserve
  verbatim (no slug renames, no alias retirements). The existing top-level `method`
  (Balanced) block is retained and cross-listed as the default in `methods`.
- Existing `routes`, `default_route`, and the original eight `fail_closed_conditions`
  in `review-routing.yml` — preserve verbatim.
- Balanced Required Sequence / Octon Fit Gates / Output Contract text.
- `…/constitution/contracts/assurance/architectural-review-*.schema.json` — the
  report/routing-decision v2 `method` field is **phase-2**
  (`architectural-review-schema-extensions`).
- Review workflow contracts under `orchestration/runtime/workflows/audit/**` — method-id
  recording in run evidence is **phase-3**.
- Architecture-readiness / surface-architecture / domain-architecture audit doctrine —
  referenced by route id only, never modified.
- The Greenfield and companion method docs — **phase-2**.

Do not create any new mechanism, lifecycle gate, routed workflow mode, evidence root,
or command facade. Do not grant any review output authority. This packet declares **no
governed mechanism integration gates**, so no governed-mechanism evaluation receipt is
required.

---

## 4. Ordered workstreams (atomic — all land together)

1. **Confirm slug decision against the live lens bank.** Re-read `lens-bank.yml`
   `suite_methods`; confirm the six canonical slugs still match
   `architecture/slug-reconciliation-decision.md`. Repository wins on any divergence
   (see §0).

2. **Refactor `naming.yml` → v2.** Bump `schema_version` to
   `architectural-review-naming-v2` and add the `methods` block per
   `resources/naming-routing-authoring-spec.md` Artifact 1:
   `methods.default: "balanced-architecture-review-method"` and a `catalog` of the
   six entries, each with a `slug` and a `lens_profile_ref` pointing at
   `lens-bank.yml#method_profiles.<slug>`. Preserve every existing key verbatim.
   Rename no slug; retire no alias.

3. **Refactor `review-routing.yml` → v2.** Bump `schema_version` to
   `architectural-review-routing-v2`; add the `method_selection` block
   (`default_method: "balanced-architecture-review-method"`,
   `allowed_methods_by_route` covering the existing review/audit routes with Balanced
   in every list, `escalation_map` from Balanced to Tradeoff / Failure-Mode /
   Evolution-Fitness / Boundary-Authority / Greenfield, and
   `constitutional_conflict_routes_to: "constitutional-challenge"`); append
   `unknown_method` and `missing_method_record` to `fail_closed_conditions`. Preserve
   the existing routes, `default_route`, and the original eight conditions verbatim.
   Reference `resources/naming-routing-authoring-spec.md` Artifact 2 for exact shape.

4. **Extend the mechanism `README.md`.** Append the six method rows to the
   "Canonical Names" table and add a short "Methods And Selection" note: every review
   run selects exactly one method; Balanced is the default; methods are HOW a review is
   conducted, routes are the OCCASION; an unknown method fails closed; method selection
   creates no lifecycle gate. Add reference links to `architecture-lens-bank.md` and
   `naming.yml` `methods`. Leave existing rows unchanged.

5. **Add Balanced cross-references only.** Add a short "Related" / "See also"
   navigation block to `balanced-architecture-review-method.md` pointing to the method
   taxonomy (`naming.yml` `methods`), the lens bank (`architecture-lens-bank.md` /
   `lens-bank.yml`), and the escalation map (`review-routing.yml`). Change no doctrine
   text.

6. **Extend the naming validator** (`validate-architectural-review-naming.sh`),
   preserving the `[OK]`/`[ERROR]` + `Validation summary: errors=N` + non-zero-exit
   convention and the `--root` override already present. Add checks:
   `schema_version == architectural-review-naming-v2`;
   `methods.default == balanced-architecture-review-method`; all six catalog slugs
   present; and **NC-A** — every `methods.catalog[].slug` appears in `lens-bank.yml`
   `suite_methods[].slug` (fails closed when a declared method has no lens-bank
   profile). Retain all existing assertions (no-regression guard).

7. **Extend the routing validator** (`validate-architectural-review-routing.sh`),
   same conventions. Add a fixture-pointing override (the routing validator does not
   currently accept `--root`; add `--root` or an equivalent path override so the NC
   fixtures can be exercised without mutating the live model). Add checks:
   `schema_version == architectural-review-routing-v2`;
   `method_selection.default_method == balanced-architecture-review-method`; every
   method referenced in `allowed_methods_by_route` / `escalation_map` is a declared
   `naming.yml` `methods.catalog` slug (**NC-B** `unknown_method`); and
   `fail_closed_conditions` contains both `unknown_method` and `missing_method_record`
   (**NC-C** `missing_method_record`). Ensure the `missing_method_record` control is
   exercised against routing-decision data this child controls — it must **not** depend
   on the unshipped phase-2 schema `method` field (per the accepted review's nonblocking
   finding). Retain all existing assertions.

8. **Author fixtures** under
   `.octon/framework/assurance/runtime/_ops/fixtures/architectural-review/method-taxonomy-routing/`
   (mirror the sibling `lens-references/` fixture layout):
   - `pass/` — naming v2 + routing v2 with all six slugs, Balanced default, both new
     conditions present → both validators pass.
   - `fail-method-without-profile/` — naming declares a method slug absent from
     `lens-bank.yml` `suite_methods` → naming validator fails (NC-A).
   - `fail-unknown-method/` — routing selects a method slug not in the naming catalog
     → routing validator fails (NC-B).
   - `fail-missing-method-record/` — routing-decision sample selects a method but omits
     the required method record while `missing_method_record` is declared → routing
     validator fails (NC-C).

9. **Run validators and capture evidence** (see §5).

10. **Refresh generated projections only via canonical scripts.** If any
    generated/effective index references naming/routing, refresh it only through the
    canonical publication script — never hand-edit generated output. If nothing indexes
    these files, record "no generated surface indexes these files" in the evidence.

---

## 5. Validation commands and evidence outputs

Run from repo root. Retain every run's stdout/stderr under the child promotion
evidence root
`.octon/state/evidence/validation/proposals/architecture-review-method-taxonomy-and-routing/`.

Positive controls (must pass, errors=0):

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-routing.sh
```

Negative controls (must fail closed — non-zero exit, errors>0):

```sh
# NC-A method without lens profile (naming validator against fixture)
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh \
  --root .octon/framework/assurance/runtime/_ops/fixtures/architectural-review/method-taxonomy-routing/fail-method-without-profile
# NC-B unknown method in routing (routing validator against fixture)
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-routing.sh \
  --root .octon/framework/assurance/runtime/_ops/fixtures/architectural-review/method-taxonomy-routing/fail-unknown-method
# NC-C missing method record (routing validator against fixture)
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-routing.sh \
  --root .octon/framework/assurance/runtime/_ops/fixtures/architectural-review/method-taxonomy-routing/fail-missing-method-record
```

(Use the exact fixture-invocation form the extended validators implement; the paths
above assume the `--root`/path-override convention added in workstream 7.)

Dependency binding + no-regression:

```sh
# Lens-bank binding: every naming method slug ∈ lens-bank suite_methods (record proof)
# Phase-0 lens-reference validator still passes against the live bank:
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lens-references.sh
# Full architectural-review suite no-regression:
for v in receipts workflows lifecycle-gates extension-split; do
  bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-$v.sh
done
# git diff proofs:
git --no-pager diff -- \
  .octon/framework/cognition/practices/methodology/architectural-review/naming.yml \
  .octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml \
  .octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md
```

`git diff` proofs must show: no slug renamed and no alias retired in `naming.yml`; no
existing route / `default_route` / original condition changed in `review-routing.yml`;
and only navigation cross-references added to `balanced-architecture-review-method.md`
(no doctrine text change).

Required retained evidence (child promotion evidence root):

- Naming + routing positive-control runs (errors=0).
- All three negative-control runs (non-zero exit demonstrated).
- Lens-bank binding proof (six slugs ∈ `suite_methods`) and the passing phase-0
  lens-reference run.
- No-regression proof for the remaining architectural-review validators.
- `git diff` proofs (no slug/alias/route change; Balanced doctrine unchanged).

Parent-program evidence never substitutes for these child receipts.

---

## 6. Acceptance criteria (all must hold)

AC-1 methods list authored (naming v2, Balanced default, six-slug catalog);
AC-2 canonical slugs fixed and reconciled with the design-revision note;
AC-3 lens-bank dependency bound + NC-A fails closed;
AC-4 method-selection routing authored (routing v2, `method_selection`, two new
conditions);
AC-5 fail-closed with all three negative controls (NC-A/NC-B/NC-C) failing closed;
AC-6 docs extended without doctrine change;
AC-7 additive-only, no regression, no authority granted;
AC-8 evidence retained under the child promotion evidence root.
See `architecture/acceptance-criteria.md` for the authoritative text.

---

## 7. Post-implementation gates (executable — required after durable changes land)

After the durable changes are in the working tree and validation has been run and
retained, produce the following in order. These are mandatory; do not claim
implemented/closeout/archive-ready while any is missing, failing, unresolved, or
blocked.

1. Create/update `support/implementation-run.md` with at least:
   - `verdict` (pass only when all durable targets landed and all validation passed),
   - `implemented_at` (UTC timestamp),
   - `promotion_evidence_count` (count of retained evidence artifacts under the child
     promotion evidence root),
   and a summary of what landed, the validation results, and evidence paths.

2. Create/update `support/implementation-conformance-review.md`, then run and retain:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh \
     --package .octon/inputs/exploratory/proposals/architecture/architecture-review-method-taxonomy-and-routing
   ```

3. Create/update `support/post-implementation-drift-churn-review.md`, then run and
   retain:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh \
     --package .octon/inputs/exploratory/proposals/architecture/architecture-review-method-taxonomy-and-routing
   ```

Preserve promotion targets, declared validation, retained evidence, rollback notes,
generated outputs, downstream references, and explicit exclusions throughout.

**Status handling:** Leave `proposal.yml#status` as `accepted`. Do **not** hand-edit it
to `implemented`. The `promote-proposal` lifecycle route performs the implemented-status
rewrite once the post-implementation receipts pass. Refuse any implemented, closeout, or
archive-ready claim while either post-implementation receipt is missing, failing,
unresolved, or blocked.

---

## 8. Rollback posture

Manual (per `resources/child-packet-index.yml`), low-risk because the change is purely
additive. To roll back: revert the additive diffs on the four methodology files
(restore `naming.yml` to `architectural-review-naming-v1` without the `methods` block;
restore `review-routing.yml` to `architectural-review-routing-v1` without
`method_selection` and the two appended conditions; remove the README method rows/note/
links; remove the Balanced navigation cross-references), revert the validator extensions,
delete the method-taxonomy-routing fixtures, then re-run the full
`validate-architectural-review-*.sh` suite (including the phase-0 lens-reference
validator) to confirm the mechanism is back to its passing v1 state. Retain a rollback
receipt under the child promotion evidence root. If a phase-2 child has already bound to
the canonical slugs, coordinate rollback at the parent program (registry revision) — do
not perform a silent local revert. See `architecture/rollback-plan.md`.

---

## 9. Blocker handling (fail closed)

Resolve blockers inside this packet's target architecture, or report a **blocked gate
outcome** with evidence. Do not invent new authority, do not widen support claims, and
do not treat proposal-local support files as implementation proof. Specifically stop and
report blocked if: the review-gate preflight fails; phase-0 re-issued different
`suite_methods` slugs (parent registry/design revision required); or any negative control
cannot be made to fail closed (the fail-closed guarantee is unmet).

---

## 10. Terminal criteria

Implementation is complete for this route when: all six promotion-target files are in
their v2/extended state; the naming and routing validators pass on the shipped models;
all three negative controls fail closed against their fixtures; the lens-bank binding and
no-regression proofs are retained; AC-1..AC-8 hold; `support/implementation-run.md`,
`support/implementation-conformance-review.md`, and
`support/post-implementation-drift-churn-review.md` exist with passing conformance and
drift validators; `proposal.yml#status` remains `accepted`; and all evidence is retained
under
`.octon/state/evidence/validation/proposals/architecture-review-method-taxonomy-and-routing/`.
Next route after passing post-implementation receipts: `promote-proposal`, then packet
verification.
