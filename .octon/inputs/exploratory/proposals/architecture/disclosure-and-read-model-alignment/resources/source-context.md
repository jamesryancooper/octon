# Source Context

_Status: Proposal-local source summary_

This child packet derives from the parent Evidence Disclosure Tier Contract
Program and the operator-supplied best-fit design. The design preserves Octon's
existing retained-evidence model while separating private raw evidence,
publishable claim evidence, operator/release disclosure, and generated read
models.

## Child Focus

Align RunCard/release disclosure and generated read models to the evidence tier contract while preserving generated non-authority.

## Parent Program Linkage

- parent program: `evidence-disclosure-tier-contract-program`
- phase: `phase-3`
- group: `disclosure`
- dependencies: evidence-disclosure-tier-contracts, publishable-evidence-receipts

## Required Review Phrases

- .octon/state/evidence/disclosure
- .octon/generated
- non-authority

## Best-Fit Decisions Bound Here

- Published evidence must prove the claim without dumping raw transcripts.
- Raw evidence is private by default and belongs under the local evidence tier.
- Promotion from local raw evidence to publishable evidence requires
  transformation through summary, redaction, limitations, and receipt metadata.
- Generated read models may summarize but never satisfy evidence gates.
- Filesystem paths must communicate whether content is local-only,
  publishable, disclosure, or generated.

This source context is proposal-local input only. It is not runtime, policy,
evidence, closeout, or implementation authority.
