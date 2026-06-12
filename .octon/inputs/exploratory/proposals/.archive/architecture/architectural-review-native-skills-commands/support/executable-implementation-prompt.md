# Executable Implementation Prompt

Implement only the owned scope for `architectural-review-native-skills-commands`.

## Promotion Targets

- `.octon/framework/capabilities/runtime/skills/audit/`
- `.octon/framework/capabilities/runtime/skills/`
- `.octon/framework/capabilities/runtime/commands/`

## Required Work

- Add thin native skill and command invocation surfaces for architectural review workflows.
- Ensure skills and commands point to workflow contracts and never duplicate workflow authority.
- Update canonical capability manifests and registries only through authored source surfaces and publication scripts.

## Validation And Evidence

Run `validate-architectural-review-skills-commands.sh`, `validate-capability-publication-state.sh`, `validate-proposal-standard.sh`, `validate-architecture-proposal.sh`, and `validate-proposal-implementation-readiness.sh`.
Record evidence in `support/implementation-run.md`, then produce `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md`.

## Rollback And Closeout

Rollback removes the child-owned skills, commands, and manifest entries.
Block closeout or archive if a skill becomes a second control plane, if host projections are hand-edited, or if conformance and drift/churn receipts are absent.
