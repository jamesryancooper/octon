# Proposal Packet Creation Prompt

This support artifact records the packet-specific creation prompt intent for
`octon-proposal-packet-lifecycle-automation`. It is a non-authoritative
operational aid and source-lineage artifact. The durable implementation remains
governed by `proposal.yml`, `architecture-proposal.yml`, proposal standards,
validators, and the declared promotion targets.

## Prompt

Create a complete Octon architecture proposal packet at:

```text
.octon/inputs/exploratory/proposals/architecture/octon-proposal-packet-lifecycle-automation/
```

The packet must define the full proposal packet lifecycle automation for a
first-party additive extension pack at:

```text
.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/
```

## Required Content

- Preserve the full source context from the conversation and manual prompt set
  under packet `resources/**`.
- Map the current manual prompt set into reusable lifecycle routes and
  guidance-only normalized variants.
- Define creation, explanation, implementation prompt generation, verification
  prompt generation, correction prompt generation, verification/correction
  convergence, closeout prompt generation, and closeout execution.
- Include proposal-program support for parent packets that coordinate canonical
  child proposal packets without nesting child packet directories.
- Define reusable patterns for lifecycle state, route dispatch, support
  artifact placement, finding-to-correction, convergence, closeout, evidence,
  composition-first behavior, authority boundaries, scenario fixtures, and
  proposal programs.
- Include the recommended extension-pack scaffold as guidance unless a better
  structure is justified during implementation.
- Compose existing Octon proposal standards, templates, workflows, validators,
  registry generation, concept-integration routes, impact-map routes, drift
  triage, and hygiene packetization.
- Keep raw extension pack inputs, generated prompts, proposal packets, chat,
  GitHub state, CI dashboards, external tools, browser state, model memory, and
  generated projections non-authoritative.
- Define implementation, validation, acceptance, cutover, closeout, risk, and
  evidence plans.
- Include packet-specific support prompts for implementation, verification, and
  closeout.

## Validation

After creating or updating the packet, run:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-proposal-packet-lifecycle-automation --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-proposal-packet-lifecycle-automation
```

Skip the registry check only while unrelated visible proposal packets make
registry regeneration unsafe for the whole worktree.
