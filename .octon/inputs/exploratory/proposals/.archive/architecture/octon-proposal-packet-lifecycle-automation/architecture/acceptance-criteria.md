# Acceptance Criteria

- proposal: `octon-proposal-packet-lifecycle-automation`

## Packet-Level Criteria

- [ ] The first-party additive extension pack exists at `.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/`.
- [ ] The pack has valid `pack.yml`, context docs, prompt bundles, skills, commands, and validation fixtures.
- [ ] The pack follows the recommended scaffold from `architecture/target-architecture.md`, or documents a justified alternate structure with equivalent coverage.
- [ ] Shared contracts cover repository grounding, proposal contracts, proposal authority boundaries, lifecycle artifact placement, validation/evidence, and GitHub closeout boundaries.
- [ ] The reusable pattern layer exists under the extension pack `context/` tree.
- [ ] The pack is selected in `.octon/instance/extensions.yml` and published through generated effective extension outputs.
- [ ] Capability routing publishes all command and skill routes.
- [ ] Host projections expose the lifecycle command and skill surfaces.
- [ ] Raw extension pack paths remain non-authoritative.
- [ ] Runtime-facing consumers use generated effective extension and capability outputs.

## Lifecycle Coverage Criteria

- [ ] Audit-aligned packet creation is covered.
- [ ] Architecture evaluation packet creation is covered.
- [ ] Highest-leverage next-step packet creation is covered.
- [ ] Generic source-to-packet creation is covered.
- [ ] Packet explanation is covered.
- [ ] Executable implementation prompt generation is covered.
- [ ] Follow-up verification prompt generation is covered.
- [ ] Correction prompt generation is covered.
- [ ] Verification-and-correction convergence is covered.
- [ ] Packet-specific closeout prompt generation is covered.
- [ ] Proposal archive, PR, CI, review conversation, merge, branch cleanup, and sync closeout is covered.
- [ ] Proposal program creation is covered.
- [ ] Program implementation prompt generation is covered.
- [ ] Program verification and correction is covered.
- [ ] Program correction prompt generation is covered.
- [ ] Program closeout is covered.

## Pattern Criteria

- [ ] Lifecycle state machine behavior is documented and validated.
- [ ] Composite route dispatcher behavior is documented and validated.
- [ ] Packet support artifact placement is documented and validated.
- [ ] Finding-to-correction behavior is documented and validated.
- [ ] Verification/correction convergence behavior is documented and validated.
- [ ] Closeout gate behavior is documented and validated.
- [ ] Evidence receipt behavior is documented and validated.
- [ ] Composition-first behavior is documented and validated.
- [ ] Authority firewall behavior is documented and validated.
- [ ] Scenario fixture coverage exists for every manual prompt class.
- [ ] Guidance-only normalized variants exist for every manual prompt class and are used only as fixture or bundle-design guidance.
- [ ] Proposal Program behavior is documented and validated.

## Proposal Program Criteria

- [ ] Parent program packets remain normal manifest-governed proposals.
- [ ] Child packets remain normal manifest-governed proposals at canonical paths.
- [ ] No child proposal packet is nested under a parent proposal directory.
- [ ] Parent packet sequence, child index, and `related_proposals` agree.
- [ ] Parent aggregate prompts do not override child `proposal.yml` or subtype manifests.
- [ ] Program correction prompts retain parent, child, child-group, or cross-packet finding ownership.
- [ ] Program closeout requires coherent child lifecycle states or explicit deferrals.

## Authority Criteria

- [ ] `proposal.yml` and subtype manifests remain proposal-local lifecycle authority.
- [ ] Generated prompts are operational aids only.
- [ ] Proposal packets remain non-canonical and temporary.
- [ ] Durable authority lands only in declared promotion targets outside proposal paths.
- [ ] Generated proposal registry remains discovery-only and is rebuilt by the canonical generator.
- [ ] GitHub, CI, chat, labels, comments, model memory, and tool availability do not become Octon authority.

## Validation Criteria

- [ ] Proposal validators pass.
- [ ] Extension pack contract validation passes.
- [ ] Extension publication validation passes.
- [ ] Extension local tests pass.
- [ ] Capability publication validation passes.
- [ ] Host projection validation passes.
- [ ] Follow-up verification prompt reports no unresolved implementation findings.
- [ ] Any deferred items are explicit, justified, and outside the promised whole-lifecycle automation surface.
