# Transitional Retirement Plan

## Transitional classes

The current architecture intentionally retains compatibility projections for existing validators and runtime tooling. These are acceptable only when explicitly temporary.

Classes covered by this plan:

- `contract-registry.yml` compatibility projections: `execution`, `mission_autonomy`, `documentation`;
- workflow compatibility command wrappers;
- host projection shims, including any symlink-era skill projection language;
- deprecated closeout prompt fallback surfaces;
- legacy proposal lineage references in active docs.

## Retirement metadata

Every transitional structure must declare:

- identifier;
- canonical replacement;
- owner;
- consumers;
- removal trigger;
- next review date;
- validator that proves no active dependency remains;
- retained retirement evidence path.

## Keep vs retire

| Transitional surface | Keep now? | Retirement condition |
|---|---:|---|
| Contract-registry compatibility projections | Yes | All validators/runtime consumers use canonical path families or generated maps. |
| Workflow compatibility wrapper | Yes, fail-closed | Run-first commands cover all workflow execution cases. |
| Root `AGENTS.md` as adapter | Yes | Keep as projected ingress adapter, not authority. |
| Deprecated closeout prompt fallback | Temporary | Adapters read ingress manifest closeout gate directly. |
| Skills symlink projection language | No | Replace with generated-routing projection model. |
| Historical wave language in active docs | No | Move to ADRs/evidence/history surfaces. |

## Validator

`validate-compatibility-retirement.sh` must emit:

- active transitional inventory;
- missing owner/consumer/expiry failures;
- dependency scan results;
- retirement-ready candidates;
- retained evidence path.
