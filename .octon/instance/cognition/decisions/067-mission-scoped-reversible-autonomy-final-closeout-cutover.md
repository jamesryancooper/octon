# ADR 067: Mission-Scoped Reversible Autonomy Final Closeout Cutover

- Date: 2026-03-25
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-25-mission-scoped-reversible-autonomy-final-closeout-cutover/plan.md`
  - `/.octon/state/evidence/migration/2026-03-25-mission-scoped-reversible-autonomy-final-closeout-cutover/`
  - `/.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-final-closeout-cutover/`
  - `/.octon/instance/cognition/decisions/066-mission-scoped-reversible-autonomy-steady-state-cutover.md`

## Context

ADR 066 closed the prior steady-state packet, but the final implementation
audit still identified several cutover-proof gaps:

- lifecycle legality still depended more on convention than on a dedicated
  seed-before-active validator
- route publication did not explicitly record scenario-family, boundary, and
  recovery provenance
- control-evidence coverage was backed by retained samples, but directive/add
  and authorize-update/add were not first-class runtime helpers
- autonomy burn and breaker tightening were not yet driven by a canonical
  retained-evidence reducer
- the mission-autonomy alignment profile and CI workflow still reflected the
  earlier validator set rather than the final closeout gate

## Decision

Promote the final MSRAOM closeout as one additional pre-1.0 atomic cutover at
`0.6.3`.

Rules:

1. `version.txt` and `/.octon/octon.yml` remain in enforced parity at `0.6.3`.
2. Seed-before-active is the only legal lifecycle path into autonomous active
   or paused mission runtime state.
3. The generated effective route records normalized scenario-family, boundary,
   and recovery provenance plus tightening overlays.
4. Directive adds, authorize-update adds, and autonomy burn/breaker
   recomputation are first-class runtime helpers with retained control
   receipts.
5. Mission summaries, operator digests, and `mission-view.yml` remain
   generated read models, but their presence and source citations are enforced
   by dedicated validators.
6. The mission-autonomy alignment profile and architecture-conformance CI
   workflow block on the full final-closeout validator and smoke-test set.

## Consequences

### Benefits

- The repo now has one explicit final-closeout model rather than a steady-state
  approximation plus proposal-local follow-up.
- Runtime helpers, generated read models, validators, and CI now agree on the
  same seed-before-active, provenance-rich MSRAOM contract.
- The release bump to `0.6.3` is accompanied by refreshed extension and
  capability publication state, so the umbrella runtime-effective gate stays
  coherent.

### Costs

- Additional runtime helper scripts, validators, and smoke tests increase the
  size of the mission-autonomy enforcement surface.
- New retained publication and control-evidence artifacts are committed for the
  `0.6.3` closeout.

### Follow-on Work

1. Verify hosted branch-protection/ruleset enforcement still matches the
   expanded architecture-conformance workflow job set.
2. Archive or normalize the superseded steady-state proposal packet in the
   user-managed proposal workspace once the surrounding worktree cleanup is
   complete.
