# Safe Intermediate States (and prohibited ones)

> Non-authoritative. Which partial states the migration may pass through without
> creating a window where an autonomous agent can perform an unauthorized durable
> effect, and which states must never exist.

## Guiding invariant

At **every** intermediate state, the following must hold:
1. No autonomous agent has a *new* unauthorized durable-effect path that did not
   exist at HEAD (the migration may not regress safety), and
2. Any newly-added authority component is *deny-by-default* until its verification
   is wired, and
3. There is never more than one live authority *issuer* or one live *broker*.

## PERMITTED intermediate states

| # | Intermediate state | Why it is safe | Guards |
|---|---|---|---|
| S1 | Canonical launch guard added while `DelegationProof` fields still exist but no longer authorize | Two records, one authority: the grant is required; the proof is evidence-only | Test: spawn denied without grant even if DelegationProof present |
| S2 | `env_clear` + sandbox applied to the **lifecycle** path before the **pipeline** path (B-03) | Reduces exposure monotonically; the un-migrated path is no worse than HEAD | Track both paths; PP-02 exit requires both wrapped |
| S3 | SQLite is the **sole writer** for grants/tokens while legacy YAML remains **read-only projection** | One writer; legacy files derived, not authoritative | Validator: no code writes legacy files as authority |
| S4 | Broker supports **one** Git effect (push/land) while unsupported durable effects are **denied** | Deny-by-default: absence of support = denial, not passthrough | Test: unsupported effect from candidate fails closed |
| S5 | Out-of-tree exact-SHA verifier protects branch-no-PR while **PR remains fallback** | Escalation path is always at least as strict | Route escalates to PR when verifier unavailable |
| S6 | Trust-root candidate can **land inert** before activation automation exists | Inert = no effect; manual operator activation is the safe default | Resolver reads staged trust-root only via activation record |
| S7 | Reconciliation added for the one supported external effect (push) before all effects | Each covered effect is exactly-once; uncovered effects still route via HEAD path | Attempt lifecycle keyed per effect class |
| S8 | Claims reworded (PP-00) before signing implemented | Honest wording never overstates; signing can follow | Support-claim-proof-map has no OVERSTATED rows |
| S9 | Federation/trust-compact gated off-by-default before removal decision | Feature-flagged off = not reachable; deletion can wait for operator | Solo dogfood passes with feature off |

## PROHIBITED intermediate states (must never exist)

| Prohibited state | Why it is unsafe | Evidence of the risk |
|---|---|---|
| Two authority **issuers** (authority_engine grant AND DelegationProof both authorizing) | Divergent authority = no single boundary | A-01 |
| Agent credentials retained during broker migration | Window where agent has both creds and a new effect path | B-01, J-02 |
| Candidate-controlled provider-write path still live after "verifier moved" is claimed | Verifier bypass persists behind a false claim | C-003 |
| Two writable runtime sources of truth (SQLite AND YAML both authoritative) | Split-brain, torn invariants | D-01, D-03 |
| Publication without exact source/target binding | Target-race / wrong-SHA landing | J-03 |
| Trust activation before rollback exists | An activation fault has no safe exit | F-018-1 |
| Support claims stronger than implemented proof at any promotion point | Misplaced trust is itself the failure | E-01, J-05 |
| Broker + second control plane both holding credentials (e.g. broker AND AUTONOMY_PAT CI merge) | Two credentialed planes = the second-broker anti-pattern | J-07 |
| Managed git hooks live while sanitized adapter is claimed complete | Hook executes under operator creds behind a false claim | C-002 |

## Ordering consequence

Because S1–S9 are the only safe partial states, the packet order is constrained:
PP-00 (honest claims) must precede any privileged work; PP-01/02/03 must precede
PP-04 (the broker needs the guard, the isolation, and the store); PP-05/06 depend
on PP-04; PP-07 depends on PP-03/04/05/06; PP-08 depends on PP-07. Any ordering
that would create a prohibited state above is rejected. See the dependency graph.
