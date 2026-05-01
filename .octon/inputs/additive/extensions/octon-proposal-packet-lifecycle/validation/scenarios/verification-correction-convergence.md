# Verification Correction Convergence

## Target Kind

`run-verification-and-correction-loop`

## Expected Behavior

The route repeats verification and correction until `clean`, `blocked`,
`needs-packet-revision`, `superseded`, or explicitly deferred. Closure-grade
packets must honor no-new-finding and two-consecutive-clean-pass requirements
when declared by the packet or source material.
