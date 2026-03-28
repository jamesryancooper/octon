# ADR 073: Wave 5 Agency Simplification And Adapter Hardening Cutover

- Date: 2026-03-27
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-27-wave5-agency-simplification-adapter-hardening-cutover/plan.md`
  - `/.octon/state/evidence/migration/2026-03-27-wave5-agency-simplification-adapter-hardening-cutover/`
  - `/.octon/inputs/exploratory/proposals/.archive/architecture/fully-unified-execution-constitution-for-governed-autonomous-work/`
  - `/.octon/instance/cognition/decisions/071-assurance-lab-disclosure-expansion-cutover.md`

## Context

Wave 4 promoted assurance, lab, and disclosure families, but two Wave 5 gaps
remained:

- the agency kernel still centered on persona-heavy `architect` and `auditor`
  defaults rather than one explicit accountable orchestrator
- host and model adapters still lacked one explicit constitutional family plus
  bounded support declarations that runtime could enforce

That left a real risk that adapter surfaces or identity overlays could be read
as hidden authority even though the target architecture forbids that model.

## Decision

Promote Wave 5 as a pre-1.0 transitional cutover.

Rules:

1. `orchestrator` becomes the default accountable execution role.
2. `verifier` remains optional and exists only where separation of duties,
   context isolation, or concurrency adds real value.
3. `SOUL.md` remains optional and non-authoritative when present.
4. `framework/constitution/contracts/adapters/**` becomes the constitutional
   contract family for host and model adapters.
5. Runtime adapter manifests live under
   `framework/engine/runtime/adapters/{host,model}/**` and remain replaceable
   plus non-authoritative.
6. Adapter-backed support claims stay bounded by
   `instance/governance/support-targets.yml`.
7. Runtime fails closed when adapter declarations or conformance criteria are
   missing.

## Consequences

### Benefits

- The default agency model becomes simpler and more accountable.
- Adapter behavior is explicit, reviewable, and tied back to the same
  support-target matrix as broader support claims.
- Validators can now block hidden-authority drift across runtime, docs, and
  bootstrap surfaces.

### Costs

- Support-target declarations and test fixtures now carry more structure.
- Runtime routing logic grows to account for adapter envelopes and conformance
  criteria.
- Older methodology or architecture docs that still assume required `SOUL.md`
  layering need follow-on cleanup.

### Follow-on Work

1. Remove any remaining non-blocking persona-shaped references in lower-value
   architecture notes or templates.
2. Extend adapter-backed receipts or disclosure artifacts if later waves need
   richer adapter provenance in human-facing outputs.
3. Continue toward Wave 6 retirement and closeout once the new adapter family
   has held steady through normal use.

## Completion

Wave 5 is complete for active runtime, governance, bootstrap, assurance, and
disclosure surfaces in this repository.

Completion basis:

- one accountable orchestrator is the default execution role
- non-default roles are bounded by explicit separation-of-duties value
- host and model adapters are published as replaceable, non-authoritative
  contract families
- support claims and disclosure artifacts now carry adapter-bounded support
  evidence
- the Wave 5 validator stack passes
