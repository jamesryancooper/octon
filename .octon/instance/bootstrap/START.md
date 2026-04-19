---
title: Start Here
description: Boot sequence and orientation for the root .octon harness.
---

# .octon: Start Here

Octon is an authored harness core designed for profile-driven portability and replaceable adapters across repositories.

Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

The currently proved live consequential envelope in this repository is the
retained `MT-B / WT-2 / LT-REF / LOC-EN` tuple using the `repo-shell` host
adapter and the `repo-local-governed` model adapter. Broader portability or
adapter coverage remains architectural intent until retained disclosure proof
and support-target publication promote it into a live claim.

## Single-Root Model

This harness uses one repo-root `.octon/` per repository.

| Component | Canonical Path |
|-----------|----------------|
| Execution roles | `.octon/framework/execution-roles/runtime/` |
| Templates | `.octon/framework/scaffolding/runtime/templates/` |
| Workflows | `.octon/framework/orchestration/runtime/workflows/` |
| Skills | `.octon/framework/capabilities/runtime/skills/` |
| Commands | `.octon/framework/capabilities/runtime/commands/` |
| Host tool contracts | `.octon/framework/capabilities/runtime/host-tools/` |
| Tools | `.octon/framework/capabilities/runtime/tools/` |
| Services | `.octon/framework/capabilities/runtime/services/` |
| Lab | `.octon/framework/lab/` |
| Observability | `.octon/framework/observability/` |
| Prompts | `.octon/framework/scaffolding/practices/prompts/` |
| Context | `.octon/instance/cognition/context/shared/` |
| Checklists | `.octon/framework/assurance/` |

**Resolution:** The active harness is the only `.octon/` on the current repository ancestor chain. Sibling repositories may each have their own repo-root harness.

## Control-Plane Profiles

`/.octon/octon.yml` is the authoritative root manifest for topology,
versioning, install/export profiles, and fail-closed policy hooks.

| Profile | Operator Surface | Behavior |
|-----------|----------------|----------|
| `bootstrap_core` | `/init` | Complete bootstrap after adopting the framework bundle and minimal instance metadata; raw `inputs/**`, `state/**`, and `generated/**` stay excluded, and host-tool installation remains out of scope |
| `repo_snapshot` | `/export-harness --profile repo_snapshot` | Export `octon.yml`, `framework/**`, `instance/**`, and the clean published enabled-pack dependency closure while excluding `inputs/exploratory/**`, `state/**`, and `generated/**`; fail closed when enabled-pack state is incompatible, quarantined, or incomplete |
| `pack_bundle` | `/export-harness --profile pack_bundle --pack-ids <csv>` | Export only selected additive packs plus dependency closure; do not apply repo trust activation policy |
| `full_fidelity` | Git clone | Advisory only; not a synthetic export payload |

---

## Constitutional Kernel

Repo-local supreme control authority lives under `framework/constitution/**`.

| Artifact Family | Canonical Path |
|-----------|----------------|
| Charter | `.octon/framework/constitution/CHARTER.md` |
| Charter manifest | `.octon/framework/constitution/charter.yml` |
| Normative precedence | `.octon/framework/constitution/precedence/normative.yml` |
| Epistemic precedence | `.octon/framework/constitution/precedence/epistemic.yml` |
| Fail-closed obligations | `.octon/framework/constitution/obligations/fail-closed.yml` |
| Evidence obligations | `.octon/framework/constitution/obligations/evidence.yml` |
| Ownership roles | `.octon/framework/constitution/ownership/roles.yml` |
| Contract registry | `.octon/framework/constitution/contracts/registry.yml` |
| Objective contracts | `.octon/framework/constitution/contracts/objective/` |
| Authority contracts | `.octon/framework/constitution/contracts/authority/` |
| Assurance contracts | `.octon/framework/constitution/contracts/assurance/` |
| Disclosure contracts | `.octon/framework/constitution/contracts/disclosure/` |
| Adapter contracts | `.octon/framework/constitution/contracts/adapters/` |
| Support-target schema | `.octon/framework/constitution/support-targets.schema.json` |

Prompts, ingress adapters, workflows, and generated projections may project
this kernel, but they may not redefine it.

---

## Canonical Specification

The cross-subsystem structural architecture contract for this harness is:

- `cognition/_meta/architecture/specification.md`

It remains subordinate to the constitutional kernel above and must not restate
competing repo-local constitutional authority.

Subsystem expansion specs:

- `agency/_meta/architecture/specification.md`
- `capabilities/_meta/architecture/specification.md`
- `orchestration/_meta/architecture/specification.md`
- `engine/_meta/architecture/README.md`

---

## Structure

```text
.octon/
├── README.md
├── AGENTS.md
├── octon.yml
├── framework/
│   ├── manifest.yml
│   ├── constitution/
│   ├── agency/
│   ├── assurance/
│   ├── capabilities/
│   ├── cognition/
│   ├── engine/
│   ├── lab/
│   ├── observability/
│   ├── orchestration/
│   └── scaffolding/
├── instance/
│   ├── manifest.yml
│   ├── extensions.yml
│   ├── ingress/
│   ├── charter/
│   ├── bootstrap/
│   ├── governance/
│   ├── agency/
│   ├── assurance/
│   ├── cognition/
│   ├── locality/
│   ├── capabilities/
│   └── orchestration/
├── inputs/
│   ├── additive/
│   │   └── extensions/
│   └── exploratory/
│       ├── ideation/
│       ├── plans/
│       ├── drafts/
│       ├── packages/
│       └── proposals/
├── state/
│   ├── continuity/
│   ├── evidence/
│   └── control/
└── generated/
    ├── effective/
    ├── cognition/
    └── proposals/
```

Only `framework/**` and `instance/**` are authored authority. Raw
`inputs/**` remain non-authoritative even when a profile exports them.

`state/**` has three required lifecycle subdomains:

- `state/continuity/**` for active repo and scope handoff state
- `state/evidence/**` for retained operational receipts and traceability
- `state/control/**` for mutable publication and quarantine truth

`inputs/exploratory/proposals/**` is the canonical raw proposal workspace.
Proposal packages remain non-authoritative, are excluded from
`bootstrap_core` and `repo_snapshot`, and are discoverable only through the
generated projection at `generated/proposals/registry.yml`.

## Overlay And Ingress Model

Canonical ingress resolves through this chain:

1. repo-root `AGENTS.md` or `CLAUDE.md`
2. `/.octon/AGENTS.md`
3. `/.octon/instance/ingress/AGENTS.md`

Root `AGENTS.md` and `CLAUDE.md` are thin adapters only. They must be a
symlink to `/.octon/AGENTS.md` or a byte-for-byte parity copy and may not add
runtime or policy text.

Ingress and prompt surfaces may project the constitutional kernel, but
`framework/constitution/**` remains the supreme repo-local control regime.

Instance-native repo authority lives at:

- `instance/manifest.yml`
- `instance/ingress/**`
- `instance/charter/**`
- `instance/bootstrap/**`
- `instance/locality/**`
- `instance/cognition/context/**`
- `instance/cognition/decisions/**`
- `instance/capabilities/runtime/**`
- `instance/orchestration/missions/**`
- `instance/extensions.yml`

Raw additive inputs remain non-authoritative and activate only through the
authored publication chain:

- raw pack input: `inputs/additive/extensions/<pack-id>/**`
- desired trust activation: `instance/extensions.yml`
- actual active state: `state/control/extensions/active.yml`
- quarantine state: `state/control/extensions/quarantine.yml`
- publication receipts: `state/evidence/validation/publication/extensions/**`
- compiled runtime-facing outputs: `generated/effective/extensions/**`

Canonical locality resolution and publication surfaces are:

- `instance/locality/manifest.yml`
- `instance/locality/registry.yml`
- `instance/locality/scopes/<scope-id>/scope.yml`
- `instance/cognition/context/scopes/<scope-id>/**`
- `state/continuity/scopes/<scope-id>/**`
- `state/control/locality/quarantine.yml`
- `state/evidence/validation/publication/locality/**`
- `generated/effective/locality/scopes.effective.yml`
- `generated/effective/locality/artifact-map.yml`
- `generated/effective/locality/generation.lock.yml`
- `state/evidence/validation/publication/capabilities/**`
- `generated/effective/capabilities/routing.effective.yml`
- `generated/effective/capabilities/artifact-map.yml`
- `generated/effective/capabilities/generation.lock.yml`

Packet 6 locality remains root-owned. Descendant `.octon/` roots,
nearest-registry fallback, hierarchical scope inheritance, and ancestor-chain
scope composition are invalid in v1.

Extension activation uses one desired/actual/quarantine/compiled model:

- desired config: `instance/extensions.yml`
- actual active state: `state/control/extensions/active.yml`
- quarantine state: `state/control/extensions/quarantine.yml`
- publication receipts: `state/evidence/validation/publication/extensions/**`
- runtime-facing compiled outputs: `generated/effective/extensions/**`
- runtime-facing capability routing: `generated/effective/capabilities/**`
- derived cognition read models: `generated/cognition/**`

Host-tool provisioning uses one repo-desired / host-actual model:

- desired repo requirements:
  `instance/capabilities/runtime/host-tools/requirements.yml`
- repo-owned resolution policy:
  `instance/governance/policies/host-tool-resolution.yml`
- shared provisioning command:
  `framework/capabilities/runtime/commands/provision-host-tools.md`
- actual host installs and control truth:
  `$OCTON_HOME/{tools/**,state/control/host-tools/**}`
- retained host provisioning evidence:
  `$OCTON_HOME/state/evidence/provisioning/host-tools/**`
- generated per-repo host-tool resolution views:
  `$OCTON_HOME/generated/effective/host-tools/repos/**`

`/init` may report missing host-tool prerequisites, but it must never install
them implicitly.

Mission-scoped reversible autonomy uses one authored/control/evidence/read-model
split:

- durable mission authority:
  `instance/orchestration/missions/<mission-id>/{mission.yml,mission.md}`
- run-contract control roots:
  `/.octon/state/control/execution/runs/<run-id>/run-contract.yml`
- stage-attempt roots:
  `/.octon/state/control/execution/runs/<run-id>/stage-attempts/**`
- runtime lifecycle control roots:
  `/.octon/state/control/execution/runs/<run-id>/{run-manifest.yml,runtime-state.yml,rollback-posture.yml,checkpoints/**}`
- repo-owned mission autonomy defaults:
  `instance/governance/policies/mission-autonomy.yml`
- repo-owned non-path ownership authority:
  `instance/governance/ownership/registry.yml`
- repo-owned support-target declarations:
  `instance/governance/support-targets.yml`
- normalized approval control roots:
  `state/control/execution/approvals/**`
- normalized exception and revocation control roots:
  `state/control/execution/{exceptions,revocations}/**`
- mutable mission control truth:
  `state/control/execution/missions/<mission-id>/**`
- retained control-plane evidence:
  `state/evidence/control/execution/**`
- retained run receipts and replay pointers:
  `state/evidence/runs/<run-id>/{receipts/**,checkpoints/**,replay-pointers.yml,trace-pointers.yml,evidence-classification.yml}`
- retained proof-plane, measurement, intervention, and disclosure evidence:
  `state/evidence/runs/<run-id>/{assurance/**,measurements/**,interventions/**,disclosure/**}`
- retained lab evidence:
  `/.octon/state/evidence/lab`
  `state/evidence/lab/`
  retained subfamilies:
  `state/evidence/lab/**`
- mission continuity:
  `state/continuity/repo/missions/<mission-id>/**`
- freshness-bounded effective mission routing:
  `generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`
- derived mission/operator read models:
  `generated/cognition/summaries/{missions,operators}/**`
- generated machine mission view:
  `generated/cognition/projections/materialized/missions/<mission-id>/mission-view.yml`

Mission creation remains authority-only under `instance/orchestration/missions/**`.
Autonomous active or paused runtime state becomes legal only after the
seed-before-active path materializes mission control truth, continuity, route
generation, summaries, and mission view outputs under their canonical roots.
Mission remains the continuity container while the run root is the primary
execution-time unit of truth for consequential runs.
Approvals, exceptions, revocations, and retained decision artifacts resolve
only from canonical control roots rather than host-shaped affordances.

Raw additive packs carry compatibility and provenance in
`inputs/additive/extensions/<pack-id>/pack.yml`.
Repo trust decisions stay in `instance/extensions.yml`.

Proposal authority uses one manifest-governed exploratory model:

- active proposal inputs:
  `inputs/exploratory/proposals/<kind>/<proposal_id>/**`
- archived proposal inputs:
  `inputs/exploratory/proposals/.archive/<kind>/<proposal_id>/**`
- generated proposal discovery: `generated/proposals/registry.yml`
- lifecycle authority:
  `proposal.yml` > subtype manifest
- proposal-local reading order:
  `navigation/source-of-truth-map.md` > subtype working docs >
  `navigation/artifact-catalog.md` > `generated/proposals/registry.yml` >
  `README.md`
- proposal registry behavior:
  `generated/proposals/registry.yml` is a deterministically rebuilt discovery
  projection and never lifecycle authority; legacy-unknown archived design
  imports stay outside the main projection until normalized

For Mission-Scoped Reversible Autonomy specifically:

- runtime closeout remains recorded in
  `instance/cognition/decisions/067-mission-scoped-reversible-autonomy-final-closeout-cutover.md`
- proposal-lineage closeout remains recorded in
  `instance/cognition/decisions/068-mission-scoped-reversible-autonomy-provenance-alignment-closeout.md`
  and
  `instance/cognition/context/shared/migrations/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/plan.md`
- proposal packets under `inputs/exploratory/proposals/**` are historical
  lineage and never runtime authority

Generated-family rules in v1:

- runtime-facing publication lives only under `generated/effective/**`
- derived cognition outputs live only under `generated/cognition/**`
- retained validation and assurance evidence lives under `state/evidence/**`
- machine-readable publication receipts live under
  `state/evidence/validation/publication/**`
- `generated/artifacts/**`, `generated/assurance/**`, and
  `generated/effective/assurance/**` are not canonical Packet 10 families

No descendant-local or scope-local proposal workspace exists in v1.

Overlay-capable repo authority is limited to these declared enabled points:

| Overlay point | Instance path | Merge mode | Precedence |
| --- | --- | --- | ---: |
| `instance-governance-policies` | `instance/governance/policies/**` | `replace_by_path` | 10 |
| `instance-governance-contracts` | `instance/governance/contracts/**` | `replace_by_path` | 20 |
| `instance-execution-roles-runtime` | `instance/execution-roles/runtime/**` | `merge_by_id` | 30 |
| `instance-assurance-runtime` | `instance/assurance/runtime/**` | `append_only` | 40 |

No other `instance/**` subtree is overlay-capable in v1.

## Naming Convention

Use plain directory names for structural units (domains, subsystems, components). Use underscore-prefixed namespaces for non-structural support material:

- `_meta/` — docs-as-code governance and architecture reference modules.
- `_ops/` — portable operational support such as scripts and helper assets.
- `_scaffold/` — templates and scaffolding material.

Canonical SSOT for `runtime/` vs `_ops/` semantics:
`cognition/_meta/architecture/runtime-vs-ops-contract.md`.

Within these namespaces, common subpaths are:

- `_meta/architecture/`
- `_meta/docs/`
- `_meta/evidence/`
- `_ops/scripts/`
- `state/**`
- `_scaffold/template/`

## Canonical Agent-Led Path

Use this as the only recommended onboarding path for agent execution.

Run this first when onboarding or resuming local repo work:

- `/bootstrap-doctor`
- canonical workflow contract:
  `/.octon/framework/orchestration/runtime/workflows/tasks/bootstrap-doctor/workflow.yml`
- human-readable guide:
  `/.octon/framework/orchestration/runtime/workflows/tasks/bootstrap-doctor/README.md`

Canonical execution-role entrypoints:

- `/.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`
- `/.octon/framework/execution-roles/runtime/specialists/registry.yml`
- `/.octon/framework/execution-roles/runtime/verifiers/registry.yml`

Flow:

1. Bootstrap
   - If root `AGENTS.md`, `/.octon/AGENTS.md`, or `/.octon/instance/charter/workspace.md` is missing, run `/init` (or
     `.octon/framework/scaffolding/runtime/_ops/scripts/init-project.sh`) first.
   - Read `/AGENTS.md` as the repo-root adapter to `/.octon/AGENTS.md`, then
     continue into `/.octon/instance/ingress/AGENTS.md`.
   - Read `/.octon/instance/charter/workspace.md`, `scope.md`,
     `conventions.md`, `cognition/_meta/architecture/specification.md`, and
     `cognition/governance/principles/README.md`.
   - Run `/bootstrap-doctor` before the first material task workflow so ingress,
     workflow discovery, support-target posture, and evidence roots are checked
     under one canonical preflight surface.
2. Execute
   - Read `state/continuity/repo/log.md` and `state/continuity/repo/tasks.json`.
   - Treat material execution as grant-bearing by default: services, workflow
     stages, executor launches, repo mutation, and protected CI control work
     must hold a valid execution grant and emit execution receipts.
   - If work is stably owned by one declared scope, also read
     `state/continuity/scopes/<scope-id>/{log.md,tasks.json,next.md}`.
   - Execute the highest-priority unblocked task.
3. Assure
   - Run `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`.
   - Run additional surface-specific validators for changed domains.
4. Continuity
   - Update `state/continuity/repo/log.md` and `state/continuity/repo/tasks.json`.
   - Update `state/continuity/scopes/<scope-id>/**` when the work's primary
     home is a declared scope rather than repo-wide continuity.
   - Complete `assurance/practices/session-exit.md` and verify
     `assurance/practices/complete.md`.

Legacy onboarding variants are hard-deprecated for new sessions.

## Runtime Quick Start

From repo root:

```bash
.octon/framework/engine/runtime/run --help
.octon/framework/engine/runtime/run studio
```

Use `studio` when you want a visual workflow graph, a read-only orchestration
operations workspace, and the safe staged edit/apply flow.

## Assistants

Assistants are focused specialists available via `@mention`:

- `@reviewer` / `@rev` — Code review
- `@refactor` / `@ref` — Code restructuring
- `@docs` / `@doc` — Documentation

See `agency/manifest.yml` for actor discovery and `catalog.md` for invocation details.

## Visibility & Autonomy Rules

Two directories are **human-led**. Agents MUST NOT access them autonomously.

| Directory              | Purpose                          | Autonomy           |
|------------------------|----------------------------------|--------------------|
| `ideation/projects/`   | Human-led explorations           | **Human-led only** |
| `ideation/scratchpad/` | Ephemeral content and idea funnel | **Human-led only** |

**Scratchpad subdirectories (`ideation/scratchpad/`):** `inbox/` (staging), `archive/` (deprecated), `brainstorm/` (exploration), `ideas/`, `drafts/`, `daily/`.

### Human-Led Collaboration

Agents MAY access `ideation/projects/` or `ideation/scratchpad/` ONLY when:

1. Human explicitly points to specific file(s)
2. Human requests a concrete change
3. Agent work stays scoped to referenced files

**During autonomous operation:** Treat these paths as if they do not exist.

---

## The Funnel

Ideas flow from ephemeral scratchpad to committed work:

```
ideation/scratchpad/ideas/      → Quick captures (most die here)
        ↓
ideation/scratchpad/brainstorm/ → Structured exploration (filter stage)
        ↓
ideation/projects/              → Committed research (produces artifacts)
        ↓
instance/orchestration/missions/        → Committed execution
        ↓
instance/cognition/context/shared/      → Permanent knowledge
```

---

## Where Things Go

| Content | Destination | Lifecycle |
|---------|-------------|-----------|
| External imports, raw drops | `ideation/scratchpad/inbox/` | Temporary → triage → move out |
| Quick ideas | `ideation/scratchpad/ideas/` | May graduate or die |
| Ideas worth exploring | `ideation/scratchpad/brainstorm/` | Graduate to projects or kill |
| Committed research | `ideation/projects/<slug>/` | Until findings published |
| Deprecated content | `ideation/scratchpad/archive/` | Permanent reference |
| Durable architecture decisions | `instance/cognition/decisions/` | Permanent |
| ADR discovery index | `instance/cognition/decisions/index.yml` | Permanent |
| Constraints, non-negotiables | `instance/cognition/context/shared/constraints.md` | Permanent |
| Next actions | `state/continuity/repo/next.md` | Active |
| Harness terminology | `instance/cognition/context/shared/glossary.md` | Reference |
| Repo-wide terminology | `instance/cognition/context/shared/glossary-repo.md` | Reference |
| Lessons learned | `instance/cognition/context/shared/lessons.md` | Reference |

**Publishing findings:** Project findings flow directly to `instance/cognition/context/shared/` files without a separate promotion step.

---

## When Stuck

- Check `state/continuity/repo/tasks.json` for blocked items and their blockers
- Check `instance/cognition/context/shared/lessons.md` for anti-patterns to avoid
- Check `instance/cognition/decisions/index.yml` and the linked ADRs for
  relevant past decisions
- Review `scaffolding/practices/prompts/` for relevant task templates
- If truly blocked, document the blocker in `state/continuity/repo/log.md` and stop
