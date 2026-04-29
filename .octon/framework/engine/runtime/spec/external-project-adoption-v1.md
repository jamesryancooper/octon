# External Project Adoption v1

This contract defines how Octon may initialize or reconcile Octon surfaces in
an external repository. It is a local preflight and initialization path, not a
state-copy path.

## Required Sequence

1. Inspect the target project and assign an Octon Compatibility Profile.
2. Detect whether `.octon/` is absent, partial, stale, conflicting, or valid.
3. Install or verify portable `framework/**` material only.
4. Initialize repo-specific `instance/**` authority locally.
5. Create or reconcile the workspace charter.
6. Initialize ingress and bootstrap surfaces.
7. Initialize governance and support-target posture.
8. Initialize `state/control/**`, `state/evidence/**`, and
   `state/continuity/**` in the target repo.
9. Rebuild `generated/**` locally.
10. Run bootstrap and doctor checks.
11. Assign the compatibility profile.
12. Defer federation membership until local compatibility and trust gates pass.

## Forbidden Shortcuts

- Blind full `.octon/` copy from another repository.
- Copying `instance/**` as repo-local authority.
- Copying `state/**` as current operational truth.
- Copying `generated/**` as source truth.
- Treating partial, stale, or conflicting `.octon/` topology as
  Octon-enabled.

`octon adopt <repo>` records local preflight evidence only. It does not mutate
the external repo and does not authorize material execution.
