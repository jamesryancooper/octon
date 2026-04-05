# Release Disclosure

`state/evidence/disclosure/releases/**` stores canonical retained HarnessCards
for support, benchmark, and release claims.

Each retained disclosure packet uses a release-local directory:

`state/evidence/disclosure/releases/<release-id>/harness-card.yml`

Use `/.octon/instance/governance/disclosure/release-lineage.yml` to determine
which retained release is the active live claim. Older release bundles remain
historical evidence unless the lineage file marks them active.
