# Target Architecture

## Target Name

**Octon Compatibility Conformance + Portable Proof Interop v6**

## Target Problem

Before Octon can safely federate trust, it must distinguish between a non-Octon external evidence source, an Octon-compatible emitter, an Octon-mediated connector, an Octon-enabled repo, and an Octon federation peer.

The current repository provides strong internal authority/evidence discipline, but does not yet expose a first-class v6 compatibility profile, adoption conformance suite, portable proof bundle, attestation envelope, or proof import/export acceptance runtime.

## Target End State

Octon gains a v6 MVP layer that can inspect an external project or system, assign an Octon Compatibility Profile, define safe adoption posture for external repos, reject blind `.octon/` state copying, verify Portable Proof Bundles, verify and classify Attestation Envelopes, retain imported proof as evidence only, mark proof/attestations accepted/rejected/stale/revoked/decision-gated, and expose a local trust-domain hook.

## Participation Tiers

| Tier | Meaning | Authority posture |
|---|---|---|
| `external_evidence_source` | Non-Octon source such as CI, SaaS, audit PDF, deployment log | Evidence only |
| `octon_compatible_emitter` | Emits Octon-shaped proof/attestations | Evidence after local verification |
| `octon_mediated_connector` | Used through governed connector path | Connector admission governs use |
| `octon_enabled_repo` | Has valid `.octon/` super-root and local authority/control/evidence roots | Eligible for deeper trust review |
| `octon_federation_peer` | Octon-enabled repo plus compact/trust-domain admission | Eligible for full federation workflows |

## MVP Scope

In MVP: Octon Compatibility Profile, External Project Compatibility Inspection, External Project Adoption Posture, Compatibility Conformance Suite, Portable Proof Bundle, Attestation Envelope, Proof Acceptance Record, Attestation Acceptance Record, Trust Domain Hook, Proof Import/Export Posture, Revocation/Expiry Hooks.

Structural hook only: Trust Registry, Federation Compact, Delegated Authority Lease, Cross-Domain Decision Request, Certification Profile, Federation Ledger.

Deferred: full federation compact lifecycle, delegated authority enforcement, cross-domain write authority, certification runtime, multi-org trust.
