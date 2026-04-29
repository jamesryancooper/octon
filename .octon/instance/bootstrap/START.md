---
title: Start Here
description: Boot sequence and orientation for the root .octon Constitutional Engineering Harness.
---

# .octon: Start Here

Canonical goal: Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

Use this document for the steady-state boot sequence. Canonical topology,
authority families, publication metadata, and doc roles live in
`/.octon/framework/cognition/_meta/architecture/contract-registry.yml`.

Bootstrap treats runtime helpers as portable operational support, not as a
second authority plane. The constitutional kernel anchor remains
`/.octon/framework/constitution/CHARTER.md`, authored lab assets remain under
`/.octon/framework/lab/`, and retained lab evidence remains under
`/.octon/state/evidence/lab/`.

Instance-native repo authority lives at:

- `/.octon/instance/manifest.yml`
- `/.octon/instance/ingress/**`
- `/.octon/instance/bootstrap/**`
- `/.octon/instance/charter/**`
- `/.octon/instance/governance/**`
- `/.octon/instance/locality/**`
- `/.octon/instance/cognition/decisions/**`
- `/.octon/instance/orchestration/missions/**`

## Boot Sequence

1. Enter through ingress.
   - repo-root `AGENTS.md` or `CLAUDE.md`
   - `/.octon/AGENTS.md`
   - `/.octon/instance/ingress/AGENTS.md`
2. Bind the constitutional and workspace objective surfaces.
   - `/.octon/framework/constitution/**`
   - `/.octon/instance/charter/workspace.md`
   - `/.octon/instance/charter/workspace.yml`
3. Bind structural orientation when the task touches topology, docs, bootstrap,
   publication, or placement rules.
   - `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
   - `/.octon/framework/cognition/_meta/architecture/specification.md`
4. Run the standard preflight before the first material task when local harness
   health or publication freshness matters.
   - `octon doctor --architecture`
   - `/bootstrap-doctor` as the workflow-backed readiness companion
   - `provision-host-tools`
   - canonical workflow:
     `/.octon/framework/orchestration/runtime/workflows/tasks/bootstrap-doctor/workflow.yml`
5. Resume continuity if the work is not greenfield.
   - repo continuity:
     `/.octon/state/continuity/repo/{log.md,tasks.json}`
   - scope continuity when one declared scope owns the work:
     `/.octon/state/continuity/scopes/<scope-id>/**`

## Authority Map

| Surface | Use |
| --- | --- |
| `framework/constitution/**` | Supreme repo-local control authority |
| `instance/charter/**` | Workspace objective authority |
| `instance/governance/**` | Repo-owned policy, support-target, exclusion, ownership, and governance disclosure authority |
| `instance/orchestration/missions/**` | Mission continuity authority |
| `state/control/**` | Mutable execution, publication, extension, and quarantine truth |
| `state/evidence/**` | Retained evidence, disclosure, and validation receipts |
| `state/continuity/**` | Handoff and resumption state |
| `generated/effective/**` | Runtime-facing derived outputs with receipt-backed freshness |
| `generated/cognition/**` | Non-authoritative operator and mission read models |
| `inputs/**` | Non-authoritative additive and exploratory inputs only |

Consequential execution binds mission, run, control, and evidence surfaces
without treating generated summaries or raw inputs as authority.
Material execution remains bound to run contracts and execution authorization.

## Live Operator Flow

Use these surfaces by name when orienting or resuming governed work. Numeric
maturity labels are lineage only; they are not the primary artifact identity.

### Safe Start

Safe Start enters through `octon start`, `octon profile`, `octon plan`, and
`octon arm --prepare-only`. The flow creates or updates Engagement, Project
Profile, Work Package, Decision Request, Evidence Profile, Preflight Evidence
Lane, Tool/MCP Connector Posture, and Run Contract Candidate surfaces. It does
not execute material work. The Run Contract Candidate becomes executable only
through `octon run start --contract <path>` after required decisions, context,
support, rollback, evidence, and execution authorization gates pass.

### Safe Continuation

Safe Continuation enters through `octon mission` and `octon continue`. The
Mission Runner evaluates the Autonomy Window, Mission Queue, Action Slice,
Continuation Decision, Mission Run Ledger, and Mission Evidence Profile before
preparing a bounded continuation. Mission continuation may stage a new
run-contract candidate, but the mission surface does not replace the run
lifecycle or authorize material execution by itself.

### Continuous Stewardship

Continuous Stewardship enters through `octon steward`. A Stewardship Program
may open a finite Stewardship Epoch, observe a Stewardship Trigger, emit a
Stewardship Admission Decision, Idle Decision, or Renewal Decision, and update
the Stewardship Ledger. Stewardship is a bounded care loop, not an infinite
agent loop; it may hand off mission candidates, but it never executes work
directly.

### Connector Admission Runtime

Connector Admission Runtime enters through `octon connector`. Connector
Operation, Connector Trust Dossier, Connector Evidence Profile, Connector Drift
Record, Connector Quarantine, support-target proof hooks, and operation-level
capability mapping govern external tool posture. Browser, API, broad MCP,
arbitrary external systems, and effectful connectors remain stage-only,
unadmitted, unsupported, or non-live unless support-target admission,
capability-pack admission, connector dossier sufficiency, rollback posture,
Decision Request resolution, run contract, context pack, execution
authorization, authorized-effect token verification, retained evidence, and
disclosure all pass.

### Constitutional Self-Evolution

Constitutional Self-Evolution enters through `octon evolve`, `octon promote`,
`octon amend`, and `octon recertify`. Evolution Program, Evolution Candidate,
Evidence-to-Candidate Distillation Record, Governance Impact Simulation,
Assurance Lab Promotion Gate, Evolution Proposal Compiler, Constitutional
Amendment Request, Promotion Runtime, Recertification Runtime, and Evolution
Ledger surfaces may prepare and evidence change. They do not self-authorize
constitutional, governance, runtime, support, connector, release, or evidence
changes.

### Federated Trust

Federated Trust enters through `octon compatibility`, `octon adopt`,
`octon proof`, `octon attest`, `octon trust`, and `octon federation`. Octon
Compatibility Profile, external project compatibility inspection, safe external
adoption posture, Portable Proof Bundle, Attestation Envelope, Local Acceptance
Record, Trust-Domain hook, proof import/export, attestation verify/accept/reject,
revocation, and expiry behavior are evidence and classification surfaces.
Imported proof and external attestations remain evidence only until a valid
Local Acceptance Record admits them locally; they never authorize execution,
widen support, or turn non-Octon systems into federation peers.

## Publication Model

- Runtime-facing effective outputs live under `generated/effective/**`.
- Operator and mission read models live under `generated/cognition/**`.
- Proposal discovery lives under `generated/proposals/registry.yml`.
- Generated outputs require the publication and freshness conditions declared in
  `contract-registry.yml#publication_metadata`.
- Retained publication receipts live under
  `state/evidence/validation/publication/**`.

## Human-Led Zone

`/.octon/inputs/exploratory/ideation/**` remains human-led. Autonomous access
is blocked unless a human explicitly scopes the request.

Proposal packets under `/.octon/inputs/exploratory/proposals/**` may inform
review or promotion work, but they remain non-authoritative lineage until their
content is promoted outside `inputs/**`.

## Additive Inputs

- raw pack input: `inputs/additive/extensions/<pack-id>/**`
- desired trust activation: `instance/extensions.yml`
- actual active state: `state/control/extensions/active.yml`
- quarantine state: `state/control/extensions/quarantine.yml`
- compiled runtime-facing outputs: `generated/effective/extensions/**`

## When You Need History

Historical wave, cutover, and proposal-lineage material no longer lives in this
boot document. Use:

- `/.octon/instance/cognition/decisions/index.yml` for durable ADR discovery
- `/.octon/instance/cognition/decisions/094-*.md` through `098-*.md` for the
  docs and topology remediation lineage
- `/.octon/state/evidence/migration/**` for retained migration evidence

## Minimal Next Actions

1. Read the ingress surface and workspace charter pair.
2. Read the structural registry if the task affects topology, docs, bootstrap,
   publication, or placement.
3. Run `/bootstrap-doctor` when freshness or local harness health is in doubt.
4. Use Safe Start to prepare Engagement, Project Profile, Work Package,
   Decision Request, Evidence Profile, connector posture, and Run Contract
   Candidate surfaces when the task is new.
5. Use Safe Continuation or Continuous Stewardship only when the work is
   mission-backed or recurring.
6. Use Connector Admission Runtime, Constitutional Self-Evolution, or Federated
   Trust only for their named governance surfaces; none of them replaces run
   contracts or execution authorization.
7. Use `octon run start --contract <path>` for the first consequential run,
   then inspect, disclose, close, and replay it through the `octon run`
   lifecycle commands.
8. Resume continuity, then execute the highest-priority unblocked task.
