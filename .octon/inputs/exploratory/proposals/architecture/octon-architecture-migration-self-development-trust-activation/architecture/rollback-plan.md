# Rollback Plan

Before selector switch, discard/quarantine the inert candidate and keep the
current version. After switch, a failed health gate or interrupted receipt
restores the pre-registered exact prior certified version and monotonic
epoch/high-water state. Preserve both content-addressed versions and evidence.

Never roll back to an unverified/revoked version, a candidate-defined selector,
or a mixed install. If the prior version cannot be proved, disable activation
and require recovery while the inert artifact remains non-authoritative.
