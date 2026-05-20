# Refine Prompt Run Log

**Original:** I moved the downloaded installable skill pack to `.archive/octon-rust-skill-pack-rust-source-authority`. Review it and determine how best to install it in Octon, where the downloaded installable pack should be placed before installation, etc. Ensure the solution is Octon-aligned and future-proof. Update the prompts accordingly.
**Refined:** 2026-05-19
**Context Depth:** standard
**Status:** updated existing prompt artifact with current staged-pack path, canonical `.incoming` intake guidance, and install-route decision criteria.

## Profile Selection Receipt

- release_state: `pre-1.0`
- change_profile: `atomic`
- rationale: the task updated a prompt artifact and run log only; no transitional compatibility route is required for this refinement.

## Repository Context

- Bound canonical ingress and required constitutional/workspace read set.
- Inspected `.archive/octon-rust-skill-pack-rust-source-authority`.
- Confirmed the staged pack is readable from the repo and includes a direct skill payload plus install fragments.
- Confirmed the pack is not an `octon-extension-pack-v5` as-is because it lacks `pack.yml` and `validation/compatibility.yml`.
- Confirmed root `.archive/**` is not a canonical runtime, policy, publication, or evidence surface in the inspected Octon topology.
- Reframed downloaded-pack intake from first principles as `.octon/inputs/additive/extensions/.incoming/<pack-id>/`, with `.archive` reserved for post-decision retention rather than pre-install intake.

## Key Refinements

1. Replaced the stale Downloads path with `.archive/octon-rust-skill-pack-rust-source-authority`.
2. Added observed pack facts to verify before implementation.
3. Required an explicit route decision: core framework skill, additive extension-pack normalization, or blocked/proposal route.
4. Clarified pre-install placement: `.octon/inputs/additive/extensions/.incoming/<pack-id>/` is the canonical raw intake for downloaded packs; root `.archive/**` is only the current ad hoc source, and `.archive` under additive inputs is post-decision retention.
5. Required updates to stale prompts/docs and prohibited direct host-projection creation.
6. Tightened the route-specific transition rule so future downloaded packs move from `.incoming` to direct core skill install, additive extension-pack normalization, or blocked/rejected retention with evidence.

## Self-Critique Results

- The prompt no longer assumes the pack is external or unreadable.
- The prompt does not pre-decide core install vs extension normalization; it forces a documented placement decision.
- The prompt preserves Octon's raw-input and generated-output non-authority boundaries.
- The prompt treats `.incoming` as intake only and blocks it from becoming runtime or evidence authority.
- The prompt gives enough concrete pack inventory to accelerate execution while requiring verification against current worktree state.

## Output

- Updated prompt artifact: `.octon/framework/scaffolding/practices/prompts/2026-05-19-downloaded-skill-pack-installation-workflow.prompt.md`
