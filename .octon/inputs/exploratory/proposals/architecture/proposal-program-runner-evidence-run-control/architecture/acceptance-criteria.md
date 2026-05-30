# Acceptance Criteria

- Raw executor logs, machine paths, cleanup transcripts, and private debug details remain local-only evidence when retained.
- Publishable claim evidence under `.octon/state/evidence/runs/**` contains concise redacted receipts, digests, limitations, and proof sufficient for hosted closeout, archive, replay, or audit claims.
- Cancellation prevents dispatch after observation; resume reconstructs from canonical run evidence, checkpoints, and live proposal state; unsafe divergence fails closed.
- Every acquired program or child lock is released or recorded as stale/unsafe on executor error, timeout, cancellation, panic, event append failure, checkpoint write failure, or max-step exhaustion.

## Negative Criteria

- Do not raw-copy local evidence into publishable retained evidence.
- Do not let generated read models satisfy route receipts, closeout evidence, or archive authorization.
- Do not proceed on unsafe resume, checkpoint/event divergence, stale lock ambiguity, or invalid evidence-tier publication.

## Terminal Criteria

- Child implementation evidence exists only after a later
  `run-packet-implementation` route.
- Child promotion is workflow-owned by `promote-proposal` and cannot be claimed
  by parent program evidence.
- Child closeout and archive remain child-owned and route-gated.
