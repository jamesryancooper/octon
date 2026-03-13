# Clean-Break Governance Cutover Evidence (2026-02-24)

## Scope

Single-promotion clean-break migration completing governance contract cutover:

- Cutover/rollback contract formalized (no dual-run, full-revert-only rollback)
- ACP operating modes formalized as canonical execution entrypoint
- Capability-to-engine consistency enforced as hard gate
- Canonical explainable policy receipt/digest contract enforced
- Canonical agent-led onboarding path promoted; legacy discoverable fallback retired
- Harness version compatibility and deterministic unsupported-version migration path enforced
- SSOT precedence matrix and drift validator enforced

## Cutover Assertions

- Post-cutover governance execution resolves only to the new contract surfaces.
- Legacy discoverable onboarding fallback (`onboard-new-developer`) is removed from workflow manifest/registry routing.
- Unsupported harness versions fail closed with deterministic migration instructions.
- Runtime/governance/practices authority precedence drift is validated fail-closed.

## Receipts and Evidence

- Decision record: `/.octon/cognition/runtime/decisions/039-clean-break-governance-cutover-contract.md`
- Migration runtime plan: `/.octon/cognition/runtime/migrations/2026-02-24-clean-break-governance-cutover/plan.md`
- Validation receipts: `validation.md`
- Command log: `commands.md`
- Change inventory: `inventory.md`
