# Architect B Cross-Review Response

> **Third-party substitute:** the original Architect B was unavailable. This
> response is an independent substitute cross-review and must not be presented as
> the original architect's personal reconsideration.

```yaml
MODE: ARCHITECT_CROSS_REVIEW
ARCHITECT_LABEL: B
REVIEWER_STATUS: THIRD_PARTY_SUBSTITUTE
INTAKE_DIRECTORY: .octon/inputs/additive/.incoming/octon-architecture-and-migration-handoff-v2.0.0
SELF_REVIEW_DIRECTORY: .octon/inputs/exploratory/reviews/architecture-migration/architecture-migration-review-20260712T015106Z-57f6e8
OTHER_REVIEW_DIRECTORY: .octon/inputs/exploratory/reviews/architecture-migration/architecture-migration-review-20260712T015114Z-6e5b57
RECONCILIATION_ID: architecture-migration-reconciliation-20260712T032411Z-10c3ff
```

This package remains non-authoritative research input. I did not communicate
with the other architect, did not read the Architect A cross-review output, did
not inspect any unrelated sibling review, and made no source, provider,
credential, workflow, Git, or original-review mutation. All writes by this
substitute are the eight required files in `cross-review/architect-b/`.

## Baseline normalization

The two reviews are directly comparable.

| Field | SELF review | OTHER review |
|---|---|---|
| Review ID | `architecture-migration-review-20260712T015106Z-57f6e8` | `architecture-migration-review-20260712T015114Z-6e5b57` |
| Repository | `git@github.com:jamesryancooper/octon.git` | same |
| Branch | `main` | `main` |
| Commit | `c5b1f5760c78ff521cca6b054e4e8fef5300505b` | same |
| Commit time | `2026-07-11T16:56:55-05:00` | same |
| Worktree | clean at review baseline | clean outside the deliberately excluded review tree |
| Host | macOS 26.5.2 arm64 | same |
| Completion | `2026-07-12T03:08:31Z` | `2026-07-12T02:31:13Z` |
| Provider evidence | available, point-in-time | available, point-in-time |
| Integrity | 46/46 intentional indexed files passed | 56/56 indexed files passed |
| Decision coverage | FD-001 through FD-024 | FD-001 through FD-024 |

No repository delta is required. Both packages contain unindexed `.DS_Store`
metadata; this does not invalidate their intentional artifacts, but the final
reconciliation should exclude or explicitly account for that metadata in its
own integrity policy. Neither baseline proves the state of a concurrently
created review directory, and provider observations remain point-in-time.

The OTHER review provides the stronger material-finding spine: its 14 AMR
findings consistently bind commit-qualified source, command/result/provider
references, confidence, limitations, repair, and acceptance tests. The SELF
review is broader and contains several valuable unique adversarial findings,
but its 106 findings are less uniform at finding-level traceability.

## Subagent record

Four bounded subagents covered the eight required roles. Each was prohibited
from reading unrelated sibling reviews or Architect A reconciliation artifacts,
and none wrote files.

### 1–2. Baseline/provenance and authority/broker/execution

- Agent: `b_baseline_authority`
- Inspected paths: the two named manifests, repository baselines, integrity
  indexes, decision crosswalks, intake decisions, lifecycle/authority source,
  broker helper, hosted no-PR scripts, and provider workflow source.
- Accepted: same clean commit, both integrity indexes, complete FD coverage,
  lifecycle-local authority, missing launch guards, broker/store absence,
  ambient hosted landing, OTHER AMR-002 scope widening, and SELF L1-01/L1-03
  candidate-editable authority decision.
- Rejected/narrowed: SELF's earlier claim that the kernel path was a trustworthy
  completed FD-003 boundary; any claim that credential presence/use was proven;
  and OTHER GATE-0 sufficiency without decision-source pinning.
- Unresolved: dynamic scope exploit, credential use, and point-in-time provider
  drift.

### 3–4. Isolation/Git/publication and runtime/evidence/recovery

- Agent: `b_isolation_runtime`
- Inspected paths: Codex/Claude launchers, worktree/Git landing scripts,
  direct-main contract, GitHub workflows/provider evidence, effect-token
  persistence, runtime bus, retention/evidence contracts, intake FD-005/013/014,
  and both migration maps.
- Accepted: credential-capable host exposure, independent-Git requirement,
  provider containment, immutable verifier direction, full transactional
  lifecycle, attempt-bound reconciliation, broker supervision, and early doctor.
- Rejected: SELF's narrow-CAS/full-store deferral, Git anchoring as an FD-014
  substitute, and delaying evidence capacity/retention beyond Class B proof.
- Unresolved: macOS sandbox mechanism, usable credentialless provider session,
  broker IPC/Keychain behavior, signer custody, retention budgets, and actual
  provider exploit reproduction.

### 5–6. Self-development/trust root and Projects/Harness/extensions/children

- Agent: `b_trust_product`
- Inspected paths: intake target decisions, evolution/promotion code and specs,
  candidate-head certification workflow, Project Profile/locality, route-bundle
  generator/resolver, task-harness specification, adapter dispatch/manifests,
  extension trust/publication, and lifecycle child scheduling.
- Accepted: FD-018 absent; FD-021 partial; FD-022 has valuable but unsafe partial
  primitives; Workspace Projects remain required; OTHER's WG-09 and WG-11
  dependencies are sound.
- Rejected: SELF's FD-020 and FD-023 `SATISFIED` classifications, Workspace
  Project final deferral, and any claim that populating a hash field alone makes
  the catalog signed.
- Clarified: `promotion_blockers()` has inspect/apply callers but is not an
  enforced merge/install/activation/rollback boundary; preserve it as scaffolding.
- Unresolved: exact trust-root inventory/bootstrap, provider replacement
  conformance, extension signer policy, and child delegation-depth proof.

### 7–8. Migration/proposal program and simplification/solo-builder challenge

- Agent: `b_program_solo`
- Inspected paths: both packet maps, safe intermediate states, implementation
  gates, simplification registers, operator decisions, product budgets, CLI
  doctor implementation, and measured repository state/workflow surfaces.
- Accepted: shared dependency spine, manual/protected-PR bridge, one supervised
  broker process owning its SQLite writer and Git adapter, full FD-005/014/019
  endpoints, and `READY_FOR_PROPOSAL_PROGRAM` semantics.
- Rejected: late catch-all UX, incomplete source ownership, narrow-CAS as final
  store, git-anchored evidence as final target, and omission of tracked run-state
  and CI operating burden.
- Unresolved: provider hosting/credential form, broker lifecycle mechanism,
  signer/trust-root/retention choices, CI keep/merge/delete set, and exact
  zero-prompt ACP mapping.

## Strongest areas of agreement

The reviews converge on the load-bearing current facts:

1. `authority_engine` and typed effects are valuable, but lifecycle/process
   launch does not consume their exact one-shot authority.
2. Candidate processes are not credentialless and do not have independent host
   and Git state.
3. No accepted durable-effect broker or SQLite/WAL authority store exists.
4. Direct-main and ambient Git contradict the accepted publication direction.
5. The active privileged provider lane executes candidate code with a write
   credential, while required verifier code is also candidate-controlled.
6. Token and journal persistence is not transactionally concurrency/crash safe.
7. Hash-linked evidence is useful but does not provide the accepted signer,
   checkpoint, capacity, retention, and recovery properties.
8. Autonomous trust-root activation is absent.
9. Existing authority, exact-ref, provider-rule, context, route-bundle,
   extension-publication, evidence, and promotion primitives should be preserved.
10. The safe bridge is manual/protected PR; no autonomous direct-main, dual
    authority, dual writer, credentialed candidate, or unsigned fallback may survive.

The reviews also converge on the migration spine:

```text
contain unsafe provider/direct-main paths
→ canonical trusted authority and launch guards
→ credentialless native isolation + independent Git
→ one full SQLite/WAL authority store
→ one supervised local broker
→ sanitized Git
→ independent exact-SHA verifier
→ signed evidence, capacity, recovery, reconciliation, retention
→ autonomous Class B proof
→ safe self-development and trust-root activation
→ Projects, full Harness Factory, extensions, bounded children, UX
→ claim promotion
```

## Most important factual disagreements

### The OTHER review found a real scope-widening defect the SELF review missed

`scope_matches` accepts both prefix directions and lacks component boundaries.
That can make an authentic narrow token match a parent or sibling-prefix target.
I accept OTHER AMR-002 and add it to WG-01. The code fact is
`STATICALLY_INSPECTED`; symlink/case/normalization exploitation remains untested.

### The SELF review found a deeper authority defect the OTHER review missed

`authorize_execution` trusts an in-tree policy runner and policy and accepts
production override paths/modes. Routing every launch through this function is
necessary but insufficient until the decision evaluator and inputs are
candidate-immutable and release overrides fail closed. This finding must be
imported into GATE-0/WG-01 and the trust-root inventory.

### The current route bundle is not the accepted Harness Factory

The route publisher hashes runtime resolution, support, capability routes,
extensions, and workflow manifest. The accepted Factory must compile the exact
project, mission, Run Contract, policy, model/tool, context, validation, evidence,
rollback, and extension inputs into a per-run manifest whose digest is bound into
authorization and spawn. The existing generator/resolver is a strong retained
primitive, so the correct status is `PARTIALLY_SATISFIED`, not greenfield absence
or completed satisfaction.

### Provider adapter contracts do not prove provider replacement

Non-authoritative replaceable adapter contracts are strong. Actual lifecycle
dispatch still hardcodes Codex/Claude selection and different safety postures,
and the current provider effect plane violates the intended seam. FD-023 is
`PARTIALLY_SATISFIED`, not complete.

### Dynamic evidence must remain narrow

The OTHER review dynamically showed the proof validator emitting a referenced
test as executed; that is accepted. Its sequential Rust and shell suites did not
dynamically demonstrate the concurrency/crash defects. Those defects remain
high-confidence static findings requiring explicit fault injection.

## Most important architectural disagreements

### Full store versus narrow CAS

The SELF simplification to atomic files plus a narrow transactional CAS conflicts
with accepted FD-005 and with multi-file observed state transitions. It is valid
as a preparatory milestone, not as WG-03 exit. One SQLite/WAL source must own all
accepted operation lifecycle state before brokered privileged effects.

### Signed evidence versus git-anchored rewording

Immediate rewording of current claims is correct. Replacing the accepted FD-014
target with plain Git anchoring is not. Git does not authenticate direct producer
identity or provide the accepted monotonic checkpoint and compaction semantics.
Signer mechanism and custody remain choices; the signed property is fixed unless
formally reopened.

### Workspace Projects as required solo-product infrastructure

The SELF deferral until a second project appears would leave FD-019/FD-024
incomplete. Workspace Project stays small, inferred, and non-authoritative. It can
run outside the first single-project safety critical path, but must precede the
full Harness Factory and complete-target claim.

### Packet ownership and operator experience

The OTHER 14-packet spine is stronger than the SELF endpoint, but WG-12 is too
broad and late. Broker supervision, guided enrollment, doctor/repair, and basic
zero-prompt route proof belong with WG-04/WG-06. Extension supply-chain,
child-agent safety, and multi-project product dogfood need explicit owners or
sub-packets. Numeric affected areas are not sufficient source ownership for a
formal proposal packet.

### Maintenance burden must be migrated, not hidden

The SELF review's tracked run-state and CI-breadth measurements remain material.
The formal program should assign:

- WG-00: physical state/workflow inventory and unsafe-plane containment;
- WG-03: operational run state into SQLite/ignored local raw storage, with
  legacy files read-only projections;
- WG-06: workflow keep/merge/retire while replacing candidate verifiers/effects;
- WG-07: quotas, checkpoints, compaction, and pins; and
- WG-13: zero per-run project-Git growth and monthly maintenance proof.

This adds no subsystem; it fulfills the intake's raw-evidence and maintenance budgets.

## Corrections accepted from the OTHER review

The substitute SELF position now:

- accepts the scope-widening and proof-metadata findings;
- changes FD-020 and FD-023 from `SATISFIED` to `PARTIALLY_SATISFIED`;
- changes FD-013 to `ABSENT` and FD-024 to `REQUIRES_DYNAMIC_PROOF`;
- credits partial primitives for FD-002, FD-014, and FD-022;
- retains full FD-005, FD-014, and FD-019 endpoints;
- treats store, broker, and Git as separate responsibilities even if one broker
  process owns their runtime implementation; and
- changes the readiness verdict to `READY_FOR_PROPOSAL_PROGRAM`.

The complete immutable amendment record is in `accepted-amendments.yml` and
`self-corrections.yml`.

## Conclusions still rejected or narrowed

I do not accept:

- OTHER GATE-0 as complete without authority decision-source pinning;
- a dynamic label as proof that token/journal races were reproduced;
- all setup/enrollment/doctor/repair work arriving only in late WG-12;
- CLI hiding as sufficient response to tracked state and CI burden; or
- fresh HOME/environment clearing as a complete credentialless provider-session design.

I retain SELF's findings on candidate-editable policy/runner/overrides, tracked
run-evidence exhaust, workflow burden, full Git extension coverage, early broker
supervision/doctor, and zero-prompt route cleanup. I narrow the SELF claim that
specific tokens were inherited: current code proves credential-capable exposure,
not a particular credential's presence, readability, or use.

## Missing evidence

The decisive remaining proofs are enumerated in
`evidence-reverification-requests.yml`. The most important are:

- adversarial authority policy/runner/override substitution;
- typed resource scope normalization/boundary negatives;
- useful credentialless Codex/Claude execution plus escape/credential/Git denial;
- full SQLite concurrency, kill-point, ENOSPC, backup, and unknown-outcome tests;
- hostile Git extension fixtures;
- immutable verifier, duplicate-context, target-race, and expiry tests;
- complete Harness Factory compile/digest/launch proof;
- signed evidence forgery/rechain/snapshot/compaction tests;
- trust activation self-widening and every kill point; and
- timed two-project solo dogfood and 30-day maintenance evidence.

These block their owning packet exits, not creation of the proposal program.

## Effect on migration architecture

The OTHER architecture is the better base after four amendments:

1. Add candidate-immutable authority decision-source integrity to WG-00/WG-01.
2. Keep the full FD-005/FD-013/FD-014 transaction and evidence properties before
   Class B proof; do not substitute atomic files or plain Git anchoring.
3. Ship supervised broker lifecycle, enrollment, doctor, and repair with WG-04,
   and initial zero-prompt route proof with WG-06.
4. Give exact file/contract/schema ownership to each formal packet, split or
   explicitly partition WG-12, and assign tracked state/CI simplification.

No accepted target decision is reopened. No VM, enterprise IAM, distributed
consensus, PR-only endpoint, autonomous direct-main, public marketplace,
persistent autonomous organization, second broker/control plane, self-authorizing
metadata, or credentialed candidate is restored.

## Effect on proposal-program readiness

The SELF review's three supposed program-authoring blockers were not valid at
that level:

- signing is already accepted; only its mechanism remains;
- the solo boundary already excludes federation as a target requirement; only
  source disposition remains; and
- trust-root inventory/bootstrap must close before WG-09 design exit, not before
  the program is created.

Accordingly, the substitute cross-review supports creating the formal proposal
program now. Privileged implementation remains blocked until corrected GATE-0,
and every later autonomy/support claim remains proof-gated.

## Cross-review verdict

**READY_FOR_PROPOSAL_PROGRAM**
