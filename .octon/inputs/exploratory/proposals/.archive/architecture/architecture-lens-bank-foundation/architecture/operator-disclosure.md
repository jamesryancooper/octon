# Operator Disclosure

## What Changes For Operators

Nothing operational changes when this child lands. No new command, skill, gate,
routed workflow mode, or evidence root is created. Operators running any existing
architecture review continue exactly as before; Balanced Architecture Review
remains the default method and its doctrine text is unchanged.

## What Becomes Available

- A shared, machine-readable **architecture lens bank** (`lens-bank.yml`) and its
  doctrine doc (`architecture-lens-bank.md`) that later suite children (method
  taxonomy/routing, method docs, schema extensions, integration) build on.
- A **lens-reference validator** that fails closed if a method doc ever cites an
  undefined lens id or a bank-known method lacks a lens profile. This is a
  correctness guard for later children; it does not gate any current review.

## What Operators Must Not Assume

- The lens bank does **not** grant any review output authority. Review outputs
  remain evidence or proposal input; the pre-integration support receipt remains
  the only lifecycle-gating review artifact.
- The five companion methods are **not** callable yet — this child only seeds the
  lens bank they will reference. Method definitions and routing arrive in later
  phases.
- The companion method slugs used in `lens-bank.yml` profiles are **provisional**
  until the phase-1 taxonomy-and-routing child fixes canonical slugs in
  `naming.yml` v2.

## Support And Evidence

Validator runs and consistency proofs are retained under
`.octon/state/evidence/validation/proposals/architecture-lens-bank-foundation/`.
This packet is non-authoritative proposal lineage; the durable authority after
promotion is the framework artifacts listed in
`architecture/file-change-map.md`.
