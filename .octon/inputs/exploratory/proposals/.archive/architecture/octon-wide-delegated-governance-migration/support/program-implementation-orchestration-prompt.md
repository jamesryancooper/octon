# Program Implementation Orchestration Prompt

program_implementation_orchestration_prompt_id: octon-wide-delegated-governance-migration-program-implementation-orchestration-prompt-2026-06-09
proposal_path: .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
route_id: generate-program-implementation-orchestration-prompt
lifecycle_id: proposal-program
status: operational-aid
generated_at: 2026-06-09T17:16:07Z

This prompt is an operational aid for implementing the accepted proposal
program. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, or substitute for child-owned
receipts and retained evidence.

The parent packet coordinates sequence, dependency gates, aggregate evidence,
and closeout refusal criteria only. It must not write child validation
verdicts, child archive metadata, child receipts, child promotion targets,
child terminal outcomes, or child implementation truth.

Durable authority may land only in each child packet's declared promotion
targets after the child packet's own gates pass. Proposal files, generated
proposal registry entries, generated projections, read models, chat history,
host state, tool availability, dashboards, external systems, and model output
are implementation inputs or derived context only; they are not runtime,
policy, permission, support, promotion, or closeout authority.

## Prompt Generation Gate Receipt

The required parent review gate passed before this prompt was written:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0`.

The required program child-readiness gate also passed before this prompt was
written:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
```

Observed result at prompt-generation time: `errors=0 warnings=0`.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: coordinate one Octon-wide delegated governance migration
  through child-owned implementation packets and fail closed on stale child
  receipts, missing proof, or parent-owned child authority
- transitional exception: not authorized

## Mandatory Parent Preflight

Before durable edits or child execution, re-read the parent packet manifest,
architecture proposal, source-of-truth map, child registry, child contract,
packet sequence, target architecture, implementation plan, acceptance
criteria, validation plan, risk register, implementation-grade review, and
proposal review. Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
```

Refuse program implementation orchestration unless all parent preflight
commands pass, `proposal.yml#status` is `accepted`, the parent review verdict
is `accepted`, implementation prompt generation remains authorized, and the
reviewed packet digest is fresh.

## Mandatory Child Preflight

Before implementing any child packet, re-read that child packet's
`proposal.yml`, subtype manifest, source-of-truth map, target architecture,
implementation plan, acceptance criteria, validation plan, risk register,
implementation-grade review, proposal review, and
`support/executable-implementation-prompt.md`.

For each child, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child-packet-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <child-packet-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <child-packet-path> --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package <child-packet-path>
```

Refuse that child implementation unless all child preflight commands pass, the
child status is `accepted`, the child review verdict is `accepted`, child
implementation is authorized, and the child reviewed packet digest is fresh.

## Execution Graph

Execute only the required, non-deferred children from
`resources/child-packet-index.yml`. Preserve the child dependency gates exactly:

1. Implement `delegated-governance-inventory-and-vocabulary`.
2. Implement `delegated-governance-shared-contract-model` only after the
   inventory child has passing implementation conformance and
   post-implementation drift/churn receipts.
3. Implement the phase-3 domain children only after the shared contract model
   has passing implementation conformance and post-implementation drift/churn
   receipts:
   - `authority-engine-typed-exception-grants`
   - `mission-runtime-proof-first-posture`
   - `connector-external-effect-delegation-boundaries`
   - `run-health-proof-state-read-models`
   - `workflow-capability-human-boundary-classification`
4. Implement `governance-validator-negative-controls` only after all phase-3
   domain children have passing implementation conformance and
   post-implementation drift/churn receipts.
5. Implement `delegated-governance-cutover-closeout` last, only after the
   validator child and its required predecessors have terminal child-owned
   outcomes and fresh child-owned receipts.

The parent registry declares `gated-parallel`, but do not run children in
parallel unless the actual file-level write sets are conflict-free or a
single accountable orchestrator owns integration. When declared write scopes
overlap, sequence the children or record an explicit integration plan before
editing durable surfaces.

## Child Implementation Map

| Child | Purpose | Declared promotion targets |
| --- | --- | --- |
| `delegated-governance-inventory-and-vocabulary` | Inventory approval/default-authority surfaces and lock vocabulary. | `.octon/framework/constitution/contracts/authority/`, `.octon/framework/engine/runtime/spec/`, `.octon/framework/orchestration/governance/`, `.octon/framework/capabilities/governance/policy/` |
| `delegated-governance-shared-contract-model` | Define proof-first delegated governance contract semantics for non-lifecycle surfaces. | `.octon/framework/constitution/contracts/authority/`, `.octon/framework/constitution/contracts/runtime/`, `.octon/framework/engine/runtime/spec/` |
| `authority-engine-typed-exception-grants` | Replace generic authority-engine approval defaults with typed human exception grants and grant-consumption evidence. | `.octon/framework/engine/runtime/crates/authority_engine/`, `.octon/framework/constitution/contracts/authority/`, `.octon/framework/assurance/runtime/_ops/tests/` |
| `mission-runtime-proof-first-posture` | Normalize mission/runtime dispatch around retained proof and typed human boundaries. | `.octon/framework/engine/runtime/crates/kernel/`, `.octon/framework/engine/runtime/spec/`, `.octon/framework/constitution/contracts/runtime/` |
| `connector-external-effect-delegation-boundaries` | Define connector and external-effect delegation boundaries with token, rollback, compensation, egress, and irreversibility proof. | `.octon/instance/governance/connectors/`, `.octon/framework/constitution/contracts/adapters/`, `.octon/framework/engine/runtime/spec/`, `.octon/framework/assurance/runtime/_ops/tests/` |
| `run-health-proof-state-read-models` | Update run-health/read-model vocabulary so projections report proof state without becoming control authority. | `.octon/framework/engine/runtime/spec/`, `.octon/framework/assurance/runtime/_ops/scripts/`, `.octon/generated/cognition/projections/materialized/` |
| `workflow-capability-human-boundary-classification` | Normalize workflow and capability classifications around typed proof boundaries instead of route shape or importance. | `.octon/framework/orchestration/governance/`, `.octon/framework/capabilities/governance/policy/`, `.octon/framework/engine/runtime/spec/` |
| `governance-validator-negative-controls` | Add cross-domain validators and negative controls for approval defaults, missing proof, generated authority misuse, and stale or mismatched evidence. | `.octon/framework/assurance/runtime/_ops/scripts/`, `.octon/framework/assurance/runtime/_ops/tests/`, `.octon/framework/constitution/contracts/authority/` |
| `delegated-governance-cutover-closeout` | Perform final compatibility retirement, cutover, aggregate evidence review, and parent-program closeout support. | `.octon/framework/constitution/contracts/authority/`, `.octon/framework/constitution/contracts/runtime/`, `.octon/framework/engine/runtime/spec/`, `.octon/framework/assurance/runtime/_ops/scripts/`, `.octon/framework/assurance/runtime/_ops/tests/`, `.octon/framework/product/features/lifecycle-autopilot.md` |

## Child Evidence Requirements

Each implemented child must retain its own implementation evidence outside
proposal-local inputs. Use each child prompt's retained evidence root and
record at minimum:

- repository reconnaissance receipt;
- implementation run receipt;
- validation command outputs;
- rollback posture note;
- implementation conformance receipt;
- post-implementation drift/churn receipt;
- promotion evidence for the child-owned durable outputs;
- generated/read-model non-authority proof where the child touches generated
  or projection surfaces;
- negative-control evidence where the child packet requires it.

Each implemented child packet must produce and pass both:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Do not close out, mark implemented, promote, or archive a child as implemented
unless those child-owned receipts pass and remain fresh against the live child
packet and durable work.

## Program Run Receipt

After executing the program orchestration attempt, write the parent-local run
receipt:

```text
.octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration/support/program-implementation-orchestration-run.md
```

The receipt must include at least:

- `verdict: pass|fail|blocked|deferred`
- `implemented_at: <UTC timestamp or n/a>`
- `promotion_evidence_count: <integer>`
- `child_authority_preserved: yes|no`

Also include:

- child receipt summary count;
- child outcomes by child id;
- retained evidence references outside proposal-local inputs;
- commands run and final summaries;
- blockers, unresolved questions, or stale receipts;
- parent authority-boundary statement confirming the parent did not satisfy or
  replace child receipts, child validation verdicts, child promotion targets,
  child archive metadata, or child terminal outcomes.

Parent implementation-run evidence may summarize child outcomes but never
satisfies child receipts, child promotion targets, child validation verdicts,
or child archive metadata.

## Validation

At the end of every child implementation, run that child packet's declared
validators plus:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child-packet-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <child-packet-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package <child-packet-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child-packet-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child-packet-path>
```

After child execution and before a passing parent program run receipt, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
```

If durable generated projections are refreshed by a child, retain the
child-owned generation, publication, or freshness evidence required by that
child. Generated projections remain derived-only and cannot authorize runtime
dispatch, grant permissions, classify human boundaries, or prove cutover
completion by themselves.

## Rollback And Closeout Refusal

Rollback is child-scoped first: revert the durable changes owned by the failed
child attempt, preserve retained evidence needed to explain the failure, and
do not rewrite parent program truth to hide the child failure.

Refuse parent pass, child closeout, implemented status, promotion, or archival
when any of these conditions hold:

- a required child is non-terminal when the current route requires terminal
  child outcomes;
- a required child has stale, missing, or failing proposal review,
  implementation run, implementation conformance, post-implementation
  drift/churn, validation, or promotion evidence;
- the parent owns or rewrites child implementation truth, validation truth,
  archive truth, terminal outcome truth, or promotion target truth;
- generic approval defaults remain in a migrated domain without an explicit
  typed human exception justification;
- external irreversible effects are delegated without token, rollback,
  compensation, egress, and irreversibility proof;
- generated projections, read models, dashboards, external systems, tool
  availability, chat history, or agent output are used as authority;
- durable authority lands outside a child packet's declared promotion targets
  without a separate accepted proposal route.
