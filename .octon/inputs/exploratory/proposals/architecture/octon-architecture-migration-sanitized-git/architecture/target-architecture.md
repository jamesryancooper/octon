# Target Architecture

## Decision

Place one closed Git adapter inside the supervised RP-04 broker. The adapter
may perform exactly one preauthorized, pinned, fast-forward ref transition. It
does not evaluate candidate repository configuration, does not hold authority
to choose a route, and does not verify its own result as the final publication
verdict.

## Smallest Sufficient Component

The adapter consists of four packet-owned contracts:

1. A broker Git request/result contract binding operation, attempt, repository
   identity, source object, target ref, expected-old object, proposed-new
   object, authorization references, and policy version.
2. A candidate-object transfer contract that imports only the required object
   closure into broker-owned minimal Git state without checkout or execution.
3. A closed Git policy that fixes commands, arguments, environment,
   configuration, transports, repository identity, and allowed output.
4. An effect implementation that proves ancestry and asks the provider to
   enforce the exact expected-old target atomically before a fast-forward-only
   update.

This is not a generic Git service. It is a narrow adapter hosted by the single
broker and backed by the single RP-03 operation/attempt state machine.

## End-To-End Flow

1. RP-04 authenticates the caller and validates a one-shot operation handle.
2. RP-03 state proves the operation is authorized and ready for an attempt.
3. RP-05 receives an immutable Git request with pinned repository and ref
   identities.
4. The adapter creates or reuses broker-owned minimal Git state that is not the
   candidate repository and has no candidate checkout.
5. The adapter imports the exact candidate object closure through a
   non-executing format.
6. The adapter verifies object identity and independently proves the proposed
   object is a descendant of the expected-old object.
7. The provider operation binds the expected-old object at the server and
   permits only the exact fast-forward transition.
8. The adapter records direct observations and any authenticated provider
   receipt without claiming that observed state proves which actor caused it.
9. RP-08 later classifies the outcome and reconciles unknown attempts before
   any retry.
10. RP-06 separately verifies the exact candidate and owns the publication
    route and final verdict.

## Closed Git Surface

The broker identity denies or neutralizes all candidate-controlled execution
and substitution surfaces, including hooks, config includes, aliases,
credential helpers, filters, clean/smudge processes, textconv, external
diff/merge drivers, fsmonitor, submodule commands, alternates, protocol and
transport helpers, SSH command injection, signing programs, editors, pagers,
attributes, and repository-local configuration. The positive exact
fast-forward path must still work.

The implementation must use an explicit minimal environment and explicit
configuration. Candidate-provided HOME, XDG paths, Git config, attributes,
repository metadata, hook paths, helper binaries, transport commands, and
ambient credentials are never inherited.

## Identity And Authority

- RP-01 remains the authority decision source.
- RP-03 remains the operation/attempt state source.
- RP-04 remains the sole broker, credential custodian, and writer.
- RP-05 owns only the Git adapter contract and implementation.
- RP-06 owns the candidate-immutable verdict and route predicate.
- RP-08 owns provider-specific outcome classification and retry/reconciliation.

The adapter has no grant-signing key, policy authority, verifier identity, or
support-admission authority. Provider credentials are operation-scoped and
supplied through the broker boundary; they are never returned to a candidate.

## Invariants

- Exactly one broker hosts the adapter.
- The candidate repository and broker Git state are physically independent.
- No candidate checkout occurs under broker identity.
- Imported objects cannot execute code or load candidate configuration.
- Repository, remote, target ref, expected-old, and proposed-new identities are
  exact and immutable for one attempt.
- An update requires both independent ancestry proof and server-observed
  expected-old equality.
- Force update and non-fast-forward behavior are unreachable.
- Observation distinguishes target state from causal attempt attribution.
- GitHub is not a canonical ledger or authority source.
- Protected PR remains available when the adapter is disabled or the route is
  not eligible.

## Unavailability

If the adapter, provider, broker credential, network, or expected-old
precondition is unavailable, the effect does not run or retry blindly.
Candidate work remains intact. The normal safe route is a protected PR after
the owning route policy confirms it is valid; invalid authority denies and
requires fresh authorization rather than PR escalation.

## Unsupported Remainder

After RP-05 alone, production autonomous publication remains unsupported.
Generic Git access, force updates, candidate checkout under broker identity,
provider verdicts, support widening, universal causal attribution, and trust
activation remain outside this packet. RP-06, RP-07, and RP-08 must close
before the complete Class B vertical can be claimed.
