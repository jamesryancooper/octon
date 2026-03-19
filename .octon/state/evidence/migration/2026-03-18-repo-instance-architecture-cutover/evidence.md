# Repo-Instance Architecture Cutover Evidence (2026-03-18)

## Scope

Single-promotion atomic migration implementing Packet 4
`repo-instance-architecture`:

- materialize the missing packet-4 repo-instance structure under
  `instance/**`
- rewrite active packet-4 control-plane references away from retired mixed
  repo-instance paths
- add fail-closed repo-instance boundary validation and wire it into the
  harness gate and lightweight CI entrypoints
- update scaffolding template surfaces so packet-4 instance structure is
  scaffolded canonically
- promote the packet-4 proposal package to `implemented`

## Cutover Assertions

- `instance/**` is the canonical repo-owned durable authority layer.
- Missing packet-4 instance structure is materialized.
- Active control-plane docs and workflows no longer rely on mixed repo-instance
  path assumptions.
- Harness validation fails closed on packet-4 boundary drift.
- `repo_snapshot` exports the live `instance/**` surface without packet-4
  drift.
- Workflow validation and harness alignment both pass after the cutover.

## Receipts and Evidence

- Proposal: `/.octon/inputs/exploratory/proposals/architecture/repo-instance-architecture/`
- Path map: `path-map.json`
- Validation receipts: `validation.md`
- Command log: `commands.md`
- Change inventory: `inventory.md`
- Migration plan:
  `/.octon/instance/cognition/context/shared/migrations/2026-03-18-repo-instance-architecture-cutover/plan.md`
- ADR:
  `/.octon/instance/cognition/decisions/048-repo-instance-architecture-atomic-cutover.md`
