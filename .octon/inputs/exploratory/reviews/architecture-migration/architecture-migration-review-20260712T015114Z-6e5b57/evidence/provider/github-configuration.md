# GitHub Provider Configuration Observation

Observed read-only for jamesryancooper/octon on 2026-07-11/12. No provider
state or secret value was mutated or retrieved.

## Repository

- Visibility: public.
- Default branch: main.
- Reviewed main SHA: c5b1f5760c78ff521cca6b054e4e8fef5300505b.
- Squash merge: enabled.
- Auto-merge: enabled.
- Merge commit and rebase merge: disabled.
- Delete branch on merge: enabled.
- Current authenticated user has admin/push capability metadata.

## Ruleset

Active ruleset 12881449, Main Branch Guardrails (Change Route + CI):

- applies to default branch;
- no bypass actors; current user cannot bypass;
- deletion restricted;
- non-fast-forward restricted;
- linear history required;
- no pull-request rule;
- four strict required checks through GitHub Actions integration 15368:
  - route_neutral_closeout_validation
  - branch_naming_validation
  - route_aware_autonomy_validation
  - exact_source_sha_validation

Classic protection metadata did not require signed commits, administrator
enforcement, or conversation resolution. Ruleset enforcement remains the
material default-branch protection observed.

## Actions and secrets metadata

- Actions enabled; allowed_actions is all.
- Action SHA pinning is not provider-required.
- Default workflow token permission is read; workflows may approve PR reviews.
- Variables include AUTONOMY_AUTO_MERGE_ENABLED=true,
  AI_GATE_ENFORCE=true, and AUTONOMY_POLICY_ENFORCE=true.
- Repository secret names include ANTHROPIC_API_KEY, AUTONOMY_PAT, and
  OPENAI_API_KEY. Values were not read.
- Preview and Production environments had no protection rules and allowed
  administrator bypass.
- Dependabot security updates, secret scanning, and push protection were
  observed disabled.

## Required-check identity observation

The four required contexts are produced by candidate-repository workflow code.
At the reviewed SHA, provider runs included a failing branch_naming_validation
instance on a source-branch run and a successful instance on a main-push run.
This demonstrates that context name alone does not uniquely bind workflow
identity/event. It does not prove an actual ruleset bypass.

## Security relevance

The ruleset's no-bypass, fast-forward, deletion, and strict-check controls are
valuable and should be preserved. The verifier producing the required checks
must be made candidate-immutable. The current pr-auto-merge lane is unsafe
because pull_request_target obtains write permissions, later checks out PR
head, and executes candidate scripts/kernel while a token remains available.

## API surfaces queried

- GET /repos/jamesryancooper/octon
- GET /repos/jamesryancooper/octon/rules/branches/main
- GET /repos/jamesryancooper/octon/rulesets
- GET /repos/jamesryancooper/octon/rulesets/12881449
- GET /repos/jamesryancooper/octon/branches/main/protection
- GET /repos/jamesryancooper/octon/actions/permissions
- GET /repos/jamesryancooper/octon/actions/permissions/workflow
- GET /repos/jamesryancooper/octon/actions/secrets
- GET /repos/jamesryancooper/octon/actions/variables
- GET /repos/jamesryancooper/octon/environments
- workflow runs and check-runs for the reviewed SHA

Classification: PROVIDER_OBSERVED. Point-in-time only.

