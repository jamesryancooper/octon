# Run Verification And Correction Loop

Run the packet-specific verification prompt, emit stable findings, generate
targeted correction prompts for unresolved findings, apply corrections only
inside packet scope, and repeat verification. Stop only at a declared terminal
state and retain each pass as evidence.

The loop must continue through verification, correction, local validation, and
re-verification until the packet reaches `clean`, `blocked`,
`needs-packet-revision`, `superseded`, or `explicitly-deferred`. When closure
certification requires consecutive clean passes, run and retain both passes
unless a failing pass produces a new stable finding. Do not hide unresolved
findings as deferrals, do not broaden correction scope beyond the packet, and
do not claim completion from a generated prompt or support artifact alone.
