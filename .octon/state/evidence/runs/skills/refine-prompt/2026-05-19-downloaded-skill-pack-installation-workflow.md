# Refine Prompt Run Log

**Original:** How can I create a workflow/surface/feature to install downloaded skill packs into Octon. Here is a downloaded skill pack: `/Users/jamesryancooper/Downloads/Archives/octon-rust-skill-pack-rust-source-authority`. Maybe something similar to proposals?
**Refined:** 2026-05-19
**Context Depth:** standard
**Status:** refined prompt saved; intent interpreted as implementation-grade prompt, not direct installation.

## Profile Selection Receipt

- release_state: `pre-1.0`
- change_profile: `atomic`
- rationale: prompt artifact and run log are narrow additions that do not require transitional compatibility handling.

## Execution Persona

Principal Octon extension, capability, and skill-publication engineer.

## Repository Context

- Mandatory ingress and constitutional read set were bound from `AGENTS.md` and `.octon/instance/ingress/AGENTS.md`.
- Capability and skill system context came from `.octon/framework/capabilities/**`.
- Extension publication context came from `.octon/framework/engine/governance/extensions/**`, `.octon/instance/extensions.yml`, `.octon/state/control/extensions/**`, and `.octon/generated/effective/extensions/catalog.effective.yml`.
- Proposal lifecycle context came from `.octon/inputs/exploratory/proposals/README.md`, proposal workflow contracts, and `.codex/skills/octon-proposal-lifecycle/SKILL.md`.
- The downloaded pack path could not be inspected in the sandbox due to an OS permission denial, so the refined prompt requires the future executor to inspect it with approval if needed.

## Intent

Create an execution-grade prompt for building a governed Octon skill-pack installation surface that treats downloaded packs as non-authoritative inputs until they pass provenance, trust, compatibility, publication, and projection gates.

## Key Refinements

1. Reframed "install" as import, admission, publication, and host projection.
2. Chose the existing extension-pack model as the preferred route.
3. Preserved the proposal analogy as lifecycle shape only, not authority.
4. Added explicit negative constraints against direct copies into `.codex/skills` or framework runtime skill definitions.
5. Required the Rust source-authority pack to be used as a real fixture or to produce a precise blocked/quarantined result.

## Negative Constraints

- Do not turn raw downloaded content into runtime or policy authority.
- Do not install by direct copy into host projection directories.
- Do not create a parallel proposal-like system when extension publication can handle the work.
- Do not weaken compatibility or trust checks to make the fixture pass.
- Do not infer the downloaded pack structure without inspecting it.

## Self-Critique Results

- The refined prompt is more explicit about authority boundaries than the original.
- It gives the future executor a concrete first fixture while preserving fail-closed behavior if the fixture is malformed or inaccessible.
- It avoids overcommitting to a workflow, skill, or command before repository reconnaissance, but it names a likely workflow shape and required stages.
- It includes validation commands likely to prove publication and host-projection behavior, with room to mark checks not applicable when scope is narrower.

## Output

- Prompt artifact: `.octon/framework/scaffolding/practices/prompts/2026-05-19-downloaded-skill-pack-installation-workflow.prompt.md`
