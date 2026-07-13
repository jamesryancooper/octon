# Program Lifecycle Plan

This plan coordinates proposal lifecycles; it does not authorize or execute the
migration.

1. Review RP-00 first; consume accepted ROD-006 (no Octon-owned direct-main
   route) and validate inventories before any privileged implementation.
2. After RP-00 verification, review RP-01 and RP-02 independently/in parallel.
   Freeze RP-01 semantics before RP-03 persistence work.
3. Review/implement RP-03 and RP-10 on separate ownership lanes; then RP-04 and
   RP-11 after their exact dependencies.
4. Advance the safety spine RP-04 → RP-05 → RP-06 → RP-07 → RP-08, maintaining
   one broker, one writer, separate verifier, signed evidence, and lower safe
   state after every gate.
5. Advance RP-09 after SI-06; advance RP-12 after RP-07/RP-11 and RP-13 after
   RP-08/RP-11 on distinct child-owned lifecycles.
6. Run RP-14 core proof only after RP-08/RP-09/RP-10/RP-11 freeze. Evaluate
   optional claims only after RP-12/RP-13. Route failed proof back to the owner.
7. Promote only exact passing child outputs through authoritative routes, run
   child conformance/drift/closeout, aggregate without substitution, and close
   the program only after all fifteen terminal outcomes are valid.
