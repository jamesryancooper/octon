# Implementation Plan

1. Use domain child outputs to identify concrete validator hooks.
2. Add positive checks for required proof, scope, authority-zone, replay, and
   receipt gates.
3. Add negative controls for approval defaults, stale evidence, scope mismatch,
   generated authority, child takeover, unsafe resume, policy override,
   governance mutation, and external irreversible effects.
4. Retain validator run evidence and conformance receipts.
