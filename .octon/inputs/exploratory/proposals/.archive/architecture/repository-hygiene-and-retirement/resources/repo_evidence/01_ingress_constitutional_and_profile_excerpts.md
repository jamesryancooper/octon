# Repo Evidence 01 — Ingress, Constitutional, and Profile Excerpts

This file captures the live ingress and constitutional anchors that directly
govern this packet.

## Ingress and read-order excerpts

**Source:** `AGENTS.md`

- Repo-root `AGENTS.md` is an ingress adapter.
- Canonical internal ingress lives at `/.octon/instance/ingress/AGENTS.md`.
- Repo-root ingress adapters must not add runtime or policy text.

**Source:** `/.octon/instance/ingress/AGENTS.md`

- The mandatory read set includes:
  - `/.octon/framework/constitution/CHARTER.md`
  - `/.octon/framework/constitution/charter.yml`
  - `/.octon/framework/constitution/obligations/fail-closed.yml`
  - `/.octon/framework/constitution/obligations/evidence.yml`
  - `/.octon/framework/constitution/precedence/normative.yml`
  - `/.octon/framework/constitution/precedence/epistemic.yml`
  - `/.octon/framework/constitution/ownership/roles.yml`
  - `/.octon/framework/constitution/contracts/registry.yml`
  - `/.octon/instance/charter/workspace.md`
  - `/.octon/instance/charter/workspace.yml`
  - `/.octon/framework/agency/runtime/agents/orchestrator/AGENT.md`
- For this repository, `pre-1.0` defaults to `atomic` unless a hard gate
  requires `transitional`.
- Only `framework/**` and `instance/**` are authored authority.
- Raw `inputs/**` must never become direct runtime or policy dependencies.

## Constitutional excerpts

**Source:** `/.octon/framework/constitution/CHARTER.md`

- The charter is the supreme repo-local constitutional regime for `/.octon/**`.
- Subordinate prompts, shims, adapters, specs, workflows, and summaries may
  project this charter but may not redefine it.
- Retained surfaces must be governed, validator-covered, proof-backed,
  disclosure-backed, and non-liminal.
- Any surface that cannot meet those conditions must be removed from the live
  claim rather than surviving as unsupported architectural debt.
- Every compensating mechanism must carry an owner, removal review, and
  retirement trigger.

**Source:** `/.octon/framework/constitution/charter.yml`

- Charter version: `1.3.0-full-attainment-cutover`
- Purpose: consequential autonomous work stays scoped, fail-closed,
  evidence-backed, reviewable, and fully unified across the admitted live
  support universe.

## Fail-closed and evidence excerpts

**Source:** `/.octon/framework/constitution/obligations/fail-closed.yml`

- Default route: `DENY`
- Relevant rules include:
  - direct raw-input runtime/policy dependency => `DENY`
  - treating generated artifacts as source of truth or second control plane => `DENY`
  - ambiguous or unresolved ownership => `ESCALATE`
  - missing approval evidence for material side effect => `STAGE_ONLY`
  - a compensating mechanism lacking owner or retirement trigger => `DENY`

**Source:** `/.octon/framework/constitution/obligations/evidence.yml`

- Retained evidence roots include:
  - `.octon/state/evidence/runs/**`
  - `.octon/state/evidence/lab/**`
  - `.octon/state/evidence/control/execution/**`
  - `.octon/state/evidence/validation/publication/**`
- Profile-governed work must record `change_profile`, `release_state`,
  profile-selection facts, rationale, and transitional-exception note when
  required.

## Precedence and ownership excerpts

**Source:** `/.octon/framework/constitution/precedence/normative.yml`

- Constitutional kernel outranks repo governance declarations.
- Repo-governance declarations include
  `.octon/instance/governance/policies/**` and
  `.octon/instance/governance/contracts/**`.

**Source:** `/.octon/framework/constitution/precedence/epistemic.yml`

- Validated runtime evidence and receipts outrank prose when asserting current
  facts.
- The present repository state outranks stale summaries.
- Conversation is advisory unless materialized into authority or evidence.

**Source:** `/.octon/framework/constitution/ownership/roles.yml`

- Ambiguity policy: `ESCALATE_OR_DENY`
- Human governance approves policy changes, support-target changes, and one-way
  door approvals.
- Model execution must not widen support tiers or authorize irreversible
  actions.
