# Wave 0 Constitutional Baseline Receipt

## Profile Selection Receipt

- `change_profile`: `transitional`
- `release_state`: `pre-1.0`
- `version_sources`:
  - `/.octon/octon.yml#versioning.harness.release_version`
- `current_version`: `0.6.3`
- `selection_facts`:
  - `downtime_tolerance`: internal harness work can absorb staged cutovers, but the blast radius is too wide for a safe atomic switch from distributed constitutional fragments to one supreme kernel.
  - `external_consumer_coordination_ability`: low external dependency pressure, but significant repo-local coordination exists across bootstrap, ingress, agency governance, architecture docs, validators, and future runtime cutovers.
  - `data_migration_backfill_needs`: moderate; authority references and validator expectations need explicit bridge updates before later waves can bind run contracts and support-target declarations.
  - `rollback_mechanism`: revert the kernel and doc-alignment change set, rerun structural and authoritative-doc validators, and fall back to the prior distributed constitutional references.
  - `blast_radius_and_uncertainty`: high for docs, ingress, and validator coupling; lower for runtime behavior because Wave 0 is intentionally scaffold-first.
  - `compliance_policy_constraints`: no class-root invariant, authored-authority rule, or fail-closed guard may weaken during the baseline cutover.
- `hard_gate_outcomes`:
  - `temporary_coexistence_required`: `true`
  - `validator_and_doc_bridging_required`: `true`
  - `mission_first_runtime_must_remain_active_until_run_contract_cutover`: `true`
  - `support_target_schema_can_land_before_support_target_publication`: `true`
- `tie_break_status`: `transitional` selected because hard gates require a staged coexistence window.
- `transitional_exception_note`:
  - `rationale`: pre-1.0 defaults to `atomic`, but Wave 0 must establish a new supreme kernel while keeping current mission-first runtime, agency governance, and fail-closed protections intact.
  - `risks`: temporary duplication between legacy constitutional prose and the new kernel; validators may lag if the kernel and shims drift; later waves must retire staged placeholders instead of leaving them permanent.
  - `owner`: Octon governance
  - `target_removal_decommission_date`: `2026-09-30`

## Implementation Plan

1. Publish the Wave 0 constitutional kernel under `/.octon/framework/constitution/**`.
2. Align `/.octon/README.md`, `/.octon/instance/bootstrap/START.md`, `/.octon/framework/cognition/_meta/architecture/specification.md`, and ingress-facing governance shims so they point to the kernel instead of competing constitutional fragments.
3. Update local structural and authoritative-doc validators to recognize the new kernel and verify the aligned read path.

## Impact Map (code, tests, docs, contracts)

- `code`:
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh`
- `tests`:
  - no new dedicated test harness added in Wave 0; rely on updated local validators listed in the compliance receipt
- `docs`:
  - `/.octon/README.md`
  - `/.octon/instance/ingress/AGENTS.md`
  - `/.octon/instance/bootstrap/START.md`
  - `/.octon/framework/agency/governance/{CONSTITUTION.md,DELEGATION.md,MEMORY.md}`
  - `/.octon/framework/cognition/_meta/architecture/specification.md`
- `contracts`:
  - `/.octon/framework/constitution/CHARTER.md`
  - `/.octon/framework/constitution/charter.yml`
  - `/.octon/framework/constitution/precedence/{normative.yml,epistemic.yml}`
  - `/.octon/framework/constitution/obligations/{fail-closed.yml,evidence.yml}`
  - `/.octon/framework/constitution/ownership/roles.yml`
  - `/.octon/framework/constitution/contracts/registry.yml`
  - `/.octon/framework/constitution/support-targets.schema.json`
  - `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`

## Compliance Receipt

- The new kernel establishes one explicit repo-local constitutional root without changing the five-class super-root or authored-authority boundaries.
- `/.octon/README.md`, `START.md`, the umbrella architecture specification, and instance ingress now point to `/.octon/framework/constitution/**` as the supreme repo-local control regime.
- Agency governance documents remain in place as subordinate application contracts so existing references stay valid while constitutional duplication is reduced.
- Harness structure validation now requires the Wave 0 constitutional files.
- Architecture conformance validation now checks that README, ingress, START, and the umbrella specification reference the kernel.
- Authoritative-doc classification now treats the kernel charter, `.octon/README.md`, and instance ingress as authoritative surfaces.

## Exceptions/Escalations

- No additional human escalation was required beyond the documented transitional exception note.
- Intentional staged gaps remain for later waves:
  - run-contract enforcement is staged until Wave 1
  - normalized approval and revocation artifacts are staged until Wave 2
  - RunCard and HarnessCard disclosure families are staged until Wave 4
  - the authoritative support-target declaration at `/.octon/instance/governance/support-targets.yml` is still unpublished in Wave 0
