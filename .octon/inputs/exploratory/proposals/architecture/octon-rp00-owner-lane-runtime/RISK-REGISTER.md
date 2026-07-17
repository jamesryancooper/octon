# Risk Register

| ID | Risk | Control | Residual disposition |
|---|---|---|---|
| R-01 | Credential leaks through argv, environment, logs, disk, or ambient helpers | FD-only capture, environment scrubbing, stdin curl config, FIFO askpass, zeroization, leak census | block on any secret-census hit |
| R-02 | Duplicate provider mutation after timeout | append-and-fsync pre-send journal, request digest, no-resend recovery | unknown outcome requires authoritative reconciliation |
| R-03 | Operation plan becomes arbitrary HTTP execution | closed operation enum, fixed origins and request shapes, strict typed bindings, canonical template digest | unsupported plan denies before credential read |
| R-04 | Post-event receipt is asserted before observation | staged runtime writes issuance, lifecycle, admission, manifest, prefix, construction, and retirement artifacts only after their inputs exist | phase mismatch or preexisting conflicting artifact blocks |
| R-05 | Token scope or lifetime differs from sealed intent | complete preauthorization tuple plus trusted capture metadata and live admission probes | mismatch terminalizes without repository mutation |
| R-06 | Provider-assigned PR number is predicted or substituted | PR-create response plus one authoritative reconcile read, completed-prefix receipt, typed binding normalization | zero, multiple, mismatched, or unknown PR state blocks without resend |
| R-07 | New runtime path bypasses authority | typed provider-repository mutation effect, inventory/coverage rows, consumption receipt, bypass tests | no fallback or stage-only live execution |
| R-08 | Existing support proof is borrowed for broader operations | refresh the existing exact-operation proof only after retained full hermetic staged execution | no general API-client or connector claim |
| R-09 | External tool substitution bypasses the Rust boundary | canonical path and digest binding before capture and before launch | any drift blocks the run |
| R-10 | Crash occurs after token capture but before lifecycle envelope | deterministic same-credential recovery under the one-attempt and replacement locks; no request is eligible before envelope durability | inability to re-present the exact token becomes credential-unresolved |
