# Validation Plan

- proposal: `octon-proposal-packet-lifecycle-automation`

## Proposal Validation

Run:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-proposal-packet-lifecycle-automation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-proposal-packet-lifecycle-automation
```

After registry regeneration is safe for the whole worktree, run:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-proposal-packet-lifecycle-automation
```

## Extension Validation

Run:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-local-tests.sh
```

## Capability And Host Projection Validation

Run:

```bash
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projection-purity.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projection-non-authority.sh
```

## Pack-Local Scenario Validation

Pack-local tests must prove:

- the implemented pack either follows the recommended scaffold from
  `architecture/target-architecture.md` or documents a better alternate
  structure with equivalent lifecycle coverage,
- shared contract coverage exists for repository grounding, proposal
  contracts, proposal authority boundaries, lifecycle artifacts, validation
  and evidence, and GitHub closeout boundaries,
- the `create-proposal-packet` bundle preserves normalize, classify,
  route-selection, packet creation, and packet validation stages even if file
  names differ from the recommended scaffold,
- the reusable patterns are present in the extension pack context tree,
- route-specific prompt bundles reference or import the relevant patterns,
- every prompt bundle manifest resolves,
- route selection selects the expected leaf,
- source context is retained under packet `resources/**`,
- generated prompts are retained under packet `support/**`,
- generated prompts do not claim authority,
- verification findings have stable IDs,
- correction prompts target one finding or declared finding group,
- closeout prompt generation requires current proposal and PR state grounding,
- closeout route refuses to merge with failing required checks or unresolved review conversations.
- proposal program parent packets reference child packets without nesting child proposal directories,
- every child packet in a proposal program validates independently,
- program sequence dependencies reference known child packet ids,
- program aggregate prompts do not override child packet manifests.

## Manual Prompt Coverage Validation

The validation suite must include representative fixtures for each manual
prompt class captured in `resources/manual-prompt-mapping.md`.

Validation fixtures should use
`resources/manual-prompt-variant-guidance.md` as guidance for preserving manual
prompt intent without copying the old prompts verbatim or making them
authoritative.

## Pattern Validation

The implementation must validate these pattern obligations:

- lifecycle transitions reject invalid next steps,
- dispatcher route selection is deterministic for representative inputs,
- generated prompts land under packet `support/**`,
- source context lands under packet `resources/**`,
- verification findings use stable IDs,
- correction prompts map to findings,
- convergence loop stops only at declared terminal states,
- closeout refuses to proceed with failing checks or unresolved review conversations,
- evidence receipts exist for route execution,
- generated prompts, GitHub state, chat, and generated registry projections are blocked from becoming authority.

## Proposal Program Validation

Program-specific fixtures must prove:

- parent program packet validates as a normal proposal,
- child packets remain at canonical proposal paths,
- nested child proposal package directories are rejected,
- parent `related_proposals`, `resources/child-packet-index.md`, and
  `architecture/packet-sequence.md` agree,
- child packets can reference the parent without making the parent
  authoritative over child lifecycle truth,
- sequence modes `sequential`, `parallel-independent`, `gated-parallel`,
  `program-atomic`, and `manual-gated` are parsed and gated correctly,
- aggregate program correction prompts preserve whether the finding belongs to
  the parent, one child, a child group, or a cross-packet dependency,
- program closeout refuses to archive the parent until child lifecycle states
  are implemented, archived, rejected, superseded, or explicitly deferred.

## Done Gate

The implementation is complete only when:

- all extension and capability publication outputs are coherent,
- host projections include the new commands and skills,
- pack-local tests pass,
- generated packet support artifacts match the placement contract,
- follow-up verification finds no unresolved lifecycle route gaps,
- this proposal can be promoted and archived without durable targets depending
  on its proposal path.
