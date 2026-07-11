---
source_id: SRC-004
source_type: conversation-turn
sequence: 4
supplied_at: "2026-06-20T16:52:08.000Z"
turn_id: "019ee5f2-65a1-7e82-b03d-7cc90ec25830"
capture_status: complete
disclosure_status: local-only
authority_mode: non-authoritative
---

# SRC-004: Sponsor distribution decisions

## User Message

1. **Separate repo or generated artifact?**  
Use a separate public repository that is populated only by a generated, allowlist-based `portable_dropin` artifact from this repo.  
This repo remains the full development/workspace repo. The public repo is a distribution mirror, not a clone target.

2. **Which `.octon/framework/**` parts need license/provenance review?**  
All of `.octon/framework/**` before first publication, with priority on:
- executable/runtime material, including scripts, Rust/WASM/runtime assets
- bundled templates and generated scaffolds
- skills, prompts, agent instructions, and host-tool projections
- schemas/contracts derived from external standards or prior systems
- test fixtures, examples, sample data, reports, and docs
- anything copied from vendors, OSS projects, AI outputs, or private work

Default answer: framework is portable by role, but not automatically publication-cleared.

3. **Should additive extension packs ship as first-party public packs?**  
Not in the base distribution.  
Initial public Octon should ship with zero additive packs by default. Any first-party packs should be separately reviewed, classified, versioned, and exported through a dedicated pack profile. If an extension is essential to Octon itself, promote it into reviewed framework material instead of treating it as local additive input.

4. **Should generated starter files be included?**  
No live `.octon/state/**` or `.octon/generated/**` files should ship in the artifact.  
The artifact should include neutral templates only, preferably under `.octon/framework/scaffolding/runtime/templates/**`. First init should create target-local state, generated/effective outputs, evidence roots, and host projections.

5. **Deprecate `bootstrap_core` or retain it?**  
Retain `bootstrap_core` as an internal/bootstrap implementation profile, but do not use it as the public distribution boundary.  
Introduce `portable_dropin` as the public-facing profile. Narrow `bootstrap_core` if needed so it does not imply copying live repo `instance/**` into other projects. Over time, deprecate public references to `bootstrap_core`, not necessarily the internal profile itself.

Recommended concise policy:

> Public Octon is a `portable_dropin` export produced from reviewed framework and bootstrap templates only. It is published through a separate public distribution surface. Local inputs, instance authority, state, generated outputs, evidence, host projections, and additive packs are excluded unless separately classified and intentionally exported.


## Assistant Message 1 (final_answer)

Agreed. This resolves the public-boundary decision cleanly.

The architecture should be:

```text
development repo
  full Octon workspace, including local inputs/instance/state/generated/evidence/projections
        |
        | allowlist export + validation gates
        v
portable_dropin artifact
  reviewed framework + bootstrap/templates only
        |
        | publish
        v
separate public distribution repo
  distribution mirror, not a clone of the development repo
```

I would treat your concise policy as the canonical wording, with one small precision:

> Public Octon is a `portable_dropin` export produced from publication-cleared framework source and neutral bootstrap templates only. It is published through a separate public distribution repository populated by an allowlist export artifact. Local inputs, instance authority, state, generated outputs, evidence, host projections, and additive packs are excluded unless separately classified, reviewed, versioned, and intentionally exported.

Key implementation implications:

- `portable_dropin` becomes the only public-facing distribution profile.
- `bootstrap_core` remains internal/bootstrap machinery, not a publication boundary.
- `.octon/framework/**` is portable by architectural role, but publication-cleared only after license/provenance/security review.
- First public release ships zero additive packs.
- The public repo must never be populated by `git push --mirror`, branch copy, or broad rsync from this repo.
- Public CI should validate the exported artifact, not this full workspace.
- Live `.octon/instance/**`, `.octon/state/**`, `.octon/generated/**`, `.octon/inputs/**`, `.codex/**`, `.claude/**`, and `.cursor/**` remain denied by default.

The next concrete artifact should be a `portable_dropin` profile contract plus an export validator that makes those exclusions mechanically enforceable.

