# 06. Implementation and migration program

## 6.1 Program overview

This packet organizes execution into eight workstreams and seven ordered phases, using the packet-contained full implementation audit as a confirmation baseline for current bounded-claim honesty and for remediation prioritization.

### Workstreams

| Workstream | Objective | Primary outputs | Owner expectation |
|---|---|---|---|
| `WS-0` | Scope freeze and packet scaffolding | change freeze, source register, execution branch | governance owner |
| `WS-1` | Claim-discipline normalization | bounded wording, release-lineage calibration | governance + disclosure maintainer |
| `WS-2` | Audit and review-lineage normalization | audit crosswalk, fresh build-to-delete packet | governance + assurance maintainer |
| `WS-3` | Authority / non-authority and contract-family normalization | non-authority register, retirement depth, registry updates, active-version coherence | governance + constitution maintainer |
| `WS-4` | Ingress / agency and projection-shell simplification | ingress manifest, parity adapters, workflow boundary thinning | runtime + ingress maintainer |
| `WS-5` | Evidence-depth and evaluator hardening | dossier depth, naturalistic representative runs, evaluator diversity, hidden-check breadth | assurance owner |
| `WS-6` | Release bundle regeneration | new bounded hardened release bundle | disclosure owner |
| `WS-7` | Certification and promotion | dual-pass recertification and active release cutover | governance owner |

## 6.2 Ordered phases

### Phase 0 — freeze inputs

**Goal:** establish the execution baseline.

Actions:

1. Freeze support-target amendments, new adapter admissions, and new capability-pack admissions for the duration of the cutover program.
2. Snapshot the current active support-target digest.
3. Snapshot the current latest explicit audit bundle and active release bundle.
4. Snapshot the packet-contained full implementation audit and extract its remediation checklist into the execution baseline.
5. Open the cutover branch.

Deliverables:

- scope-freeze note
- baseline digests
- cutover branch

### Phase 1 — claim-discipline normalization (`WS-1`)

**Goal:** eliminate active overclaim wording.

Actions:

1. Introduce a bounded machine enum such as `bounded-admitted-live-universe` (or equivalent clearly bounded name).
2. Update all active claim-bearing artifacts to use the bounded enum.
3. Replace active “full-attainment” truth labels with bounded-attainment wording.
4. Preserve historical releases as historical lineage without rewriting their evidence.

Dependencies: none.

Exit criteria:

- no active claim-bearing artifact uses `global-complete-finite` or equivalent universalizing wording.

### Phase 2 — audit + review-lineage normalization (`WS-2`)

**Goal:** make the latest explicit audit and the current active support universe line up with current closure lineage.

Actions:

1. Add `current-audit-crosswalk.yml`.
2. Issue a fresh build-to-delete packet aligned to the six admitted tuples.
3. Update `closeout-reviews.yml` latest packet pointer.
4. Generate a fresh ablation review report for the new packet.
5. Produce a `review-packet-freshness-report.yml` in the new closure bundle.
6. Reconcile the packet-contained full implementation audit recommendations against packet scope so that no recommendation is left untraced.

Dependencies: phase 1 complete.

Exit criteria:

- current audit findings all have machine-readable live dispositions;
- latest review packet is fresher than the last support-universe change;
- all active review lineage points to the fresh packet, not 2026-04-06.

### Phase 3 — authority / non-authority and version normalization (`WS-3`)

**Goal:** remove ambiguity around permanent non-authority surfaces and retained claim-adjacent historical surfaces while normalizing family version declarations.

Actions:

1. Add non-authority-surface policy contract.
2. Add non-authority register for permanent derived/effective/operator surfaces.
3. Upgrade retirement register entries with rationale depth, canonical successor, claim-effect, blocker flags, and review freshness fields.
4. Update constitutional registry and family READMEs to use one normalized compatibility / non-authority pattern.
5. Align objective/runtime/disclosure family version declarations with live artifact usage or declare explicit governed coexistence.

Dependencies: phase 2 complete.

Exit criteria:

- every permanent non-authority surface is inventoried once;
- no family README or registry entry presents a stale contract version as canonical-active;
- every retained claim-adjacent removable surface has mature rationale and review linkage.

### Phase 4 — ingress / agency and projection-shell simplification (`WS-4`)

**Goal:** reduce interpretive ambiguity in default ingress and keep host/workflow projection surfaces thin.

Actions:

1. Add `instance/ingress/manifest.yml`.
2. Rewrite ingress files to reference the manifest rather than carrying mandatory/optional logic only in prose.
3. Narrow the default mandatory set to kernel + workspace + orchestrator.
4. Add ingress parity validator for root and dot-octon adapter files.
5. Add a projection-shell boundary policy and thin any workflow-hosted approval/evaluator path so canonical logic lives in repo-local contracts, validators, or modules.

Dependencies: phase 3 complete.

Exit criteria:

- mandatory ingress set is machine-declared and parity-validated;
- no workflow-hosted approval or evaluator path remains the sole durable definition of canonical behavior.

### Phase 5 — evidence depth + evaluator hardening (`WS-5`)

**Goal:** close `CS-01` and `CS-02`.

Actions:

1. Add support-dossier-evidence-depth contract.
2. Add evaluator-diversity contract.
3. Add hidden-check-breadth contract.
4. Upgrade all live support dossiers with sufficiency sections.
5. Generate additional retained runs as needed to meet minima.
6. Ensure consequential tuples have at least one naturalistic representative retained run in the current release.
7. Ensure consequential tuples have at least one non-host-exclusive evaluator path.
8. Produce tuple-level and release-level depth / diversity / hidden-check reports.

Dependencies: phases 2–4 complete.

Exit criteria:

- every admitted tuple meets minima for retained runs, scenario classes, evaluator diversity, and hidden-check breadth;
- consequential tuples have naturalistic representative evidence and at least one non-host-exclusive evaluator path.

### Phase 6 — release bundle regeneration (`WS-6`)

**Goal:** produce the new hardened bounded release bundle.

Actions:

1. Generate the new release bundle under `<CUTOVER_DATE>-uec-bounded-hardening-closure`.
2. Generate all closure reports.
3. Generate updated effective projections.
4. Generate a new residual ledger in which all packet-scope retained items are closed and only future widening blockers remain.

Dependencies: phases 1–5 complete.

Exit criteria:

- full release bundle exists and is internally consistent.

### Phase 7 — certification and promotion (`WS-7`)

**Goal:** certify and atomically promote the new bounded hardened release.

Actions:

1. Run pass 1 validators on the frozen cutover branch.
2. Re-run pass 2 validators from a clean checkout.
3. If both pass, issue the new closure certificate.
4. Update active release lineage.
5. Mark the previous active release historical/superseded.

Dependencies: phase 6 complete.

Exit criteria:

- dual-pass clean;
- new closure certificate issued;
- release lineage promoted.

## 6.3 Artifact production order

1. bounded wording changes
2. audit crosswalk
3. fresh build-to-delete packet
4. non-authority policy + register
5. retirement register v3
6. active-version normalization across objective/runtime/disclosure families
7. ingress manifest + parity adapters
8. projection-shell boundary thinning
9. dossier sufficiency metadata
10. additional runs / hidden checks
11. depth/diversity reports
12. release bundle regeneration
13. certification

## 6.4 Ownership expectations

This packet assumes role-based ownership, not named individuals.

- **Octon governance owner:** claim discipline, release lineage, certification, residual ledger
- **Constitution maintainer:** registry, family README normalization, claim truth conditions
- **Runtime / ingress maintainer:** ingress manifest, parity adapters, and projection-shell boundary thinning
- **Assurance maintainer:** validators, review packet, evidence depth, evaluator diversity, hidden checks, and non-host-exclusive evaluator paths
- **Disclosure maintainer:** closure reports, release bundle assembly

## 6.5 Migration principle

The migration is **forward-only into a new active release bundle**.

Historical release bundles and historical review packets remain retained evidence. The program does not attempt to retroactively rewrite prior releases to match the new bounded discipline. It instead:

- creates a new hardened bounded release,
- updates active pointers,
- and explicitly demotes older active artifacts into historical lineage.
