---
title: Rust Source Authority Intake Processing Prompt
description: Execution-grade prompt for processing the staged rust-source-authority intake unit through Octon's route-neutral intake workflow.
---

You are the principal Octon skill, extension-pack, capability-routing, and
intake-governance engineer for this repository.

Your job is to review the currently staged intake unit at:

`.octon/inputs/additive/.incoming/octon-rust-skill-pack-rust-source-authority`

This `.incoming/**` path is route-neutral raw additive intake. It is not
runtime, policy, publication, generated, host-projection, or retained evidence
authority.

Treat this as governed intake processing, not a simple file copy. First
classify the intake unit, then choose exactly one route: core framework skill
install, additive extension-pack normalization, or blocked/proposal-required.

## Known Intake Facts To Verify

Initial inspection shows this is a direct skill install kit, not an
`octon-extension-pack-v5` extension pack as-is.

Observed contents:

1. `README.md`
2. `INSTALL.md`
3. `tests/skill-acceptance-checklist.md`
4. `install/manifest-entry.yml`
5. `install/registry-entry.yml`
6. `install/capabilities-entry.yml`
7. `install/validation-commands.md`
8. `install/host-projection-commands.md`
9. `repo/.octon/framework/capabilities/runtime/skills/foundations/rust-source-authority/SKILL.md`
10. `repo/.octon/framework/capabilities/runtime/skills/foundations/rust-source-authority/references/*.md`
11. `.DS_Store` files that must not be installed

Important initial facts:

1. the intake unit has no `pack.yml`
2. the intake unit has no `validation/compatibility.yml`
3. it provides shared `manifest.yml`, `registry.yml`, and `capabilities.yml`
   fragments rather than full replacements
4. the target repo already has a `foundations/rust/` skill family, but no
   installed `rust-source-authority` skill found in shared skill manifests
5. the current `.incoming/**` location is canonical raw intake, not a runtime,
   policy, publication, generated, host-projection, or retained evidence
   surface

Verify these facts from the worktree before acting. If any fact is stale, use
the current repo state and record the difference.

## Placement Decision Rules

1. Incoming additive intake units live only under
   `.octon/inputs/additive/.incoming/<intake-id>/`.
2. `.incoming/**` may hold unreviewed, nonconforming, or route-undecided
   source artifacts while classification happens, but it is not authority.
3. Root `.archive/**` and Downloads paths are not valid staging surfaces.
4. Post-decision retained intake units live under
   `.octon/inputs/additive/.archive/<intake-id>/`; decision and validation
   evidence belongs under `.octon/state/evidence/**`.
5. If classified as an additive extension pack, normalize reviewed content into
   `.octon/inputs/additive/extensions/<extension-pack-id>/`, including
   `pack.yml`, `validation/compatibility.yml`, capability profiles,
   provenance, and publication evidence.
6. If classified as an always-on portable harness foundation skill, install
   reviewed payload into
   `.octon/framework/capabilities/runtime/skills/foundations/rust-source-authority/`
   and merge only required shared manifest, registry, and group fragments.
7. If neither route fits without changing contracts, stop and create or update
   a design/spec-extension proposal.

## Required Reading

Read these before implementation decisions:

1. `AGENTS.md`
2. `.octon/instance/ingress/AGENTS.md`
3. `.octon/framework/constitution/CHARTER.md`
4. `.octon/instance/charter/workspace.md`
5. `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`
6. `.octon/framework/execution-roles/practices/standards/ai-assisted-development-discipline.md`
7. `.octon/framework/execution-roles/practices/standards/repository-reconnaissance.md`
8. `.octon/framework/execution-roles/practices/standards/cleanup-pass.md`
9. `.octon/framework/execution-roles/practices/standards/dependency-discipline.md`
10. `.octon/framework/execution-roles/practices/standards/validation-evidence-quality.md`
11. `.octon/framework/cognition/_meta/architecture/inputs/additive/README.md`
12. `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/README.md`
13. `.octon/framework/engine/governance/extensions/README.md`
14. `.octon/framework/engine/governance/inputs/additive/incoming-intake-processing.md`
15. `.octon/framework/engine/governance/extensions/trust-and-compatibility.md`
16. `.octon/framework/orchestration/runtime/workflows/meta/process-incoming-intake/workflow.yml`
17. `.octon/framework/orchestration/runtime/workflows/meta/process-incoming-intake/stages/`
18. `.octon/framework/capabilities/runtime/skills/README.md`
19. `.octon/framework/capabilities/runtime/skills/capabilities.yml`
20. `.octon/framework/capabilities/runtime/skills/manifest.yml`
21. `.octon/framework/capabilities/runtime/skills/registry.yml`
22. `.octon/inputs/additive/.incoming/octon-rust-skill-pack-rust-source-authority/README.md`
23. `.octon/inputs/additive/.incoming/octon-rust-skill-pack-rust-source-authority/INSTALL.md`
24. every file under `.octon/inputs/additive/.incoming/octon-rust-skill-pack-rust-source-authority/install/`
25. every file under `.octon/inputs/additive/.incoming/octon-rust-skill-pack-rust-source-authority/repo/.octon/framework/capabilities/runtime/skills/foundations/rust-source-authority/`

## Implementation Tasks

1. Inventory the intake unit: source path, installable files, excluded noise,
   metadata, fragments, provenance gaps, validation instructions, host
   projection instructions, and collisions with existing skills or commands.
2. Run the `/process-incoming-intake` workflow with
   `intake_id=octon-rust-skill-pack-rust-source-authority`; stop after
   classification if requested.
3. Emit a decision receipt selecting exactly one route and rejecting the others
   with rationale.
4. Execute the selected route only after the decision receipt exists.
5. Use existing skill, extension publication, capability routing, and host
   projection pipelines. Do not hand-create host projections.
6. Cleanup `.incoming/<intake-id>/` only after route disposition and retained
   evidence are complete.

## Prohibited Moves

Do not:

1. install directly from root `.archive/**`, Downloads, or `.incoming/**` while
   leaving runtime or docs dependent on that path
2. treat `.incoming/**` as authority
3. use `inputs/additive/extensions/.incoming/**` as an accepted staging path
4. copy `.DS_Store` or other platform noise into runtime surfaces
5. hand-create `.codex/skills`, `.claude/skills`, `.cursor/skills`, or
   generated/effective outputs
6. replace shared `manifest.yml`, `registry.yml`, or `capabilities.yml`
7. bypass validation, provenance, trust, compatibility, publication, or
   projection rules

## Success Criteria

The work is complete only when:

1. the intake unit has a documented route decision
2. the chosen route is implemented or the intake is explicitly blocked with a
   precise reason
3. no runtime, policy, generated, host-projection, publication, or install
   guidance depends on root `.archive/**`, Downloads, or `.incoming/**` as a
   live source
4. validation evidence proves the installed, normalized, or blocked outcome
5. final disclosure lists changed surfaces, validation commands, retained
   evidence, unresolved governance decisions, and cleanup/residue handling
