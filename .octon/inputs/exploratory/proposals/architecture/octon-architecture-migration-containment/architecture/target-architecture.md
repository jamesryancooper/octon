# Target Architecture

## Target State: SI-00 Contained Baseline

RP-00 ends in exactly one safe resting state:

```text
clean exact repository baseline + bound provider observation
  -> no candidate-head privileged provider writer
  -> no Octon-owned human or agent direct-main route
  -> protected PR is Octon's only privileged bridge
  -> every physical writer, launcher, credential, policy input, trust root,
     and provider workflow is registered and assigned one accountable role
  -> support and proof claims equal direct retained evidence
  -> current state/workflow/operator burden is measured
```

This state is containment, not the target runtime. Later packets may be
designed in parallel, but no later packet may perform a privileged change until
the RP-00 exit proof passes.

## Planned Source Ownership

- RP-00 owns the physical inventory and claim-correction transition.
- Human governance remains the owner of support declarations; accepted ROD-006
  removes every Octon-owned human or agent direct-main route. Ordinary human Git
  remains outside Octon.
- `authority_engine` remains the sole normal decision issuer; RP-00 does not
  add another evaluator or authority path.
- Protected PR is a temporary safe bridge, not a new control plane.
- `.github/**` remains a non-authoritative host projection.
- Retained evidence records facts; it never authorizes a route or widens a
  support claim.

## Invariants

1. No candidate-controlled workflow or checkout may perform a privileged
   provider write during the contained state.
2. No Octon-owned human or agent route may select or publish directly to
   `main`; ordinary human Git remains outside Octon.
3. Missing or unregistered writers, launchers, credentials, decision inputs,
   trust roots, and provider workflows fail closed.
4. A referenced test is never classified as dynamically executed merely
   because a containing validator passed.
5. Support claims cite admitted tuples and direct retained proof at the correct
   evidence classification.
6. Disabling an unsafe route preserves candidate work and the protected-PR
   recovery lane.
7. Containment does not create a broker, store, verifier, credential proxy,
   workflow controller, or second authority plane.
8. No count-based cleanup occurs without separate ownership and deletion proof.

## Component Behavior When Unavailable

- If inventory generation or validation is unavailable, privileged
  implementation remains blocked; the prior inventory is not assumed fresh.
- If provider observation is unavailable, its freshness is recorded as stale
  and no provider-dependent claim or privileged route is enabled.
- If support proof cannot be resolved, the affected claim is demoted or
  removed from live disclosure.
- If an unsafe projection cannot be safely disabled, the packet stops before
  privileged work; no ambient fallback is permitted.

## Prohibited Intermediate and Final States

- dual authority or dual writer acceptance;
- any Octon-owned human or agent direct-main route;
- candidate-head provider write or verifier code;
- ambient credentials in a candidate execution context;
- linked-worktree-only isolation claimed as sufficient;
- PR escalation used to launder forged, stale, revoked, or wrong-scope
  authority;
- generated, GitHub, proposal, reconciliation, or evidence surfaces treated as
  authority;
- complete, live, executed, or signed claims without direct retained proof;
- privileged implementation before SI-00 exit.

## Unsupported Remainder

After RP-00 exits, Octon still does not have the RP-01 candidate-immutable
authority package, RP-02 credentialless isolation, RP-03 SQLite store, RP-04
broker, RP-05 sanitized Git, RP-06 immutable verifier/publication, RP-07 signed
bounded evidence, RP-08 recovery/Class B vertical, RP-09 trust activation, or
RP-10 through RP-14 product and optional capability proof. SI-00 must not be
presented as autonomous-publication or support-completion evidence.
