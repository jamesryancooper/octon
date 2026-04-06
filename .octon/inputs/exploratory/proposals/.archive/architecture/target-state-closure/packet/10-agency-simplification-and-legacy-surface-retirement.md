# 10. Agency Simplification and Legacy Surface Retirement

## 1. Goal

Keep the orchestrator-centered accountable agency model while removing residual persona-heavy execution surfaces from the active path.

## 2. Preserve

Preserve as load-bearing:
- `.octon/framework/agency/manifest.yml`
- `default_agent: orchestrator`
- mission ownership and routing policy
- memory discipline
- no arbitrary skill-actor delegation
- optional verifier profile where it provides real proof value

## 3. Current problem

Legacy agency surfaces still exist:
- `.octon/framework/agency/runtime/agents/architect/AGENT.md`
- `.octon/framework/agency/runtime/agents/architect/SOUL.md`
- historical precedence chains that still mention AGENTS → CONSTITUTION → DELEGATION → MEMORY → AGENT → SOUL

These are no longer the intended active kernel path.

## 4. Target model

### Active kernel roles
- `orchestrator`
- `verifier` (optional but real)
- any additional runtime roles only if they provide:
  - separation of duties
  - context isolation
  - concurrency
  - proof value

### Non-kernel overlays
- persona
- voice
- inspirational style
- roleplay-heavy identity
- `SOUL`-style materials

These may remain only as:
- overlays
- legacy shims
- archival references

They may not be loaded by default in active consequential execution.

## 5. Path plan

### Preserve
- `.octon/framework/agency/manifest.yml`
- `.octon/framework/agency/runtime/agents/orchestrator/**`

### Demote
- `.octon/framework/agency/runtime/agents/architect/**`
  - target state: `framework/agency/runtime/legacy/architect/**`
  - or delete after deprecation window

### Remove from active ingress
- references from `.octon/instance/ingress/AGENTS.md` to legacy architect or SOUL surfaces

### Optional retained shim
- a read-only historical note or redirect file explaining replacement by orchestrator

## 6. Validation

Create:
- `validate-no-legacy-active-path.sh`

Validator checks:
- no active ingress references legacy architect/SOUL surfaces
- no runtime manifests or run bundles declare architect as default kernel role
- no closure certification job depends on architect/SOUL materials
- any retained legacy path is marked `historical-shim` or `overlay-only`

## 7. Temporary shims allowed

During compatibility window only:
- historical redirects
- docs that explain the rename
- projections for users/tooling that still expect architect naming

These must carry:
- explicit deprecation date
- retirement trigger
- owner

## 8. Retirement trigger

Delete or archive legacy architect / SOUL surfaces when:
- no active manifest, ingress, workflow, or runtime code references them
- ablation test shows no regression in proof planes
- active release bundle passes `validate-no-legacy-active-path.sh` twice consecutively

## 9. Acceptance criteria

- orchestrator is the only default kernel execution identity
- verifier remains only where it provides real proof value
- no active consequential execution path depends on architect or SOUL
- retained legacy surfaces are overlays or historical shims only
