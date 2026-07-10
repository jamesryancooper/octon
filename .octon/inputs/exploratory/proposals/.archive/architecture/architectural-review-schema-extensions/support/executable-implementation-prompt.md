# Executable Implementation Prompt — Architectural Review Schema Extensions

- proposal_path: `.octon/inputs/exploratory/proposals/architecture/architectural-review-schema-extensions`
- proposal_id: `architectural-review-schema-extensions`
- proposal_kind: `architecture` (subtype `surface-refactor`)
- change_profile: `atomic`
- release_state: `pre-1.0`
- parent_program: `architecture-review-method-suite-program` (child `architectural-review-schema-extensions`, phase-2)
- generated_by: `octon-proposal-lifecycle generate-packet-implementation-prompt`
- authority_class: non-authority executable prompt. `proposal.yml` and `architecture-proposal.yml` are the packet-local authority; the durable authority is the framework artifacts once promoted. Support files (including this prompt) are never implementation proof, never widen scope, and never approve execution.

You are implementing this accepted, review-authorized architecture packet directly.
Implement **only** the declared promotion targets, record evidence under the child
promotion evidence root, run the declared validation, handle blockers fail-closed,
and do not broaden the packet beyond its promotion targets. This is an **atomic**
landing: the two v2 schemas, the contracts/assurance README extension, the
receipts-validator v2 awareness, and the positive + three negative-control fixtures
land as one coherent change. There is no intermediate live state where a v2 schema
exists without validator coverage or where a v1 producer is broken.

---

## 0. Preflight gate (fail closed before any durable edit)

Run and require zero errors before writing any framework file:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh \
  --package .octon/inputs/exploratory/proposals/architecture/architectural-review-schema-extensions \
  --require-implementation-authorization
```

Refuse to proceed unless the packet has a fresh accepted `support/proposal-review.md`
with `implementation_prompt_authorized: yes`, zero open blocking findings, and a fresh
strict Pre-Integration Architecture Review receipt
(`support/pre-integration-architecture-review.yml`, verdict `pass`).

**Dependency precondition (verify, do not assume).** This child binds to two upstream
siblings that must have passed their `verification` gates and be live at HEAD:

- **phase-1** `architecture-review-method-taxonomy-and-routing` — the v2 `method` enum
  binds to the `naming.yml` `methods` catalog slugs.
- **phase-0** `architecture-lens-bank-foundation` — `lenses_applied` ids bind to the
  `lens-bank.yml` lens ids.

Re-read the live catalogs and confirm they still match
`resources/schema-extension-authoring-spec.md` verbatim before authoring:

```sh
yq -r '.methods.catalog[].slug' \
  .octon/framework/cognition/practices/methodology/architectural-review/naming.yml
yq -r '.lenses[].id' \
  .octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml
```

Expected six method slugs (fixed by phase-1; the v2 `method` enum copies them verbatim):

1. `balanced-architecture-review-method` (default)
2. `greenfield-reference-architecture-review-method`
3. `tradeoff-review-method`
4. `failure-mode-review-method`
5. `evolution-fitness-review-method`
6. `boundary-authority-review-method`

Expected 18 lens ids (12 core + 6 extended): `system-job-framing`, `domain-model`,
`current-reality-map`, `steelman-chestertons-fence`, `complexity-separation`,
`clean-sheet-reference`, `quality-attribute-scenarios`, `tradeoff-adr`,
`failure-and-recovery`, `authority-boundary`, `validation-strategy`,
`non-goals-deletion`, `security-threat-model`, `data-truth-lineage`,
`contracts-compatibility`, `operability-observability-evidence`, `evolution-fitness`,
`sequencing-mvp-migration`.

If phase-0/phase-1 re-issued different slugs or lens ids, **stop** and report a blocked
gate. The repository wins; a divergence becomes a parent-program registry/design
revision, not a local reinterpretation.

---

## 1. Target end state

The Architectural Review Mechanism's contract surface under
`.octon/framework/constitution/contracts/assurance/` carries a **method-aware layer**,
additively, with the v1 schemas retained and the support receipt untouched:

- `architectural-review-report-v2.schema.json` exists as a **strict additive superset**
  of `architectural-review-report-v1`: every v1 required field and constraint preserved
  (including `additionalProperties: false`, the six-value `review_mode` enum, and the
  `$ref`s to `review-finding-v1.schema.json` / `review-disposition-v1.schema.json`),
  `schema_version` const `architectural-review-report-v2`, plus two new **required**
  fields — `method` (enum of the six canonical suite method slugs) and `lenses_applied`
  (array, `minItems: 1`, `uniqueItems: true`, `items` non-empty strings).
- `architectural-review-routing-decision-v2.schema.json` exists as the same strict
  additive superset of `architectural-review-routing-decision-v1` (preserving the v1
  `selected_mode` enum and all other v1 fields/constraints verbatim), `schema_version`
  const `architectural-review-routing-decision-v2`, plus the same two additive required
  fields. This completes the schema-level `method` record that phase-1's
  `missing_method_record` fail-closed condition anticipated.
- The v1 report and routing-decision schemas and
  `architectural-review-support-receipt-v1.schema.json` are **retained byte-for-byte
  unchanged**.
- The contracts/assurance `README.md` lists the two v2 schemas beside their v1
  counterparts; existing entries unchanged.
- `validate-architectural-review-receipts.sh` gains **v2 awareness** (see §4):
  a v2 report/routing-decision path (method ∈ live `naming.yml` catalog → `unknown_method`;
  every `lenses_applied` id ∈ live `lens-bank.yml` → `undefined_lens`), a v1 coexistence
  path (validates v1 artifacts without the new fields), and a support-receipt drift guard
  (`receipt_schema_drift`). Its existing support-receipt behavior is preserved exactly.
- A `pass` fixture and three negative-control fixtures (`fail-unknown-method`,
  `fail-undefined-lens`, `fail-receipt-schema-drift`) demonstrate each new fail-closed
  rule.

Behavior preservation: v1 producers remain valid and method-agnostic (Balanced is the
default method when none is recorded). The `method`/`lenses_applied` fields are
descriptive records only and grant **no** review output any lifecycle or closeout
authority; the pre-integration support receipt remains the sole lifecycle-gating review
artifact. No existing route, gate, alias, or evidence root changes.

---

## 2. In-scope surfaces (owned write scopes)

Durable writes are limited to these registry-declared write scopes and nothing else:

- `.octon/framework/constitution/contracts/assurance/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- the assurance test fixture tree
  (`.octon/framework/assurance/runtime/_ops/fixtures/architectural-review/`) for fixtures

Owned file families (exact promotion targets — match `proposal.yml` `promotion_targets`
and `architecture/file-change-map.md`):

| Path | Change |
| --- | --- |
| `…/constitution/contracts/assurance/architectural-review-report-v2.schema.json` | **New**: strict additive superset of report-v1 + required `method`/`lenses_applied` |
| `…/constitution/contracts/assurance/architectural-review-routing-decision-v2.schema.json` | **New**: strict additive superset of routing-decision-v1 + required `method`/`lenses_applied` |
| `…/constitution/contracts/assurance/README.md` | Additive: list the two v2 schemas beside their v1 counterparts; existing entries unchanged |
| `…/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh` | Additive: v2 report/routing-decision path + v1 coexistence path + support-receipt drift guard; existing support-receipt assertions retained |
| `…/assurance/runtime/_ops/fixtures/architectural-review/schema-extensions/` (new) | `pass/`, `fail-unknown-method/`, `fail-undefined-lens/`, `fail-receipt-schema-drift/` fixtures |
| `.octon/state/evidence/validation/proposals/architectural-review-schema-extensions/` | Child promotion evidence root (validator runs, NC runs, additive-superset diffs, binding + coexistence + no-regression proofs) |

(The fixture subdirectory name `schema-extensions/` mirrors the sibling
`method-taxonomy-routing/` layout; any equivalent subdir under the architectural-review
fixture tree is acceptable as long as fixtures live under the assurance fixture tree.)

---

## 3. Out-of-scope surfaces (do not touch)

- `architectural-review-report-v1.schema.json` and
  `architectural-review-routing-decision-v1.schema.json` — **retained** for coexistence;
  v2 is a superset. Do not modify or delete.
- `architectural-review-support-receipt-v1.schema.json` — the support receipt **never**
  gains `method`/`lenses_applied`; keep it byte-for-byte unchanged (this is guarded by
  NC-3).
- `…/methodology/architectural-review/naming.yml` (`methods` catalog) — phase-1 verified
  dependency; the v2 `method` enum binds to its slugs but does not modify it.
- `…/methodology/architectural-review/review-routing.yml` (`method_selection`,
  `missing_method_record`) — phase-1 verified dependency; this child completes its intent
  at the schema level but does not modify it.
- `…/methodology/architectural-review/lens-bank.yml` — phase-0 verified dependency;
  `lenses_applied` binds to its lens ids but does not modify it.
- `…/constitution/contracts/assurance/family.yml` — does not reference the
  architectural-review schemas; no registration change is needed.
- Review workflow contracts under `orchestration/runtime/workflows/audit/**` — method-id
  recording in run evidence is **phase-3** (`architectural-review-suite-integration`).
- The Greenfield and companion method docs — phase-2 siblings, out of this packet.
- Architecture-readiness / surface-architecture / domain-architecture audit doctrine —
  the v2 `review_mode`/`selected_mode` enums are inherited verbatim from v1; no route
  added or removed.

Do not create any new mechanism, lifecycle gate, routed workflow mode, evidence root, or
command facade. Do not grant any review output authority. This packet declares **no
governed mechanism integration gates**, so no `support/governed-mechanism-integration-evaluation.yml`
and no governed-mechanism evaluation/receipt validators are required.

---

## 4. Ordered workstreams (atomic — all land together)

1. **Confirm the binding surfaces against the live repo** (per §0). Re-read the six
   `naming.yml` `methods.catalog[].slug` values and the 18 `lens-bank.yml` lens ids;
   confirm `resources/schema-extension-authoring-spec.md` still matches. Repository wins
   on any divergence — stop and report blocked (§9).

2. **Author `architectural-review-report-v2.schema.json`.** Copy
   `architectural-review-report-v1.schema.json` verbatim, then change only:
   - `$id` → `…/architectural-review-report-v2.schema.json`
   - `title` → `Architectural Review Report v2`
   - `schema_version.const` → `architectural-review-report-v2`
   - add to `properties`:
     - `method`: `{ "type": "string", "enum": [ <the six slugs, in naming-catalog order> ] }`
     - `lenses_applied`: `{ "type": "array", "minItems": 1, "uniqueItems": true, "items": { "type": "string", "minLength": 1 } }`
   - add `method` and `lenses_applied` to `required`.

   Keep `additionalProperties: false`, the full six-value `review_mode` enum, the
   `$ref`s to `review-finding-v1.schema.json` / `review-disposition-v1.schema.json`, and
   every other v1 field/constraint **verbatim**. The schema constrains `lenses_applied`
   to a non-empty de-duplicated string array; the *validator* (not an 18-value enum in the
   schema) binds each id to the live lens bank, so a lens-bank change needs no schema bump.

3. **Author `architectural-review-routing-decision-v2.schema.json`.** Apply the identical
   treatment to `architectural-review-routing-decision-v1.schema.json`: v2 `$id`, `title`
   (`Architectural Review Routing Decision v2`), `schema_version.const`
   (`architectural-review-routing-decision-v2`), the same two additive required fields;
   preserve the v1 `selected_mode` enum and all other v1 fields/constraints verbatim.

4. **Leave the v1 schemas and the support receipt untouched.** Make no edit to
   `architectural-review-report-v1.schema.json`,
   `architectural-review-routing-decision-v1.schema.json`, or
   `architectural-review-support-receipt-v1.schema.json`.

5. **Extend the contracts/assurance `README.md`.** Append the two v2 schema entries to the
   architectural-review schema list beside their v1 counterparts; leave existing entries
   unchanged (additive only, no rewrite).

6. **Extend `validate-architectural-review-receipts.sh` with v2 awareness.** Branch on the
   passed artifact's `schema_version` **before** applying any artifact-specific assertions,
   preserving the `[OK]`/`[ERROR]` + `Validation summary: errors=N` + non-zero-exit
   convention:
   - **Support-receipt path (existing behavior + drift guard):** when
     `schema_version == architectural-review-support-receipt-v1`, keep **every** existing
     support-receipt assertion unchanged, and additionally fail closed
     (**NC-3 `receipt_schema_drift`**) if the receipt declares any other `schema_version`
     that claims to be a support receipt or carries a `method`/`lenses_applied` field.
   - **v2 report/routing-decision path (new):** when `schema_version` ends in `-v2`
     (`architectural-review-report-v2` / `architectural-review-routing-decision-v2`),
     assert `method` is present and ∈ the live `naming.yml` `methods.catalog` slugs
     (**NC-1 `unknown_method`**) and `lenses_applied` is a non-empty array whose every id
     is a declared `lens-bank.yml` lens id (**NC-2 `undefined_lens`**).
   - **v1 report/routing-decision path (coexistence):** when `schema_version` ends in
     `-v1` for a report/routing-decision artifact, validate it **without** requiring
     `method`/`lenses_applied`.

   **Backward-compatibility invariant (load-bearing):** the existing `--receipt <path>`
   support-receipt invocation is called by `validate-proposal-review-gate.sh` and by the
   pre-integration-architecture-review workflow. A valid v1 support receipt must continue
   to pass exactly as today; the drift guard must fire only on actual drift, never on a
   conformant v1 receipt. Retain all existing support-receipt assertions (no-regression
   guard). Choose the artifact-intake surface (generalize `--receipt`, or add an explicit
   report/routing-decision flag) so that schema_version routing is unambiguous and the
   existing call sites keep working unchanged.

7. **Author fixtures** under
   `.octon/framework/assurance/runtime/_ops/fixtures/architectural-review/schema-extensions/`
   (mirror the sibling `method-taxonomy-routing/` fixture layout):
   - `pass/` — a valid v2 report **and** a valid v2 routing-decision using a real method
     slug and real lens ids → validator passes (errors=0).
   - `fail-unknown-method/` — a v2 artifact whose `method` is not in the naming catalog →
     fails closed (**NC-1 `unknown_method`**).
   - `fail-undefined-lens/` — a v2 artifact whose `lenses_applied` contains an id not in
     the lens bank → fails closed (**NC-2 `undefined_lens`**).
   - `fail-receipt-schema-drift/` — a support receipt whose `schema_version` is not v1 or
     that carries a `method` field → fails closed (**NC-3 `receipt_schema_drift`**).

   The pass/NC-1/NC-2 fixtures cross-check against the **live** `naming.yml` and
   `lens-bank.yml` (not fixture copies), consistent with how the validator resolves the
   catalogs.

8. **Run validators and capture evidence** (see §5).

9. **Refresh generated projections only via canonical scripts.** If any generated/effective
   index references the assurance contract schemas, refresh it **only** through the
   canonical publication script — never hand-edit generated output. If nothing indexes
   these files, record "no generated surface indexes these files" in the evidence.

---

## 5. Validation commands and evidence outputs

Run from repo root. Retain every run's stdout/stderr (and the diffs below) under the
child promotion evidence root
`.octon/state/evidence/validation/proposals/architectural-review-schema-extensions/`.
Parent-program evidence never substitutes for these child receipts.

**Schema well-formedness + additive-superset proofs** (report and routing-decision):

```sh
# Well-formed JSON / JSON Schema parse of each v2 schema (use the repo's available
# JSON tooling, e.g. jq for parse; a JSON Schema validator if one is present):
jq -e . .octon/framework/constitution/contracts/assurance/architectural-review-report-v2.schema.json
jq -e . .octon/framework/constitution/contracts/assurance/architectural-review-routing-decision-v2.schema.json

# Additive-superset diff: only $id, title, schema_version const, and the two additive
# required fields (method, lenses_applied) may differ from v1.
diff .octon/framework/constitution/contracts/assurance/architectural-review-report-v1.schema.json \
     .octon/framework/constitution/contracts/assurance/architectural-review-report-v2.schema.json || true
diff .octon/framework/constitution/contracts/assurance/architectural-review-routing-decision-v1.schema.json \
     .octon/framework/constitution/contracts/assurance/architectural-review-routing-decision-v2.schema.json || true
```

The diffs must show **no** v1 field removed, renamed, or re-typed — only the four allowed
kinds of change (`$id`, `title`, `schema_version` const, and the two added required
fields).

**Receipts validator — positive control (must pass, errors=0):**

```sh
# Invoke against the pass fixture (valid v2 report + routing-decision), using the
# artifact-intake surface implemented in workstream 6.
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh \
  --receipt .octon/framework/assurance/runtime/_ops/fixtures/architectural-review/schema-extensions/pass/<v2-report-file>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh \
  --receipt .octon/framework/assurance/runtime/_ops/fixtures/architectural-review/schema-extensions/pass/<v2-routing-decision-file>
```

**Receipts validator — negative controls (must fail closed — non-zero exit, errors>0):**

```sh
# NC-1 unknown method
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh \
  --receipt .octon/framework/assurance/runtime/_ops/fixtures/architectural-review/schema-extensions/fail-unknown-method/<artifact>
# NC-2 undefined lens
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh \
  --receipt .octon/framework/assurance/runtime/_ops/fixtures/architectural-review/schema-extensions/fail-undefined-lens/<artifact>
# NC-3 receipt schema drift
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh \
  --receipt .octon/framework/assurance/runtime/_ops/fixtures/architectural-review/schema-extensions/fail-receipt-schema-drift/<artifact>
```

(Use the exact fixture-invocation form the extended validator implements; the flag/path
form above assumes the artifact-intake surface added in workstream 6.)

**Dependency binding, coexistence, and no-regression:**

```sh
# Method-enum ↔ naming-catalog binding proof (the six v2 enum values == naming catalog slugs):
yq -r '.methods.catalog[].slug' \
  .octon/framework/cognition/practices/methodology/architectural-review/naming.yml
# lenses_applied ↔ lens-bank binding proof (every pass-fixture lens id ∈ lens-bank ids):
yq -r '.lenses[].id' \
  .octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml

# v1 coexistence: a v1 report/routing-decision artifact still validates without method/lenses.
# Support-receipt-unchanged proof + README-only-extended proof:
git --no-pager diff -- \
  .octon/framework/constitution/contracts/assurance/architectural-review-support-receipt-v1.schema.json \
  .octon/framework/constitution/contracts/assurance/architectural-review-report-v1.schema.json \
  .octon/framework/constitution/contracts/assurance/architectural-review-routing-decision-v1.schema.json
git --no-pager diff -- .octon/framework/constitution/contracts/assurance/README.md

# Full architectural-review suite no-regression (phase-0 lens + phase-1 naming/routing + rest):
for v in naming routing lens-references workflows lifecycle-gates extension-split skills-commands; do
  bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-$v.sh
done
# Re-run the review gate to confirm the support-receipt path still passes end-to-end:
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh \
  --package .octon/inputs/exploratory/proposals/architecture/architectural-review-schema-extensions \
  --require-implementation-authorization
```

The `git diff` proofs must show the three v1 schema files **unchanged** (empty diff) and
the `README.md` **only extended** (the two v2 entries added, existing entries unchanged).

**Required retained evidence (child promotion evidence root):**

- v2 schema well-formedness runs + the two additive-superset diffs (report + routing-decision).
- Receipts-validator positive-control run (errors=0) and all three negative-control runs
  (non-zero exit demonstrated).
- Method-enum ↔ naming-catalog binding proof and `lenses_applied` ↔ lens-bank binding proof.
- v1 coexistence proof (a v1 artifact validates without the new fields).
- Support-receipt-unchanged `git diff` (empty) and README-only-extended `git diff`.
- No-regression proof for the full `validate-architectural-review-*.sh` suite and the
  re-run review gate.

---

## 6. Acceptance criteria (all must hold)

- **AC-1** v2 report schema authored (superset of report-v1 + required `method`/`lenses_applied`).
- **AC-2** v2 routing-decision schema authored (superset of routing-decision-v1 + the two fields).
- **AC-3** method enum bound to phase-1 naming catalog; NC-1 `unknown_method` fails closed.
- **AC-4** lenses bound to phase-0 lens bank; NC-2 `undefined_lens` fails closed.
- **AC-5** support receipt byte-for-byte unchanged and guarded; NC-3 `receipt_schema_drift`
  fails closed.
- **AC-6** validator passes on the `pass` fixture and fails (non-zero exit) on all three NCs.
- **AC-7** v1 coexistence preserved (v1 schemas retained and still validate v1 artifacts;
  posture recorded in `architecture/schema-coexistence-decision.md`).
- **AC-8** contracts/assurance README lists the two v2 schemas without rewriting existing entries.
- **AC-9** additive-only, no regression, no authority granted (no v1 field removed/renamed/
  re-typed; no new mechanism/gate/routed-mode/evidence-root/command-facade; remaining suite
  still passes).
- **AC-10** evidence retained under the child promotion evidence root.

See `architecture/acceptance-criteria.md` for the authoritative text (AC-1..AC-10).

---

## 7. Post-implementation gates (executable — required after durable changes land)

After the durable changes are in the working tree and validation has been run and
retained, produce the following in order. These are mandatory; do not claim
implemented/closeout/archive-ready while any is missing, failing, unresolved, or blocked.

1. Create/update `support/implementation-run.md` with at least:
   - `verdict` (pass only when all durable targets landed and all validation passed),
   - `implemented_at` (UTC timestamp),
   - `promotion_evidence_count` (count of retained evidence artifacts under the child
     promotion evidence root),
   and a summary of what landed, the validation results, and evidence paths.

2. Create/update `support/implementation-conformance-review.md`, then run and retain:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh \
     --package .octon/inputs/exploratory/proposals/architecture/architectural-review-schema-extensions
   ```

3. Create/update `support/post-implementation-drift-churn-review.md`, then run and retain:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh \
     --package .octon/inputs/exploratory/proposals/architecture/architectural-review-schema-extensions
   ```

Preserve promotion targets, declared validation, retained evidence, rollback notes,
generated outputs, downstream references, and explicit exclusions throughout.

**Status handling:** Leave `proposal.yml#status` as `accepted`. Do **not** hand-edit it to
`implemented`. The `promote-proposal` lifecycle route performs the implemented-status
rewrite once the post-implementation receipts pass. Refuse any implemented, closeout, or
archive-ready claim while either post-implementation receipt is missing, failing,
unresolved, or blocked.

---

## 8. Rollback posture

Manual (per `resources/child-packet-index.yml`), low-risk because the change is purely
additive. To roll back (see `architecture/rollback-plan.md`):

1. Delete `architectural-review-report-v2.schema.json` and
   `architectural-review-routing-decision-v2.schema.json`.
2. Revert the additive README entries in the contracts/assurance `README.md`.
3. Revert the receipts-validator v2 awareness (the v2 report/routing-decision path, the v1
   coexistence path, and the support-receipt drift guard / NC-1/NC-2/NC-3) and delete the
   `schema-extensions/` fixtures. The existing support-receipt assertions were never
   changed, so the validator returns to its prior behavior exactly.
4. Confirm no downstream child bound to the v2 schemas yet. Phase-3
   (`architectural-review-suite-integration`) binds only at its `verification` gate; a
   rollback before phase-3 implementation has no downstream references to repair. If phase-3
   has already emitted v2 review evidence, coordinate rollback at the parent program
   (registry revision) — do not perform a silent local revert.
5. Re-run the full `validate-architectural-review-*.sh` suite to confirm the contract
   surface is back to its prior passing state.
6. Retain a rollback receipt under the child promotion evidence root.

---

## 9. Blocker handling (fail closed)

Resolve blockers inside this packet's target architecture, or report a **blocked gate
outcome** with evidence. Do not invent new authority, do not widen support claims, and do
not treat proposal-local support files as implementation proof. Specifically stop and
report blocked if:

- the review-gate preflight (§0) fails;
- phase-0 re-issued different `lens-bank.yml` lens ids or phase-1 re-issued different
  `naming.yml` `methods` catalog slugs (parent registry/design revision required before
  this child binds);
- a v2 schema cannot be made a clean additive superset of its v1 schema (a v1 field would
  have to change or drop) without a design revision;
- any of the three negative controls cannot be made to fail closed (the fail-closed
  guarantee is unmet); or
- the support-receipt schema cannot be kept byte-for-byte unchanged, or the existing
  `--receipt` support-receipt path (depended on by the review gate) cannot be preserved.

---

## 10. Terminal criteria

Implementation is complete for this route when: both v2 schema files exist as strict
additive supersets of their v1 baselines; the v1 report/routing-decision schemas and the
support-receipt schema are byte-for-byte unchanged; the contracts/assurance README lists
the two v2 schemas without rewriting existing entries; the receipts validator has v2
awareness and passes on the `pass` fixture while all three negative controls
(`unknown_method`, `undefined_lens`, `receipt_schema_drift`) fail closed against their
fixtures; the additive-superset diffs, binding proofs, v1 coexistence proof, and full-suite
no-regression proofs are retained; AC-1..AC-10 hold; `support/implementation-run.md`,
`support/implementation-conformance-review.md`, and
`support/post-implementation-drift-churn-review.md` exist with passing conformance and
drift validators; `proposal.yml#status` remains `accepted`; and all evidence is retained
under `.octon/state/evidence/validation/proposals/architectural-review-schema-extensions/`.
Next route after passing post-implementation receipts: `promote-proposal`, then packet
verification.
