# Program Implementation Orchestration Prompt

Run child implementation in declared dependency order for
`native-architectural-review-mechanism`.

## Child Route

Each child owns its own review receipt, implementation prompt, implementation
run receipt, conformance review, drift/churn review, promotion targets,
validators, evidence, closeout evidence, and archive transition. Parent
summaries cannot satisfy child receipts.

## Program Validation

Run proposal program structure and child readiness validators, then run each
child's proposal standard, architecture proposal, implementation-readiness,
architectural-review, publication, conformance, and drift/churn validators.

## Evidence And Rollback

Retain program orchestration evidence under the parent support directory and
child-owned evidence under each child. Rollback is child-specific and must not
remove unrelated user work.

## Closeout Boundary

Block program closeout or archive unless every child is implemented, verified,
closed out, archived, and free of lifecycle residue, with fresh generated
registries and derived projections.
