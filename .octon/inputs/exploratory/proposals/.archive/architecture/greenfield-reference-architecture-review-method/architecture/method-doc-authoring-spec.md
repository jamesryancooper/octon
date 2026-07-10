# Method Doc Authoring Spec

This spec is the implementation-time source for
`greenfield-reference-architecture-review-method.md`. It is non-authoritative
proposal content; the durable authority is the authored doc after promotion.
Every claim below is grounded in method-taxonomy.md §2, the greenfield charter,
and the live `naming.yml` / `review-routing.yml` / `lens-bank.yml`.

## Target Doc Path

`.octon/framework/cognition/practices/methodology/architectural-review/greenfield-reference-architecture-review-method.md`

## Canonical Bindings (must match live surfaces exactly)

- **Method slug:** `greenfield-reference-architecture-review-method`
  (= `naming.yml` `methods.catalog` slug = `lens-bank.yml` `suite_methods` slug).
- **Display name:** Greenfield Reference Architecture Review.
- **Role:** companion method (Balanced remains the default).
- **Lens profile ref:** `lens-bank.yml#method_profiles.greenfield-reference-architecture-review-method`.

## Required Doc Sections (author in this order)

### 1. Header + Question + Non-Authority Line

- Title: `# Greenfield Reference Architecture Review Method`.
- One-line question: *"If this system or subsystem did not exist, what should we
  build first?"*
- A non-authority line: output is reference architecture — evidence or proposal
  input, never implementation authority (foreshadows the fail-closed boundary).

### 2. Use Cases And Non-Goals

- **Use cases:** new systems, new subsystems, and major replacement candidates
  *before* implementation proposals exist.
- **Non-goals (verbatim intent from method-taxonomy §2):**
  - deciding what to change in an existing system → that is the **Balanced**
    method;
  - fantasy architecture — output must respect Octon governance, support-claim
    boundaries, evidence obligations, validation, and operability from day one;
  - absorbing the companion methods' output contracts (Tradeoff, Failure-Mode,
    Evolution/Fitness, Boundary/Authority).

### 3. Required Inputs

- the system's job / mission statement;
- known hard constraints — governance posture, evidence obligations,
  support-claim boundaries;
- an explicit statement of what is being replaced, if anything (drives whether
  `current-reality-map` is engaged as an optional lens).

### 4. Lens Profile (cite from the bank; no private catalog)

State that Greenfield draws its lenses from the shared Architecture Lens Bank and
list the profile by lens id, exactly as `lens-bank.yml` declares:

- **Required (14):** `system-job-framing`, `domain-model`,
  `clean-sheet-reference`, `quality-attribute-scenarios`, `failure-and-recovery`,
  `authority-boundary`, `validation-strategy`, `non-goals-deletion`,
  `security-threat-model`, `data-truth-lineage`, `contracts-compatibility`,
  `operability-observability-evidence`, `evolution-fitness`,
  `sequencing-mvp-migration`.
- **Optional (3):** `current-reality-map` (engage when replacing an existing
  system), `complexity-separation`, `tradeoff-adr`.

Link: `[Architecture Lens Bank](./architecture-lens-bank.md)` and the profile
anchor in `lens-bank.yml`. Do **not** restate lens definitions; cite ids only.

### 5. Five Required Output Sections

Each Greenfield review must produce all five, in this order. The spec maps each
to the lenses that drive it (binding proof for the doc-consistency check):

1. **Domain / job model** — the system's fundamental job, bounded contexts, core
   entities, and the problem it exists to solve. Lenses: `system-job-framing`,
   `domain-model`.
2. **Reference architecture** — the clean-sheet reference design: components,
   responsibilities, boundaries, and contracts. This is the deliverable, not a
   comparison artifact. Lenses: `clean-sheet-reference`, `contracts-compatibility`,
   `complexity-separation` (optional).
3. **Quality / security / ops model** — quality-attribute scenarios, threat
   model, failure and recovery behavior, and observability/operability from day
   one. Lenses: `quality-attribute-scenarios`, `security-threat-model`,
   `failure-and-recovery`, `operability-observability-evidence`.
4. **Authority / evidence model** — where durable authority lives, what must
   never become authority, the data-truth/lineage model, and the validation
   strategy. This section is what prevents fantasy architecture: every reference
   design states its authority placement and evidence obligations. Lenses:
   `authority-boundary`, `data-truth-lineage`, `validation-strategy`.
5. **Evolution plan** — fitness functions, drift and retirement triggers,
   compatibility posture, and revisit cadence. Lenses: `evolution-fitness`.

### 6. Build Discipline

- **Initial-build sequencing** — the ordered first increments to build, gated by
  dependencies. Lens: `sequencing-mvp-migration`.
- **Minimum viable architecture** — the smallest coherent architecture that does
  the system's job with governance, evidence, and operability intact. Lenses:
  `sequencing-mvp-migration`, `non-goals-deletion`.
- **What-not-to-build-yet list** — an explicit deletion/deferral list of
  components that are tempting but not yet justified, each with the trigger that
  would justify it later. Lens: `non-goals-deletion`.

### 7. Clean-Sheet Complementarity With Balanced

State the relationship explicitly so the two methods are not confused:

- Both use the `clean-sheet-reference` lens.
- In **Balanced**, the clean-sheet reference is a *comparison tool* against
  current reality, feeding a realistic what-to-change target for an existing
  system (Balanced's Required Sequence steps 8–10).
- In **Greenfield**, the clean-sheet reference *is the deliverable*: there is no
  existing system to preserve, or the existing system is being replaced.
  Greenfield issues **no what-to-change verdict**; when an existing system is
  being replaced, the transition back to current reality is handed to Balanced or
  proposal drafting (see escalation).

### 8. Escalation Rules

Cite `review-routing.yml` `method_selection.escalation_map` and
`constitutional_conflict_routes_to`; do not restate routing data as new authority:

- an option choice *inside* the reference design → **Tradeoff Review**
  (`tradeoff-review-method`);
- a runtime-critical subsystem in the design → **Failure-Mode Review**
  (`failure-mode-review-method`);
- before any implementation proposal → **Balanced Review** or proposal drafting
  against current reality (when replacing an existing system);
- constitutional conflicts → **Constitutional Challenge** (existing kernel gate).

### 9. Output Boundary (Fail-Closed)

State, as the doc's fail-closed boundary:

- Greenfield output is **reference architecture**: retained evidence or proposal
  input. It is **never** implementation authority, **never** a lifecycle gate, and
  **never** a what-to-change verdict against an existing system.
- Method selection grants review outputs no authority; the **pre-integration
  support receipt remains the only lifecycle-gating review artifact**.
- A Greenfield output treated as implementation authority is out of contract
  (fail-closed): implementation still requires a proposal drafted against current
  reality and its own pre-integration review.

### 10. Related / Navigation

- Method taxonomy and default: `[naming.yml](./naming.yml)` `methods`.
- Shared lens catalog: `[Architecture Lens Bank](./architecture-lens-bank.md)`.
- Escalation and allowed-methods routing:
  `[review-routing.yml](./review-routing.yml)` `method_selection`.
- Default method it complements:
  `[Balanced Architecture Review Method](./balanced-architecture-review-method.md)`.
- Composition boundaries (cited, never modified): architecture-readiness
  evaluation (owns readiness verdicts — Greenfield issues none) and the
  surface-architecture audit.

## Two Additive Wiring Edits

1. `naming.yml` — on the existing `methods.catalog` greenfield entry, add
   `doc: "greenfield-reference-architecture-review-method.md"` (mirrors the
   Balanced entry). Change nothing else; do not bump `schema_version`.
2. `README.md` — add a Greenfield method-doc link to the **References** section
   (the canonical-names Greenfield row already exists from phase-1).

## Authoring Constraints

- Additive only. Do not edit Balanced doctrine text, companion docs, the lens
  bank, routing routes/method_selection semantics, or any validator.
- Cite lens ids and routing/escalation data; never restate them as new authority.
- Keep the doc archive-ready as structured Markdown with no generated build
  artifact.
