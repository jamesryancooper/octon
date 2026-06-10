# Generated And Read-Model Non-Authority Receipt

run_id: lifecycle-proposal-program-1781073115145-fe49ec37-delegated-governance-cutover-closeout
checked_at: 2026-06-10T11:33:42Z
verdict: pass

## Checks

Searched generated effective and materialized cognition outputs for
non-authority classification and forbidden-consumer metadata. Relevant findings:

- generated effective runtime and capability locks retain
  `non_authority_classification` and `forbidden_consumers` fields.
- materialized run health views expose `authority.may_authorize: false`.
- materialized run health views retain `forbidden_consumers`.
- `operator-read-models-v1.md` defines run health views as generated-only
  operator read models that cannot authorize continuation or widen support.
- the delegated-governance negative-control validator confirms generated
  outputs and read models cannot grant authority.

## Boundary

Generated/read-model outputs may summarize status and diagnostics. They remain
forbidden as authorization, policy, support-target, state-reconstruction,
promotion, terminal, retained-evidence, or closeout truth sources.

## Validator Evidence

Retained validator log:

- `logs/validate-delegated-governance-negative-controls.log`

## Decision

Generated/read-model outputs remain non-authority after cutover. This route did
not refresh, publish, or promote generated projections.
