# Octon Policy Interface (v1)

> **Normative:** This file defines the engine-owned v1 launch interface for
> policy evaluation and validation.

## Purpose

Provide a stable contract boundary for policy execution so `capabilities/`
depends on engine interfaces, not engine implementation internals.

## Launcher Endpoints

- POSIX: `/.octon/framework/engine/runtime/policy`
- Windows: `/.octon/framework/engine/runtime/policy.cmd`

These launchers are the canonical invocation boundary for policy operations.

## Engine Contract

- Interface owner: `engine/runtime/**`
- Runtime implementation owner: `engine/runtime/crates/policy_engine/**`
- Caller contract: invoke launchers only; do not couple to crate paths or
  build paths.
- Launcher behavior defaults are runtime-configured in:
  - `engine/runtime/config/policy-interface.yml`
- Repo-owned network egress authorization is declared in:
  - `/.octon/instance/governance/policies/network-egress.yml`
- Repo-owned execution budget governance is declared in:
  - `/.octon/instance/governance/policies/execution-budgets.yml`
- Repo-owned mission autonomy defaults are declared in:
  - `/.octon/instance/governance/policies/mission-autonomy.yml`
- Repo-owned non-path ownership authority is declared in:
  - `/.octon/instance/governance/ownership/registry.yml`
- Repo-owned support-target declarations are declared in:
  - `/.octon/instance/governance/support-targets.yml`
- Repo-owned workspace objective narrative is declared in:
  - `/.octon/instance/charter/workspace.md`
- Repo-owned workspace objective machine contract is declared in:
  - `/.octon/instance/charter/workspace.yml`
- Historical workspace objective shims, when retained for lineage or bootstrap
  compatibility, remain outside the live runtime path.
- Canonical authority contracts are published under:
  - `/.octon/framework/constitution/contracts/authority/`
- Canonical runtime contracts are published under:
  - `/.octon/framework/constitution/contracts/runtime/`
- Canonical assurance contracts are published under:
  - `/.octon/framework/constitution/contracts/assurance/`
- Canonical disclosure contracts are published under:
  - `/.octon/framework/constitution/contracts/disclosure/`
- Canonical adapter contracts are published under:
  - `/.octon/framework/constitution/contracts/adapters/`
- Runtime host adapter manifests are published under:
  - `/.octon/framework/engine/runtime/adapters/host/`
- Runtime model adapter manifests are published under:
  - `/.octon/framework/engine/runtime/adapters/model/`
- Framework capability-pack contracts are published under:
  - `/.octon/framework/capabilities/packs/`
- Repo-local capability-pack admission is published under:
  - `/.octon/instance/capabilities/runtime/packs/`
- Canonical run-contract control roots are published under:
  - `/.octon/state/control/execution/runs/`
- Canonical run lifecycle control files are published under:
  - `/.octon/state/control/execution/runs/<run_id>/{run-manifest.yml,runtime-state.yml,rollback-posture.yml,checkpoints/**}`
- Canonical lab-authored scenario and replay contracts are published under:
  - `/.octon/framework/lab/`
- Canonical observability-authored measurement and intervention contracts are published under:
  - `/.octon/framework/observability/`
- Canonical approval control roots are published under:
  - `/.octon/state/control/execution/approvals/requests`
  - `/.octon/state/control/execution/approvals/grants`
- Canonical exception and revocation control roots are published under:
  - `/.octon/state/control/execution/exceptions/leases.yml`
  - `/.octon/state/control/execution/revocations/grants.yml`
- Generated mission summaries are published under:
  - `/.octon/generated/cognition/summaries/missions/`
- Generated operator digests are published under:
  - `/.octon/generated/cognition/summaries/operators/`
- Generated machine-readable mission views are published under:
  - `/.octon/generated/cognition/projections/materialized/missions/`

## Supported Command Surface (v1)

The launcher forwards to `octon-policy` and supports these command groups:

- `preflight`
- `enforce`
- `acp-preflight`
- `acp-enforce`
- `receipt-validate`
- `grant-eval`
- `doctor`

Wrapper extension for `acp-enforce`:

- `--emit-receipt`
- `--run-id <id>` (requires `--request`)
- `--digest` (requires `--emit-receipt`)

## Intent Binding Contract (v1 Extension)

Autonomous policy evaluation requests MUST provide an intent binding:

- `intent_ref.id`
- `intent_ref.version`

Canonical contract path:

- `engine/runtime/spec/intent-contract-v1.schema.json`

Fail-closed behavior:

- Missing `intent_ref`: deny with reason code `INTENT_MISSING`
- Invalid/unknown `intent_ref`: deny with reason code `INTENT_REF_INVALID`
- Autonomous run for non-`agent-ready` classification: deny with reason code
  `MODE_VIOLATION_AUTONOMY_NOT_ALLOWED`

Autonomous execution requests that operate under Mission-Scoped Reversible
Autonomy MUST also provide `autonomy_context` with:

- `mission_ref`
- `slice_ref`
- `intent_ref`
- `mission_class`
- `oversight_mode`
- `execution_posture`
- `reversibility_class`
- `boundary_id`

Missing mission autonomy context is a fail-closed denial for autonomous runs.

Phase 2 objective rule:

- instance/charter workspace pair is the active workspace-charter layer
- bootstrap/cognition workspace shims are non-runtime lineage only
- mission remains the continuity container for mission-class work
- run contracts define the canonical atomic execution unit under
  `state/control/execution/runs/**`

Wave 3 lifecycle rule:

- consequential stages must bind the canonical run control and evidence roots
  before approval materialization, policy receipts, or other consequential
  side effects occur
- mission summaries and mission views may consume run evidence, but they may
  not replace the bound run root as the execution-time unit of truth

Phase 3 normalization rule:

- `run-manifest.yml` is the canonical bound run-manifest model
- `runtime-state.yml` carries mutable execution status only
- `state/evidence/runs/<run_id>/evidence-classification.yml` must encode the
  packet Class A/B/C evidence model
- supported boundary-sensitive runs must retain external immutable replay
  payloads through a content-addressed index under
  `state/evidence/external-index/**`

For material ACP runs (`phase=promote|finalize` or explicit material side-effect
flags), the wrapper executes a single mandatory path:

- ensure `instruction_layers` is present on the request (inject defaults when
  absent),
- emit an instruction-layer manifest artifact under
  `state/evidence/runs/<run_id>/instruction-layer-manifest.json`,
- fail closed if manifest emission cannot be completed.

## Receipt And Digest Contracts

ACP receipt/digest artifacts emitted by wrapper-assisted `acp-enforce`
evaluations must follow:

- Receipt schema: `engine/runtime/spec/policy-receipt-v2.schema.json`
- Digest format: `engine/runtime/spec/policy-digest-v2.md`
- Instruction-layer manifest schema:
  `engine/runtime/spec/instruction-layer-manifest-v1.schema.json`

Decision outputs for `ALLOW`, `STAGE_ONLY`, and `DENY` must include:

- machine-readable `reason_codes`
- human-readable `remediation` guidance
- budget metadata when execution-budget policy participates in the decision
- ownership and support-tier routing posture when authority routing
  participates in the decision
- egress posture and normalized approval/exception/revocation refs when those
  families participate in the decision

Material execution that requests outbound HTTP or model-backed execution MUST
also satisfy:

- destination-scoped repo-owned network egress policy for `net.http`
- repo-owned execution budget policy for billable or model-backed paths
- repo-owned ownership and support-target declarations for consequential work
- repo-owned host/model adapter declarations and adapter-conformance criteria
  from `/.octon/instance/governance/support-targets.yml`
- repo-owned capability-pack admission under
  `/.octon/instance/capabilities/runtime/packs/registry.yml`
- retained run evidence under `state/evidence/runs/<run_id>/**` for any
  resulting egress or cost artifacts
- canonical run receipts under `state/evidence/runs/<run_id>/receipts/**`
- canonical run assurance, measurement, intervention, and disclosure families
  under
  `state/evidence/runs/<run_id>/{assurance/**,measurements/**,interventions/**,disclosure/**}`
- canonical replay and trace pointers under
  `state/evidence/runs/<run_id>/{replay-pointers.yml,trace-pointers.yml}`
- canonical run evidence classification under
  `state/evidence/runs/<run_id>/evidence-classification.yml`
- retained lab evidence under `state/evidence/lab/**` for any system-level
  behavioral or support claims
- retained lab evidence root:
  `/.octon/state/evidence/lab`
  `state/evidence/lab`

Host labels, comments, checks, and similar affordances remain
non-authoritative projections. Policy evaluation consumes only the normalized
authority artifacts instead of the host surface directly.

Adapter metadata keys for runtime requests are:

- `support_host_adapter`
- `support_model_adapter`
- `support_model_tier`
- `support_language_resource_tier`
- `support_locale_tier`

Capability-pack admission is evaluated from inferred execution surfaces plus
any explicit metadata override:

- shell execution implies the `shell` pack
- repo-local read/write scope implies the `repo` pack
- branch mutation or publication implies the `git` pack
- retained evidence emission implies the `telemetry` pack
- outbound HTTP implies the `api` pack
- browser-driving metadata implies the `browser` pack

Unadmitted or unsupported packs fail closed.

## Instruction-Layer Manifest Contract

For material policy evaluations, runtime wrappers MUST emit an instruction-layer
manifest that conforms to
`engine/runtime/spec/instruction-layer-manifest-v1.schema.json`.

Minimum required per-layer fields are:

- `layer_id`
- `source`
- `sha256`
- `bytes`
- `visibility`

Material runs MUST NOT use a compatibility path that omits manifest emission.
If layer metadata is missing and cannot be deterministically assembled, wrapper
execution MUST return contract error (`2`) before policy evaluation.

## Exit Codes

- `0` - allow/success
- `13` - deny by policy decision
- `2` - contract/runtime invocation error

## Environment

- `OCTON_POLICY_BIN`: optional explicit binary path override.
- `OCTON_POLICY_MODE_OVERRIDE`: optional runtime mode override exported by
  launcher when rollout-mode state is present.

## Versioning

- Incompatible interface changes require a new versioned spec file
  (`policy-interface-vN.md`) and corresponding launcher/runtime updates.
- Existing v1 semantics are immutable once released.
