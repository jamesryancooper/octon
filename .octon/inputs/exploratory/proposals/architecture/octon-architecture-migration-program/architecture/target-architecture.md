# Target Architecture

The parent is a lightweight gated-parallel coordinator over fifteen sibling
proposals. It supplies discovery, the exact acyclic dependency graph, safe-state
ordering, cross-packet source ownership, shared-integration serialization,
aggregate risk/evidence views, operator reading order, correction routing,
promotion handoff, and closeout accounting. It is not a scheduler, authority
issuer, runtime store, broker, verifier, evidence producer, or implementation
work unit.

The target product architecture keeps one candidate-immutable authority issuer,
one transactional writer, one supervised credential/effect broker, a separate
immutable verifier, signed bounded evidence, honest reconciliation, prior-version
trust activation, non-authoritative Workspace Projects, one deterministic
Harness Factory, a private signed extension path, bounded depth-one children,
and independent proof-only Solo Local dogfood. Provider-native primitives are
used where they reduce custom machinery without weakening proof.

The migration rests only in SI-00 through SI-08. Each child can advance only
after dependency verification and its own acceptance/proof. Core Solo Local
claims may close claim-scoped after RP-08/RP-09/RP-10/RP-11; extension and child
claims remain disabled until RP-12/RP-13; full program closeout waits all fifteen.

No direct-main agent, credentialed candidate, second issuer/writer/broker/control
plane, VM fleet, enterprise identity layer, public marketplace, persistent agent
organization, universal exactly-once claim, same-change self-certification, or
proposal-as-authority is introduced.
