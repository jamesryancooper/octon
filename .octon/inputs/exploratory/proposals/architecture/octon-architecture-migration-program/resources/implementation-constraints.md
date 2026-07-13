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
- Freeze history shape and route before verification/effect. Bind repository,
  source identity/ref, `O`, `S`, grant, policy, `V`, operation, attempt, target,
  consequence, expiry, revocation, and evidence into one exact tuple.
- Require a true server-observed expected-old fast-forward CAS. Force,
  non-fast-forward, bypass, check-then-push substitution, ambient Git behavior,
  and generic Git service surfaces are unreachable.
- Preserve one store/writer and honest T1/external/T2/UNKNOWN semantics.
- Fail closed on missing/revoked/stale/ambiguous authority, evidence, provider,
  capacity, selector, or dependency state while preserving useful work.
- Never switch an invalid, collided, `ATTEMPTING`, or `UNKNOWN` attempt to PR.
  PR is a fresh pre-effect policy selection for valid review-required work only.
- Synchronize canonical local `main` only after landed proof as a fast-forward
  mirror. Cleanup requires route-specific landed proof and an expected-tip
  conditional operation; otherwise retain `landed/cleanup-deferred` and `S`.
- Prefer provider-native primitives only when their exact current behavior is
  observed, bounded, and replaceable; no live secondary claim without live proof.
- No `.github/**` octon-internal target, direct generated-authority edit, raw
  evidence in project Git, or same-change self-certification.
- Optimize for zero routine prompts, one-screen status, automatic recovery, and
  the measured Solo Local budgets; complexity without a proved risk/value owner
  is removed.
