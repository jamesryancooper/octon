# Validation

Success means:

- `pack.yml` exposes `prompts/` when the bundle is added
- the bundle manifest uses `octon-extension-prompt-set-v1`
- the bundle manifest declares a non-empty `companions` sequence
- the manifest path entries resolve to files created in the bundle
- no shared references or routing contract are introduced in MVP
- rerunning is idempotent
- conflicting content blocks the scaffold
