# Proposal-Program Readiness

## Decision

READY_FOR_PROPOSAL_PROGRAM

## Why

- The repository baseline and live provider posture were bound at one exact
  commit.
- All 24 operator decisions were independently cross-walked.
- Material current-state blockers have exact evidence, minimum repairs, and
  acceptance tests.
- The migration reuses existing primitives and has explicit retirements,
  compatibility bridges, forbidden intermediate states, rollback, and proof.
- Fourteen packets have owners, dependencies, entry/exit criteria, rollback,
  and proof.
- Remaining operator choices are bounded to packet design and do not alter the
  program's dependency spine.
- No source or provider mutation is needed to create the program.

## Conditions on program creation

The program must:

1. preserve this review as non-authoritative evidence;
2. make WG-00 the first implementation packet;
3. prohibit privileged implementation until GATE-0 passes;
4. keep current auto-merge/direct-main paths disabled or non-autonomous;
5. prohibit dual authority, dual writers, candidate credentials, unsanitized
   Git, and candidate verifier code in every intermediate state;
6. make proof artifacts direct-observer, digest-bound, and honest;
7. retain manual/protected PR as the only pre-proof publication bridge;
8. require operator decisions before their owning packets exit design;
9. use canonical proposal/ADR promotion rather than treating this review as
   architecture authority.

## Not yet ready

- privileged broker/provider implementation;
- autonomous Class B landing;
- production support claims;
- trust-root automation;
- optional remote effect worker.

Each is gated in phase-3/implementation-readiness-gates.yml.

