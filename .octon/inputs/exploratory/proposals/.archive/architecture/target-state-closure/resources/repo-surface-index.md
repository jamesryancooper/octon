# Repo Surface Index

This index lists the primary repository surfaces that informed the packet. It is not an exhaustive line audit of every crate and script, but it is the grounded surface set used for the design.

## Root / class-root surfaces
- `.octon/README.md`
- `.octon/octon.yml`
- `.octon/instance/manifest.yml`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `.octon/framework/overlay-points/registry.yml`

## Constitutional and governance surfaces
- `.octon/framework/constitution/**`
- `.octon/instance/governance/policies/**`
- `.octon/instance/governance/disclosure/**`
- `.octon/instance/governance/closure/**`
- `.octon/instance/governance/support-targets.yml`
- `.octon/instance/governance/contracts/**`
- `.octon/instance/governance/ownership/**`

## Objective / mission / ingress surfaces
- `.octon/instance/charter/**`
- `.octon/instance/bootstrap/**`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/instance/orchestration/missions/**`
- `.octon/instance/cognition/context/shared/intent.contract.yml`

## Agency surfaces
- `.octon/framework/agency/manifest.yml`
- `.octon/framework/agency/runtime/agents/orchestrator/**`
- `.octon/framework/agency/runtime/agents/architect/**`
- `.octon/framework/agency/governance/**`

## Runtime / adapter / capability surfaces
- `.octon/framework/engine/runtime/README.md`
- `.octon/framework/engine/runtime/config/policy-interface.yml`
- `.octon/framework/engine/runtime/spec/**`
- `.octon/framework/engine/runtime/crates/**`
- `.octon/framework/engine/runtime/adapters/host/**`
- `.octon/framework/engine/runtime/adapters/model/**`
- `.octon/framework/capabilities/**`

## State / evidence / continuity surfaces
- `.octon/state/control/execution/**`
- `.octon/state/continuity/**`
- `.octon/state/evidence/**`
- `.octon/state/evidence/disclosure/**`

## Lab / observability surfaces
- `.octon/framework/lab/**`
- `.octon/framework/observability/**`

## CI / enforcement surfaces
- `.github/workflows/architecture-conformance.yml`
- `.github/workflows/deny-by-default-gates.yml`
- `.github/workflows/pr-autonomy-policy.yml`
- `.github/workflows/ai-review-gate.yml`

## Design consequence of incomplete inspection

Some internal crate logic, helper scripts, and all pack implementations were not line-audited in full. Where the packet prescribes changes inside those subsystems, it treats visible manifests, schemas, evidence artifacts, and workflow boundaries as the authoritative external seam.
