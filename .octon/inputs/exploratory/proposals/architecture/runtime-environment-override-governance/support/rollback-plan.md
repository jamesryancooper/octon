# Rollback Plan

- **Profile:** atomic (`proposal.yml#change_profile`). The accepted change set
  lands as one revertible unit.
- **Rollback action:** git revert of the landed change set. No data
  migration, no state/control mutation, no generated republication is part of
  the change, so revert is complete rollback.
- **Post-rollback verification:** (1) route-bundle publication succeeds on the
  publication path (the bootstrap case must not be stranded by revert);
  (2) existing assurance validators pass; (3) the env-override invariance
  negative control is removed or expected-fail-annotated in the same revert so
  the assurance plane stays green-meaningful.
- **Rollback trigger examples:** publication bootstrap breaks in a way the
  explicit input cannot serve; protected-mode workflows fail on removed
  role/intent defaults; negative control reveals an unconverted dependency.
  The migration-specific rollback conditions (including deprecation-phase
  discoveries of load-bearing external usage) are defined in
  `architecture/operational-flexibility-and-migration.md` §3.
- **Posture note:** rollback restores the pre-decision state including the
  ungoverned ambient surface; F-01 reopens and the packet returns to revision
  rather than silently closing.
