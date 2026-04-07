# Octon Completion Proposal and Design Packet

## A. Executive Design Thesis

Octon does not need a new architecture. It needs a completion architecture:
preserve the constitutional kernel, run-oriented control and evidence roots,
support-target matrix, lab domain, observability domain, adapters, and
disclosure surfaces that already exist; then harden the missing links that
still prevent an honest "fully unified execution constitution" claim.

The strongest needed moves are:

1. normalize live authority around canonical request, grant, lease,
   revocation, and decision chains across all material runtime paths;
2. make mission, run, attempt, and stage semantics coherent and
   machine-enforced;
3. turn stage and attempt state plus event-ledger state into the undeniable
   runtime system of record;
4. require proof-plane parity for every admitted support target;
5. make support-target promotion and exclusion rules binding;
6. mature replay and externalized evidence;
7. make build-to-delete a real operating system rather than an aspirational
   post-claim annex.

The packet therefore aims for bounded, evidence-first constitutional
completion, not cosmetic closure. The repo already has the right constitutional
superstructure, adapter boundaries, and disclosure vocabulary; the remaining
work is normalization, truth-binding, and deletion of transitional ambiguity.

A necessary refinement to the prior packet is this: the current repository now
contains sophisticated closure and claim artifacts that already assert
completion, including:

- `.octon/framework/constitution/claim-truth-conditions.yml`
- `.octon/instance/governance/closure/closure-summary.yml`
- `.octon/instance/governance/closure/gate-status.yml`
- `.octon/instance/governance/closure/phase-status.yml`
- `.octon/instance/governance/disclosure/harness-card.yml`
- multiple retained release HarnessCards under
  `.octon/state/evidence/disclosure/releases/**`

Those surfaces are still too closure-local and self-sealing to serve as
first-order truth. The target-state design must invert that dependency:
independent run, support, proof, adapter, and retirement evidence becomes
truth; closure and claim artifacts become generated summaries derived from that
truth graph. Until that inversion is complete, Octon can publish bounded
readiness statements, but not the final unified-execution claim.

A second refinement is that the audit's largest runtime gaps are narrower than
they first appeared. The live repo does already contain:

- an active exception-lease set with concrete active and expired leases under
  `.octon/state/control/execution/exceptions/leases.yml`;
- a live stage-attempt artifact for the sampled consequential run under
  `.octon/state/control/execution/runs/uec-global-github-repo-consequential-20260404/stage-attempts/initial.yml`;
- workflow-backed simplification and build-to-delete validators in
  `.github/workflows/architecture-conformance.yml`;
- a substantial retirement and ablation governance packet under
  `.octon/instance/governance/contracts/retirement-registry.yml` and related
  review contracts.

That means the remaining work is no longer "invent leases," "invent stage
state," or "invent build-to-delete." It is to normalize, bind, and generalize
those surfaces so they govern every material path and support target
consistently.

The correct repo-grounded verdict is therefore narrower and stricter than a
simple closure claim: Octon has made substantial, architecture-faithful
implementation progress, but it is not yet target-state complete enough to
honestly claim that it is already a fully unified execution constitution.
Preserve the direction, harden the runtime and authority normalization,
complete proof-plane enforcement symmetry, keep important staged tuples
outside the live claim envelope, and only then make the strongest claim.

## B. Current Baseline to Preserve

### Preserve 1 - Constitutional kernel and class-root discipline

Current baseline: Octon already has the correct class-root structure and a
substantive constitutional kernel under `.octon/framework/constitution/**`,
with charter, obligations, ownership, precedence, contract families, and a
support-target schema. The repo-level `.octon` design still cleanly separates
authored authority, runtime truth, generated views, and input overlays.

Paths:

- `.octon/README.md`
- `.octon/framework/constitution/**`
- `.octon/instance/ingress/AGENTS.md`

Judgment: preserve.

Why: this is already the strongest part of the system and is fully aligned
with the packet's architectural center of gravity.

Machine enforcement to keep:

- ingress precedence;
- authored vs state vs generated separation;
- generated-effective freshness checks.

Migration note: do not replace. Only tighten claim-truth binding and family
completeness.

### Preserve 2 - Bounded live support universe and support-target matrix

Current baseline: the repo already has a real support-target matrix, admission
files, and support dossiers. Repo-shell plus repo-local-governed are clearly
closer to live support; GitHub control-plane and frontier-governed remain
explicitly `stage_only` in important tuples.

Paths:

- `.octon/instance/governance/support-targets.yml`
- `.octon/instance/governance/support-target-admissions/**`
- `.octon/instance/governance/support-dossiers/**`

Judgment: preserve and harden.

Why: bounded honesty is a strength. Overclaiming broader host or model support
would damage the constitutional model.

Machine enforcement to keep:

- tuple-level admission;
- required proof planes;
- required authority artifacts;
- review dates and recertification posture;
- exclusion from the live claim envelope.

Migration note: promotion and restriction semantics need to become more
explicit and automated, not replaced.

### Preserve 3 - Run-oriented control and evidence roots

Current baseline: run contracts, manifests, runtime state, checkpoints, replay
manifests, intervention logs, measurement summaries, and RunCards and
HarnessCards already exist in the correct state roots. The sampled
consequential run also already contains `events.manifest.yml`, `events.ndjson`,
authority roots, checkpoints, rollback posture, and a live stage-attempt
artifact.

Paths:

- `.octon/state/control/execution/runs/**`
- `.octon/state/evidence/runs/**`
- `.octon/state/evidence/disclosure/**`

Judgment: preserve and normalize.

Why: the repo has already moved beyond "conversation as runtime." The
remaining issue is consistency and truth-binding, not absence.

Machine enforcement to keep:

- per-run roots;
- append-oriented evidence retention;
- disclosure generation;
- runtime-state projection from durable run-local truth.

Migration note: split and enrich stage, attempt, and event structures rather
than replacing the run-oriented model.

### Preserve 4 - Adapter separation and non-authoritative host posture

Current baseline: host and model adapters are already explicit, bounded, and
support-target-aware. GitHub is non-authoritative; CI is projection-only;
repo-shell is the cleanest live host surface; model adapters declare support
tiers, contamination and reset policy, and conformance suite refs.

Paths:

- `.octon/framework/engine/runtime/adapters/host/**`
- `.octon/framework/engine/runtime/adapters/model/**`

Judgment: preserve and harden.

Why: this is precisely the portability boundary the packet wanted.

Machine enforcement to keep:

- adapter support declarations;
- conformance suite refs;
- known limitations;
- support-target binding.

Migration note: add stronger promotion gating and runtime conformance proofs
before widening live support.

### Preserve 5 - Top-level lab and observability domains

Current baseline: lab and observability are already first-class top-level
domains, not naming shims.

Paths:

- `.octon/framework/lab/**`
- `.octon/framework/observability/**`

Judgment: preserve and mature.

Why: the domains are correct; they now need fuller contractization and
stronger binding to support-target proof and replay.

Migration note: add missing explicit contract families and generated report
surfaces; do not collapse them back into assurance or runtime.

### Preserve 6 - Orchestrator-centered agency simplification

Current baseline: the agency manifest already centers execution on a single
accountable orchestrator, treats identity overlays as optional and
non-authoritative, and keeps free-form skill-actor delegation off. The runtime
agents directory foregrounds orchestrator and verifier.

Paths:

- `.octon/framework/agency/manifest.yml`
- `.octon/framework/agency/runtime/agents/**`

Judgment: preserve, simplify further.

Why: the kernel agency simplification is correct. Remaining transitional
surfaces should be demoted or deleted from active use.

## C. Definition of Complete

Octon may honestly claim it is a fully unified execution constitution only
when all of the following are true within a bounded, explicit live support
universe:

1. Constitutional singularity: all normative control derives from the
   constitutional kernel plus instance authority surfaces, not prompts,
   labels, or host-native metadata.
2. Objective coherence: every material run is bound to a valid workspace
   charter and run contract, and every tuple that declares
   `requires_mission: true` has a non-null mission binding unless it is in an
   explicitly sunsetted transition mode excluded from live claim.
3. Execution singularity: execution attempt and stage state are live,
   inspectable, and folded into canonical runtime state via an append-oriented
   event ledger or equivalent durable lifecycle.
4. Authority singularity: every consequential or boundary-sensitive action
   path emits canonical authority artifacts: route receipt, request, grant,
   bundle as needed, decision artifact, lease refs if applicable, revocation
   awareness, and execution receipt.
5. Lease normalization: exception leases are first-class, per-run and per-stage
   scoped, expiry-bound, revocable, retirement-bound, and runtime-enforced.
6. Support-target truth: no tuple counted inside the live claim is
   `stage_only`, `experimental`, or otherwise excluded; all such tuples may
   exist, but must be explicitly outside the live claim envelope.
7. Proof-plane parity: each admitted tuple has the required proof planes
   completed, retained, and machine-gated: structural, functional,
   governance, recovery, and behavioral or maintainability where applicable.
8. Replay truth: retained class-A and class-B evidence plus external immutable
   replay payload indexing are sufficient to reconstruct and audit
   representative consequential runs.
9. Disclosure truth: RunCards and HarnessCards are generated from canonical
   evidence, not hand-authored claim surfaces, and include exclusions,
   intervention disclosure, support universe, proof bundles, and known
   limitations.
10. Build-to-delete truth: every transitional compensator, shim, staged
    exclusion, and non-load-bearing scaffold has an owner, insertion
    rationale, measurable retirement trigger, review cadence, and deletion or
    ablation receipt path.
11. Closure derivation: closure summaries, gate-status files, phase-status
    files, and claim-complete statuses are generated from the above conditions
    rather than serving as independent truth sources.

Anything less can still justify a bounded readiness or partially complete
constitutional claim, but not the final one.

This is a refinement of the current repo's own closure approach, which already
tracks closure aggressively but still places some deletion follow-through
outside claim truth. That boundary is not acceptable for final completion
because build-to-delete is now a constitutional property, not post-claim
housekeeping.

## D. Constitutional Kernel Design

### Design decision 1 - Rebind claim truth from closure-local to evidence-first

Target paths:

- modify `.octon/framework/constitution/claim-truth-conditions.yml`
- modify `.octon/instance/governance/closure/**`
- modify `.octon/framework/constitution/charter.yml`
- generate `.octon/generated/effective/closure/claim-evaluation.yml`

Relation to current baseline: the current repo already has
`claim-truth-conditions.yml` and closure files, but the truth graph still
leans too heavily on closure summaries and gate surfaces.

Judgment category: re-bound.

Why this is correct: a constitution cannot prove itself by citing its own
closure memo. Truth must flow from independent admissions, proof bundles,
adapter conformance, retained runs, retirement status, and replay evidence.

Required machine enforcement: implement a claim evaluator that walks support
admissions, dossiers, proof bundles, run cards, adapter conformance manifests,
retirement registry, and intervention and measurement evidence; closure files
become generated outputs only.

Migration note: keep existing closure files during transition, but mark them
`generated_from: claim-evaluator` and prohibit manual edits.

Proof and acceptance note: a simulated regression in any source proof artifact
must automatically flip claim status or exclusion status in the generated
closure output.

### Design decision 2 - Make build-to-delete part of constitutional truth

Target paths:

- modify `.octon/framework/constitution/obligations/fail-closed.yml`
- create or normalize `.octon/instance/governance/retirement/**`
  or an equivalent canonical governance-domain retirement family
- create `.octon/state/evidence/governance/deletion-receipts/**`

Relation to current baseline: the current repo already has a fail-closed
obligation on compensators without owner or retirement trigger, Phase 6 and
Phase 7 validators in CI, and a substantial retirement registry under
`.octon/instance/governance/contracts/retirement-registry.yml`.

Judgment category: harden.

Why this is correct: if transitional scaffolding can survive indefinitely
after claim, the constitution is incomplete by definition.

Required machine enforcement: no claim-complete state while any active
transitional mechanism lacks owner, cadence, or retirement trigger, or while
any retirement item is overdue without waiver.

Migration note: current phase-status semantics must be changed so
"post-claim deletion follow-through" is not outside truth for
constitutional items.

Proof and acceptance note: the claim evaluator must fail on overdue retirement
entries.

### Design decision 3 - Keep dual precedence explicit and compiled

Target paths:

- preserve `.octon/framework/constitution/precedence/normative.yml`
- preserve `.octon/framework/constitution/precedence/epistemic.yml`
- generate `.octon/generated/effective/precedence/*.yml`

Relation to current baseline: the repo already has explicit normative and
epistemic precedence surfaces.

Judgment category: preserve.

Why this is correct: constitutional control and evidentiary grounding are
different axes and should stay separate.

Required machine enforcement: ingress and runtime resolution must reject
conflicts by evaluating both precedence graphs independently.

Migration note: add compiled effective views and validator coverage; preserve
the authored source precedence files.

Proof and acceptance note: precedence conflict tests must exist in assurance
suites.

## E. Intent and Objective Model Design

### Design decision 1 - Preserve workspace plus mission plus run, but split stage contract from execution attempt

Target paths:

- modify `.octon/framework/constitution/contracts/objective/**`
- add `stage-contract-v1.schema.json`
- add `execution-attempt-v1.schema.json`
- add `run-contract-v4.schema.json`
- deprecate `stage-attempt-v2` to a compatibility role

Relation to current baseline: the current repo already has workspace, mission,
run, and stage-attempt schemas, but the live semantics still overload stage
and attempt and allow a mission contradiction in sampled stage-only
consequential runs.

Judgment category: normalize.

Why this is correct: a stage is an intended slice of a run; an attempt is an
actual try against that stage. Collapsing them hides retry, rollback, and
contamination semantics.

Required machine enforcement: every run has ordered stage contracts; every
stage has one or more execution attempts; runtime state folds attempt outcomes
into current stage state.

Migration note: provide a compatibility mapper from `stage-attempt-v2` to
`stage-contract` plus `execution-attempt` for old runs.

Proof and acceptance note: sampled consequential runs must show live stage
contract, attempt contract, checkpoint, and event-ledger linkage.

### Design decision 2 - Make mission binding explicit and non-contradictory

Target paths:

- modify `run-contract-v4.schema.json`
- modify support-target admissions and dossiers
- modify run builders under runtime

Relation to current baseline: the sampled run uses `requires_mission: true`
with `mission_id: null`; that must be eliminated in live claimed tuples.

Judgment category: harden.

Why this is correct: mission-required execution without mission binding breaks
the packet's objective hierarchy.

Required machine enforcement: add
`mission_binding_mode: required|optional|forbidden` and
`transition_mode: none|legacy-missionless-stage-only-projection`. The
transition mode is allowed only for excluded stage-only tuples and must carry
a sunset date.

Migration note: convert current missionless stage-only GitHub consequential
runs into explicit transition-mode runs; forbid them inside the live claim.

Proof and acceptance note: no claim-included run may have mission-binding
contradictions.

### Design decision 3 - Make done-when, exclusions, reversibility, protected zones, and required evidence first-class in every run and stage

Target paths:

- objective contracts
- support admissions
- stage contracts

Relation to current baseline: current run contracts already contain much of
this and should be preserved and deepened.

Judgment category: preserve and harden.

Why this is correct: these are the machine-readable form of governed intent.

Required machine enforcement: stage entry criteria cannot be satisfied unless
required evidence and protected-zone constraints are resolved.

Migration note: add missing fields only where older schemas are thinner.

Proof and acceptance note: validators must fail if run or stage omission occurs
in consequential tuples.

## F. Durable Control and Precedence Design

### Design decision 1 - Keep repo-local authored authority as the system of record; generated views are projections only

Target paths:

- preserve class roots and ingress
- add stronger generated-effective validators

Relation to current baseline: already correct and explicitly described in
ingress.

Judgment category: preserve.

Why this is correct: repo-local authored truth is central to replayability,
auditability, and low drift.

Required machine enforcement: generated outputs must carry provenance,
freshness, and rebuildability markers; they may never become silent authority.

Migration note: none.

Proof and acceptance note: generated-effective drift tests.

### Design decision 2 - Compile two effective views: normative resolution and epistemic resolution

Target paths:

- `.octon/generated/effective/precedence/**`
- `.octon/framework/engine/runtime/crates/**`

Relation to current baseline: implied by current authored surfaces, but not
yet fully visible as explicit compiled outputs.

Judgment category: harden.

Why this is correct: runtime and ingress should not recompute precedence ad
hoc.

Required machine enforcement: every run binds to a compiled effective control
view and a compiled effective grounding view.

Migration note: preserve source precedence files.

Proof and acceptance note: effective-view checksums recorded in run manifests.

### Design decision 3 - Make overlays additive and non-authoritative by rule, not culture

Target paths:

- `.octon/inputs/**`
- `.octon/framework/agency/overlays/**`

Judgment category: normalize.

Why this is correct: non-authoritative overlays are useful, but only if they
cannot silently outrank authored authority.

Required machine enforcement: overlay application requires explicit target and
provenance and is prohibited from modifying constitutional truth.

Migration note: remove any legacy active overlay references in kernel paths.

Proof and acceptance note: overlay injection tests in structural and
governance assurance suites.

## G. Authority, Approval, Lease, and Revocation Design

### Design decision 1 - All material execution entrypoints must route through a canonical authority engine

Target paths:

- `.octon/framework/engine/runtime/crates/**`
- `.octon/framework/constitution/contracts/authority/**`
- `.github/workflows/**`

Relation to current baseline: approval, grant, revocation, and decision
schemas already exist, and the PR autonomy workflow already materializes
request and grant artifacts.

Judgment category: normalize.

Why this is correct: artifact presence is insufficient unless runtime and
workflows are forced through it.

Required machine enforcement: no consequential step without a valid
authority-route receipt and decision artifact; no host-native shortcut.

Migration note: wrap existing workflow and service entrypoints with the
authority engine.

Proof and acceptance note: route and receipt coverage tests across repo-shell,
GitHub projection, CI projection, and any browser or API packs.

### Design decision 2 - Normalize exception leases into a run and stage-bound lease subsystem

Target paths:

- preserve `.octon/state/control/execution/exceptions/leases.yml` as a
  compatibility index
- create `.octon/state/control/execution/exceptions/leases/index.yml`
- create `.octon/state/control/execution/exceptions/leases/<lease-id>.yml`
- create `.octon/state/control/execution/exceptions/by-run/<run-id>.yml`

Relation to current baseline: a live lease set already exists, including
active and expired leases with owners and retirement triggers.

Judgment category: harden and normalize.

Why this is correct: leases are now real enough that the remaining gap is
scoping, linkage, and runtime enforcement.

Required machine enforcement: lease validity check on every exceptional
action; expiry, revocation, run and stage scope, target surface, grant chain,
and quota must all match.

Migration note: emit both the compatibility set file and canonical per-lease
files during transition.

Proof and acceptance note: dedicated lease issuance, expiry, revocation, and
overreach tests.

### Design decision 3 - Revocations must be live kill-switches, not archival records

Target paths:

- authority contracts
- `.octon/state/control/execution/revocations/**`
- runtime policy engine

Relation to current baseline: revocation schemas and roots exist, but
runtime-wide kill behavior is not yet uniformly proven.

Judgment category: harden.

Why this is correct: governability depends on live revocation.

Required machine enforcement: runtime checks revocation state before tool
execution, before checkpoint resume, and before projection emission.

Migration note: none.

Proof and acceptance note: revocation exercise scenarios required in both lab
and assurance.

### Design decision 4 - Host adapters remain projections, never authorities

Target paths:

- host adapter contracts
- support-target dossiers

Relation to current baseline: already correctly modeled. GitHub is
non-authoritative and `stage_only`.

Judgment category: preserve.

Why this is correct: labels, comments, and checks are adapters, not authority.

Required machine enforcement: host state may project or mirror canonical
authority artifacts only.

Migration note: none.

## H. Agency and Capability Design

### Design decision 1 - Keep a minimal kernel: orchestrator plus verifier

Target paths:

- `.octon/framework/agency/manifest.yml`
- `.octon/framework/agency/runtime/agents/**`

Relation to current baseline: already largely true.

Judgment category: preserve.

Why this is correct: responsibility and independence are load-bearing;
persona theater is not.

Required machine enforcement: one accountable owner per run; verifier role
separated from generator where proof or review requires independence.

Migration note: move any legacy persona surfaces out of active runtime
registries.

Proof and acceptance note: no ingress or runtime path may require
persona-specific prose.

### Design decision 2 - Capability packs become typed, governed execution surfaces

Target paths:

- adapter contracts
- instance governance

Relation to current baseline: capability packs already appear in support
tuples but need harder contractization.

Judgment category: harden.

Why this is correct: browser, UI, and broader API action surfaces should
arrive only through typed packs.

Required machine enforcement: each pack declares tools, side-effect class,
sandbox requirements, observability requirements, default routes, and admitted
support tuples.

Migration note: map existing `repo`, `git`, `shell`, `telemetry`, `api`, and
`browser` references into explicit pack contracts.

Proof and acceptance note: pack conformance suites per adapter, model, and
host tuple.

### Design decision 3 - Sub-agents are for bounded context and separation of duties, not personas

Judgment category: simplify.

Why this is correct: current repo direction favors context isolation and
verifier independence over roleplay-heavy teams.

Required machine enforcement: sub-agent creation requires explicit bounded
objective, allowed tools, return schema, and owner stage.

Migration note: delete or demote non-load-bearing persona kits from the
kernel path.

## I. Runtime, Continuity, Recovery, and Evidence Design

### Design decision 1 - Make runtime explicitly event-ledger-based

Target paths:

- use the existing `run-event-ledger-v1` schema in the runtime family
- create live per-run `event-ledger.yml` or `events/*.yml`

Relation to current baseline: the sampled retained state is still
projection-heavy, but the run already emits `events.manifest.yml` and
`events.ndjson`, which is enough to show that eventification is partially
real.

Judgment category: normalize.

Why this is correct: runtime should be reconstructible from append-only
events, with `runtime-state.yml` as a projection.

Required machine enforcement: every state transition emits an event;
projections are regenerated from the ledger.

Migration note: start by emitting events alongside current projections.

Proof and acceptance note: `state-reconstruction-v1` or equivalent must be
exercised against real runs.

### Design decision 2 - Checkpoints must become richer and stage-aware

Target paths:

- `.octon/framework/constitution/contracts/runtime/checkpoint-v3`
- `.octon/state/control/execution/runs/<run>/checkpoints/**`

Relation to current baseline: a bound checkpoint exists, but remains thin.

Judgment category: harden.

Why this is correct: long-running reliability depends on knowing exactly what
is bound, safe, resumable, and rollbackable.

Required machine enforcement: checkpoint type, stage ref, contamination state,
rollback posture ref, evidence refs, and side-effect barrier status must be
captured.

Migration note: preserve `bound.yml`, but add typed checkpoint variants.

### Design decision 3 - Continuity artifacts are explicit, bounded handoff state, not hidden chat residue

Target paths:

- `.octon/state/continuity/runs/**`
- runtime contracts

Relation to current baseline: continuity roots already exist conceptually and
in the contract registry.

Judgment category: harden.

Why this is correct: resumability without fragile chat continuity is core to
the packet.

Required machine enforcement: continuity artifacts reference current stage,
open blockers, pending approvals, checkpoint refs, and a next-step plan.

Migration note: add writer and reader discipline; keep mutable continuity
separate from retained evidence.

### Design decision 4 - Compensation, contamination, retry, and rollback become first-class records

Target paths:

- runtime contracts
- per-run roots

Relation to current baseline: schemas and exemplar rollback posture already
exist.

Judgment category: harden.

Why this is correct: reliability is not only success state; it is
recoverability state.

Required machine enforcement: retry classes, contamination records,
compensation records, and rollback posture required for consequential and
boundary-sensitive runs.

Proof and acceptance note: the recovery proof plane must reference them in all
admitted consequential tuples.

### Design decision 5 - Evidence classes formalize git-inline vs git-tracked vs external immutable

Target paths:

- retention contracts
- run manifests
- replay manifests
- external index

Relation to current baseline: the retention family already supports this
direction.

Judgment category: preserve and harden.

Why this is correct: it matches the settled packet position and the repo's
current architecture.

Required machine enforcement: every run classifies evidence; every replay
manifest identifies class-B manifest refs and class-C external immutable refs.

Migration note: add a validator that no required class-C payload is missing an
external index pointer.

## J. Verification, Evaluation, and Lab Design

### Design decision 1 - Proof-plane parity is tuple-specific, but real and blocking

Target paths:

- `.octon/framework/assurance/**`
- support admissions and dossiers
- proof bundle manifests

Relation to current baseline: proof planes and assurance domains already
exist, but live tuple requirements are uneven and some stage-only tuples
require only partial planes.

Judgment category: harden.

Why this is correct: claimed support must be backed by the proof planes
appropriate to the tuple's consequence class.

Required machine enforcement:

- observe/read: structural + functional + governance mandatory
- consequential: structural + functional + governance + recovery +
  maintainability mandatory
- boundary-sensitive or broader API or browser: all six mandatory, including
  behavioral

Migration note: GitHub stage-only tuples remain excluded until promoted.

Proof and acceptance note: the promotion engine fails on missing proof planes.

### Design decision 2 - Evaluator independence becomes explicit

Target paths:

- assurance evaluators
- lab
- runtime verifier role

Judgment category: normalize.

Why this is correct: generator self-certification is not enough.

Required machine enforcement: every consequential support tuple must have at
least one independent evaluator path separate from the generator path, plus
deterministic checks.

Migration note: keep the current verifier runtime role and formalize it.

### Design decision 3 - Lab becomes the authoritative experimentation domain for replay, faults, shadow, and adversarial validation

Target paths:

- `.octon/framework/lab/**`
- `.octon/state/evidence/lab/**`

Relation to current baseline: already first-class.

Judgment category: preserve and harden.

Why this is correct: the top-level lab domain is one of the repo's best
implemented architectural moves.

Required machine enforcement: support dossiers reference required lab
scenarios and retained lab evidence bundles.

Migration note: add scenario catalogs and typed fault, shadow, and replay
contracts.

### Design decision 4 - Hidden checks are allowed, but must be disclosed as hidden

Judgment category: harden.

Why this is correct: anti-overfitting matters, hidden checks are useful, and
hidden check existence must still be disclosed.

Required machine enforcement: HarnessCards and RunCards must record whether
hidden checks were part of proof or evaluation.

Migration note: add protected evaluation roots if they are not already
formalized enough.

## K. Observability, Disclosure, and Reporting Design

### Refinement - add explicit constitutional contract families for observability and evolution

This is the main structural refinement beyond the prior packet. The repo
already has first-class `framework/observability/**` and a real
build-to-delete and evolution story, but the constitutional contract registry
still clusters most of the relevant artifacts into runtime, disclosure, and
retention without an explicit observability or evolution family. That leaves
measurement, intervention, failure taxonomy, retirement, deletion receipts,
and ablation logic semantically under-homed. The target state should add those
families explicitly.

### Design decision 1 - Observability records become first-class contracts

Target paths:

- add `.octon/framework/constitution/contracts/observability/**`

New artifacts:

- `measurement-record-v1`
- `measurement-summary-v1`
- `intervention-record-v1`
- `failure-incident-v1`
- `report-bundle-v1`

Judgment category: normalize.

Why this is correct: the current observability domain exists; its records
should be constitutionally typed.

Required machine enforcement: all consequential runs emit measurement and
intervention records, even when empty.

### Design decision 2 - RunCard and HarnessCard become generated disclosure surfaces only

Target paths:

- disclosure family
- disclosure evidence roots

Relation to current baseline: both already exist and are substantive.

Judgment category: harden.

Why this is correct: disclosure should summarize reality, not create it.

Required machine enforcement: cards are produced only from canonical
run, support, proof, and evidence graphs.

Migration note: preserve current fields, but add generation metadata and
claim-scope metadata.

### Design decision 3 - Failure taxonomy and replay indexing become reportable and queryable

Target paths:

- observability family
- observability runtime and governance domains
- external index

Judgment category: harden.

Why this is correct: auditability requires more than generic logs.

Required machine enforcement: every failed or degraded run is categorized by
failure class, support tuple, adapter tuple, and recovery outcome.

## L. Adapter, Capability-Pack, and Support-Target Design

### Design decision 1 - Keep the portable kernel narrow and explicit; keep non-portability adapter-mediated and justified

Target paths:

- constitution
- runtime adapters
- support matrix

Relation to current baseline: already strong.

Judgment category: preserve.

Why this is correct: portability where valuable, explicit non-portability
where necessary.

### Design decision 2 - Promotion, restriction, and de-admission become explicit support-target governance

Target paths:

- `support-targets.yml`
- admissions
- dossiers
- closure evaluator

Judgment category: harden.

Why this is correct: `stage_only` must mean something operational.

Required machine enforcement:

- `unsupported` -> deny
- `experimental` -> deny unless explicitly invoked in lab-only mode
- `stage_only` -> execute only with exclusion from live claim, explicit
  escalation or default route, and a dossier
- `supported` -> allowed within the bounded claim universe
- `deprecated` and `revoked` -> allowed only for migration or forensics, or
  denied

Migration note: current `stage_only` GitHub and frontier-governed tuples
remain excluded until promoted.

Proof and acceptance note: a promotion package must include required proof,
lab, replay, disclosure, and recertification data.

### Design decision 3 - Capability packs are the admission surface for browser, UI, and broader API action

Target paths:

- adapter contracts
- support tuples
- capability-pack family

Judgment category: normalize.

Why this is correct: action expansion should not be ad hoc.

Required machine enforcement: broader packs require stricter proof-plane and
governance coverage.

## M. Contract and Artifact Specifications

Below, each artifact is specified in target-state form. "Owner" means the
constitutional owning domain, not necessarily a human.

### Harness Charter

- Purpose: define what Octon is, is for, is not, and its non-negotiable
  obligations.
- Owner: constitutional kernel.
- Path: `.octon/framework/constitution/CHARTER.md` plus
  `.octon/framework/constitution/charter.yml`.
- Fields: identity, purpose, non-goals, obligations refs, ownership refs,
  support-truth model ref, amendment policy.
- Validator: charter schema plus cross-ref integrity.
- Lifecycle: authored, versioned, rarely changed.
- Enforcement: ingress precedence plus claim evaluator.
- Migration: preserve existing files; add claim-truth inversion references.

### Workspace Charter

- Purpose: repo-specific enduring operating envelope.
- Owner: instance authority.
- Path: `.octon/instance/charter/workspace.md` plus
  `.octon/instance/charter/workspace.yml`.
- Fields: workspace id, mission policy, support universe defaults, protected
  zones, baseline capabilities, repo-local source-of-truth map.
- Validator: workspace-charter schema plus ingress coherence.
- Lifecycle: stable, edited under governance.
- Enforcement: required in every run manifest.
- Migration: preserve current pair, add field parity where needed.

### Mission Charter

- Purpose: medium-lived governed objective spanning one or more runs.
- Owner: mission authority.
- Path: `.octon/instance/orchestration/missions/<mission-id>/**`
  or an equivalent canonical mission-authority artifact under the mission root.
- Fields: mission id, workspace ref, scope, exclusions, done-when,
  acceptance, risk or materiality, reversibility class, protected zones,
  required evidence, version.
- Validator: mission-charter schema plus support-target admissibility.
- Lifecycle: created before mission-required runs; amended under authority.
- Enforcement: required for tuples with `requires_mission`.
- Migration: disallow null mission in claim-included required-mission runs.

### Run Contract

- Purpose: bounded execution agreement for one run.
- Owner: runtime objective layer.
- Path: `.octon/state/control/execution/runs/<run-id>/run-contract.yml`;
  target schema `run-contract-v4`.
- Fields: run id, workspace ref, mission ref, mission_binding_mode,
  support-target tuple, requested capability packs, scope, exclusions,
  done-when, acceptance criteria, risk or materiality, reversibility,
  protected zones, required authority artifacts, required proof,
  transition_mode, disclosure expectations.
- Validator: schema plus mission binding plus support tuple plus protected-zone
  validation.
- Lifecycle: authored or generated pre-run; immutable after bind except for
  explicit annexes.
- Enforcement: runtime cannot start without a valid bound run contract.
- Migration: map v3 to v4; introduce explicit transition mode for excluded
  legacy cases.

### Execution Attempt Contract

- Purpose: one actual attempt to execute a stage under a run.
- Owner: runtime control layer.
- Path: `.octon/state/control/execution/runs/<run-id>/stages/<stage-id>/attempts/<attempt-id>.yml`;
  schema `execution-attempt-v1`.
- Fields: attempt id, stage ref, route receipt ref, grant bundle ref,
  lease refs, checkpoint strategy, contamination baseline, retry class,
  rollback posture ref, status.
- Validator: authority chain plus stage linkage plus checkpoint preconditions.
- Lifecycle: generated on stage attempt start; append-only state transitions.
- Enforcement: all tool execution must bind to an active attempt.
- Migration: split from old stage-attempt artifacts.

### Stage Contract

- Purpose: define one slice of a run.
- Owner: runtime objective layer.
- Path: `.octon/state/control/execution/runs/<run-id>/stages/<stage-id>/stage-contract.yml`;
  schema `stage-contract-v1`.
- Fields: stage id, stage name, run ref, scope, allowed capability packs,
  entry criteria, exit criteria, evidence plan, rollback candidate,
  claim effect, protected zones.
- Validator: schema plus run linkage.
- Lifecycle: created before stage execution.
- Enforcement: attempts cannot start without satisfying entry criteria.
- Migration: derive from current stage-attempt fields where needed.

### ApprovalRequest

- Purpose: canonical request for human or harness approval.
- Owner: authority layer.
- Path: `.octon/state/control/execution/approvals/requests/**`.
- Fields: request id, run and stage ref, requested action class, rationale,
  requested packs or tools, risk class, evidence refs.
- Validator: schema plus subject validity.
- Lifecycle: emitted before a gated action.
- Enforcement: no grant without request.
- Migration: preserve current workflow-generated artifacts.

### ApprovalGrant

- Purpose: canonical approval decision.
- Owner: authority layer.
- Path: `.octon/state/control/execution/approvals/grants/**`.
- Fields: grant id, request ref, issuer, scope, expiry, conditions,
  subject refs.
- Validator: schema plus request linkage.
- Lifecycle: emitted after approval.
- Enforcement: authority engine checks validity before action.
- Migration: preserve current shape; add stronger bundle binding.

### GrantBundle

- Purpose: compact set of active grants for a run or stage.
- Owner: authority layer.
- Path: `.octon/state/control/execution/approvals/bundles/**`
  or an equivalent per-run authority root.
- Fields: bundle id, included grants, effective scope, expiry window,
  supersedes refs.
- Validator: schema plus included-grant validity.
- Lifecycle: generated at bind or start, updated on re-approval.
- Enforcement: runtime resolves against a bundle rather than loose grants.
- Migration: current grant-bundle schemas become live required artifacts.

### ExceptionLease

- Purpose: bounded temporary exception.
- Owner: authority exception subsystem.
- Path: `.octon/state/control/execution/exceptions/leases/<lease-id>.yml`.
- Fields: lease id, lease class, run and stage refs, target surface,
  issued_by, owner, justification, allowed methods or paths, quota,
  issued_at, expires_at, revocation_mode, rollback posture ref,
  retirement trigger, status.
- Validator: schema plus authority chain plus expiry and revocation checks.
- Lifecycle: issued before exceptional action; expires or revokes
  automatically.
- Enforcement: runtime denies out-of-scope exceptional use.
- Migration: keep the leases set index for compatibility.

### Revocation

- Purpose: invalidate grants, leases, and routes.
- Owner: authority layer.
- Path: `.octon/state/control/execution/revocations/**`.
- Fields: revocation id, target refs, reason, effective_at, issuer, severity.
- Validator: schema plus target existence.
- Lifecycle: append-only.
- Enforcement: live kill-switch.
- Migration: preserve current contract; ensure runtime-wide checks.

### QuorumPolicy

- Purpose: define who or what combination can approve what.
- Owner: authority and governance layer.
- Path: authority-family schemas plus instance governance policies.
- Fields: policy id, action classes, approver sets, minimum quorum,
  escalation mode, expiry.
- Validator: policy schema plus actor refs.
- Lifecycle: authored and reviewed.
- Enforcement: grant issuance blocked unless policy is satisfied.
- Migration: formalize any inherited mission-autonomy semantics.

### DecisionArtifact

- Purpose: canonical allow, escalate, or deny resolution.
- Owner: authority engine.
- Path: `.octon/state/control/execution/decisions/**`
  or an equivalent per-run authority root.
- Fields: decision id, subject refs, route receipt ref, disposition,
  rationale, evidence refs, issuer class.
- Validator: schema plus route linkage.
- Lifecycle: emitted for each consequential decision.
- Enforcement: runtime follows only decision artifacts.
- Migration: preserve the current family and make it ubiquitous.

### Model Adapter Contract

- Purpose: define model-specific support and conformance.
- Owner: adapter layer.
- Path: `.octon/framework/engine/runtime/adapters/model/**`.
- Fields: adapter id, support status, default route, supported tuples,
  conformance suite refs, contamination or reset policy, known limitations.
- Validator: adapter schema plus support-target linkage.
- Lifecycle: authored, versioned, recertified.
- Enforcement: unsupported tuple combinations denied.
- Migration: preserve current adapters; add stronger promotion gates.

### Capability and Tool Contract

- Purpose: define tool and pack semantics.
- Owner: adapter and capability layer.
- Path: explicit capability-pack and tool schemas under adapter or a new
  capability-contract family.
- Fields: tool id, input or output schema, side-effect class, idempotency,
  compensation strategy, observability fields, default route, sandbox
  requirements.
- Validator: schema plus pack membership checks.
- Lifecycle: authored, versioned.
- Enforcement: tools unavailable without a valid contract.
- Migration: derive from current pack and tool surfaces.

### Host Adapter Contract

- Purpose: describe host projection behavior.
- Owner: adapter layer.
- Path: `.octon/framework/engine/runtime/adapters/host/**`.
- Fields: adapter id, authority mode, support status, projection sources,
  conformance suites, known limitations.
- Validator: adapter schema.
- Lifecycle: authored, recertified.
- Enforcement: host-native state cannot create authority.
- Migration: preserve current files.

### Run Manifest

- Purpose: bind run runtime roots and pointers.
- Owner: runtime layer.
- Path: per-run `run-manifest.yml`.
- Fields: actor ref, run root refs, stage root, evidence and disclosure roots,
  replay and trace roots, intervention and measurement roots, mission ref,
  support tuple, last execution receipt ref, effective precedence refs.
- Validator: schema plus root existence.
- Lifecycle: generated at bind or start, updated append-only by refs.
- Enforcement: canonical locator for all run artifacts.
- Migration: preserve and enrich.

### Checkpoint

- Purpose: durable resumability barrier.
- Owner: runtime layer.
- Path: per-run `checkpoints/**`.
- Fields: checkpoint id and type, stage and attempt refs, contamination status,
  rollback posture ref, side-effect barrier state, evidence refs.
- Validator: schema plus event-sequence coherence.
- Lifecycle: emitted pre and post consequential barriers and stage boundaries.
- Enforcement: resume allowed only from valid checkpoints.
- Migration: extend current bound checkpoint into a richer set.

### Continuity Artifact

- Purpose: mutable handoff state for continuation.
- Owner: runtime continuity layer.
- Path: `.octon/state/continuity/runs/<run-id>/handoff.yml`.
- Fields: current stage, open blockers, pending approvals, next steps,
  relevant refs, contamination notes.
- Validator: continuity schema plus run linkage.
- Lifecycle: mutable across a run; not retained proof authority.
- Enforcement: used for resume and init; not claim truth.
- Migration: introduce a normalized shape where missing.

### Replay Manifest

- Purpose: retained map to replayable evidence.
- Owner: retention and runtime layer.
- Path: `.octon/state/evidence/runs/<run-id>/replay/replay-manifest.yml`.
- Fields: class-A refs, class-B refs, class-C external immutable refs,
  external index ref, replay storage class.
- Validator: schema plus external index integrity.
- Lifecycle: emitted at retained milestones and completion.
- Enforcement: required for consequential runs.
- Migration: preserve current v2 manifest and tighten required refs.

### Compensation Artifact

- Purpose: record compensating action.
- Owner: runtime recovery layer.
- Path: `.octon/state/control/execution/runs/<run-id>/compensations/**`.
- Fields: compensation id, target event ref, action taken, outcome,
  residual risk.
- Validator: schema plus event linkage.
- Lifecycle: emitted after compensation.
- Enforcement: required when reversibility is compensating rather than rollback.
- Migration: move from schema-only intent to live use.

### Contamination Record

- Purpose: record state contamination or reset need.
- Owner: runtime recovery layer.
- Path: `.octon/state/control/execution/runs/<run-id>/contamination/**`.
- Fields: contamination id, source, severity, reset requirement,
  affected roots, resolution.
- Validator: schema plus run linkage.
- Lifecycle: append-only.
- Enforcement: resume and promotion gates check contamination state.
- Migration: make current schema and posture fields live mandatory on
  affected runs.

### Assurance Report

- Purpose: structured proof artifact for a plane or suite.
- Owner: assurance layer.
- Path: `.octon/state/evidence/runs/<run-id>/assurance/**`
  and `.octon/state/evidence/validation/**`.
- Fields: proof plane, suite ref, evaluator refs, outcome, evidence refs,
  hidden-check disclosure, interventions.
- Validator: assurance schema plus suite linkage.
- Lifecycle: emitted by proof jobs.
- Enforcement: required by support admissions and proof bundles.
- Migration: preserve current reports; standardize format.

### Intervention Record

- Purpose: explicit human or harness intervention disclosure.
- Owner: observability family.
- Path: `.octon/state/evidence/runs/<run-id>/interventions/log.yml`
  or `records/**`.
- Fields: intervention id, actor, reason, action taken, timing, materiality,
  hidden or visible flag.
- Validator: schema plus run linkage.
- Lifecycle: append-only, including explicit empty records.
- Enforcement: cards cannot claim zero intervention without an empty record.
- Migration: normalize current empty logs into an explicit contract.

### Measurement Record

- Purpose: structured runtime metric record.
- Owner: observability family.
- Path: `.octon/state/evidence/runs/<run-id>/measurements/**`.
- Fields: metric id, type, window, values, units, source, attribution.
- Validator: schema plus source linkage.
- Lifecycle: append-only or summarized by windows.
- Enforcement: required for cost, latency, token, or equivalent reporting.
- Migration: add per-record structure alongside current summaries.

### RunCard

- Purpose: per-run disclosure artifact.
- Owner: disclosure family.
- Path: `.octon/state/evidence/disclosure/runs/<run-id>/run-card.yml`.
- Fields: run id, support tuple, adapters, capability packs, authority refs,
  proof-plane refs, replay ref, intervention and measurement refs,
  claim effect, known exclusions.
- Validator: disclosure schema plus source-graph completeness.
- Lifecycle: generated after run completion or retained milestone.
- Enforcement: no consequential run counts toward claims without a valid
  RunCard.
- Migration: preserve current v2 richness and generate only.

### HarnessCard

- Purpose: release-level bounded disclosure artifact.
- Owner: disclosure family.
- Path: `.octon/state/evidence/disclosure/releases/<release-id>/harness-card.yml`
  plus `.octon/instance/governance/disclosure/harness-card.yml`
  for the current live release claim.
- Fields: release id, claim status, support universe, retained adapters,
  capability packs, proof bundle refs, coverage refs, parity refs,
  claim drift refs, representative runs, exclusions, recertification cadence.
- Validator: disclosure schema plus claim-evaluator linkage.
- Lifecycle: generated on release claim evaluation.
- Enforcement: no release completion claim without a valid HarnessCard.
- Migration: preserve current richness, remove any manual truth role.

### Evidence Retention Contract

- Purpose: define evidence classes and retention rules.
- Owner: retention family.
- Path: retention-family schemas such as
  `evidence-retention-contract-v2.schema.json` or the current equivalent.
- Fields: evidence class map, retention durations, storage class,
  immutability expectations, disclosure obligations, replay requirements.
- Validator: retention schema plus evidence-classification linkage.
- Lifecycle: authored, reviewed.
- Enforcement: run manifest and replay manifest must conform.
- Migration: preserve current v1 concepts and expand external immutable
  maturity.

### SupportTarget Matrix

- Purpose: define the bounded admitted support universe.
- Owner: instance governance.
- Path: `.octon/instance/governance/support-targets.yml`.
- Fields: tuple ids, host, model, workload, context, and locale classes,
  support status, default route, requires_mission, required proof,
  required authority artifacts, admitted packs, exclusions.
- Validator: support-target schema plus admission and dossier coherence.
- Lifecycle: authored and reviewed.
- Enforcement: runtime can only execute admitted tuples under declared routes.
- Migration: preserve the current matrix and add promotion and restriction
  fields.

### Retirement, Ablation, and Deletion Artifacts

- Purpose: operationalize build-to-delete.
- Owner: evolution family or governance and evidence domains.
- Paths:
  - `.octon/instance/governance/retirement/registry.yml`
    or the current equivalent retirement registry under governance contracts
  - `.octon/state/evidence/governance/ablation-reports/**`
  - `.octon/state/evidence/governance/deletion-receipts/**`
  - `.octon/instance/governance/retirement/reviews/**`
    or equivalent closeout review roots
- Fields: item id, type (shim, compensator, legacy surface, stage-only
  exclusion), owner, insertion reason, survival test, metric, review cadence,
  retirement trigger, rollback risk, status.
- Validator: no missing owner, cadence, or trigger; no overdue unresolved
  items.
- Lifecycle: created when any temporary scaffold is introduced; closed only by
  a deletion receipt or explicit retained waiver.
- Enforcement: claim evaluator fails on overdue or ownerless entries.
- Migration: bootstrap from existing stage-only tuples, legacy shims, and
  compensators.

## N. Repository Change Plan

### Create

- `.octon/framework/constitution/contracts/objective/stage-contract-v1.schema.json`
- `.octon/framework/constitution/contracts/objective/execution-attempt-v1.schema.json`
- `.octon/framework/constitution/contracts/objective/run-contract-v4.schema.json`
- `.octon/framework/constitution/contracts/observability/**`
- `.octon/framework/constitution/contracts/evolution/**`
- `.octon/instance/governance/retirement/**`
- `.octon/generated/effective/closure/**`
- `.octon/state/control/execution/runs/<run>/stages/<stage>/stage-contract.yml`
- `.octon/state/control/execution/runs/<run>/stages/<stage>/attempts/<attempt>.yml`
- `.octon/state/control/execution/runs/<run>/events/**`
  or `event-ledger.yml`
- `.octon/state/control/execution/exceptions/leases/index.yml`
- `.octon/state/control/execution/exceptions/leases/<lease>.yml`
- `.octon/state/evidence/governance/deletion-receipts/**`
- `.octon/state/evidence/governance/ablation-reports/**`

### Modify

- `.octon/framework/constitution/claim-truth-conditions.yml`
- `.octon/framework/constitution/charter.yml`
- `.octon/framework/constitution/obligations/fail-closed.yml`
- `.octon/instance/governance/support-targets.yml`
- `.octon/instance/governance/support-target-admissions/**`
- `.octon/instance/governance/support-dossiers/**`
- `.octon/framework/engine/runtime/adapters/**`
- `.octon/framework/agency/manifest.yml`
- `.octon/framework/assurance/**`
- `.octon/framework/lab/**`
- `.octon/framework/observability/**`
- `.octon/state/control/execution/runs/**`
- `.octon/state/evidence/disclosure/**`
- `.github/workflows/pr-autonomy-policy.yml`
- `.github/workflows/architecture-conformance.yml`

### Delete or demote

- any active kernel references to persona-heavy legacy agency surfaces
- any hand-authored closure outputs once generated equivalents exist
- any missionless required-mission execution path inside the live claim universe
- any undocumented or ownerless compensating shim

## O. Migration, Compatibility, and Rollout Plan

### Phase 0 - Truth freeze and compatibility mode

Keep current contracts and closure surfaces in place, but mark closure and
claim outputs as non-authoritative during migration. Existing run-contract-v3
and stage-attempt-v2 remain readable.

### Phase 1 - Objective normalization

Introduce `stage-contract-v1`, `execution-attempt-v1`, and `run-contract-v4`.
Add migration mappers from old state. All newly created runs use the new
shape. Old missionless required-mission runs are automatically tagged with an
excluded transition mode.

### Phase 2 - Authority normalization

Wrap all runtime and workflow entrypoints with the canonical authority engine.
Emit route receipts, decision artifacts, grant bundles, and lease refs
consistently. Keep compatibility writers for old approval roots where needed.

### Phase 3 - Runtime eventification

Start emitting append-only run events alongside existing runtime-state
projections. Introduce richer checkpoints and explicit continuity artifacts.
Use reconstruction tests to validate projection equivalence.

### Phase 4 - Observability and disclosure generation

Add the observability contract family, measurement and intervention records,
failure taxonomy, generated RunCards and HarnessCards, and generated closure
summaries.

### Phase 5 - Support-target hardening

Add explicit promotion, restriction, and de-admission fields, promotion
packages, and recertification gates. Keep GitHub and frontier-governed
excluded until proof parity is real.

### Phase 6 - Build-to-delete institutionalization

Bootstrap the retirement registry from all known stage-only exclusions, shims,
legacy active surfaces, and compensating mechanisms. Add deletion receipts and
ablation reports.

### Phase 7 - Claim re-evaluation

Only after the above, run the new claim evaluator to determine whether the
bounded "fully unified execution constitution" claim is now honest.

## P. Simplification, Deletion, and Retirement Plan

Delete or demote anything that is not load-bearing for constitutional
execution:

- persona-heavy agency remnants - move to inactive overlays or delete if
  unreferenced;
- compatibility-only stage and attempt shims - remove after migration coverage
  reaches 100 percent;
- missionless transition mode - sunset date mandatory; delete once the
  GitHub stage-only projection is either promoted with mission discipline or
  retired;
- manual closure status files - replace with generated outputs;
- any support tuple without dossier, admission, or review cadence - de-admit
  or mark unsupported;
- any broad capability pack that no longer carries unique value - retire and
  fold into a smaller explicit pack;
- any compensating mechanism without a measurable retirement trigger -
  fail closed, then delete or replace.

Build-to-delete becomes real when every temporary surface is visible in the
retirement registry and every removal emits a deletion receipt linked to the
prior artifact set and any rollback contingency.

## Q. Acceptance Gates and Proof Required

Before Octon can claim bounded target-state completion, all of the following
must exist and pass:

1. Objective semantics gate - no contradictory mission and run bindings in
   claim-included tuples.
2. Authority adoption gate - all material entrypoints emit canonical
   authority artifacts.
3. Lease and revocation gate - active lease scope, expiry, and revocation are
   enforced in runtime.
4. Runtime state gate - event ledger reconstructs the runtime-state
   projection.
5. Checkpoint and recovery gate - stage-aware checkpoints and
   rollback or compensation records exist for consequential tuples.
6. Support-target gate - every claim-included tuple is admitted,
   dossier-backed, recertified, and not `stage_only`.
7. Proof-plane gate - required proof planes exist for every admitted tuple.
8. Lab gate - required lab scenarios and retained evidence bundles exist per
   dossier.
9. Disclosure gate - generated RunCards, HarnessCards, and proof bundles
   exist and are source-complete.
10. Replay gate - the external immutable replay index is populated for
    required classes.
11. Retirement gate - no overdue or ownerless transitional items remain.
12. Closure generation gate - closure outputs are generated from the
    independent evidence graph only.

## R. Staged Implementation Program

### Wave 1 - Claim truth rebind

Severity: critical.

Unlocks: honest completion semantics.

Work: claim evaluator, closure generation, claim-status reclassification, and
build-to-delete inside truth.

### Wave 2 - Objective semantics repair

Severity: critical.

Unlocks: coherent workspace, mission, run, stage, and attempt model.

Work: stage-contract and execution-attempt split, run-contract-v4,
mission-binding rules.

### Wave 3 - Runtime-wide authority adoption

Severity: critical.

Unlocks: true governed autonomy.

Work: authority engine wrapping, route receipts, grants, bundles, lease
linkage, revocation checks.

### Wave 4 - Event-sourced runtime and recovery hardening

Severity: critical.

Unlocks: replayable, reconstructible lifecycle.

Work: event ledgers, rich checkpoints, compensation, contamination, and retry
records.

### Wave 5 - Observability and disclosure contractization

Severity: high.

Unlocks: scientifically meaningful reporting and audit.

Work: observability contract family, measurement and intervention records,
generated cards.

### Wave 6 - Support-target promotion system

Severity: high.

Unlocks: honest bounded live support universe.

Work: promotion criteria, restriction triggers, dossier hardening, parity
gating.

### Wave 7 - Proof-plane parity and lab binding

Severity: high.

Unlocks: full constitutional proof maturity.

Work: tuple-specific proof matrices, evaluator independence, hidden-check
disclosure, lab scenario catalogs.

### Wave 8 - Build-to-delete operating system

Severity: high.

Unlocks: low-entropy long-term architecture.

Work: retirement registry, ablation reports, deletion receipts,
overdue-item failure.

### Wave 9 - Agency kernel cleanup

Severity: medium.

Unlocks: final kernel simplification.

Work: demote or delete persona-heavy transitionals and preserve only the
orchestrator and verifier kernel.

### Wave 10 - Final bounded claim evaluation

Severity: terminal gate.

Unlocks: honest "fully unified execution constitution" claim within the
explicit live support universe.

Work: rerun the claim evaluator, emit the release HarnessCard, and publish the
closure bundle.

## S. Residual Risks and Open Questions

Current repo-grounded verdict: substantial, serious, architecture-faithful
implementation progress; not yet target-state complete enough for the final
claim.

Non-blocking uncertainties remain even after this packet:

- how broad the live support universe should be after completion; the packet
  recommends staying narrow until parity is proven;
- how far GitHub projection should ever be promoted versus remaining
  `stage_only` by design;
- how much hidden-check infrastructure is enough to prevent overfitting
  without introducing governance opacity;
- how multilingual and low-resource support should be added into the
  support-target matrix without premature overclaiming;
- how much of the current recovery and observability stack should become
  generated versus append-authored;
- whether an explicit evolution contract family is preferable to keeping
  retirement artifacts in governance and disclosure roots. This is the cleaner
  long-term move, but it is a refinement, not a prerequisite for the
  conceptual model.

Additional blind spots and residual risks from the current implementation
baseline remain important:

- structural and governance verification are still more visibly enforced than
  functional, behavioral, and recovery proof in the inspected workflow
  posture;
- the external immutable replay story is better specified than proven end to
  end; manifests and indices exist, but backend operational maturity is still a
  live risk;
- intervention disclosure exists as a contract and evidence family, but rich
  non-empty intervention cases remain under-evidenced in sampled artifacts;
- bounded support honesty is currently strong, but breadth beyond the present
  admitted support universe remains unproven;
- claim-surface optimism risk is now real: sophisticated HarnessCards,
  closure bundles, and proof/disclosure artifacts can look more complete than
  the live runtime enforcement actually is unless the evidence graph remains
  the only source of truth.

What does block core completion is clearer:

- contradictory mission binding;
- incomplete authority normalization;
- missing event-ledger truth as the primary runtime substrate;
- `stage_only` tuples inside the live claim universe;
- uneven proof parity;
- non-generated closure truth;
- build-to-delete remaining outside constitutional completion.

That is the packet: preserve the architecture that is already right, harden
the paths that still depend on convention, normalize the runtime and authority
chain, and refuse final claims until closure becomes a summary of proof rather
than a substitute for it.
