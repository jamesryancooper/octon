---
finding_id: archive-planner-bash-validator-runtime
generated_at: 2026-06-19T15:54:32Z
generated_by: octon-proposal-lifecycle-generate-program-correction-prompt
target_program: .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
owning_scope: proposal-program-lifecycle-tooling
severity: blocking
verdict: correction-required
child_authority_preserved: yes
archive_executed: no
---

# Correction Prompt: Archive Planner Bash Validator Runtime

## Blocker

Parent archive was not executed because canonical route discovery did not select
`archive-proposal` with no blockers.

Failing route-discovery command:

```sh
.octon/framework/engine/runtime/run lifecycle plan --lifecycle proposal-program --target .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
```

Observed planner route:

```yaml
program_route:
  route_id: generate-program-correction-prompt
blocked_by_program_gate: program-structure
program_blockers:
  - blocker_class: validation-failed
    message: program route archive-proposal failed required gate program-structure
```

Planner gate failure excerpt:

```text
.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh: line 15: declare: -A: invalid option
declare: usage: declare [-afFirtx] [-p] [name[=value] ...]
```

The same validator passed in explicit archive preflight when invoked with the
repository-supported Bash:

```sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
```

Preflight log root:

```text
/tmp/octon-parent-archive-gates-20260619T154925Z
```

## Required Correction Route

Use the smallest governed route that makes lifecycle planner validator execution
use a Bash runtime compatible with repository assurance scripts, or makes the
affected validator contract portable without weakening validation.

Acceptable correction paths:

- If local lifecycle policy already defines a Bash runtime override, route this
  as operator/runtime configuration and rerun route discovery with that override
  bound.
- If the lifecycle contract is too environment-dependent, create or link a
  narrow proposal that updates proposal lifecycle validator dispatch to resolve
  the supported Bash runtime consistently before executing gate validators.
- If validator portability is the intended local standard, create or link a
  narrow proposal that removes Bash 4-only constructs from the affected
  lifecycle gate validators without weakening checks.

Do not patch the parent program registry, child packets, child evidence,
generated outputs, or archive metadata to work around this blocker.

## Acceptance Criteria

The correction is complete only when all of the following pass from fresh
preflight:

```sh
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --skip-registry-check
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --run-registry-check
/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh --target .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --lifecycle proposal-program --format yaml
.octon/framework/engine/runtime/run lifecycle plan --lifecycle proposal-program --target .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy
```

The final lifecycle plan must report:

```yaml
program_route:
  route_id: archive-proposal
program_blockers: []
approval_blockers: []
final_verdict: route-ready
```

## Boundaries

- Do not execute parent archive from this correction route.
- Do not mutate child packets.
- Do not recreate child evidence.
- Do not use parent evidence to satisfy child-owned evidence.
- Do not hand-edit generated outputs.
- Refresh generated outputs only through canonical generators if validators
  require it after the correction.
- Do not perform cleanup, deletion, branch cleanup, landing, publication, push,
  PR creation, or any `cleaned` claim.
