# Acceptance Criteria

- Terminal proof can be emitted without source-branch commits after landing.
- Terminal proof distinguishes landed ref from proof sink state.
- Missing landing, sync, cleanup, authorization, or validation proof blocks
  terminal success claims.
- Terminal proof does not mutate origin/main or the landed source ref.
- Parent evidence does not satisfy child terminal proof evidence.
