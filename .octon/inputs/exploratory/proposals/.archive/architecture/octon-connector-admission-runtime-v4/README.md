# Connector Admission Runtime and Trust Dossier v4

This proposal packet defines the selected highest-leverage next v4 step toward **Federated Stewardship and Capability Runtime v4**.

## Selected v4 step

**Connector Admission Runtime + Connector Trust Dossier + Support-Target Expansion Proof Hooks**

The packet deliberately does **not** implement the whole v4 architecture. It selects connector admission because every broader v4 promise — cross-repo work, release envelopes, portfolio coordination, production-adjacent operations, campaign rollups with external evidence, and broader MCP/API/browser capability use — depends on a trustworthy way to admit external operations without bypassing Octon's authority, support-target, policy, authorization, evidence, and rollback model.

## Why this step

The live repository already has:
- capability packs for `repo`, `git`, `shell`, `telemetry`, `browser`, and `api`;
- a bounded-admitted-finite support-target model where `browser` and `api` are present but non-live/stage-only style surfaces;
- engine-owned execution authorization for material execution;
- material side-effect classes including service invocation, protected CI, generated-effective publication, extension activation, and capability-pack activation;
- generated/effective handle discipline and support matrix rules that forbid generated widening.

What is missing is a first-class, operation-level admission path for **external connectors**.

## Packet status

This proposal has been implemented into durable repository surfaces. The packet
remains non-authoritative exploratory lineage under
`inputs/exploratory/proposals/**`; promoted authority now lives under
`framework/**`, `instance/**`, and `state/**`, with generated connector views
remaining derived read models only. See `resources/implementation-report.md`.

## Reading order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/target-architecture.md`
5. `architecture/current-state-gap-map.md`
6. `architecture/implementation-plan.md`
7. `architecture/validation-plan.md`
8. `architecture/acceptance-criteria.md`
9. `resources/v4-architecture-evaluation.md`
10. `support/executable-implementation-prompt.md`
