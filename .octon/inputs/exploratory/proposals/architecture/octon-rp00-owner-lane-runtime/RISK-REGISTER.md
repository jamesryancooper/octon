# Risk Register

| ID | Risk | Control | Residual disposition |
|---|---|---|---|
| R-01 | Credential leaks through argv, environment, logs, disk, or ambient helpers | FD-only capture, environment scrubbing, stdin-only curl config/body, FIFO askpass, redaction tests, zeroization | block on any secret-census hit |
| R-02 | Duplicate provider mutation after timeout | append-only pre-send journal, request digest, terminal outcome class, no-resend recovery | unknown outcome requires authoritative read and separate reconciliation authority |
| R-03 | Manifest becomes arbitrary HTTP execution | closed operation enum, fixed GitHub origin, path-template validation, method/body constraints, exact digest and review/run/candidate binding | unsupported operation denies before credential read |
| R-04 | Token scope or principal differs from sealed tuple | pre-effect `/user` and repository capability probes; exact login/id/repository/API-version checks | mismatch terminalizes without mutation |
| R-05 | New runtime path bypasses existing authority | new typed authorized-effect kind, inventory/coverage rows, consumption receipt, negative token tests | no fallback or stage-only live execution |
| R-06 | Existing protected-CI support claim is borrowed for broader operations | update admission, dossier, and proof bundle only after a retained full hermetic runtime run and negative controls; name the exact owner-lane operation | no general API-client or connector claim |
| R-07 | Lifecycle controller cannot consume required human authorization | provider-authority blocker maps to an approval blocker with exact route/run/candidate scope | missing or stale grant remains blocked |
| R-08 | Existing RP-00 candidate is silently changed | implement on isolated clean branch; regenerate RP-00 candidate after precursor landing | frozen candidate remains evidence, not the final landing candidate |
| R-09 | External tool substitution bypasses the Rust boundary | bind canonical executable paths and SHA-256 digests before credential capture; reverify before launch; ignore ambient PATH | any drift blocks the run |
