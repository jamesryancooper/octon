# Program Implementation Orchestration Prompt

prompt_id: lifecycle-postmortem-evaluation-program-implementation-orchestration-prompt-20260605T115530Z
generated_at: 2026-06-05T11:55:32Z
generator: codex-proposal-lifecycle-generate-program-implementation-orchestration-prompt
program_packet_path: .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program
parent_review_digest_at_generation: sha256:e0bfd494bc427a84f3c97cd4035bba4191333daaac950d2be72e494cc24757e6
verdict: ready-for-program-implementation-orchestration

This prompt orchestrates implementation of the accepted
`lifecycle-postmortem-evaluation-program` proposal program. It is not a
promotion receipt, child receipt, runtime authority, policy authority, support
claim, or evidence that implementation has completed.

## Role

Act as the single accountable Octon orchestrator and runtime/assurance engineer
for a proposal-program implementation run.

Operate under:

- `.octon/instance/ingress/AGENTS.md`
- `.octon/framework/constitution/CHARTER.md`
- `.octon/framework/constitution/charter.yml`
- `.octon/framework/constitution/obligations/fail-closed.yml`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/constitution/precedence/normative.yml`
- `.octon/framework/constitution/precedence/epistemic.yml`
- `.octon/framework/constitution/ownership/roles.yml`
- `.octon/framework/constitution/contracts/registry.yml`
- `.octon/instance/charter/workspace.md`
- `.octon/instance/charter/workspace.yml`
- `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`
- `.octon/framework/execution-roles/practices/standards/ai-assisted-development-discipline.md`
- `.octon/framework/execution-roles/practices/standards/repository-reconnaissance.md`
- `.octon/framework/execution-roles/practices/standards/validation-evidence-quality.md`
- `.octon/framework/execution-roles/practices/standards/cleanup-pass.md`
- `.octon/framework/execution-roles/practices/standards/dependency-discipline.md`

## Gate Snapshot

This prompt was generated after these parent pre-implementation gates passed:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program --require-implementation-authorization
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program
```

The parent review authorizes program implementation orchestration prompt
generation only. It does not implement, promote, close out, archive, or make
live any runtime behavior.

## Objective

Implement a governed lifecycle-postmortem capability that can be invoked after
an Octon lifecycle process has run. The implementation must:

- provide a post-run, read-only `lifecycle-postmortem` meta workflow and
  runtime entry point;
- define a lifecycle-postmortem evaluator template and structured output
  contract;
- validate postmortem reports, structured outputs, evidence references,
  invariant compliance, invariant validity/evolution review, final judgment,
  and non-authority boundaries;
- retain postmortem outputs as evidence under canonical run evidence roots;
- keep postmortem findings and invariant recommendations non-authorizing until
  separately accepted through the proper governance, proposal, amendment, or
  review-disposition route.

## Profile Selection Receipt

Before implementation, emit this receipt in the run notes:

```yaml
profile_selection_receipt:
  release_state: pre-1.0
  selected_change_profile: atomic
  rationale: Parent and required child packets are pre-1.0 Octon-internal architecture work. No transitional exception is authorized by this prompt.
  transitional_exception_note: none
```

## Mandatory Preflight

Before planning or editing durable targets, re-run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program --require-implementation-authorization
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program
```

Continue only when all three gates return `errors=0 warnings=0`.

For each required child packet, also run before editing that child's durable
targets:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <child-packet-path> --require-implementation-authorization
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package <child-packet-path>
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child-packet-path> --skip-registry-check
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <child-packet-path>
```

Refuse implementation orchestration if any review digest is stale, any required
child is blocked, clarification is required, required metadata is missing, a
dependency gate is unsatisfied, or a child would need to exceed its accepted
manifest.

## Parent Package Read Set

Read the parent files in this order:

1. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/proposal.yml`
2. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/architecture-proposal.yml`
3. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/resources/child-packet-index.yml`
4. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/architecture/packet-sequence.md`
5. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/architecture/child-packet-contract.md`
6. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/architecture/target-architecture.md`
7. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/architecture/implementation-plan.md`
8. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/architecture/acceptance-criteria.md`
9. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/architecture/program-closeout-plan.md`
10. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/validation-plan.md`
11. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/resources/source-lifecycle-postmortem-evaluation.md`
12. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/resources/source-invariant-evaluation.md`
13. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/resources/source-invariant-validity-evolution.md`
14. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/resources/source-traceability-matrix.md`
15. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/navigation/source-of-truth-map.md`
16. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/support/proposal-review.md`
17. `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/support/implementation-grade-completeness-review.md`

For each child, read `proposal.yml`, `architecture-proposal.yml`,
`architecture/target-architecture.md`, `architecture/implementation-plan.md`,
`architecture/acceptance-criteria.md`, `validation-plan.md`,
`support/proposal-review.md`, and
`support/implementation-grade-completeness-review.md` before modifying durable
targets.

## Authority Boundaries

- The parent program coordinates only. It does not satisfy child receipts,
  promotion targets, validation verdicts, closeout evidence, or archive
  metadata.
- Proposal files under `inputs/**` are non-authoritative implementation
  lineage. They may guide implementation only because the proposal review gates
  accepted them.
- Generated outputs, raw inputs, chat history, host labels, comments,
  dashboards, tool availability, and postmortem reports may not become runtime,
  policy, support, closure, or invariant authority.
- Postmortem evaluator output remains retained evidence. It may report
  blockers, redesign pressure, and invariant concerns, but it may not approve
  lifecycle transition, closeout, promotion, support widening, redesign, or
  invariant amendment.
- Invariant validity/evolution recommendations remain proposed evidence. They
  may create findings, proposal candidates, or constitutional amendment
  candidates, but they do not change invariants without a separate governed
  route.
- Do not make lifecycle postmortems mandatory closeout gates in this program.
  That would require a later accepted policy or lifecycle proposal.

## Child Program Sequence

Use `resources/child-packet-index.yml` and `architecture/packet-sequence.md` as
the sequencing contract. The accepted sequence is:

| Phase | Child packet | Dependency gate | Promotion targets |
| --- | --- | --- | --- |
| 1 | `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-meta-workflow` | none | `.octon/framework/orchestration/runtime/workflows/meta/lifecycle-postmortem/`; `.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs` |
| 2 | `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluator-template` | workflow child verification | `.octon/framework/assurance/evaluators/`; `.octon/framework/constitution/contracts/assurance/` |
| 3 | `.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-validator` | workflow and evaluator child verification | `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-postmortem.sh`; `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-postmortem.sh`; `.octon/framework/assurance/runtime/_ops/fixtures/lifecycle-postmortem/`; `.octon/framework/assurance/functional/suites/lifecycle-postmortem-integrity.yml`; `.octon/instance/assurance/runtime/lifecycle-postmortem.yml` |

Although the parent registry declares `gated-parallel`, this program's
dependencies make the practical route sequential: workflow first, evaluator
second, validator third.

## Phase 1: Meta Workflow

Implement only the accepted `lifecycle-postmortem-meta-workflow` child.

Required outcomes:

- add `.octon/framework/orchestration/runtime/workflows/meta/lifecycle-postmortem/workflow.yml`;
- add workflow stage files for evidence binding, evaluator invocation, finding
  materialization, and final report;
- add a runtime command path such as `octon lifecycle postmortem --run-id`;
- bind a target run id and reject empty or unsafe ids;
- reconstruct factual lifecycle state from retained run control and evidence,
  not chat memory or generated summaries;
- write retained postmortem evidence under
  `.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/`;
- emit optional review-finding records only as evidence;
- refuse lifecycle authority mutation.

Done gates:

- missing required evidence blocks or lowers confidence instead of inventing
  facts;
- generated, input, or chat context cannot become authority;
- runtime state, journals, closeout dispositions, support targets, generated
  outputs, proposal manifests, and authority artifacts are not mutated.

After implementation, produce child-owned
`support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md`.

## Phase 2: Evaluator Template

Implement only the accepted `lifecycle-postmortem-evaluator-template` child
after Phase 1 output layout is stable.

Required outcomes:

- add evaluator documentation under
  `.octon/framework/assurance/evaluators/lifecycle-postmortem/`;
- add
  `.octon/framework/assurance/evaluators/templates/lifecycle-postmortem-template.md`;
- add
  `.octon/framework/constitution/contracts/assurance/lifecycle-postmortem-evaluation-v1.schema.json`;
- update evaluator routing only enough to identify lifecycle-postmortem as an
  optional post-run evaluator.

The template and schema must include:

- evidence-grounded lifecycle reconstruction;
- bad-implementation-versus-wrong-architecture distinction;
- patch-versus-redesign reasoning;
- final judgment enum:
  - `Fit to reuse as-is`
  - `Fit to reuse with targeted improvements`
  - `Fit for limited/pilot use only`
  - `Not fit without significant lifecycle redesign`
  - `Fundamentally misaligned with the system's needs`
- invariant compliance evaluation before quality scoring;
- invariant ratings limited to `Pass`, `Partial`, `Fail`, `Unknown`, and
  `Not Applicable`;
- `Unknown` treated as an evidence gap, never as pass;
- invariant validity/evolution review after redesign pressure and before final
  recommendations;
- validity/evolution recommendations limited to `Keep`, `Clarify`,
  `Strengthen`, `Relax`, `Split`, `Merge`, `Reclassify`, `Replace`, `Remove`,
  and `Add`;
- required change and change-control bar for every non-`Keep`
  validity/evolution recommendation;
- explicit non-authority statement for all recommendations;
- mapping to durable `review-finding-v1` records when needed.

After implementation, produce child-owned
`support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md`.

## Phase 3: Validator And Fixtures

Implement only the accepted `lifecycle-postmortem-validator` child after the
workflow output layout and evaluator schema/template are stable.

Required outcomes:

- add
  `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-postmortem.sh`;
- add
  `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-postmortem.sh`;
- add positive and negative fixtures under
  `.octon/framework/assurance/runtime/_ops/fixtures/lifecycle-postmortem/`;
- add
  `.octon/framework/assurance/functional/suites/lifecycle-postmortem-integrity.yml`;
- add `.octon/instance/assurance/runtime/lifecycle-postmortem.yml`.

The validator must be deterministic and model-free. It must validate:

- required report sections and structured output schema version;
- final judgment enum;
- evidence references and known limits;
- generated/input non-authority classification;
- non-authority statement;
- optional `review-finding-v1` records when emitted;
- invariant compliance section ordering, ratings, evidence gaps, blocking
  status, and required correction fields;
- invariant validity/evolution section ordering, recommendation categories,
  required changes, and change-control bars.

Negative fixtures must fail for:

- generated output treated as authority;
- raw input treated as authority;
- missing or unresolved evidence references;
- invalid final judgment;
- missing patch-versus-redesign reasoning;
- missing invariant compliance review;
- Unknown treated as Pass;
- material invariant failure without evidence gap, blocking status, or required
  correction;
- missing invariant validity/evolution review;
- invalid invariant recommendation category;
- non-`Keep` invariant recommendation without required change;
- relaxation, removal, narrowing, downgrading, or addition recommendation
  without high or very high scrutiny;
- evaluator report claiming an invariant change was approved or enacted.

After implementation, produce child-owned
`support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md`.

## Validation Requirements

Before durable implementation begins:

- parent review gate with implementation authorization;
- parent child-readiness gate;
- parent program-structure validator;
- child review gate with implementation authorization for each child being
  implemented;
- child implementation-readiness validator for each child being implemented.

After each child implementation:

- run that child's proposal standard and architecture validators;
- run validators and tests declared by the child;
- run adjacent validators required by touched durable targets;
- retain child-owned implementation evidence;
- write and pass child-owned implementation conformance and drift/churn
  reviews.

After all implemented children:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-postmortem.sh --run-id <fixture-run-id>
```

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-postmortem.sh
```

Run these parent checks again:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program
```

Do not refresh generated proposal registries unless the implementation route
explicitly owns that generated-output update.

## Child Authority And Evidence

Each child owns its own:

- durable promotion targets;
- implementation plan;
- validators;
- evidence requirements;
- rollback posture;
- `support/implementation-conformance-review.md`;
- `support/post-implementation-drift-churn-review.md`;
- closeout and archive evidence.

Parent summaries may summarize child outcomes but must never satisfy child
receipts, child promotion targets, child validation verdicts, child archive
metadata, or child rollback evidence.

## Parent Implementation-Run Evidence

After child implementation work is complete enough for the parent program to
claim implementation execution, write parent-local
`support/program-implementation-orchestration-run.md` with at least:

```yaml
verdict: pass|fail
implemented_at: <UTC timestamp>
promotion_evidence_count: <number>
child_authority_preserved: yes|no
```

Use `verdict: pass` and `child_authority_preserved: yes` only when:

- required child manifests, receipts, validation verdicts, promotion targets,
  closeout metadata, and archive metadata remain child-owned;
- every implemented required child has child-owned implementation evidence;
- every implemented required child has passing implementation-conformance and
  post-implementation drift/churn evidence before closeout or implemented
  archival;
- durable promotion evidence exists outside proposal-local inputs;
- no generated, proposal-local, external, tool, dashboard, MCP, host-state, or
  agent-output surface is treated as authority.

Parent `support/program-implementation-orchestration-run.md` may summarize
child outcomes, but it does not satisfy child receipts.

## Terminal Criteria

This prompt is complete when it has been used to drive an implementation run
that either:

- completes all required child-owned implementation work allowed by the parent
  sequence and records parent
  `support/program-implementation-orchestration-run.md`; or
- stops at the first blocking child-owned stale receipt, failed validator,
  dependency failure, authority-boundary conflict, or scope-overrun risk and
  records the blocker without promoting unsupported claims.

Do not archive the parent program, close out child packets, promote final
lifecycle-postmortem support claims, or make lifecycle postmortems mandatory
unless the active lifecycle route and operator approval explicitly authorize
those later stages.
