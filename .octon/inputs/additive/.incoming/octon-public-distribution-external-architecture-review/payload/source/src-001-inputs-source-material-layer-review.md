---
source_id: SRC-001
source_type: conversation-turn
sequence: 1
supplied_at: "2026-06-20T15:50:24.000Z"
turn_id: "019ee5b9-dfe9-7b33-8328-6d46af1dc158"
capture_status: complete
disclosure_status: local-only
authority_mode: non-authoritative
---

# SRC-001: Inputs source-material and authority review

## User Message

Act as a principal Octon architecture reviewer.

Assess the claim that `.octon/inputs/**` is the repo-specific source-material layer that makes an Octon installation unique to a given repository.

Evaluate the claim without assuming it is true. Distinguish clearly between:

- repo-specific or differentiating material
- proprietary or IP-sensitive material
- authored authority
- runtime-consumed configuration
- retained evidence
- generated/effective outputs

Scope:
- Review `.octon/inputs/**` as non-authoritative input material.
- Compare it against the roles of `.octon/framework/**`, `.octon/instance/**`, `.octon/state/**`, and `.octon/generated/**`.
- Treat `.octon/inputs/exploratory/ideation/**` as human-led; inspect only as needed for this review and do not mutate anything.

Questions to answer:

1. In what sense, if any, does `.octon/inputs/**` make an Octon installation repo-specific?
2. Where does repo-specific durable authority actually live?
3. Which parts of `.octon/inputs/**` are raw intake, advisory planning, proposal lineage, normalized extension source, or human-led ideation?
4. What would be misleading or dangerous about calling `.octon/inputs/**` “the proprietary layer”?
5. What is the better mental model for how `.octon/inputs/**` relates to governed promotion, publication, runtime use, and authority?
6. Are there naming, documentation, or taxonomy changes that would make this boundary clearer?

Deliverables:
- A concise verdict: true, partly true, or false, with nuance.
- An evidence table citing relevant repository paths.
- A boundary model showing how `inputs/**` relates to `instance/**`, `state/**`, and `generated/**`.
- Risks caused by confusing raw inputs with authority.
- Recommended wording for the concept.
- Open questions or assumptions.

Constraints:
- Read-only review only.
- Do not promote, publish, install, archive, or modify any files.
- Do not treat raw inputs as policy, runtime authority, retained evidence, or generated-effective output.
- Do not make legal/IP conclusions from the word “proprietary” unless the repository contains explicit evidence for that claim.

## Assistant Message 1 (commentary)

I’ll use the `audit-domain-architecture` skill for a read-only architecture assessment, and first load the repo ingress instructions plus the skill contract so the review matches local conventions.

## Assistant Message 2 (commentary)

I’ve confirmed the local ingress explicitly says `framework/**` and `instance/**` are authored authority, `state/**` is operational truth/evidence, `generated/**` is derived, and raw `inputs/**` is not a runtime or policy dependency. I’m going to verify that claim against the actual tree and surrounding contracts rather than taking the ingress text as conclusive.

## Assistant Message 3 (commentary)

Next I’m loading the mandatory constitutional and workspace files plus the conditional standards. This is still read-only; I’m using them as evidence about how the repository describes authority, runtime posture, and retained evidence.

## Assistant Message 4 (commentary)

The core constitutional files strongly separate “input material” from authority and evidence. I’m reading the rest of the mandatory set, then I’ll map the actual `.octon/inputs` structure and look for any runtime references that contradict that separation.

## Assistant Message 5 (commentary)

The mandatory reads are complete. I’m now mapping directories and searching for explicit references to input, authority, publication, evidence, and generated-effective roles so the conclusion rests on observed placement and contracts.

## Assistant Message 6 (commentary)

The tree shows `.octon/inputs` has two main families: `additive` extension/source intake and `exploratory` plans, syntheses, proposals, reports, and ideation. I’m narrowing into the local READMEs and registries now, because those are the strongest evidence for intended classification without opening human ideation content unnecessarily.

## Assistant Message 7 (commentary)

The local READMEs align with the registry: exploratory material is advisory/lineage-only, reports are source material, syntheses are advisory, and ideation is explicitly human-led. I’m checking the deeper registry entries and additive extension manifests next, because “unique to a repository” may be truer for normalized extension source than for exploratory notes.

## Assistant Message 8 (commentary)

The registry’s path-family entries are useful: `inputs_additive` is explicitly “unselected desired extension source material,” while `inputs_exploratory` is “human-led ideation, proposal packets, plans, syntheses, and reports retained as exploratory lineage.” I’m checking the publication side so I can separate source material from active/generated extension state.

## Assistant Message 9 (commentary)

The extension publication path confirms the key distinction: desired selection is instance-owned, active truth is state-owned, runtime-facing outputs are generated/effective, and `inputs/additive/extensions/**` remains source material with hashes in generated artifact maps. I’m reading the small governance docs that define that split, then I’ll do a contradiction pass.

## Assistant Message 10 (commentary)

For exploratory inputs, I’ve deliberately limited ideation inspection to directory-level docs. The request scopes it as human-led, and the evidence needed for this review is the boundary contract, not the substance of the notes.

## Assistant Message 11 (commentary)

Proposal packets are structurally richer than ordinary notes, but they still describe themselves as temporary and non-canonical, with promotion targets outside the proposal path. That matters for the claim: some `inputs/**` material is differentiating design lineage, but not durable authority.

## Assistant Message 12 (commentary)

I’m now filling the comparison columns for `state/**`, `generated/**`, and `instance/**`: where current control, retained evidence, generated read models, and repo-authored authority actually live.

## Assistant Message 13 (commentary)

The comparison is converging: `instance/**` is the durable repo-specific authored layer; `state/**` carries mutable truth and evidence; `generated/**` carries rebuildable views. I’m checking the root and instance manifests for portability/profile claims, because those are the places that define what travels with an installation.

## Assistant Message 14 (commentary)

One nuance surfaced: some validators and publication tooling are allowed to read raw extension source under `inputs/additive/extensions/**`, and generated artifact maps retain source hashes from those paths. That does not make the source runtime authority, but it does mean “inputs are inert” would be too strong.

## Assistant Message 15 (commentary)

The term “proprietary” appears in intake-routing risk checks, not as a class name for all inputs. That supports a narrower conclusion: proprietary or IP-sensitive material is something intake classification may detect and constrain, not something the entire `inputs/**` root implies.

## Assistant Message 16 (commentary)

I have the evidence set. I’ll do a short self-challenge pass now: look for cases where `inputs/**` is consumed by runtime, where promotion targets still point into inputs, or where “source material” is doing more work than the labels imply.

## Assistant Message 17 (commentary)

The contradiction pass found no obvious durable runtime/policy dependence on raw inputs as authority. The runtime references I checked are either tests/fixtures, proposal lifecycle handling, generated-source dependency tracking, or explicit denial/classification paths.

## Assistant Message 18 (commentary)

One real naming risk did surface in code: authority-path classification groups `.octon/inputs/additive/**` with “authored governance or durable control surface” for write-scope/criticality purposes. That appears to be a safety classification, but the label is easy to misread as source-of-truth authority.

## Assistant Message 19 (commentary)

Generated/effective contracts are consistent: runtime may consume generated outputs only through resolver-verified handles, with raw inputs rejected as authority sources. That gives the boundary model a clear promotion path from source to generated handle without treating the source as live.

## Assistant Message 20 (commentary)

A second nuance is sharper: the topology registry’s generic `runtime_effective` metadata says input families are forbidden source families, while the extension publication artifacts trace published extension outputs back to `inputs/additive/extensions/**` and even some proposal README anchors. That is probably intended as digest provenance, but the registry wording is too broad for extension publication.

## Assistant Message 21 (commentary)

I’m reading the runtime-resolution selector and support declarations for one final check on where repo-specific runtime configuration is actually anchored.

## Assistant Message 22 (commentary)

The self-challenge is done. I found two boundary-clarity issues worth calling out, but no basis for treating `inputs/**` as durable authority or as a blanket proprietary/IP layer.

## Assistant Message 23 (final_answer)

**Verdict**

Partly true. `.octon/inputs/**` can make an Octon installation repo-specific as a non-authoritative source-material and lineage layer: local extension source packs, proposal packets, advisory plans, syntheses, reports, and human-led ideation can differ by repo. But it is not the repo-specific authority layer, not inherently proprietary, not retained evidence, not runtime-consumed policy/config, and not generated/effective output.

**Evidence**

| Path | Evidence |
| --- | --- |
| [.octon/README.md](/Users/jamesryancooper/Projects/octon/.octon/README.md) | Defines `instance/` as repo-specific durable authored authority and `inputs/` as non-authoritative additive/exploratory inputs. |
| [.octon/framework/cognition/_meta/architecture/contract-registry.yml](/Users/jamesryancooper/Projects/octon/.octon/framework/cognition/_meta/architecture/contract-registry.yml) | Classifies `inputs` as `non-authoritative-input`; separates authored authority, control, evidence, generated handles, exploratory input, and raw additive input. |
| [.octon/octon.yml](/Users/jamesryancooper/Projects/octon/.octon/octon.yml) | `repo_snapshot` includes `instance/**` and enabled additive extension sources, excludes exploratory/state/generated; runtime authority order excludes `inputs`. |
| [.octon/instance/extensions.yml](/Users/jamesryancooper/Projects/octon/.octon/instance/extensions.yml) | Repo-owned desired extension selection lives in `instance`, while source roots point to `inputs/additive/extensions`. |
| [.octon/inputs/additive/README.md](/Users/jamesryancooper/Projects/octon/.octon/inputs/additive/README.md) | Additive material becomes capability only after classification, validation, selection, and publication. |
| [.octon/inputs/additive/extensions/README.md](/Users/jamesryancooper/Projects/octon/.octon/inputs/additive/extensions/README.md) | Normalized extension packs are raw source packs, not the published runtime-facing extension surface. |
| [.octon/state/control/extensions/active.yml](/Users/jamesryancooper/Projects/octon/.octon/state/control/extensions/active.yml) | Active published extension state and publication receipt linkage live under `state/control`. |
| [.octon/generated/effective/extensions/catalog.effective.yml](/Users/jamesryancooper/Projects/octon/.octon/generated/effective/extensions/catalog.effective.yml) | Runtime-facing extension catalog is generated/effective and points back to input source manifests by provenance. |
| [.octon/inputs/exploratory/README.md](/Users/jamesryancooper/Projects/octon/.octon/inputs/exploratory/README.md) | Exploratory material may inform work but is not runtime, policy, generated, control, publication, evidence, or host-projection authority. |
| [.octon/inputs/exploratory/proposals/README.md](/Users/jamesryancooper/Projects/octon/.octon/inputs/exploratory/proposals/README.md) | Proposals are temporary implementation aids; promotion targets must be durable surfaces outside proposal paths. |
| [.octon/state/evidence/README.md](/Users/jamesryancooper/Projects/octon/.octon/state/evidence/README.md) | Retained evidence belongs under `state/evidence/**`; raw inputs may be cited but are not evidence authority. |
| [.octon/instance/governance/runtime-resolution.yml](/Users/jamesryancooper/Projects/octon/.octon/instance/governance/runtime-resolution.yml) | Runtime config forbids `.octon/inputs/**` as runtime authority and consumes generated/effective handles resolver-only. |

**Boundary Model**

```text
inputs/additive/.incoming/**
  -> classify + route
  -> state/evidence/** receipts
  -> proposal/program handoff or blocked/deferred

inputs/additive/extensions/**
  -> selected by instance/extensions.yml
  -> active/quarantine truth in state/control/extensions/**
  -> publication receipts in state/evidence/validation/publication/**
  -> generated/effective/extensions/** for runtime resolver use

inputs/exploratory/**
  -> human review, proposal lifecycle, plan, synthesis, or governed Change
  -> durable authority only if promoted into framework/** or instance/**
  -> retained proof only if recorded under state/evidence/**
  -> generated projections only as derived discovery/read models
```

No valid model has `inputs/** -> runtime/policy authority` directly.

**Input Taxonomy**

| Inputs subtree | Best classification |
| --- | --- |
| `inputs/additive/.incoming/**` | Raw additive intake before classification. |
| `inputs/additive/.archive/**` | Historical retained input copy, not retained evidence. |
| `inputs/additive/extensions/**` | Normalized extension source packs. |
| `inputs/exploratory/proposals/**` | Manifest-governed proposal lineage. |
| `inputs/exploratory/plans/*.md` | Advisory planning. |
| `inputs/exploratory/syntheses/*.md` | Advisory research synthesis. |
| `inputs/exploratory/reports/**` | Multi-file non-authoritative report sets. |
| `inputs/exploratory/ideation/**` | Human-led exploration; I inspected only boundary docs/listings needed for this review. |

**Risks**

Calling `inputs/**` “the proprietary layer” is dangerous because it turns a risk finding into a class identity. The repo only treats proprietary, licensed, redistribution-unsafe, secret, or private data as intake classification concerns, not as a blanket property of the root.

Confusing raw inputs with authority can cause direct runtime reads, stale proposal dependencies, skipped publication/freshness gates, invalid closeout claims, unsafe retention of sensitive material, and autonomous access to human-led ideation.

Two clarity issues are worth fixing: runtime write-scope code labels `.octon/inputs/additive/**` as `octon-authored-governance` for approval gating, which is protective but easy to misread; and generic runtime-effective metadata says input families are forbidden source families, while extension publication necessarily records input source digests. That should be worded as “forbidden authority sources,” not “no provenance from inputs.”

**Recommended Wording**

“`.octon/inputs/**` is Octon’s non-authoritative source-material and lineage workbench. It can contain repo-differentiating additive source, proposal history, planning, synthesis, reports, and human-led ideation. Governed promotion may consume it, but durable authority lives in `framework/**` and `instance/**`, operational truth and retained evidence live in `state/**`, and runtime-facing derived handles live in `generated/effective/**`.”

**Recommended Changes**

Rename or document `inputs/additive/extensions/**` as “extension source packs” more prominently.

Split the runtime classification label for `.octon/inputs/additive/**` from `authored-governance` to something like `protected-additive-source`.

Clarify publication metadata so input paths may be provenance/digest sources for extension publication but never authority sources.

Replace proposal-local “source of truth” wording with “proposal-local working reference” where it appears in exploratory proposal prompts.

**Open Questions**

Should first-party bundled extension source under `inputs/additive/extensions/**` be considered repo-specific, portable pack material, or both?

Should runtime-facing extension locks depend on exploratory proposal README anchors, or should those anchors move to framework/scaffolding docs?

Should proposal promotion targets continue to include `inputs/additive/extensions/**`, or should normalized extension source get a clearer non-authority class name?

I made no file edits. The worktree was already dirty when checked.

