# Octon Architecture Review Prompt Library

This payload contains seven copy/paste-ready `Octon Architect` prompts for
Octon architecture and governance review. Each prompt has the standalone
`Review Result Output and Artifact Placement Amendment` appended.

These prompts are model-agnostic and pin no specific execution model.

## How to Use This Library

Run Prompt 1 first. It is the Tier 1 whole-architecture review and includes a
bounded clean-sheet lens as a comparison tool. Do not run the standalone
clean-sheet follow-up first.

Run Prompt 2 only if Prompt 1 finds unresolved foundational doubts about
Octon's shape, such as the five-root model, generated/effective handles,
mission/run separation, support-target proofing, retained file-native evidence,
or excessive compensating complexity.

Prompts 3 through 7 run in two modes. In targeted mode, a prior review or the
operator supplies the mechanism, domain, surface, architecture, or triggering
finding, and the prompt reviews only that target. In standalone
self-enumerating mode, the prompt enumerates the in-scope items from the
repository itself, opens with an inventory, declares an item budget for the
run, reviews items in inventory order, and records every unreviewed item
explicitly as a remainder for a continuation run. Standalone sweeps of
Prompts 3, 5, and 6 intersect by design (the same area can appear as a
mechanism, a domain, and a surface family); prefer targeted routed runs after
Prompt 1, and have a later sweep cite prior retained review evidence for an
already-reviewed area instead of re-reviewing it.

Use Prompt 3 for a current governed mechanism that spans multiple surfaces but
is narrower than the whole super-root. Supply the mechanism when routing from
a prior review; run it standalone to enumerate and cycle through all governed
mechanisms.

Use Prompt 4 only after an architecture has already been accepted and the
question is whether it is ready for implementation planning. It must not become
implementation. Run standalone, it enumerates accepted architectures pending
implementation planning from decision, proposal, and retained review records;
an empty inventory is a valid outcome.

Use Prompt 5 for a bounded domain such as support targets,
generated/effective trust, context packing, connector admission, self-evolution,
evidence closure, autonomy, product claim and disclosure discipline, change
closeout and hosted-control surfaces, or validator depth and architecture
health. Supply the domain when routing from a prior review; run it standalone
to enumerate and cycle through all bounded domains.

Use Prompt 6 for one durable surface: a contract, registry, schema family,
policy, adapter boundary, generated/effective handle family, evidence root, or
read-model family. Supply the surface when routing from a prior review. Its
standalone sweep mode faces a large surface space, so it groups files into
surface families and works within a declared item budget across runs.

Use Prompt 7 when a prior review finds a likely conflict with Octon's
constitutional, precedence, authority, fail-closed, or evidence obligations,
and supply that triggering finding. It may also run standalone as a
repository-wide constitutional sweep; candidates then require cited repository
evidence of an actual tension, and a finding of zero candidates is a valid
outcome.

Delegate low-leverage work to cheaper models or implementation agents: file
inventories, markdown cleanup, schema formatting, validator implementation,
fixture writing, code patches, migration sequencing, changelog drafting, and
implementation task breakdowns. `Octon Architect` should be reserved for
architecture judgment, authority-boundary critique, contradiction discovery,
method selection, and review-quality assessment.

## Included Prompts

1. `prompts/01-octon-authoritative-super-root-balanced-architecture-review.md`
2. `prompts/02-bounded-clean-sheet-delta-review.md`
3. `prompts/03-current-state-mechanism-architecture-review.md`
4. `prompts/04-architecture-readiness-audit.md`
5. `prompts/05-domain-architecture-audit.md`
6. `prompts/06-surface-architecture-audit.md`
7. `prompts/07-constitutional-challenge-review.md`

## Standalone Amendment

- `review-result-output-and-artifact-placement-amendment.md`

## Source And Completeness

- Normalized source conversation thread: `source/conversation-thread.md`
- Completeness review: `completeness-review.md`
- Earlier prompt-set coverage map: `coverage-map.md`
- Deferred pilot run protocol: `pilot-run-protocol.md`

The earlier review-target lists in the conversation thread are superseded by
the later seven-prompt library request and final archive request. They remain
source context, not missing prompt artifacts. `coverage-map.md` records how
the earlier eight-prompt and twelve-prompt sets map into the final seven
review routes.

`pilot-run-protocol.md` defines the expected order, evidence bundle, routing
rules, stop conditions, and non-goals for a later operator-approved pilot run.
It does not authorize or execute the pilot.

## Important Boundary

These prompts are for architecture review and routing decisions only. They do
not authorize implementation, mutate Octon authority, widen support, create
proposals, publish generated/effective outputs, or modify runtime/control truth.
