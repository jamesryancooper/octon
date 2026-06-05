# Cleanup Lifecycle Residue Bundle Contract

- Route id: `cleanup-lifecycle-residue`.
- Command id: `octon-proposal-cleanup-lifecycle-residue`.
- Skill and prompt set id: `octon-proposal-lifecycle-cleanup-lifecycle-residue`.
- Receipt id: `lifecycle-residue-cleanup`.
- Receipt path: `support/lifecycle-residue-cleanup.md`.

The route may classify lifecycle residue and delegate eligible local run-state
cleanup to `repo-hygiene-cleanup`. It must not delete from helper
classification alone, must not call the helper's mutation modes directly, and
must not auto-clean foreign, ambiguous, protected, referenced, manual-review,
user-owned, or active implementation artifacts.

Do not invoke the helper with `--confirm`, `--authorize`, or `--authorization`
from this route; those mutation modes belong to `repo-hygiene-cleanup` and its
validating `repo-hygiene-cleanup-authorization-v1` receipt path.
