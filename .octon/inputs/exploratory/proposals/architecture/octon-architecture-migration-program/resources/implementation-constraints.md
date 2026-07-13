# Frontier-Model Implementation Constraints

- Treat proposals/reconciliation as non-authoritative; re-read current durable
  authority and exact accepted child receipts before each implementation.
- Change only the accepted child's exact owned modules/entries; shared files use
  the serialized integration lane and preserve other packet ownership.
- Never infer acceptance, operator disposition, provider fact, dynamic proof, or
  support claim from planning prose.
- Freeze and digest dependency interfaces; material drift stops/replans rather
  than silently broadening scope.
- Keep candidates credentialless and canonical authority immutable; all effects
  cross the broker and every verdict stays separate from publication.
- Preserve one store/writer and honest T1/external/T2/UNKNOWN semantics.
- Fail closed on missing/revoked/stale/ambiguous authority, evidence, provider,
  capacity, selector, or dependency state while preserving useful work.
- Prefer provider-native primitives only when their exact current behavior is
  observed, bounded, and replaceable; no live secondary claim without live proof.
- No `.github/**` octon-internal target, direct generated-authority edit, raw
  evidence in project Git, or same-change self-certification.
- Optimize for zero routine prompts, one-screen status, automatic recovery, and
  the measured Solo Local budgets; complexity without a proved risk/value owner
  is removed.
