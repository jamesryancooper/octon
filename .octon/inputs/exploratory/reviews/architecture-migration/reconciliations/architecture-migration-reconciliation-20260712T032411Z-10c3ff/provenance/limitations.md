# Limitations

- Architect B's original reviewer was unavailable. Its cross-review is an explicitly labelled independent third-party substitute, not original-author reconsideration. This is the primary process variance.
- Both reviews use the same clean commit, avoiding repository evolution as a disagreement source. Ignored caches/local state were not exhaustively fingerprinted.
- Immutable integrity indexes validate intentional indexed artifacts. Unindexed `.DS_Store` metadata and the index files themselves are outside those checks and were not used as evidence.
- Provider observations are read-only and point-in-time. The reconciliation did not refresh live configuration; every provider-dependent implementation or promotion claim requires a timestamped refresh.
- Source-boundary compliance is supported by allowlists, manifests, reviewer declarations, inspected-path reports, and artifact scans. It is not a complete operating-system read audit.
- Review B's status summary counts conflict with its per-FD records, and some finding references use shorthand prefixes. Reconciliation uses per-decision details plus cross-review corrections.
- Static call-path evidence establishes many current gaps but does not prove exploit frequency, complete mediation, crash behavior, sandbox escape, or provider behavior. Those claims remain explicitly dynamic/adversarial proof obligations.
- The original sequential runtime tests did not reproduce the inferred concurrency/crash failures. Dynamic labels are retained only for behavior actually executed.
- Exact provider-session, IPC, CAS/attempt attribution, verifier deployment, project-schema, Harness/provider-breadth, and workflow-surface mechanisms have bounded engineering defaults and escalate only if proof fails. Retention/recovery, autonomy risk, epoch-zero trust, extension signers, child budgets, and final support posture remain the six packet-local operator judgments.
- No primary external technical documentation was necessary to resolve the reconciled architecture; provider-specific mechanisms remain unselected and therefore unverified.
- This package is research-only and cannot promote either review, the target architecture, support claims, or implementation.
