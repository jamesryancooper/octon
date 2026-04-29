# Implementation Plan

## Workstream 1 — Contracts

Add compatibility, adoption, proof bundle, attestation, proof acceptance, and trust hook schemas/contracts.

## Workstream 2 — Instance policy

Add deny-by-default trust policies for proof bundle acceptance, attestation acceptance, external project adoption, and local trust registry posture.

## Workstream 3 — Control/evidence roots

Materialize control state for compatibility status, imported proof, attestation status, revocation status, and ledger summaries. Retain evidence for compatibility scans, adoption scans, proof verification, attestation verification, and redaction/freshness checks.

## Workstream 4 — Runtime/CLI

Add inspection-first commands for compatibility and adoption, plus proof/attestation import/export/verify commands. All commands fail closed if lower-level v1-v5 surfaces needed for live behavior are absent.

## Workstream 5 — Validation

Add schema validators, placement validators, proof digest/freshness/redaction validators, attestation scope/freshness/revocation validators, imported-proof no-authority negative controls, and no-blind-copy adoption tests.

## Workstream 6 — Documentation

Document participation tiers, safe adoption, proof import/export, attestation acceptance, non-authority boundaries, and deferred federation scope.
