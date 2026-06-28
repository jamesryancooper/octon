prompt_id: product-feature-catalog-documentation-and-drift-gate-program-implementation-orchestration-prompt-20260627
generated_at: 2026-06-27T18:02:27Z
route_id: generate-program-implementation-orchestration-prompt
parent_program_path: .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate
readiness_verdict: pass
child_authority_preservation_required: yes

# Program Implementation Orchestration Prompt

Use this prompt to orchestrate implementation for the accepted parent proposal
program:

`.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate`

This prompt is parent-local coordination guidance only. It does not implement
child packets, update product feature catalog entries, add validators, change
delivery workflows, promote, archive, deliver, close out, or mint authority.

## Preflight Gates

Before executing implementation work, rerun and require passing results from:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate --require-implementation-authorization
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate
```

Stop if any gate fails, any child review is stale, any child packet loses
implementation authorization, any child-owned readiness receipt is missing, or
any dependency/cutover constraint is incoherent.

## Authority Boundaries

- The parent program is coordination lineage only.
- Parent evidence cannot satisfy child receipts, child promotion targets, child
  validation verdicts, child implementation evidence, child closeout evidence,
  or child archive metadata.
- Each child must use its own `proposal.yml`, `architecture-proposal.yml`,
  `architecture/**`, `validation-plan.md`, support receipts, promotion targets,
  acceptance criteria, and authority notes.
- Do not mutate a sibling packet unless the active child packet explicitly
  requires that sibling-local consistency change.
- Generated outputs, raw inputs, host UI state, chat/model memory, and tool
  availability are non-authority unless backed by authored runtime, spec,
  validator, or retained evidence surfaces.
- Product feature catalog entries remain navigation-only. They do not mint
  runtime routes, generated-effective state, support claims, or execution
  evidence.
- The feature-catalog drift gate may recommend or block closeout claims; it
  must not silently rewrite product docs or authorize execution.

## Execution Sequence

Run child implementations in the parent-declared sequential order:

1. `.octon/inputs/exploratory/proposals/architecture/document-current-product-feature-gaps`
2. `.octon/inputs/exploratory/proposals/architecture/feature-catalog-drift-closeout-gate`
3. `.octon/inputs/exploratory/proposals/architecture/feature-catalog-drift-validator`
4. `.octon/inputs/exploratory/proposals/architecture/closeout-integration-and-receipts`

Dependency notes:

- Child 1 establishes the product feature catalog target state and must land
  before enforcement depends on complete catalog coverage.
- Child 2 depends on child 1 and defines the receipt/gate contract.
- Child 3 depends on child 2 and implements validator detection and negative
  controls for the gate contract.
- Child 4 depends on children 2 and 3 and wires validator/receipt results into
  proposal packet delivery, proposal program delivery, and proposal packet
  terminal closeout.

## Child 1 - Document Current Product Feature Gaps

Path:
`.octon/inputs/exploratory/proposals/architecture/document-current-product-feature-gaps`

Use only this child's own manifest, scope, promotion targets, validation plan,
and acceptance criteria. This child owns documentation updates for the current
feature gaps. It does not implement the automatic drift gate.

Promotion targets:

- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/product/features/README.md`
- `.octon/framework/product/features/`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh`

Document the accepted audit feature set, grouped coherently by subsystem:

- `engagement-change-package-compiler`
- `mission-autonomy-and-planning`
- `continuous-stewardship-runtime`
- `connector-admission-runtime`
- `self-evolution-runtime`
- `trust-compatibility-and-portable-proof`
- `runtime-effective-publication-and-routing`
- `operator-read-models`
- `run-first-runtime-lifecycle`
- `repo-hygiene-cleanup`
- `host-tool-provisioning`
- `repository-bootstrap-and-harness-portability`
- `grounded-query-retrieval`
- `deterministic-filesystem-observation`
- `native-agent-platform-interop`
- `workflow-authoring-and-studio`
- `native-service-runtime-and-catalog`
- `support-universe-admission-and-disclosure`
- `context-pack-builder-and-binding`
- `execution-authorization-and-effect-tokens`
- `evidence-store-and-proof-plane`
- `governed-promotion-activation-and-recertification`
- `workflow-statechart-task-harness`
- `proposal-packet-authoring-validation-archival`

Acceptance/validation obligations:

- Every audited feature id is represented in `catalog.yml` with accurate
  implementation status and complete reference sections.
- Existing partially documented surfaces are expanded, merged, split, renamed,
  downgraded, or explicitly folded into a documented parent feature according
  to child-local evidence.
- Feature notes exist where human boundary explanation is necessary.
- Generated outputs, raw inputs, host projections, and evidence paths carry
  explicit non-authority or evidence-only notes.
- Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/document-current-product-feature-gaps --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/document-current-product-feature-gaps
```

Before child closeout or implemented archival, produce and pass this child's:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

## Child 2 - Feature Catalog Drift Closeout Gate

Path:
`.octon/inputs/exploratory/proposals/architecture/feature-catalog-drift-closeout-gate`

Use only this child's own manifest, scope, promotion targets, validation plan,
and acceptance criteria. This child defines the gate and receipt contract. It
does not implement the full validator or workflow integration by itself.

Promotion targets:

- `.octon/framework/product/contracts/feature-catalog-drift-receipt-v1.schema.json`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/`

Acceptance/validation obligations:

- Define the feature-catalog drift receipt contract.
- Define explicit no-change, documented-change, documented-retirement, and
  blocked-unresolved-drift outcomes.
- Classify additions, removals, retirements, renames, splits, merges, status
  changes, material boundary updates, stale refs, and authority note drift.
- Keep the gate evidence-only and non-authorizing.
- Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --receipt <fixture>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-workflow.sh
```

Before child closeout or implemented archival, produce and pass this child's:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

## Child 3 - Feature Catalog Drift Validator

Path:
`.octon/inputs/exploratory/proposals/architecture/feature-catalog-drift-validator`

Use only this child's own manifest, scope, promotion targets, validation plan,
and acceptance criteria. This child owns validator logic and tests. It does not
own workflow integration or catalog documentation updates except
validator-aware checks.

Promotion targets:

- `.octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

Acceptance/validation obligations:

- Flag missing catalog entries for new implemented product-facing or
  cross-surface features.
- Flag stale entries for removed or retired features.
- Flag under-documented changed features when refs, evidence, validators,
  related docs, or authority notes no longer match reality.
- Flag status mismatches.
- Represent rename, split, merge, and downgrade cases.
- Exclude non-product-feature helpers, generated-only projections, raw inputs,
  and capability-library-only surfaces with explicit rationale.
- Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --fixture missing-catalog-entry
bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --fixture stale-ref
bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --fixture status-mismatch
bash .octon/framework/assurance/runtime/_ops/tests/test-feature-catalog-drift-closeout.sh
```

Before child closeout or implemented archival, produce and pass this child's:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

## Child 4 - Closeout Integration And Receipts

Path:
`.octon/inputs/exploratory/proposals/architecture/closeout-integration-and-receipts`

Use only this child's own manifest, scope, promotion targets, validation plan,
and acceptance criteria. This child owns workflow integration and receipt
wiring. It depends on the gate contract and validator.

Promotion targets:

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/`
- `.octon/framework/product/contracts/proposal-packet-delivery-receipt-v1.schema.json`
- `.octon/framework/product/contracts/proposal-program-delivery-receipt-v1.schema.json`
- `.octon/framework/product/contracts/proposal-packet-terminal-closeout-receipt-v1.schema.json`

Acceptance/validation obligations:

- Proposal packet delivery cannot emit completed delivery when unresolved
  feature-catalog drift exists.
- Proposal program delivery cannot emit completed delivery when unresolved
  child or parent feature-catalog drift exists.
- Proposal packet terminal closeout cannot emit archive-ready when unresolved
  feature-catalog drift exists.
- Receipts cite catalog validation result, drift result, affected feature ids,
  required documentation action, and authority notes.
- Workflow validators enforce the new stage and receipt refs.
- Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --receipt <delivery-receipt>
```

Before child closeout or implemented archival, produce and pass this child's:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

## Parent Run Evidence Required After Execution

After child implementation orchestration completes, write only parent-local
coordination evidence at:

`.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate/support/program-implementation-orchestration-run.md`

That parent-local run evidence must include at minimum:

- `verdict`
- `implemented_at`
- `promotion_evidence_count`
- `child_authority_preserved`

Use `verdict: pass` and `child_authority_preserved: yes` only when:

- all implemented child packets produced their own required implementation
  evidence and validation results;
- all implemented child packets produced and passed
  `support/implementation-conformance-review.md`;
- all implemented child packets produced and passed
  `support/post-implementation-drift-churn-review.md`;
- child manifests, child receipts, child promotion targets, child validation
  verdicts, and child archive metadata remain child-owned;
- parent evidence only summarizes child outcomes and does not satisfy child
  receipts or child lifecycle truth.

## Stop Conditions

Stop before downstream program promotion, verification, closeout, or archive if:

- any child validator fails;
- any child conformance or drift/churn review fails or is missing;
- a child requires a sibling mutation not authorized by that child packet;
- generated/raw/host/chat/tool state is treated as authority;
- the parent receipt is being used to satisfy a child receipt;
- implementation would require product catalog, validator, workflow, or
  receipt-contract work outside the active child promotion targets.

## Recommended Next Route

Use the generated prompt to run the implementation orchestration route for the
accepted child sequence, commonly surfaced as
`run-program-implementation-orchestration`. Do not run program promotion,
verification, closeout, archive, delivery, staging, or commit routes until the
child-owned implementation receipts and parent-local
`program-implementation-orchestration-run.md` exist and pass their gates.
