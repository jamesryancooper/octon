# Pilot Run Protocol

Source library: `source/conversation-thread.md` (normalized source-model wording)

Review date: 2026-07-06

Review persona: `Octon Architect`

## Purpose

This runbook defines how to execute a later evidence-producing pilot run from
the prompt library without turning the raw intake library itself into
authority.

The protocol is intentionally non-executing. It records the expected order,
routing rules, evidence outputs, stop conditions, and non-goals for a future
operator-approved pilot run.

## Authority Boundary

- This intake remains raw non-authoritative source material until a governed
  disposition admits it elsewhere.
- Running the prompts later must produce retained review evidence, not
  authority.
- Review results must not mutate `framework/**`, `instance/**`,
  `state/control/**`, `state/evidence/**`, `state/continuity/**`,
  `generated/**`, runtime files, support claims, proposal artifacts, or host
  projections by themselves.
- A later proposal packet or proposal program may cite retained review evidence,
  but the proposal artifact is still candidate lineage, not authority.
- Generated proposal navigation, if later created through a governed route,
  remains a non-authoritative read model.

## Preconditions For A Later Pilot

Before running any prompt, the operator or agent should confirm:

- the intake unit still validates;
- the pilot has an explicit review id;
- the repository checkout and branch or commit are recorded; the recorded
  local checkout is the review substrate (the GitHub URL in each prompt
  identifies the project, not the substrate);
- no specific execution model is pinned by this library; record whichever model actually runs the pilot;
- the review persona is `Octon Architect`;
- for a self-enumerating run of Prompts 3-7, an item budget for the run is
  declared before per-item reviews begin;
- no implementation, cleanup, archive move, generated publication, or proposal
  creation is authorized by the pilot itself;
- retained review evidence destination is selected before execution.

Recommended retained evidence destination:

```text
.octon/state/evidence/validation/architecture/reviews/<review-type>/<review-id>/
```

## Review-Type Slugs

Use these `<review-type>` values in the retained evidence destination:

| Prompt | `<review-type>` slug |
| --- | --- |
| Prompt 1 | `super-root-balanced-review` |
| Prompt 2 | `clean-sheet-delta-review` |
| Prompt 3 | `current-state-mechanism-architecture-review` |
| Prompt 4 | `architecture-readiness-audit` |
| Prompt 5 | `domain-architecture-audit` |
| Prompt 6 | `surface-architecture-audit` |
| Prompt 7 | `constitutional-challenge-review` |

Slugs for Prompts 3-6 match the corresponding route ids in
`.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml`.
Prompts 1, 2, and 7 have no registered route id there; their slugs are defined
by this protocol. Constitutional Challenge candidates surfaced by any prompt
still route to
`.octon/state/evidence/validation/architecture/reviews/constitutional-challenge-candidates/<review-id>/`
per the placement amendment; the `constitutional-challenge-review` slug is for
the retained evidence of a Prompt 7 run itself.

## Pilot Sequence

1. Validate the intake envelope.
   - Run the incoming-intake validator.
   - Confirm the prompt library remains under
     `.octon/inputs/additive/.incoming/octon-architecture-review-prompt-library/`.
   - Confirm no final disposition has already moved or admitted the intake.

2. Create a pilot evidence folder.
   - Use a stable `review-id`.
   - Record date, repository path, branch, commit, operator, the model actually
     used for the run, and prompt source paths.
   - Copy or reference the exact prompt artifact used for the run.

3. Run Prompt 1 first.
   - Prompt 1 is the Tier 1 whole-super-root balanced architecture review.
   - It includes the bounded clean-sheet lens needed for the first pass.
   - Do not run Prompt 2 before Prompt 1.

4. Preserve Prompt 1 output as retained evidence.
   - Store the review result under the selected evidence folder.
   - Include cited repository paths, findings, unknowns, and routing decision.
   - Do not convert the result directly into a proposal program.

5. Route follow-up prompts from Prompt 1 findings.
   - When routing to Prompts 3, 5, 6, or 7 from a prior review, supply the
     identified mechanism, domain, surface, or triggering finding as the
     prompt's target so the prompt runs in targeted mode and reviews only
     that target. The standalone self-enumerating mode is for unrouted runs.
   - Run Prompt 2 only if Prompt 1 leaves unresolved foundational doubts about
     Octon's shape.
   - Run Prompt 3 for a current governed mechanism that needs cross-surface
     review, supplying the mechanism.
   - Run Prompt 5 for a bounded domain identified by Prompt 1, supplying the
     domain.
   - Run Prompt 6 for a single durable surface or tight surface family
     identified by Prompt 1, Prompt 3, or Prompt 5, supplying the surface.
   - Run Prompt 7 with the triggering finding if a prior review identifies a
     likely constitutional, precedence, authority, fail-closed, evidence,
     support, generated-output, runtime, disclosure, or autonomy conflict.
   - Run Prompt 4 only after an architecture has been accepted and the question
     is readiness for implementation planning.

6. Handle multi-item runs from self-enumerating prompts.
   - A standalone run of Prompts 3-7 may produce one review per enumerated
     item. Use one parent review id for the run.
   - Store the run-level inventory, run context, and prompt reference in the
     parent bundle, and store each per-item review in a per-item subfolder
     under the parent review id (for example
     `<review-id>/items/<item-slug>/`).
   - Each per-item review carries its own Review Result Routing and Artifact
     Placement section from the amendment; per-item routing outcomes may
     differ.
   - The parent bundle's route decision records the maximum escalation across
     items (evidence-only < proposal packet < proposal program <
     Constitutional Challenge) plus the full per-item outcome list.
   - Items recorded as "not reviewed in this run" stay in the parent
     inventory as the remainder; a continuation run uses a new review id and
     cites the prior parent bundle.

7. Synthesize the retained review evidence.
   - Distinguish preserve-as-is, insufficient evidence, bounded revision,
     coordinated program, and constitutional challenge outcomes.
   - Record whether a proposal packet or proposal program is warranted.
   - Do not create the proposal artifact inside the pilot unless a separate
     governed route explicitly authorizes that step.

## Required Pilot Evidence Bundle

A later pilot should produce a file-native evidence bundle similar to:

```text
review.md
evidence-index.yml
source-prompt.md
repo-scope.yml
model-and-run-context.yml
repository-citations.yml
item-inventory.yml
findings.yml
authority-boundary-map.yml
generated-effective-risk-register.yml
support-proof-gap-map.yml
validator-depth-matrix.yml
route-decision.yml
open-questions.md
validation.md
```

Minimum fields to preserve:

- review id;
- prompt id and prompt path;
- model actually used for the run;
- review persona;
- run mode (targeted or self-enumerating) and, for self-enumerating runs, the
  declared item budget and the continuation remainder;
- repository path;
- branch and commit;
- model-visible context supplied;
- files, directories, and surfaces inspected;
- repository citations for major claims;
- findings with severity and confidence;
- required evidence for unresolved claims;
- downstream routing recommendation;
- explicit non-authority statement.

## Stop Conditions

Stop the pilot and record a blocked evidence result if:

- the intake no longer validates;
- the prompt source cannot be identified exactly;
- the model output lacks repository citations for major claims;
- the review attempts to authorize implementation, proposal creation,
  generated publication, support widening, archive movement, cleanup, or
  runtime/control mutation;
- the model treats generated outputs, read models, host UI, chat transcripts,
  provider sessions, model memory, raw inputs, or retained evidence as
  authority;
- constitutional conflict is detected and Prompt 7 has not yet been routed;
- required repository evidence is missing or inaccessible;
- the review scope expands beyond the selected prompt route;
- a targeted run expands beyond its supplied target;
- a self-enumerating run reviews items beyond its declared item budget or
  drops an enumerated item without recording it in the continuation
  remainder.

## Routing Outcomes

Each completed review must choose one outcome:

- retain as evidence only;
- retain as evidence and recommend a single proposal packet;
- retain as evidence and recommend a proposal program;
- retain as evidence and trigger Constitutional Challenge Review;
- block because evidence is insufficient;
- block because the review exceeded scope or violated authority boundaries.

Proposal creation is a later governed action. The pilot may recommend it, but
must not perform it by default.

## Validation For A Later Pilot

Recommended checks after the later pilot run:

```text
bash .octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh --intake-id octon-architecture-review-prompt-library
bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh
```

The pilot evidence folder should also be checked manually for:

- retained evidence destination under `state/evidence/**`;
- no mutation outside the evidence folder;
- complete route decision;
- complete source prompt reference;
- repository citations for major claims;
- explicit non-authority statement.

## Explicit Non-Goals

This protocol does not:

- run any architecture review prompt;
- create a proposal packet;
- create a proposal program;
- implement findings;
- update validators;
- publish generated/effective outputs;
- widen support;
- mutate runtime/control state;
- archive or delete the intake unit;
- make the prompt library durable capability.

## Boundary Statement

This protocol is intake-local, non-authoritative planning material. It is a
runbook for a later operator-approved pilot, not approval to execute that
pilot.
