# Target Architecture

- proposal: `octon-proposal-packet-lifecycle-automation`

## Target State

Octon has a published first-party additive extension pack named
`octon-proposal-packet-lifecycle` that automates the full proposal packet
lifecycle while preserving Octon's existing authority model.

The extension pack provides reusable routes for:

1. collecting and preserving source context,
2. classifying proposal scenarios,
3. generating or creating proposal packets,
4. explaining proposal packets,
5. generating executable implementation prompts,
6. running implementation through existing packet execution routes,
7. generating follow-up verification prompts,
8. generating targeted correction prompts from verification findings,
9. repeating verification and correction to convergence,
10. generating packet-specific closeout prompts,
11. running full proposal archive, PR, CI, review, merge, branch, and sync closeout,
12. creating and operating parent proposal programs across child proposal packets,
13. retaining evidence and packet support artifacts in canonical locations.

## Extension Pack Shape

The durable authored source for the automation lives under:

```text
.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/
  pack.yml
  README.md
  context/
    patterns/
      proposal-program.md
  prompts/
    shared/
    create-proposal-packet/
    explain-proposal-packet/
    generate-implementation-prompt/
    generate-verification-prompt/
    generate-correction-prompt/
    generate-closeout-prompt/
    run-verification-and-correction-loop/
    closeout-proposal-packet/
    create-proposal-program/
    generate-program-implementation-prompt/
    generate-program-verification-prompt/
    generate-program-correction-prompt/
    run-program-verification-and-correction-loop/
    generate-program-closeout-prompt/
    closeout-proposal-program/
  skills/
  commands/
  validation/
```

Raw pack content remains a non-authoritative additive input until published.
Runtime-facing discovery uses generated effective extension and capability
outputs.

## Recommended Scaffold Guidance

The implementation should start from this scaffold unless live repository
constraints or existing extension-pack conventions make an alternate structure
clearly better:

```text
.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/
  pack.yml
  README.md

  context/
    overview.md
    routing-guide.md
    lifecycle-model.md
    scenario-taxonomy.md
    output-boundaries.md
    bundle-matrix.md
    routing.contract.yml
    patterns/
      proposal-program.md

  prompts/
    shared/
      repository-grounding.md
      proposal-contract.md
      proposal-authority-boundaries.md
      lifecycle-artifact-contract.md
      validation-and-evidence-contract.md
      github-closeout-boundary.md

    create-proposal-packet/
      manifest.yml
      README.md
      stages/
        01-normalize-source-context.md
        02-classify-proposal-scenario.md
        03-select-creation-route.md
        04-generate-or-create-packet.md
        05-validate-packet.md
      companions/
        01-generate-custom-creation-prompt.md
        02-align-bundle.md
      references/

    explain-proposal-packet/
    generate-implementation-prompt/
    generate-verification-prompt/
    generate-correction-prompt/
    generate-closeout-prompt/
    run-verification-and-correction-loop/
    closeout-proposal-packet/
    create-proposal-program/
    generate-program-implementation-prompt/
    generate-program-verification-prompt/
    generate-program-correction-prompt/
    run-program-verification-and-correction-loop/
    generate-program-closeout-prompt/
    closeout-proposal-program/

  skills/
  commands/
  validation/
```

This scaffold is guidance, not an extra proposal authority model. An alternate
structure is acceptable only when the implementation records the rationale in
the pack README or context docs and proves equivalent coverage for shared
contracts, route manifests, route stages, companions, references, validation
fixtures, commands, skills, and publication outputs.

## Reusable Pattern Layer

The extension pack owns a reusable pattern layer that every route can cite
instead of restating lifecycle safety rules independently. The intended pattern
set is defined in `architecture/reusable-patterns.md` and should land durably
under the extension pack's `context/` tree, preferably as
`context/patterns.md` or split files under `context/patterns/`.

The required patterns are:

- lifecycle state machine,
- route dispatcher,
- packet support artifact placement,
- finding-to-correction,
- convergence loop,
- closeout gate,
- evidence receipt,
- composition first,
- authority firewall,
- scenario fixtures,
- proposal program.

These patterns are architectural constraints for the implementation. A route
that bypasses the state model, support artifact placement, authority firewall,
proposal program boundary, or closeout gate is not a conforming implementation
of this proposal.

The Proposal Program pattern is detailed in
`architecture/proposal-program-pattern.md`. It allows parent packets to
coordinate child packets while preserving canonical child packet placement and
child manifest authority.

## Prompt Bundle Model

Each lifecycle operation is a separate prompt bundle with its own
`manifest.yml`, stages, references, companions, required repo anchors, and
validation scenarios. Shared contracts define repository grounding, proposal
authority boundaries, packet support artifact placement, evidence, and closeout
rules.

The implementation must not collapse the lifecycle into one giant prompt.
Routing must preserve distinct responsibilities for creation, explanation,
implementation prompt generation, verification prompt generation, correction
prompt generation, and closeout prompt generation.

## Packet Support Artifact Model

Generated packet-specific operational artifacts are retained under the proposal
packet being operated on:

```text
resources/
  source-context.md
  source-evaluation.md
  source-audit.md

support/
  proposal-packet-creation-prompt.md
  executable-implementation-prompt.md
  follow-up-verification-prompt.md
  custom-closeout-prompt.md
  correction-prompts/
  executable-program-implementation-prompt.md
  follow-up-program-verification-prompt.md
  program-correction-prompts/
  custom-program-closeout-prompt.md
  child-closeout-prompts/
```

`resources/**` preserves source inputs and evaluation lineage.
`support/**` preserves generated operational prompts and lifecycle aids.
Program-specific support artifacts live in the parent proposal program packet.
Child packets retain their own packet-specific support artifacts.

## Existing Surface Composition

The automation composes, rather than replaces:

- proposal standards and subtype standards,
- proposal templates,
- proposal create, validate, promote, and archive workflows,
- proposal validators and registry generator,
- `octon-concept-integration` source-to-packet and packet-to-implementation routes,
- `octon-impact-map-and-validation-selector` validation selection,
- `octon-drift-triage` remediation packet inputs where drift is the source,
- `octon-retirement-and-hygiene-packetizer` cleanup and retirement planning where applicable.

## Authority Boundaries

The extension pack may generate prompts and orchestrate proposal lifecycle
operations. It must not treat prompts, packets, source context, generated
registry projections, GitHub comments, PR labels, CI dashboards, model memory,
chat, MCP/tool availability, browser state, or external dashboards as Octon
authority, control truth, runtime policy, or permission.

Durable authority lands only in declared promotion targets outside proposal
packets. Proposal packets remain implementation-scoped and temporary.
