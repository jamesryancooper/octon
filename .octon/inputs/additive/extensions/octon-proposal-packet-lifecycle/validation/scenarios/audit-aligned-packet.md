# Audit-Aligned Packet

## Target Kind

`create-proposal-packet`

## Expected Behavior

The route preserves the full audit under `resources/**`, maps each finding to
remediation, acceptance criteria, validation, and closure proof, and keeps the
audit non-authoritative. The packet must define the closure threshold,
including zero unresolved source findings unless a finding is explicitly
rejected, superseded, or deferred with owner and rationale.
