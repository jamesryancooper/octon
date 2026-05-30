# Implementation Plan

_Status: In-review parent-program implementation plan_

This plan coordinates child implementation state and dependency gates. It does
not implement durable runtime, policy, evidence, or validator targets by
itself. Parent orchestration authorization is resolved only by a fresh strict
parent review gate and live child-readiness validation.

## Step 1: Establish Parent Program

- Create `proposal.yml` and `architecture-proposal.yml`.
- Create the child registry and human index.
- Create packet sequence, child contract, and closeout plan.
- Create risk, validation, source-context, and creation-receipt surfaces.

## Step 2: Apply Resolved Design Decisions

- Use `.octon/state/evidence/.gitignore` for local evidence ignore behavior.
- Require publishable receipts for hosted/shared closeout and any claim that
  leaves the local machine.
- Warn above 64 KiB and fail above 256 KiB for one publishable receipt unless
  a schema-declared exception applies.
- Require local evidence references to use relative paths or logical ids plus
  digests, never absolute machine paths.
- Require manual redaction declarations with validator-assisted checks.

## Step 3: Coordinate Child Packets

Preserve `evidence-disclosure-tier-contracts` as child-owned `implemented`
state with its own implementation, conformance, and post-implementation
drift/churn receipts. Use each remaining accepted sibling child packet's
`support/executable-implementation-prompt.md` only after a fresh accepted
parent review and required gates authorize orchestration. Do not nest child
packet directories under the parent and do not let parent evidence satisfy
child implementation receipts.

## Step 4: Gate Required Children

Enforce the sequence in `architecture/packet-sequence.md`. Do not allow
closeout/repo-hygiene behavior or residue migration work to proceed until
contracts, storage boundaries, receipt schemas, disclosure/read-model posture,
and validators have child-owned review evidence.

## Step 5: Close Out Parent

Close out this parent only after aggregate evidence proves child terminal
outcomes, child receipt freshness, authority separation, hosted/local evidence
boundary preservation, and no unsupported live claims.
