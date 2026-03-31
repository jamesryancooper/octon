# De-Hosting Authority Closeout

## Problem statement

The GitHub host adapter already says GitHub is a non-authoritative projection
surface. Closure still requires the practical workflow paths to behave that way.

The critical remaining risk is not descriptive inconsistency. It is that a
workflow-local decision about high-impact changes, lane posture, or merge
eligibility can still behave like hidden authority.

## Closeout decision

All consequential lane/blocker/manual-lane decisions for the certified envelope
must be emitted as **canonical authority artifacts**.

GitHub and CI may:

- call canonical classifiers or materializers
- project labels, comments, checks, and summaries
- gate merges based on the result of canonical validators

GitHub and CI may **not**:

- mint authority by label or workflow-local state alone
- substitute workflow-local classification for retained authority artifacts
- become the system of record for control-plane decisions

## Required architectural move

Introduce canonical `.octon/**` logic that classifies consequential PR posture
and materializes a retained decision artifact. Repo-local workflows then consume
that output as a projection.

## Minimum closeout surface

- canonical classifier/materializer under `.octon/framework/assurance/governance/**`
- retained authority-decision artifact under `.octon/state/evidence/control/execution/**`
- optional repo-local workflow binding under `.github/workflows/**` that invokes
  the canonical logic but does not replace it

## Proof requirement

Closure is satisfied only if a static and behavioral audit can show all of the
following:

1. the decisive classification lives in canonical `.octon/**` logic
2. the decision is retained as a canonical artifact
3. GitHub labels/comments/checks are projections of that artifact
4. removing the GitHub projection layer does not remove the canonical decision

## Why this is still needed even with a bounded claim

The release claim is correctly bounded to the repo-shell certified envelope, so
GitHub is outside the fully realized claim surface. Even so, hidden host
authority is still a claim-quality risk because it weakens the integrity of the
overall execution constitution. Closure therefore treats de-hosting as a claim
blocker, not just a hardening follow-up.
