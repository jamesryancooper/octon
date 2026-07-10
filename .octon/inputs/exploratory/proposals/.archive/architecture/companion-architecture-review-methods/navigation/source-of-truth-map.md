# Source-of-Truth Map

Manual precedence and boundary map for the Companion Architecture Review Methods
packet. This file is navigation only; it is not authoritative over the manifests.

## Durable Authorities (Promotion Targets — New Surfaces)

The four authored method docs are the durable outputs. After promotion they
stand on their own with no dependency on this proposal path:

- `.octon/framework/cognition/practices/methodology/architectural-review/tradeoff-review-method.md`
- `.octon/framework/cognition/practices/methodology/architectural-review/failure-mode-review-method.md`
- `.octon/framework/cognition/practices/methodology/architectural-review/evolution-fitness-review-method.md`
- `.octon/framework/cognition/practices/methodology/architectural-review/boundary-authority-review-method.md`

## Durable Authorities Modified In Place (Additive Only)

These already-canonical files receive additive, non-semantic edits and remain
owned by their existing doctrine; they are not new promotion targets:

- `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml`
  — add an additive `doc:` pointer to each of the four companion `methods.catalog`
  entries (mirroring the existing Greenfield pointer). No slug, default, role, or
  lens-profile-reference change.
- `.octon/framework/cognition/practices/methodology/architectural-review/README.md`
  — add the four method-doc links to the References section. The canonical-names
  table and Methods-And-Selection prose already name all six methods and are not
  changed.

## Upstream Durable Authorities This Packet Depends On (Read-Only)

Delivered by earlier program children; cited and re-grounded, never modified by
this child:

- `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml`
  (`architectural-review-naming-v2`) — canonical method catalog, slugs, default,
  and `lens_profile_ref` bindings for the four companions.
- `.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml`
  (`architectural-review-lens-bank-v1`) — the only lens catalog and the
  per-method `method_profiles.<slug>` required/optional lens sets.
- `.octon/framework/cognition/practices/methodology/architectural-review/architecture-lens-bank.md`
  — human-readable lens doctrine the docs link to.
- `.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml`
  (`architectural-review-routing-v2`) — `method_selection` allowed-methods,
  `escalation_map`, and `constitutional_conflict_routes_to`; the docs cite this
  routing data and do not restate it as new authority.
- `.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md`
  and `greenfield-reference-architecture-review-method.md` — the default and
  first companion doc; the four new docs mirror their authored shape.
- `.octon/framework/cognition/practices/methodology/architectural-review/README.md`
  — mechanism ownership and authority-boundary doctrine.

## Composition Boundaries (Cited, Never Modified Or Duplicated)

- `.octon/framework/cognition/practices/methodology/architecture-readiness/framework.md`
  (section "## Mandatory Failure-Mode Analysis") and its `README.md` — own
  readiness verdicts and the mandatory failure-mode analysis. Failure-Mode Review
  cites this vocabulary and issues no readiness verdict.
- `.octon/framework/cognition/practices/methodology/audits/surface-architecture.md`
  — Surface Architecture Audit doctrine (canonical mode `surface-architecture-audit`
  in `naming.yml` `canonical_modes`, invocation alias `audit-surface-architecture`,
  skill `.octon/framework/capabilities/runtime/skills/audit/audit-surface-architecture/`).
  It owns single-unit `contract-first`/`mixed`/`markdown-first`/`human-led`
  authority-model classification (section "## Authority Model Classification").
  Boundary/Authority Review escalates single-unit follow-ups to it and does not
  duplicate that vocabulary. Note: the parent program's `method-taxonomy.md`
  cites this doc as `audits/surface-architecture.md` relative to the review dir;
  the live path is under `methodology/audits/` — the repository path governs (see
  `architecture/current-state-gap-map.md`).

## Proposal-Local Lifecycle Sources

- `proposal.yml` — highest packet-local lifecycle authority.
- `architecture-proposal.yml` — the single architecture subtype manifest.

Everything under `README.md`, `navigation/**`, `architecture/**`, `resources/**`,
and `support/**` is explanatory, planning, lineage, or evidence material and is
never authoritative.

## Derived Projections

- `.octon/generated/proposals/registry.yml` — discovery-only projection of
  proposal manifests. Registry regeneration is deferred to a coordinated refresh
  because unrelated visible proposal packets are present in the workspace;
  validation for this packet runs with the registry-skip mode (see
  `architecture/validation-plan.md`).

## Retained Evidence Surfaces (Child-Owned, Outside This Path)

- `.octon/state/evidence/validation/proposals/companion-architecture-review-methods/`
  — child-owned validator and lifecycle evidence.
- `.octon/state/evidence/runs/skills/**` and `.octon/state/evidence/runs/workflows/**`
  — run evidence when review/verification routes execute.

Parent program evidence under
`.octon/state/evidence/validation/proposals/architecture-review-method-suite-program/`
never satisfies this child's receipts.

## Boundary Rules

- No new mechanism, routed workflow mode, lifecycle gate, evidence root, report
  or routing-decision schema, validator, or command facade is created by this
  child (those belong to other program children or are deferred).
- Method output is retained evidence or proposal input only; it never becomes
  lifecycle-gate, closeout, promotion, or runtime authority.
- The packet, its resources, the intake unit, and the parent program design docs
  are lineage only; where they disagree with the live repository, the repository
  wins and the divergence is recorded (see `architecture/current-state-gap-map.md`).
