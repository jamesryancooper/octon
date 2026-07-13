# Program Closeout Plan

Program closeout starts only after every required child reaches a valid terminal
outcome through its own lifecycle and the exact child receipts remain current.
Core RP-14 proof may close claim-scoped after RP-08/RP-09/RP-10/RP-11, but the
program cannot close while RP-12 or RP-13 remains nonterminal.

The parent verifies registry/DAG integrity, exact child terminal references,
promotion freshness, aggregate safe-state/claim truth, Revision 2 lineage,
generated registry freshness, no residual proposal backreferences, and clean
Change/branch/worktree handoff. It records only an aggregate read model; it does
not create, validate, authorize, or replace child terminal receipts.

Any failed optional capability is demoted/disabled and recorded honestly. Any
failed required child blocks full program closeout or requires a governed child
rejection/supersession and parent revision. Archive occurs only after all
post-implementation conformance/drift and authoritative promotion receipts pass.
