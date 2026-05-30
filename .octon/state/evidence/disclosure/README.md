# Disclosure Evidence

`state/evidence/disclosure/**` stores canonical retained disclosure artifacts.

- `runs/**` retains RunCards for consequential runs
- `releases/**` retains HarnessCards for release, support, and benchmark claims

These disclosure roots are canonical for supported live paths. Historical
mirrors may remain elsewhere only when they are explicitly non-live.

RunCards, HarnessCards, release summaries, and closure summaries may cite
repo-publishable evidence receipts when they summarize private or local-only
evidence. Raw local evidence is not published into these disclosure roots by
copy; it remains behind digest-backed local refs, external-index refs, or
explicit limitations recorded in the publishable receipt.

Generated read models under `generated/**` may summarize these disclosure
artifacts for operator inspection, but they remain derived-only and cannot
satisfy evidence, support-proof, closeout, archive, policy, or authority gates.
