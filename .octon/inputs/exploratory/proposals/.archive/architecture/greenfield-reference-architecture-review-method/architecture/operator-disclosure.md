# Operator Disclosure

## What Changes For Operators

Little changes operationally when this child lands. No new command, skill, gate,
routed workflow mode, or evidence root is created. Balanced Architecture Review
remains the **default** method: any review that makes no method selection behaves
exactly as before. What is new is that a reviewer who selects the **Greenfield
Reference Architecture Review** method (already routable since phase-1) now has an
authored output contract to conduct the review against.

## What Becomes Available

- A native **Greenfield method doc** answering "if this system or subsystem did
  not exist, what should we build first?", with five required output sections
  (domain/job model; reference architecture; quality/security/ops model;
  authority/evidence model; evolution plan) plus initial-build sequencing, a
  minimum viable architecture, and an explicit what-not-to-build-yet list.
- The doc is **wired into the catalog**: the `naming.yml` greenfield entry
  references it and the mechanism README links it, so operators can discover the
  contract from the method catalog.

## What Operators Must Not Assume

- Greenfield output is **reference architecture only**. It is evidence or proposal
  input — never implementation authority, never a lifecycle gate, and never a
  what-to-change verdict against an existing system. Implementation still requires
  a proposal drafted against current reality and its own pre-integration review.
  The pre-integration support receipt remains the only lifecycle-gating review
  artifact.
- Greenfield does **not** replace Balanced. For an existing system, use Balanced
  (or draft a proposal against current reality); Greenfield is for the
  clean-sheet reference design before an implementation proposal exists. When a
  Greenfield review reaches an option choice inside the design it escalates to
  Tradeoff Review; a runtime-critical subsystem escalates to Failure-Mode Review.
- The four **companion method docs** (Tradeoff, Failure-Mode, Evolution/Fitness,
  Boundary/Authority) are authored by a separate phase-2 child
  (`companion-architecture-review-methods`); the **schema field** recording the
  selected method and applied lenses is authored by
  `architectural-review-schema-extensions` (phase-2); **method-id recording in
  run evidence** is authored by `architectural-review-suite-integration`
  (phase-3). This child authors only the Greenfield output contract.
- No existing route, alias, evidence root, lens profile, or the pre-integration
  gate changed.

## Support And Evidence

The doc-consistency check run, the structural and fail-closed-boundary presence
checks, the no-regression validator sweep, and the additive-only / doctrine-
unchanged `git diff` proofs are retained under
`.octon/state/evidence/validation/proposals/greenfield-reference-architecture-review-method/`.
This packet is non-authoritative proposal lineage; the durable authority after
promotion is the framework artifacts listed in `architecture/file-change-map.md`.
