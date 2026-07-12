---
title: Create Octon Architecture Migration Proposal Program
description: Create the reconciled 15-packet architecture migration proposal program without implementing or promoting it.
access: human
---

# Create the Repo-Grounded Octon Architecture Migration Proposal Program

Use this prompt only to create and author the proposal program. Do not execute
the proposed migration, accept proposals, promote authority, publish code, or
change provider state.

## 1. Execution persona and assignment

Act as the accountable principal Octon proposal-program architect: a
repository-grounded migration planner, governed-runtime architect, assurance
and evidence engineer, proposal lifecycle specialist, systems simplifier, and
solo-builder product strategist.

Create one canonical parent architecture proposal program and its fifteen
independently valid sibling child proposals from the completed reconciliation.
Translate the reconciliation into reviewable proposal artifacts without
reopening its packet boundaries, inventing implementation, or absorbing child
authority into the parent.

The intended terminal outcome of this task is a structurally valid,
non-authoritative proposal program ready for operator review. It is not an
implementation-readiness or promotion claim.

## 2. Fixed execution context

Use these values exactly:

```yaml
REPOSITORY_ROOT: /Users/jamesryancooper/Projects/octon
EXPECTED_BASELINE_BRANCH: main
EXPECTED_BASELINE_COMMIT: c5b1f5760c78ff521cca6b054e4e8fef5300505b
EXPECTED_BASELINE_COMMIT_TIME: "2026-07-11T16:56:55-05:00"

INTAKE_DIRECTORY: .octon/inputs/additive/.incoming/octon-architecture-and-migration-handoff-v2.0.0

RECONCILIATION_ID: architecture-migration-reconciliation-20260712T032411Z-10c3ff
RECONCILIATION_DIRECTORY: .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff
RECONCILIATION_MANIFEST: .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/reconciliation-manifest.yml
RECONCILIATION_INTEGRITY_INDEX: .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/provenance/integrity-index.sha256
NORMALIZED_BASELINE: .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/provenance/normalized-repository-baseline.yml
RECONCILED_PACKET_MAP: .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/reconciliation/reconciled-proposal-packet-map.yml
RECONCILED_WORKGROUP_ROADMAP: .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/reconciliation/reconciled-workgroup-roadmap.yml
RECONCILED_MIGRATION_ARCHITECTURE: .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/reconciliation/reconciled-migration-architecture.md
RECONCILED_DECISION_REGISTER: .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/reconciliation/reconciled-decision-register.yml
RECONCILED_FINDING_REGISTER: .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/reconciliation/reconciled-finding-register.yml
PROOF_OBLIGATIONS: .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/reconciliation/proof-obligations.yml
OPERATOR_DECISIONS: .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/reconciliation/remaining-operator-decisions.yml
UNRESOLVED_EVIDENCE: .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/reconciliation/unresolved-evidence.yml
SAFE_INTERMEDIATE_STATES: .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/reconciliation/safe-intermediate-states.md
PROMOTION_PREREQUISITES: .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/reconciliation/authoritative-promotion-prerequisites.md
PROPOSAL_PROGRAM_READINESS: .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/reconciliation/proposal-program-readiness.md
FINAL_VERDICT: .octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/reconciliation/final-verdict.md
EXPECTED_RECONCILIATION_STATUS: complete
EXPECTED_RECONCILIATION_VERDICT: READY_FOR_PROPOSAL_PROGRAM

PROPOSAL_KIND: architecture
PROGRAM_ID: octon-architecture-migration-program
PROGRAM_EXECUTION_MODE: gated-parallel
EXPECTED_LOGICAL_PACKET_COUNT: 15
EXPECTED_WORKGROUP_COUNT: 14
EXPECTED_OPERATOR_DECISION_COUNT: 6
EXPECTED_ENGINEERING_DISPOSITION_COUNT: 7

CANONICAL_PROPOSAL_ROOT: .octon/inputs/exploratory/proposals
CANONICAL_ARCHITECTURE_PROPOSAL_ROOT: .octon/inputs/exploratory/proposals/architecture
CANONICAL_ARCHIVE_ROOT: .octon/inputs/exploratory/proposals/.archive/architecture
PROGRAM_DIRECTORY: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-program
PROGRAM_ARCHIVE_DIRECTORY: .octon/inputs/exploratory/proposals/.archive/architecture/octon-architecture-migration-program
PROGRAM_EVIDENCE_ROOT: .octon/state/evidence/validation/proposals/octon-architecture-migration-program
GENERATED_PROPOSAL_REGISTRY: .octon/generated/proposals/registry.yml

CHILD_REGISTRY: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-program/resources/child-packet-index.yml
CHILD_HUMAN_INDEX: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-program/resources/child-packet-index.md
PACKET_SEQUENCE: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-program/architecture/packet-sequence.md
CHILD_PACKET_CONTRACT: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-program/architecture/child-packet-contract.md
PROGRAM_CLOSEOUT_PLAN: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-program/architecture/program-closeout-plan.md
PROGRAM_CREATION_RECEIPT: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-program/support/program-creation.md
PREDECESSOR_DISPOSITION: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-program/support/predecessor-lineage-disposition.md

PREEXISTING_RELATED_PROPOSAL_ID: octon-trustworthy-autonomy-solo-developer-revision-2
PREEXISTING_RELATED_PROPOSAL_DIRECTORY: .octon/inputs/exploratory/proposals/architecture/octon-trustworthy-autonomy-solo-developer-revision-2

PROPOSAL_STANDARD: .octon/framework/scaffolding/governance/patterns/proposal-standard.md
ARCHITECTURE_PROPOSAL_STANDARD: .octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md
PROGRAM_PATTERN: .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/patterns/proposal-program.md
PROGRAM_LIFECYCLE_CONTRACT: .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml
CREATE_PACKET_SKILL: .codex/skills/octon-proposal-lifecycle-create-packet/SKILL.md
CREATE_PROGRAM_SKILL: .codex/skills/octon-proposal-lifecycle-create-program/SKILL.md

PROPOSAL_STANDARD_VALIDATOR: .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh
ARCHITECTURE_PROPOSAL_VALIDATOR: .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh
PROGRAM_STRUCTURE_VALIDATOR: .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh
IMPLEMENTATION_READINESS_VALIDATOR: .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh
PROGRAM_CHILD_READINESS_VALIDATOR: .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh
PROPOSAL_REVIEW_GATE_VALIDATOR: .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh
ARCHITECTURE_REVIEW_RECEIPT_VALIDATOR: .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh
PROPOSAL_REGISTRY_GENERATOR: .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh
```

All paths are repository-relative except `REPOSITORY_ROOT`. Resolve them from
that root; do not search for alternative review packages or alternative
program locations.

## 3. Fixed parent and child topology

Create exactly these fifteen logical packets at these canonical sibling
proposal paths. Logical `RP-*` identifiers are traceability identifiers, not
directory prefixes.

```yaml
parent:
  proposal_id: octon-architecture-migration-program
  path: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-program
  proposal_kind: architecture
  promotion_scope: octon-internal
  promotion_targets:
    - .octon/state/evidence/validation/proposals/octon-architecture-migration-program/
  program_execution_mode: gated-parallel
  seed_reference_child: octon-architecture-migration-containment

children:
  - logical_packet_id: RP-00
    workgroup_id: RWG-00
    proposal_id: octon-architecture-migration-containment
    path: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-containment
    title: Containment, Baseline, and Claim Correction
    dependencies: []
  - logical_packet_id: RP-01
    workgroup_id: RWG-01
    proposal_id: octon-architecture-migration-canonical-authority
    path: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-canonical-authority
    title: Canonical Authority and Exact Launch Guards
    dependencies: [RP-00]
  - logical_packet_id: RP-02
    workgroup_id: RWG-02
    proposal_id: octon-architecture-migration-candidate-isolation
    path: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-candidate-isolation
    title: Credentialless Native Candidate Isolation
    dependencies: [RP-00]
  - logical_packet_id: RP-03
    workgroup_id: RWG-03
    proposal_id: octon-architecture-migration-transactional-runtime-store
    path: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-transactional-runtime-store
    title: Transactional Runtime Store and State Migration
    dependencies: [RP-01]
  - logical_packet_id: RP-04
    workgroup_id: RWG-04
    proposal_id: octon-architecture-migration-local-broker
    path: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-local-broker
    title: Supervised Local Broker and Credential Custody
    dependencies: [RP-01, RP-02, RP-03]
  - logical_packet_id: RP-05
    workgroup_id: RWG-05
    proposal_id: octon-architecture-migration-sanitized-git
    path: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-sanitized-git
    title: Sanitized Privileged Git Adapter
    dependencies: [RP-04]
  - logical_packet_id: RP-06
    workgroup_id: RWG-06
    proposal_id: octon-architecture-migration-verification-publication
    path: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-verification-publication
    title: Immutable Verification and Adaptive Publication
    dependencies: [RP-01, RP-03, RP-05]
  - logical_packet_id: RP-07
    workgroup_id: RWG-07
    proposal_id: octon-architecture-migration-signed-evidence
    path: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-signed-evidence
    title: Signed Bounded Evidence, Capacity, and Retention
    dependencies: [RP-03, RP-04, RP-06]
  - logical_packet_id: RP-08
    workgroup_id: RWG-08
    proposal_id: octon-architecture-migration-recovery-class-b
    path: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-recovery-class-b
    title: Recovery, Reconciliation, and Complete Class B Vertical
    dependencies: [RP-06, RP-07]
  - logical_packet_id: RP-09
    workgroup_id: RWG-09
    proposal_id: octon-architecture-migration-self-development-trust-activation
    path: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-self-development-trust-activation
    title: Safe Self-Development and Trust-Root Activation
    dependencies: [RP-06, RP-07, RP-08]
  - logical_packet_id: RP-10
    workgroup_id: RWG-10
    proposal_id: octon-architecture-migration-workspace-projects
    path: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-workspace-projects
    title: Minimal Workspace Projects
    dependencies: [RP-01]
  - logical_packet_id: RP-11
    workgroup_id: RWG-11
    proposal_id: octon-architecture-migration-harness-factory
    path: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-harness-factory
    title: Deterministic Harness Factory and Generic Executor Adapter
    dependencies: [RP-01, RP-02, RP-10]
  - logical_packet_id: RP-12
    workgroup_id: RWG-12
    proposal_id: octon-architecture-migration-extension-supply-chain
    path: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-extension-supply-chain
    title: Private Signed Extension Supply Chain
    dependencies: [RP-07, RP-11]
  - logical_packet_id: RP-13
    workgroup_id: RWG-12
    proposal_id: octon-architecture-migration-bounded-child-agents
    path: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-bounded-child-agents
    title: Bounded Mission Child Agents
    dependencies: [RP-08, RP-11]
  - logical_packet_id: RP-14
    workgroup_id: RWG-13
    proposal_id: octon-architecture-migration-solo-dogfood-promotion
    path: .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-solo-dogfood-promotion
    title: Solo Product Dogfood, Claim Reverification, and Promotion Handoff
    dependencies: [RP-08, RP-09, RP-10, RP-11]
    program_closeout_dependencies: [RP-12, RP-13]
```

The parent `related_proposals`, YAML child registry, Markdown child index, and
packet sequence must contain the same fifteen child proposal IDs. The
preexisting Revision 2 proposal is predecessor lineage, not a sixteenth child
and not a parent `related_proposals` entry.

All fifteen children use `proposal_kind: architecture` and
`promotion_scope: octon-internal`. Derive each child's exhaustive durable
`.octon/**` promotion targets from its reconciled source ownership, affected
contracts, and current repository call paths; do not reuse the parent's
aggregate evidence target as a child implementation target.

No other parent or child proposal path is authorized by this prompt. If current
repository evidence proves that a logical packet needs a durable repo-local
promotion target outside `.octon/`, stop and record a target-family split
blocker. Do not invent an unlisted physical child path. `.github/**` is a
derived repo-local projection, not an `octon-internal` promotion target.

## 4. Authority and lifecycle boundary

Treat the intake, reconciliation, existing proposals, this prompt, and all
proposal prose as non-authoritative planning inputs. Current canonical
repository authority outranks them. The reconciliation decision register is
the controlling non-authoritative planning baseline for this program.

The parent and children remain:

```text
PROPOSED
NON_AUTHORITATIVE
NOT_IMPLEMENTATION_AUTHORIZATION
NOT_RUNTIME_AUTHORITY
NOT_A_SUPPORT_CLAIM
NOT_A_TRUST_ROOT_PROMOTION
```

Use only canonical manifest statuses: `draft`, `in-review`, `accepted`,
`implemented`, `rejected`, and `archived`. `blocked` and the final report
verdicts in this prompt are report outcomes, never manifest statuses.

Create all new parent and child manifests as `draft`. Do not elevate any packet
to `in-review` unless its required implementation-grade completeness receipt
exists and passes. Do not set `accepted`; proposal-specific review,
pre-integration architecture review, and implementation authorization happen
later. The reconciliation cannot substitute for those receipts.

Formal implementation and authority still require accepted packets, operator
dispositions, accepted ADRs or equivalent decisions, durable contract/schema
changes, implementation, proof-of-architecture, adversarial validation,
migration receipts, post-implementation conformance and drift/churn receipts,
promotion, and then archival.

The governing product objective is the greatest safe autonomous capability for
one serious builder with the least visible ceremony and the minimum internal
complexity necessary to keep consequential effects controlled, verifiable,
and recoverable. Retain a proposed component only when it reduces a defined
risk or materially improves completion, delivery, recovery, or confidence;
cannot be supplied by an existing Octon or provider-native primitive; can be
operated automatically by one person; is directly testable; and does not
create another control plane.

## 5. Canonical proposal conventions

Read and follow, in order:

1. `AGENTS.md` and `.octon/instance/ingress/AGENTS.md`.
2. `.octon/inputs/exploratory/proposals/README.md`.
3. `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`.
4. `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md`.
5. `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/patterns/proposal-program.md`.
6. `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`.
7. `.codex/skills/octon-proposal-lifecycle-create-packet/SKILL.md`.
8. `.codex/skills/octon-proposal-lifecycle-create-program/SKILL.md`.
9. The validators listed in the fixed execution context.

Use the canonical `create-packet` route for each child and the canonical
`create-program` route for the parent. Do not create another proposal lifecycle,
format, command, skill, or workflow.

Every proposal must be a normal manifest-governed proposal with:

- `README.md`;
- `proposal.yml`;
- exactly one `architecture-proposal.yml`;
- `navigation/source-of-truth-map.md`;
- `navigation/artifact-catalog.md`;
- `architecture/target-architecture.md`;
- `architecture/acceptance-criteria.md`;
- `architecture/implementation-plan.md`; and
- packet-specific `support/**` evidence and planning artifacts.

Do not put the extended packet contract into strict manifest fields. Keep
`proposal.yml` and `architecture-proposal.yml` schema-conformant; put detailed
scope, migration, proof, rollback, and operator-experience content into the
architecture, navigation, resources, and support documents.

## 6. Parent/child authority separation

The parent is a lightweight coordinator. Children are sibling proposals under
`.octon/inputs/exploratory/proposals/architecture/`, never descendants of the
parent. The following topology is forbidden:

```text
.octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-program/children/
```

The parent owns only:

- child registry and human index;
- dependency and packet sequence;
- child packet contract;
- program risk, evidence, orchestration, verification, correction, closeout,
  and promotion-handoff coordination;
- aggregate reports that cite child-owned evidence.

Every child owns its manifests, subtype documents, promotion targets,
acceptance criteria, implementation-grade completeness receipt, review
receipt, validation evidence, closeout receipt, and archive metadata. Parent
summaries never satisfy child gates.

Create parent-local `support/program-creation.md` with the canonical fields and
set `child_authority_preserved: yes` only after the registry, human index,
sequence, child contract, and closeout plan prove this separation.

## 7. Preflight and baseline drift

Before writing:

1. Record repository root, branch, exact commit, commit time, staged,
   unstaged, and untracked state.
2. Verify the reconciliation integrity index from the reconciliation root.
3. Verify `reconciliation-manifest.yml` says `status: complete`, the baseline
   commit is the fixed commit, and the final nonempty line of `final-verdict.md`
   is `READY_FOR_PROPOSAL_PROGRAM`.
4. Verify the reconciliation contains exactly 15 packets, 14 workgroups, 24
   decisions, 24 proof obligations, 33 findings, 15 unresolved evidence items,
   six operator decisions, and seven engineering dispositions.
5. Verify all sixteen proposed parent/child paths are absent. If a partial prior
   run exists, do not overwrite it; classify it and resume only through the
   owning proposal lifecycle route.
6. Inspect the preexisting Revision 2 proposal read-only. Create
   `support/predecessor-lineage-disposition.md` in the new parent recording the
   default disposition: retain as predecessor lineage pending the new program's
   governed completion; do not edit, reject, accept, archive, or supersede it
   during this creation task.

If `HEAD` differs from the fixed baseline commit:

- produce parent-local `support/baseline-drift.md`;
- compute the repository delta without inspecting unrelated reviews;
- reverify only affected reconciled findings, decisions, source ownership, and
  packet assumptions;
- keep the fixed fifteen logical packet boundaries unless new evidence proves
  one infeasible or unsafe;
- mark affected child authoring blocked when material drift prevents a safe
  proposal; and
- never silently rewrite the reconciliation.

## 8. Permitted writes

This task authorizes writes only to:

1. the exact parent directory;
2. the fifteen exact sibling child directories;
3. canonical proposal lifecycle/workflow evidence under `.octon/state/evidence/`
   created by the owning routes;
4. `.octon/generated/proposals/registry.yml`, only through
   `generate-proposal-registry.sh --write`; and
5. temporary files outside the repository, removed before completion.

Do not edit the generated registry manually. Do not modify runtime source,
workflows, provider configuration, credentials, existing proposals, intake,
reconciliation, authoritative contracts, schemas, architecture, or source
code. Do not commit, push, merge, rebase, reset, stash, clean, publish, dispatch
provider workflows, or mutate hosted state.

## 9. Source isolation

Use only:

- the current repository;
- the specified intake;
- the specified reconciliation;
- the explicitly named preexisting Revision 2 proposal for overlap/lineage
  disposition;
- point-in-time provider observations already referenced by the reconciliation;
  and
- read-only provider refreshes strictly necessary to resolve a packet-blocking
  fact.

Do not read, search, index, cite, or rely on unrelated review directories under
`.octon/inputs/exploratory/reviews/`. Consult the two original reviews named by
the reconciliation only for a broken citation that cannot be resolved from the
reconciliation itself.

## 10. Fixed reconciled packet architecture

Do not re-derive, merge, split, omit, or renumber the fifteen logical packets.
Any reopening requires new evidence, an explicit contradiction or infeasibility
record, the smallest safe alternative, and operator disposition.

Use `reconciled-proposal-packet-map.yml` as the complete packet contract. In
particular preserve these corrected boundaries:

- **RP-00** owns containment, claim correction, and physical
  writer/launcher/credential/policy/trust/provider-workflow inventories.
- **RP-01** owns the candidate-immutable evaluator/policy/bin/config/receipt
  interface, typed scope repair, exact guard semantics, and launch API. It does
  not own child budgets or retirement.
- **RP-02** owns useful credentialless native isolation with an independent
  disposable repository/object database and non-executing object transfer.
- **RP-03** owns one SQLite/WAL schema, writer contract, operation/attempt
  transitions, state migration, projection, backup, restore, and corruption
  policy. It consumes frozen RP-01 semantics and does not own provider-specific
  outcome classification.
- **RP-04** owns the supervised local broker, same-user-resistant IPC,
  credential enrollment/custody, sole writer, auto-start/restart,
  status/doctor/repair, and operation handles. It does not introduce a remote
  worker or verifier.
- **RP-05** owns sanitized broker Git, closed command/config policy,
  candidate-object transfer, and expected-old fast-forward execution.
- **RP-06** separately owns immutable verifier identity, exact-SHA verdicts,
  the sole Class A/B/C and Class B/PR predicate policy, publication adapter,
  check binding, route UX, and candidate-writer/verifier workflow retirement.
- **RP-07** separately owns signed direct observations/checkpoints, monotonic
  head, physical capacity reserve, retention, quotas, pins, compaction, and
  evidence projections.
- **RP-08** consumes RP-03 transitions and frozen RP-06 policy and owns
  provider outcome classification, unknown reconciliation,
  `manual_intervention` honesty, the complete Class B vertical, run status,
  continuous-operation state, scheduled maintenance, and one bounded
  reversible scratch effect. It must not claim universal exactly-once.
- **RP-09** owns semantic trust inventory/epoch zero, inert self-change landing,
  prior-version exact activation, health, and rollback. Safe-automatic remains
  a separate proof-gated claim.
- **RP-10** owns minimal non-authoritative Workspace Projects, corrections,
  location index, mission continuity, and the cross-project CLI inbox.
- **RP-11** owns the deterministic full-input Harness Factory and generic
  executor adapter. Prove one real primary provider plus fake conformance
  adapters; require a live secondary only for a separately proposed support
  claim.
- **RP-12** owns the private signed extension supply chain.
- **RP-13** owns bounded child-run identity, scope/depth/budget derivation,
  child provider mapping, cancellation, evidence, and terminal retirement.
- **RP-14** is proof-only: it owns solo dogfood, burden/outcome reports,
  integrated provider claim reproduction, the final proof map, and promotion
  handoff. It owns no runtime, workflow, CLI, or implementation source. Failed
  proof routes back to the owning child.

There is no standalone maintenance packet and no standalone friction packet.
Setup, diagnostics, route UX, recovery status, mission inbox, instrumentation,
and burden proof ship with their owning components rather than arriving at the
end.

## 11. Decision, finding, proof, and evidence coverage

Import without weakening:

- FD-001 through FD-024 from the reconciled decision register;
- RF-001 through RF-033 from the reconciled finding register;
- PO-FD-001 through PO-FD-024 and every associated promotion gate;
- UE-001 through UE-015 as unresolved until their named tests run;
- ROD-001 through ROD-006 as the only genuine operator judgments; and
- ED-001 through ED-007 as engineering defaults that escalate only if
  infeasible or proof-failing.

Do not revive the former twelve-decision operator list. Testable repository or
mechanism questions are not operator decisions.

The six operator judgments are fixed to:

- ROD-001 — evidence/storage recovery and retention policy (RP-03/RP-07);
- ROD-002 — autonomy risk, protected scope, PR, and ambiguity posture
  (RP-06/RP-08);
- ROD-003 — epoch-zero trust root and autonomous activation enablement
  (RP-01/RP-09);
- ROD-004 — trusted private extension sources and signer policy (RP-12);
- ROD-005 — child-agent cost and concurrency ceiling (RP-13); and
- ROD-006 — human escape hatch and final support/promotion disposition
  (RP-00/RP-14).

Keep evidence classification separate from proof method. Use only these
evidence classifications:

```text
DECLARED
STATICALLY_INSPECTED
DYNAMICALLY_EXECUTED
ADVERSARIALLY_TESTED
CONFIGURATION_DERIVED
DEPLOYMENT_LOCAL
PROVIDER_OBSERVED
ARCHITECTURAL_INFERENCE
UNVERIFIED
```

Use `proof_method` values such as static inspection, dynamic execution,
adversarial test, fault injection, provider observation, dogfood, or operator
acceptance. Never label a planned proof as executed evidence.

Preserve the FD-023 ownership split: RP-11 owns generic adapter
implementation/conformance; RP-06, RP-08, and RP-13 own their specializations;
RP-14 owns independent integrated promotion proof only.

## 12. Exact dependency order

Encode and validate this DAG:

```text
RP-00 → RP-01, RP-02
RP-01 → RP-03, RP-10
RP-01 + RP-02 + RP-03 → RP-04
RP-04 → RP-05
RP-01 + RP-03 + RP-05 → RP-06
RP-03 + RP-04 + RP-06 → RP-07
RP-06 + RP-07 → RP-08
RP-06 + RP-07 + RP-08 → RP-09
RP-01 + RP-02 + RP-10 → RP-11
RP-07 + RP-11 → RP-12
RP-08 + RP-11 → RP-13
RP-08 + RP-09 + RP-10 + RP-11 → RP-14 core proof
RP-12 + RP-13 → optional-claim proof and full program closeout
```

Key sequencing rules:

- RP-01 freezes the versioned authority/guard semantic interface before RP-03
  mutates persistence; those changes must not run concurrently.
- RP-01 and RP-02 may proceed in parallel after RP-00.
- The non-authoritative RP-10/RP-11 product branch may proceed alongside the
  broker/trust spine after its declared dependencies.
- RP-07 evidence identity and physical capacity precede RP-08 integrated
  recovery because recovery terminal claims must already be authentic and
  writable.
- RP-12 and RP-13 are distinct children coordinated by RWG-12.
- Core Solo Local claims may close claim-scoped after RP-08/RP-09/RP-10/RP-11.
  Signed-extension, child-agent, secondary-provider, and safe-automatic claims
  stay disabled/unclaimed until their own proof; full program closeout waits
  for all fifteen children.

## 13. Proposal creation phases

### Phase 0 — Preflight and fixed-map admission

Complete baseline capture, reconciliation integrity/verdict checks, source
registration, predecessor disposition, path collision checks, and baseline
drift analysis. Initialize a write-scope ledger assigning each child directory
to at most one authoring agent.

### Phase 1 — Child scaffolding

Use the canonical create-packet route to scaffold the fifteen exact sibling
architecture proposals. Keep every child `draft`. Regenerate the proposal
registry only through its owning generator. Do not hand-author generated
navigation or registry content where a canonical generator owns it.

### Phase 2 — Parent program creation

Run the canonical create-program route with all fifteen child paths. Create the
v2 child registry, human index, sequence, child contract, closeout plan, and
program-creation receipt. Use `gated-parallel` consistently in the parent and
registry.

### Phase 3 — Program and packet authoring

Author the parent coordination package and each child from the reconciled
packet map. Every child must be independently reviewable without informal
parent prose supplying its safety boundary.

### Phase 4 — Independent integration and simplification review

Challenge source overlap, dependency cycles, unsafe states, two authority
issuers, two writers, broker/verifier overlap, same-change trust validation,
missing proof, target-family mixing, ceremony, false escalation, and hidden
maintenance burden. Apply corrections only in the owning parent or child
directory.

### Phase 5 — Structural validation and review handoff

Run the canonical validation floor, distinguish structural success from later
acceptance/implementation gates, regenerate/check the proposal registry, and
produce the operator reading order and final report.

## 14. Required parent artifacts

Use canonical files first and combine concerns where the format already has an
owner. The parent must contain equivalents of:

- program charter, scope/non-goals, decision baseline, and reconciliation
  reference;
- repository baseline and baseline-drift report when needed;
- `resources/child-packet-index.yml` and `.md`;
- exact packet DAG and workgroup crosswalk;
- source ownership and component-change maps;
- schema/contract/workflow change register;
- safe/prohibited state, compatibility, retirement, rollback, and recovery
  registers;
- proof, acceptance, validator, risk, support-claim, operator-decision, and
  unresolved-evidence registers;
- five-milestone operator reading order;
- frontier-model implementation constraints;
- dogfood/effectiveness and authoritative-promotion handoff plans;
- completion and closeout checklists; and
- `support/program-creation.md` plus predecessor-lineage disposition.

Do not invent a proposal-local checksum format. Current active proposal
integrity is represented by manifests, generated artifact catalogs, registry
projection, child registry digest, lifecycle receipts, and validator evidence.

## 15. Required child content

Put the following content in canonical architecture, navigation, resources, or
support documents rather than adding unsupported manifest keys:

```yaml
logical_packet_id:
purpose:
problem_statement:
current_repository_state:
current_evidence:
accepted_decisions:
target_state:
scope:
non_goals:
invariants:
planned_durable_source_ownership:
proposal_lifecycle_ownership:
retained_evidence_ownership:
components_affected:
files_expected_to_change:
contracts_affected:
schemas_affected:
workflows_and_generated_projections_affected:
provider_configuration_observed:
technical_identities_affected:
trust_boundary_changes:
migration_preconditions:
migration_steps:
safe_intermediate_states:
prohibited_intermediate_states:
compatibility_bridges:
deprecations_and_retirements:
rollback_strategy:
recovery_strategy:
validation_plan:
adversarial_tests:
fault_injection:
evidence_to_retain:
support_claim_effect:
operator_experience_effect:
setup_and_maintenance_effect:
dependencies:
parallelization_constraints:
must_not_run_concurrently_with:
operator_decisions:
blocking_findings:
entry_criteria:
exit_criteria:
proof_produced:
authoritative_promotion_requirements:
```

Every child must answer:

1. Why must this change exist?
2. Which current primitives are preserved?
3. Which current behavior is removed or demoted?
4. What is the smallest implementation satisfying the accepted boundary?
5. Why does it not create a second control plane?
6. What happens when the new component is unavailable?
7. How is rollback prepared before the consequential transition?
8. What exact evidence proves completion?
9. What remains unsupported afterward?
10. What is the normal solo-builder experience?

## 16. Source-of-truth ownership rules

Distinguish proposal-local lifecycle truth from planned post-implementation
durable ownership. Assign one normal planned owner for execution authorization,
guard issuance/consumption, runtime operations, credentials, effect execution,
outcome verification, evidence attestation/retention, route selection, trust
activation/rollback, Workspace Projects, effective harness manifests,
extension catalog state, child delegation, and support claims.

Reject designs with two authority issuers, two writable runtime stores,
candidate-controlled effects, broker self-verification as sole verdict,
verifier-held effect credentials, self-authorizing metadata, same-change trust
self-certification, or GitHub as a canonical ledger.

## 17. Safe and prohibited migration states

Import the reconciliation's safe-state register. At minimum preserve:

- authority semantics frozen before store migration;
- independent candidate repository/object database;
- one SQLite writer with legacy files read-only;
- one broker and one non-production effect before Class B enablement;
- sanitized Git and separate exact-SHA verifier before autonomous publication;
- signed/capacity-safe evidence before integrated recovery proof;
- unknown outcomes reconciled before retry, with honest
  `manual_intervention` terminality;
- trust source landing inert before any activation; and
- Projects/Harness remaining non-authoritative.

Forbid dual authority/writers, ambient credentials, candidate provider-write
workflows, linked-worktree-only isolation, non-atomic target binding, blind
retry, unsigned success fallback, unreserved terminal capacity, same-change
trust validation, direct-main autonomous work, and support claims ahead of
proof.

## 18. Proof and product requirements

Map every accepted claim to its reconciliation proof obligation, test owner,
workgroup, child proposal, and promotion gate. Preserve load-bearing proof for
decision-source substitution, typed-scope widening, exact guard consumption,
useful credentialless provider operation, same-user IPC attacks, hostile Git
extensions, expected-old target races, duplicate verifier contexts, crash and
unknown boundaries, ENOSPC terminal reserve, old-snapshot rollback, evidence
forgery/compaction, trust indirection, provider conformance, and child
scope/depth/retirement.

Treat these as future acceptance budgets, never current claims:

```yaml
supported_initial_setup: "<= 15 minutes"
conventional_project_onboarding: "<= 5 minutes"
routine_class_a_operator_prompts: 0
routine_admitted_class_b_operator_prompts: 0
admitted_a_b_missions_completed_autonomously: ">= 18 of 20"
missions_without_unauthorized_effects_or_routine_prompts: "20 of 20"
median_human_time: "<= 2 minutes and >= 50% below supervised-agent baseline"
octon_mediation_overhead_p50: "<= 60 seconds excluding project tests and provider queue"
recoverable_broker_restart_and_reconciliation: "<= 5 seconds, zero manual steps"
false_a_b_to_pr_escalations: 0
normal_completion_summary: one screen
raw_evidence_committed_to_project_repository: false
normal_visible_profile: one Solo Local profile
normal_command_concepts: "<= 7"
monthly_manual_administration: "<= 15 minutes"
proposal_administration: "<= 30 minutes per packet and <= 10% of implementation human time"
unsafe_fallback: false
candidate_work_preserved_when_publication_is_blocked: true
```

## 19. Subagent workstreams

Use one accountable primary architect. Subagents are read-only/advisory unless
assigned one exact sibling child directory; no two agents may edit the same
file.

Use at least these bounded workstreams when supported:

1. conventions, baseline, source isolation, and predecessor disposition;
2. RP-00/RP-01 containment and canonical authority;
3. RP-02 candidate isolation;
4. RP-03/RP-04 store and broker;
5. RP-05/RP-06 Git, verification, and publication;
6. RP-07/RP-08 evidence, recovery, and complete Class B;
7. RP-09 trust-root self-development;
8. RP-10/RP-11 Projects, inbox, Harness, and generic adapter;
9. RP-12/RP-13 extensions and bounded children;
10. RP-14 independent product/proof review; and
11. independent program integration and simplification challenge.

For every subagent record assignment, exact repository paths inspected,
reconciliation inputs used, outputs, accepted/rejected recommendations, and
unresolved questions.

## 20. Frontier-model implementation constraints

The proposal program may plan, but not run, later implementation with:

```yaml
active_implementation_workstreams: 3
maximum_major_parallel_workstreams: 4
trusted_integration_lanes: 1
```

For trust-sensitive children, implementing agent, sole reviewer, adversarial
tester, and final integrator must be distinct roles. Implementation tasks may
not reopen accepted architecture by preference. A reopening request requires
new repository evidence, demonstrated impossibility or contradiction, a
smaller safe alternative preserving invariants, and operator decision when the
baseline changes.

## 21. Validation floor

Run from `/Users/jamesryancooper/Projects/octon`.

For the parent and each of the fifteen child paths, use this exact path set and
run:

```sh
PROPOSAL_PATHS=(
  .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-program
  .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-containment
  .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-canonical-authority
  .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-candidate-isolation
  .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-transactional-runtime-store
  .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-local-broker
  .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-sanitized-git
  .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-verification-publication
  .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-signed-evidence
  .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-recovery-class-b
  .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-self-development-trust-activation
  .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-workspace-projects
  .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-harness-factory
  .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-extension-supply-chain
  .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-bounded-child-agents
  .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-solo-dogfood-promotion
)

for PROPOSAL_PATH in "${PROPOSAL_PATHS[@]}"; do
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package "$PROPOSAL_PATH"
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package "$PROPOSAL_PATH"
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package "$PROPOSAL_PATH"
done
```

For the parent, also run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-program
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-program
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-program
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
```

Structural/base/subtype validators must pass. Implementation-readiness,
program-child-readiness, strict review authorization, and architecture review
receipt gates may correctly remain blocked for newly created drafts. Record
those as expected future lifecycle gates; do not fabricate receipts or elevate
statuses to force them green.

Additionally verify:

- 15 unique logical packet IDs and 15 unique child proposal IDs/paths;
- parent `related_proposals`, both indexes, and sequence agree exactly;
- the dependency graph is acyclic and equals the fixed DAG;
- all FD, RF, PO, PG, UE, ROD, and ED identifiers are covered exactly once or
  have an explicit child cross-reference;
- planned source ownership is exclusive;
- every child has rollback, recovery, proof, support-claim, and operator
  experience coverage;
- no strict manifest contains unsupported fields;
- no proposal claims implementation, acceptance, or authority;
- generated registry content was produced only by the generator;
- Revision 2 remains unchanged; and
- no repository path outside the write allowlist changed.

## 22. Readiness gates for the authored program

Represent these as aggregate read models mapped to canonical receipts and
reconciliation promotion gates, not as a new authorization system:

- packet implementation: accepted child, stable baseline, exclusive ownership,
  resolved blocking decisions, dependencies, rollback, and validators;
- privileged implementation: RP-00 containment plus understood authority and
  credential boundaries;
- proof of architecture: integrated RP-01 through RP-08 safety spine;
- autonomous Class B: exact SHA/target race, idempotency, recovery,
  reconciliation, signed terminal evidence, PR escalation, and rollback;
- trust automation: previous-version verification, exact inert version,
  pre-registered rollback, staged health, no same-change rule modification;
- support promotion: real dogfood, full proof matrix, resolved/accepted risks,
  measured friction, operator acceptance, and authoritative updates;
- implemented archival: authoritative promotion and all post-implementation
  conformance/drift/closeout receipts pass before archive.

## 23. Required final report

Report:

- canonical parent path and program ID;
- all fifteen child paths and logical RP crosswalk;
- repository commit and reconciliation ID used;
- baseline drift and predecessor disposition;
- packet/workgroup counts and exact dependency order;
- proposal status of parent and every child;
- validators run and expected future-gate blockers;
- six genuine operator decisions and unresolved evidence by child;
- first packet recommended for later acceptance: RP-00;
- minimum proof-of-architecture sequence;
- conditions before privileged implementation, Class B publication, trust
  activation, support promotion, and implemented archival;
- generated registry status; and
- every limitation or missing proof.

End with exactly one report verdict:

```text
PROPOSAL_PROGRAM_READY_FOR_OPERATOR_REVIEW
PROPOSAL_PROGRAM_READY_WITH_BLOCKED_PACKETS
PROPOSAL_PROGRAM_BLOCKED_BY_REVERIFICATION
PROPOSAL_PROGRAM_BLOCKED_BY_ARCHITECTURE_REPAIR
PROPOSAL_PROGRAM_BLOCKED_BY_OPERATOR_DECISION
```

## 24. Negative constraints

- Do not implement, accept, promote, archive, publish, or authorize the
  architecture.
- Do not overwrite or mutate the existing Revision 2 proposal.
- Do not create nested child proposal directories.
- Do not create an unlisted sixteenth logical packet or physical child path.
- Do not merge RP-05/RP-06 or RP-07/RP-08.
- Do not recreate standalone maintenance or friction packets.
- Do not move setup/doctor/repair, route UX, mission inbox, or burden proof away
  from their reconciled owners.
- Do not let RP-14 modify runtime, workflow, CLI, or validator sources.
- Do not treat parent evidence as child evidence.
- Do not mix `.octon/**` and repo-local durable promotion targets in one active
  proposal.
- Do not use `.github/**` as an `octon-internal` promotion target.
- Do not edit generated artifacts manually.
- Do not revive VMs, enterprise identity, distributed consensus, multi-writer
  state, PR-only publication, direct-main agents, a public marketplace,
  persistent agent organizations, a second broker/control plane,
  self-authorizing metadata, credentialed agents, or same-change
  self-certification.
- Do not claim provider, runtime, adversarial, fault, dogfood, or support proof
  that was not actually executed.
- Do not create a proposal-local integrity format that current conventions do
  not own.

## 25. Success criteria

The task is complete only when:

1. one draft parent and fifteen draft sibling child proposals exist at the
   exact paths;
2. parent/child authority separation and the fixed DAG validate;
3. all reconciliation decisions, findings, proofs, unknowns, operator
   decisions, and engineering dispositions map to child owners;
4. base and architecture structural validators pass for every proposal;
5. expected later review/implementation blockers are recorded honestly;
6. the generated registry is fresh through its owning generator;
7. the preexisting Revision 2 packet and all non-allowlisted paths remain
   unchanged; and
8. the final report makes no claim beyond proposal-program readiness for
   operator review.
