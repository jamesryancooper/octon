# Program Lifecycle Plan

This plan coordinates proposal lifecycles; it does not authorize or execute the
migration.

1. Review RP-00 first; consume accepted ROD-006, disable candidate-head
   privileged writers, Octon `direct-main`, destructive unlanded cleanup, and
   current autonomous no-PR effects. Eligible no-PR work remains classified,
   blocked, and preserved. The current PR workflow is not presumed safe.
2. After RP-00 verification, review RP-01 and RP-02 independently/in parallel.
   Freeze RP-01 semantics before RP-03 persistence work.
3. Review/implement RP-03 and RP-10 on separate ownership lanes; then RP-04 and
   RP-11 after their exact dependencies.
4. Advance RP-04 → RP-05 → RP-06 → RP-07 → RP-08. RP-01 first proves the complete
   typed publication grant, RP-03 freezes the tuple at T1, and RP-04 validates
   that committed tuple without gaining route or verdict authority. RP-05 owns
   closed ref primitives, RP-06 policy/verdict/PR/history/mirror semantics,
   RP-07 signed evidence, and RP-08 result classification/recovery/cleanup.
   Production no-PR stays disabled until all four production packets exit.
5. Advance RP-09 after SI-06; advance RP-12 after RP-07/RP-11 and RP-13 after
   RP-08/RP-11 on distinct child-owned lifecycles.
6. Run RP-14 core proof only after RP-08/RP-09/RP-10/RP-11 freeze. Evaluate
   optional claims only after RP-12/RP-13. Route failed proof back to the owner.
7. Promote only exact passing child outputs through authoritative routes, run
   child conformance/drift/closeout, aggregate without substitution, and close
   the program only after all fifteen terminal outcomes are valid.

If exact CAS, conditional ref operations, PR tuple binding, or recovery cannot
fit these existing boundaries without a generic Git surface or second control
plane, stop with the precise infeasibility for operator disposition. Do not add
a child or weaken the boundary silently.
