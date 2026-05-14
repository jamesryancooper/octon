# Executable Program Implementation Prompt

prompt_id: governed-workflow-runtime-transition-program-implementation-prompt-20260513T123609Z
generated_at: 2026-05-13T12:36:09Z
generator: codex-proposal-packet-lifecycle-generate-program-implementation-prompt
program_packet_path: .octon/inputs/exploratory/proposals/architecture/governed-workflow-runtime-transition-program
parent_review_digest_at_generation: sha256:12d88c7ab11a805b44ea98c50bf5bbe7f8da4e086ca111e4d572d25f6d418458
verdict: ready-for-program-implementation

## Gate Snapshot

This prompt was generated only after these parent pre-implementation gates
passed:

- `validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/governed-workflow-runtime-transition-program --require-implementation-authorization`
- `validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/governed-workflow-runtime-transition-program`
- `validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/governed-workflow-runtime-transition-program`

The parent review authorizes implementation prompt generation only. It does not
implement, promote, close out, archive, or make live any runtime behavior.

## Implementation Task

Implement the Governed Workflow Runtime transition by executing the required
child proposal packets in the parent registry sequence, while preserving every
child packet as the owner of its own manifest, acceptance criteria, validation
verdicts, implementation receipts, promotion targets, closeout evidence, and
archive metadata.

Use the parent program only for coordination, dependency ordering, aggregate
evidence, and final parent implementation-run evidence. Parent evidence may
summarize child outcomes, but it must never satisfy child receipts.

## Required Authority Boundaries

- Do not treat this parent program as runtime, policy, support, evidence,
  connector, or closeout authority.
- Do not treat child readiness summaries in the parent as child-owned proof.
- Do not treat generated projections, proposal-local files, chat transcripts,
  agent output, external dashboards, tool availability, MCP server availability,
  Durable Object state, or external workflow-engine state as authority.
- Do not broaden a child packet beyond its child-owned manifest, promotion
  targets, acceptance criteria, and validators.
- Do not implement deferred or lab-only candidates unless an accepted later
  parent registry mutation makes them required.
- Preserve current canonical runtime contracts until a child-owned accepted
  packet proves, validates, promotes, and records replacement or cutover
  evidence.

## Parent-Owned Coordination Work

The implementation agent must:

1. Re-read the parent program package and every required child packet from live
   files before changing durable targets.
2. Re-run the parent strict review gate and child-readiness gate immediately
   before implementation work begins.
3. Execute child packets according to the dependency sequence below.
4. Keep durable implementation evidence outside proposal-local inputs except
   for child-owned and parent-owned lifecycle receipts required by the active
   proposal lifecycle.
5. Record aggregate parent implementation evidence in
   `support/implementation-run.md` only after child-owned implementation
   evidence exists and child authority has remained preserved.

## Child-Owned Implementation Targets

| Phase | Child packet | Dependency gate | Promotion targets |
| --- | --- | --- | --- |
| 0 | `.octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update` | none | `.octon/README.md`; `.octon/AGENTS.md`; `.octon/instance/ingress/AGENTS.md`; `.octon/instance/bootstrap/START.md`; `.octon/framework/cognition/_meta/terminology/glossary.md`; `.octon/framework/cognition/_meta/architecture/specification.md`; `.octon/framework/cognition/_meta/architecture/contract-registry.yml` |
| 1 | `.octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails` | after phase 0 verification | `.octon/framework/cognition/_meta/terminology/naming-constitution.md`; `.octon/framework/cognition/_meta/terminology/glossary.md`; `.octon/framework/cognition/_meta/architecture/specification.md`; `.octon/README.md`; `.octon/AGENTS.md`; `.octon/instance/ingress/AGENTS.md` |
| 2 | `.octon/inputs/exploratory/proposals/architecture/workflow-statechart-task-specific-execution-harness` | after phase 1 verification | `.octon/framework/engine/runtime/spec/`; `.octon/framework/constitution/contracts/runtime/`; `.octon/framework/assurance/runtime/_ops/scripts/`; `.octon/generated/cognition/projections/materialized/` |
| 3 | `.octon/inputs/exploratory/proposals/architecture/agent-node-model-call-contract` | after phase 2 verification | `.octon/framework/engine/runtime/spec/`; `.octon/framework/constitution/contracts/runtime/`; `.octon/instance/governance/policies/`; `.octon/framework/assurance/runtime/_ops/scripts/` |
| 4a | `.octon/inputs/exploratory/proposals/architecture/workflow-history-replay-idempotency-compensation` | after phase 2 verification | `.octon/framework/engine/runtime/spec/`; `.octon/framework/constitution/contracts/runtime/`; `.octon/framework/assurance/runtime/_ops/scripts/`; `.octon/state/evidence/` |
| 4b | `.octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage` | after phase 2 verification | `.octon/framework/engine/runtime/spec/`; `.octon/framework/engine/runtime/crates/`; `.octon/framework/assurance/runtime/_ops/scripts/`; `.octon/framework/assurance/runtime/_ops/tests/` |
| 5 | `.octon/inputs/exploratory/proposals/architecture/evidence-provenance-hardening` | after phase 3, 4a, and 4b verification | `.octon/framework/engine/runtime/spec/`; `.octon/framework/constitution/obligations/evidence.yml`; `.octon/framework/constitution/contracts/retention/`; `.octon/framework/constitution/contracts/disclosure/`; `.octon/framework/assurance/runtime/_ops/scripts/` |
| 6 | `.octon/inputs/exploratory/proposals/architecture/connector-operation-admission` | after phase 4b and phase 5 verification | `.octon/instance/governance/connector-admissions/`; `.octon/instance/governance/connectors/`; `.octon/framework/constitution/contracts/adapters/`; `.octon/framework/assurance/runtime/_ops/scripts/` |
| 7 | `.octon/inputs/exploratory/proposals/architecture/migration-cutover-compatibility-retirement` | after closeout-ready evidence for all prerequisites | `.octon/framework/cognition/_meta/terminology/naming-constitution.md`; `.octon/framework/cognition/_meta/terminology/glossary.md`; `.octon/framework/cognition/_meta/architecture/specification.md`; `.octon/README.md`; `.octon/AGENTS.md`; `.octon/instance/ingress/AGENTS.md`; `.octon/instance/bootstrap/START.md` |

## Allowed Parallel Groups

- Phase 4a and phase 4b may run in gated parallel after phase 2 has verified.
- No phase 5 evidence/provenance work may start until phase 3, phase 4a, and
  phase 4b have child-owned verification evidence.
- No phase 6 connector-admission work may start until effect-token coverage and
  evidence/provenance hardening are verified.
- Phase 7 cutover must run last and must wait for child-owned terminal or
  closeout-ready evidence from every required prerequisite.

## Deferred And Lab-Only Scope

Do not implement these registry entries in this program implementation run:

- `.octon/inputs/exploratory/proposals/architecture/durable-coordination-adapter-evaluation`
- `.octon/inputs/exploratory/proposals/architecture/mcp-integration-evaluation`
- `.octon/inputs/exploratory/proposals/architecture/external-workflow-engine-adapter-evaluation`

They remain non-required, deferred, lab-only, and rejected as authority unless a
later accepted parent registry mutation changes their status.

## Preflight Commands

Run these before durable implementation begins:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/governed-workflow-runtime-transition-program --require-implementation-authorization
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/governed-workflow-runtime-transition-program
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/governed-workflow-runtime-transition-program
```

For each required child packet, also run the child-owned review gate and
readiness validators before modifying durable targets:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <child-packet-path> --require-implementation-authorization
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package <child-packet-path>
```

## Child Execution Requirements

For each implemented child packet:

1. Re-read its `proposal.yml`, subtype manifest, acceptance criteria, validation
   plan, support receipts, and approved promotion targets.
2. Apply only the durable changes authorized by that child packet.
3. Preserve the child packet as the owner of implementation evidence.
4. Write or refresh the child-owned implementation evidence required by the
   active proposal lifecycle.
5. Run the child-owned validators declared by the child packet and any adjacent
   validators required by touched durable targets.
6. Produce and pass child-owned `support/implementation-conformance-review.md`
   and `support/post-implementation-drift-churn-review.md` before child closeout
   or implemented archival.
7. Stop and record the blocker if a child review digest is stale, a validator
   fails, a dependency is missing, or a child would need to exceed its manifest.

## Shared Runtime And Generated Surfaces

The program may coordinate changes touching these shared surfaces only through
the relevant child packets:

- runtime specs and runtime contracts under `.octon/framework/engine/runtime/`
  and `.octon/framework/constitution/contracts/runtime/`;
- effect-token and side-effect coverage under runtime crates, scripts, and
  tests;
- evidence, retention, disclosure, and provenance obligations;
- connector admission and adapter contract surfaces;
- generated materialized projections as derived outputs only;
- entry artifacts and terminology surfaces during the final compatibility and
  cutover phase.

Generated outputs remain derived-only. If a durable target requires generated
projection updates, update the authoritative source first, regenerate through
the established repository route, and keep generated artifacts from becoming
authority.

## Program Evidence Outputs

After child implementation work is complete enough for the parent program to
claim implementation execution, write parent-local
`support/implementation-run.md` with at least:

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
- no generated, proposal-local, external, tool, dashboard, MCP, Durable Object,
  or agent-output surface is treated as authority.

Parent `support/implementation-run.md` may summarize child outcomes, but it
does not satisfy child receipts.

## Terminal Criteria For This Prompt

This prompt is complete when it has been used to drive an implementation run
that either:

- completes all required child-owned implementation work allowed by the parent
  sequence and records parent `support/implementation-run.md`; or
- stops at the first blocking child-owned stale receipt, failed validator,
  dependency failure, authority-boundary conflict, or scope-overrun risk and
  records the blocker without promoting unsupported claims.

Do not archive the parent program, close out child packets, promote final
Governed Workflow Runtime claims, or run post-implementation proposal-program
closeout unless the active lifecycle route and operator approval explicitly
authorize those later stages.
