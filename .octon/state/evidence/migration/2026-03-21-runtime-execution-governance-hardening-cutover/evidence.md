# Runtime Execution Governance Hardening Cutover Evidence (2026-03-21)

## Scope

Single-promotion atomic migration implementing `runtime-execution-governance-hardening`:

- add engine-owned execution authorization, request, grant, receipt, and
  executor-profile contracts
- route material kernel entry points through execution authorization and
  retained execution evidence
- migrate live workflow contracts to `workflow-contract-v2` with stage
  authorization metadata
- replace raw workflow executor flag usage with managed executor wrappers
- assert protected CI posture explicitly in the named protected workflows
- add execution-governance validation to the runtime-effective assurance gate

## Cutover Assertions

- Material service, stdio, workflow-stage, kernel mutation, and protected CI
  paths now rely on one execution-governance boundary.
- Protected execution denies weaker-than-`hard-enforce` requested policy modes.
- Live workflow contracts are `workflow-contract-v2` only.
- Protected GitHub workflows emit receipts through the execution posture guard.
- Extension and capability publication locks were republished so their
  root-manifest hashes match the new execution-governance config.

## Receipts And Evidence

- Validation receipts: `validation.md`
- Command log: `commands.md`
- Change inventory: `inventory.md`
- ADR:
  `/.octon/instance/cognition/decisions/060-runtime-execution-governance-hardening-atomic-cutover.md`
- Runtime specs:
  `/.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
- Protected CI guard:
  `/.octon/framework/assurance/runtime/_ops/scripts/assert-protected-execution-posture.sh`
