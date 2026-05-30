# Source Context

_Status: Proposal-local source summary_

This child packet derives from the parent Evidence Disclosure Tier Contract
Program and the operator-supplied best-fit design. The design preserves Octon's
existing retained-evidence model while separating private raw evidence,
publishable claim evidence, operator/release disclosure, and generated read
models.

## Child Focus

Add validator gates for tier metadata, local-only path safety, publishable receipt concision, and hosted closeout independence from local-only evidence.

## Parent Program Linkage

- parent program: `evidence-disclosure-tier-contract-program`
- phase: `phase-4`
- group: `validation`
- dependencies: evidence-disclosure-tier-contracts, local-evidence-store-boundary, publishable-evidence-receipts, disclosure-and-read-model-alignment

## Required Review Phrases

- tracked local evidence
- oversized publishable evidence
- hosted closeout

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
