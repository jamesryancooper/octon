# Validation, Fail-Closed, Quarantine, And Staleness Cutover Evidence (2026-03-20)

## Scope

Single-promotion atomic migration implementing Packet 14
`validation-fail-closed-quarantine-staleness`:

- add the runtime-effective Packet 14 trust gate
- add retained publication receipts under
  `state/evidence/validation/publication/**`
- promote the extension, locality, and capability publication schema revisions
- republish locality with reduced coherent publication on scope-local
  quarantine
- harden extension publication against native-versus-extension capability
  collisions
- keep `repo_snapshot` clean-only when extension quarantine is non-empty
- retire the Packet 14 proposal package into `.archive/**`

## Cutover Assertions

- Runtime and policy trust now terminate at one explicit Packet 14 validator
  gate.
- Scope-local failures no longer collapse locality publication when a coherent
  surviving scope set exists.
- Runtime-facing publication families now emit machine-readable retained
  publication receipts.
- Extension effective publication no longer exposes obsolete raw-pack
  `content_roots`.
- Export remains fail-closed when extension quarantine is non-empty.
- The focused Packet 14 shell regressions and harness alignment gate passed.

## Receipts And Evidence

- Validation receipts: `validation.md`
- Command log: `commands.md`
- Change inventory: `inventory.md`
- Migration plan:
  `/.octon/instance/cognition/context/shared/migrations/2026-03-20-validation-fail-closed-quarantine-staleness-cutover/plan.md`
- ADR:
  `/.octon/instance/cognition/decisions/058-validation-fail-closed-quarantine-staleness-atomic-cutover.md`
- Archived proposal package:
  `/.octon/inputs/exploratory/proposals/.archive/architecture/validation-fail-closed-quarantine-staleness/`
