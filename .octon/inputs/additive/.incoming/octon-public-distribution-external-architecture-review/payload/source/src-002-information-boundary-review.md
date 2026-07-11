---
source_id: SRC-002
source_type: conversation-turn
sequence: 2
supplied_at: "2026-06-20T16:13:59.000Z"
turn_id: "019ee5cf-760a-7963-82ac-a79749366d71"
capture_status: complete
disclosure_status: local-only
authority_mode: non-authoritative
---

# SRC-002: Sensitive-information and publication-boundary review

## User Message

Act as a principal Octon security and information-boundary reviewer.

I want to identify every repository surface where proprietary, sensitive, private, or publication-restricted information may reside before the repository is pushed publicly to GitHub.

Context:
- Sensitive material may appear under `.octon/inputs/**`, especially raw intake, exploratory notes, plans, proposals, reports, or human-led ideation.
- Additional proprietary or sensitive material may also reside under `.octon/instance/**`, `.octon/state/**`, `.octon/generated/**`, host projections, logs, evidence, or generated artifacts.
- I am not asking whether these surfaces are authoritative. I am asking where sensitive material may physically or semantically reside in the local repository and how it could accidentally become public through Git tracking, generated outputs, publication artifacts, or pushes to GitHub.

Scope:
- Review likely sensitivity-bearing surfaces across the repository, especially:
  - `.octon/inputs/**`
  - `.octon/instance/**`
  - `.octon/state/**`
  - `.octon/generated/**`
  - root/config/host projection files that may mirror or publish Octon content
  - Git-tracked generated artifacts, evidence, logs, reports, and archives
- Treat `.octon/inputs/exploratory/ideation/**` as human-led; inspect only boundary docs, file names, and minimal metadata unless explicitly authorized.
- Do not mutate files, rewrite history, delete files, alter `.gitignore`, or run cleanup.

Questions to answer:
1. Which repository surfaces may contain proprietary, sensitive, private, secret, credential, license-restricted, or publication-restricted material?
2. Which of those surfaces are likely to be Git-tracked, generated, copied, projected, or published to GitHub?
3. Which surfaces are raw source material, authored authority, runtime/control state, retained evidence, generated output, host projection, or local-only residue?
4. Where are the highest-risk leak paths from local-only or sensitive material into public GitHub history?
5. What safety/security mechanism should be planned to prevent accidental public publication?
6. What naming, taxonomy, `.gitignore`, validation, pre-commit, CI, redaction, or publication-gate changes would reduce risk?

Deliverables:
- A concise risk verdict.
- A surface inventory table with path, role, sensitivity risk, Git/publication risk, and recommended handling.
- A data-classification taxonomy for Octon repository material.
- A leak-path model showing how sensitive material could move from local files into generated outputs, evidence, commits, or GitHub.
- Recommended controls, prioritized by impact and implementation cost.
- Open questions and assumptions.

Constraints:
- Read-only review only.
- Do not quote or expose sensitive contents in the response; redact examples.
- Do not make legal/IP conclusions unless the repository explicitly provides evidence.
- Distinguish “may contain sensitive material” from “is proprietary by definition.”
- Distinguish authority boundaries from information-security boundaries.


## Assistant Message 1 (commentary)

I’ll keep this read-only and treat this as an information-boundary review, not an authority review. I’m going to inspect path inventories, tracking status, ignore rules, publication/projection docs, and filename/keyword signals without opening human-led ideation content beyond boundary metadata.

## Assistant Message 2 (commentary)

I’m starting with the file-level exposure map: which Octon and host projection paths are tracked, which are untracked, and what ignore rules exist. That tells us what can reach GitHub by ordinary push versus what can leak through later staging, generation, or projection.

## Assistant Message 3 (commentary)

I’m continuing from the prior architectural pass, but this time treating authority and information exposure as separate axes. I’ll keep the evidence at path/category level and avoid quoting any potentially sensitive payload content.

## Assistant Message 4 (commentary)

The root ignore rules already show a mixed posture: several sensitive-looking roots are ignored by default, but there are explicit unignore exceptions for selected evidence runs, proposal archives, incoming intake status files, generated materialized indexes, and host-facing generated surfaces. I’ll now quantify what is currently tracked versus merely present.

## Assistant Message 5 (commentary)

Current tracking is materially broader than “source docs only”: thousands of tracked files sit under operational control, retained evidence, generated projections, proposal packets, and host-agent projections. That does not prove sensitive content, but it means a normal public push could expose more than authoritative Octon source.

## Assistant Message 6 (commentary)

The ideation surface is not only notes: filenames show tracked scratchpad material plus an embedded executable-layer project with source files and a `service.wasm`. I have not opened those contents; the path shape alone is enough to treat that subtree as sensitive until deliberately classified.

## Assistant Message 7 (commentary)

A filename/content-marker scan, limited to paths and not values, shows the expected policy documents plus real publication workflows. The content-marker list is not a secret finding by itself; it identifies where secret/redaction/publication concepts are represented and where generated/evidence outputs can carry them.

## Assistant Message 8 (commentary)

I’m going to pull line-numbered excerpts from the repository’s own boundary documents now. I’ll keep this to governance and taxonomy files, not raw payloads or human-led ideation notes.

## Assistant Message 9 (commentary)

The additive intake documents are security-relevant even though they are authority-boundary documents: they explicitly identify executable, binary, secret/private-data, redistribution, and provenance posture as classification inputs. That supports “may contain sensitive material,” not “is proprietary by definition.”

## Assistant Message 10 (commentary)

The repo has a good conceptual foundation for security controls: disclosure tiers distinguish private raw evidence, repo-publishable evidence, release disclosure, and generated read models, and the context-packing policy has explicit redaction/secret-denial semantics. The weaker spot is that those semantics are not uniformly reflected in Git tracking defaults for the local repository.

## Assistant Message 11 (commentary)

The GitHub workflows create a concrete public leak path, not just a theoretical one: one release workflow stages and pushes generated effective state, extension control state, selected evidence decision logs, validation evidence, and publication receipts back to a release branch. Artifact upload workflows also publish selected evidence/generated bundles as CI artifacts.

## Assistant Message 12 (commentary)

Ignore-rule probing confirms the mixed stance: incoming raw payloads are ignored, but additive archives are explicitly unignored; local evidence and stash archives are ignored; state control run roots are explicitly unignored; materialized generated projections are generally ignored except selected indexes. That means the main exposure comes from committed state/evidence/control exceptions and publication paths, not just accidental raw intake staging.

## Assistant Message 13 (commentary)

There is an existing repo-hygiene policy, but it scopes out `.octon/inputs/**` and focuses on cleanup/retention rather than pre-publication secrecy. For a public GitHub push, that leaves a gap: hygiene may protect local residue from deletion without proving that tracked evidence, control, proposals, or human-led notes are safe to publish.

## Assistant Message 14 (commentary)

I’ll do one last path-only sweep for classic secret-bearing filenames and repository-local artifacts. This does not read file contents; it helps distinguish ignored local residue from tracked publication surfaces.

## Assistant Message 15 (commentary)

The path-only sweep reinforces the same risk classes: tracked files include effect-token records, `.jsonl` filesystem snapshots, proposal archives with source-context and implementation prompts, `.patch` diffs, `.log` outputs, and WebAssembly artifacts. I’m not treating those as confirmed secrets; I’m treating them as surfaces that need classification before a public push.

## Assistant Message 16 (commentary)

The broad `find` path scan is still running because it is walking the full workspace. It is read-only; I’ll let it finish briefly, then I’ll use the already bounded Git-index evidence for the final review if it remains too broad.

## Assistant Message 17 (commentary)

The path sweep also found ignored build products under runtime `target/` and generated `.tmp/`; those are less likely to be pushed by ordinary Git commands but still need local-publication hygiene because force-adds, archive exports, or broad packaging can include them.

## Assistant Message 18 (final_answer)

**Verdict**

High risk to push publicly as-is. Not because `.octon/inputs/**` is “the proprietary layer,” but because the repo currently tracks broad classes of raw input, human-led notes, proposal lineage, operational state, retained evidence, generated projections, and host projections. I did not inspect raw ideation contents beyond filenames/metadata, and I am not making legal/IP conclusions.

Observed tracked scope: `.octon/inputs` 4,390 files, `.octon/instance` 442, `.octon/state` 27,840, `.octon/generated` 1,211, plus tracked `.codex`, `.claude`, `.cursor`, and `.github` surfaces.

**Surface Inventory**

| Surface | Role | Sensitivity Risk | Git / Publication Risk | Recommended Handling |
|---|---:|---:|---:|---|
| [`.octon/inputs/additive/.incoming/**`](/Users/jamesryancooper/Projects/octon/.octon/inputs/additive/.incoming/README.md:1) | raw intake | High: explicit risk fields for executable, binary, secret/private-data, redistribution | Payloads ignored; status files can track | Keep raw payloads ignored; classify before any promotion |
| [`.octon/inputs/additive/.archive/**`](/Users/jamesryancooper/Projects/octon/.octon/inputs/additive/.archive/README.md:1) | retained raw intake copies | High | Explicitly unignored in [.gitignore](/Users/jamesryancooper/Projects/octon/.gitignore:7) | Default-deny public unless classified safe and justified |
| [`.octon/inputs/additive/extensions/**`](/Users/jamesryancooper/Projects/octon/.octon/inputs/additive/extensions/README.md:1) | normalized extension source | Medium-high: prompts, skills, templates, source packs | 701 tracked; published to `generated/effective` | Require provenance/license/source classification before publication |
| [`.octon/inputs/exploratory/ideation/**`](/Users/jamesryancooper/Projects/octon/.octon/inputs/exploratory/ideation/scratchpad/README.md:72) | human-led ideation | High: notes, inbox, daily, project experiments | 79 tracked; includes executable-layer project and `.wasm` by filename metadata | Track structure only or explicit allowlist; default private |
| [`.octon/inputs/exploratory/proposals/**`](/Users/jamesryancooper/Projects/octon/.octon/inputs/exploratory/proposals/README.md:1) | proposal lineage | Medium-high: plans, prompts, source lineage, implementation reviews | 3,533 tracked; 196 untracked; registry projection | Treat as advisory lineage; public only after review/redaction |
| `.octon/inputs/exploratory/{plans,reports,syntheses}/**` | advisory planning/research | Medium-high | tracked | Review for private strategy, source excerpts, internal analysis |
| [`.octon/instance/**`](/Users/jamesryancooper/Projects/octon/.octon/README.md:58) | repo-specific durable authority | Medium: governance, support posture, connectors, ownership, missions | tracked; feeds generated outputs | Decide which authored authority is public product vs private deployment |
| [`.octon/state/control/**`](/Users/jamesryancooper/Projects/octon/.octon/state/control/README.md:1) | mutable runtime/control truth | High: run contracts, approvals, exceptions, effect-token records | 13,550 tracked; run roots explicitly unignored | Public only by narrow allowlist; most should be local/private |
| [`.octon/state/continuity/**`](/Users/jamesryancooper/Projects/octon/.octon/state/continuity/README.md:1) | resumable work state | High: handoff/current work context | 732 tracked; run continuity unignored | Default local-only; publish summaries only if redacted |
| [`.octon/state/evidence/**`](/Users/jamesryancooper/Projects/octon/.octon/state/evidence/README.md:1) | retained evidence | Very high: logs, traces, receipts, raw/pointer payloads, diffs | 13,558 tracked; publication receipts tracked; CI uploads evidence | Enforce disclosure tiers and redaction before GitHub |
| [`.octon/generated/effective/**`](/Users/jamesryancooper/Projects/octon/.octon/octon.yml:63) | generated runtime-facing outputs | Medium-high: source refs, hashes, active pack state | 471 tracked; release workflow auto-commits paths | Generated output inherits source classification |
| [`.octon/generated/cognition/**`](/Users/jamesryancooper/Projects/octon/.octon/generated/cognition/projections/README.md:1) | generated read models | Medium-high: aggregates private facts | 648 tracked | Publish only with traceability and source-safe classification |
| [`.octon/generated/proposals/**`](/Users/jamesryancooper/Projects/octon/.octon/inputs/exploratory/proposals/README.md:20) | proposal registry/artifacts | Medium-high | 92 tracked; 4 untracked | Treat as derivative proposal exposure |
| `.codex/**`, `.claude/**`, `.cursor/**` | host projections | Medium-high: commands, skills, settings, prompts | 667 tracked total | Publish only from reviewed projection manifest |
| [`.github/workflows/**`](/Users/jamesryancooper/Projects/octon/.github/workflows/release-please.yml:100) | CI/publication automation | Medium-high: can publish artifacts and commit generated/evidence paths | 47 tracked; release workflow stages state/evidence/generated paths | Add public-publication gate before upload/commit |

**Boundary Model**

```text
raw/local source
  -> inputs/additive/.incoming or inputs/exploratory/ideation
  -> proposals/plans/reports or normalized extension source
  -> instance authority only through governed promotion
  -> state/control + state/evidence during execution
  -> generated/effective, generated/cognition, generated/proposals
  -> host projections and GitHub workflows/artifacts
  -> git commit / release branch / GitHub artifact / public repo
```

Authority and security are separate. The repo correctly says `inputs/**` is non-authoritative and excludes it from runtime/policy authority, but non-authoritative files can still contain sensitive information and can still leak through proposal packets, evidence, generated summaries, host projections, or CI artifacts.

**Highest-Risk Leak Paths**

1. Raw or human-led material becomes proposal/support/source-lineage content, then appears in `generated/proposals/**`.
2. Private run output lands in `state/evidence/**`, then is summarized into disclosure or uploaded as a CI artifact.
3. Extension source under `inputs/additive/extensions/**` is published into `generated/effective/extensions/**` and projected into `.codex`, `.claude`, or `.cursor`.
4. Runtime/control records under `state/control/**` expose run scopes, grants, exceptions, effect-token metadata, or local execution context.
5. Release automation stages generated/effective, extension control, and publication evidence paths into a release branch.

**Recommended Controls**

P0 before public push:
- Add a public-publication gate that fails on tracked files under high-risk roots unless explicitly allowlisted.
- Run secret scanning and history scanning before any public remote push.
- Require disclosure-tier classification for every public `state/evidence/**` file.
- Block raw-copy promotion from private evidence or raw input into generated/read-model/public artifacts.
- Restrict GitHub artifact uploads to redacted, tiered, allowlisted paths.

P1:
- Change `.gitignore` posture to default-ignore ideation content, continuity, run control, most evidence, additive archives, and generated materialized projections.
- Add `classification.yml` or equivalent per publication-bearing root: `public_allowed`, `disclosure_tier`, `source_class`, `redaction_status`.
- Add generated taint tracking: generated files inherit the most restrictive source classification.
- Review `.claude/settings.json` and host projections before public release.

P2:
- Create a curated public-export profile instead of publishing the full working repo.
- Plan separate Git history remediation if any sensitive material was previously committed.
- Add CODEOWNERS/review gates for high-risk roots.

**Recommended Wording**

“`.octon/inputs/**` is a non-authoritative source-material and proposal-lineage area. It may contain repo-specific, private, proprietary, licensed, or publication-restricted material, but it is not proprietary by definition and not an authority layer. Public release requires governed promotion, classification, redaction/minimization, evidence-tiering, and generated-output publication gates.”

**Open Questions**

- Is the goal to publish the whole working repository, or a curated public export?
- Which `instance/**` governance/support surfaces are intended public product documentation?
- Are existing tracked evidence/control/proposal histories already cleared for public disclosure?
- Should host projections be distributed publicly or regenerated by installers?
- Who owns final redaction and license/provenance signoff?

