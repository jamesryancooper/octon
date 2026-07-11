---
source_id: SRC-006
source_type: conversation-turn
sequence: 6
supplied_at: "2026-06-26T18:50:37.000Z"
turn_id: "019f0545-052f-7373-b714-aedf463cb703"
capture_status: complete
disclosure_status: local-only
authority_mode: non-authoritative
---

# SRC-006: Public-distribution implementation-planning brief

## User Message

Act as a principal Octon architecture and release-boundary planner.

Based on the work explored in this thread, produce a concise implementation-planning brief for the Octon public distribution model.

Goal:
Summarize what has been explored, what decisions or recommendations have emerged, and how to proceed toward a finalized implementation plan for publishing Octon as a portable public distribution.

Context to cover:
- The distinction between the full local development/workspace repo and the separate public distribution repo
- The proposed `portable_dropin` export model
- Why `bootstrap_core`, `repo_snapshot`, and `pack_bundle` are not sufficient as the public boundary
- Which repository surfaces are portable framework material
- Which surfaces must remain excluded: local inputs, instance authority, state, generated outputs, evidence, host projections, additive packs, logs, reports, and local residue
- The need for framework-wide license, provenance, sensitivity, and publication review before first public release
- The requirement that the public repo be populated only by an allowlist-generated artifact, not by cloning or mirroring this workspace repo

Deliverables:
1. Executive overview of what was explored
2. Current architectural verdict: what aligns, what does not, and what needs clarification
3. Recommended target model for public distribution
4. Proposed implementation workstreams
5. Required policy/profile changes, especially `portable_dropin`
6. Required export, validation, CI, pre-push, and publication gates
7. Risks and failure modes to prevent
8. Suggested phased roadmap from current state to finalized implementation
9. Open questions and decisions still needed

Constraints:
- Do not mutate files.
- Do not inspect sensitive or human-led ideation content.
- Do not assume non-authoritative content is safe to publish.
- Distinguish architecture boundaries from information-security/publication boundaries.
- Clearly separate confirmed findings from recommendations and assumptions.

Answer in a structured but concise format suitable for turning into an implementation plan.

## Assistant Message 1 (final_answer)

**1. Executive Overview**

We reviewed Octon’s current architecture against the goal of publishing a portable public distribution. The main conclusion: the conceptual architecture is mostly sound, but the current repository/publication mechanics are not safe as a public boundary.

Confirmed from prior inspection:

- [`.octon/README.md`](/Users/jamesryancooper/Projects/octon/.octon/README.md:29) already distinguishes `framework`, `instance`, `state`, `generated`, and `inputs`.
- [`.octon/octon.yml`](/Users/jamesryancooper/Projects/octon/.octon/octon.yml:33) has `bootstrap_core`, `repo_snapshot`, and `pack_bundle`, but no true public distribution profile.
- [inputs architecture](/Users/jamesryancooper/Projects/octon/.octon/framework/cognition/_meta/architecture/inputs/README.md:3) correctly says inputs are raw/non-authoritative, not publication authority.
- [evidence tiers](/Users/jamesryancooper/Projects/octon/.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml:16) support private vs publishable disclosure boundaries.
- [release-please workflow](/Users/jamesryancooper/Projects/octon/.github/workflows/release-please.yml:100) currently stages generated/evidence/control paths, so it is not suitable for public distribution.

**2. Architectural Verdict**

Partly aligned.

What aligns:

- `framework/**` is the right portable product/framework root.
- `instance/**` is correctly modeled as repo-specific durable authority.
- `state/**` is correctly modeled as runtime/control/evidence/continuity.
- `generated/**` is correctly modeled as derived/effective output.
- `inputs/**` is correctly non-authoritative and not runtime authority.
- Scaffolding/bootstrap is the right mechanism for creating target-local surfaces.

What does not align yet:

- There is no enforced `portable_dropin` public boundary.
- Existing profiles can be mistaken for publication profiles.
- Current release automation can publish local generated/evidence/control material.
- The base Octon template manifest appears ahead of actual template files.
- Host projections are tracked locally and need exclusion from public output.
- `framework/**` is portable by role, but not automatically publication-cleared.

**3. Target Model**

Use a separate public distribution repository populated only by a generated artifact:

```text
full local development repo
  framework + local inputs + instance + state + generated + evidence + projections
        |
        | allowlist export: portable_dropin
        v
portable_dropin artifact
  publication-cleared framework + neutral bootstrap/templates only
        |
        v
separate public Octon repo
  distribution mirror, not a clone of this workspace
```

The public repo must never be populated by `git push --mirror`, branch copy, broad `rsync`, or a normal clone of this workspace.

**4. Why Current Profiles Are Insufficient**

| Profile | Finding |
|---|---|
| `bootstrap_core` | Closest, but internal; currently includes live `instance/manifest.yml`, so it should not define public distribution. |
| `repo_snapshot` | Too broad; includes repo-local `instance/**` and enabled extension material. |
| `pack_bundle` | Useful for separately reviewed extension packs, not base Octon. |
| `full_fidelity` | Explicitly a normal clone; opposite of the public distribution boundary. |

**5. Public Allowlist**

Recommended public source classes:

- `.octon/octon.yml`, sanitized or profile-scoped for distribution
- `.octon/README.md`
- `.octon/framework/**`, after publication review
- `.octon/framework/scaffolding/runtime/bootstrap/**`
- `.octon/framework/scaffolding/runtime/templates/**`, after template repair/review
- neutral root adapter templates, not local adapters as-is
- neutral instance/state/generated templates under framework scaffolding only

**6. Required Denylist**

Exclude by default:

- `.octon/inputs/**`
- `.octon/instance/**`, except neutral templates
- `.octon/state/**`
- `.octon/generated/**`
- `.codex/**`, `.claude/**`, `.cursor/**`
- additive packs
- evidence, logs, traces, reports, receipts, archives
- local run state and local residue
- generated effective outputs unless rebuilt inside a public-safe export process

**7. Implementation Workstreams**

1. Define `portable_dropin` profile semantics in `.octon/octon.yml`.
2. Repair or replace the base Octon template set so required files actually exist.
3. Build an allowlist export script that writes to a clean artifact directory.
4. Build a denylist validator for exported artifacts.
5. Add framework-wide license/provenance/sensitivity/publication review.
6. Create separate public distribution repo and publish only export output.
7. Replace public release CI with artifact validation, not local workspace release logic.
8. Add pre-push/public-remote protections against denied paths.
9. Document the boundary in README and contributor guidance.

**8. Required Gates**

Before first public publication:

- allowlist-only export verification
- denylist scan for local roots and host projections
- secret/sensitive-content scan
- framework license/provenance review
- executable/runtime/WASM/script review
- template completeness check
- generated-output taint check
- evidence-disclosure classification check
- public repo diff check before push
- CI gate that fails if excluded roots appear

**9. Risks To Prevent**

- Publishing the full workspace repo instead of a distribution artifact.
- Treating “non-authoritative” as “safe to publish.”
- Copying live `instance/**` into public Octon.
- Publishing generated/effective outputs that encode local configuration.
- Shipping retained evidence, logs, reports, or receipts.
- Accidentally publishing host projections from `.codex`, `.claude`, or `.cursor`.
- Shipping additive packs before separate classification/versioning.
- Assuming all framework material is license-safe without review.

**10. Phased Roadmap**

Phase 1: Boundary contract  
Define `portable_dropin`, denylist, allowlist, and public repo policy.

Phase 2: Template repair  
Make neutral bootstrap/templates complete and remove dependency on live local `instance/**`.

Phase 3: Export tooling  
Implement clean-room artifact generation plus manifest/checksum output.

Phase 4: Validation gates  
Add denylist, template completeness, provenance, secret, generated-taint, and evidence checks.

Phase 5: Public repo pipeline  
Populate a separate public repo only from validated artifacts.

Phase 6: First release review  
Run full framework publication review and publish only after all gates pass.

**11. Open Decisions**

- Exact public repo name and ownership.
- Whether `portable_dropin` lives only in `.octon/octon.yml` or also gets a standalone contract file.
- Whether root adapters ship as files, templates, or generated install outputs.
- Whether any framework-host projection templates should be included.
- How to record publication clearance for each framework subtree.
- Whether `bootstrap_core` should be narrowed immediately or only documented as internal.

