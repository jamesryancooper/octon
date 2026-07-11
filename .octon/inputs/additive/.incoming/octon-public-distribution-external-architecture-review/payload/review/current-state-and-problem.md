---
disclosure_status: externally-shareable-after-maintainer-review
authority_mode: non-authoritative
external_transmission_approved: false
---

# Current State And Problem

## Architecture That Already Aligns

**Confirmed repository evidence:** The shared-foundation model defines:

- `.octon/framework/**` as portable authored core;
- `.octon/instance/**` as repository-specific durable authored authority;
- `.octon/inputs/**` as non-authoritative additive or exploratory input;
- `.octon/state/**` as mutable control, continuity, and retained evidence;
- `.octon/generated/**` as rebuildable derived output.

Evidence:
`.octon/framework/cognition/_meta/architecture/shared-foundation.md` and
`.octon/README.md`.

## Implementation Gaps To Verify

1. **Profiles:** `.octon/octon.yml` currently defines
   `bootstrap_core`, `repo_snapshot`, `pack_bundle`, and
   `full_fidelity`, but no `portable_dropin`.
2. **Exporter:** `export-harness.sh` copies workspace paths and its
   `repo_snapshot` path invokes publication-state writers before export.
3. **Scope:** `repo_snapshot` includes live `instance/**` and enabled pack
   closure, which violates the public base boundary.
4. **Bootstrap:** the current starter tree and manifest require neutrality and
   completeness review; the primary initializer is Bash-based and is not a
   proven Windows Tier 1 path.
5. **Downstream delivery:** repository search found no exact core lock,
   verified artifact resolver, transactional updater, interrupted-update
   recovery, or core rollback implementation.
6. **Evidence semantics:** `write-run.sh` contains synthetic immutable-style
   locators and run-identifier-derived digest text that must not be represented
   as real external immutable storage.
7. **Release path:** the current workspace release workflow references
   `AUTONOMY_PAT`, pushes generated effective state, and operates on workspace
   history.
8. **Hosted churn:** the reviewed commit tracks approximately 40,112 state
   files, 1,871 generated files, 5,748 input files, and hundreds of files in
   each host-projection root.
9. **Publication clearance:** no complete framework component, license,
   provenance, sensitivity, or publication-clearance model has yet been
   implemented.

## Why This Matters

- Architectural role does not establish publication safety.
- Non-authority does not establish confidentiality or redistribution rights.
- Generated output can reproduce sensitive source material.
- Git ignore cannot prevent an explicitly added, previously tracked, generated,
  copied, or release-packaged file from becoming public.
- Workspace history can retain excluded content even when the current tree is
  later cleaned.

Sources: `SRC-001`, `SRC-002`, `SRC-003`, `SRC-009`,
`SRC-010`, `SRC-011`, `SRC-015`, and `SRC-018`.

