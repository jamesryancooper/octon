# Acceptance Criteria

- AC-01: One versioned candidate-immutable evaluator/policy/bin/config/receipt
  tuple is installed outside candidate control and its full identity is checked
  at every decision and launch.
- AC-02: A static spawn census and dynamic negative suite prove every candidate
  process reaches the exact final guard; no direct or legacy launch bypass
  remains. The check rejects a raw candidate spawn in any file or symbol not
  assigned in `resources/candidate-launch-census.yml` and rejects an assigned
  spawn that lacks the same-path consuming guard invocation.
- AC-03: Typed path, Git-ref, URI, repository, actor, capability, expiry,
  revocation, epoch, candidate, and Harness scope tests deny every widening,
  substitution, boundary-confusion, and stale-input case.
- AC-04: N-way concurrent consumption and crash tests prove one-shot at-most-once
  launch admission without log-only success.
- AC-05: RP-01 publishes a frozen semantic interface and handoff digest that
  RP-03 consumes without reinterpretation; concurrent semantic/persistence
  mutation is prohibited.
- AC-06: SI-01 is demonstrated with only non-privileged candidate launches;
  broker, credentials, Git publication, trust activation, and child budgets
  remain disabled and unclaimed.
- AC-07: The accepted ROD-003 epoch-zero and preauthorization boundary is bound,
  the complete design may authorize an exact implementation candidate, and
  UE-001/UE-002 are then resolved against that exact commit before conformance,
  implementation completion, or promotion.
- AC-08: Rollback disables launch and restores only a previously certified
  authority package; no candidate-tree or loose-file authority fallback exists.
- AC-09: Publication grants structurally bind issuer, repository, source
  identity/ref, `S`, target ref, `O`, route-policy digest, operation,
  expiry/revocation/epoch, and consequence scope without giving RP-01 route
  policy or provider-effect ownership.
