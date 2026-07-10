# Executable Implementation Prompt — Architecture Lens Bank Foundation

generated_by: Octon `generate-packet-implementation-prompt` route
run_id: `20260709-arms-program-clean-delivery-04-architecture-lens-bank-foundation`
packet: `.octon/inputs/exploratory/proposals/architecture/architecture-lens-bank-foundation`
authorization_basis: accepted `proposal.yml#status`, accepted
`support/proposal-review.md` (`implementation_prompt_authorized: yes`,
`open_blocking_findings_count: 0`), strict Pre-Integration Architecture Review
receipt `support/pre-integration-architecture-review.yml`.
non_authority: This prompt is proposal-local candidate lineage. It grants no
runtime, policy, or durable authority and never satisfies any parent-program or
sibling-child receipt. Durable authority is the promoted framework artifacts.

---

## 0. Preflight (fail closed)

Before writing any durable file, confirm implementation authorization is still
fresh at the current packet digest. Run, from repo root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh \
  --package .octon/inputs/exploratory/proposals/architecture/architecture-lens-bank-foundation \
  --require-implementation-authorization
```

Proceed only if this exits `errors=0` with `implementation_prompt_authorized:
yes` and zero open blocking findings. If the gate fails — stale digest, missing
authorization, or open blocker — stop and report a **blocked gate outcome** with
the failing output as evidence. Do not implement, do not widen scope, and do not
edit the packet to force the gate green.

Confirm write scope is limited to the two registry-declared scopes plus the
assurance fixture tree (see §2). Any change outside them is out of scope.

---

## 1. Target End State

After this child lands, the Architectural Review Mechanism directory
`.octon/framework/cognition/practices/methodology/architectural-review/` holds
**six** files: the four existing ones (`README.md`,
`balanced-architecture-review-method.md`, `naming.yml`, `review-routing.yml`,
all unchanged) plus two new authored artifacts:

- `architecture-lens-bank.md` — lens doctrine: the 18-lens catalog in two tiers
  (12 core, 6 extended), a human-view per-method R/O/— profile table, the
  clean-sheet vs Greenfield complementarity statement, the Balanced
  sequence→lens-id appendix, and the four sprawl controls.
- `lens-bank.yml` — the machine-readable contract: `lenses[]` with `id` + `tier`
  for all 18 lenses, and `method_profiles.<method>` with `required`/`optional`
  lens sets for all six suite methods.

`.octon/framework/assurance/runtime/_ops/scripts/` gains one new validator,
`validate-architectural-review-lens-references.sh`, that fails closed on an
undefined lens id in a method reference or a bank-known method missing a profile.
Its fixtures (one passing, two negative controls) land under the assurance
fixture tree.

The mechanism's runtime behavior, routing, gates, and Balanced doctrine are
unchanged. The lens bank is analysis tooling only; it grants no review output
authority.

This is an **atomic** change (`change_profile: atomic`). All authored artifacts
and their validator land together as one coherent landing. There is no
intermediate live state where a half-populated bank is referenceable, and
post-cutover validation (§6) runs before any success claim.

---

## 2. In-Scope And Out-Of-Scope Surfaces

### Owned file families (write scopes — the ONLY places durable changes land)

1. `.octon/framework/cognition/practices/methodology/architectural-review/`
   — the two new authored artifacts only. Existing files are read-only.
2. `.octon/framework/assurance/runtime/_ops/scripts/`
   — the one new validator only.
3. The assurance fixture tree
   `.octon/framework/assurance/runtime/_ops/fixtures/architectural-review/`
   (final leaf paths chosen to match sibling fixtures) — passing + two
   negative-control fixtures. Optionally register the new validator in the
   sibling test harness `_ops/tests/test-architectural-review-validators.sh` if
   and only if that stays inside these scopes and follows its existing pattern.

### Promotion targets (must all exist and pass; do not add or drop targets)

- `.octon/framework/cognition/practices/methodology/architectural-review/architecture-lens-bank.md`
- `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lens-references.sh`
- `.octon/state/evidence/validation/proposals/architecture-lens-bank-foundation/`
  (child-owned evidence root)

### Explicitly NOT changed (preserve verbatim — verify with `git diff`)

- `balanced-architecture-review-method.md` — cross-referenced, never edited (AC-4).
- `naming.yml` — the v2 methods-list refactor is phase-1 scope.
- `review-routing.yml` — `method_selection` semantics are phase-1 scope.
- `README.md` (mechanism) — canonical-names table update is phase-1 scope.
- `.octon/framework/constitution/contracts/assurance/architectural-review-*.schema.json`
  — schema v2 additions are phase-2 scope.
- Review workflow contracts under `orchestration/runtime/workflows/audit/**`
  — method-recording is phase-3 scope.
- Architecture-readiness / surface-architecture audit doctrine — composed with,
  never modified.

Create **no** new mechanism, lifecycle gate, routed workflow mode, evidence
root, or command facade. Grant **no** review output any authority.

---

## 3. Ordered Workstreams

Author in this order; the whole set lands as one atomic change.

1. **Author `lens-bank.yml`.** Transcribe all 18 lens ids + tiers and the six
   `method_profiles` (Balanced + five companions) exactly from
   `resources/lens-bank-authoring-spec.md` §"Artifact 2" (R → `required`,
   O → `optional`, — → omitted). Finalize field names against sibling
   `naming.yml` / `review-routing.yml` conventions (NB-2 defers final naming to
   this stage). Use the **provisional** companion method slugs and add an inline
   comment recording that the phase-1 `architecture-review-method-taxonomy-and-routing`
   child owns the canonical slugs in `naming.yml` v2.
2. **Author `architecture-lens-bank.md`.** Write the five required sections from
   the authoring spec §"Artifact 1": purpose/scope; the 18-lens catalog
   (per lens: id, tier, the question it asks, the evidence artifact it produces,
   when to apply — content fixed by `resources/source-context.md` §"Lens Catalog");
   the human-view R/O/— profile table mirroring `lens-bank.yml` exactly; the
   clean-sheet vs Greenfield complementarity statement; and the four sprawl
   controls (new-lens admission requires a named decision/evidence/routing
   outcome; no private lens catalogs; validator fails closed; retirement follows
   naming/retirement discipline with explicit legacy alias). State the doc's
   non-goals (creates no method, routing, gate, or schema; grants no authority).
3. **Author the Balanced appendix.** Carry the 11-steps→10-lenses mapping table
   from `resources/lens-bank-authoring-spec.md` §"Balanced Required Sequence
   Expressed As Lens Ids" **verbatim** into `architecture-lens-bank.md` (NB-1:
   the appendix must be self-explaining that charter framing, step-9 compare, and
   step-10 target-architecture output are method-level activities, not lenses).
   The resulting Balanced required set is exactly the 10 `R` lens ids. Do **not**
   edit `balanced-architecture-review-method.md`.
4. **Author the validator** `validate-architectural-review-lens-references.sh`
   following existing `validate-architectural-review-*.sh` conventions:
   `#!/usr/bin/env bash` + `set -euo pipefail`, `--root` handling, `pass()`/
   `fail()` emitting `[OK]`/`[ERROR]`, a trailing `Validation summary: errors=N`,
   non-zero exit when `errors>0`, and `yq` for YAML reads. Implement both
   fail-closed rules: (a) any lens id referenced by a method profile/method doc
   that is not in `lenses[].id` → error; (b) a bank-known method with no
   `method_profiles.<method>` entry or an empty `required` set where the source
   mandates one → error. The validator MUST check lens-id integrity and profile
   completeness **without hard-coupling to companion method slugs** that only
   exist after phase-1. Include a positive control over the shipped bank.
5. **Author fixtures** under the assurance fixture tree beside sibling
   architectural-review fixtures: a passing fixture, a `fail-undefined-lens`
   fixture (a method reference citing a lens id absent from `lenses[]`), and a
   `fail-missing-profile` fixture (a `lens-bank.yml` omitting a required method
   profile).
6. **Confirm Balanced unchanged and run validators** (see §4, §6). Retain all
   runs as evidence (§5).
7. **Generated projections.** If a generated methodology index references the new
   files, refresh it **only** through the canonical publication script — never
   hand-edit any `generated/**` path. If no such index exists, record that no
   generated refresh was required.

---

## 4. Validation Commands

Run from repo root. All must meet their fail-closed expectation before any
success claim.

| Check | Command | Expected |
| --- | --- | --- |
| Lens-reference positive control | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lens-references.sh` (shipped bank) | pass, `errors=0`, exit 0 |
| Negative control 1 — undefined lens id | validator against the `fail-undefined-lens` fixture | fail, `errors>0`, non-zero exit |
| Negative control 2 — missing method profile | validator against the `fail-missing-profile` fixture | fail, `errors>0`, non-zero exit |
| Doc/registry consistency | compare `architecture-lens-bank.md` profile table + 18 lens ids/tiers vs `lens-bank.yml` | identical id + tier + profile sets |
| Balanced unchanged | `git diff -- .octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md` | empty (no change) |
| No regression | `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh` and `.../validate-architectural-review-routing.sh` | still pass |
| Fixture-retention / test harness (if wired) | `bash .octon/framework/assurance/runtime/_ops/tests/test-architectural-review-validators.sh` | pass |

The two negative controls are **mandatory**, not optional: this child ships an
enforcement surface, so at least one negative control per fail-closed rule is
required (child-packet-contract obligation 4).

---

## 5. Evidence Outputs

Retain all of the following under the child-owned evidence root
`.octon/state/evidence/validation/proposals/architecture-lens-bank-foundation/`
and reference them from the receipts in §7. Parent program evidence never
substitutes for these child receipts, and proposal-local `support/**` files are
never used as implementation proof.

- Lens-reference validator runs: positive control + both negative controls
  (captured stdout/stderr showing the pass and the two fail-closed exits).
- Doc/registry consistency check result (18 lens ids + tiers + six profiles
  agree between doc and YAML).
- Balanced-unchanged proof (`git diff` empty for the Balanced doc).
- No-regression proof (existing naming/routing validators still pass).
- Note recording whether any generated methodology index required a canonical
  publication refresh, and the outcome.

---

## 6. Cutover (atomic) And Post-Cutover Validation

Land all four artifacts (two docs, validator, fixtures) as one coherent change —
no partial live state. Then, before claiming success, confirm every §4 row meets
its expectation:

- validator passes on the shipped bank;
- both negative-control fixtures fail closed (non-zero exit);
- doc/registry consistency holds;
- `git diff` shows `balanced-architecture-review-method.md` unchanged;
- existing naming/routing validators still pass;
- evidence retained under the child evidence root.

If any post-cutover check fails and cannot be corrected in place within the
packet target architecture, treat it as a rollback trigger (§8) or a blocked gate
outcome with evidence — do not claim partial success.

---

## 7. Post-Implementation Gates (make the receipts executable)

After the durable changes land and §6 passes, produce the post-implementation
receipts in order. Refuse any closeout or archive claim while either
post-implementation receipt is missing, failing, unresolved, or blocked, and do
not claim `implemented` status in that state either.

1. **Create/update `support/implementation-run.md`** with at least:
   `verdict`, `implemented_at`, and `promotion_evidence_count` (the count of
   retained evidence artifacts under the child evidence root). Record which
   promotion targets landed and link the §5 evidence.
2. **Create/update `support/implementation-conformance-review.md`**, then run:
   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh \
     --package .octon/inputs/exploratory/proposals/architecture/architecture-lens-bank-foundation
   ```
   Resolve to `errors=0` before proceeding.
3. **Create/update `support/post-implementation-drift-churn-review.md`**, then run:
   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh \
     --package .octon/inputs/exploratory/proposals/architecture/architecture-lens-bank-foundation
   ```
   Resolve to `errors=0` before proceeding.

**Status handling:** leave `proposal.yml#status` as `accepted`. Do **not**
rewrite it to `implemented` here — the `promote-proposal` lifecycle route
performs the implemented-status rewrite once these receipts pass. Preserve the
promotion targets, declared validation, retained evidence, rollback notes,
generated outputs, downstream references (phase-1 binds at its `verification`
gate), and explicit exclusions unchanged.

---

## 8. Rollback Posture

Rollback is **manual** and low-risk because the change is purely additive.

1. Delete the two authored artifacts, the validator, and its fixtures.
2. Confirm no other file referenced them yet. Phase-1 only binds at its
   `verification` gate, so a rollback before phase-1 implementation has no
   downstream references to repair. If phase-1 has already bound to the lens ids,
   coordinate rollback at the parent program (registry revision) — never a silent
   local revert that would strand a downstream child.
3. Re-run the existing architectural-review validator suite to confirm the
   mechanism is back to its prior passing state.
4. Retain a rollback receipt under the child evidence root recording what was
   removed and why.

Rollback triggers: the bank is inconsistent with the live mechanism in a way that
cannot be corrected in place; a parent registry/design revision supersedes the
lens-bank design before this child closes; or the validator cannot be made to
fail closed on its negative controls.

---

## 9. Terminal Criteria

Implementation is complete for this route when all hold:

- AC-1..AC-7 (`architecture/acceptance-criteria.md`) are satisfied:
  lens doctrine authored (AC-1), machine-readable bank authored with doc↔YAML
  agreement (AC-2), fail-closed validator with both negative controls (AC-3),
  Balanced expressed as lens ids with the doc unedited (AC-4), four sprawl
  controls authored (AC-5), additive-only with no authority granted (AC-6),
  evidence retained (AC-7).
- All §4 validators pass, with the two negative controls demonstrably failing
  closed.
- Evidence is retained under the child evidence root (§5).
- The two post-implementation receipts (§7) exist and pass; `proposal.yml#status`
  remains `accepted` for the `promote-proposal` route.

Closeout, archive, and `implemented`-status claims are **out of scope for this
route** and remain gated on the post-implementation receipts and the downstream
lifecycle routes.

## 10. Blocker Discipline

Resolve blockers inside the packet target architecture and its declared write
scopes, or report a **blocked gate outcome** with the failing evidence. Do not
invent new authority, widen the promotion targets or support claims, edit
out-of-scope files, use proposal-local `support/**` files as implementation
proof, or force any gate green by editing the packet. Delegation across bounded
agents is **not** required and **not** authorized by this packet; if a human
later authorizes delegated implementation, split work only across disjoint write
scopes with a single integration owner.
