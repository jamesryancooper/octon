---
source_id: SRC-005
source_type: conversation-turn
sequence: 5
supplied_at: "2026-06-20T16:56:40.000Z"
turn_id: "019ee5f6-8cc8-7c82-9290-69b2e84fb09d"
capture_status: complete
disclosure_status: local-only
authority_mode: non-authoritative
---

# SRC-005: Architecture fit-for-purpose question

## User Message

> Is Octon’s current architecture fit for its intended purpose, and does its structure support the public, portable, governed distribution model we are trying to create?

Architecture-review:

> Assess whether Octon’s current architecture, repository structure, authority boundaries, and publication model are fit for purpose. Specifically, determine where the current design supports or conflicts with the goal of producing a portable public Octon distribution while keeping repo-specific inputs, instance authority, runtime state, generated outputs, evidence, and host projections out of the public surface.

Answer:

> Does Octon’s current architecture align with the intended public distribution model, or are there structural boundaries that need to be clarified, narrowed, or redesigned before publication?


## Assistant Message 1 (commentary)

I’ll use the `audit-domain-architecture` skill because this is explicitly an architecture fitness review. I’ll keep this read-only and focus on the public distribution boundary, not on judging local content as publishable.

## Assistant Message 2 (commentary)

The skill’s contract is read-only in intent, but it normally writes audit receipts. I’m not going to write those here because your publication-boundary work has consistently required no mutation; I’ll apply the review structure directly in the response.

## Assistant Message 3 (commentary)

I’m going to re-check the live repository shape and the distribution-related manifests so the answer is grounded in current files, not just the prior boundary discussion.

## Assistant Message 4 (final_answer)

**Short Answer**

Octon is partly aligned with the intended public distribution model, but it is not publication-ready as structured today.

The core architecture has the right conceptual boundaries: `framework` is portable, `instance` is repo authority, `state` is runtime/evidence, `generated` is derived, and `inputs` are non-authoritative raw/advisory material. The problem is that the repository and release mechanics do not yet enforce a public distribution boundary. A public push of this repo would be structurally unsafe.

Target mode: observed for the current repo; prospective for `portable_dropin`, because that profile does not yet exist.

**Current Surface Map**

| Surface | Current role | Public distribution fitness |
|---|---|---|
| [.octon/framework/**](/Users/jamesryancooper/Projects/octon/.octon/README.md:33) | Portable authored Octon core | Architecturally fit, but needs license/provenance/security clearance |
| [.octon/instance/**](/Users/jamesryancooper/Projects/octon/.octon/README.md:34) | Repo-specific durable authority | Must be excluded except neutral templates |
| [.octon/state/**](/Users/jamesryancooper/Projects/octon/.octon/README.md:35) | Mutable control, continuity, retained evidence | Must be excluded |
| [.octon/generated/**](/Users/jamesryancooper/Projects/octon/.octon/README.md:36) | Rebuildable effective outputs/read models | Must be excluded and rebuilt in target repos |
| [.octon/inputs/**](/Users/jamesryancooper/Projects/octon/.octon/framework/cognition/_meta/architecture/inputs/README.md:3) | Raw/non-authoritative inputs | Must be excluded by default |
| `.codex/**`, `.claude/**`, `.cursor/**` | Local host projections | Must be excluded except reviewed templates |
| [.github/workflows/release-please.yml](/Users/jamesryancooper/Projects/octon/.github/workflows/release-please.yml:100) | Local release automation | Not fit for public distribution as-is |

Tracked local-publication risk is high: this repo currently tracks thousands of files under excluded surfaces, including `.octon/state` and `.octon/inputs`.

**What Fits**

The class-root model is strong. [.octon/README.md](/Users/jamesryancooper/Projects/octon/.octon/README.md:29) clearly separates portable framework material from repo-local authority, runtime state, generated outputs, and inputs.

The input boundary is also directionally correct. The inputs architecture says `inputs/**` is raw source material and is never runtime, policy, generated, state/control, publication, retained evidence, or host-projection authority.

The evidence model supports safe publication in principle. The evidence tier contract explicitly forbids raw-copy promotion into publishable surfaces and says generated read models cannot become retained evidence.

The scaffolding runtime is the right architectural mechanism for public distribution: ship neutral bootstrap machinery, then let first init create target-local `instance`, `state`, `generated`, evidence roots, and projections.

**What Conflicts**

Finding A1: No explicit public distribution profile exists.

Current profiles are not the right boundary. [bootstrap_core](/Users/jamesryancooper/Projects/octon/.octon/octon.yml:34) is closest but still includes live `instance/manifest.yml`. [repo_snapshot](/Users/jamesryancooper/Projects/octon/.octon/octon.yml:39) includes local `instance/**`. [pack_bundle](/Users/jamesryancooper/Projects/octon/.octon/octon.yml:49) is extension-specific. None means “reviewed portable public artifact only.”

Finding A2: Release automation conflicts with the desired public model.

The current release workflow refreshes and stages `.octon/generated/effective/**`, `.octon/state/control/**`, and `.octon/state/evidence/**` paths during release. That is appropriate for an internal governed repo, but unsafe as a public distribution pipeline.

Finding A3: Template boundary is incomplete.

The base Octon template manifest declares required files like `README.md`, `AGENTS.md`, `octon.yml`, `framework/manifest.yml`, and `instance/manifest.yml`, but those files are currently missing under the template root. That makes the intended “generate target-local surfaces from neutral templates” path under-specified.

Finding A4: Framework is portable by role, not automatically publication-cleared.

The architecture correctly places framework material in the portable root, but executable/runtime assets, prompts, skills, schemas, test fixtures, examples, and docs still need publication clearance before first release.

Finding A5: Host projections are not isolated from distribution.

The repo tracks `.codex`, `.claude`, and `.cursor` projection surfaces. These may be useful locally, but they should not be copied into a public Octon distribution except as reviewed templates or generated target-local outputs.

**Fit Verdict**

Octon’s architecture is conceptually fit for the public portable model, but its current repository structure and publication mechanics are not yet mechanically fit.

Before publication, the boundary must be clarified and enforced with:

- a new `portable_dropin` profile
- an allowlist export script
- denylist validation for local roots
- repaired neutral bootstrap templates
- a separate public distribution repository
- CI/pre-push gates that reject local `inputs`, `instance`, `state`, `generated`, evidence, and host projections

**Keep As-Is**

Keep the class-root model. It is the strongest part of the architecture.

Keep `bootstrap_core` as internal implementation machinery, but stop presenting it as the public boundary.

Keep `pack_bundle` separate for reviewed extension packs. Do not include additive packs in base Octon.

Keep generated/evidence publication rules for the development repo, but do not reuse that release workflow for the public mirror.

**Required Redesign Before Publication**

The missing structural piece is not a new conceptual taxonomy; it is an enforced export boundary.

Recommended shape:

```text
full development repo
  framework + local inputs + instance + state + generated + evidence + projections
        |
        | portable_dropin allowlist export
        v
generated artifact
  publication-cleared framework + neutral bootstrap/templates only
        |
        v
separate public distribution repo
```

**Final Answer**

Octon aligns at the architectural-concept level, but not yet at the repository/publication-mechanics level. The structural boundaries are clear enough to support the intended model, but they must be narrowed and made enforceable before publication. The public distribution should be generated from reviewed `framework` and bootstrap templates only; it should not be a clone, branch, release workflow output, or GitHub mirror of this current workspace.

