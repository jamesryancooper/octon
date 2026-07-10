# Executable Implementation Prompt — Greenfield Reference Architecture Review Method

authority_class: retained-evidence-only (proposal-local support artifact; grants
no promotion or runtime authority and is never itself implementation proof)
generated_by_route: `generate-packet-implementation-prompt`
run_id: `20260709-arms-program-clean-delivery-04-greenfield-reference-architecture-review-method`
proposal_path: `.octon/inputs/exploratory/proposals/architecture/greenfield-reference-architecture-review-method`
change_profile: `atomic` · release_state: `pre-1.0` · rollback_posture: `manual`
review_gate: `support/proposal-review.md` accepted, `implementation_prompt_authorized: yes`,
`open_blocking_findings_count: 0`, reviewed_packet_digest fresh (re-verified by
`validate-proposal-review-gate.sh --require-implementation-authorization`, errors=0)

You are the implementer for this phase-2 child packet. Implement **only** the
declared durable promotion targets, atomically, with retained evidence. Do not
broaden scope, invent authority, or use proposal-local support files as
implementation proof.

---

## 1. Target End State

The Architectural Review Mechanism directory
`.octon/framework/cognition/practices/methodology/architectural-review/` carries
an authored **Greenfield Reference Architecture Review** method doc, wired into
the existing method catalog and README with two additive navigation edits. The
greenfield method — already named (phase-1 `naming.yml`), routable (phase-1
`review-routing.yml` `method_selection`), and lens-profiled (phase-0
`lens-bank.yml`) — gains its output contract. Nothing else changes: no new
mechanism, gate, routed workflow mode, evidence root, command facade, or schema;
no Balanced or companion doctrine edit; no lens-bank, routing-semantics, or
validator change.

## 2. In-Scope Surfaces (the ONLY durable writes; registry write scope = the mechanism directory)

Promotion targets (must match `proposal.yml#promotion_targets` exactly):

1. **NEW** `.octon/framework/cognition/practices/methodology/architectural-review/greenfield-reference-architecture-review-method.md`
   — the method output contract.
2. **EDIT (additive)** `.../architectural-review/naming.yml` — add
   `doc: "greenfield-reference-architecture-review-method.md"` to the existing
   `methods.catalog` greenfield entry (mirrors the Balanced entry).
3. **EDIT (additive)** `.../architectural-review/README.md` — add a link to the
   new doc in the **References** section only.
4. **EVIDENCE** `.octon/state/evidence/validation/proposals/greenfield-reference-architecture-review-method/`
   — child-owned promotion evidence root (retained validation runs + diffs).

## 3. Out-of-Scope Surfaces (explicitly DO NOT touch)

- `lens-bank.yml` and `architecture-lens-bank.md` (phase-0 verified dependency — cited, not modified).
- `review-routing.yml` `method_selection` / escalation map (phase-1 — cited, not modified).
- `naming.yml` slugs, `canonical_modes`, aliases, facades, `schema_version`, or any non-greenfield entry.
- `balanced-architecture-review-method.md` (Balanced doctrine — contrasted, never edited).
- Companion method docs — Tradeoff, Failure-Mode, Evolution/Fitness, Boundary/Authority (`companion-architecture-review-methods`, phase-2).
- The README canonical-names table (Greenfield row already present from phase-1).
- `validate-architectural-review-*.sh` (run for no-regression only; never edited).
- `architectural-review-*.schema.json` report/routing-decision v2 fields (`architectural-review-schema-extensions`, phase-2).
- Review workflow contracts and generated/effective projections (`architectural-review-suite-integration`, phase-3; refreshed only via canonical publishers, never hand-edited here).
- Architecture-readiness / surface-architecture audit doctrine (composition boundaries — cited only).

No delegation is authorized: this is a single-surface additive authoring task.
Keep it to one owner; do not split across subagents.

## 4. Ordered Workstreams (atomic — all land together; no partial live state)

**WS0 — Re-ground bindings (repository wins).** Re-read the live surfaces before
authoring; if any slug or lens id drifted from the packet, reconcile to the
repository:
- `naming.yml` `methods.catalog` greenfield entry: slug
  `greenfield-reference-architecture-review-method`, `role: companion`,
  `lens_profile_ref: lens-bank.yml#method_profiles.greenfield-reference-architecture-review-method`,
  currently **no** `doc:` field.
- `review-routing.yml` `method_selection`: allowed methods + `escalation_map` +
  `constitutional_conflict_routes_to`.
- `lens-bank.yml` `method_profiles.greenfield-reference-architecture-review-method`:
  **14 required + 3 optional** lens ids (see WS1 §Lens Profile). If the live
  profile differs from the list below, the live bank wins — cite exactly what the
  bank declares and record the reconciliation in evidence.

**WS1 — Author the method doc** at the target path per
`architecture/method-doc-authoring-spec.md`, in this section order:
1. **Header + question + non-authority line** — title
   `# Greenfield Reference Architecture Review Method`; question *"If this system
   or subsystem did not exist, what should we build first?"*; a non-authority line
   foreshadowing the fail-closed boundary.
2. **Use cases and non-goals** — use cases: new systems, new subsystems, major
   replacement candidates *before* implementation proposals. Non-goals: deciding
   what to change in an existing system (→ Balanced); fantasy architecture that
   ignores Octon governance / support-claim boundaries / evidence obligations /
   validation / operability; absorbing companion methods' output contracts.
3. **Required inputs** — system job/mission statement; known hard constraints
   (governance posture, evidence obligations, support-claim boundaries); explicit
   statement of what is being replaced, if anything.
4. **Lens profile** — state Greenfield draws from the shared Architecture Lens
   Bank and cite ids only (no private catalog). Required (14):
   `system-job-framing`, `domain-model`, `clean-sheet-reference`,
   `quality-attribute-scenarios`, `failure-and-recovery`, `authority-boundary`,
   `validation-strategy`, `non-goals-deletion`, `security-threat-model`,
   `data-truth-lineage`, `contracts-compatibility`,
   `operability-observability-evidence`, `evolution-fitness`,
   `sequencing-mvp-migration`. Optional (3): `current-reality-map`,
   `complexity-separation`, `tradeoff-adr`. Link
   `[Architecture Lens Bank](./architecture-lens-bank.md)` and the
   `lens-bank.yml` profile anchor.
5. **Five required output sections** (in order), each mapped to its driving lenses
   as binding proof for the doc-consistency check: (1) domain/job model
   [`system-job-framing`, `domain-model`]; (2) reference architecture — the
   deliverable [`clean-sheet-reference`, `contracts-compatibility`,
   `complexity-separation` optional]; (3) quality/security/ops model
   [`quality-attribute-scenarios`, `security-threat-model`,
   `failure-and-recovery`, `operability-observability-evidence`]; (4)
   authority/evidence model [`authority-boundary`, `data-truth-lineage`,
   `validation-strategy`]; (5) evolution plan [`evolution-fitness`].
6. **Build discipline** — initial-build sequencing
   [`sequencing-mvp-migration`]; minimum viable architecture
   [`sequencing-mvp-migration`, `non-goals-deletion`]; what-not-to-build-yet list
   with a justifying trigger per deferred item [`non-goals-deletion`].
7. **Clean-sheet complementarity with Balanced** — both use
   `clean-sheet-reference`; in Balanced it is a comparison tool against current
   reality (Balanced Required Sequence steps 8–10); in Greenfield it *is* the
   deliverable and issues **no what-to-change verdict**; replacement transitions
   hand back to Balanced or proposal drafting.
8. **Escalation rules** — cite `review-routing.yml` `method_selection`
   (`escalation_map`, `constitutional_conflict_routes_to`), do not restate as new
   authority: option choice inside the design → Tradeoff; runtime-critical
   subsystem → Failure-Mode; before any implementation proposal → Balanced or
   proposal drafting against current reality; constitutional conflict →
   Constitutional Challenge.
9. **Output boundary (fail-closed)** — Greenfield output is reference
   architecture: retained evidence or proposal input; **never** implementation
   authority, **never** a lifecycle gate, **never** a what-to-change verdict; the
   pre-integration support receipt remains the only lifecycle-gating review
   artifact; treating Greenfield output as implementation authority is out of
   contract.
10. **Related / navigation** — links to `naming.yml` methods,
    `architecture-lens-bank.md`, `review-routing.yml` `method_selection`,
    `balanced-architecture-review-method.md`, and the cited-only composition
    boundaries (architecture-readiness, surface-architecture audit).

Keep the doc archive-ready as structured Markdown; no generated build artifact.

**WS2 — Wire `naming.yml` (additive).** Add
`doc: "greenfield-reference-architecture-review-method.md"` to the existing
`methods.catalog` greenfield entry only. Do **not** bump `schema_version`, rename
any slug, retire any alias, or touch any other entry.

**WS3 — Add the README references link (additive).** Append a link to the new
Greenfield method doc in the mechanism README **References** section only. Do
**not** touch the canonical-names table.

## 5. Validation Commands (implementation-time floor + no-regression sweep)

Run from repo root; capture full stdout/stderr into the evidence root (§6).

Doc-consistency check (child's mandatory floor — child-packet-contract obligation 4):
- **Slug match:** doc declared slug == `naming.yml` `methods.catalog` greenfield slug == `lens-bank.yml` `suite_methods` slug == `greenfield-reference-architecture-review-method`.
- **Lens-profile match:** the lens ids cited in the doc == `lens-bank.yml` `method_profiles.greenfield-reference-architecture-review-method` (required + optional) — no extra id, no missing id, no private catalog.
- **Structural:** all five required sections + all three build-discipline subsections present.
- **Fail-closed boundary:** the reference-architecture-only boundary is present and stated fail-closed.

No-regression validator sweep (each must report `errors=0`):
```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-routing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lens-references.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-workflows.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lifecycle-gates.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-extension-split.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-skills-commands.sh
```
(Consult each validator's `--help`/usage if it requires an explicit target arg;
pass the mechanism/config path it expects. Do not modify any validator to make it
pass.)

Additive-only / doctrine-unchanged diff proof (scoped `git diff`):
```sh
git diff -- .octon/framework/cognition/practices/methodology/architectural-review/naming.yml
git diff -- .octon/framework/cognition/practices/methodology/architectural-review/README.md
git diff --stat -- .octon/framework/cognition/practices/methodology/architectural-review/
```
Confirm: `naming.yml` shows only the added `doc:` line; `README.md` shows only a
References link; `balanced-architecture-review-method.md`, companion docs,
`lens-bank.yml`, `architecture-lens-bank.md`, and `review-routing.yml` show **no**
change; the only new file is the greenfield method doc.

## 6. Evidence Outputs (retained; parent-program evidence never substitutes)

Write all runs and proofs under the child promotion evidence root
`.octon/state/evidence/validation/proposals/greenfield-reference-architecture-review-method/`:
doc-consistency check result (slug + lens-profile + structural + fail-closed
boundary), the full no-regression validator sweep output, and the scoped `git
diff` additive-only / doctrine-unchanged proofs. Reference these from the
implementation and post-implementation receipts below. Do **not** place evidence
inside the proposal packet path and do **not** treat any `support/**` file as
implementation proof.

## 7. Post-Implementation Gates (make each executable; do not claim success while any is missing/failing/blocked)

After the durable changes land:
1. Create/update `support/implementation-run.md` with at least `verdict`,
   `implemented_at`, and `promotion_evidence_count`.
2. Create/update `support/implementation-conformance-review.md`, then run:
   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/greenfield-reference-architecture-review-method
   ```
3. Create/update `support/post-implementation-drift-churn-review.md`, then run:
   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/greenfield-reference-architecture-review-method
   ```

## 8. Terminal Criteria (all must hold — maps to AC-1…AC-9)

- AC-1 doc authored; AC-2 five required output sections present; AC-3 build
  discipline (sequencing + minimum viable architecture + what-not-to-build-yet)
  present; AC-4 reference-architecture-only boundary stated fail-closed; AC-5 lens
  profile bound to the bank with exact doc-consistency match; AC-6 non-goals +
  clean-sheet complementarity + escalation rules stated; AC-7 doc wired in,
  additive only (no slug/schema-version/route/table-row change); AC-8 no
  regression, no new authority (validators pass, Balanced/companion/lens/routing
  unchanged); AC-9 evidence retained under the child root.
- Doc-consistency check passes; full `validate-architectural-review-*.sh` suite
  passes; both post-implementation receipts exist and pass.
- Leave `proposal.yml#status` as `accepted` — do **not** rewrite it to
  `implemented`; the `promote-proposal` lifecycle route performs that rewrite.
- Refuse any `implemented` / closeout / archive-ready claim while either
  post-implementation receipt is missing, failing, unresolved, or blocked.

## 9. Blocker Posture (fail-closed)

Resolve blockers inside this packet's target architecture (the mechanism
directory) or report a **blocked gate outcome with evidence**. Do not widen
scope, edit out-of-scope surfaces, invent new authority, or use support files as
proof. If an upstream binding drifted (greenfield slug or lens profile changed in
phase-0/phase-1) such that the doc cannot be authored consistently, stop and
report blocked with the reconciliation evidence rather than forcing a mismatched
doc — see `architecture/rollback-plan.md` triggers.

## 10. Rollback Posture

Manual (per registry). If reverting: delete the method doc, revert the additive
`naming.yml` `doc:` reference and the README link, confirm no downstream child
(phase-3 suite-integration) has bound to the doc, re-run the full validator suite,
and retain a rollback receipt under the child evidence root. Any rollback that
would strand a downstream child escalates to parent-program coordination, not a
silent local revert.

---

**Next route after this prompt is retained and the packet keeps a fresh accepted
review with `implementation_prompt_authorized: yes`:**
`/octon-proposal-run-packet-implementation`.
