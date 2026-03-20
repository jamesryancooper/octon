# Memory Routing And Decision Surfaces Cutover Evidence (2026-03-20)

## Scope

Single-promotion atomic migration implementing Packet 11
`memory-context-adrs-operational-decision-evidence`:

- retire the duplicate generated ADR summary from `instance/**`
- keep readable decision summaries only under
  `generated/cognition/summaries/**`
- keep authored ADR authority only under `instance/cognition/decisions/**`
- rewrite active docs, workflows, templates, and skills to the new read/write
  split
- harden generator and validator contracts to fail closed on the retired
  instance-local summary path
- archive the Packet 11 proposal package as implemented

## Cutover Assertions

- `/.octon/instance/cognition/context/shared/decisions.md` no longer exists.
- `/.octon/generated/cognition/summaries/decisions.md` is the only readable
  generated decision summary surface.
- `/.octon/instance/cognition/decisions/**` remains the only authored ADR
  authority surface.
- Active docs and templates now use the generated summary for reading and ADR
  files plus `index.yml` for writing.
- Boundary and generated-artifact validators fail closed if the retired summary
  path reappears.
- The Packet 11 proposal package now lives under `.archive/**` with an
  `implemented` disposition.

## Receipts And Evidence

- Archived proposal:
  `/.octon/inputs/exploratory/proposals/.archive/architecture/memory-context-adrs-operational-decision-evidence/`
- Validation receipts: `validation.md`
- Command log: `commands.md`
- Change inventory: `inventory.md`
- Migration plan:
  `/.octon/instance/cognition/context/shared/migrations/2026-03-20-memory-routing-and-decision-surfaces-cutover/plan.md`
- ADR:
  `/.octon/instance/cognition/decisions/055-memory-routing-and-decision-surfaces-atomic-cutover.md`
