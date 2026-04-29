# Architecture Proposal: Octon Compatibility Conformance + Portable Proof Interop v6

## Executive Decision

This packet selects **Octon Compatibility Conformance + Portable Proof Interop** as the single highest-leverage v6 implementation step.

The full v6 architecture eventually includes trust domains, trust registries, federation compacts, delegated authority leases, cross-domain Decision Requests, certification profiles, federation ledgers, and multi-peer federation. Those all depend on a narrower prerequisite:

> Octon must first be able to classify external participants, safely adopt Octon into external projects, and verify portable proof/attestation artifacts as evidence without importing authority.

## Why This Is Highest Leverage

The live repository already has a strong super-root model, portability profile hints, run lifecycle, support-target proof posture, evidence obligations, and proposal standards. What is missing is a formal compatibility and proof interop layer that determines whether another project/system can safely participate in v6 at all.

Without this layer, non-Octon systems may be mistaken for federation peers, external proof may be over-trusted, attestations may be confused with approvals, and a copied `.octon/` tree may import stale or foreign authority.

## Scope

In scope: Octon Compatibility Profile, external project compatibility inspection, safe adoption design, compatibility conformance suite, Portable Proof Bundle, Attestation Envelope, proof import/export posture, attestation verify/accept/reject posture, local acceptance posture, revocation/expiry hooks, and trust-domain hooks.

Out of scope: full federation compact lifecycle, delegated authority enforcement, cross-domain write authority, production deployment federation, multi-organization mesh federation, marketplace trust, external AI quorum, automatic support widening.
