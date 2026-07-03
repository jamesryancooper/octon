# Implementation Plan

1. Review closeout-worktree, worktree classifier, cleanup helper, wrapper validator, and cleanup fixtures.
2. Add classifier output fields for disposition-required, preserve-authorized, cleanup-authorized, protected, and foreign residue.
3. Require closeout-worktree reports to bind the classifier fingerprint before cleanup or preservation is accepted.
4. Update cleanup loops to stop and inspect exact blocker evidence when preflight remains blocked.
5. Add fixtures for `.DS_Store`, generated health files, protected state/control residue, foreign tracked changes, and authorized disposable local artifacts.
