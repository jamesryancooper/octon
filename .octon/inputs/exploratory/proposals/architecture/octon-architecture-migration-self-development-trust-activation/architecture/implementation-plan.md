# Implementation Plan

1. Verify the frozen RP-01/RP-06/RP-07/RP-08 digests and interfaces from the
   exact design receipt; census the semantic
   trust closure, indirect build/provider paths, selector, and rollback state.
2. Implement the selected RFC-8785/SHA-256 trust inventory, classifier receipt, inert install,
   activation envelope, selector, health, and rollback contracts.
3. Implement content-addressed side-by-side installation without activation and
   an installed-version classifier/verifier that candidates cannot select.
4. Implement the two-slot monotonic selector journal, selected 600-second health
   profile, 30-second prior-version restore,
   monotonic epoch, and crash/reboot/disk-full recovery receipts.
5. Before any activation claim, run direct/indirect/rename/build/provider closure and candidate-widening
   adversarial suites plus every activation kill point; resolve UE-001/009/015.
6. Implement the accepted ROD-003 small content-addressed epoch-zero inventory,
   one-time human trust anchor/bootstrap, and exact scope/artifact-version/time/
   budget/verifier/health/rollback preauthorization. Resolve encoding,
   detection, health-window, canary, and rollback-duration mechanics through
   reversible design and proof; prove SI-07, rehearse rollback, and cut over
   atomically. Safe automatic activation remains disabled and unclaimed until
   separately proved and later promoted.
