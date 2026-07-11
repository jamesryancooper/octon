---
source_id: SRC-007
source_type: conversation-turn
sequence: 7
supplied_at: "2026-06-26T18:57:30.000Z"
turn_id: "019f054b-53d3-7202-bd39-28792814f181"
capture_status: complete
disclosure_status: local-only
authority_mode: non-authoritative
---

# SRC-007: External architect handoff prompt request

## User Message

I want to provide all the information in this thread to an architectural engineer to review, finalize, and create an implementation plan for the public distribution model. Create a prompt that will instruct this.


## Assistant Message 1 (final_answer)

Use this prompt:

```text
Act as a principal Octon architecture and release-boundary engineer.

Objective:
Review, finalize, and turn the Octon public distribution model into an implementation plan.

Context:
Octon currently lives in a full local development/workspace repository. That repository contains portable framework material, but also local repo-specific material, private/sensitive/proprietary-risk material, generated outputs, runtime state, retained evidence, host projections, logs, reports, and local residue.

The intended public model is not to publish this workspace repo. The intended model is:

development/workspace repo
  -> allowlist-generated portable_dropin artifact
  -> separate public distribution repo

The public repo is a distribution mirror populated only from the generated artifact. It must not be a clone, mirror, branch copy, or broad rsync of the workspace repo.

Prior findings and working decisions:
- `.octon/framework/**` is portable by architectural role, but not automatically publication-cleared.
- All of `.octon/framework/**` requires license, provenance, sensitivity, and publication review before first public release.
- High-priority framework review areas include executable/runtime material, scripts, Rust/WASM/runtime assets, templates, generated scaffolds, skills, prompts, agent instructions, host-tool projections, schemas/contracts derived from external standards or prior systems, test fixtures, examples, sample data, reports, docs, vendor/OSS/AI/private-work derived material.
- `.octon/instance/**` is repo-specific durable authority and must not be copied into the public artifact except as neutral templates.
- `.octon/state/**` is runtime/control/evidence/continuity state and must not ship.
- `.octon/generated/**` is derived/effective output and must not ship as live local content.
- `.octon/inputs/**` is non-authoritative raw/advisory material; non-authoritative does not mean safe to publish.
- `.octon/inputs/exploratory/ideation/**` is human-led; inspect only filenames/metadata unless explicitly authorized.
- `.codex/**`, `.claude/**`, `.cursor/**` are local host projections/settings; exclude except reviewed templates.
- Additive packs should not ship in the base distribution. Ship zero additive packs initially. Any first-party pack needs separate classification, versioning, review, and export profile. If an extension is essential to Octon, promote it into reviewed framework material.
- No live `.octon/state/**` or `.octon/generated/**` starter files should ship. First init should create target-local state, generated/effective outputs, evidence roots, and host projections from neutral templates.
- Retain `bootstrap_core` as an internal/bootstrap implementation profile, but do not use it as the public distribution boundary.
- Introduce `portable_dropin` as the public-facing profile.
- Over time, deprecate public references to `bootstrap_core`, not necessarily the internal profile itself.

Important files/surfaces to inspect:
- `AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/octon.yml`, especially `bootstrap_core`, `repo_snapshot`, `pack_bundle`, generated commit defaults, and runtime refs
- `.octon/README.md`
- `.octon/framework/scaffolding/runtime/**`
- `.octon/framework/scaffolding/runtime/templates/**`
- `.octon/framework/scaffolding/runtime/templates/octon/manifest.json`
- `.octon/framework/cognition/_meta/architecture/inputs/README.md`
- `.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml`
- `.gitignore`
- `.github/workflows/release-please.yml`
- Host projection roots: `.codex/**`, `.claude/**`, `.cursor/**`, metadata only unless needed
- Do not inspect human-led ideation content beyond filenames/metadata.

Known concerns to verify:
- Existing profiles are insufficient:
  - `bootstrap_core` is closest but internal and may imply copying live `instance/manifest.yml`.
  - `repo_snapshot` is too broad because it includes local `instance/**` and extension material.
  - `pack_bundle` is for separately reviewed extension packs, not base Octon.
  - `full_fidelity` is a normal clone and is explicitly not the public model.
- Current release workflow appears unsafe for public distribution because it stages generated/effective, state/control, and state/evidence paths.
- The base Octon template manifest may declare required files that are missing from the actual template tree. Verify and plan repair.
- Current `.gitignore` is hygiene, not a security/publication boundary.

Constraints:
- Start read-only.
- Do not mutate files while producing the plan.
- Do not publish, push, delete, rewrite history, or clean files.
- Do not assume non-authoritative content is safe to publish.
- Distinguish architecture/authority boundaries from information-security/publication boundaries.
- Distinguish confirmed findings from recommendations and assumptions.
- Do not make legal/IP conclusions unless explicit repository evidence supports them.

Tasks:
1. Validate whether the current architecture is fit for the portable public distribution model.
2. Identify structural gaps that must be clarified, narrowed, or redesigned before publication.
3. Define the `portable_dropin` profile contract and semantics.
4. Define the public distribution allowlist.
5. Define the explicit denylist and rationale.
6. Specify how the export artifact should be generated from the workspace repo.
7. Specify validation gates for export, CI, pre-push, publication, and public repo sync.
8. Specify how framework-wide license/provenance/sensitivity/publication review should be recorded.
9. Specify required changes to `bootstrap_core`, docs, templates, `.gitignore`, CI, and release automation.
10. Provide a phased roadmap from current state to first public release.
11. Identify open questions and decisions needed before implementation.

Deliverables:
- Executive verdict: aligned, partly aligned, or not aligned, with nuance.
- Current surface inventory table:
  - path
  - role
  - public distribution handling
  - risk
  - recommended action
- Proposed `portable_dropin` profile specification.
- Public artifact allowlist and denylist.
- Boundary model showing:
  - full workspace repo
  - allowlist export
  - generated artifact
  - separate public distribution repo
  - target project first init
- Export tool design:
  - inputs
  - outputs
  - manifest/checksum expectations
  - failure behavior
- Validation gate design:
  - denylisted path scan
  - template completeness
  - secret/sensitivity scan
  - license/provenance scan
  - generated-output taint check
  - evidence-disclosure check
  - host projection exclusion
  - public repo diff check
- CI/pre-push/publication-gate recommendations.
- Phased implementation roadmap with acceptance criteria.
- Risks and failure modes.
- Open questions and assumptions.

Recommended policy wording to evaluate and refine:
“Public Octon is a `portable_dropin` export produced from publication-cleared framework source and neutral bootstrap templates only. It is published through a separate public distribution repository populated by an allowlist export artifact. Local inputs, instance authority, state, generated outputs, evidence, host projections, and additive packs are excluded unless separately classified, reviewed, versioned, and intentionally exported.”
```

