---
source_id: SRC-009
source_type: conversation-turn
sequence: 9
supplied_at: "2026-07-09T18:05:35.000Z"
turn_id: "019f480e-7829-7eb1-93df-a5cbd1267f4f"
capture_status: complete
disclosure_status: local-only
authority_mode: non-authoritative
---

# SRC-009: Architecture review and finalization brief

## User Message

# Octon Public Distribution Architecture Review and Finalization

Act as a principal Octon architecture, security-boundary, and release engineering reviewer.

## Objective

Review the complete conversation thread, all attached prior conversations, and the relevant repository evidence. Then evaluate, challenge, finalize, and translate the proposed Octon Public Distribution Model into an implementation-ready architecture plan.

Do not merely summarize earlier conclusions. Independently verify implementation-critical claims, identify conflicts or unsupported assumptions, and determine whether the proposed model is coherent, secure, enforceable, and fit for purpose.

## Conversation Attachments

I will provide each relevant prior conversation as an attachment.

Treat these attachments as review inputs and planning history, not as unquestioned authority. For each attachment:

- Extract findings, decisions, recommendations, assumptions, risks, and unresolved questions.
- Distinguish confirmed repository evidence from conversational interpretation.
- Identify contradictions between conversations.
- Verify implementation-critical claims against the current repository.
- Prefer repository evidence when it conflicts with a conversational claim, while identifying whether the repository itself needs to change.
- Avoid quoting or exposing sensitive content; summarize or redact it where appropriate.
- Produce a consolidated decision record so important context is not lost between conversations.

## Established Direction

Treat the following as sponsor decisions unless repository evidence demonstrates that they are infeasible or internally contradictory:

- The current repository remains the full development and workspace repository.
- Public Octon will live in a separate public distribution repository.
- The public repository will be populated only from a generated, allowlist-based `portable_dropin` artifact.
- The public repository is a distribution mirror, not a clone or mirror of the full workspace repository.
- `bootstrap_core` remains an internal bootstrap profile and is not the public release boundary.
- `repo_snapshot`, `pack_bundle`, and `full_fidelity` are not suitable public base-distribution boundaries.
- The base public distribution ships with zero additive packs.
- All `.octon/framework/**` material requires license, provenance, sensitivity, and publication-clearance review before first publication.
- Live repository-specific inputs, instance authority, runtime state, generated outputs, evidence, host projections, logs, reports, archives, and local residue must not enter the public artifact.
- Initialization in a target repository should create target-local instance authority, state, evidence roots, generated outputs, and host projections from reviewed neutral templates.

## Architectural Distinctions

Keep these boundaries explicit throughout the review:

- Architectural authority is not the same as publication safety.
- Non-authoritative material is not automatically safe to publish.
- Portable-by-role material is not automatically publication-cleared.
- “May contain sensitive information” is not the same as “proprietary by definition.”
- Generated material may reproduce or transform sensitive source material.
- Git ignore rules are hygiene controls, not a complete publication boundary.

## Repository Evidence to Review

Prioritize these surfaces:

- `.octon/octon.yml`
- `.octon/README.md`
- `.octon/framework/**`
- `.octon/framework/scaffolding/runtime/**`
- `.octon/framework/scaffolding/runtime/templates/octon/**`
- `.octon/framework/cognition/_meta/architecture/inputs/README.md`
- `.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml`
- `.gitignore`
- `.github/workflows/release-please.yml`
- `.codex/**`, `.claude/**`, and `.cursor/**`

Inspect other paths only when necessary to validate a boundary, dependency, projection, or leak path.

## Required Evaluation

1. Determine whether Octon’s current class-root architecture supports the proposed public distribution model.
2. Identify where current structure, naming, profiles, templates, workflows, or Git behavior conflict with that model.
3. Classify repository surfaces as:
   - portable framework source
   - neutral bootstrap or scaffolding template
   - repository-specific authored authority
   - raw or exploratory input
   - runtime or control state
   - retained evidence
   - generated or effective output
   - host projection
   - additive extension source
   - local-only residue
4. Define the exact semantics of `portable_dropin`, including its allowlist, denylist, output structure, initialization behavior, and invariants.
5. Determine whether the existing bootstrap templates are complete and neutral enough to support a new installation.
6. Define how the private workspace repository produces and updates the separate public repository without exposing excluded material.
7. Specify the controls required before the first release and for every later publication.
8. Convert all confirmed gaps into an ordered, implementation-ready plan with dependencies and measurable acceptance criteria.

## Required Deliverables

Provide:

1. A concise architectural verdict: aligned, partly aligned, or misaligned.
2. A consolidated decision record from the conversation attachments.
3. A current-state versus target-state boundary model.
4. A definitive public artifact allowlist.
5. An explicit denylist with rationale.
6. A normative specification for the `portable_dropin` profile.
7. A comparison explaining why existing profiles are insufficient.
8. A phased implementation plan with file-level work areas, dependencies, and acceptance criteria.
9. Required export, validation, CI, pre-push, and publication gates.
10. A framework-wide license, provenance, sensitivity, and publication-review plan.
11. Key leak paths, failure modes, and rollback considerations.
12. Open questions requiring sponsor or maintainer decisions.
13. Recommended policy wording for repository documentation.

Label conclusions as one of:

- **Confirmed evidence**
- **Sponsor decision**
- **Recommendation**
- **Assumption**
- **Open question**

## Minimum Publication Gates

At minimum, evaluate and specify:

- Allowlist-only export from a clean staging directory
- Denylisted-path detection
- Template completeness and neutrality checks
- Secret and sensitive-content scanning
- License and provenance clearance
- Executable, script, Rust, WASM, and runtime-asset review
- Generated-output provenance or taint checks
- Evidence-disclosure classification
- Host-projection exclusion
- Public-repository content and diff validation
- CI rejection of excluded roots
- Protected publication credentials and release authorization
- Pre-push protection against targeting a public remote from the workspace repository

## Constraints

- Begin read-only.
- Do not modify, promote, publish, install, archive, delete, or rewrite files.
- Do not inspect `.octon/inputs/exploratory/ideation/**` beyond filenames, boundary documentation, and minimal metadata.
- Do not expose sensitive contents in the report.
- Do not make legal or intellectual-property conclusions without explicit evidence.
- Do not treat current repository behavior as correct merely because it exists.
- Do not treat prior conversational recommendations as confirmed until verified.
- Do not propose publishing this full workspace repository.

The final result must be sufficiently precise that an implementation engineer can turn it into tracked work without needing to reconstruct the architectural intent from the original conversations.

## Assistant Message 1 (commentary)

I’m using the `audit-domain-architecture` skill because this is a bounded, evidence-backed architecture critique. I’ll first load its audit contract and Octon’s canonical repository instructions, then verify the profile, template, publication, and projection boundaries without reading ideation content or changing files.

## Assistant Message 2 (commentary)

The skill’s audit contract requires fixed lenses, path-level evidence, stable findings, acceptance criteria, a self-challenge pass, and explicit coverage accounting. Because your constraint is strictly read-only, I’ll produce that structure in the response but will not write the skill’s usual evidence receipts into `.octon/state/**`.

## Assistant Message 3 (commentary)

I’m treating the audit target as the observed cross-domain publication boundary (`.octon/**` plus release and host-projection surfaces), using a deep evidence pass. The governing files will be assessed as architectural evidence rather than presumed correct; next I’m binding the repository’s mandatory context and then mapping the actual current tree.

## Assistant Message 4 (commentary)

The repository’s own doctrine strongly supports the five-class authority separation, but that is only one half of the question. I’m now checking the physical Git/publication surfaces and the bootstrap implementation, where a sound conceptual boundary can still fail operationally.

## Assistant Message 5 (commentary)

The current tree confirms an important distinction: the class-root model is conceptually strong, while the shipped scaffold still contains live-looking `state/**`, `generated/**`, input, and legacy path material. I’ll complete the review in five passes:

1. Verify profile and class-root semantics.
2. Test bootstrap/template completeness, neutrality, and path consistency.
3. Trace Git, workflow, host-projection, and public-remote leak paths.
4. Inventory framework publication-clearance obligations without inspecting sensitive content.
5. Self-challenge findings and convert confirmed gaps into sequenced work with acceptance criteria.

## Assistant Message 6 (commentary)

The bootstrap review has surfaced two concrete implementation problems, not just policy gaps: the base template manifest names required root files that are absent, and the canonical initializer’s default path calculation appears to resolve the repository root as the existing `.octon/` directory. I’m validating both statically before assigning severity.

## Assistant Message 7 (commentary)

The next risk is transport, not authority: what Git and CI can physically copy or commit. I’m checking tracked-volume exposure, ignore exceptions, release automation, host projections, and whether any public-remote push guard exists; I will report only classifications and paths, not sensitive payloads or remote URLs.

## Assistant Message 8 (commentary)

The transport review confirms the highest-risk leak path: the existing exporter copies the working-tree `framework/` directory recursively. This checkout currently contains roughly 29,000 ignored framework files, including a large Rust build tree and nested local evidence, so ignore rules do not protect an export. The public builder must extract only reviewed files from a pinned Git tree, never `cp -R` the workspace.

## Assistant Message 9 (commentary)

Framework is a candidate public product surface, not a cleared one. The current tree has no repository-level `LICENSE`, `NOTICE`, or publication-clearance ledger; it also contains native binaries, WASM modules, hundreds of executable scripts, fixtures, prompts, skills, schemas, and a dependency-review workflow that covers only the main Rust workspace. That makes framework clearance a first-release blocking workstream, exactly as the sponsor direction anticipates.

## Assistant Message 10 (commentary)

The self-challenge pass upheld the main findings with one important qualification: tracked or sensitive-looking local surfaces do not prove a public leak by themselves. The release blocker is that no enforced artifact boundary exists yet, while the available exporter and templates are unsafe to reuse unchanged. I’m doing a final worktree sanity check, then I’ll provide the decision record, normative profile, gates, and phased file-level plan.

## Assistant Message 11 (final_answer)

## Architectural Verdict

**Confirmed evidence:** **Partly aligned, but publication-blocked.** Octon’s five-class architecture provides a strong conceptual basis for portable distribution: framework is portable authored material; instance is repository-specific authority; state is operational truth/evidence; generated is derived; inputs are non-authoritative source material. This is explicit in [.octon/README.md](/Users/jamesryancooper/Projects/octon/.octon/README.md:29) and the [architecture registry](/Users/jamesryancooper/Projects/octon/.octon/framework/cognition/_meta/architecture/contract-registry.yml:22).

The operational release boundary does not yet implement that architecture. There is no `portable_dropin` profile, existing validators reject additional profile names, the current exporter copies working-tree directories, and the bootstrap template is incomplete and not neutral. Octon should not be published through the current workspace or existing export workflow.

No reviewed surface is “proprietary by definition.” The report identifies publication and sensitivity risk, not legal ownership.

## Decision Record

| Status | Consolidated decision |
|---|---|
| **Sponsor decision** | Keep this repository as the private/full workspace repository. |
| **Sponsor decision** | Populate a separate public repository only from a generated `portable_dropin` artifact. |
| **Sponsor decision** | Public history must be synthetic artifact history, never cloned, mirrored, subtree-split, or pushed from workspace history. |
| **Sponsor decision** | Retain `bootstrap_core` internally; do not use it, `repo_snapshot`, `pack_bundle`, or `full_fidelity` as the public boundary. |
| **Sponsor decision** | Ship zero additive extension packs in the base distribution. |
| **Sponsor decision** | Exclude live instance, inputs, state, generated output, evidence, host projections, logs, reports, archives, and residue. |
| **Sponsor decision** | Require framework-wide license, provenance, sensitivity, and publication review before first release. |
| **Recommendation** | Treat `framework/**` as the candidate set, not an automatic allowlist. Every exported path must also have current clearance. |

## Critical Findings

| ID | Severity | Gap, evidence, and acceptance criterion |
|---|---|---|
| PD-001 | Critical | No public profile exists. Only four profiles are declared in [octon.yml](/Users/jamesryancooper/Projects/octon/.octon/octon.yml:33), and the [validator](/Users/jamesryancooper/Projects/octon/.octon/framework/assurance/runtime/_ops/scripts/validate-root-manifest-profiles.sh:107) rejects any other name. **Done:** `portable_dropin` has schema-backed semantics and positive/negative tests. |
| PD-002 | Critical | The existing exporter uses recursive working-tree copies in [export-harness.sh](/Users/jamesryancooper/Projects/octon/.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh:91) and refreshes source-repository publication state at [line 157](/Users/jamesryancooper/Projects/octon/.octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh:157). The current framework tree contains about 29,000 ignored files, including build and nested evidence residue. **Done:** export only blobs from a pinned Git commit, with zero source-worktree mutation. |
| PD-003 | High | All five files declared required by the [base template manifest](/Users/jamesryancooper/Projects/octon/.octon/framework/scaffolding/runtime/templates/octon/manifest.json:8) are absent; 19 of 52 described content files are absent. The template also contains legacy top-level roots and published-looking state/generated placeholders. **Done:** clean-target installation test proves a complete, neutral, five-class result. |
| PD-004 | High | The initializer’s default path resolves `OCTON_DIR` to `framework` at [init-project.sh](/Users/jamesryancooper/Projects/octon/.octon/framework/scaffolding/runtime/bootstrap/init-project.sh:4), then derives output paths from the wrong default root at [line 105](/Users/jamesryancooper/Projects/octon/.octon/framework/scaffolding/runtime/bootstrap/init-project.sh:105). It also does not create the complete target-local topology. **Done:** default and explicit-root tests pass idempotently on empty fixture projects. |
| PD-005 | Critical | No repository-level `LICENSE`, `NOTICE`, or publication-clearance ledger was found. The Rust workspace declares a package license expression in [Cargo.toml](/Users/jamesryancooper/Projects/octon/.octon/framework/engine/runtime/crates/Cargo.toml:19), but that does not establish clearance for the whole framework. **Done:** every candidate path is cleared or denied and required license/notice material exists. |
| PD-006 | High | The current [release workflow](/Users/jamesryancooper/Projects/octon/.github/workflows/release-please.yml:100) commits generated, control, and evidence paths and pushes with a workspace credential. It is a workspace release workflow, not a public export pipeline. **Done:** a dedicated, isolated public-distribution workflow replaces it for public publication. |
| PD-007 | High | Inputs, instance, state, generated outputs, and host projections are heavily Git-tracked. Host projection generation reads effective routing and extension publication outputs in [publish-host-projections.sh](/Users/jamesryancooper/Projects/octon/.octon/framework/capabilities/_ops/scripts/publish-host-projections.sh:17). **Done:** artifact and public-repository CI reject every excluded root. |
| PD-008 | Medium | “Publication” currently primarily denotes generated-effective runtime publication in the [architecture registry](/Users/jamesryancooper/Projects/octon/.octon/framework/cognition/_meta/architecture/contract-registry.yml:1476), which can be confused with external public distribution. **Done:** documentation distinguishes `runtime_effective_publication` from `public_distribution`. |
| PD-009 | Medium | No executable local pre-push hook or configured hooks path was present. Server-side repository controls were not inspected. **Done:** workspace-to-public-remote rejection plus protected public-repository rules are verified. |

## Boundary Model

```text
Current
full workspace + local residue
    -> bootstrap_core / repo_snapshot / pack_bundle
    -> working-tree directory copy or normal Git clone
    -> workspace release workflow
    -> generated, control, evidence, and history exposure risk

Target
pinned private-workspace commit
    + private publication policy and clearance ledger
    -> isolated empty staging directory
    -> fixed allowlist intersected with current clearance
    -> denylist, content, provenance, and bootstrap gates
    -> signed portable_dropin artifact
    -> synthetic commit in separate public repository
    -> target init creates local instance/inputs/state/generated/projections
```

## Artifact Contract

**Recommendation:** The initial supported payload should be:

```text
.octon/
  README.md
  octon.yml
  framework/**        # only tracked, publication-cleared paths
```

The public-repository envelope may additionally contain reviewed `README.md`, license/notice/security documents, one distribution-validation workflow, and deterministic `portable-dropin.manifest.json`, checksums, SBOM, and provenance attestations.

**Definitive denylist:** Everything not explicitly allowed, including `.git/**`, `.octon/AGENTS.md`, `.octon/instance/**`, `.octon/inputs/**`, `.octon/state/**`, `.octon/generated/**`, unknown `.octon/*` roots, `.codex/**`, `.claude/**`, `.cursor/**`, current workspace `.github/**`, root adapters, workspace release metadata, untracked or ignored files, caches, unsafe symlinks, and unclassified executable/binary content.

Neutral template source under `framework/scaffolding/runtime/**` remains eligible only after repair and clearance. No pre-populated “published” state or generated-effective file may be installed.

## `portable_dropin` Semantics

**Recommendation:**

- Source basis: one immutable, preferably signed workspace commit.
- Candidate source: `.octon/{octon.yml,README.md}` plus cleared `.octon/framework/**`.
- Precedence: deny rules override includes; missing classification fails closed.
- Extraction: use Git objects from the pinned commit, never filesystem recursion.
- Determinism: identical source commit, profile version, and clearance ledger produce identical file lists and digests.
- Clearance: every output path is bound to an owner, origin/provenance decision, sensitivity decision, publication decision, license posture, and content digest.
- Public metadata: generated only in isolated staging and forbidden from embedding local paths, operator identities, private evidence, or workspace commit messages.
- Initialization: creates a new instance ID, instance authority, zero-pack extension configuration, state/evidence roots, generated outputs, and selected host projections in the target repository.
- Safety: init is collision-aware, idempotent, supports dry-run, and rolls back only files created by the failed invocation.

| Existing profile | Why it is insufficient |
|---|---|
| `bootstrap_core` | Includes live `instance/manifest.yml`, has no public clearance or repository envelope, and is not handled by the exporter. |
| `repo_snapshot` | Includes all local instance authority and enabled packs; its implementation mutates publication state and copies working-tree directories. |
| `pack_bundle` | Transfers additive extension packs only and is deliberately trust-agnostic. |
| `full_fidelity` | Uses a normal clone, including full workspace history and excluded material. |

## Implementation Plan

| Phase | File-level work areas | Dependency and acceptance criterion |
|---|---|---|
| 0. Decisions | `.octon/instance/cognition/decisions/**`; new `instance/governance/publication/**` | Decide public repository identity, license, binary posture, clearance owner, and host defaults. |
| 1. Contract | `.octon/octon.yml`; `framework/product/contracts/**`; architecture registry; README; profile validators/tests | Add normative `portable_dropin`; existing internal profiles retain their roles; unknown profiles still fail. |
| 2. Bootstrap | `framework/scaffolding/runtime/{bootstrap,templates}/**`; `init-project.sh`; `/init` docs and tests | Replace stale template topology, fix root resolution, and prove complete clean installation and idempotency. |
| 3. Clearance | Private clearance ledger; root license/notice sources; Cargo/service manifests; binaries/WASM; prompts, skills, fixtures, schemas, docs | One hundred percent of candidate files are `allow` or `deny`; no `unknown` remains. |
| 4. Export | New dedicated portable exporter/workflow; assurance validators and negative fixtures | Two builds from the same commit are byte-identical; dirty, ignored, denied, tainted, and unclassified fixtures fail. |
| 5. Delivery | New workspace publication workflow; reviewed public-repo templates; public CI; pre-push guard | Private rehearsal mirror exactly matches the artifact manifest; only a scoped GitHub App can update it after approval. |
| 6. Release | Public tree verification, signed tag/assets, installation matrix, incident playbook | All gates pass independently; public tree and release-asset digests match retained private receipts. |

## Required Gates

1. Pinned source commit, clean authorization record, protected release environment.
2. Complete path/digest-bound clearance, license review, third-party notices, SBOM, and dependency review across every Rust workspace.
3. Reproducible clean-directory export with no source-worktree writes.
4. Denylisted-path, unknown-root, unsafe-symlink, special-file, archive, and binary checks.
5. Secret, credential, private-path, sensitive-content, and publication-restriction scanning.
6. Generated-output taint and evidence-disclosure checks; no raw evidence or host projection.
7. Template completeness, neutrality, zero-pack, install, idempotency, and rollback tests.
8. Public-repository full-tree and diff equality against the artifact manifest.
9. Synthetic public commit messages and release notes; no private workspace history or commit subjects.
10. Scoped short-lived publication credentials, human release approval, protected branch/tag rules.
11. Workspace pre-push rejection for the public repository identity.
12. Public CI rejection of excluded roots, manifest drift, missing attestations, or unreviewed executable changes.

`.gitignore` should be tightened for genuine local residue, but remain a hygiene control. The enforceable boundary is the artifact builder plus CI.

## Framework Review

**Confirmed evidence:** The tracked framework currently contains 4,052 files, including 730 shell scripts, 112 Rust files, five WASM modules, two native macOS binaries, hundreds of executable-mode files, and large prompt, skill, template, fixture, test, schema, and documentation surfaces.

**Recommendation:** Review by subsystem and path digest. Native binaries should normally be rebuilt in public CI and released separately with checksums, SBOM, signatures, and source provenance. Prebuilt WASM must either reproduce from the included source or be excluded. New or changed framework files return to `unclassified` automatically.

## Risks and Rollback

- A workspace clone, subtree split, or mirrored ref can expose historical objects even when the current tree is filtered. Never use those mechanisms.
- Broad `framework/**` inclusion can silently publish new files. Clearance intersection must default-deny them.
- Generated outputs can reproduce sensitive input. Require source lineage and taint checks, not only path checks.
- Public receipts, release notes, SBOM metadata, and commit messages can leak local paths or private names.
- Init can damage target repositories if it overwrites existing files. Require preflight, creation manifest, and bounded rollback.
- A public leak is not undone by deleting a file. Revoke exposed credentials first, suspend releases, revert or purge public history under an incident procedure, and verify mirrors and release assets.

## Open Questions

- **Open question:** What repository-level license and third-party notice policy will govern the complete public surface?
- **Open question:** Will v1 ship source-only, reproducibly built WASM, or platform binaries as separate release assets?
- **Open question:** Does v1 publish the complete cleared framework, or should tests/fixtures/developer material be excluded through a proven dependency closure?
- **Open question:** Which host projections should init create by default, and should generation require explicit opt-in?
- **Open question:** What minimal target-local governance and overlay defaults must init create?
- **Open question:** What server-side visibility, branch protection, secret-scanning, and repository-transfer controls already exist?
- **Assumption:** The prior messages visible in this task constitute the supplied conversation record; no separate attachment artifacts were available for independent file-level comparison.

## Recommended Policy

> Public Octon is produced only through the `portable_dropin` profile from a pinned, reviewed workspace commit. The profile exports publication-cleared framework source and reviewed distribution metadata through an allowlist whose deny rules take precedence. It never exports workspace history, local inputs, instance authority, state, generated outputs, evidence, host projections, additive packs, or local residue. The separate public repository contains synthetic artifact history only. Target-local authority, control state, evidence, generated outputs, and host projections are created during initialization.

Audit mode was observed/deep at commit `eff350fcfec641e59665e74544f104f2e5bc6a4d`. Ideation contents were not inspected, no files were modified, and no audit receipts were written because of the read-only constraint.

