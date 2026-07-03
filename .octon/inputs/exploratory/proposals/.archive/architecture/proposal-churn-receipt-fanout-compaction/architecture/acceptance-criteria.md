# Acceptance Criteria

- Equivalent repeated validations do not create unbounded timestamped receipt fanout.
- Receipt equivalence is defined by producer identity, input/source digests, validator or publisher version, result, output digest, retained proof digest, and evidence obligation, not by timestamp alone.
- Full retained proof remains retrievable and digest-verified.
- Publication and validation obligations remain enforceable.
- Missing full proof, stale pointer, or digest drift fails validation.
- No retained evidence is deleted without owning cleanup authority.
