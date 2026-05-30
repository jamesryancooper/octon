# Source Context

_Status: Proposal-local source summary_

This child packet derives from the parent Evidence Disclosure Tier Contract
Program and the operator-supplied best-fit design. The design preserves Octon's
existing retained-evidence model while separating private raw evidence,
publishable claim evidence, operator/release disclosure, and generated read
models.

## Child Focus

Establish the local-only raw evidence store under `.octon/state/evidence/local/**` with an Octon-scoped ignore rule and clear non-publishable authority posture.

## Parent Program Linkage

- parent program: `evidence-disclosure-tier-contract-program`
- phase: `phase-2`
- group: `local-store`
- dependencies: evidence-disclosure-tier-contracts

## Required Review Phrases

- .octon/state/evidence/local
- .gitignore
- local-only

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
