# Workflows

`/.octon/framework/orchestration/runtime/workflows/` is the single canonical
orchestration surface in Octon.

Each workflow unit contains:

- `workflow.yml` as the canonical machine-readable contract
- `stages/` as the canonical executor-facing stage assets
- `README.md` as the generated human-readable and slash-facing facet

## Discovery

1. Read `manifest.yml` for workflow discovery.
2. Read `registry.yml` for extended workflow metadata.
3. Load `<group>/<id>/workflow.yml` as the authoritative contract.
4. Load `README.md` only when human-readable staged guidance is needed.

## Authority Model

- Canonical authority lives in `workflow.yml` and `stages/`.
- `README.md` is generated and must not be treated as authoritative.
- No peer legacy orchestration surface remains.

## Contract Disambiguation

- `schema_version: workflow-contract-v2` is required in each `workflow.yml`.
- Every stage must declare an `authorization` block with action type,
  requested capabilities, side-effect flags, scopes, review requirements, and
  allowed executor profiles.
- `execution_profile` is required in each `workflow.yml`.
- Allowed `execution_profile` values are `core` and `external-dependent`.
- Governance-impacting changes to workflow contracts, validators, or runtime
  behavior must declare exactly one `change_profile` before implementation.

## Groups

- `meta/`
- `audit/`
- `refactor/`
- `foundations/`
- `missions/`
- `projects/`
- `ideation/`
- `tasks/`
