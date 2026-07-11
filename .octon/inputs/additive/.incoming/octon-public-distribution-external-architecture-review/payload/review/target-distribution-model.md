---
disclosure_status: externally-shareable-after-maintainer-review
authority_mode: non-authoritative
external_transmission_approved: false
---

# Target Distribution Model

## Target

**Sponsor decision:** Public Octon is a generated distribution, not a public
copy of the development workspace.

The target flow is:

1. Resolve an exact private-workspace Git commit.
2. Select the smallest dependency-closed set of cleared portable components.
3. Materialize only allowlisted tracked blobs into an empty staging directory.
4. Apply invariant denylist checks.
5. Emit a canonical file manifest and aggregate digest.
6. Add only reviewed public-repository-only files.
7. Prove the candidate public tree exactly matches the manifest.
8. Update a separate public checkout with synthetic history.
9. Build release candidates from the public repository commit.
10. Require one deliberate maintainer action to publish the exact commit,
    version, and manifest digest.

## Included By Role And Clearance

- publication-cleared portable framework component closure;
- neutral bootstrap templates;
- required wrappers and runtime binaries;
- license and required notice files;
- public-repository-only security, contribution, identity, CI, and release
  files.

## Excluded By Default

- live `.octon/instance/**`;
- all project or workspace `.octon/inputs/**`;
- `.octon/state/**` and raw evidence;
- `.octon/generated/**`;
- `.codex/**`, `.claude/**`, and `.cursor/**` projections;
- additive packs;
- logs, caches, reports, proposal lineage, archives, scratch files, and local
  residue;
- workspace Git history.

## Existing Profiles

- `bootstrap_core`: retained for internal bootstrap semantics, not public
  publication.
- `repo_snapshot`: contains repository-specific material and is too broad.
- `pack_bundle`: exports extension packs, while the base ships zero packs.
- `full_fidelity`: clone-oriented and therefore incompatible with synthetic
  public history.

Sources: `SRC-003`, `SRC-004`, `SRC-009`, `SRC-014`,
`SRC-015`, and `SRC-018`.

